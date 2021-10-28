#!/usr/bin/env bash

set_aliyun_mirror() {
  mkdir -p /etc/docker

  echo '{"registry-mirrors": ["https://23deml29.mirror.aliyuncs.com"]}' | sudo tee /etc/docker/daemon.json

  sudo systemctl daemon-reload
  sudo systemctl restart docker
}

if planetarian::net::in-gfw; then
  curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
  set_aliyun_mirror
else
  curl -fsSL https://get.docker.com | bash -s docker
fi
