FROM docker.io/library/alpine:3.22 as builder

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

# install dependencies
RUN apk add --update-cache \
    curl \
    g++ \
    gcc \
    git \
    linux-headers \
    build-base \
    make \
    perl \
    tar \
    cmake \
    upx

# download pcre library
WORKDIR /src/pcre
ARG PCRE_VER=8.45
RUN curl -L -O "https://cfhcable.dl.sourceforge.net/project/pcre/pcre/${PCRE_VER}/pcre-${PCRE_VER}.tar.gz" \
    && tar xzf "/src/pcre/pcre-${PCRE_VER}.tar.gz"

# download openssl
ARG OPENSSL_VER=openssl-3.1.3
WORKDIR /src/openssl
RUN git clone -j$(nproc) -b "${OPENSSL_VER}" https://github.com/openssl/openssl.git /src/openssl

# download zlib
WORKDIR /src/zlib
ARG ZLIB_VER=1.3.1
RUN curl -sL -O "https://www.zlib.net/zlib-${ZLIB_VER}.tar.gz" \
    && tar xzf "zlib-${ZLIB_VER}.tar.gz"

# download brotli module
WORKDIR /src/ngx_brotli
RUN git clone -j$(nproc) --recurse-submodule https://github.com/google/ngx_brotli.git /src/ngx_brotli && \
    cd /src/ngx_brotli/deps/brotli && \
    mkdir out && cd out && \
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed .. && \
    cmake --build . --config Release --target brotlienc

# download fancy-index module
RUN git clone -j$(nproc) https://github.com/aperezdc/ngx-fancyindex.git /src/ngx-fancyindex

# download nginx source
WORKDIR /src/nginx
RUN curl -L -O "http://nginx.org/download/nginx-${VERSION}.tar.gz" \
    && tar xzf "nginx-${VERSION}.tar.gz"

# configure and build nginx
WORKDIR /src/nginx/nginx-"${VERSION}"
RUN ./configure --prefix=/usr/share/nginx \
                --sbin-path=/usr/sbin/nginx \
                --conf-path=/etc/nginx/nginx.conf \
                --error-log-path=/var/log/nginx/error.log \
                --http-log-path=/var/log/nginx/access.log \
                --pid-path=/tmp/nginx.pid \
                --lock-path=/run/lock/subsys/nginx \
                --http-client-body-temp-path=/tmp/nginx/client \
                --http-proxy-temp-path=/tmp/nginx/proxy \
                --with-threads \
                --with-file-aio \
                --with-zlib="/src/zlib/zlib-${ZLIB_VER}" \
                --with-pcre="/src/pcre/pcre-${PCRE_VER}" \
                --with-pcre-jit \
                --with-http_addition_module \
                --with-http_random_index_module \
                --with-http_ssl_module \
                --with-http_stub_status_module \
                --with-http_sub_module \
                --add-module=/src/ngx_brotli \
                --add-module=/src/ngx-fancyindex \
                --with-openssl=/src/openssl \
                --without-http_uwsgi_module \
                --without-http_scgi_module \
                --without-select_module \
                --without-poll_module \
                --without-mail_pop3_module \
                --without-mail_imap_module \
                --without-mail_smtp_module \
                --with-cc-opt="-O2 -flto -ffunction-sections -fdata-sections -fPIE -fstack-protector-all -D_FORTIFY_SOURCE=2 -Wformat -Werror=format-security" \
                --with-ld-opt="-Wl,--gc-sections -s -static -static-libgcc" \
    && make -j$(nproc) \
    && make install

# compress the nginx binary
RUN upx --best /usr/sbin/nginx

# setup nginx folders and files
RUN mkdir -p /etc/nginx \
    && mkdir -p /tmp/nginx/{client,proxy} \
    && mkdir -p /usr/share/nginx/fastcgi_temp \
    && mkdir -p /var/log/nginx \
    && mkdir -p /var/www/html \
    && touch /tmp/nginx.pid

# copy in default nginx configs
COPY nginx/ /etc/nginx/

# set up the final container
FROM gcr.io/distroless/static:nonroot

# run as nonroot
USER nonroot

# copy files over
COPY --from=builder --chown=nonroot:nonroot /etc/nginx /etc/nginx
COPY --from=builder --chown=nonroot:nonroot /tmp/nginx.pid /tmp/nginx.pid
COPY --from=builder --chown=nonroot:nonroot /tmp/nginx /tmp/nginx
COPY --from=builder --chown=nonroot:nonroot /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder --chown=nonroot:nonroot /usr/share/nginx/fastcgi_temp /usr/share/nginx/fastcgi_temp
COPY --from=builder --chown=nonroot:nonroot /var/log/nginx /var/log/nginx
COPY --from=builder --chown=nonroot:nonroot /var/www/html /var/www/html
COPY --chown=nonroot:nonroot html/index.html /var/www/html/index.html

# listen on an unprivileged port
EXPOSE 8080

# configure entrypoint
ENTRYPOINT ["/usr/sbin/nginx","-g","daemon off;"]
