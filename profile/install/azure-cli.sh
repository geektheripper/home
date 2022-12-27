#!/usr/bin/env bash

# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt

. "$HOME/.planetarian/profile/planetarian-install.sh"

planetarian::install::utils::apt::ensure \
  ca-certificates curl apt-transport-https lsb-release

planetarian::install::utils::apt::import-key \
  microsoft https://packages.microsoft.com/keys/microsoft.asc

planetarian::install::utils::apt::add-repo \
  azure-cli "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main"

sudo apt-get update
sudo apt-get install azure-cli
