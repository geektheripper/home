#!/usr/bin/env bash

hclfmt_version=0.0.1

mkdir -p /tmp/hclfmt
cd "/tmp/hclfmt" || exit

wget https://github.com/teamon/hclfmt/releases/download/v${hclfmt_version}/hclfmt_${hclfmt_version}_Linux_x86_64.gz
gzip -d hclfmt_${hclfmt_version}_Linux_x86_64.gz
chmod +x hclfmt_${hclfmt_version}_Linux_x86_64
sudo mv hclfmt_${hclfmt_version}_Linux_x86_64 /usr/local/bin/hclfmt
