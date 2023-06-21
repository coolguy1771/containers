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
    && upx /go/bin/envsubst

FROM public.ecr.aws/docker/library/alpine:${VERSION} as build-openssl
ARG VERSION
ARG CHANNEL
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}

ENV OPENSSL_VERSION=3.0.8

RUN apk update && \
    apk --no-cache upgrade && \
    apk --no-cache add \
      gcc \
      linux-headers \
      make \
      musl-dev \
      perl  && \
    rm -rf /var/cache/apk/* && \
    curl -o /openssl.tar.gz https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz

WORKDIR /usr/local/src/openssl

RUN tar -zxf /openssl.tar.gz -C /usr/local/src/openssl --strip-components=1 && \
    perl ./Configure \
      --prefix=/usr \
      --libdir=lib \
      --openssldir=/etc/ssl \
      enable-ktls \
      shared \
      no-zlib \
      no-async \
      no-comp \
      no-idea \
      no-mdc2 \
      no-rc5 \
      no-ec2m \
      no-sm2 \
      no-sm4 \
      no-ssl3 \
      no-seed \
      no-weak-ssl-ciphers \
      enable-fips \
      enable-ec_nistp_64_gcc_128 \
      -Wa,--noexecstack && \
    make -j$(nproc) && \
    make install && \
    make install_fips && \
    openssl fipsinstall -out /etc/ssl/fipsmodule.cnf -module /usr/lib/ossl-modules/fips.so

FROM public.ecr.aws/docker/library/alpine:${VERSION}
ARG VERSION
ARG CHANNEL
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}

WORKDIR /app

# hadolint ignore=DL3002
USER root

#hadolint ignore=DL3018
RUN \
    apk --no-cache upgrade && \
    apk add --no-cache \
        # 656 kB           # 1.28 MB     # 632 kB
        ca-certificates    bash          bind-tools \
        # 256 kB           # 156 kB      # 40 kB
        curl               iputils       jo \
        # 564 kB           # 200 kB      # 316 kB
        jq                 moreutils     nano \
        # 76 kB
        pv \
        # 36 kB            # 3.3 MB      # 320 kB
        tini               tzdata        unzip \
        # 16 kB            # 480 kB
        util-linux         wget \
    && \
    # 264 kB
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.14/main unrar

COPY --from=build-openssl /usr/lib/ossl-modules/fips.so /usr/lib/ossl-modules/fips.so
COPY --from=build-openssl /etc/ssl/fipsmodule.cnf /etc/ssl/fipsmodule.cnf

#hadolint ignore=DL3018
RUN update-ca-certificates && \
    sed -i 's/^default\s=\sdefault_sect/# default = default_sect/' /etc/ssl/openssl.cnf && \
    sed -i 's/^#\s\.include\sfipsmodule.cnf/\.include \/etc\/ssl\/fipsmodule.cnf/' /etc/ssl/openssl.cnf && \
    sed -i 's/^#\sfips\s=\sfips_sect/fips = fips_sect\nbase = base_sect\n\n[base_sect]\nactivate=1/' /etc/ssl/openssl.cnf && \
    sed -i "s/umask.*/umask 077/g" /etc/profile && \
    sed -i -r '/^(root|nobody)/!d' /etc/group /etc/passwd /etc/shadow && \
    chown root:root /etc/shadow && \
    chmod 000 /etc/shadow && \
    addgroup -S kah --gid 568 \
        && adduser -S kah -G kah --uid 568 \
    && \
    mkdir -p /config \
    && chown -R kah:kah /config \
    && chmod -R 775 /config \
    && ln -s /usr/bin/vi   /usr/local/bin/vi \
    && ln -s /usr/bin/vi   /usr/local/bin/vim \
    && ln -s /usr/bin/nano /usr/local/bin/nano \
    && ln -s /usr/bin/nano /usr/local/bin/neovim \
    && ln -s /usr/bin/nano /usr/local/bin/emacs \
    && rm -rf /tmp/*

VOLUME ["/config"]
COPY --from=builder /go/bin/envsubst /usr/local/bin/envsubst
ENTRYPOINT ["/sbin/tini", "--"]
