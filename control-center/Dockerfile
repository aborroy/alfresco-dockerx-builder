ARG CONTROL_CENTER_VERSION
FROM quay.io/alfresco/alfresco-control-center:${CONTROL_CENTER_VERSION} AS APP
FROM nginxinc/nginx-unprivileged:1.21-alpine

COPY --from=APP /usr/share/nginx/html/ /usr/share/nginx/html/ 
COPY --from=APP /etc/nginx/ /etc/nginx/
COPY --from=APP /docker-entrypoint.d/* /docker-entrypoint.d/

ENV APP_CONFIG_PROVIDER=$PROVIDER
ENV APP_CONFIG_AUTH_TYPE=$AUTH_TYPE
ENV BASE_PATH=$BASE_PATH

ENV SERVER_PORT=8080

USER 101

ENV NGINX_ENVSUBST_OUTPUT_DIR=/etc/nginx/conf.d