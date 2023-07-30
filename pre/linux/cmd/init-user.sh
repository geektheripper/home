#!/usr/bin/env bash

init-user() {
  username=$1
  public_key=$2
  allow_sudo=$3

  HOME_DIR=/home/$username
  PASSWD="$(gen_passwd)"

  mkdir -p "$HOME_DIR/.ssh"

  id -u "$username" || {
    useradd --home-dir "$HOME_DIR" -s /bin/bash "$username"
    echo "$username:$PASSWD" | chpasswd
    chown -R "$username":"$username" "$HOME_DIR"
  }

  mkdir -p "$HOME_DIR/.ssh"
  echo "$public_key" >"$HOME_DIR/.ssh/authorized_keys"

  chown -R "$username:$username" "$HOME_DIR/.ssh"
  chmod -R go-rwsx "$HOME_DIR/.ssh"

  if [[ "$allow_sudo" == "true" ]]; then
    echo "$username ALL=(ALL) NOPASSWD:ALL" >"/etc/sudoers.d/99_$username"
    chmod 440 "/etc/sudoers.d/99_$username"
  fi
}
