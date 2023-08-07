function global:EnableDeveloperMode {
  $TmpScript = Download-TmpFile -Topic 'ext' -FileName 'enable-developer-mode.ps1'
  powershell $TmpScript
}

function global:Install-Scoop {
  Param($ScoopProxy)

  if (CmdNotExist scoop) {
    Write-Host 'Installing scoop...'
    Set-ExecutionPolicy RemoteSigned -scope CurrentUser
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
  }

  If ($ScoopProxy) {
    scoop config proxy "$ScoopProxy"
  }

  if (CmdNotExist scoop) { scoop install git }

  $buckets = (scoop bucket list).Name
  if ($buckets -notcontains 'extras') { scoop bucket add 'extras' }
  if ($buckets -notcontains 'ash-258') { scoop bucket add 'ash-258' 'https://github.com/Ash258/Scoop-Ash258.git' }
  if ($buckets -notcontains 'dorado') { scoop bucket add 'dorado' 'https://github.com/chawyehsu/dorado.git' }
  if ($buckets -notcontains 'scevils') { scoop bucket add 'scevils' 'https://git.geektr.co/geektr/scevils.git' }
  scoop update

  if (CmdNotExist sudo) { scoop install sudo }
  if (CmdNotExist ssh-keygen) { scoop install openssh }

  if (CmdNotExist innounp) { scoop install innounp }
  if (CmdNotExist dark) { scoop install dark }

  scoop cache rm *
  sudo Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1
  EnableDeveloperMode
  scoop checkup
}

function global:Install-Aria2 {
  scoop install aria2
  scoop config aria2-enabled true
  scoop config aria2-max-connection-per-server 8
  scoop config aria2-warning-enabled false
}

function global:Install-VCRedist {
  scoop install vcredist2019
  scoop install vcredist2017
  scoop install vcredist
  scoop uninstall vcredist2019
  scoop uninstall vcredist2017
  scoop uninstall vcredist
}
