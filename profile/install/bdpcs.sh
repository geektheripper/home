#!/usr/bin/env bash

latest_ver() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

set -e

if planetarian::net::in-gfw; then
  planetarian::proxy::set
fi

version=$(latest_ver qjfoidnh/BaiduPCS-Go)

_tmp_dir=$(mktemp -d)
trap "rm -r $_tmp_dir" EXIT
pushd "$_tmp_dir" || exit

wget -O bdpcs.zip "https://github.com/qjfoidnh/BaiduPCS-Go/releases/download/$version/BaiduPCS-Go-$version-linux-amd64.zip"
unzip bdpcs.zip
sudo mv BaiduPCS-Go-"$version"-linux-amd64/BaiduPCS-Go /usr/local/bin/bdpcs
sudo chown root:root /usr/local/bin/bdpcs
