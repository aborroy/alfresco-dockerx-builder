#!/bin/bash
# Build Alfresco Docker Images for ARM64
# Maven credentials required for building "*-ent" Docker Images

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Check dependencies
array=( "git" "ggrep" "wget" "mvn" "java" "docker" )
for i in "${array[@]}"
do
    command -v $i >/dev/null 2>&1 || { 
        echo >&2 "$i is required"; 
        exit 1; 
    }
done

# Home Folder
HOME_FOLDER=$PWD

# Configuration
REPOSITORY=alfresco
NEXUS_USER=
NEXUS_PASS=
PLATFORM_DOCKER=linux/arm64
CONTAINER_BUILD_CMD_DOCKER="docker buildx build . --load --platform $PLATFORM_DOCKER"
CMD_DOCKER=docker
PLATFORM_PODMAN=arm64
CONTAINER_BUILD_CMD_PODMAN="podman build . --arch=$PLATFORM_PODMAN"
CMD_PODMAN=podman

# Default is Docker
PLATFORM=$PLATFORM_DOCKER
CONTAINER_BUILD_CMD=$CONTAINER_BUILD_CMD_DOCKER
CMD=$CMD_DOCKER

# Docker Images building flags
REPO="false"
REPO_ENT="false"
AGS="false"
AGS_ENT="false"
SHARE="false"
SHARE_ENT="false"
AGS_SHARE="false"
AGS_SHARE_ENT="false"
SEARCH="false"
SEARCH_ENT="false"
TRANSFORM="false"
T_LIBREOFFICE="false"
T_IMAGEMAGICK="false"
T_MISC="false"
T_PDF_RENDERER="false"
T_TIKA="false"
TRANSFORM_ROUTER="false"
SHARED_FILE_STORE="false"
ACA="false"
ADW="false"
AAA="false"
PROXY="false"
PROXY_ENT="false"
IDENTITY="false"
ESC_LIVE_INDEXING="false"
ESC_LIVE_MEDIATION="false"
ESC_LIVE_CONTENT="false"
ESC_LIVE_METADATA="false"
ESC_LIVE_PATH="false"
ESC_RE_INDEXING="false"


function build {

  # Repository Community
  if [ "$REPO" == "true" ]; then
    cd repo
    $CONTAINER_BUILD_CMD \
    --build-arg ALFRESCO_VERSION=$REPO_COM_VERSION \
    -t $REPOSITORY/alfresco-content-repository-community:$REPO_COM_VERSION
    cd $HOME_FOLDER
  fi

  # Repository Enterprise
  if [ "$REPO_ENT" == "true" ]; then
    cd repo-ent
    $CONTAINER_BUILD_CMD \
    --build-arg ALFRESCO_VERSION=$REPO_ENT_VERSION \
    -t quay.io/$REPOSITORY/alfresco-content-repository:$REPO_ENT_VERSION
    cd $HOME_FOLDER
  fi

  # AGS Community Repo
  if [ "$AGS" == "true" ]; then
    cd ags
    $CONTAINER_BUILD_CMD \
    --build-arg AGS_VERSION=$AGS_VERSION \
    -t $REPOSITORY/alfresco-governance-repository-community:$AGS_VERSION
    cd $HOME_FOLDER
  fi

  # AGS Enterprise Repo
  if [ "$AGS_ENT" == "true" ]; then
    cd ags-ent
    $CONTAINER_BUILD_CMD \
    --build-arg AGS_ENT_VERSION=$AGS_ENT_VERSION \
    -t quay.io/$REPOSITORY/alfresco-governance-repository-enterprise:$AGS_ENT_VERSION
    cd $HOME_FOLDER
  fi

  # Share
  if [ "$SHARE" == "true" ]; then

    rm -rf acs-community-packaging
    git clone git@github.com:Alfresco/acs-community-packaging.git
    cd acs-community-packaging
    git checkout $SHARE_VERSION || { echo -e >&2 "Available tags:\n$(git tag -l "${SHARE_VERSION:0:5}*")"; exit 1; }
    SHARE_COM_VERSION=$(ggrep -oP '(?<=<dependency.alfresco-community-share.version>).*?(?=</dependency.alfresco-community-share.version>)' pom.xml)
    cd ..
    
    cd share
    $CONTAINER_BUILD_CMD \
    --build-arg SHARE_INTERNAL_VERSION=$SHARE_COM_VERSION \
    -t $REPOSITORY/alfresco-share:$SHARE_VERSION
    cd $HOME_FOLDER
  fi

  # Share Enterprise
  if [ "$SHARE_ENT" == "true" ]; then

    rm -rf acs-packaging
    git clone git@github.com:Alfresco/acs-packaging.git
    cd acs-packaging
    git checkout $SHARE_VERSION || { echo -e >&2 "Available tags:\n$(git tag -l "${SHARE_VERSION:0:5}*")"; exit 1; }
    SHARE_ENT_VERSION=$(ggrep -oP '(?<=<dependency.alfresco-enterprise-share.version>).*?(?=</dependency.alfresco-enterprise-share.version>)' pom.xml)
    cd ..
    
    cd share
    $CONTAINER_BUILD_CMD \
    --build-arg SHARE_INTERNAL_VERSION=$SHARE_ENT_VERSION \
    -t quay.io/$REPOSITORY/alfresco-share:$SHARE_VERSION
    cd $HOME_FOLDER
  fi

  # AGS Community Share
  if [ "$AGS_SHARE" == "true" ]; then
    cd ags-share
    $CONTAINER_BUILD_CMD  \
    --build-arg AGS_SHARE_VERSION=$AGS_SHARE_VERSION \
    -t $REPOSITORY/alfresco-governance-share-community:$AGS_SHARE_VERSION
    cd $HOME_FOLDER  
  fi
  
  # AGS Enterprise Share
  if [ "$AGS_SHARE_ENT" == "true" ]; then
    cd ags-share-ent
    $CONTAINER_BUILD_CMD  \
    --build-arg AGS_SHARE_ENT_VERSION=$AGS_SHARE_ENT_VERSION \
    -t quay.io/$REPOSITORY/alfresco-governance-share-enterprise:$AGS_SHARE_ENT_VERSION
    cd $HOME_FOLDER  
  fi

  # Search Services 
  if [ "$SEARCH" == "true" ]; then
    cd search
    $CONTAINER_BUILD_CMD \
    --build-arg SEARCH_VERSION=$SEARCH_VERSION \
    --build-arg DIST_DIR=/opt/alfresco-search-services \
    -t $REPOSITORY/alfresco-search-services:$SEARCH_VERSION    
    cd $HOME_FOLDER
  fi

  # Search Services Enterprise
  if [ "$SEARCH_ENT" == "true" ]; then
    cd search
    $CONTAINER_BUILD_CMD \
    --build-arg SEARCH_VERSION=$SEARCH_ENT_VERSION \
    --build-arg NEXUS_USER=$NEXUS_USER \
    --build-arg NEXUS_PASS=$NEXUS_PASS \
    --build-arg DIST_DIR=/opt/alfresco-insight-engine \
    -t quay.io/$REPOSITORY/alfresco-insight-engine:$SEARCH_ENT_VERSION
    cd $HOME_FOLDER
  fi

  # Transform Service
  if [ "$TRANSFORM" == "true" ]; then

    if wget -q --method=HEAD https://raw.githubusercontent.com/Alfresco/alfresco-transform-core/$TRANSFORM_VERSION/engines/aio/src/main/resources/application-default.yaml;
    then
      wget https://raw.githubusercontent.com/Alfresco/alfresco-transform-core/$TRANSFORM_VERSION/engines/aio/src/main/resources/application-default.yaml
    else
      wget https://raw.githubusercontent.com/Alfresco/alfresco-transform-core/$TRANSFORM_VERSION/alfresco-transform-core-aio/alfresco-transform-core-aio-boot/src/main/resources/application-default.yaml
    fi  

    LIBREOFFICE_HOME_FOLDER=$(ggrep -oP '(?<=path: \$\{LIBREOFFICE_HOME:).*?(?=\})' application-default.yaml)
    IMAGEMAGICK_HOME_FOLDER=$(ggrep -oP '(?<=root: \$\{IMAGEMAGICK_ROOT:).*?(?=\})' application-default.yaml)
    rm application-default.yaml

    cd transform
    $CONTAINER_BUILD_CMD \
    --build-arg TRANSFORM_VERSION=$TRANSFORM_VERSION \
    --build-arg IMAGEMAGICK_HOME_FOLDER=$IMAGEMAGICK_HOME_FOLDER \
    --build-arg LIBREOFFICE_HOME_FOLDER=$LIBREOFFICE_HOME_FOLDER \
    -t $REPOSITORY/alfresco-transform-core-aio:$TRANSFORM_VERSION
    cd $HOME_FOLDER

  fi

  # T-LibreOffice
  if [ "$T_LIBREOFFICE" == "true" ]; then

    wget https://raw.githubusercontent.com/Alfresco/alfresco-transform-core/$T_LIBREOFFICE_VERSION/engines/aio/src/main/resources/application-default.yaml
    LIBREOFFICE_HOME_FOLDER=$(ggrep -oP '(?<=path: \$\{LIBREOFFICE_HOME:).*?(?=\})' application-default.yaml)
    rm application-default.yaml  

    cd t-libreoffice
    $CONTAINER_BUILD_CMD \
    --build-arg TRANSFORM_VERSION=$T_LIBREOFFICE_VERSION \
    --build-arg LIBREOFFICE_HOME_FOLDER=$LIBREOFFICE_HOME_FOLDER \
    -t $REPOSITORY/alfresco-libreoffice:$T_LIBREOFFICE_VERSION
    cd $HOME_FOLDER
  
  fi

  # T-ImageMagick
  if [ "$T_IMAGEMAGICK" == "true" ]; then

    wget https://raw.githubusercontent.com/Alfresco/alfresco-transform-core/$T_IMAGEMAGICK_VERSION/engines/aio/src/main/resources/application-default.yaml
    IMAGEMAGICK_HOME_FOLDER=$(ggrep -oP '(?<=root: \$\{IMAGEMAGICK_ROOT:).*?(?=\})' application-default.yaml)
    rm application-default.yaml  

    cd t-imagemagick
    $CONTAINER_BUILD_CMD \
    --build-arg TRANSFORM_VERSION=$T_IMAGEMAGICK_VERSION \
    --build-arg IMAGEMAGICK_HOME_FOLDER=$IMAGEMAGICK_HOME_FOLDER \
    -t $REPOSITORY/alfresco-imagemagick:$T_IMAGEMAGICK_VERSION
    cd $HOME_FOLDER
  
  fi

  # T-Tika
  if [ "$T_TIKA" == "true" ]; then

    cd t-tika
    $CONTAINER_BUILD_CMD \
    --build-arg TRANSFORM_VERSION=$T_TIKA_VERSION \
    -t $REPOSITORY/alfresco-tika:$T_TIKA_VERSION
    cd $HOME_FOLDER
  
  fi    

  # T-PdfRenderer
  if [ "$T_PDF_RENDERER" == "true" ]; then

    wget https://raw.githubusercontent.com/Alfresco/alfresco-transform-core/$T_PDF_RENDERER_VERSION/engines/aio/src/main/resources/application-default.yaml
    IMAGEMAGICK_HOME_FOLDER=$(ggrep -oP '(?<=root: \$\{IMAGEMAGICK_ROOT:).*?(?=\})' application-default.yaml)
    rm application-default.yaml

    cd t-pdf-renderer
    $CONTAINER_BUILD_CMD \
    --build-arg TRANSFORM_VERSION=$T_PDF_RENDERER_VERSION \
    --build-arg IMAGEMAGICK_HOME_FOLDER=$IMAGEMAGICK_HOME_FOLDER \
    -t $REPOSITORY/alfresco-pdf-renderer:$T_PDF_RENDERER_VERSION
    cd $HOME_FOLDER
  
  fi

  # T-Misc
  if [ "$T_MISC" == "true" ]; then

    cd t-misc
    $CONTAINER_BUILD_CMD \
    --build-arg TRANSFORM_VERSION=$T_MISC_VERSION \
    -t $REPOSITORY/alfresco-transform-misc:$T_MISC_VERSION
    cd $HOME_FOLDER
  
  fi

  # Transform Router
  if [ "$TRANSFORM_ROUTER" == "true" ]; then

    cd transform-router
    $CONTAINER_BUILD_CMD \
    --build-arg TRANSFORM_ROUTER_VERSION=$TRANSFORM_ROUTER_VERSION \
    -t quay.io/$REPOSITORY/alfresco-transform-router:$TRANSFORM_ROUTER_VERSION
    cd $HOME_FOLDER

  fi

  # Shared File Store
  if [ "$SHARED_FILE_STORE" == "true" ]; then
    cd shared-file-store
    $CONTAINER_BUILD_CMD \
    --build-arg SHARED_FILE_STORE_VERSION=$SHARED_FILE_STORE_VERSION \
    -t quay.io/$REPOSITORY/alfresco-shared-file-store:$SHARED_FILE_STORE_VERSION
    cd $HOME_FOLDER
  fi    

  # ACA
  if [ "$ACA" == true ]; then
    cd aca
    $CONTAINER_BUILD_CMD \
    --build-arg ACA_VERSION=$ACA_VERSION \
    -t $REPOSITORY/alfresco-content-app:$ACA_VERSION
    cd $HOME_FOLDER
  fi

  # ADW
  if [ "$ADW" == true ]; then
    cd adw
    $CONTAINER_BUILD_CMD \
    --build-arg ADW_VERSION=$ADW_VERSION \
    -t quay.io/$REPOSITORY/alfresco-digital-workspace:$ADW_VERSION
    cd $HOME_FOLDER
  fi  

  # AAA
  if [ "$AAA" == true ]; then
    cd aaa
    $CONTAINER_BUILD_CMD \
    --build-arg AAA_VERSION=$AAA_VERSION \
    -t quay.io/$REPOSITORY/alfresco-admin-app:$AAA_VERSION
    cd $HOME_FOLDER
  fi

  # Proxy
  if [ "$PROXY" == "true" ] || [ "$PROXY_ENT" == "true" ]; then
    rm -rf acs-ingress
    git clone git@github.com:Alfresco/acs-ingress.git
    cd acs-ingress
    git checkout $PROXY_VERSION
    PREFIX=""
    if [ "$PROXY_ENT" == "true" ]; then
      PREFIX="quay.io/"
    fi
    $CONTAINER_BUILD_CMD \
    -t $PREFIX$REPOSITORY/alfresco-acs-nginx:$PROXY_VERSION
    cd $HOME_FOLDER
  fi

  # Identity
  if [ "$IDENTITY" == "true" ]; then

    cd identity
    $CONTAINER_BUILD_CMD \
    --build-arg IDENTITY_VERSION=$IDENTITY_VERSION \
    -t $REPOSITORY/alfresco-identity-service:$IDENTITY_VERSION
    cd $HOME_FOLDER

  fi    

  # Elasticsearch Connector
  if [ "$ESC_LIVE_INDEXING" == "true" ]; then

    cd live-indexing
    $CONTAINER_BUILD_CMD \
    --build-arg ESC_VERSION=$ESC_LIVE_INDEXING_VERSION \
    -t quay.io/$REPOSITORY/alfresco-elasticsearch-live-indexing:$ESC_LIVE_INDEXING_VERSION
    cd $HOME_FOLDER

  fi

  # Elasticsearch Connector - Mediation
  if [ "$ESC_LIVE_MEDIATION" == "true" ]; then

    cd live-indexing-mediation
    $CONTAINER_BUILD_CMD \
    --build-arg ESC_VERSION=$ESC_LIVE_MEDIATION_VERSION \
    -t quay.io/$REPOSITORY/alfresco-elasticsearch-live-indexing-mediation:$ESC_LIVE_MEDIATION_VERSION
    cd $HOME_FOLDER

  fi

  # Elasticsearch Connector - Content
  if [ "$ESC_LIVE_CONTENT" == "true" ]; then

    cd live-indexing-content
    $CONTAINER_BUILD_CMD \
    --build-arg ESC_VERSION=$ESC_LIVE_CONTENT_VERSION \
    -t quay.io/$REPOSITORY/alfresco-elasticsearch-live-indexing-content:$ESC_LIVE_CONTENT_VERSION
    cd $HOME_FOLDER

  fi

  # Elasticsearch Connector - Metadata
  if [ "$ESC_LIVE_METADATA" == "true" ]; then

    cd live-indexing-metadata
    $CONTAINER_BUILD_CMD \
    --build-arg ESC_VERSION=$ESC_LIVE_METADATA_VERSION \
    -t quay.io/$REPOSITORY/alfresco-elasticsearch-live-indexing-metadata:$ESC_LIVE_METADATA_VERSION
    cd $HOME_FOLDER

  fi

  # Elasticsearch Connector - Path
  if [ "$ESC_LIVE_PATH" == "true" ]; then

    cd live-indexing-path
    $CONTAINER_BUILD_CMD \
    --build-arg ESC_VERSION=$ESC_LIVE_PATH_VERSION \
    -t quay.io/$REPOSITORY/alfresco-elasticsearch-live-indexing-path:$ESC_LIVE_PATH_VERSION
    cd $HOME_FOLDER

  fi        

  # Elasticsearch Connector Reindexing
  if [ "$ESC_RE_INDEXING" == "true" ]; then

    cd re-indexing
    $CONTAINER_BUILD_CMD \
    --build-arg ESC_VERSION=$ESC_RE_INDEXING_VERSION \
    -t quay.io/$REPOSITORY/alfresco-elasticsearch-reindexing:$ESC_RE_INDEXING_VERSION
    cd $HOME_FOLDER

  fi  

  # List Docker Images built (or existing)
  $CMD images "alfresco/*"
  $CMD images "quay.io/*"

}

# EXECUTION
# Parse params from command line
while test $# -gt 0
do
    case "$1" in
        podman)
            PLATFORM=$PLATFORM_PODMAN
            CONTAINER_BUILD_CMD=$CONTAINER_BUILD_CMD_PODMAN
            CMD=$CMD_PODMAN
            shift
        ;;
        docker)
            # Default values fits to Docker
            shift
        ;;
        repo)
            REPO="true"
            shift
            REPO_COM_VERSION=$1
            shift
        ;;
        repo-ent)
            REPO_ENT="true"
            shift
            REPO_ENT_VERSION=$1
            shift
        ;;
        ags)
            AGS="true"
            shift
            AGS_VERSION=$1
            shift
        ;;
        ags-ent)
            AGS_ENT="true"
            shift
            AGS_ENT_VERSION=$1
            shift
        ;;
        transform)
            TRANSFORM="true"
            shift
            TRANSFORM_VERSION=$1
            shift
        ;;
        t-libreoffice)
            T_LIBREOFFICE="true"
            shift
            T_LIBREOFFICE_VERSION=$1
            shift
        ;;
        t-tika)
            T_TIKA="true"
            shift
            T_TIKA_VERSION=$1
            shift
        ;;
        t-pdf-renderer)
            T_PDF_RENDERER="true"
            shift
            T_PDF_RENDERER_VERSION=$1
            shift
        ;;
        t-imagemagick)
            T_IMAGEMAGICK="true"
            shift
            T_IMAGEMAGICK_VERSION=$1
            shift
        ;;
        t-misc)
            T_MISC="true"
            shift
            T_MISC_VERSION=$1
            shift
        ;;
        transform-router-ent)
            TRANSFORM_ROUTER="true"
            shift
            TRANSFORM_ROUTER_VERSION=$1
            shift
        ;;
        shared-file-store-ent)
            SHARED_FILE_STORE="true"
            shift
            SHARED_FILE_STORE_VERSION=$1
            shift
        ;;
        share)
            SHARE="true"
            shift
            SHARE_VERSION=$1
            shift
        ;;
        share-ent)
            SHARE_ENT="true"
            shift
            SHARE_VERSION=$1
            shift
        ;;        
        ags-share)
            AGS_SHARE="true"
            shift
            AGS_SHARE_VERSION=$1
            shift
        ;;
        ags-share-ent)
            AGS_SHARE_ENT="true"
            shift
            AGS_SHARE_ENT_VERSION=$1
            shift
        ;;
        search)
            SEARCH="true"
            shift
            SEARCH_VERSION=$1
            shift
        ;;
        search-ent)
            SEARCH_ENT="true"
            shift
            SEARCH_ENT_VERSION=$1
            shift
        ;;
        aca)
            ACA="true"
            shift
            ACA_VERSION=$1
            shift
        ;;
        adw)
            ADW="true"
            shift
            ADW_VERSION=$1
            shift
        ;;        
        aaa)
            AAA="true"
            shift
            AAA_VERSION=$1
            shift
        ;;
        proxy)
            PROXY="true"
            shift
            PROXY_VERSION=$1
            shift
        ;;        
        proxy-ent)
            PROXY_ENT="true"
            shift
            PROXY_VERSION=$1
            shift
        ;;
        identity)
            IDENTITY="true"
            shift
            IDENTITY_VERSION=$1
            shift
        ;;
        esc-live-indexing)
            ESC_LIVE_INDEXING="true"
            shift
            ESC_LIVE_INDEXING_VERSION=$1
            shift
        ;;
        esc-live-mediation)
            ESC_LIVE_MEDIATION="true"
            shift
            ESC_LIVE_MEDIATION_VERSION=$1
            shift
        ;;
        esc-live-content)
            ESC_LIVE_CONTENT="true"
            shift
            ESC_LIVE_CONTENT_VERSION=$1
            shift
        ;;
        esc-live-metadata)
            ESC_LIVE_METADATA="true"
            shift
            ESC_LIVE_METADATA_VERSION=$1
            shift
        ;;       
        esc-live-path)
            ESC_LIVE_PATH="true"
            shift
            ESC_LIVE_PATH_VERSION=$1
            shift
        ;;         
        esc-reindexing)
            ESC_RE_INDEXING="true"
            shift
            ESC_RE_INDEXING_VERSION=$1
            shift
        ;;
        *)
            echo "An invalid parameter was received: $1"
            echo "Allowed parameters:"
            echo "  repo VERSION"
            echo "  repo-ent VERSION"
            echo "  ags VERSION"
            echo "  share VERSION"
            echo "  share-ent VERSION"
            echo "  ags-share VERSION"
            echo "  search VERSION"
            echo "  search-ent VERSION"
            echo "  aca VERSION"
            echo "  adw VERSION"
            echo "  aaa VERSION"
            echo "  transform VERSION"
            echo "  t-libreoffice VERSION"
            echo "  t-pdf-renderer VERSION"
            echo "  t-tika VERSION"
            echo "  t-imagemagick VERSION"
            echo "  t-misc VERSION"
            echo "  transform-router-ent VERSION"
            echo "  shared-file-store-ent VERSION"
            echo "  proxy VERSION"
            echo "  identity VERSION"
            echo "  esc-live-indexing VERSION"
            echo "  esc-live-mediation VERSION"
            echo "  esc-live-content VERSION"
            echo "  esc-live-metadata VERSION"
            echo "  esc-live-path VERSION"
            echo "  esc-reindexing VERSION"
            exit 1
        ;;
    esac
done

# Build Container Images
build
