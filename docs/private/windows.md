# Win Private snippets for geektr

```powershell
irm https://planetarian.geektr.co/-/windows/pre.ps1 | iex
```

## Enable Remote

run as Administrator:

```powershell
Set-RemoteRDP
Set-RemoteSSH
```

## System Config

```powershell
Set-System -ComputerName '<name>' -Description '<name> in geektr.co'
CreateAdministrator -UserName 'geektr' -FullName 'GeekTR'
CreateAdministrator -UserName 'geektr' -FullName 'Hoshino Yumemi'
Invoke-Evil-Action
```

## Base environment config

```powershell
Install-Scoop -ScoopProxy "proxy.geektr.co:3128"
# Install-Aria2
Install-VCRedist

Clear-History-And-Exit
```

