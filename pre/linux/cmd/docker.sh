#!/usr/bin/env bash

docker-set-mirrors() {
  mkdir -p /etc/docker

  join_by() {
    local d=${1-} f=${2-}
    if shift 2; then
      printf %s "$f" "${@/#/$d}"
    fi
  }

  local snippet
  snippet=$(join_by '","' "$@")
  echo '{"registry-mirrors": ["'"${snippet}"'"]}' | sudo tee /etc/docker/daemon.json

  sudo systemctl daemon-reload
  sudo systemctl restart docker
}

docker-set-proxy() {
  sudo mkdir -p /etc/systemd/system/docker.service.d
  sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment='HTTP_PROXY=${1}'
Environment='HTTPS_PROXY=${1}'
Environment='NO_PROXY=${2}'
EOF

  sudo systemctl daemon-reload
  sudo systemctl restart docker
}

docker-install() {
  curl -fsSL https://get.docker.com | DOWNLOAD_URL=$1 bash -s docker
}
