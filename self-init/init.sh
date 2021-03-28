#!/usr/bin/env bash

# sudo apt-get update && sudo apt-get install -y crudini

export PLANETARIAN_HOME="$HOME"/.planetarian/home

planetarian::bashrc_block_probe() {
  cat "$HOME"/.bashrc | grep "$1"
} > /dev/null

planetarian::bashrc_block_probe '# planetarian home' || {
  cat >> "$HOME"/.bashrc <<EOF
# planetarian home
if [ -f "$PLANETARIAN_HOME/.profile" ]; then
  . "$PLANETARIAN_HOME/.profile"
fi
EOF
}

. "$PLANETARIAN_HOME/.profile"
