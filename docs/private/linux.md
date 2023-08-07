# Private snippets for geektr

## Install

run as root:

```bash
source <(curl -s https://planetarian.geektr.co/-/linux/pre.sh)

set-apt-proxy http://proxy.geektr.co:3128

auto-init-system https://planetarian.geektr.co/-/private/planetarian.json
```

run as geektr:

```bash
source <(curl -s https://planetarian.geektr.co/-/linux/pre.sh)

set-proxy http://proxy.geektr.co:3128
install-planetarian
auto-init-planetarian https://planetarian.geektr.co/-/private/planetarian.json all

refresh-system
```

## Install Docker

```bash
source <(curl -s https://planetarian.geektr.co/-/linux/pre.sh)

docker-install
docker-set-proxy $(planetarian::proxy::get-proxy) $(planetarian::proxy::get-no-proxy)
# docker-set-proxy 'http://proxy.geektr.co:3128' '127.0.0.0/8,10.0.0.0/8,localhost,*.aliyuncs.com,*.geektr.co'
```

## Intall K3S

```bash
source <(curl -s https://planetarian.geektr.co/-/linux/pre.sh)

# https://docs.k3s.io/cli/server
k3s-install \
  --write-kubeconfig-mode 0644 \
  --node-external-ip 0.0.0.0 \
  --tls-san domain.geektr.co \
  --kube-apiserver-arg service-node-port-range=1-65535

k3s-set-proxy 'http://proxy.geektr.co:3128' '127.0.0.0/8,10.0.0.0/8,localhost,*.aliyuncs.com,*.geektr.co'
```

## Update Config

```bash
ossutil cp --acl=public-read -f config-template.json \
  oss://co-geektr-planetarian/-/private/planetarian.json
```

## Git

```bash
git config --global user.name "GeekTR"
git config --global user.email "geektheripper@gmail.com"
git config --global init.defaultBranch "goshujin-sama"
git config --global pull.ff only
```
