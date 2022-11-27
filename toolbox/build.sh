#!/usr/bin/env bash

set -e

pushd "$PLANETARIAN_ROOT/toolbox/" || exit 0

go build -o "$PLANETARIAN_ROOT/bin/toolbox"
