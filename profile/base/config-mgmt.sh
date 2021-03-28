#!/usr/bin/env bash

planetarian::config() {
  action=$1
  shift
  if [[ "add" == "$action" ]]; then
    crudini --set --list --list-sep ',' "$PLANETARIAN_CONFIG" "$@"
  elif [[ "remove" == "$action" ]]; then
    crudini --del --list --list-sep ',' "$PLANETARIAN_CONFIG" "$@"
  else
    crudini --"$action" "$PLANETARIAN_CONFIG" "$@"
  fi
}

planetarian::feature_switch() {
  scope=$1
  switch=$2
  value=$3
  if [ -z "$value" ]; then
    [[ "on" == "$(planetarian::config get "$scope" "$switch")" ]]
  elif [[ "on" == "$value" ]]; then
    planetarian::config set "$scope" "$switch" on
  else
    planetarian::config del "$scope" "$switch"
  fi
} 2>/dev/null

pcmd config planetarian::config
pcmd switch planetarian::feature_switch
