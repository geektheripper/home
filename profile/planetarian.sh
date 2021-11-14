#!/usr/bin/env bash
export PLANETARIAN_ROOT="$HOME/.planetarian"
export PLANETARIAN_HOME="$HOME/.planetarian/profile"
export PLANETARIAN_CONFIG="$HOME/.planetarian.ini"

export LC_ALL=en_US.UTF-8

planetarian::profile::reload() {
  for script_name in \
    "env" "helpers" "command" "config-mgmt"; do
    # shellcheck disable=SC1090
    . "$PLANETARIAN_HOME/base/$script_name.sh"
  done

  for file in "$PLANETARIAN_HOME/scripts"/*; do
    # shellcheck disable=SC1090
    if [ -f "$file" ]; then . "$file"; fi
  done

  if find "$PLANETARIAN_HOME/local" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
    for file in "$PLANETARIAN_HOME/local"/*; do
      # shellcheck disable=SC1090
      if [ -f "$file" ]; then . "$file"; fi
    done
  fi

  planetarian::command reload planetarian::profile::reload
  planetarian::command update planetarian::update
}

planetarian::profile::reload

planetarian::update() {
  git -C "$PLANETARIAN_ROOT" pull && planetarian::profile::reload
}
