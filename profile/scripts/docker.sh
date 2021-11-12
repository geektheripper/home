#!/usr/bin/env bash

planetarian::docker::set-proxy() {
  _proxy=$(planetarian::proxy::get-proxy "$1")
  _no_proxy=$(planetarian::proxy::get-no-proxy)

  mkdir -p "$HOME"/.docker

  _file="$HOME"/.docker/config.json
  if [ ! -f "$_file" ]; then
    echo '{}' >"$_file"
  fi

  # shellcheck disable=SC2094
  jq \
    --arg _proxy "$_proxy" \
    --arg _no_proxy "$_no_proxy" \
    '.proxies.default.httpProxy = $_proxy |
     .proxies.default.httpsProxy = $_proxy |
     .proxies.default.noProxy = $_no_proxy' \
    "$_file" | tac | tac >"$_file"
}

planetarian::docker::unset-proxy() {
  _file="$HOME"/.docker/config.json
  if [ -f "$_file" ]; then
    # shellcheck disable=SC2094
    jq \
      'del(.proxies.default.httpProxy) |
       del(.proxies.default.httpsProxy) |
       del(.proxies.default.noProxy)' \
      "$_file" | tac | tac >"$_file"
  fi
}

planetarian::docker() {
  command="planetarian::docker::$1"
  shift
  $command "$@"
}

planetarian::command docker planetarian::docker
