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

# Docker Images building flags
REPO="false"
REPO_ENT="false"
SHARE="false"
SHARE_ENT="false"
SEARCH="false"
SEARCH_ENT="false"
TRANSFORM="false"
TRANSFORM_ROUTER="false"
SHARED_FILE_STORE="false"
ACA="false"
PROXY="false"
PROXY_ENT="false"

function build {

  # Repository Community
  if [ "$REPO" == "true" ]; then

    rm -rf acs-community-packaging
    git clone git@github.com:Alfresco/acs-community-packaging.git
    cd acs-community-packaging
    git checkout $REPO_COM_VERSION || { echo -e >&2 "Available tags:\n$(git tag -l "${REPO_COM_VERSION:0:5}*")"; exit 1; }
    REPO_VERSION=$(ggrep -oP '(?<=<dependency.alfresco-community-repo.version>).*?(?=</dependency.alfresco-community-repo.version>)' pom.xml)
    SHARE_INTERNAL_VERSION=$(ggrep -oP '(?<=<dependency.alfresco-community-share.version>).*?(?=</dependency.alfresco-community-share.version>)' pom.xml)

    rm -rf alfresco-community-repo
    git clone git@github.com:Alfresco/alfresco-community-repo.git
    cd alfresco-community-repo
    git checkout $REPO_VERSION || { echo -e >&2 "Available tags:\n$(git tag -l "${REPO_VERSION:0:5}*")"; exit 1; }
    mvn clean install -DskipTests
    cd packaging/docker-alfresco
    wget https://nexus.alfresco.com/nexus/service/local/repo_groups/public/content/org/alfresco/alfresco-share-base-distribution/$SHARE_INTERNAL_VERSION/alfresco-share-base-distribution-$SHARE_INTERNAL_VERSION.zip \
    && unzip alfresco-share-base-distribution-*.zip
    cp alfresco-share-base-distribution-*/amps/* target/amps
    sed -i '' 's/alfresco-base-tomcat:tomcat9-jre11-centos7.*/alfresco-base-tomcat:tomcat9-jre11-centos7-202209261711/g' Dockerfile
    docker buildx build . --load --platform linux/arm64 \
    -t $REPOSITORY/alfresco-content-repository-community:$REPO_COM_VERSION
    cd $HOME_FOLDER
  fi

  # Repository Enterprise
  if [ "$REPO_ENT" == "true" ]; then
    cd repo
    docker buildx build . --load --platform linux/arm64 \
    --build-arg ALFRESCO_VERSION=$REPO_ENT_VERSION \
    --build-arg NEXUS_USER=$NEXUS_USER \
    --build-arg NEXUS_PASS=$NEXUS_PASS \
    -t quay.io/$REPOSITORY/alfresco-content-repository:$REPO_ENT_VERSION
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
    docker buildx build . --load --platform linux/arm64 \
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
    docker buildx build . --load --platform linux/arm64 \
    --build-arg SHARE_INTERNAL_VERSION=$SHARE_ENT_VERSION \
    -t quay.io/$REPOSITORY/alfresco-share:$SHARE_VERSION
    cd $HOME_FOLDER
  fi  

  # Search Services 
  if [ "$SEARCH" == "true" ]; then
    cd search
    docker buildx build . --load --platform linux/arm64 \
    --build-arg SEARCH_VERSION=$SEARCH_VERSION \
    --build-arg DIST_DIR=/opt/alfresco-search-services \
    -t $REPOSITORY/alfresco-search-services:$SEARCH_VERSION    
    cd $HOME_FOLDER
  fi

  # Search Services Enterprise
  if [ "$SEARCH_ENT" == "true" ]; then
    cd search
    docker buildx build . --load --platform linux/arm64 \
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
    docker buildx build . --load --platform linux/arm64 \
    --build-arg TRANSFORM_VERSION=$TRANSFORM_VERSION \
    --build-arg IMAGEMAGICK_HOME_FOLDER=$IMAGEMAGICK_HOME_FOLDER \
    --build-arg LIBREOFFICE_HOME_FOLDER=$LIBREOFFICE_HOME_FOLDER \
    -t $REPOSITORY/alfresco-transform-core-aio:$TRANSFORM_VERSION
    cd $HOME_FOLDER

  fi

  # Transform Router
  if [ "$TRANSFORM_ROUTER" == "true" ]; then

    cd transform-router
    docker buildx build . --load --platform linux/arm64 \
    --build-arg TRANSFORM_ROUTER_VERSION=$TRANSFORM_ROUTER_VERSION \
    --build-arg NEXUS_USER=$NEXUS_USER \
    --build-arg NEXUS_PASS=$NEXUS_PASS \
    -t quay.io/$REPOSITORY/alfresco-transform-router:$TRANSFORM_ROUTER_VERSION
    cd $HOME_FOLDER

  fi

  # Shared File Store
  if [ "$SHARED_FILE_STORE" == "true" ]; then

    cd shared-file-store
    docker buildx build . --load --platform linux/arm64 \
    --build-arg SHARED_FILE_STORE_VERSION=$SHARED_FILE_STORE_VERSION \
    --build-arg NEXUS_USER=$NEXUS_USER \
    --build-arg NEXUS_PASS=$NEXUS_PASS \
    -t quay.io/$REPOSITORY/alfresco-shared-file-store:$SHARED_FILE_STORE_VERSION
    cd $HOME_FOLDER

  fi    

  # ACA
  if [ "$ACA" == true ]; then
    rm -rf alfresco-content-app
    git clone git@github.com:Alfresco/alfresco-content-app.git
    cd alfresco-content-app
    git checkout $ACA_VERSION || { echo -e >&2 "Available tags:\n$(git tag -l "${ACA_VERSION:0:5}*")"; exit 1; }
    npm install
    npm run build
    docker buildx build . --load --platform linux/arm64 \
    --build-arg PROJECT_NAME=content-ce \
    -t $REPOSITORY/alfresco-content-app:$ACA_VERSION
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
    docker buildx build . --load --platform linux/arm64 \
    -t $PREFIX$REPOSITORY/alfresco-acs-nginx:$PROXY_VERSION
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
        *)
            echo "An invalid parameter was received: $1"
            echo "Allowed parameters:"
            echo "  repo VERSION"
            echo "  repo-ent VERSION"
            echo "  share VERSION"
            echo "  share-ent VERSION"
            echo "  search VERSION"
            echo "  search-ent VERSION"
            echo "  aca VERSION"
            echo "  transform VERSION"
            echo "  transform-router-ent VERSION"
            echo "  shared-file-store-ent VERSION"
            echo "  proxy VERSION"
            exit 1
        ;;
    esac
done

# Build Docker Images
build
