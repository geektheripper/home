#!/usr/bin/env bash

planetarian::secret::init_drive() {
  pltr_secret_base="/run/planetarian/secret"
  if df -a | grep "$pltr_secret_base" >/dev/null; then
    echo "$pltr_secret_base"
    return 0
  fi
  sudo mkdir -p "$pltr_secret_base"
  sudo mount -t ramfs ramfs "$pltr_secret_base"
  sudo chown "$UID:$UID" "$pltr_secret_base"
  sudo chmod go-rwx "$pltr_secret_base"
  echo "$pltr_secret_base"
}

planetarian::secret::init() {
  planetarian::secret::vault::init
  planetarian::feature_switch secret autoload on
}

planetarian::feature_switch secret autoload && planetarian::secret::init_drive >/dev/null

pcmd "secret init" planetarian::secret::init
