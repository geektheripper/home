#!/usr/bin/env bash

planetarian::safe_prepend /usr/local/go/bin

if [[ -d /usr/local/go/src ]]; then
  export GOPATH=/usr/local/go/src
fi
