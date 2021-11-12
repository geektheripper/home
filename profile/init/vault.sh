#!/usr/bin/env bash

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

papt() {
  if planetarian::net::in-gfw; then
    planetarian::proxy::set
    # shellcheck disable=SC2154
    sudo http_proxy="$http_proxy" https_proxy="$http_proxy" apt-get "$@"
  else
    sudo apt-get "$@"
  fi
}

papt update
papt install -y vault
