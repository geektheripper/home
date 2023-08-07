function global:Invoke-Evil-Action {
  Require-Administrator
  $KmsFile = Download-TmpFile -Topic 'evil' -FileName 'kms.bat'
  cmd.exe /c "$KmsFile"
}

function global:Clear-History-And-Exit {
  Remove-Item -Path ((Get-PSReadlineOption).HistorySavePath) -Force
  exit
}
