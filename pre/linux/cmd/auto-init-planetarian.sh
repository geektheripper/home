#!/usr/bin/env bash

# Vault
auto-init-vault() {
  planetarian_vault_config=$(json_pick "$1" '.planetarian.secret.vault')

  if [ -n "$planetarian_vault_config" ]; then
    planetarian::secret::init
    planetarian::secret::vault::set_host "$(json_pick "$planetarian_vault_config" '.address')"
    planetarian::secret::vault::set_user "$(json_pick "$planetarian_vault_config" '.user')"
  fi
}

# Proxy
auto-init-proxy() {
  planetarian::proxy::set-default "$(json_pick "$1" '.planetarian.proxy.default_server')"

  IFS=';' read -ra ADDR <<<"$(json_pick "$1" '.planetarian.proxy.no_proxy')"
  for i in "${ADDR[@]}"; do
    planetarian::proxy::no-proxy add "$i"
  done

  if [[ "$(json_pick "$1" '.planetarian.proxy.autoload')" == "true" ]]; then
    planetarian::proxy::autoload true
  fi
}

auto-init-planetarian() {
  load-planetarian

  # Install nessary dependencies
  if ! command -v jq &>/dev/null; then
    sudo apt-get update && sudo apt-get install -y jq
  fi

  local planetarian_config
  planetarian_config=$(fetch "$1")
  shift

  funcs=("$@")

  if [ "${funcs[*]}" = "all" ]; then funcs=(proxy vault); fi

  for func in "${funcs[@]}"; do
    "auto-init-$func" "$planetarian_config"
  done
}
