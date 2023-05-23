# Alfresco Docker Image ARM64 Builder

This project provides a sample script to build Alfresco Docker Images for **Apple Silicon**. This tool is oriented for Alfresco Developers that use Docker Images in their development workflow.

Alfresco doesn't provide ARM64 Docker Images *YET* and this configuration is not *officially* supported by Alfresco.

>> Additional recommendations provided by [howkymike](https://howkymike.github.io/) in
>> https://gist.github.com/howkymike/d2ad4e81298e2408511a14cb731441c3


## Requirements

Following software is required to be installed:

* Mac OS X with Apple Silicon chip
* [docker buildx](https://docs.docker.com/buildx/working-with-buildx/)
* [maven](https://maven.apache.org)
* [java](https://www.oracle.com/java/technologies/java-se-glance.html)
* [git](https://git-scm.com)
* [ggrep](https://formulae.brew.sh/formula/grep)
* [wget](https://formulae.brew.sh/formula/wget)

Alternatively, [Podman](https://podman-desktop.io) can be used instead of Docker.

## Building

**Syntax**

Available Alfresco Docker Images can be selected by using command line arguments.

```
$ ./buildx.sh [repo VERSION] [proxy VERSION] [share VERSION] [search VERSION] [aca VERSION]
```

Building the Images for **Podman** requires to add `podman` argument in the command:

```
$ ./buildx.sh podman repo 7.3.0
```

**Sample execution**

The process will take a while, but it will pull to your local Docker Repository all the Images selected by using the same tag name provided by Alfresco.

```
$ ./buildx.sh repo 7.3.0 share 7.3.0 search 2.0.3 transform 3.0.0 aca 3.1.0

...

REPOSITORY                                      TAG       IMAGE ID       CREATED              SIZE
alfresco/alfresco-search-services               2.0.3     ed75b40d7c8f   7 minutes ago        951MB
alfresco/alfresco-share                         7.3.0     318e3d6b4426   17 hours ago         1.85GB
alfresco/alfresco-content-repository-community  7.3.0     b5974502c4d9   8 minutes ago        957MB
alfresco/alfresco-content-app                   3.1.0     ea083a198161   17 hours ago         84.2MB
alfresco/alfresco-transform-core-aio            3.0.0     696189c329f0   8 minutes ago        4.93GB
```

Once the Docker Images are available in your local registry, existing Docker Compose templates can be run using ARM64 architecture.

Enterprise Docker Images can be also built, but [Alfresco Nexus](https://nexus.alfresco.com) credentials are required. Populate `NEXUS_USER`and `NEXUS_PASS` properties in `buildx.sh` file.

```
$ ./buildx.sh repo-ent 7.3.0 share-ent 7.3.0 search-ent 2.0.3
```
