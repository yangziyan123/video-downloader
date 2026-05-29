ARG NODE_IMAGE=node:22-alpine
FROM ${NODE_IMAGE} AS build

WORKDIR /app

COPY frontend/package*.json ./
RUN npm ci

COPY frontend/ ./
RUN npm run build

ARG NGINX_IMAGE=nginx:1.27-alpine
FROM ${NGINX_IMAGE}

COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
