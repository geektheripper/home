#!/usr/bin/env bash

sudo apt-get update && sudo apt-get install -y \
  locales crudini jq curl gpg software-properties-common

sudo locale-gen en_US.UTF-8

export PLANETARIAN_HOME="$HOME/.planetarian/profile"

planetarian::bashrc_block_probe() { grep "$1" <"$HOME/.bashrc"; } >/dev/null

planetarian::bashrc_block_probe '# planetarian home' || {
  cat >>"$HOME"/.bashrc <<EOF

# includes common profile
if [ -f "$PLANETARIAN_HOME/planetarian.sh" ]; then
  . "$PLANETARIAN_HOME/planetarian.sh"
fi

EOF
}

# shellcheck disable=SC1090
. "$PLANETARIAN_HOME/planetarian.sh"
