ARG VERSION
FROM public.ecr.aws/docker/library/alpine:3.18 as builder
ARG VERSION
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT=""
ARG TARGETPLATFORM
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH} \
    GOARM=${TARGETVARIANT} \
    GOPATH=/go
ENV PATH $GOPATH/bin:$PATH
#hadolint ignore=DL3018
RUN \
    apk add --no-cache go upx \
    && go install -ldflags="-s -w" github.com/drone/envsubst/cmd/envsubst@latest \
    && upx --ultra-brute /go/bin/envsubst

FROM docker.io/redhat/ubi9-minimal:${VERSION}

WORKDIR /app
COPY /apps/ubi9-minimal/scripts /dsop-fix/

# Be careful when adding packages because this will ultimately be built on a licensed RHEL host,
# which enables full RHEL repositories and could allow for installation of packages that would
# violate Red Hat license agreement when running the container on a non-RHEL licensed host.
# See the following link for more details:
# https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html-single/building_running_and_managing_containers/index/#add_software_to_a_running_ubi_container
RUN echo "[main]" >> /etc/dnf/dnf.conf && \
    echo "exclude=filesystem-*" >> /etc/dnf/dnf.conf && \
    echo Update packages and install DISA STIG fixes && \
    microdnf repolist && \
    microdnf --setopt install_weak_deps=0 update -y && \
    microdnf install -y crypto-policies-scripts shadow-utils && \
    groupadd -g 5568 kah &&\
    useradd -g kah -M -u 5568 kah && \
    mkdir -p /config &&\
    chown -R kah:kah /config &&\
    chmod -R 775 /config &&\
    # Do not use loops to iterate through shell scripts, this allows for scripts to fail
    # but the build to still be successful. Be explicit when executing scripts and ensure
    # that all scripts have "set -e" at the top of the bash file!
    /dsop-fix/xccdf_org.ssgproject.content_rule_configure_crypto_policy.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_openssl_use_strong_entropy.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_configure_openssl_crypto_policy.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_configure_gnutls_tls_crypto_policy.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_harden_sshd_ciphers_openssh_conf_crypto_policy.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_harden_sshd_ciphers_opensshserver_conf_crypto_policy.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_harden_sshd_macs_openssh_conf_crypto_policy.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_harden_sshd_macs_opensshserver_conf_crypto_policy.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_umask_etc_bashrc.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_umask_etc_profile.sh && \
    /dsop-fix/xccdf_org.ssgproject.content_rule_accounts_umask_etc_csh_cshrc.sh && \
    chmod +t /tmp /var/tmp && \
    microdnf clean all && \
    rm -rf /dsop-fix/ /var/cache/dnf/ /var/tmp/* /tmp/* /var/tmp/.???* /tmp/.???*

# Disable ChaCha20 Algorithms
RUN set -eux; \
    disabledAlgorithms=' \
        TLS_CHACHA20_POLY1305_SHA256, \
        TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256, \
        TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256, \
        TLS_DHE_RSA_WITH_CHACHA20_POLY1305_SHA256, \
    '; \
    disabledAlgorithms="${disabledAlgorithms//[[:space:]]/}"; \
    sed -i "s/^jdk\.tls\.disabledAlgorithms=/jdk.tls.disabledAlgorithms=$disabledAlgorithms/" \
        /usr/share/crypto-policies/FIPS/java.txt;

ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini && mv /tini /sbin/tini

ENV container oci
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

VOLUME ["/config"]

ENTRYPOINT ["/sbin/tini", "--"]
