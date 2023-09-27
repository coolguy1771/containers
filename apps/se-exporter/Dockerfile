FROM ghcr.io/coolguy1771/alpine:rolling@sha256:9ce9b7bd2576d09b9567c326c53ac71cad66b9eb63df840a976d1d4f4967ecf2

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL
#hadolint ignore=DL3018
RUN apk add --no-cache ca-certificates openssl python3 py3-pip

RUN pip3 install se-exporter

CMD [ "/sbin/tini", "--", "/usr/bin/se-exporter" ]
