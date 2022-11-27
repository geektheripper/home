#!/usr/bin/env bash

planetarian::init() {
  bash -i "$PLANETARIAN_HOME/init/$1.sh"
}

planetarian::command init planetarian::init

planetarian::init::utils::set-proxy() {
  if [ -z "$HTTP_PROXY" ] && planetarian::net::in-gfw; then
    planetarian::proxy::set
    I_SET_PROXY=true
  fi
  reset_proxy() {
    if [ "$I_SET_PROXY" = "true" ]; then
      planetarian::proxy::unset
      echo "proxy unset"
    fi
  }
  trap reset_proxy EXIT
}

planetarian::init::utils::cd-tempdir() {
  temp_dir=$(mktemp -d)
  flag=$1
  clear_temp_dir() {
    [ "$flag" == "debug" ] && return
    rm -r "$temp_dir"
  }
  trap clear_temp_dir EXIT
  cd "$temp_dir" || exit
}

BEDITOR="$PLANETARIAN_BIN/toolbox block-editor write"
planetarian::init::utils::block-edit() {
  $BEDITOR "$@"
}
