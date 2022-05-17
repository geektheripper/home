#!/usr/bin/env bash

set -e

latest_ver() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

if planetarian::net::in-gfw; then
  planetarian::proxy::set
fi

version=$(latest_ver docker/compose)

DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/$version/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
#!/usr/bin/env bash

set -e

latest_ver() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

if planetarian::net::in-gfw; then
  planetarian::proxy::set
fi

version=$(latest_ver docker/compose)

DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/$version/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose
