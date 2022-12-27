#!/usr/bin/env bash

set-proxy() {
  export all_proxy="$1"
  export http_proxy="$1"
  export https_proxy="$1"
  export ftp_proxy="$1"
  export ALL_PROXY="$1"
  export HTTP_PROXY="$1"
  export HTTPS_PROXY="$1"
  export FTP_PROXY="$1"
}
