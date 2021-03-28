#!/usr/bin/env bash
planetarian::safe_prepend "$(which yarn &>/dev/null && yarn global bin 2>/dev/null)"
planetarian::safe_prepend "$(which npm &>/dev/null && npm bin -g 2>/dev/null)"

planetarian::node::prepare() {
  which gpg &>/dev/null || sudo apt-get install -y gpg
}

planetarian::node::gpg_import() {
  key=$1

  if [[ -z "$key" ]]; then
    echo >&2 "no keys specified"
    return 1
  fi

  if [[ ",$(planetarian::config get node gpg_keys)," = *",$key,"* ]]; then
    echo >&2 "$key already imported, skip"
    return 0
  fi

  gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$key" ||
    gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "$key" ||
    gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "$key" || {
    echo >&2 "import key failed: $key"
    return 1
  }

  echo >&2 "import key: $key"
  planetarian::config add node gpg_keys "$key"
}

planetarian::node::latest_node() {
  curl -s https://nodejs.org/en/download/ | grep 'Latest LTS Version:' | grep -Pom 1 "(\d+\.)+\d+" | head -n 1
}

planetarian::node::lstest_yarn() {
  curl -s https://classic.yarnpkg.com/en/docs/install | grep 'Classic Stable' | grep -Pom 1 "(\d+\.)+\d+"
}

planetarian::node::install_node() {
  NODE_VERSION=${1=$(planetarian::node::latest_node)}

  ARCH=
  dpkgArch="$(dpkg --print-architecture)"

  case "${dpkgArch##*-}" in
  amd64) ARCH='x64' ;;
  ppc64el) ARCH='ppc64le' ;;
  s390x) ARCH='s390x' ;;
  arm64) ARCH='arm64' ;;
  armhf) ARCH='armv7l' ;;
  i386) ARCH='x86' ;;
  *)
    echo "unsupported architecture"
    return 1
    ;;
  esac
  # gpg keys listed at https://github.com/nodejs/node#release-keys

  for key in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
    B9E2F5981AA6E0CD28160D9FF13993A75599653C; do
    planetarian::node::gpg_import "$key"
  done

  pushd /tmp || return 1
  curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz"
  curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc"
  gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc
  grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c -
  sudo tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner
  rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt
  popd || return 1

  sudo ln -sf /usr/local/bin/node /usr/local/bin/nodejs
  # smoke tests
  node --version
  npm --version
}

planetarian::node::install_yarn() {
  YARN_VERSION=${1=$(planetarian::node::lstest_yarn)}

  planetarian::node::gpg_import 6A010C5166006599AA17F08146C2130DFD2497F5

  pushd /tmp || return 1
  curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz"
  curl -fsSLO --compressed "https://yarnpkg.com/downloads/$YARN_VERSION/yarn-v$YARN_VERSION.tar.gz.asc"
  gpg --batch --verify "yarn-v$YARN_VERSION.tar.gz.asc" "yarn-v$YARN_VERSION.tar.gz"
  mkdir -p /opt
  sudo tar -xzf "yarn-v$YARN_VERSION.tar.gz" -C /opt/
  sudo ln -sf "/opt/yarn-v$YARN_VERSION/bin/yarn" /usr/local/bin/yarn
  sudo ln -sf "/opt/yarn-v$YARN_VERSION/bin/yarnpkg" /usr/local/bin/yarnpkg
  rm "yarn-v$YARN_VERSION.tar.gz.asc" "yarn-v$YARN_VERSION.tar.gz"
  popd || return 1

  # smoke test
  yarn --version
}

planetarian::node::config_node() {
  mkdir -p "$HOME/.node/npm/bin"
  mkdir -p "$HOME/.node/npm-cache"
  mkdir -p "$HOME/.node/yarn/bin"
  mkdir -p "$HOME/.node/yarn-cache"
  mkdir -p "$HOME/.node/yarn-global"
  npm config set prefix "$HOME/.node/npm"
  npm config set cache "$HOME/.node/npm-cache"
}

planetarian::node::config_yarn() {
  yarn config set prefix "$HOME/.node/yarn"
  yarn config set global-folder "$HOME/.node/yarn-global"
  yarn config set cache-folder "$HOME/.node/yarn-cache"
}

planetarian::node::init() {
  planetarian::node::install_node
  planetarian::node::install_yarn
  hash -r
  planetarian::node::config_node
  planetarian::node::config_yarn
}

pcmd 'node install node' planetarian::node::install_node
pcmd 'node install yarn' planetarian::node::install_yarn
pcmd 'node init' planetarian::node::init
