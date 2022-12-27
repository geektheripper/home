#!/usr/bin/env bash

set -e

planetarian::install::utils::require-proxy
planetarian::install::utils::cd-tempdir

wget "https://github.com/koalaman/shellcheck/releases/download/latest/shellcheck-latest.linux.x86_64.tar.xz"
tar xvf shellcheck-latest.linux.x86_64.tar.xz

planetarian::install::utils::place-binary shellcheck-latest/shellcheck shellcheck
