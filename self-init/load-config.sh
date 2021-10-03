#!/usr/bin/env bash

planetarian_remote_config=${planetarian_remote_config:-$1}

planetarian_config=$(curl "$planetarian_remote_config")

json_pick() {
  echo "$1" | jq -r "$2"
}

# Vault
load_vault() {
  planetarian_vault_config=$(json_pick "$planetarian_config" '.planetarian.secret.vault')
  planetarian::secret::vault::set_host "$(json_pick "$planetarian_vault_config" '.address')"
  planetarian::secret::vault::set_user "$(json_pick "$planetarian_vault_config" '.user')"
}

# Proxy
load_proxy() {
  planetarian::proxy::set-default "$(json_pick "$planetarian_config" '.planetarian.proxy.default_server')"

  if [[ "$(json_pick "$planetarian_config" '.planetarian.proxy.autoload')" == "true" ]]; then
    planetarian::proxy::autoload true
  fi
}

load_vault
load_proxy
