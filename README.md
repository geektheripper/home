# Planetarian

GeekTR's linux home directory.

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

## Init

`i init <item>`

| key             | description                          |
| --------------- | ------------------------------------ |
| `git`           | set git user email and defaultBranch |
| `vscode-remote` | set zsh as default shell             |
| `zsh`           | install oh-my-zsh and pure theme     |
| `shellcheck`    | install shellcheck                   |
