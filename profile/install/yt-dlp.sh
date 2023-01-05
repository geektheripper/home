#!/usr/bin/env bash

. "$HOME/.planetarian/profile/planetarian-install.sh"

planetarian::install::utils::require-proxy
planetarian::install::utils::cd-tempdir

version=$(planetarian::install::utils::github-latest-ver yt-dlp/yt-dlp)

wget https://github.com/yt-dlp/yt-dlp/releases/download/${version}/yt-dlp

planetarian::install::utils::place-binary yt-dlp yt-dlp
