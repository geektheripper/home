#!/usr/bin/env bash

latest_ver() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

version=$(latest_ver qjfoidnh/BaiduPCS-Go)

mkdir /tmp/bdpcs
cd /tmp/bdpcs || exit
wget -O bdpcs.zip "https://github.com/qjfoidnh/BaiduPCS-Go/releases/download/$version/BaiduPCS-Go-$version-linux-amd64.zip"
unzip bdpcs.zip
sudo mv BaiduPCS-Go-"$version"-linux-amd64/BaiduPCS-Go /usr/local/bin/bdpcs
sudo chown root:root /usr/local/bin/bdpcs
rm -r /tmp/bdpcs
