#!/usr/bin/env bash

# TODO:detect in gfw or not

k3s-set-proxy() {
  sudo tee /etc/systemd/system/k3s.service.env <<EOF
CONTAINERD_HTTP_PROXY='${1}'
CONTAINERD_HTTPS_PROXY='${1}'
CONTAINERD_NO_PROXY='${2}'
EOF

  sudo systemctl daemon-reload
  sudo systemctl restart k3s
}

k3s-install() {
  curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_KUBECONFIG_MODE="440" INSTALL_K3S_EXEC="server" sh -s - $@
  sudo chown root:sudo /etc/rancher/k3s/k3s.yaml
}
