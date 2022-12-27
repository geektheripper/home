#!/usr/bin/env bash

auto-init-system() {
  require::toolbox || return $?

  # Install nessary dependencies
  if ! command -v jq &>/dev/null; then
    sudo apt-get update && sudo apt-get install -y jq
  fi

  local planetarian_remote_config=$1
  local planetarian_config=$(fetch "$planetarian_remote_config")

  echo "$planetarian_config" | jq -c '.init.users[]' | while read -r i; do
    username=$(json_pick "$i" '.username')
    public_key=$(json_pick "$i" '.public_key')
    allow_sudo=$(json_pick "$i" '.allow_sudo')

    init-user "$username" "$public_key" "$allow_sudo"
  done
}
