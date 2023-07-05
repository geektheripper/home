# Init RouterOS

## Add user

::: code-group

```shell [geektr]
server_addr=

user=geektr
group=admin
pubkey="$(i ssh get pk geektr.co $user) $user@geektr.co"
filename=keys/$user.pub.txt
read passwd
```

```shell [yumemi]
server_addr=

user=yumemi
group=admin
pubkey="$(i ssh get pk geektr.co $user) $user@geektr.co"
filename=keys/$user.pub.txt
read passwd
```

```shell [forward]
server_addr=

user=forward
group=forward
pubkey="$(i ssh get pk geektr.co $user) $user@geektr.co"
filename=keys/$user.pub.txt
passwd=$(i toolbox rnd)
```

:::

```shell
ssh "admin@$server_addr" <<EOF
/user add name="$user" password="$passwd" group="$group" disabled=yes
/file print file="$filename" where name=""
:delay 1
/file set "$filename" contents="$pubkey"
/user ssh-keys import user="$user" public-key-file="$filename"
/file remove "$filename"
/user set "$user" disabled=no
EOF
```
