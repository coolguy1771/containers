ARG VERSION
FROM ghcr.io/coolguy1771/ubi9:9.1.0 as build

FROM registry.access.redhat.com/ubi9-micro:${VERSION}

ARG VERSION
ARG CHANNEL
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}

WORKDIR /app

COPY ./apps/ubi9-micro/scripts /dsop-fix/

# Be careful when adding packages because this will ultimately be built on a licensed RHEL host,
# which enables full RHEL repositories and could allow for installation of packages that would
# violate Red Hat license agreement when running the container on a non-RHEL licensed host.

RUN /dsop-fix/xccdf_org.ssgproject.content_rule_openssl_use_strong_entropy.sh && \
    rm -rf /dsop-fix /var/cache/dnf/ /tmp/* && \
# fix CCE-80783-4 sticky /tmp until Red Hat fixes in source ubi9-micro
    chmod +t /tmp /var/tmp

# for umask, remediation scripts fail since grep/sed are missing
COPY --from=build --chown=0:0 /etc/bashrc /etc/bashrc
COPY --from=build --chown=0:0 /etc/csh.cshrc /etc/csh.cshrc

# for default certificates, ca-certificates is not installed in ubi-micro
COPY --from=build --chown=0:0 /etc/pki /etc/pki
COPY --from=build --chown=0:0 /etc/ssl /etc/ssl

# copy tini and envsubst from ubi9
COPY --from=build --chown=0:0 /sbin/tini /sbin/tini
COPY --from=build --chown=0:0 /usr/bin/envsubst /usr/bin/envsubst

ENV container oci
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

VOLUME ["/config"]

ENTRYPOINT ["/sbin/tini", "--"]
