#!/usr/bin/env bash

planetarian::init() {
  bash -i "$PLANETARIAN_HOME/init/$1.sh"
}

planetarian::command init planetarian::init
