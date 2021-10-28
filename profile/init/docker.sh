#!/usr/bin/env bash

latest_ver() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

set_aliyun_mirror() {
  mkdir -p /etc/docker

  echo '{"registry-mirrors": ["https://23deml29.mirror.aliyuncs.com"]}' | sudo tee /etc/docker/daemon.json

  sudo systemctl daemon-reload
  sudo systemctl restart docker
}

install_docker_compose() {
  version=$(latest_ver docker/compose)

  sudo curl -L "https://github.com/docker/compose/releases/download/${version}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
}

if planetarian::net::in-gfw; then
  curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
  set_aliyun_mirror
else
  curl -fsSL https://get.docker.com | bash -s docker
fi

planetarian::proxy::set
install_docker_compose
