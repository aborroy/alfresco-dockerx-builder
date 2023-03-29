ARG TRANSFORM_ROUTER_VERSION
FROM quay.io/alfresco/alfresco-transform-router:${TRANSFORM_ROUTER_VERSION} AS TR
FROM alfresco/alfresco-base-java:jre17-rockylinux8-202209261621

ENV JAVA_OPTS=""
ENV JAVA_OPTS_CONTAINER_FLAGS=""

# Set default user information
ARG GROUPNAME=Alfresco
ARG GROUPID=1000
ARG ROUTERUSERNAME=trouter
ARG USERID=33016

COPY --from=TR /*.jar /

RUN groupadd -g ${GROUPID} ${GROUPNAME} && \
    useradd -u ${USERID} -G ${GROUPNAME} ${ROUTERUSERNAME} && \
    chgrp -R ${GROUPNAME} alfresco-transform-router.jar

USER ${ROUTERUSERNAME}

ENTRYPOINT java ${JAVA_OPTS} ${JAVA_OPTS_CONTAINER_FLAGS} -jar alfresco-transform-router.jar