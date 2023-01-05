#!/usr/bin/env bash
# shellcheck disable=SC2181

planetarian::secret::vault::env::keys() {
  eval "$(planetarian::vault jq -p "$1" 'to_entries | map(.key) | join(" ")')"
}

planetarian::secret::vault::env::load() {
  eval "$(planetarian::vault jq -p "$1" -f assign-map)"
}

planetarian::secret::vault::env::run-with() {
  _path=$1
  shift
  # shellcheck disable=SC2145
  eval "$(planetarian::vault jq -p "$_path" -f assign-map) $@"
}

planetarian::secret::vault::env::export() {
  eval "$(planetarian::vault jq -p "$1" -f export-map)"
}

planetarian::secret::vault::env::unset() {
  keys=$(planetarian::secret::vault::env::keys "$1")
  if [ "$?" -ne "0" ]; then return 1; fi
  eval "unset $keys"
  eval "export $keys"
}

planetarian::secret::vault::env::envsubst() {
  eval "$(planetarian::vault jq -p "$1" -f assign-map) envsubst"
}

planetarian::secret::vault::env() {
  command="planetarian::secret::vault::env::$1"
  shift
  $command "$@"
}

planetarian::command "vault env" planetarian::secret::vault::env
