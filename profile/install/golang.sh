#!/usr/bin/env bash

. "$HOME/.planetarian/profile/planetarian-install.sh"

planetarian::install::utils::require-proxy
planetarian::install::utils::cd-tempdir

golang_version=1.18

go_dl_url="https://golang.org$(wget -qO- https://golang.org/dl | grep -oP '/dl\/go([0-9\.]+)\.linux-amd64\.tar\.gz' | grep "$golang_version" | head -n 1)"

wget -O go.tar.gz "$go_dl_url"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go.tar.gz

export PATH="/usr/local/go/bin:$PATH"
export GOPATH=/usr/local/go/src

planetarian::toolbox text-block -f "$HOME/.profile" -key "golang" write <<'EOF'
if [ -d /usr/local/go/bin ] ; then
    export PATH="/usr/local/go/bin:$PATH"
fi
if [ -d /usr/local/go/src ] ; then
    export $GOPATH=/usr/local/go/src
fi
EOF
