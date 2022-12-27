#!/usr/bin/env bash

set -e

planetarian::install::utils::require-proxy
planetarian::install::utils::cd-tempdir

version=$(planetarian::install::utils::github-latest-ver caddyserver/caddy)

wget -O "caddy.tar.gz" "https://github.com/caddyserver/caddy/releases/download/v${version}/caddy_${version}_linux_amd64.tar.gz"
tar -xvzf caddy.tar.gz

planetarian::install::utils::place-binary ./caddy caddy
