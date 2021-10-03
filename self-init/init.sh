#!/usr/bin/env bash

sudo apt-get update && sudo apt-get install -y \
  locales crudini jq curl gpg software-properties-common \
  apt-add-repository

sudo locale-gen en_US.UTF-8

export PLANETARIAN_HOME="$HOME/.planetarian/profile"

planetarian::bashrc_block_probe() { grep "$1" <"$HOME/.bashrc"; } >/dev/null

touch "$HOME"/.bashrc

planetarian::bashrc_block_probe '# includes common profile' || {
  cat >>"$HOME"/.bashrc <<EOF

# includes common profile
if [ -f "$PLANETARIAN_HOME/planetarian.sh" ]; then
  . "$PLANETARIAN_HOME/planetarian.sh"
fi

EOF
}

if [ ! -f "$HOME"/.profile ]; then
  cat >"$HOME"/.profile <<'EOF'
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then . "$HOME/.bashrc"; fi
if [ -d "$HOME/.local/bin" ]; then PATH="$HOME/.local/bin:$PATH"; fi
EOF
fi

# shellcheck disable=SC1091
. "$PLANETARIAN_HOME/planetarian.sh"

planetarian_remote_config=$1
if [ -n "$planetarian_remote_config" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.planetarian/self-init/load-config.sh"
fi
