FROM alfresco/alfresco-base-tomcat:tomcat9-jre11-centos7-202209261711

ARG SHARE_INTERNAL_VERSION
ENV SHARE_INTERNAL_VERSION $SHARE_INTERNAL_VERSION

RUN yum -y update && yum -y install wget unzip

RUN wget https://nexus.alfresco.com/nexus/service/local/repo_groups/public/content/org/alfresco/alfresco-share-base-distribution/$SHARE_INTERNAL_VERSION/alfresco-share-base-distribution-$SHARE_INTERNAL_VERSION.zip \
    && unzip alfresco-share-base-distribution-*.zip

RUN mkdir -p /usr/local/tomcat/shared/classes/alfresco/web-extension
RUN mkdir -p /usr/local/tomcat/amps_share
RUN mkdir -p /usr/local/tomcat/alfresco-mmt
RUN mkdir /licenses

RUN cp alfresco-share-base-distribution-*/web-server/webapps/* /usr/local/tomcat/webapps
RUN mkdir /usr/local/tomcat/webapps/share && \
    unzip /usr/local/tomcat/webapps/share.war -d /usr/local/tomcat/webapps/share && \
    rm /usr/local/tomcat/webapps/share.war
RUN cp alfresco-share-base-distribution-*/bin/* /usr/local/tomcat/alfresco-mmt/

RUN cp alfresco-share-base-distribution-*/web-extension-samples/share-config-custom.xml /usr/local/tomcat/shared/classes/alfresco/web-extension
RUN cp alfresco-share-base-distribution-*/web-extension-samples/smartfolders-amp-actions-config.xml /usr/local/tomcat/shared/classes/alfresco/web-extension

RUN cp alfresco-share-base-distribution-*/licenses/* /licenses/

RUN rm -rf alfresco-share-base-distribution-*

RUN sed -i "s/shared.loader=/shared.loader=\${catalina.base}\/shared\/classes/" /usr/local/tomcat/conf/catalina.properties

# Increase resource caching size
RUN sed -i "s|<Context>|<Context>\n<Resources cacheMaxSize=\"51200\"/> |g" /usr/local/tomcat/conf/context.xml

RUN curl https://raw.githubusercontent.com/Alfresco/alfresco-community-share/$SHARE_INTERNAL_VERSION/packaging/docker/substituter.sh \
    -o /usr/local/tomcat/shared/classes/alfresco/substituter.sh
RUN curl https://raw.githubusercontent.com/Alfresco/alfresco-community-share/$SHARE_INTERNAL_VERSION/packaging/docker/src/main/resources/web-extension-samples/share-config-custom.xml \
    -o /usr/local/tomcat/shared/classes/alfresco/web-extension/share-config-custom.xml
RUN chmod +x /usr/local/tomcat/shared/classes/alfresco/substituter.sh

# apply amps
RUN java -jar /usr/local/tomcat/alfresco-mmt/alfresco-mmt*.jar install \
              /usr/local/tomcat/amps_share /usr/local/tomcat/webapps/share -directory -nobackup -force

ENTRYPOINT ["/usr/local/tomcat/shared/classes/alfresco/substituter.sh", "catalina.sh run"]