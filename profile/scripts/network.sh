#!/usr/bin/env bash

planetarian::ipv6::on() {
  sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
  sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0
}

planetarian::ipv6::off() {
  sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
  sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
}

planetarian::command "ipv6 on" planetarian::ipv6::on
planetarian::command "ipv6 off" planetarian::ipv6::off

planetarian::net::connect-google() {
  ping -c1 -W1 www.google.com >/dev/null
}

planetarian::net::in-gfw() {
  if planetarian::config net:in_gfw switch test yes; then
    return 0
  elif planetarian::config net:in_gfw switch test no; then
    return 1
  elif planetarian::net::connect-google; then
    planetarian::config net:in_gfw switch turn no
    return 1
  else
    planetarian::config net:in_gfw switch turn yes
    return 0
  fi
}
