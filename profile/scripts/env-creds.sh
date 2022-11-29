#!/usr/bin/env bash

planetarian::env::aliyun() {
  account=${1:-default}
  eval "$(planetarian::vault jq -p planetarian-kv/aliyun/"$account" -f export-map -sk "Ali_Key,Ali_Secret")"
}

planetarian::env::aws() {
  account=${1:-default}
  region=$2

  eval "$(planetarian::vault jq -p planetarian-kv/aws/"$account" -f export-map -sk "AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY,AWS_DEFAULT_REGION")"

  if [ -n "$region" ]; then export AWS_DEFAULT_REGION=$region; fi
}

planetarian::env::minio() {
  host=${1:-default}
  key=$2

  eval "$(planetarian::vault jq -p planetarian-kv/minio/"$host" -f export-map -sk "MC_HOST_$key")"
}

planetarian::env::misc() {
  env_path=${1}
  eval "$(planetarian::vault jq -p planetarian-kv/misc/"$env_path" -f export-map)"
}

planetarian::command 'env aliyun' planetarian::env::aliyun
planetarian::command 'env aws' planetarian::env::aws
planetarian::command 'env minio' planetarian::env::minio
planetarian::command 'env misc' planetarian::env::misc
