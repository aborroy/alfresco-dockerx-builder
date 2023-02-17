ARG AGS_ENT_VERSION
FROM quay.io/alfresco/alfresco-governance-repository-enterprise:${AGS_ENT_VERSION} AS AGS
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
COPY --from=AGS --chown=${IMAGEUSERNAME}:${GROUPNAME} ${TOMCAT_DIR} ${TOMCAT_DIR}
RUN rm -r ${TOMCAT_DIR}/native-jni-lib && cp -r /tmp/native-jni-lib ${TOMCAT_DIR}/native-jni-lib

USER ${IMAGEUSERNAME}