# Planetarian

planetarian's linux shell environment

## Install

```bash
# apt-get install -y curl git
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
i secret init
# valut
i vault set-host [host]
i vault set-user []
i vault login <period>
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
