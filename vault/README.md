# Vault

planetarian use [hashicorp vault](https://www.vaultproject.io/) as backend secret storage, it expect an `kv v2` secret engine with specific path structure.

## `certs/<domain>`

store ssl certificate, reference [acme.sh](https://github.com/acmesh-official/acme.sh)

```JSON
{
  "ca": "<ca>",
  "cer": "<cer>",
  "conf": "<conf>",
  "csr": "<csr>",
  "fullchain": "<fullchain>",
  "key": "<key>"
}
```

## `gitlab/terraform`

access token for access terraform state

```json
{
  "access_token": "<access_token>",
  "username": "<username>"
}
```

## `ssh/<hostname>`

ssh keys and config for ssh access

`ssh/<hostname>/config` :

```json
{ "file": "<ssh config file content>" }
```

`ssh/<hostname>/keys/<username>` :

```json
{ "private": "<ssh private key>" }
```

## `<service-name>/<account-name>`

environments for services, account-name can be `default` as a default account-name

```json
{
  "<env_key>": "<env_value>",
  "...": "..."
}
```
