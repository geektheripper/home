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

planetarian::command "rnd string" planetarian::random::string
planetarian::command "rnd alpha" planetarian::random::alpha
planetarian::command "rnd alnum" planetarian::random::alpha_number
planetarian::command "rnd passwd" planetarian::random::alpha_number
planetarian::command "rnd sqpass" planetarian::random::secure_password
