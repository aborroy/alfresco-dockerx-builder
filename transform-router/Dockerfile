FROM alfresco/alfresco-base-java:jre17-rockylinux8-202209261621

ARG TRANSFORM_ROUTER_VERSION
ENV TRANSFORM_ROUTER_VERSION $TRANSFORM_ROUTER_VERSION

# Nexus credentials
ARG NEXUS_USER
ENV NEXUS_USER $NEXUS_USER
ARG NEXUS_PASS
ENV NEXUS_PASS $NEXUS_PASS

ENV JAVA_OPTS=""
ENV JAVA_OPTS_CONTAINER_FLAGS=""

# Set default user information
ARG GROUPNAME=Alfresco
ARG GROUPID=1000
ARG ROUTERUSERNAME=trouter
ARG USERID=33016

RUN curl --user $NEXUS_USER:$NEXUS_PASS \
    https://nexus.alfresco.com/nexus/service/local/repositories/enterprise-releases/content/org/alfresco/alfresco-transform-router/$TRANSFORM_ROUTER_VERSION/alfresco-transform-router-$TRANSFORM_ROUTER_VERSION.jar \
    -o alfresco-transform-router.jar

RUN groupadd -g ${GROUPID} ${GROUPNAME} && \
    useradd -u ${USERID} -G ${GROUPNAME} ${ROUTERUSERNAME} && \
    chgrp -R ${GROUPNAME} alfresco-transform-router.jar

EXPOSE 8095 8443

USER ${ROUTERUSERNAME}

ENTRYPOINT java ${JAVA_OPTS} ${JAVA_OPTS_CONTAINER_FLAGS} -jar alfresco-transform-router.jar