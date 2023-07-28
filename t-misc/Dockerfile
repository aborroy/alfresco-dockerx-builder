FROM alfresco/alfresco-base-java:jdk17-rockylinux8

ARG TRANSFORM_VERSION
ENV TRANSFORM_VERSION $TRANSFORM_VERSION

ENV JAVA_OPTS=""

# Set default user information
ARG GROUPNAME=Alfresco
ARG GROUPID=1000
ARG AIOUSERNAME=transform-misc
ARG USERID=33017

RUN yum -y update && yum -y install wget

RUN if [[ $TRANSFORM_VERSION = 3* || $TRANSFORM_VERSION = 4* ]]; then \
      wget https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-transform-misc/$TRANSFORM_VERSION/alfresco-transform-misc-$TRANSFORM_VERSION.jar && \
      cp alfresco-transform-misc-$TRANSFORM_VERSION.jar /usr/bin && \
      ln /usr/bin/alfresco-transform-misc-$TRANSFORM_VERSION.jar /usr/bin/alfresco-transform-misc.jar; \
    else \    
      wget https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-transform-misc-boot/$TRANSFORM_VERSION/alfresco-transform-misc-boot-$TRANSFORM_VERSION.jar && \
      cp alfresco-transform-misc-boot-$TRANSFORM_VERSION.jar /usr/bin && \
      ln /usr/bin/alfresco-transform-misc-boot-$TRANSFORM_VERSION.jar /usr/bin/alfresco-transform-misc.jar; \
    fi

EXPOSE 8090

RUN groupadd -g ${GROUPID} ${GROUPNAME} && \
    useradd -u ${USERID} -G ${GROUPNAME} ${AIOUSERNAME} && \
    chgrp -R ${GROUPNAME} /usr/bin/alfresco-transform-misc.jar

USER ${AIOUSERNAME}

ENTRYPOINT /usr/lib/jvm/java-17/bin/java $JAVA_OPTS -jar /usr/bin/alfresco-transform-misc.jar