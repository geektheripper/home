planetarian::proxy::get-proxy() {
  if [ ! -z "$1" ]; then
    echo $1
    return 0
  fi

  if [ ! -z "$PLTR_PROXY" ]; then
    echo "$PLTR_PROXY"
    return 0
  fi

  planetarian::config get proxy url 2> /dev/null
}

planetarian::proxy::set-default() {
  planetarian::config set proxy url "$1"
}

planetarian::proxy::set() {
  proxy="$(planetarian::proxy::get-proxy $1)"
  echo "set proxy to: $proxy"
  export all_proxy="$proxy"
  export http_proxy="$proxy"
  export https_proxy="$proxy"
  export ftp_proxy="$proxy"
  export ALL_PROXY="$proxy"
  export HTTP_PROXY="$proxy"
  export HTTPS_PROXY="$proxy"
  export FTP_PROXY="$proxy"
}

planetarian::proxy::unset() {
  unset all_proxy
  unset http_proxy
  unset https_proxy
  unset ftp_proxy
  unset ALL_PROXY
  unset HTTP_PROXY
  unset HTTPS_PROXY
  unset FTP_PROXY
}

planetarian::proxy::autoload() {
  planetarian::feature_switch proxy autoload $1
}

planetarian::feature_switch proxy autoload && planetarian::proxy::set

planetarian::proxy() {
  action=$1
  shift
  planetarian::proxy::$action $@
}

pltr_proxy=planetarian::proxy

# pltr proxy set http://host:port
# pltr proxy set-default http://host:port
# pltr proxy unset
# pltr proxy autoload on
# pltr proxy autoload off
