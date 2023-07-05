planetarian::terraform::secret::ensure() {
  sudo $PLANETARIAN_TOOLBOX veracrypt ensure --namespace "$1" --name "secret" --size 64MiB --mount-point "$(planetarian::toolbox proj-dir)/.secret"
}

planetarian::terraform::secret::backup() {
  planetarian::toolbox veracrypt backup --namespace "$1" --name "secret"
}

planetarian::terraform::secret::umount() {
  planetarian::toolbox veracrypt umount --namespace "$1" --name "secret"
}

planetarian::command 'tf secret ensure' planetarian::terraform::secret::ensure
planetarian::command 'tf secret backup' planetarian::terraform::secret::backup
planetarian::command 'tf secret umount' planetarian::terraform::secret::umount
