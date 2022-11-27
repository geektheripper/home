#!/usr/bin/env bash

set -e

if planetarian::net::in-gfw; then
  planetarian::proxy::set
fi

_tmp_dir=$(mktemp -d)
trap "rm -r $_tmp_dir" EXIT
pushd "$_tmp_dir" || exit

wget "https://github.com/koalaman/shellcheck/releases/download/latest/shellcheck-latest.linux.x86_64.tar.xz"
tar xvf shellcheck-latest.linux.x86_64.tar.xz
sudo cp shellcheck-latest/shellcheck /usr/bin/shellcheck
