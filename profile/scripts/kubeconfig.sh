# KUBECONFIG
planetarian::kubeconfig::init() {
  secret_dir=$(planetarian::secret::init_drive)
  kubeconfig_dir="$secret_dir/kubeconfig"

  mkdir -p "$kubeconfig_dir"

  echo "$kubeconfig_dir"
}

planetarian::kubeconfig::load() {
    cluster=$1
    namespace=${2:-default}
    
    if [ -z "$cluster" ]; then
      echo "require cluster name"
      return 1
    fi

    kubeconfig_dir="$(planetarian::kubeconfig::init)"
    kubeconfig_file="$kubeconfig_dir/$cluster.$namespace.yaml"

    eval "$(planetarian::vault jq -p planetarian-kv/k8s/"$cluster"/"$namespace" -sk kubeconfig -f assign-map)"
    echo "$kubeconfig">"$kubeconfig_file"
    chmod 600 "$kubeconfig_file"
    unset kubeconfig

    export KUBECONFIG=$kubeconfig_file
}

planetarian::command 'kubecfg load' planetarian::kubeconfig::load
