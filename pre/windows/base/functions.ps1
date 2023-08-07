# require administrator
# usage:
# Require-Administrator
Function global:Require-Administrator {
  If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "This script needs to be run As Admin"
    Break
  }
}

# read user input with default value and current value
# usage:
# $ReadIn = Read-Host-With-Default -Message 'Enter a value' \
# -Default 'default value' -Current 'current value'
Function global:Read-Host-With-Default {
  Param($Message, $Default, $Current)
  if ($Current) {
    $Message = [string]::Concat($Message, ' [Current: ', $Current, ']')
  }
  if ($Default) {
    $Message = [string]::Concat($Message, ' [Default: ', $Default, ']')
  }
  $ReadIn = Read-Host $Message
  return ($Default, $ReadIn)[[bool]$ReadIn]
}

# set registry item
# usage:
# Set-RegistyItem -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' \
# -Name 'fDenyTSConnections' -Value 0 -Type DWord
Function global:Set-RegistyItem {
  Require-Administrator

  param ($Path, $Name, $Value, $Type)

  IF (!(Test-Path $Path)) {
    New-Item -Path $Path -Force | Out-Null
  }

  New-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force | Out-Null
}

# download tmp files
# usage:
# Download-TmpFile -Topic 'Optimize-System' -FileName 'Win10.ps1'
Function global:Download-TmpFile {
  Param($Topic, $FileName)

  if (!(Test-Path "$env:TEMP\planetarian")) {
    New-Item -Path "$env:TEMP" -Name "planetarian" -ItemType "directory" -Force
  }

  if (!(Test-Path "$env:TEMP\planetarian\$Topic")) {
    New-Item -Path "$env:TEMP\planetarian" -Name "$Topic" -ItemType "directory" -Force
  }

  Invoke-WebRequest -Uri "$PlanetarianReleaseUrlPrefix\$Topic\$FileName" -OutFile "$env:TEMP\planetarian\$Topic\$FileName"
  return "$env:TEMP\planetarian\$Topic\$FileName"
}

# clear all tmp files
# usage:
# Clear-TmpFiles
Function global:Clear-TmpFiles {
  Remove-Item -Path "$env:TEMP/planetarian" -Recurse -Force
}

# detect if the current user is in great firewall
$Global:InGreatFireWall = "unknown"
Function global:If-In-Great-FireWall {
  If ("unknown" -eq $Global:InGreatFireWall) {
    $Request = [System.Net.WebRequest]::Create('http://google.com')
    # 四季映姫
    $Request.Timeout = 4717
    Try {
      $Response = $Request.GetResponse()
      $Response.Close()
      $Global:InGreatFireWall = $False
    }
    Catch {
      $Global:InGreatFireWall = $True
    }
  }

  return $Global:InGreatFireWall
}

# restart windows explorer
# usage:
# Restart-Explorer
Function Restart-Explorer {
  <#
    .Synopsis
    Restart the Windows Explorer process.
    #>
  [cmdletbinding(SupportsShouldProcess)]
  [Outputtype("None")]
  Param()

  Require-Administrator

  Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
  Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Stopping Explorer.exe process"
  Get-Process -Name Explorer | Stop-Process -Force
  #give the process time to start
  Start-Sleep -Seconds 2
  Try {
    Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Verifying Explorer restarted"
    $p = Get-Process -Name Explorer -ErrorAction stop
  }
  Catch {
    Write-Warning "Manually restarting Explorer"
    Try {
      Start-Process explorer.exe
    }
    Catch {
      #this should never be called
      Throw $_
    }
  }
  Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
}

# if specific user is administrator
# usage:
# Is-Administrator geektr
Function global:Is-Administrator {
  Param($UserName)
  (Get-LocalGroupMember 'Administrators').Name -contains "$env:UserDomain\$UserName" 
}

# test if command exists
# usage:
# CmdExist scoop
Function global:CmdExist {
  return Get-Command $args[0] -ErrorAction SilentlyContinue
}

# test if command not exists
# usage:
# CmdNotExist scoop
function global:CmdNotExist {
  return -not(Get-Command $args[0] -ErrorAction SilentlyContinue)
}
