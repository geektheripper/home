# Getting Started

Load helper before proceeding with the following operations

```bash
source <(curl -s https://planetarian.geektr.co/-/linux/pre.sh)
```

## Pre Install

Then you can:

1. Create users

```bash
init-user <username> <public-key> <sudo>
```

2. Set proxy for apt

```bash
set-apt-proxy http://example.com:3128
```

3. Set proxy for current env

```bash
set-proxy http://example.com:3128
```

4. Auto config

Provide the required parameters for initialization with a json on a url: [Auto Config](./auto-config).

```bash
auto-init-system <url>
```

## Install

```bash
install-planetarian
```

## Post Install

use a remote json to config planetarian: [Auto Config](./auto-config).

```bash
auto-init-planetarian <url> [functions]
auto-init-planetarian <url> all
```
