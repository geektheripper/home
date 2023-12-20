#!/usr/bin/env bash

. "$HOME/.planetarian/profile/planetarian-install.sh"

planetarian::install::utils::help-msg "$@" <<EOF
i install node [major version and package manager]
i install node 20
i install node 20 pnpm yarn
i install node pnpm@8.12.1
EOF

planetarian::install::utils::require-proxy

NODE_MAJOR=
YARN_VERSION=
PNPM_VERSION=

while [ $# -gt 0 ]; do
  case "$1" in
  [0-9]*)
    NODE_MAJOR=$1
    shift
    ;;
  yarn*)
    YARN_VERSION=$1
    shift
    ;;
  pnpm*)
    PNPM_VERSION=$1
    shift
    ;;
  *)
    break
    echo "unknown argument: $1"
    ;;
  esac
done

if ! [ -z "$NODE_MAJOR" ]; then
  # https://github.com/nodesource/distributions

  planetarian::install::utils::apt::ensure \
    ca-certificates curl gnupg

  planetarian::install::utils::apt::import-key \
    nodesource https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key

  planetarian::install::utils::apt::set-repo \
    nodejs "deb https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main"

  sudo apt-get update
  sudo apt-get install -y nodejs
  echo "node@$(node --version) installed"
fi

node_check() {
  if ! command -v node &>/dev/null; then
    echo "node is not installed"
    exit 1
  fi

  if ! [ "$(echo -e "$(node --version)\nv16.17" | sort -V | head -n1)" = "v16.17" ]; then
    echo "node version under 16.17 is not supported"
    exit 1
  fi
}

if ! [ -z "$YARN_VERSION" ]; then
  if [ "$YARN_VERSION" = "yarn" ]; then YARN_VERSION="yarn@stable"; fi
  node_check
  corepack prepare "$YARN_VERSION" --activate
  echo "yarn@$(yarn --version) installed"
fi

if ! [ -z "$PNPM_VERSION" ]; then
  if [ "$PNPM_VERSION" = "pnpm" ]; then PNPM_VERSION="pnpm@latest"; fi
  node_check
  corepack prepare "$PNPM_VERSION" --activate
  echo "pnpm@$(pnpm --version) installed"
fi
