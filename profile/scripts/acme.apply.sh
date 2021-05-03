#!/usr/bin/env bash
planetarian::acme::apply::console() {
  base=$1
  domain=$2

  echo "fullchain:"
  echo
  cat "$base/fullchain.cer"
  echo
  echo "key:"
  echo
  cat "$base/$domain.key"
}

# scp "$HOME/.ssh/keys/geektr.co/root.pub" root@ryou.geektr.co:/etc/ssh/keys-root/authorized_keys
planetarian::acme::apply::esxi() {
  base=$1
  domain=$2
  host=$3

  key="$HOME/.ssh/keys/geektr.co/root"

  scp -i "$key" "$base/fullchain.cer" root@"$host":/etc/vmware/ssl/rui.crt
  scp -i "$key" "$base/$domain.key" root@"$host":/etc/vmware/ssl/rui.key
  ssh -i "$key" root@"$host" "/etc/init.d/hostd restart && /etc/init.d/vpxa restart"
}
