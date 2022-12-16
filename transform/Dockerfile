# Image provides an all-in-one (AIO) container in which to run core transformations for Alfresco Content Services.

# Tika is from Apache. See the license at http://www.apache.org/licenses/LICENSE-2.0.
# LibreOffice is from The Document Foundation. See the license at https://www.libreoffice.org/download/license/ or in /libreoffice.txt.
# ImageMagick is from ImageMagick Studio LLC. See the license at http://www.imagemagick.org/script/license.php or in /ImageMagick-license.txt.
# alfresco-pdf-renderer uses the PDFium library from Google Inc. See the license at https://pdfium.googlesource.com/pdfium/+/master/LICENSE or in /pdfium.txt.

FROM alfresco/alfresco-base-java:jdk17-rockylinux8

ARG TRANSFORM_VERSION
ENV TRANSFORM_VERSION $TRANSFORM_VERSION

ARG EXIFTOOL_VERSION=12.25
ARG EXIFTOOL_FOLDER=Image-ExifTool-${EXIFTOOL_VERSION}
ARG EXIFTOOL_URL=https://nexus.alfresco.com/nexus/service/local/repositories/thirdparty/content/org/exiftool/image-exiftool/${EXIFTOOL_VERSION}/image-exiftool-${EXIFTOOL_VERSION}.tgz

ENV ALFRESCO_PDF_RENDERER_LIB_RPM_URL=https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-pdf-renderer/1.1/alfresco-pdf-renderer-1.1-linux.tgz

ENV JAVA_OPTS=""

# Set default user information
ARG GROUPNAME=Alfresco
ARG GROUPID=1000
ARG AIOUSERNAME=transform-all-in-one
ARG USERID=33017

RUN yum -y update && yum -y install wget cairo cups-libs libSM libGLU
RUN yum -y install --skip-broken libreoffice-*
RUN dnf install epel-release -y && dnf config-manager --set-enabled powertools && \
    dnf install -y ImageMagick ImageMagick-devel && dnf -y install perl-Image-ExifTool

RUN ln -s /usr/lib64/ImageMagick-7.0.10 /usr/lib64/ImageMagick-6.9.12
RUN ln -s /usr/lib64/libreoffice /opt/libreoffice7.2

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

RUN if [[ $TRANSFORM_VERSION = 3* ]]; then \
      wget https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-transform-core-aio/$TRANSFORM_VERSION/alfresco-transform-core-aio-$TRANSFORM_VERSION.jar && \
      cp alfresco-transform-core-aio-$TRANSFORM_VERSION.jar /usr/bin && \
      ln /usr/bin/alfresco-transform-core-aio-$TRANSFORM_VERSION.jar /usr/bin/alfresco-transform-core-aio.jar; \
    else \
      wget https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-transform-core-aio-boot/$TRANSFORM_VERSION/alfresco-transform-core-aio-boot-$TRANSFORM_VERSION.jar && \
      cp alfresco-transform-core-aio-boot-$TRANSFORM_VERSION.jar /usr/bin && \
      ln /usr/bin/alfresco-transform-core-aio-boot-$TRANSFORM_VERSION.jar /usr/bin/alfresco-transform-core-aio.jar; \
    fi

EXPOSE 8090

RUN groupadd -g ${GROUPID} ${GROUPNAME} && \
    useradd -u ${USERID} -G ${GROUPNAME} ${AIOUSERNAME} && \
    chgrp -R ${GROUPNAME} /usr/bin/alfresco-transform-core-aio.jar

USER ${AIOUSERNAME}

ENTRYPOINT /usr/lib/jvm/java-17/bin/java $JAVA_OPTS -jar /usr/bin/alfresco-transform-core-aio.jar