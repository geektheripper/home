#!/usr/bin/env bash

planetarian::secret::vault::set_host() {
  planetarian::config set secret vault_addr "$1"
}
planetarian::secret::vault::set_user() {
  planetarian::config set secret vault_user "$1"
}
planetarian::secret::vault::login() {
  VAULT_PERIOD=${1:-1h}

  VAULT_ADDR=$(planetarian::config get secret vault_addr 2>/dev/null)
  VAULT_ADDR=${VAULT_ADDR:-"https://vault.geektr.co"}
  export VAULT_ADDR

  VAULT_USER=$(planetarian::config get secret vault_user 2>/dev/null)
  VAULT_USER=${VAULT_USER:-"planetarian"}

  unset VAULT_TOKEN
  vault login -no-print -method=userpass username="$VAULT_USER"
  tmp_token="$(vault token create -explicit-max-ttl "$VAULT_PERIOD" -format json | jq -r '.auth.client_token')"
  vault login -no-print "$tmp_token"
  export VAULT_TOKEN="$tmp_token"
  unset tmp_token
}

pcmd "vault set-host" planetarian::secret::vault::set_host
pcmd "vault set-user" planetarian::secret::vault::set_user
pcmd "vault login" planetarian::secret::vault::login
