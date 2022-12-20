FROM alfresco/alfresco-base-tomcat:tomcat9-jre17-rockylinux8-202209261711

# Set default environment args
ARG TOMCAT_DIR=/usr/local/tomcat

# Set default user information
ARG GROUPNAME=Alfresco
ARG GROUPID=1000
ARG IMAGEUSERNAME=alfresco
ARG USERID=33000

# Alfresco Repository Version
ARG ALFRESCO_VERSION
ENV ALFRESCO_VERSION $ALFRESCO_VERSION

# Nexus credentials
ARG NEXUS_USER
ENV NEXUS_USER $NEXUS_USER
ARG NEXUS_PASS
ENV NEXUS_PASS $NEXUS_PASS

# Create prerequisite to store tools and properties
RUN mkdir -p ${TOMCAT_DIR}/shared/classes/alfresco/extension/mimetypes && \
    mkdir -p ${TOMCAT_DIR}/shared/classes/alfresco/extension/transform/renditions && \
    mkdir -p ${TOMCAT_DIR}/shared/classes/alfresco/extension/transform/pipelines && \
    mkdir -p ${TOMCAT_DIR}/shared/classes/alfresco/extension/querysets && \
    mkdir /licenses && \
    mkdir -p ${TOMCAT_DIR}/shared/classes/alfresco/extension/keystore && \
    mkdir ${TOMCAT_DIR}/alfresco-mmt && \
    touch ${TOMCAT_DIR}/shared/classes/alfresco-global.properties

RUN yum install -y unzip && \
    curl --user $NEXUS_USER:$NEXUS_PASS \
    https://nexus.alfresco.com/nexus/service/local/repo_groups/private/content/org/alfresco/alfresco-content-services-distribution/$ALFRESCO_VERSION/alfresco-content-services-distribution-$ALFRESCO_VERSION.zip -o alfresco-content-services-distribution-$ALFRESCO_VERSION.zip \
    && mkdir target && mv alfresco-content-services-distribution-$ALFRESCO_VERSION.zip target/ && cd target \
    && unzip alfresco-content-services-distribution-$ALFRESCO_VERSION.zip \
    && cd ..

# Copy the WAR files to the appropriate location for your application server
# Copy the JDBC drivers for the database you are using to the lib/ directory.
# Copy the alfresco-mmt.jar
# Copy Licenses to the root of the Docker image
# Copy default keystore
RUN cp -r target/web-server/webapps/alfresco.war ${TOMCAT_DIR}/webapps && \
    unzip ${TOMCAT_DIR}/webapps/alfresco.war -d ${TOMCAT_DIR}/webapps/alfresco && \
    rm ${TOMCAT_DIR}/webapps/alfresco.war && \
    cp -r target/web-server/lib/*.jar ${TOMCAT_DIR}/lib/ && \
    cp -r target/bin/* ${TOMCAT_DIR}/alfresco-mmt/ && \
    cp -r target/licenses/* /licenses/ && \
    cp -r target/keystore/metadata-keystore/* ${TOMCAT_DIR}/shared/classes/alfresco/extension/keystore

# Change the value of the shared.loader= property to the following:
# shared.loader=${catalina.base}/shared/classes
RUN sed -i "s/shared.loader=/shared.loader=\${catalina.base}\/shared\/classes/" ${TOMCAT_DIR}/conf/catalina.properties

# Install api-explorer (cut to three elements version number)
RUN API_EXPLORER_VERSION=$(echo "$ALFRESCO_VERSION" | cut -c1-5) && \
    curl https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/api-explorer/$API_EXPLORER_VERSION/api-explorer-$API_EXPLORER_VERSION.war \
    -o api-explorer.war && mv api-explorer.war ${TOMCAT_DIR}/webapps/

RUN mkdir -p ${TOMCAT_DIR}/amps

# Copy the amps from build context to the appropriate location for your application server
RUN cp -r target/amps/* ${TOMCAT_DIR}/amps

# Install amps on alfresco.war
RUN java -jar ${TOMCAT_DIR}/alfresco-mmt/alfresco-mmt.jar install \
              ${TOMCAT_DIR}/amps \
              ${TOMCAT_DIR}/webapps/alfresco -directory -nobackup

# Move the log file
RUN sed -i -e "s_appender.rolling.fileName\=alfresco.log_appender.rolling.fileName\=${TOMCAT_DIR}/logs\/alfresco.log_" \
        ${TOMCAT_DIR}/webapps/alfresco/WEB-INF/classes/log4j.properties && \
    sed -i -e "s_appender.rolling.filePattern=alfresco.log.%d{yyyy-MM-dd}_appender.rolling.filePattern\=${TOMCAT_DIR}/logs\/alfresco.log.%d{yyyy-MM-dd}_" \
        ${TOMCAT_DIR}/webapps/alfresco/WEB-INF/classes/log4j.properties && \
    sed -i -e "s_log4j.appender.File.File\=alfresco.log_log4j.appender.File.File\=${TOMCAT_DIR}/logs\/alfresco.log_" \
        ${TOMCAT_DIR}/webapps/alfresco/WEB-INF/classes/log4j.properties && \
# Add catalina.policy to ROOT.war and alfresco.war
# Grant all security permissions to alfresco webapp because of numerous permissions required in order to work properly.
# Grant only deployXmlPermission to ROOT webapp.
    sed -i -e "\$a\grant\ codeBase\ \"file:\$\{catalina.base\}\/webapps\/alfresco\/-\" \{\n\    permission\ java.security.AllPermission\;\n\};\ngrant\ codeBase\ \"file:\$\{catalina.base\}\/webapps\/_vti_bin\/-\" \{\n\    permission\ java.security.AllPermission\;\n\};\ngrant\ codeBase\ \"file:\$\{catalina.base\}\/webapps\/ROOT\/-\" \{\n\    permission org.apache.catalina.security.DeployXmlPermission \"ROOT\";\n\};" ${TOMCAT_DIR}/conf/catalina.policy

# fontconfig is required by Activiti worflow diagram generator
# installing pinned dependencies as well
RUN yum install -y fontconfig-2.13.1-4.el8 \
                   dejavu-fonts-common-2.35-7.el8 \
                   fontpackages-filesystem-1.44-22.el8 \
                   freetype-2.9.1-4.el8_3.1 \
                   libpng-1.6.34-5.el8 \
                   dejavu-sans-fonts-2.35-7.el8 && \
    yum clean all

# The standard configuration is to have all Tomcat files owned by root with group GROUPNAME and whilst owner has read/write privileges,
# group only has restricted permissions and world has no permissions.
RUN mkdir -p ${TOMCAT_DIR}/conf/Catalina/localhost && \
    mkdir -p ${TOMCAT_DIR}/alf_data && \
    groupadd -g ${GROUPID} ${GROUPNAME} && \
    useradd -u ${USERID} -G ${GROUPNAME} ${IMAGEUSERNAME} && \
    chgrp -R ${GROUPNAME} ${TOMCAT_DIR} && \
    chmod g+rx ${TOMCAT_DIR}/conf && \
    chmod -R g+r ${TOMCAT_DIR}/conf && \
    find ${TOMCAT_DIR}/webapps -type d -exec chmod 0750 {} \; && \
    find ${TOMCAT_DIR}/webapps -type f -exec chmod 0640 {} \; && \
    chmod -R g+r ${TOMCAT_DIR}/webapps && \
    chmod g+r ${TOMCAT_DIR}/conf/Catalina && \
    chmod g+rwx ${TOMCAT_DIR}/alf_data && \
    chmod g+rwx ${TOMCAT_DIR}/logs && \
    chmod o-w ${TOMCAT_DIR}/logs && \
    chmod g+rwx ${TOMCAT_DIR}/temp && \
    chmod g+rwx ${TOMCAT_DIR}/work && \
    chmod o-w ${TOMCAT_DIR}/work && \
    chmod 664 ${TOMCAT_DIR}/alfresco-mmt/alfresco-mmt*.jar && \
    chown -R ${USERID} ${TOMCAT_DIR}/* && \
    find /licenses -type d -exec chmod 0755 {} \; && \
    find /licenses -type f -exec chmod 0644 {} \;

# For remote debug
EXPOSE 8000

USER ${IMAGEUSERNAME}    