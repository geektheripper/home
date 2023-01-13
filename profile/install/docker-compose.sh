#!/usr/bin/env bash

. "$HOME/.planetarian/profile/planetarian-install.sh"

planetarian::install::utils::require-proxy
planetarian::install::utils::cd-tempdir

version=$(planetarian::install::utils::github-latest-ver docker/compose)

MAYBE_SUDO=

if [ -z "$DOCKER_CONFIG" ]; then
  if [ "$GLOBAL_INSTALL" = "true" ]; then
    MAYBE_SUDO=sudo
    DOCKER_CONFIG=/usr/local/lib/docker
  else
    DOCKER_CONFIG=$HOME/.docker
  fi
fi

wget -O docker-compose "https://github.com/docker/compose/releases/download/v$version/docker-compose-linux-x86_64"
chmod +x docker-compose

$MAYBE_SUDO mkdir -p "$DOCKER_CONFIG/cli-plugins"
$MAYBE_SUDO mv docker-compose "$DOCKER_CONFIG/cli-plugins/"
