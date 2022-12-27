#!/usr/bin/env bash

planetarian::vault() {
  VAULT_ROOT_TOKEN=$VAULT_ROOT_TOKEN planetarian::toolbox @vault "$@"
}

planetarian::secret::vault::su() { eval "$(planetarian::vault su)"; }
planetarian::secret::vault::sudo() { VAULT_TOKEN=$VAULT_ROOT_TOKEN "$@"; }
planetarian::secret::vault::jq() { eval "$(planetarian::vault jq "$@")"; }

planetarian::secret::vault::reset() { echo "" >~/.vault-token; }

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

  VAULT_TOKEN_FILE="$PLANETARIAN_PRIVATE/secret/vault-token" \
    VAULT_USER="$VAULT_USER" \
    planetarian::vault login
}

planetarian::secret::vault::set_host() {
  planetarian::config secret:vault_addr write "$1"
  planetarian::secret::vault::reset
  planetarian::secret::vault::load
}

planetarian::secret::vault::set_user() {
  planetarian::secret::vault::reset
  planetarian::config secret:vault_user write "$1"
}

planetarian::secret::vault::tf() {
  eval "$(planetarian::vault jq -p "planetarian-kv/$1" -f export-map 'with_entries(.key |= "TF_VAR_\(.)")')"
}

planetarian::config secret:autoload switch test yes && planetarian::secret::vault::load

planetarian::command "vault set-host" planetarian::secret::vault::set_host
planetarian::command "vault set-user" planetarian::secret::vault::set_user
planetarian::command "vault login" planetarian::secret::vault::login
planetarian::command "vault reset" planetarian::secret::vault::reset
planetarian::command "vault su" planetarian::secret::vault::su
planetarian::command "vault sudo" planetarian::secret::vault::sudo
planetarian::command "vault jq" planetarian::secret::vault::jq
planetarian::command "vault tf" planetarian::secret::vault::tf
