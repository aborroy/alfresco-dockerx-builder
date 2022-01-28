#!/bin/bash
# Build Alfresco Docker Images for Apple Silicon

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Docker Images building flags
REPO="false"
SHARE="false"
SEARCH="false"

function build {

  # Repository
  if [ "$REPO" == "true" ]; then
    rm -rf alfresco-community-repo
    git clone git@github.com:Alfresco/alfresco-community-repo.git
    cd alfresco-community-repo
    mvn clean install -DskipTests
    cd packaging/docker-alfresco
    docker buildx build . --load --platform linux/arm64 -t alfresco-content-repository-community-arm64
    cd ../../..
  fi

  # Share
  if [ "$SHARE" == "true" ]; then
    rm -rf alfresco-community-share
    git clone git@github.com:Alfresco/alfresco-community-share.git
    cd alfresco-community-share
    mvn clean install -DskipTests
    cd packaging/docker
    ## Remove LABEL line from Dockerfile
    sed -i '' -e '$ d' Dockerfile
    docker buildx build . --load --platform linux/arm64 -t alfresco-share-arm64
    cd ../../..
  fi

  # Search Services
  if [ "$SEARCH" == "true" ]; then
    rm -rf SearchServices
    git clone git@github.com:Alfresco/SearchServices.git
    cd SearchServices/search-services
    mvn clean install -DskipTests
    cd packaging/target/docker-resources
    docker buildx build . --load --platform linux/arm64 -t alfresco-search-services-arm64
    cd ../../../..
  fi

  # List Docker Images built (or existing)
  docker images "*-arm64"

}

# EXECUTION
# Parse params from command line
while test $# -gt 0
do
    case "$1" in
        -repo)
            REPO="true"
            shift
        ;;
        -share)
            SHARE="true"
            shift
        ;;
        -search)
            SEARCH="true"
            shift
        ;;
        *)
            echo "An invalid parameter was received: $1"
            echo "Allowed parameters:"
            echo "  -repo"
            echo "  -share"
            echo "  -search"
            exit 1
        ;;
    esac
done

# Build Docker Images
build
