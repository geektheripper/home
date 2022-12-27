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

install-planetarian
auto-init-planetarian https://planetarian.geektr.co/-/private/planetarian.json all
```

## Install Docker

```bash
source <(curl -s https://planetarian.geektr.co/-/linux/pre.sh)

docker-install
docker-set-proxy $(planetarian::proxy::get-proxy) $(planetarian::proxy::get-no-proxy)
# docker-set-proxy 'http://proxy.geektr.co:3128' '127.0.0.0/8,10.0.0.0/8,localhost,*.aliyuncs.com,*.geektr.co'
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
