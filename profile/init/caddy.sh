#!/usr/bin/env bash

latest_ver() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

if planetarian::net::in-gfw; then
  planetarian::proxy::set
fi

version=$(latest_ver caddyserver/caddy)

caddy_tmp_dir=$(mktemp -d)
trap rm -r caddy_tmp_dir

cd "$caddy_tmp_dir" || exit
wget -O "caddy.tar.gz" "https://github.com/caddyserver/caddy/releases/download/$version/caddy_2.4.5_linux_amd64.tar.gz"
tar -xvzf caddy.tar.gz
mv caddy "$HOME"/.local/bin
