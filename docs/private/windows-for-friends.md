# Win snippets for geektr's friends

```powershell
irm https://planetarian.geektr.co/-/windows/pre.ps1 | iex
```

## System Config

```powershell
Set-System -ComputerName '<name>' -Description 'Configured by GeekTR with love.'
# CreateAdministrator -UserName '<username>' -FullName '<UserName>'
Invoke-Evil-Action
```

## Base environment config

```powershell
irm myip.ipip.net
# ssh router.home.geektr.co /ip/firewall/address-list/add address=xx.xx.xx.xx list=ProxyWhiteList
Install-Scoop -ScoopProxy "home.geektr.co:12128"
# Install-Aria2
Install-VCRedist

Clear-History-And-Exit
```

## Applications

```powershell
scoop install extras/dismplusplus
scoop install extras/googlechrome
scoop install extras/sysinternals

scoop install extras/snipaste
scoop install extras/wox

scoop install extras/potplayer
scoop install extras/imageglass
scoop install extras/obs-studio
```
