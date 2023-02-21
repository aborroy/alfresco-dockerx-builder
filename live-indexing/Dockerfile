ARG ESC_VERSION=3.2.0
FROM quay.io/alfresco/alfresco-elasticsearch-live-indexing:${ESC_VERSION} AS ESC
FROM alfresco/alfresco-base-java:jdk11-rockylinux8

COPY --from=ESC --chown=1000 /opt /opt

WORKDIR /opt
ENTRYPOINT exec java $JAVA_OPTS -jar app.jar