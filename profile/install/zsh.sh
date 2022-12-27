#!/usr/bin/env bash

set -e

sudo apt-get install -y zsh

mkdir -p "$HOME/.zsh"

if [ -d "$HOME/.oh-my-zsh" ]; then
  git -C "$HOME/.oh-my-zsh" pull
else
  git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

if [ -d "$HOME/.zsh/pure" ]; then
  git -C "$HOME/.zsh/pure" pull
else
  git clone --depth 1 https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
fi

sudo usermod --shell /usr/bin/zsh "$(whoami)"

if [ ! -f "$HOME/.zshrc" ]; then

  cat >"$HOME/.zshrc" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true
plugins=(git docker python tmux npm yarn)

if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi

fpath+="$HOME/.zsh/pure"

autoload -U promptinit
promptinit
prompt pure

EOF

  planetarian::toolbox text-block -f "$HOME/.zshrc" -key "planetarian" write <<'EOF'
if [ -f "$PLANETARIAN_HOME/planetarian.sh" ]; then
  . "$PLANETARIAN_HOME/planetarian.sh"
fi
EOF

fi
