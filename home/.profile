#!/usr/bin/env bash

export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'
export LC_ALL='en_US.UTF-8'
export TERM='xterm'

export PLANETARIAN_ROOT="$HOME"/.planetarian
export PLANETARIAN_HOME="$HOME"/.planetarian/home

function planetarian::quick_hash() {
  echo "$1" | cksum | awk '{print $1}'
}

function planetarian::command() {
  eval "pltr_cmd_$(planetarian::quick_hash " $1")=$2"
}
alias pcmd='planetarian::command'

function planetarian() {
  command_key=""

  while true; do
    command_key="$command_key $1"
    shift

    command=$(eval 'echo $pltr_cmd_'"$(planetarian::quick_hash "$command_key")"'')

    if [ -n "$command" ]; then break; fi
    if [ -z "$1" ]; then
      echo >&2 'command not found'
      return 1
    fi
  done

  $command "$@"
}
alias i='planetarian'

planetarian::safe_source() {
  if [ -f "$1" ]; then
    # shellcheck disable=SC1090
    . "$1"
  fi
}

planetarian::safe_prepend() {
  if [ -d "$1" ]; then
    if [[ $PATH == *"$1:"* ]]; then
      export PATH=${PATH//$1:/}
    fi
    if [[ $PATH == *":$1" ]]; then
      export PATH=${PATH//:$1/}
    fi
    export PATH="$1:$PATH"
  fi
}

planetarian::profile::reload() {
  for file in "$PLANETARIAN_HOME"/.profile.d/*; do
    if [ -f "$file" ]; then
      planetarian::safe_source "$file"
    fi
  done
}
planetarian::profile::manual_reload() {
  planetarian::safe_source "$PLANETARIAN_HOME"/.profile
}
pcmd reload planetarian::profile::manual_reload

planetarian::update() {
  git -C "$PLANETARIAN_ROOT" pull && planetarian::profile::manual_reload
}
pcmd update planetarian::profile::update

planetarian::config() {
  action=$1
  conf_file="$PLANETARIAN_HOME"/.profile-config.ini
  shift
  if [[ "add" == "$action" ]]; then
    crudini --set --list --list-sep ',' "$conf_file" "$@"
  elif [[ "remove" == "$action" ]]; then
    crudini --del --list --list-sep ',' "$conf_file" "$@"
  else
    crudini --"$action" "$conf_file" "$@"
  fi
}
pcmd config planetarian::config

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
pcmd switch planetarian::feature_switch

planetarian::profile::reload

planetarian::init() {
  bash -i "$PLANETARIAN_ROOT"/init/"$1".sh
}
pcmd init planetarian::init
