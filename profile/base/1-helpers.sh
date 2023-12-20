#!/usr/bin/env bash

# help other parts to modify the script environment

planetarian::safe_source() {
  if [ -f "$1" ]; then
    # shellcheck disable=SC1090
    . "$1"
  fi
}

planetarian::safe_prepend() {
  if [ -d "$1" ]; then
    if [[ $PATH == *"$1:"* ]]; then
      export PATH=${PATH//$1:/}
    fi
    if [[ $PATH == *":$1" ]]; then
      export PATH=${PATH//:$1/}
    fi
    export PATH="$1:$PATH"
  fi
}

planetarian::edit() {
  if ! [ -z "$EDITOR" ]; then
    "$EDITOR" "$@"
    return
  fi

  if [ "$TERM_PROGRAM" = "vscode" ]; then
    code "$@"
    return
  fi

  if command -v vim &>/dev/null; then
    EDITOR="vim"
  elif command -v nano &>/dev/null; then
    EDITOR="nano"
  elif command -v vi &>/dev/null; then
    EDITOR="vi"
  else
    echo "no editor found"
    return 1
  fi

  "$EDITOR" "$@"
}
