planetarian::ipv6::on() {
  sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
  sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0
}

planetarian::ipv6::off() {
  sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
  sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
}

planetarian::ipv6() {
  action=$1
  shift
  planetarian::ipv6::$action $@
}

pltr_ipv6=planetarian::ipv6
