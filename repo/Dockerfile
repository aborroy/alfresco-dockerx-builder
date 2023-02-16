ARG ALFRESCO_VERSION=7.3.1
FROM quay.io/alfresco/alfresco-content-repository:${ALFRESCO_VERSION} AS REPO
FROM alfresco/alfresco-base-tomcat:tomcat9-jre17-rockylinux8-202209261711

ARG TOMCAT_DIR=/usr/local/tomcat
ARG USERID=33000
ARG GROUPID=1000

COPY --from=REPO --chown=${USERID}:${GROUPID} ${TOMCAT_DIR} ${TOMCAT_DIR}

USER ${USERID}