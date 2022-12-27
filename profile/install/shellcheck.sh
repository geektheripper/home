#!/usr/bin/env bash

. "$HOME/.planetarian/profile/planetarian-install.sh"

planetarian::install::utils::require-proxy
planetarian::install::utils::cd-tempdir

wget "https://github.com/koalaman/shellcheck/releases/download/latest/shellcheck-latest.linux.x86_64.tar.xz"
tar xvf shellcheck-latest.linux.x86_64.tar.xz

planetarian::install::utils::place-binary shellcheck-latest/shellcheck shellcheck
