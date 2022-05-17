#!/usr/bin/env bash

set -e

if planetarian::net::in-gfw; then
  planetarian::proxy::set
fi

go_dl_url="https://golang.org$(wget -qO- https://golang.org/dl | grep -oP '/dl\/go([0-9\.]+)\.linux-amd64\.tar\.gz' | head -n 1)"

_tmp_dir=$(mktemp -d)
trap "rm -r $_tmp_dir" EXIT
pushd "$_tmp_dir" || exit

wget $go_dl_url
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.18.2.linux-amd64.tar.gz
