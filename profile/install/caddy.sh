#!/usr/bin/env bash

. "$HOME/.planetarian/profile/planetarian-install.sh"

planetarian::install::utils::require-proxy
planetarian::install::utils::cd-tempdir

version=$(planetarian::install::utils::github-latest-ver caddyserver/caddy)

wget -O "caddy.tar.gz" "https://github.com/caddyserver/caddy/releases/download/v${version}/caddy_${version}_linux_amd64.tar.gz"
tar -xvzf caddy.tar.gz

planetarian::install::utils::place-binary ./caddy caddy
