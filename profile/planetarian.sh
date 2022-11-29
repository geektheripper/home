#!/usr/bin/env bash
# shellcheck disable=SC2034,SC1090

# determine private dir
if [ -z "$PLANETARIAN_PRIVATE" ]; then
  if which systemd &>/dev/null; then
    PLANETARIAN_PRIVATE="/run/user/$UID/planetarian"
  else
    PLANETARIAN_PRIVATE="/tmp/planetarian-$UID"
  fi
fi

# ensure private dir
if [ ! -d $PLANETARIAN_PRIVATE ]; then
  (umask 77 && mkdir $PLANETARIAN_PRIVATE)
fi

# determine install mode
PLANETARIAN_ROOT=$HOME/.planetarian
if [ -f $PLANETARIAN_PRIVATE/.use-tmp-install ]; then
  PLANETARIAN_ROOT=/tmp/planetarian-$UID
fi

PLANETARIAN_HOME=$PLANETARIAN_ROOT/profile
PLANETARIAN_BIN="$PLANETARIAN_ROOT/bin"
PLANETARIAN_CONFIG="$HOME/.planetarian.ini"

planetarian::profile::reload() {
  for file in "$PLANETARIAN_HOME/base"/*.sh; do
    if [ -f "$file" ]; then . "$file"; fi
  done

  for file in "$PLANETARIAN_HOME/scripts"/*.sh; do
    planetarian::safe_source "$file"
  done

  if find "$PLANETARIAN_HOME/local" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
    for file in "$PLANETARIAN_HOME/local"/*; do
      planetarian::safe_source "$file"
    done
  fi

  planetarian::command reload planetarian::profile::reload
  planetarian::command update planetarian::update
}

planetarian::profile::reload

planetarian::update() {
  git -C "$PLANETARIAN_ROOT" pull && planetarian::profile::reload
}
