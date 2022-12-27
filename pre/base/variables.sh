#!/usr/bin/env bash

_boot_id=$(cat /proc/sys/kernel/random/boot_id)
_res_url_prefix=https://planetarian.geektr.co/-/linux
_pre_tmp=/tmp/planetarian-$_boot_id
_pre_bin=$_pre_tmp/bin
