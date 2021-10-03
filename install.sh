#!/usr/bin/env bash

git clone git@github.com:geektheripper/planetarian.git "$HOME"/.planetarian ||
  git clone https://github.com/geektheripper/planetarian.git "$HOME"/.planetarian

#shellcheck disable=SC1091
. "$HOME/.planetarian/self-init/init.sh"
