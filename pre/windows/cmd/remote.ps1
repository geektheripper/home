function global:Set-RemoteRDP {
  Require-Administrator

  Write-Host "allow remote desktop access..."
  Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
  Enable-NetFirewallRule -Group "@FirewallAPI.dll,-28752"
}

function global:Set-RemoteSSH {
  Require-Administrator
  
  Write-Host "allow ssh access..."
  Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
  Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
  Start-Service sshd
  Set-Service -Name sshd -StartupType 'Automatic'
  if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
  } else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
  }

  Write-Host "set powershell as default ssh shell..."
  New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
}

function global:Set-RemotePS {
  Require-Administrator

  Write-Host "allow powershell remote access..."
  Enable-PSRemoting -Force
  Enable-PSRemoting -SkipNetworkProfileCheck -Force
  Set-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -RemoteAddress Any
}

function global:Set-Remote {
  Set-RemoteRDP
  Set-RemoteSSH
  Set-RemotePS
}

function global:Set-RemoteSSHKey {
  Require-Administrator
  # TODO: install ssh pub key
  # Write-Host "install ssh pub key..."
}
