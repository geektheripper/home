#!/usr/bin/env bash

. "$HOME/.planetarian/profile/planetarian-install.sh"

planetarian::install::utils::require-proxy
planetarian::install::utils::cd-tempdir

version=$(planetarian::install::utils::github-latest-ver teamon/hclfmt)

wget "https://github.com/teamon/hclfmt/releases/download/v${version}/hclfmt_${version}_Linux_x86_64.gz"
gzip -d "hclfmt_${version}_Linux_x86_64.gz"

planetarian::install::utils::place-binary "hclfmt_${version}_Linux_x86_64" hclfmt
