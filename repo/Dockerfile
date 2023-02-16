ARG ALFRESCO_VERSION=7.3.1
FROM quay.io/alfresco/alfresco-content-repository:${ALFRESCO_VERSION} AS REPO
FROM alfresco/alfresco-base-tomcat:tomcat9-jre17-rockylinux8-202209261711

ARG TOMCAT_DIR=/usr/local/tomcat
# Set default user information
ARG GROUPNAME=Alfresco
ARG GROUPID=1000
ARG IMAGEUSERNAME=alfresco
ARG USERID=33000

RUN groupadd -g ${GROUPID} ${GROUPNAME} && \
    useradd -u ${USERID} -G ${GROUPNAME} ${IMAGEUSERNAME}

COPY --from=REPO --chown=${IMAGEUSERNAME}:${GROUPNAME} ${TOMCAT_DIR} ${TOMCAT_DIR}

USER ${IMAGEUSERNAME}