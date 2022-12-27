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

planetarian::install::utils::apt::ensure() {
  for pkg in "$@"; do
    dpkg-query --show --showformat='${db:Status-Status}\n' "$pkg" &>/dev/null ||
      sudo apt-get install -y "$pkg"
  done
}

planetarian::install::utils::apt::import-key() {
  planetarian::install::utils::apt::ensure gnupg2 || exit 1
  curl -sL "$2" | gpg --dearmor |
    sudo tee "/etc/apt/trusted.gpg.d/$1.gpg" >/dev/null
}

planetarian::install::utils::apt::add-repo() {
  local apt_src_file="/etc/apt/sources.list.d/$1.list"
  echo "$2" | sudo tee -a "$apt_src_file" >/dev/null
  uniq "$apt_src_file" | sudo tee "$apt_src_file" >/dev/null
}

planetarian::install::utils::require-proxy() {
  if planetarian::net::in-gfw; then
    planetarian::proxy::set
  fi
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

planetarian::install::utils::github-latest-ver() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}

planetarian::install::utils::place-binary() {
  if [ "$GLOBAL_INSTALL" = "true" ]; then
    sudo mv "$1" "/usr/local/bin/$2"
    sudo chown root:root "/usr/local/bin/$2"
    sudo chmod +x "/usr/local/bin/$2"
  else
    mv "$1" "$HOME/.local/bin/$2"
    sudo chmod +x "$HOME/.local/bin/$2"
  fi
}
