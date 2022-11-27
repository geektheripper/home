#!/usr/bin/env bash

planetarian::secret::vault::install() {
  planetarian::install vault
}

planetarian::secret::vault::clear() {
  unset VAULT_ADDR
  unset VAULT_USER
  rm -f ~/.vault-token
}

planetarian::secret::vault::load() {
  VAULT_ADDR=$(planetarian::config secret:vault_addr read 2>/dev/null)
  if [ -z "$VAULT_ADDR" ]; then
    echo >&2 "\$VAULT_ADDR not set"
    return 1
  fi

  export VAULT_ADDR
}

planetarian::secret::vault::login() {
  planetarian::secret::vault::load

  VAULT_USER=$(planetarian::config secret:vault_user read 2>/dev/null)
  if [ -z "$VAULT_USER" ]; then
    echo >&2 "\$VAULT_USER not set"
    return 1
  fi

  vault token revoke -self 2>/dev/null
  unset VAULT_TOKEN
  vault login -no-print -method=userpass username="$VAULT_USER"
  VAULT_TOKEN=$(vault token lookup --format json | jq -r '.data.id')
  export VAULT_TOKEN
}

planetarian::secret::vault::su() {
  echo -n "root token: "
  read -rs VAULT_TOKEN
  export VAULT_TOKEN
}

planetarian::secret::vault::set_host() {
  planetarian::config secret:vault_addr write "$1"
  planetarian::secret::vault::clear
  planetarian::secret::vault::load
}

planetarian::secret::vault::set_user() {
  planetarian::secret::vault::clear
  planetarian::config secret:vault_user write "$1"
}

planetarian::secret::vault::json() {
  _json=$(vault kv get --format json "$1")
  _json_jq() { echo "$_json" | jq -r "$1"; }
  if [[ "$(_json_jq '.data.data | type')" == "object" ]] && [[ "$(_json_jq '.data.metadata | type')" == "object" ]]; then
    _json_jq '.data.data'
  else
    _json_jq '.data'
  fi
}

planetarian::config secret:autoload switch test yes && planetarian::secret::vault::load

planetarian::command "vault set-host" planetarian::secret::vault::set_host
planetarian::command "vault set-user" planetarian::secret::vault::set_user
planetarian::command "vault login" planetarian::secret::vault::login
planetarian::command "vault su" planetarian::secret::vault::su

planetarian::command "vault json" planetarian::secret::vault::json
