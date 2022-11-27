#!/usr/bin/env bash
export RES_URL_PREFIX=https://flint.geektr.co/planetarian
export PLANETARIAN_ROOT="$HOME/.planetarian"
export PLANETARIAN_HOME="$HOME/.planetarian/profile"
export PLANETARIAN_BIN="$HOME/.planetarian/bin"
export PLANETARIAN_CONFIG="$HOME/.planetarian.ini"

# Install nessary dependencies
sudo apt-get update && sudo apt-get install -y \
  locales crudini jq curl gpg software-properties-common

# Locale
sudo locale-gen en_US.UTF-8

# Download bins
mkdir -p "$PLANETARIAN_BIN"
wget -O "$PLANETARIAN_BIN/toolbox" "$RES_URL_PREFIX/bin/toolbox"
chmod +x "$PLANETARIAN_BIN/toolbox"

# Write configs
BEDITOR="$PLANETARIAN_BIN/toolbox block-editor write -v -"

$BEDITOR -k "includes common profile" -f "$HOME"/.bashrc <<EOF
if [ -f "$PLANETARIAN_HOME/planetarian.sh" ]; then
  . "$PLANETARIAN_HOME/planetarian.sh"
fi
EOF

if [ ! -f "$HOME"/.profile ]; then
  $BEDITOR -k "planetarian initial" -f "$HOME"/.bashrc <<'EOF'
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then . "$HOME/.bashrc"; fi
EOF
fi

$BEDITOR -k "planetarian local bin" -f "$HOME"/.bashrc <<'EOF'
if [ -d "$HOME/.local/bin" ]; then PATH="$HOME/.local/bin:$PATH"; fi
EOF

# shellcheck disable=SC1091
. "$PLANETARIAN_HOME/planetarian.sh"

planetarian_remote_config=$1
if [ -n "$planetarian_remote_config" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.planetarian/self-init/load-config.sh"
fi
