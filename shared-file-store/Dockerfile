FROM alfresco/alfresco-base-java:jre17-rockylinux8-202209261621

ARG SHARED_FILE_STORE_VERSION
ENV SHARED_FILE_STORE_VERSION $SHARED_FILE_STORE_VERSION

# Nexus credentials
ARG NEXUS_USER
ENV NEXUS_USER $NEXUS_USER
ARG NEXUS_PASS
ENV NEXUS_PASS $NEXUS_PASS

ENV JAVA_OPTS=""

# Set default user information
ARG GROUPNAME=Alfresco
ARG GROUPID=1000
ARG USERNAME=sfs
ARG USERID=33030

# Set default environment args
ARG FILE_STORE_DIR=/tmp/Alfresco

RUN curl --user $NEXUS_USER:$NEXUS_PASS \
    https://nexus.alfresco.com/nexus/service/local/repositories/enterprise-releases/content/org/alfresco/alfresco-shared-file-store-controller/$SHARED_FILE_STORE_VERSION/alfresco-shared-file-store-controller-$SHARED_FILE_STORE_VERSION.jar \
    -o alfresco-shared-file-store.jar && \
    cp alfresco-shared-file-store.jar /usr/bin

# The standard configuration is to have all files owned by root with group GROUPNAME and whilst owner has read/write privileges,
# group only has restricted permissions and world has no permissions.
RUN mkdir -p ${FILE_STORE_DIR} && \
    groupadd -g ${GROUPID} ${GROUPNAME} && \
    useradd -u ${USERID} -G ${GROUPNAME} ${USERNAME} && \
    chgrp -R ${GROUPNAME} ${FILE_STORE_DIR} && \
    chmod g+rwx ${FILE_STORE_DIR} && \
    chgrp -R ${GROUPNAME} /usr/bin/alfresco-shared-file-store.jar

EXPOSE 8099

USER ${USERNAME}
ENTRYPOINT java $JAVA_OPTS -jar /usr/bin/alfresco-shared-file-store.jar