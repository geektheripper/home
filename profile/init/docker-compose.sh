#!/usr/bin/env bash

latest_ver() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

install_docker_compose() {
  version=$(latest_ver docker/compose)

  sudo curl -L "https://github.com/docker/compose/releases/download/${version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
}

if planetarian::net::in-gfw; then
  planetarian::proxy::set
fi

install_docker_compose
