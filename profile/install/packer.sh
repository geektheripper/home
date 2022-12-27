#!/usr/bin/env bash

. "$HOME/.planetarian/profile/planetarian-install.sh"

planetarian::install::utils::apt::import-key \
  hashicorp https://apt.releases.hashicorp.com/gpg

planetarian::install::utils::apt::add-repo \
  hashicorp "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

sudo apt-get update
sudo apt-get install -y packer
