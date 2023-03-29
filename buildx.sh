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
PLATFORM=linux/arm64

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
TRANSFORM_ROUTER="false"
SHARED_FILE_STORE="false"
ACA="false"
ADW="false"
AAA="false"
PROXY="false"
PROXY_ENT="false"
IDENTITY="false"
ESC_LIVE_INDEXING="false"

function build {

  # Repository Community
  if [ "$REPO" == "true" ]; then
    cd repo
    docker buildx build . --load --platform $PLATFORM \
    --build-arg ALFRESCO_VERSION=$REPO_COM_VERSION \
    -t $REPOSITORY/alfresco-content-repository-community:$REPO_COM_VERSION
    cd $HOME_FOLDER
  fi

  # Repository Enterprise
  if [ "$REPO_ENT" == "true" ]; then
    cd repo-ent
    docker buildx build . --load --platform $PLATFORM \
    --build-arg ALFRESCO_VERSION=$REPO_ENT_VERSION \
    -t quay.io/$REPOSITORY/alfresco-content-repository:$REPO_ENT_VERSION
    cd $HOME_FOLDER
  fi

  # AGS Community Repo
  if [ "$AGS" == "true" ]; then
    cd ags
    docker buildx build . --load --platform $PLATFORM \
    --build-arg AGS_VERSION=$AGS_VERSION \
    -t $REPOSITORY/alfresco-governance-repository-community:$AGS_VERSION
    cd $HOME_FOLDER
  fi

  # AGS Enterprise Repo
  if [ "$AGS_ENT" == "true" ]; then
    cd ags-ent
    docker buildx build . --load --platform $PLATFORM \
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
    docker buildx build . --load --platform $PLATFORM \
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
    docker buildx build . --load --platform $PLATFORM \
    --build-arg SHARE_INTERNAL_VERSION=$SHARE_ENT_VERSION \
    -t quay.io/$REPOSITORY/alfresco-share:$SHARE_VERSION
    cd $HOME_FOLDER
  fi

  # AGS Community Share
  if [ "$AGS_SHARE" == "true" ]; then
    cd ags-share
    docker buildx build . --no-cache --load --platform $PLATFORM \
    --build-arg AGS_SHARE_VERSION=$AGS_SHARE_VERSION \
    -t $REPOSITORY/alfresco-governance-share-community:$AGS_SHARE_VERSION
    cd $HOME_FOLDER  
  fi
  
  # AGS Enterprise Share
  if [ "$AGS_SHARE_ENT" == "true" ]; then
    cd ags-share-ent
    docker buildx build . --no-cache --load --platform $PLATFORM \
    --build-arg AGS_SHARE_ENT_VERSION=$AGS_SHARE_ENT_VERSION \
    -t quay.io/$REPOSITORY/alfresco-governance-share-enterprise:$AGS_SHARE_ENT_VERSION
    cd $HOME_FOLDER  
  fi

  # Search Services 
  if [ "$SEARCH" == "true" ]; then
    cd search
    docker buildx build . --load --platform $PLATFORM \
    --build-arg SEARCH_VERSION=$SEARCH_VERSION \
    --build-arg DIST_DIR=/opt/alfresco-search-services \
    -t $REPOSITORY/alfresco-search-services:$SEARCH_VERSION    
    cd $HOME_FOLDER
  fi

  # Search Services Enterprise
  if [ "$SEARCH_ENT" == "true" ]; then
    cd search
    docker buildx build . --load --platform $PLATFORM \
    --build-arg SEARCH_VERSION=$SEARCH_ENT_VERSION \
    --build-arg NEXUS_USER=$NEXUS_USER \
    --build-arg NEXUS_PASS=$NEXUS_PASS \
    --build-arg DIST_DIR=/opt/alfresco-insight-engine \
    -t quay.io/$REPOSITORY/alfresco-insight-engine:$SEARCH_ENT_VERSION
    cd $HOME_FOLDER
  fi

  # Transform Service
  if [ "$TRANSFORM" == "true" ]; then

    wget https://raw.githubusercontent.com/Alfresco/alfresco-transform-core/$TRANSFORM_VERSION/engines/aio/src/main/resources/application-default.yaml
    IMAGEMAGICK_HOME_FOLDER=$(ggrep -oP '(?<=path: \$\{LIBREOFFICE_HOME:).*?(?=\})' application-default.yaml)
    LIBREOFFICE_HOME_FOLDER=$(ggrep -oP '(?<=root: \$\{IMAGEMAGICK_ROOT:).*?(?=\})' application-default.yaml)
    rm application-default.yaml

    cd transform
    docker buildx build . --load --platform $PLATFORM \
    --build-arg TRANSFORM_VERSION=$TRANSFORM_VERSION \
    --build-arg IMAGEMAGICK_HOME_FOLDER=$IMAGEMAGICK_HOME_FOLDER \
    --build-arg LIBREOFFICE_HOME_FOLDER=$LIBREOFFICE_HOME_FOLDER \
    -t $REPOSITORY/alfresco-transform-core-aio:$TRANSFORM_VERSION
    cd $HOME_FOLDER

  fi

  # Transform Router
  if [ "$TRANSFORM_ROUTER" == "true" ]; then

    cd transform-router
    docker buildx build . --load --platform $PLATFORM \
    --build-arg TRANSFORM_ROUTER_VERSION=$TRANSFORM_ROUTER_VERSION \
    --build-arg NEXUS_USER=$NEXUS_USER \
    --build-arg NEXUS_PASS=$NEXUS_PASS \
    -t quay.io/$REPOSITORY/alfresco-transform-router:$TRANSFORM_ROUTER_VERSION
    cd $HOME_FOLDER

  fi

  # Shared File Store
  if [ "$SHARED_FILE_STORE" == "true" ]; then

    cd shared-file-store
    docker buildx build . --load --platform $PLATFORM \
    --build-arg SHARED_FILE_STORE_VERSION=$SHARED_FILE_STORE_VERSION \
    --build-arg NEXUS_USER=$NEXUS_USER \
    --build-arg NEXUS_PASS=$NEXUS_PASS \
    -t quay.io/$REPOSITORY/alfresco-shared-file-store:$SHARED_FILE_STORE_VERSION
    cd $HOME_FOLDER

  fi    

  # ACA
  if [ "$ACA" == true ]; then
    cd aca
    docker buildx build . --load --platform $PLATFORM \
    --build-arg ACA_VERSION=$ACA_VERSION \
    -t $REPOSITORY/alfresco-content-app:$ACA_VERSION
    cd $HOME_FOLDER
  fi

  # ADW
  if [ "$ADW" == true ]; then
    cd adw
    docker buildx build . --load --platform $PLATFORM \
    --build-arg ADW_VERSION=$ADW_VERSION \
    -t quay.io/$REPOSITORY/alfresco-digital-workspace:$ADW_VERSION
    cd $HOME_FOLDER
  fi  

  # AAA
  if [ "$AAA" == true ]; then
    cd aaa
    docker buildx build . --load --platform $PLATFORM \
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
    docker buildx build . --load --platform $PLATFORM \
    -t $PREFIX$REPOSITORY/alfresco-acs-nginx:$PROXY_VERSION
    cd $HOME_FOLDER
  fi

  # Identity
  if [ "$IDENTITY" == "true" ]; then

    cd identity
    docker buildx build . --load --platform $PLATFORM \
    --build-arg IDENTITY_VERSION=$IDENTITY_VERSION \
    -t $REPOSITORY/alfresco-identity-service:$IDENTITY_VERSION
    cd $HOME_FOLDER

  fi    

  # Elasticsearch Connector
  if [ "$ESC_LIVE_INDEXING" == "true" ]; then

    cd live-indexing
    docker buildx build . --load --platform $PLATFORM \
    --build-arg ESC_VERSION=$ESC_LIVE_INDEXING_VERSION \
    -t quay.io/$REPOSITORY/alfresco-elasticsearch-live-indexing:$ESC_LIVE_INDEXING_VERSION
    cd $HOME_FOLDER

  fi

  # List Docker Images built (or existing)
  docker images "alfresco/*"
  docker images "quay.io/*"

}

# EXECUTION
# Parse params from command line
while test $# -gt 0
do
    case "$1" in
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
            echo "  transform-router-ent VERSION"
            echo "  shared-file-store-ent VERSION"
            echo "  proxy VERSION"
            echo "  identity VERSION"
            echo "  esc-live-indexing VERSION"
            exit 1
        ;;
    esac
done

# Build Docker Images
build
