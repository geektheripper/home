#!/usr/bin/env bash

planetarian::secret::vault::init() {
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt-get update && sudo apt-get install vault
}

planetarian::secret::vault::clear() {
  unset VAULT_ADDR
  unset VAULT_USER
  rm -f ~/.vault-token
}

planetarian::secret::vault::load() {
  VAULT_ADDR=$(planetarian::config get secret vault_addr 2>/dev/null)
  VAULT_ADDR=${VAULT_ADDR:-"https://vault.geektr.co"}
  export VAULT_ADDR
}

planetarian::secret::vault::login() {
  planetarian::secret::vault::load

  VAULT_USER=$(planetarian::config get secret vault_user 2>/dev/null)
  VAULT_USER=${VAULT_USER:-"planetarian"}

  vault login -no-print -method=userpass username="$VAULT_USER"
}

planetarian::secret::vault::set_host() {
  planetarian::config set secret vault_addr "$1"
  planetarian::secret::vault::clear
  planetarian::secret::vault::load
}

planetarian::secret::vault::set_user() {
  planetarian::secret::vault::clear
  planetarian::config set secret vault_user "$1"
  planetarian::secret::vault::login
}

planetarian::feature_switch secret autoload && planetarian::secret::vault::load

pcmd "vault set-host" planetarian::secret::vault::set_host
pcmd "vault set-user" planetarian::secret::vault::set_user
pcmd "vault login" planetarian::secret::vault::login
