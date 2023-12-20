#!/usr/bin/env bash

. "$HOME/.planetarian/profile/planetarian-install.sh"

planetarian::install::utils::help-msg "$@" <<EOF
i install golang (default 1.19)
i install golang 1.18
EOF

planetarian::install::utils::require-proxy
planetarian::install::utils::cd-tempdir

golang_version=${1:-1.20}

go_dl_url="https://go.dev$(wget -qO- https://go.dev/dl | grep -oP '/dl\/go([0-9\.]+)\.linux-amd64\.tar\.gz' | grep "$golang_version" | head -n 1)"

wget -O go.tar.gz "$go_dl_url"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go.tar.gz

export PATH="/usr/local/go/bin:$PATH"

planetarian::toolbox text-block -f "$HOME/.profile" -key "golang" write <<EOF
if [ -d /usr/local/go/bin ] ; then
    export PATH="/usr/local/go/bin:\$PATH"
fi

if command -v go &> /dev/null ; then
    export PATH="\$(go env GOPATH)/bin:\$PATH"
fi
EOF
