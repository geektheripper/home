#!/usr/bin/env bash

# i env aliyun

set -e

pushd "$HOME/.planetarian/toolbox/" || exit 0

go build -ldflags="-s -w" -o "$HOME/.planetarian/bin/toolbox"
