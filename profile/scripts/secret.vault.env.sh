#!/usr/bin/env bash
planetarian::secret::vault::env::keys() {
  planetarian::secret::vault::json "$1" | jq -r 'to_entries | map(.key) | join(" ")'
}

planetarian::secret::vault::env::pair() {
  planetarian::secret::vault::json "$1" | jq -r 'to_entries | map(.key + "=" + "'"'"'" + (.value | tostring) +"'"'"'") | join(" ")'
}

planetarian::secret::vault::env::load() {
  eval "$(planetarian::secret::vault::env::pair "$1")"
}

planetarian::secret::vault::env::export() {
  eval "export $(planetarian::secret::vault::env::pair "$1")"
}

planetarian::secret::vault::env::unset() {
  keys=$(planetarian::secret::vault::env::keys "$1")
  eval "unset $keys"
  eval "export $keys"
}

planetarian::secret::vault::env::envsubst() {
  eval "$(planetarian::secret::vault::env::pair "$1") envsubst"
}

planetarian::secret::vault::env() {
  command="planetarian::secret::vault::env::$1"
  shift
  $command "$@"
}

planetarian::command "vault env" planetarian::secret::vault::env
