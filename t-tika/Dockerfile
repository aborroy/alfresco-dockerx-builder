FROM alfresco/alfresco-base-java:jdk17-rockylinux8

ARG TRANSFORM_VERSION
ENV TRANSFORM_VERSION $TRANSFORM_VERSION

ARG EXIFTOOL_VERSION=12.25
ARG EXIFTOOL_FOLDER=Image-ExifTool-${EXIFTOOL_VERSION}
ARG EXIFTOOL_URL=https://nexus.alfresco.com/nexus/service/local/repositories/thirdparty/content/org/exiftool/image-exiftool/${EXIFTOOL_VERSION}/image-exiftool-${EXIFTOOL_VERSION}.tgz

ENV JAVA_OPTS=""

# Set default user information
ARG GROUPNAME=Alfresco
ARG GROUPID=1000
ARG AIOUSERNAME=transform-tika
ARG USERID=33017

RUN yum -y update && yum -y install wget

RUN if [[ $TRANSFORM_VERSION = 3* || $TRANSFORM_VERSION = 4* ]]; then \
      wget https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-transform-tika/$TRANSFORM_VERSION/alfresco-transform-tika-$TRANSFORM_VERSION.jar && \
      cp alfresco-transform-tika-$TRANSFORM_VERSION.jar /usr/bin && \
      ln /usr/bin/alfresco-transform-tika-$TRANSFORM_VERSION.jar /usr/bin/alfresco-transform-tika.jar; \
    else \
      wget https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-transform-tika-boot/$TRANSFORM_VERSION/alfresco-transform-tika-boot-$TRANSFORM_VERSION.jar && \
      cp alfresco-transform-tika-boot-$TRANSFORM_VERSION.jar /usr/bin && \
      ln /usr/bin/alfresco-transform-tika-boot-$TRANSFORM_VERSION.jar /usr/bin/alfresco-transform-tika.jar; \
    fi

EXPOSE 8090

RUN groupadd -g ${GROUPID} ${GROUPNAME} && \
    useradd -u ${USERID} -G ${GROUPNAME} ${AIOUSERNAME} && \
    chgrp -R ${GROUPNAME} /usr/bin/alfresco-transform-tika.jar

USER ${AIOUSERNAME}

ENTRYPOINT /usr/lib/jvm/java-17/bin/java $JAVA_OPTS -jar /usr/bin/alfresco-transform-tika.jar