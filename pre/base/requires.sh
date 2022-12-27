#!/usr/bin/env bash

# requires
require::root() {
  if [ "$EUID" -ne 0 ]; then
    echo >&2 "must run as root"
    return 1
  fi
}

require::non-root() {
  if [ "$EUID" -eq 0 ]; then
    echo >&2 "must not run as root"
    return 1
  fi
}

require::toolbox() {
  if [ -f "$_pre_bin/toolbox" ]; then return 0; fi

  mkdir -p "$_pre_bin"
  download "$_pre_bin/toolbox" "$_res_url_prefix/bin/toolbox"
  chmod -R 777 "$_pre_bin"
}
toolbox() { "$_pre_bin/toolbox" "$@"; }
