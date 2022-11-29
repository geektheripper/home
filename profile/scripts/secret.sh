#!/usr/bin/env bash
planetarian_secret_drive_inited=

planetarian::secret::init_drive() {
  pltr_secret_base="$PLANETARIAN_PRIVATE/secret"

  if [[ "$planetarian_secret_drive_inited" == "true" ]]; then
    echo "$pltr_secret_base"
    return 0
  fi

  if [ ! -d "$pltr_secret_base" ]; then
    (umask 77 && mkdir "$pltr_secret_base")
  fi

  if planetarian::config secret:avoid_physical_attack switch test yes; then

    if df -a | grep "$pltr_secret_base" >/dev/null; then
      echo "$pltr_secret_base"
      return 0
    fi

    sudo mount -t ramfs ramfs "$pltr_secret_base"
    sudo chown "$UID:$UID" "$pltr_secret_base"
    sudo chmod go-rwx "$pltr_secret_base"
    echo "$pltr_secret_base"
  fi

  if [ ! -f "$HOME/.vault-token" ]; then
    ln -s "$PLANETARIAN_PRIVATE/secret/vault-token" "$HOME/.vault-token"
  fi

  planetarian_secret_drive_inited=true

  planetarian::secret::init_drive::post || echo "secrret post init failed"
}

planetarian::secret::init_drive::post() {
  for command in $(planetarian::config secret:post_init set list); do
    $command || return 1
  done
}

planetarian::secret::init() {
  planetarian::secret::vault::install
  planetarian::config secret:autoload switch turn yes
}

planetarian::config secret:autoload switch test yes && planetarian::secret::init_drive >/dev/null

planetarian::command "secret init" planetarian::secret::init
