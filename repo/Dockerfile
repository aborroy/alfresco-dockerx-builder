ARG ALFRESCO_VERSION
FROM alfresco/alfresco-content-repository-community:${ALFRESCO_VERSION} AS REPO
FROM alfresco/alfresco-base-tomcat:tomcat9-jre17-rockylinux8-202209261711

ARG TOMCAT_DIR=/usr/local/tomcat
# Set default user information
ARG GROUPNAME=Alfresco
ARG GROUPID=1000
ARG IMAGEUSERNAME=alfresco
ARG USERID=33000

RUN groupadd -g ${GROUPID} ${GROUPNAME} && \
    useradd -u ${USERID} -G ${GROUPNAME} ${IMAGEUSERNAME}

RUN cp -r ${TOMCAT_DIR}/native-jni-lib /tmp/native-jni-lib
COPY --from=REPO --chown=${IMAGEUSERNAME}:${GROUPNAME} ${TOMCAT_DIR} ${TOMCAT_DIR}
RUN rm -r ${TOMCAT_DIR}/native-jni-lib && cp -r /tmp/native-jni-lib ${TOMCAT_DIR}/native-jni-lib

# fontconfig is required by Activiti worflow diagram generator
# installing pinned dependencies as well
RUN yum install -y fontconfig-2.13.1-4.el8 \
                   dejavu-fonts-common-2.35-7.el8 \
                   fontpackages-filesystem-1.44-22.el8 \
                   freetype-2.9.1-9.el8 \
                   libpng-1.6.34-5.el8 \
                   dejavu-sans-fonts-2.35-7.el8 && \
    yum clean all

USER ${IMAGEUSERNAME}