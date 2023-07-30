#!/usr/bin/env bash

export PLANETARIAN_ROOT="$HOME/.planetarian"
export PLANETARIAN_HOME="$HOME/.planetarian/profile"
export PLANETARIAN_BIN="$HOME/.planetarian/bin"
export PLANETARIAN_CONFIG="$HOME/.planetarian.ini"

install-planetarian() {
  require::non-root || return $?
  require::toolbox || return $?

  if [ ! -d "$PLANETARIAN_ROOT" ]; then
    git clone https://github.com/geektheripper/planetarian.git "$PLANETARIAN_ROOT"
  fi

  # Locale
  sudo locale-gen en_US.UTF-8

  # Download bins
  mkdir -p "$PLANETARIAN_BIN"
  # download "$PLANETARIAN_BIN/toolbox" "$_res_url_prefix/bin/toolbox"
  cp "$_pre_bin/toolbox" "$PLANETARIAN_BIN/toolbox"
  chmod +x "$PLANETARIAN_BIN/toolbox"

  if [ ! -f "$HOME"/.profile ]; then
    touch "$HOME"/.profile
    toolbox text-block -k "load bashrc" -f "$HOME"/.profile write <<'EOF'
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then . "$HOME/.bashrc"; fi
EOF
  fi

  toolbox text-block -k "planetarian" -f "$HOME"/.profile write <<EOF
if [ -f "$PLANETARIAN_HOME/planetarian.sh" ]; then
  . "$PLANETARIAN_HOME/planetarian.sh"
fi

if [ -d "\$HOME/.local/bin" ]; then
  PATH="\$HOME/.local/bin:\$PATH"
fi
EOF

  if [ -f "$HOME"/.zshrc ]; then
    toolbox text-block -k "load profile" -f "$HOME"/.zshrc write <<'EOF'
if [ -f "$HOME/.profile" ]; then . "$HOME/.profile"; fi
EOF
  fi

  touch "$HOME/.planetarian.ini"

  echo >&2 "It is recommended to restart a new shell session to use planetarian."
  echo >&2 "If you want to start at the current shell, use 'load-planetarian'."
}

# shellcheck disable=SC1091
load-planetarian() { . "$PLANETARIAN_HOME/planetarian.sh"; }
