#!/usr/bin/env bash

install_ms_package_signing_key() {
  wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O /tmp/ms-prod.deb &&
    sudo dpkg -i /tmp/ms-prod.deb &&
    rm /tmp/ms-prod.deb
}

install_dotnet_sdk() {
  install_ms_package_signing_key || return 1

  sudo apt-get update
  sudo apt-get install -y apt-transport-https &&
    sudo apt-get update &&
    sudo apt-get install -y dotnet-sdk-5.0
}

planetarian::proxy::unset
install_dotnet_sdk
