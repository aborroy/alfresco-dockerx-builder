ARG IDENTITY_VERSION=1.8.0
FROM alfresco/alfresco-identity-service:${IDENTITY_VERSION} AS IDENTITY
FROM alfresco/alfresco-base-java:jdk11-rockylinux8

COPY --from=IDENTITY --chown=1000 /opt/jboss /opt/jboss

USER 1000

EXPOSE 8080
EXPOSE 8443

ENTRYPOINT [ "/opt/jboss/tools/docker-entrypoint.sh" ]

CMD ["-b", "0.0.0.0"]
