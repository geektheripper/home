#!/usr/bin/env bash

set -e

pushd docs

yarn build

super-cp
