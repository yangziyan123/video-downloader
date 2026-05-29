ARG NODE_IMAGE=node:22-alpine
ARG NGINX_IMAGE=nginx:1.27-alpine
ARG NPM_REGISTRY=https://registry.npmmirror.com

FROM ${NODE_IMAGE} AS build

ARG NPM_REGISTRY

WORKDIR /app

COPY frontend/package*.json ./
RUN npm config set registry "${NPM_REGISTRY}" \
    && npm ci --registry="${NPM_REGISTRY}"

COPY frontend/ ./
RUN npm run build

FROM ${NGINX_IMAGE}

COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
