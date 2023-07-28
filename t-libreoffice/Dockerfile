FROM alfresco/alfresco-base-java:jdk17-rockylinux8

ARG TRANSFORM_VERSION
ENV TRANSFORM_VERSION $TRANSFORM_VERSION

ARG LIBREOFFICE_HOME_FOLDER
ENV LIBREOFFICE_HOME_FOLDER $LIBREOFFICE_HOME_FOLDER

ENV JAVA_OPTS=""

# Set default user information
ARG GROUPNAME=Alfresco
ARG GROUPID=1000
ARG AIOUSERNAME=transform-libreoffice
ARG USERID=33017

RUN yum -y update && yum -y install wget cairo cups-libs libSM libGLU
RUN yum -y install --skip-broken libreoffice-*

RUN ln -s /usr/lib64/libreoffice ${LIBREOFFICE_HOME_FOLDER}

RUN if [[ $TRANSFORM_VERSION = 3* || $TRANSFORM_VERSION = 4* ]]; then \
      wget https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-transform-libreoffice/$TRANSFORM_VERSION/alfresco-transform-libreoffice-$TRANSFORM_VERSION.jar && \
      cp alfresco-transform-libreoffice-$TRANSFORM_VERSION.jar /usr/bin && \
      ln /usr/bin/alfresco-transform-libreoffice-$TRANSFORM_VERSION.jar /usr/bin/alfresco-transform-libreoffice.jar; \
    else \
      wget https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-transform-libreoffice-boot/$TRANSFORM_VERSION/alfresco-transform-libreoffice-boot-$TRANSFORM_VERSION.jar && \
      cp alfresco-transform-libreoffice-boot-$TRANSFORM_VERSION.jar /usr/bin && \
      ln /usr/bin/alfresco-transform-libreoffice-boot-$TRANSFORM_VERSION.jar /usr/bin/alfresco-transform-libreoffice.jar; \
    fi

EXPOSE 8090

RUN groupadd -g ${GROUPID} ${GROUPNAME} && \
    useradd -u ${USERID} -G ${GROUPNAME} ${AIOUSERNAME} && \
    chgrp -R ${GROUPNAME} /usr/bin/alfresco-transform-libreoffice.jar

USER ${AIOUSERNAME}

ENTRYPOINT /usr/lib/jvm/java-17/bin/java $JAVA_OPTS -jar /usr/bin/alfresco-transform-libreoffice.jar