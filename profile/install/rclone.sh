#!/usr/bin/env bash

. "$HOME/.planetarian/profile/planetarian-install.sh"

planetarian::install::utils::require-proxy
planetarian::install::utils::cd-tempdir

version=$(planetarian::install::utils::github-latest-ver rclone/rclone)

wget -O rclone.deb "https://github.com/rclone/rclone/releases/download/v${version}/rclone-v${version}-linux-amd64.deb"
sudo dpkg -i rclone.deb
