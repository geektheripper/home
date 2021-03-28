#!/usr/bin/env bash

settings_path="$HOME/.vscode-server/data/Machine/settings.json"

if [ -d ~/.vscode-server ]; then

  if [ ! -f "$settings_path" ]; then
    echo '{}' > "$settings_path"
  fi
declare -A map

  map=(
    ["terminal.integrated.shell.linux"]="zsh"
  )

  for key in "${!map[@]}"; do
    cat <<< $(jq -r '."'"$key"'" = "'"${map[$key]}"'"' "$settings_path") > $settings_path
  done
fi
