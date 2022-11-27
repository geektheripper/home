#!/usr/bin/env bash
PLANETARIAN_ROOT="$HOME/.planetarian"
PLANETARIAN_HOME="$HOME/.planetarian/profile"
# shellcheck disable=SC2034
PLANETARIAN_BIN="$HOME/.planetarian/bin"
# shellcheck disable=SC2034
PLANETARIAN_CONFIG="$HOME/.planetarian.ini"

export LC_ALL=en_US.UTF-8

planetarian::profile::reload() {
  for file in "$PLANETARIAN_HOME/base"/*.sh; do
    # shellcheck disable=SC1090
    if [ -f "$file" ]; then . "$file"; fi
  done

  for file in "$PLANETARIAN_HOME/scripts"/*.sh; do
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
