#!/usr/bin/env bash

sudo apt-get update

# base
sudo apt-get install -y \
  software-properties-common openssh-server openssh-client

# editor
sudo apt-get install -y \
  vim nano

# terminal
sudo apt-get install -y \
  screen tmux htop tree

# compress
sudo apt-get install -y \
  bzip2 zip unzip p7zip p7zip-full

# network about
sudo apt-get install -y \
  mtr curl wget axel dnsutils net-tools rsync

# develop about
sudo apt-get install -y \
  git git-lfs make

# hardware utils
sudo apt-get install -y \
  ipmitool

# meida
sudo apt-get install -y \
  mediainfo ffmpeg pngquant youtube-dl

# thrid party
sudo apt-get install -y \
  restic
