#!/usr/bin/env bash

planetarian::install() {
  if [ "$1" = "-g" ] || [ "$1" = "--global" ]; then
    local GLOBAL_INSTALL=true
    shift
  fi

  local install_script="$PLANETARIAN_HOME/install/$1.sh"
  shift

  GLOBAL_INSTALL=$GLOBAL_INSTALL bash -i "$install_script" "$@"
}

planetarian::command install planetarian::install
