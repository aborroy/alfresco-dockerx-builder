FROM alfresco/alfresco-base-java:jdk17-rockylinux8

ARG TRANSFORM_VERSION
ENV TRANSFORM_VERSION $TRANSFORM_VERSION

ARG IMAGEMAGICK_HOME_FOLDER
ENV IMAGEMAGICK_HOME_FOLDER $IMAGEMAGICK_HOME_FOLDER

ENV JAVA_OPTS=""

# Set default user information
ARG GROUPNAME=Alfresco
ARG GROUPID=1000
ARG AIOUSERNAME=transform-pdf-renderer
ARG USERID=33017

RUN yum -y update && yum -y install wget
RUN dnf install epel-release -y && dnf config-manager --set-enabled powertools && \
    dnf install -y ImageMagick ImageMagick-devel

RUN ln -s /usr/lib64/ImageMagick-7.0.10 ${IMAGEMAGICK_HOME_FOLDER}

# Replacement for alfresco-pdf-renderer by using ImageMagick
# Only covering the simple call (generate PNG for page 0 of the PDF): 
#   alfresco-pdf-renderer <input-pdf> <output-png>
# Additional parameters should be added:
# --version displays Alfresco PDF Renderer version number
# --width=<width> override page width in pixels
# --height=<height> override page height in pixels
# --maintain-aspect-ratio Maintain aspect ratio when resizing the page
# --allow-enlargement When maintaining the aspect ratio, allow one parameter to exceed the given height/width
# --page=<number> 0-based page number to be converted (default 0)
RUN echo 'convert -thumbnail x100 -background white -alpha remove $1[0] $2' >> /usr/bin/alfresco-pdf-renderer && \
    chmod +x /usr/bin/alfresco-pdf-renderer

RUN if [[ $TRANSFORM_VERSION = 3* || $TRANSFORM_VERSION = 4* ]]; then \
      wget https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-transform-pdf-renderer/$TRANSFORM_VERSION/alfresco-transform-pdf-renderer-$TRANSFORM_VERSION.jar && \
      cp alfresco-transform-pdf-renderer-$TRANSFORM_VERSION.jar /usr/bin && \
      ln /usr/bin/alfresco-transform-pdf-renderer-$TRANSFORM_VERSION.jar /usr/bin/alfresco-transform-pdf-renderer.jar; \
    else \    
      wget https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-transform-pdf-renderer-boot/$TRANSFORM_VERSION/alfresco-transform-pdf-renderer-boot-$TRANSFORM_VERSION.jar && \
      cp alfresco-transform-pdf-renderer-boot-$TRANSFORM_VERSION.jar /usr/bin && \
      ln /usr/bin/alfresco-transform-pdf-renderer-boot-$TRANSFORM_VERSION.jar /usr/bin/alfresco-transform-pdf-renderer.jar; \
    fi

EXPOSE 8090

RUN groupadd -g ${GROUPID} ${GROUPNAME} && \
    useradd -u ${USERID} -G ${GROUPNAME} ${AIOUSERNAME} && \
    chgrp -R ${GROUPNAME} /usr/bin/alfresco-transform-pdf-renderer.jar

USER ${AIOUSERNAME}

ENTRYPOINT /usr/lib/jvm/java-17/bin/java $JAVA_OPTS -jar /usr/bin/alfresco-transform-pdf-renderer.jar