ARG PYTHON_IMAGE=python:3.11-slim
FROM ${PYTHON_IMAGE}

ARG APT_MIRROR=http://mirrors.aliyun.com/debian
ARG APT_SECURITY_MIRROR=http://mirrors.aliyun.com/debian-security
ARG PIP_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple
ARG PIP_TRUSTED_HOST=pypi.tuna.tsinghua.edu.cn

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_INDEX_URL=${PIP_INDEX_URL} \
    PIP_TRUSTED_HOST=${PIP_TRUSTED_HOST}

WORKDIR /app

RUN set -eux; \
    sed -i \
        -e "s|http://deb.debian.org/debian|${APT_MIRROR}|g" \
        -e "s|http://deb.debian.org/debian-security|${APT_SECURITY_MIRROR}|g" \
        /etc/apt/sources.list.d/debian.sources; \
    apt-get update -o Acquire::Retries=5 \
    && apt-get install -y --no-install-recommends ffmpeg ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt /app/requirements.txt
RUN pip install --retries 5 --timeout 120 -r /app/requirements.txt

COPY backend/ /app/

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
