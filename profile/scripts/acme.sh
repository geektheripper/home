#!/usr/bin/env bash
ACME_SH_PATH=$HOME/.acme.sh

planetarian::acme::install() {
  secret_dir=$(planetarian::secret::init_drive)

  echo -n "email for acme: "
  read -r acme_email

  mkdir -p "$secret_dir/acme/conf"
  mkdir -p "$secret_dir/acme/certs"

  git clone https://github.com/acmesh-official/acme.sh.git "/tmp/.acme.sh"
  pushd "/tmp/.acme.sh" || return
  ./acme.sh --install \
    --config-home "$secret_dir/acme/conf" \
    --cert-home "$secret_dir/acme/certs" \
    --accountemail "$acme_email" \
    --accountkey "$secret_dir/acme/acc.key" \
    --accountconf "$secret_dir/acme/acc.conf" \
    --useragent "planetarian"
  popd || return

  rm -rf "/tmp/.acme.sh"
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

  mkdir -p "$base"

  vault kv get --format json "planetarian-kv/certs/$domain" >"$base/acme.json"
  [[ -s "$base/acme.json" ]] || {
    rm "$base/acme.json"
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

planetarian::acme::issue_or_renew() {
  dns_provider="$1"
  [[ "$dns_provider" == "gandi" ]] && dns_provider=gandi_livedns
  shift

  first_domain="$1"

  planetarian::acme::pull "$first_domain" 2>/dev/null

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

pcmd 'acme install' planetarian::acme::install
pcmd 'acme req' planetarian::acme::issue_or_renew
pcmd 'acme rm' planetarian::acme::remove
pcmd 'acme apply' planetarian::acme::apply
pcmd 'acme show' planetarian::acme::show
