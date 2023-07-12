#!/usr/bin/env bash

. "$HOME/.planetarian/profile/planetarian-install.sh"

planetarian::install::utils::require-proxy
planetarian::install::utils::cd-tempdir

version=$(planetarian::install::utils::github-latest-ver iawia002/lux)

wget -O lux.tar.gz "https://github.com/iawia002/lux/releases/download/v${version}/lux_${version}_Linux_x86_64.tar.gz"
tar -xzf lux.tar.gz

planetarian::install::utils::place-binary lux lux
