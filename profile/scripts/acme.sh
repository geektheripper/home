#!/usr/bin/env bash
ACME_SH_PATH=$HOME/.acme.sh

planetarian::acme::install() {
  secret_dir=$(planetarian::secret::init_drive)

  acme_email=$(planetarian::config cread acme email "email for acme: ")

  mkdir -p "$secret_dir/acme/conf"
  mkdir -p "$secret_dir/acme/certs"

  if [ -d "$HOME/.acme.sh" ]; then
    cp -r "$HOME/.acme.sh" /tmp/
  else
    git clone https://github.com/acmesh-official/acme.sh.git "/tmp/.acme.sh"
  fi

  pushd "/tmp/.acme.sh" || return 1

  ./acme.sh --install \
    --config-home "$secret_dir/acme/conf" \
    --cert-home "$secret_dir/acme/certs" \
    --accountemail "$acme_email" \
    --accountkey "$secret_dir/acme/acc.key" \
    --accountconf "$secret_dir/acme/acc.conf" \
    --useragent "planetarian"

  popd || return

  rm -rf "/tmp/.acme.sh"

  planetarian::config add secret post_init "planetarian::acme::install"
}

planetarian::acme::push() {
  secret_dir=$(planetarian::secret::init_drive)

  domain="$1"
  base="$secret_dir/acme/certs/$domain"

  vault kv put "planetarian-kv/certs/$domain" \
    ca="$(cat "$base/ca.cer")" \
    cer="$(cat "$base/$domain.cer")" \
    conf="$(cat "$base/$domain.conf")" \
    csr="$(cat "$base/$domain.csr")" \
    csrConf="$(cat "$base/$domain.csr.conf")" \
    fullchain="$(cat "$base/fullchain.cer")" \
    key="$(cat "$base/$domain.key")"
}

planetarian::acme::pull() {
  secret_dir=$(planetarian::secret::init_drive)

  domain="$1"
  base="$secret_dir/acme/certs/$domain"

  [[ -f "$base/$domain.cer" ]] && return

  mkdir -p "$base"

  vault kv get --format json "planetarian-kv/certs/$domain" >"$base/acme.json"

  [[ -s "$base/acme.json" ]] || {
    echo "fail to load key"
    rm -r "$base"
    return 1
  }

  (tee \
    >(jq -r '.data.data.ca' >"$base/ca.cer") \
    >(jq -r '.data.data.cer' >"$base/$domain.cer") \
    >(jq -r '.data.data.conf' >"$base/$domain.conf") \
    >(jq -r '.data.data.csr' >"$base/$domain.csr") \
    >(jq -r '.data.data.csrConf' >"$base/$domain.csr.conf") \
    >(jq -r '.data.data.fullchain' >"$base/fullchain.cer") \
    >(jq -r '.data.data.key' >"$base/$domain.key") \
    >/dev/null) <"$base/acme.json"

  find "$base" -type f -size -2b -delete
}

planetarian::acme::apply() {
  secret_dir=$(planetarian::secret::init_drive)

  target="$1"
  shift
  domain="$1"
  shift
  base="$secret_dir/acme/certs/$domain"

  planetarian::acme::pull "$domain" || return 1

  "planetarian::acme::apply::$target" "$base" "$domain" "$@"
}

planetarian::acme::show() {
  planetarian::acme::apply console "$1"
}

planetarian::acme::remove() {
  secret_dir=$(planetarian::secret::init_drive) || return 1

  domain="$1"
  rm -r "$secret_dir/acme/certs/$domain"
}

planetarian::acme::remote_remove() {
  domain="$1"
  vault kv metadata delete "planetarian-kv/certs/$domain"
}

planetarian::acme::issue_or_renew() {
  dns_provider="$1"
  [[ "$dns_provider" == "gandi" ]] && dns_provider=gandi_livedns
  shift

  first_domain="$1"

  planetarian::acme::pull "$first_domain"

  command="acme.sh"

  if [ -f "$ACME_SH_PATH/$first_domain/$first_domain.csr.conf" ]; then
    command+=" --renew"
  else
    command+=" --issue"
  fi

  command+=" --dns dns_$dns_provider"

  for domain in "$@"; do
    command+=" -d '$domain'"
  done

  eval "$command" && planetarian::acme::push "$first_domain"
}

planetarian::command 'acme install' planetarian::acme::install
planetarian::command 'acme req' planetarian::acme::issue_or_renew
planetarian::command 'acme rm' planetarian::acme::remove
planetarian::command 'acme remote-rm' planetarian::acme::remote_remove
planetarian::command 'acme apply' planetarian::acme::apply
planetarian::command 'acme show' planetarian::acme::show
