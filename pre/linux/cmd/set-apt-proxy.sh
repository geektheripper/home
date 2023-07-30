#!/usr/bin/env bash

set-apt-proxy() {
  require::root || return $?

  cat >/etc/apt/apt.conf.d/planetarian-proxy.conf <<EOF
Acquire {
  HTTP::proxy "$1";
  HTTPS::proxy "$1";
}
EOF
}
