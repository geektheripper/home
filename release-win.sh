#!/usr/bin/env bash

set -e

rm -rf windows-files
mkdir -p windows-files
trap "rm -r windows-files" EXIT

# Build pre.ps1
append-pre() {
  cat pre/windows/$1 >>windows-files/pre.ps1
}

append-pre "base/*"
append-pre "cmd/*"

# Copy files
cp -r pre/windows/ext windows-files/
cp -r pre/windows/evil windows-files/
# cp -r bin windows-files/

super-cp -e windows
