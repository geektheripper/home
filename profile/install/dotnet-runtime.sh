#!/usr/bin/env bash

set -e

planetarian::install::utils::cd-tempdir

wget https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb

planetarian::install::utils::apt::ensure apt-transport-https

sudo apt-get update
sudo apt-get install -y aspnetcore-runtime-5.0
