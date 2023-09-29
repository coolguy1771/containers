FROM ghcr.io/coolguy1771/alpine:rolling@sha256:56d460fdf320cfa8b40298db0f0eb6d0363aba019a51591f6bccef6f3fb62e85

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL
#hadolint ignore=DL3018
RUN apk add --no-cache ca-certificates openssl python3 py3-pip

RUN pip3 install se-exporter

CMD [ "/sbin/tini", "--", "/usr/bin/se-exporter" ]
