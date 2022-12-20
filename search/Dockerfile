FROM alfresco/alfresco-base-java:jre11-rockylinux8-202209261621

ARG DIST_DIR
ENV DIST_DIR $DIST_DIR
ENV LANG C.UTF-8

# Get values from ENV VARS or use default values if ENV VARS are not specified
ENV SOLR_DATA_DIR_ROOT=${SOLR_DATA_DIR_ROOT:-$DIST_DIR/data}
ENV SOLR_SOLR_MODEL_DIR=${SOLR_SOLR_MODEL_DIR:-$DIST_DIR/data/alfrescoModels}

ARG USERNAME=solr
ARG USERID=33007

ARG SEARCH_VERSION
ENV SEARCH_VERSION $SEARCH_VERSION

# Nexus credentials (only for Insight Engine)
ARG NEXUS_USER
ENV NEXUS_USER $NEXUS_USER
ARG NEXUS_PASS
ENV NEXUS_PASS $NEXUS_PASS

RUN if [ "$DIST_DIR" == "/opt/alfresco-insight-engine" ]; then \
    curl --user $NEXUS_USER:$NEXUS_PASS \
    https://nexus.alfresco.com/nexus/service/local/repositories/enterprise-releases/content/org/alfresco/alfresco-insight-engine-distribution/${SEARCH_VERSION}/alfresco-insight-engine-distribution-${SEARCH_VERSION}.zip \
    -o solr.zip; \
else \
    curl https://nexus.alfresco.com/nexus/service/local/repositories/releases/content/org/alfresco/alfresco-search-services/${SEARCH_VERSION}/alfresco-search-services-${SEARCH_VERSION}.zip \
    -o solr.zip; \
fi

RUN curl https://raw.githubusercontent.com/Alfresco/SearchServices/master/search-services/packaging/src/docker/search_config_setup.sh \
    -o search_config_setup.sh

RUN set -x \
   && useradd \
        -c "Alfresco ${USERNAME}" \
        -M \
        -s "/bin/bash" \
        -u "${USERID}" \
        -o \
        "${USERNAME}" \
   && yum install -y unzip \
   && yum install -y lsof ca-certificates \
   && yum install -y wget \
   && yum clean all \
   && unzip solr.zip -d /opt/ && rm solr.zip \
   && mkdir -p $DIST_DIR/data \
   && mv $DIST_DIR/solrhome/alfrescoModels $DIST_DIR/data/ \
   && chown -R ${USERNAME}:${USERNAME} $DIST_DIR \
   && echo '#Docker Setup' >> $DIST_DIR/solr.in.sh \
   && echo 'SOLR_OPTS="$SOLR_OPTS -Dsolr.data.dir.root=$SOLR_DATA_DIR_ROOT -Dsolr.solr.model.dir=$SOLR_SOLR_MODEL_DIR"' >> $DIST_DIR/solr.in.sh

RUN cp search_config_setup.sh $DIST_DIR/solr/bin/ && \
    chmod +x $DIST_DIR/solr/bin/search_config_setup.sh

# Add the licenses to a root directory.
RUN mv $DIST_DIR/licenses /licenses

WORKDIR $DIST_DIR

VOLUME $DIST_DIR/data
VOLUME $DIST_DIR/solrhome
# Expose a folder to mount keystores in the host (required for Mutual TLS Auth)
VOLUME $DIST_DIR/keystores

# SOLR Service Port
EXPOSE 8983

USER ${USERNAME}
CMD $DIST_DIR/solr/bin/search_config_setup.sh "$DIST_DIR/solr/bin/solr start -f"