#!/usr/bin/env bash

planetarian::ssh::init() {
  secret_dir=$(planetarian::secret::init_drive)

  source_dir="$secret_dir/ssh"
  target_dir="$HOME/.ssh"

  mkdir -p "$source_dir/keys"
  mkdir -p "$source_dir/config.d"

  if [ ! -f "$target_dir/config" ]; then
    echo "Include ~/.ssh/config.d/*" >"$target_dir/config"
  fi

  if [ ! -d "$target_dir/keys" ]; then
    ln -s "$source_dir/keys" "$target_dir/keys"
  fi

  if [ ! -d "$target_dir/config.d" ]; then
    ln -s "$source_dir/config.d" "$target_dir/config.d"
  fi
}

planetarian::ssh::sync() {
  planetarian::ssh::init
  for collection_name in $(vault kv list -format=json "planetarian-kv/ssh/" | jq -r '.[]' | sed 's|/$||'); do
    planetarian::ssh::sync::pull "$collection_name"
  done
}

planetarian::ssh::sync::push() {
  planetarian::ssh::init

  if [ -z "$1" ]; then
    echo "require collection name"
    return 1
  fi

  collection=$1

  config="$HOME/.ssh/config.d/$collection"

  if [ -f "$config" ]; then
    vault kv put "planetarian-kv/ssh/$collection/config" file="@$config" >/dev/null &&
      echo >&2 "push config to valut: $collection"
  fi

  key_base="$HOME/.ssh/keys/$collection"
  #shellcheck disable=SC2044
  for key_file in $(find "$key_base" -type f \( -not -name '*.*' \)); do
    key_name=$(basename "$key_file")
    vault kv put "planetarian-kv/ssh/$collection/keys/$key_name" "private=@$key_file" >/dev/null &&
      echo >&2 "push keys to valut: $collection/$key_name"
  done

  # if [ ! -f "$key_file.pub" ]; then
  #   ssh-keygen -y -f keys/geektr.co/geektr >"$key_file.pub"
  # fi
}

planetarian::ssh::sync::pull() {
  if [ -z "$1" ]; then
    echo "require collection name"
    return 1
  fi

  planetarian::ssh::init

  collection=$1

  key_base="$HOME/.ssh/keys/$collection"
  config="$HOME/.ssh/config.d/$collection"

  if [ ! -d "$key_base" ]; then mkdir "$key_base"; fi

  if [ ! -f "$config" ]; then
    vault kv get -field=file "planetarian-kv/ssh/$collection/config" >"$config" &&
      chmod 0400 "$config" &&
      echo >&2 "pull config from valut: $collection" || rm "$config"
  fi

  # shellcheck disable=SC2044
  for key_name in $(vault kv list -format=json "planetarian-kv/ssh/$collection/keys/" | jq -r '.[]'); do
    key_file="$key_base/$key_name"
    [ ! -f "$key_file" ] &&
      vault kv get -field=private "planetarian-kv/ssh/$collection/keys/$key_name" >"$key_file" &&
      chmod 0400 "$key_file" &&
      echo >&2 "pull keys from valut: $collection/$key_name"
  done
}

planetarian::ssh::sync::create() {
  if [ -z "$1" ]; then
    echo "require collection name"
    return 1
  fi
  if [ -z "$2" ]; then
    echo "require key name"
    return 1
  fi

  planetarian::ssh::sync::pull "$1"

  key_file="$HOME/.ssh/keys/$1/$2"
  ssh-keygen -b 4096 -t rsa -f "$key_file" -q -N ""

  planetarian::ssh::sync::push "$1"
}

planetarian::ssh::sync::get_public_key() {
  if [ -z "$1" ]; then
    echo "require collection name"
    return 1
  fi
  if [ -z "$2" ]; then
    echo "require key name"
    return 1
  fi

  planetarian::ssh::sync::pull "$1"

  ssh-keygen -y -f "$HOME/.ssh/keys/$1/$2" | tee "$HOME/.ssh/keys/$1/$2.pub"
}

planetarian::ssh::sync::get_fingerprints() {
  if [ -z "$1" ]; then
    echo "require collection name"
    return 1
  fi
  if [ -z "$2" ]; then
    echo "require key name"
    return 1
  fi

  planetarian::ssh::sync::pull "$1"

  key_file="$HOME/.ssh/keys/$1/$2"
  ssh-keygen -E md5 -lf "$key_file"
  ssh-keygen -E sha1 -lf "$key_file"
  ssh-keygen -lf "$key_file"
}

pcmd "ssh sync" planetarian::ssh::sync
pcmd "ssh push" planetarian::ssh::sync::push
pcmd "ssh pull" planetarian::ssh::sync::pull
pcmd "ssh create" planetarian::ssh::sync::create

pcmd "ssh get pk" planetarian::ssh::sync::get_public_key
pcmd "ssh get fp" planetarian::ssh::sync::get_fingerprints
