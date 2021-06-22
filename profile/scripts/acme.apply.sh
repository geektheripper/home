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

# i acme apply scp geektr.co yumemi@portainer.geektr.co /srv/portainer key.pem cert.pem
planetarian::acme::apply::scp() {
  base=$1
  domain=$2
  connect_str=$3
  target_dir=$4
  priv_key_name=$5
  pub_key_name=$6

  key="$HOME/.ssh/keys/geektr.co/root"

  scp -i "$key" "$base/fullchain.cer" "$connect_str":"$target_dir"/"$pub_key_name"
  scp -i "$key" "$base/$domain.key" "$connect_str":"$target_dir"/"$priv_key_name"
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
