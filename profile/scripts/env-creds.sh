#!/usr/bin/env bash

planetarian::env::env_cred() {
  scope=$1
  account=$2
  key=$3

  value=$(vault kv get -field="$key" "planetarian-kv/$scope/$account")
  eval "export $key=$value"
}

planetarian::env::aliyun::init() {
  account=${1:-default}

  planetarian::env::env_cred aliyun "$account" Ali_Key
  planetarian::env::env_cred aliyun "$account" Ali_Secret
}

planetarian::env::aws::init() {
  account=${1:-default}
  region=$2

  planetarian::env::env_cred aws "$account" AWS_ACCESS_KEY_ID
  planetarian::env::env_cred aws "$account" AWS_SECRET_ACCESS_KEY
  if [ -z "$region" ]; then
    planetarian::env::env_cred aws "$account" AWS_DEFAULT_REGION
  else
    export AWS_DEFAULT_REGION=$region
  fi
}

pcmd 'env aliyun' planetarian::env::aliyun::init
pcmd 'env aws' planetarian::env::aws::init
