#!/usr/bin/env bash

apt-get update && apt-get install -y sudo curl git

gen_passwd() {
  (tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1) </dev/urandom
}

init_user() {
  USER_NAME=$1
  PUB_KEY=$2

  HOME_DIR=/home/$USER_NAME
  PASSWD="$(gen_passwd)"

  mkdir -p "$HOME_DIR/.ssh"

  id -u "$USER_NAME" || {
    useradd --home-dir "$HOME_DIR" -s /bin/bash "$USER_NAME"
    echo "$USER_NAME:$PASSWD" | chpasswd
    chown -R "$USER_NAME":"$USER_NAME" "$HOME_DIR"
  }

  mkdir -p "$HOME_DIR/.ssh"
  echo "$PUB_KEY" >"$HOME_DIR/.ssh/authorized_keys"

  chown -R "$USER_NAME:$USER_NAME" "$HOME_DIR/.ssh"
  chmod -R go-rwsx "$HOME_DIR/.ssh"

  echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >"/etc/sudoers.d/99_$USER_NAME"
  chmod 440 "/etc/sudoers.d/99_$USER_NAME"
}

init_user geektr 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCc72lsFSvgEyprw4ig/ikiREXtcIqRgM42KK92DNQiJ1JjC3amRbQER57ww7V3ygPJ7UPqg6VjnHrKpfumbfCaC33uBI5DEaJRERmKXqtRR6KpQ0tDz5S5H9wAus3xhT3s73hY9JVUnKADpd3PKT/JAiTUEChaMkesYr6r4tmh5ChEYG8sCCok3xXdUIRGYx4Alg2LkQ3wh8Z2tp+r2MDKxLLWblcXTPPl4iOekKyPjpqwJr5e8U6/WOxcMFvZaO0BEM8WcGLXNrSExpe1J0H8lLkhfoXofqv+UvT7RBx9neCfnlBpTGInY7aM5WmQJl68jyOlO85A7LLr2KL9SJ/iEgLYu/4Aq7sumyPjJ8yJ1j10ZjrhfmJtAGolON0tyoTZOsbJl1VDVyki8TEgKSji40jrgDvxHEUBXywKclZulYfC5EkItdExBU+YylXJGweFKKSbnhV9k0dUNjnQW6HSeldSRtS4l0J25f9gqNr5cssyTf6SH0DF8z5YleMK2u2oNzit856Bs2CcyYpTRQEel/cisgPpqSU0TVWdxyEKtXWqyIup8BHvWNq9w0S0PQl80I3Cefc7belREsdklHXIxpcWnsfZBmy2HyhE3Wj3PxIdUmqqpwwCUETL+i7oEkbmMnwVL7xybvljMqL7TDpMkvPZjelp/LUfZrjvrXfvow== geektr@geektr.co'
init_user yumemi 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+yOZhuXLPLSHvegXQSfrRSBdKMW5TJ/gi0j2PQApOe8rqb/3Eh6PjAr1muAHNS6hrZCjtL2ok46fMb5EXiuegxe5VrtCNw/r2f8pn93J2iY5B+h/rbYcbNhifWGBE75VnkPEFJskkcO0BgwjyYs8sGvC44W1KYriKbmN263Fr8w8es0Bb3TVthG5Sf1Xy0YDWD1HhHXgY68qSv27Ldvg2+OP2Fe7lZ/7VIfiiR61VDsqNQEqjnjBlEsIZN2wphm1ZCtV0Ko5ZxTp3xlX+E1bbiIPa6wOpabgLFAZj2umm05xWdwvt5D5C8aCpV7kEJmaSIomRwDu1zzBWYLwNUVw5 yumemi@geektr.co'
