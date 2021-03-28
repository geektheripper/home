#!/usr/bin/env bash

mkdir -p /tmp/shellcheck
wget -P /tmp/shellcheck/ "https://github.com/koalaman/shellcheck/releases/download/latest/shellcheck-latest.linux.x86_64.tar.xz"
tar xvf /tmp/shellcheck/shellcheck-latest.linux.x86_64.tar.xz -C /tmp/shellcheck
sudo cp /tmp/shellcheck/shellcheck-latest/shellcheck /usr/bin/shellcheck
rm -r /tmp/shellcheck
hash -r