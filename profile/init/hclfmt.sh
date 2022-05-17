#!/usr/bin/env bash

set -e

latest_ver() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"v([^"]+)".*/\1/'
}

if planetarian::net::in-gfw; then
  planetarian::proxy::set
fi

version=$(latest_ver teamon/hclfmt)

_tmp_dir=$(mktemp -d)
trap "rm -r $_tmp_dir" EXIT
pushd "$_tmp_dir" || exit

wget https://github.com/teamon/hclfmt/releases/download/v${version}/hclfmt_${version}_Linux_x86_64.gz
gzip -d hclfmt_${version}_Linux_x86_64.gz
chmod +x hclfmt_${version}_Linux_x86_64
sudo mv hclfmt_${version}_Linux_x86_64 /usr/local/bin/hclfmt
