# Planetarian

planetarian's linux shell environment

## Install

```bash
# new cloud machine
curl -fsSL https://raw.githubusercontent.com/geektheripper/planetarian/master/init.sh | bash

# install planetarian
apt-get install -y curl git
curl -fsSL https://raw.githubusercontent.com/geektheripper/planetarian/master/install.sh | bash
```

## Config

```bash
i config <set|del|get|add|remove> <scope> <key> [value]
i switch <scope> <key> [on|off]
```

## Network

```bash
i ipv6 [on|off]
```

## Self Management

```bash
i reload
i upadte
```

## Proxy

```bash
i proxy set http://host:port
i proxy set-default http://host:port
i proxy unset
i proxy autoload on
i proxy autoload off
```

## NodeJS

```bash
i node init
i node install-node [version]
i node install-yarn [version]
```

## Secret

```bash
# init secret drive, install vault
# and open autoload secret switch
i secret init

# valut
i vault set-host [host]
i vault set-user [user]
i vault login
```

## SSH

```
~/.ssh/keys -> /run/planetarian/secret/ssh/keys
|-- <collection name>
|   |-- <key name>
|   `-- ...
`-- ...

~/.ssh/config.d -> /run/planetarian/secret/ssh/config.d
|-- <collection name>
`-- ...
```

```bash
# pull all keys and config from vault
i ssh sync

# push/pull a collection to vault
# includes config and keys
i ssh push <collection>
i ssh pull <collection>

# create a key and push to vault
i ssh create <collection> <key>

# print public key
i ssh get pk <collection> <key>
# print fingerprints fo a key
i ssh get fp <collection> <key>
```

## ACME

```bash
# install acme.sh
i acme install

# issue or renew a cert
i acme req <provider> <domain> [...alt domains]

# remove local cert
i acme rm <domain>

# apply cert to target
i acme apply <target> [...target options]
i acme apply console <domain>
i acme apply esxi <domain> <server>

# show cert
# alias to "i acme apply console <domain>"
i acme show <domain>
```

## Environment based credentials

```bash
i env aliyun [account]
i env aws [account] [default_region]
i env minio [server] [user_name]
```

## Init

`i init <item>`

| key             | description                                      |
| --------------- | ------------------------------------------------ |
| `git`           | set git user email and defaultBranch             |
| `vscode-remote` | set zsh as default shell                         |
| `zsh`           | install oh-my-zsh and pure theme                 |
| `shellcheck`    | install shellcheck                               |
| `docker`        | install docker, docker-compose and aliyun mirror |
| `node`          | alias to `i node init`                           |
| `daily`         | daily applications for geektr                    |
| `minio`         | install minio client                             |
