#!/usr/bin/env bash

planetarian::install::utils::cd-tempdir
planetarian::install::utils::require-proxy

wget https://dl.min.io/client/mc/release/linux-amd64/mc

planetarian::install::utils::place-binary ./mc mc
