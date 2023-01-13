#!/usr/bin/env bash

. "$HOME/.planetarian/profile/planetarian-install.sh"

planetarian::install::utils::require-proxy

version=$(planetarian::install::utils::github-latest-ver docker/compose)

if [ -z "$DOCKER_CONFIG" ]; then
  if [ "$GLOBAL_INSTALL" = "true" ]; then
    DOCKER_CONFIG=/usr/local/lib/docker
  else
    DOCKER_CONFIG=$HOME/.docker
  fi
fi

mkdir -p "$DOCKER_CONFIG/cli-plugins"
curl -SL "https://github.com/docker/compose/releases/download/$version/docker-compose-linux-x86_64" -o "$DOCKER_CONFIG/cli-plugins/docker-compose"
chmod +x "$DOCKER_CONFIG/cli-plugins/docker-compose"
