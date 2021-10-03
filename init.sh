#!/usr/bin/env bash

gen_passwd() {
  (tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1) </dev/urandom
}

init_user() {
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

json_pick() {
  echo "$1" | jq -r "$2"
}

apt-get update && apt-get install -y sudo curl git jq

planetarian_remote_config=$1

planetarian_config=$(curl "$planetarian_remote_config")

echo "$planetarian_config" | jq -c '.init.users[]' | while read -r i; do
  username=$(json_pick "$i" '.username')
  public_key=$(json_pick "$i" '.public_key')
  allow_sudo=$(json_pick "$i" '.allow_sudo')

  init_user "$username" "$public_key" "$allow_sudo"
done
