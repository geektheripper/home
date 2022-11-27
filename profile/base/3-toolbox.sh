#!/usr/bin/env bash

# integrate the toolbox

PLANETARIAN_TOOLBOX=$PLANETARIAN_BIN/toolbox
planetarian::toolbox() { $PLANETARIAN_TOOLBOX "$@"; }
planetarian::command toolbox "$PLANETARIAN_TOOLBOX"

# ini config
planetarian::config() {
  _section_key=$1
  shift
  $PLANETARIAN_TOOLBOX ini -t "$PLANETARIAN_CONFIG:$_section_key" "$@"
}
planetarian::command config planetarian::config
