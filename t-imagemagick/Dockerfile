FROM alfresco/alfresco-base-java:jdk17-rockylinux8

ARG TRANSFORM_VERSION
ENV TRANSFORM_VERSION $TRANSFORM_VERSION

ARG IMAGEMAGICK_HOME_FOLDER
ENV IMAGEMAGICK_HOME_FOLDER $IMAGEMAGICK_HOME_FOLDER

ENV JAVA_OPTS=""

# Set default user information
ARG GROUPNAME=Alfresco
ARG GROUPID=1000
ARG AIOUSERNAME=transform-imagemagick
ARG USERID=33017

RUN yum -y update && yum -y install wget
RUN dnf install epel-release -y && dnf config-manager --set-enabled powertools && \
    dnf install -y ImageMagick ImageMagick-devel

RUN ln -s /usr/lib64/ImageMagick-7.0.10 ${IMAGEMAGICK_HOME_FOLDER}

RUN if [[ $TRANSFORM_VERSION = 3* || $TRANSFORM_VERSION = 4* ]]; then \
      wget https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-transform-imagemagick/$TRANSFORM_VERSION/alfresco-transform-imagemagick-$TRANSFORM_VERSION.jar && \
      cp alfresco-transform-imagemagick-$TRANSFORM_VERSION.jar /usr/bin && \
      ln /usr/bin/alfresco-transform-imagemagick-$TRANSFORM_VERSION.jar /usr/bin/alfresco-transform-imagemagick.jar; \
    else \
      wget https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-transform-imagemagick-boot/$TRANSFORM_VERSION/alfresco-transform-imagemagick-boot-$TRANSFORM_VERSION.jar && \
      cp alfresco-transform-imagemagick-boot-$TRANSFORM_VERSION.jar /usr/bin && \
      ln /usr/bin/alfresco-transform-imagemagick-boot-$TRANSFORM_VERSION.jar /usr/bin/alfresco-transform-imagemagick.jar; \
    fi

EXPOSE 8090

RUN groupadd -g ${GROUPID} ${GROUPNAME} && \
    useradd -u ${USERID} -G ${GROUPNAME} ${AIOUSERNAME} && \
    chgrp -R ${GROUPNAME} /usr/bin/alfresco-transform-imagemagick.jar

USER ${AIOUSERNAME}

ENTRYPOINT /usr/lib/jvm/java-17/bin/java $JAVA_OPTS -jar /usr/bin/alfresco-transform-imagemagick.jar