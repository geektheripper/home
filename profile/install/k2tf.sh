#!/usr/bin/env bash

. "$HOME/.planetarian/profile/planetarian-install.sh"

planetarian::install::utils::require-proxy
planetarian::install::utils::cd-tempdir

version=$(planetarian::install::utils::github-latest-ver sl1pm4t/k2tf)

wget -O k2tf.tar.gz "https://github.com/sl1pm4t/k2tf/releases/download/v${version}/k2tf_${version}_Linux_x86_64.tar.gz"
tar -xzf k2tf.tar.gz

planetarian::install::utils::place-binary k2tf k2tf
