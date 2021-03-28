planetarian::gpg_key::import() {
  key=$1

  if [[ -z "$key" ]]; then
    >&2 echo "no keys specified"
    return 1
  fi

  if [[ ",$(planetarian::config get gpg_key imported)," = *",$key,"* ]]; then
    >&2 echo "$key already imported, skip"
    return 0
  fi

  gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ||
  gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" ||
  gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" || {
    >&2 echo "import key failed: $key"
    return 1
  }

  >&2 echo "import key: $key"
  planetarian::config add gpg_key imported "$key"
}
