#!/usr/bin/env bash

# i env aliyun

. $HOME/.planetarian/profile/planetarian.sh

set -e

pushd "$PLANETARIAN_ROOT/toolbox/" || exit 0

go build -o "$PLANETARIAN_ROOT/bin/toolbox"

go build -ldflags="-s -w" -o toolbox
# upx toolbox --best --lzma

tar -czf toolbox.tar.gz toolbox
trap "rm toolbox.tar.gz" EXIT
ossutil cp --acl=public-read -f toolbox oss://co-geektr-flint/planetarian/bin/toolbox
ossutil cp --acl=public-read -f toolbox.tar.gz oss://co-geektr-flint/planetarian/bin/toolbox.tar.gz
