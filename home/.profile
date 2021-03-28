export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'
export LC_ALL='en_US.UTF-8'
export TERM='xterm'

export PLANETARIAN_ROOT="$HOME"/.planetarian
export PLANETARIAN_HOME="$HOME"/.planetarian/home

planetarian::safe_source() {
  if [ -f "$1" ]; then
    # shellcheck disable=SC1090
    . "$1"
  fi
}

planetarian::safe_prepend() {
  if [ -d "$1" ]; then
    if [[ $PATH == *"$1:"* ]]; then
      export PATH=$(echo $PATH | sed -e "s|$1:||g")
    fi
    if [[ $PATH == *":$1" ]]; then
      export PATH=$(echo $PATH | sed -e "s|:$1$||")
    fi
    export PATH="$1:$PATH"
  fi
}

planetarian::profile::reload() {
  for file in "$PLANETARIAN_HOME"/.profile.d/*; do
    if [ -f "$file" ]; then
      planetarian::safe_source "$file"
    fi
  done
}
planetarian::profile::manual_reload() {
  planetarian::safe_source "$PLANETARIAN_HOME"/.profile
}
pltr_reload=planetarian::profile::manual_reload

planetarian::update() {
  git -C "$PLANETARIAN_ROOT" pull && planetarian::profile::manual_reload
}
pltr_update=planetarian::profile::update

planetarian::config() {
  action=$1
  shift
  crudini --$action "$PLANETARIAN_HOME"/.profile-config.ini $@
}
pltr_config=planetarian::config

planetarian::feature_switch() {
  scope=$1
  switch=$2
  value=$3
  if [ -z "$value" ]; then
    [ "on" == "$(planetarian::config get $scope $switch)" ]
  elif [ "on" == "$value" ]; then
    planetarian::config set $scope $switch on
  else
    planetarian::config del $scope $switch
  fi
} 2> /dev/null
pltr_switch=planetarian::feature_switch

planetarian::profile::reload

planetarian::init() {
  "$PLANETARIAN_ROOT"/init/$1.sh
}
pltr_init=planetarian::init

function pltr() {
  command=$(eval 'echo $pltr_'$1'')
  shift
  $command $@
}
