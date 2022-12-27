#!/usr/bin/env bash

# functions
gen_passwd() { (tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1) </dev/urandom; }

json_pick() { echo "$1" | jq -r "$2"; }

fetch() {
  if command -v curl &>/dev/null; then
    curl -s "$1"
  elif command -v wget &>/dev/null; then
    wget -qO- "$1"
  else
    echo "At least one of wget and curl must be installed"
    return 1
  fi
}

download() {
  if command -v curl &>/dev/null; then
    echo curl -s -o "$1" "$2"
  elif command -v wget &>/dev/null; then
    echo wget -q -O "$1" "$2"
  else
    echo "At least one of wget and curl must be installed"
    return 1
  fi
}
