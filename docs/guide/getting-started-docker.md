# Getting Started Docker

Load helper first,

```bash
source <(curl -s https://planetarian.geektr.co/-/linux/pre.sh)
```

then:

## Install

```bash
docker-install

# install via mirror
docker-install https://mirrors.aliyun.com/docker-ce
docker-install https://mirror.azure.cn/docker-ce
```

## Set proxy for docker daemon

```bash
docker-set-proxy <proxy-server> [no-proxy-list]
# docker-set-proxy http://proxy.example.com:3128 '127.0.0.0/8,10.0.0.0/8,localhost'
```

## Set mirror for docker

```bash
docker-set-mirrors <mirror-server> [mirror-servers...]
# docker-set-mirrors "http://hub-mirror.c.163.com" "https://docker.mirrors.ustc.edu.cn" "https://dockerhub.azk8s.cn" "	https://reg-mirror.qiniu.com" "https://registry.docker-cn.com"
```
