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

version=$(latest_ver caddyserver/caddy)

_tmp_dir=$(mktemp -d)
trap "rm -r $_tmp_dir" EXIT
pushd "$_tmp_dir" || exit

wget -O "caddy.tar.gz" "https://github.com/caddyserver/caddy/releases/download/v${version}/caddy_${version}_linux_amd64.tar.gz"
tar -xvzf caddy.tar.gz
mv caddy "$HOME"/.local/bin
