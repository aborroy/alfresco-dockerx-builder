# Alfresco Docker Image ARM64 Builder

This project provides a sample script to build Alfresco Docker Images for Apple Silicon (M1). This tool is oriented for Alfresco Developers that use Docker Images in their development workflow.

Alfresco doesn't provide ARM64 Docker Images and this configuration is not *officially* supported by Alfresco.

>> Additional recommendations provided by [howkymike](https://howkymike.github.io/) in
>> https://gist.github.com/howkymike/d2ad4e81298e2408511a14cb731441c3


## Requirements

Following software is required to be installed:

* Mac OS X
* [docker buildx](https://docs.docker.com/buildx/working-with-buildx/)
* [maven](https://maven.apache.org)
* [java](https://www.oracle.com/java/technologies/java-se-glance.html)
* [git](https://git-scm.com)

## Building

**Syntax**

Available Alfresco Docker Images can be selected by using command line arguments.

```
$ ./buildx.sh [-repo] [-share] [-search]
```

**Sample execution**

The process will take a while, but it will pull to your local Docker Repository all the Images selected by appending an "-arm64" suffix the the name.

```
$ ./buildx.sh -repo -share -search

...

REPOSITORY                                    TAG       IMAGE ID       CREATED              SIZE
alfresco-search-services-arm64                latest    5eac00f189c3   About a minute ago   1.57GB
alfresco-share-arm64                          latest    4a20eb8558cc   3 minutes ago        759MB
alfresco-content-repository-community-arm64   latest    b5974502c4d9   8 minutes ago        957MB
```

## Using ARM64 Docker Images

Once the images are available in your local Docker Repository, you can modify local `Dockerfile` and `docker-compose.yml` files (like the ones used by the [Alfresco SDK](https://docs.alfresco.com/content-services/6.0/develop/sdk/)) to use the new Docker Images.

For instance, change this line...

```
FROM alfresco/alfresco-content-repository-community
```

... by this other

```
FROM alfresco-content-repository-community-arm64
```
