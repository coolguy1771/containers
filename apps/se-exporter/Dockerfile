FROM ghcr.io/coolguy1771/alpine:rolling@sha256:dd86ae1e9dff5d819a13fbf7d315ffb6d9a8fba4bec07982ea845267879dd5a1

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL
#hadolint ignore=DL3018
RUN apk add --no-cache ca-certificates openssl python3 py3-pip

RUN pip3 install se-exporter

CMD [ "/sbin/tini", "--", "/usr/bin/se-exporter" ]
