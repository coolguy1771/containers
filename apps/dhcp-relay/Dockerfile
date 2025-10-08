FROM docker.io/library/ubuntu:noble AS builder

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

WORKDIR /ipxe/

RUN apt-get -y update \
  && apt-get -y install --no-install-recommends build-essential genisoimage git isolinux liblzma-dev mtools syslinux ca-certificates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


RUN git clone --branch master https://github.com/ipxe/ipxe.git /ipxe \
  && sed -i 's/^#undef[[:space:]]*DOWNLOAD_PROTO_HTTPS[[:space:]]*\/\* Secure Hypertext Transfer Protocol \*\//#define DOWNLOAD_PROTO_HTTPS\t\/\* Secure Hypertext Transfer Protocol \*\//' src/config/general.h \
  && sed -i 's/^\/\/#define[[:space:]]*PING_CMD[[:space:]]*\/\* Ping command \*\//#define PING_CMD\t\/\* Ping command \*\//' src/config/general.h \
  && cd /ipxe/src \
  && make -j$(nproc) bin/undionly.kpxe \
  && make -j$(nproc) bin-x86_64-efi/ipxe.efi

FROM docker.io/alpine:3.22.2

RUN apk -U add dnsmasq curl

COPY --from=builder /ipxe/src/bin/undionly.kpxe /var/lib/tftpboot/{undionly.kpxe,undionly.kpxe.0}
COPY --from=builder /ipxe/src/bin-x86_64-efi/ipxe.efi /var/lib/tftpboot/

EXPOSE 53 67 69
ENTRYPOINT ["/usr/sbin/dnsmasq"]

LABEL org.opencontainers.image.source="https://github.com/poseidon/dnsmasq"
