# Dockerfile for shadowsocks-rust based alpine
# Copyright (C) 2021 zdevcs <mail@zdev.me>
# Reference URL:
# https://github.com/shadowsocks/shadowsocks-rust
# https://github.com/teddysun/v2ray-plugin
# https://github.com/teddysun/xray-plugin

FROM golang:alpine as builder
LABEL maintainer="zdevcs <mail@zdev.me>"

COPY build_ray-plugin.sh /root/build_ray-plugin.sh
COPY build_shadowsocks-rust.sh /root/build_shadowsocks-rust.sh

RUN set -ex \
    && runDeps="git bash musl-dev openssl-dev gcc" \
    && apk add --no-cache --virtual .build-deps ${runDeps} \
    && wget -t5 -T20 -c https://sh.rustup.rs -O /root/rust.sh \
    && sh /root/rust.sh -y && source $HOME/.cargo/env \
    && chmod +x /root/build_ray-plugin.sh /root/build_shadowsocks-rust.sh \
    && bash /root/build_ray-plugin.sh \
    && bash /root/build_shadowsocks-rust.sh \
    && rm -f /root/build_ray-plugin.sh /root/build_shadowsocks-rust.sh /root/rust.sh \
    && apk del --no-network --purge .build-deps

FROM alpine:latest
LABEL maintainer="zdevcs <mail@zdev.me>"

COPY --from=builder /root/build/* /usr/bin/
COPY config_sample.json /etc/shadowsocks-rust/config.json

RUN set -ex && \
    apk add --no-cache tzdata rng-tools \
    $(scanelf --needed --nobanner $(which sslocal) $(which ssmanager) $(which ssserver) $(which ssurl) \
    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
    | xargs -r apk info --installed \
    | sort -u)

WORKDIR /etc/shadowsocks-rust
VOLUME /etc/shadowsocks-rust
ENV TZ=Asia/Shanghai
CMD [ "/usr/bin/ssserver", "-c", "/etc/shadowsocks-rust/config.json" ]
