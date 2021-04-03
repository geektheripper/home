#!/usr/bin/env bash

function planetarian::quick_hash() {
  echo "$1" | cksum | awk '{print $1}'
}

function planetarian::command() {
  eval "pltr_cmd_$(planetarian::quick_hash " $1")=$2"
}

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

alias pcmd='planetarian::command'
alias i='planetarian'