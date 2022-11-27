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
