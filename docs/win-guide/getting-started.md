# Getting Started

Load helper before proceeding with the following operations

```powershell
irm https://planetarian.geektr.co/-/windows/pre.ps1 | iex
```

## Remote

enable remote services and set firewall rules

```powershell
Set-RemoteRDP
Set-RemoteSSH
Set-RemotePS

# enable all above
Set-Remote
```

## System Config

hostname, workgroup and description

```powershell
Set-System -WorkGroupName 'WORKGROUP' -ComputerName 'DESKTOP-XXXXXXX' -Description 'DESKTOP-XXXXXXX in geektr cloud'

# set by interactive shell
Set-System-Manual

CreateAdministrator -UserName 'geektr' -FullName 'GeekTR'
```

## Invoke Evil Action

```powershell
Invoke-Evil-Action
```

## Install Scoop

```powershell
Install-Scoop
Install-Scoop -ScoopProxy "proxy.geektr.co:3128"
Install-Aria2
Install-VCRedist
```

## Utils

```powershell
Clear-History-And-Exit
```

## Applications

Google Chrome

```powershell
InstallGoogleChrome

NewChromeProfile -ProfileName <string> \
  [-DisplayName <string>] \
  [-ShortcutDir <string>] \
  [-ThemeColor <string>] \
  [-Avatar <string>] \

NewChromeProfile -ProfileName 'GeekTR'
NewChromeProfile -ProfileName 'Miku' -DisplayName '❤️Miku' -ShortcutDir 'desktop' -ThemeColor '39C5BB' -Avatar 'vinyl'
```

```

## Todos

- [ ] fix Invoke-Evil-Action
- [ ] 7zip config
- [ ] Set-RemoteSSHKey
- [ ] Update-System
- [ ] Shell-Config
- [ ] Win Optimize Scripts (Optimize-Server, Optimize-UI etc.)
- [ ] ChromeInstallExtension
- [ ] SetProxy
```
