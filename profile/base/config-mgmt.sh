#!/usr/bin/env bash

planetarian::config::read() {
  _scope=$1
  _key=$2
  _msg=$3

  crudini --get "$PLANETARIAN_CONFIG" "$_scope" "$_key" && return

  >&2 echo -n "$_msg"
  read -r config_value
  crudini --set "$PLANETARIAN_CONFIG" "$_scope" "$_key" "$config_value"
  echo "$config_value"
}

planetarian::config() {
  action=$1
  shift
  if [[ "add" == "$action" ]]; then
    crudini --set --list --list-sep ',' "$PLANETARIAN_CONFIG" "$@"
  elif [[ "remove" == "$action" ]]; then
    crudini --del --list --list-sep ',' "$PLANETARIAN_CONFIG" "$@"
  elif [[ "cread" == "$action" ]]; then
    planetarian::config::read "$@"
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

planetarian::command config planetarian::config
planetarian::command switch planetarian::feature_switch
