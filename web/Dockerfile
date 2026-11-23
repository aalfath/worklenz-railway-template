# Worklenz web: the official frontend build served by nginx, which also proxies
# the API, the realtime socket and file storage on the same public domain.
FROM chamikajaycey/worklenz-frontend:3.4.2@sha256:e487c11f4b6ddcc0cac029a8b74830cfd95d8f08cce66b19c6981470d7b19e79 AS frontend

FROM nginx:1.30.7-alpine@sha256:caf4e1e032a20f9c3c5e28fc7f25ffd768ad8677b4975c54193075997b3a97e3
RUN rm -f /etc/nginx/conf.d/default.conf
COPY --from=frontend /app/build /usr/share/nginx/html
# The browser talks to the API on the same origin, so no URL has to be baked in.
COPY env-config.js /usr/share/nginx/html/env-config.js
COPY nginx.conf /etc/nginx/nginx.conf
COPY worklenz.conf.template /etc/nginx/templates/worklenz.conf.template
COPY proxy_headers.conf /etc/nginx/proxy_headers.conf
ENV PORT=8080 \
    BACKEND_HOST=backend \
    BACKEND_PORT=3000 \
    STORAGE_HOST=seaweedfs \
    STORAGE_PORT=8333 \
    S3_BUCKET=worklenz-bucket \
    NGINX_ENTRYPOINT_LOCAL_RESOLVERS=1 \
    NGINX_ENTRYPOINT_WORKER_PROCESSES_AUTOTUNE=0
EXPOSE 8080
