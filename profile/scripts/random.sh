#!/usr/bin/env bash

planetarian::random::string() {
  (tr -dc "$1" | fold -w "$2" | head -n 1) </dev/urandom
}

planetarian::random::alpha() {
  planetarian::random::string 'a-zA-Z' "${1:-16}"
}

planetarian::random::alpha_number() {
  planetarian::random::string 'a-zA-Z0-9' "${1:-16}"
}

planetarian::random::secure_password() {
  planetarian::random::string 'a-zA-Z0-9~!@#%^&()_+-={}[];,.' "${1:-16}"
}

pcmd "rnd string" planetarian::random::string
pcmd "rnd alpha" planetarian::random::alpha
pcmd "rnd alnum" planetarian::random::alpha_number
pcmd "rnd passwd" planetarian::random::alpha_number
pcmd "rnd sqpass" planetarian::random::secure_password
