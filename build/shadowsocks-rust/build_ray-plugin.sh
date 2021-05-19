# !/bin/bash

# Copyright (C) 2021 zdevcs <mail@zdev.me>
# Reference URL:
# https://github.com/teddysun/v2ray-plugin
# https://github.com/teddysun/xray-plugin

COMMANDS=(git go wget)
for CMD in "${COMMANDS[@]}"; do
    if [ ! "$(command -v "${CMD}")" ]; then
        echo "${CMD} is not installed, please install it and try again." && exit 1
    fi
done

PLUGINS=(v2ray-plugin xray-plugin)

for PLUGIN in ${PLUGINS[@]}; do
    cd ${HOME}
    PLUGIN_URL="https://github.com/teddysun/${PLUGIN}.git"
    PLUGIN_HOME=$(pwd)/${PLUGIN}
    PLUGIN_VER=$(wget -qO- -c -t20 -T2 \
        "https://api.github.com/repos/teddysun/${PLUGIN}/releases/latest" |
        grep "tag_name" | cut -d\" -f4)
    LDFLAGS="-X main.VERSION=${PLUGIN_VER} -s -w"
    git clone --branch "${PLUGIN_VER}" --depth=1 "${PLUGIN_URL}" && cd "${PLUGIN_HOME}"
    mkdir -p /root/build/
    echo "Building ${PLUGIN}..."
    env CGO_ENABLED=0 go build -v -trimpath -ldflags "${LDFLAGS}" -o /root/build/${PLUGIN} || exit 1
    cd ${HOME}
    rm -rf "${PLUGIN_HOME}"
done
