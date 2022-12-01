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

RUN yum -y update && yum -y install wget unzip libreoffice-core
RUN dnf install epel-release -y && dnf config-manager --set-enabled powertools && \
    dnf install -y ImageMagick ImageMagick-devel && dnf -y install perl-Image-ExifTool

RUN ln -s /usr/lib64/libreoffice /opt/libreoffice7.2

RUN curl -s -S $ALFRESCO_PDF_RENDERER_LIB_RPM_URL -o alfresco-pdf-renderer-linux.tgz && \
    tar xf alfresco-pdf-renderer-linux.tgz -C /usr/bin && \
 	rm -f alfresco-pdf-renderer-linux.tgz

RUN wget https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-transform-core-aio/$TRANSFORM_VERSION/alfresco-transform-core-aio-$TRANSFORM_VERSION.jar && \
    cp alfresco-transform-core-aio-$TRANSFORM_VERSION.jar /usr/bin

RUN ln /usr/bin/alfresco-transform-core-aio-$TRANSFORM_VERSION.jar /usr/bin/alfresco-transform-core-aio.jar

EXPOSE 8090

RUN groupadd -g ${GROUPID} ${GROUPNAME} && \
    useradd -u ${USERID} -G ${GROUPNAME} ${AIOUSERNAME} && \
    chgrp -R ${GROUPNAME} /usr/bin/alfresco-transform-core-aio.jar

USER ${AIOUSERNAME}

ENTRYPOINT /usr/lib/jvm/java-17/bin/java $JAVA_OPTS -jar /usr/bin/alfresco-transform-core-aio.jar