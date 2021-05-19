# !/bin/bash

# Copyright (C) 2021 zdevcs <mail@zdev.me>
# Reference URL:
# https://github.com/shadowsocks/shadowsocks-rust

COMMANDS=(cargo git wget)
for CMD in "${COMMANDS[@]}"; do
    if [ ! "$(command -v "${CMD}")" ]; then
        echo "${CMD} is not installed, please install it and try again." && exit 1
    fi
done

cd ${HOME}
SHADOWSOCKS_URL=https://github.com/shadowsocks/shadowsocks-rust.git
SHADOWSOCKS_HOME=$(pwd)/shadowsocks-rust
EXTRA_FEATURES="dns-over-tls dns-over-https local-dns local-flow-stat local-http-native-tls local-redir local-tunnel"
SHADOWSOCKS_VER=$(wget -qO- -c -t20 -T2 \
    "https://api.github.com/repos/shadowsocks/shadowsocks-rust/releases/latest" |
    grep "tag_name" | cut -d\" -f4)
git clone --branch "${SHADOWSOCKS_VER}" --depth=1 "${SHADOWSOCKS_URL}" && cd "${SHADOWSOCKS_HOME}"
echo "Building shadowsocks-rust..."
RUSTFLAGS="-C target-feature=-crt-static" cargo build --release --features "${EXTRA_FEATURES}" --verbose || exit 1
cd ${HOME} && mkdir -p /root/build
cp -pv ${SHADOWSOCKS_HOME}/target/release/ss* /root/build
rm -rf ${SHADOWSOCKS_HOME} /root/build/ss*.d
