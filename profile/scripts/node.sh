#!/usr/bin/env bash

planetarian::node::configure_npm() {
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/lib/npm"
  mkdir -p "$HOME/.cache/npm"

  npm config set prefix "$HOME/.local/bin"
  npm config set global "$HOME/.local/lib/npm"
  npm config set cache "$HOME/.cache/npm"
}

planetarian::node::configure_yarn() {
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/lib/yarn"
  mkdir -p "$HOME/.cache/yarn"

  yarn config set prefix "$HOME/.local/bin"
  yarn config set global-folder "$HOME/.local/lib/yarn"
  yarn config set cache-folder "$HOME/.cache/yarn"
}

planetarian::node::init() {
  planetarian::node::configure_npm
  planetarian::node::configure_yarn
}

planetarian::node::install() {
  if [[ -z "$1" ]]; then
    echo "Usage: i node install <version> [package managers...]"
    return 1
  fi
  planetarian::install $1 yarn pnpm
  planetarian::node::init
}

planetarian::command 'node install' planetarian::node::install
planetarian::command 'node init' planetarian::node::init
