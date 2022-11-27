#!/usr/bin/env bash

planetarian::install() {
  bash -i "$PLANETARIAN_HOME/install/$1.sh"
}

planetarian::command install planetarian::install

planetarian::install::utils::set-proxy() {
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

planetarian::install::utils::cd-tempdir() {
  temp_dir=$(mktemp -d)
  flag=$1
  clear_temp_dir() {
    [ "$flag" == "debug" ] && return
    rm -r "$temp_dir"
  }
  trap clear_temp_dir EXIT
  cd "$temp_dir" || exit
}

planetarian::install::utils::block-edit() {
  "$PLANETARIAN_TOOLBOX" block-editor write "$@"
}
