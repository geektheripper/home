function global:Set-System-Manual {
  Require-Administrator

  $Win32CS = Get-WMIObject -Class Win32_ComputerSystem
  $Win32OS = Get-WMIObject Win32_OperatingSystem

  $WorkGroupName = Read-Host-With-Default `
    -Message "What is your workgroup name?" `
    -Current $Win32CS.Workgroup `
    -Default $Win32CS.Workgroup

  if ($Win32CS.Workgroup -ne $WorkGroupName) {
    Add-Computer -WorkGroupName $WorkGroupName
  }

  $ComputerName = Read-Host-With-Default `
    -Message 'What is your computer name?' `
    -Current $Win32OS.PSComputerName `
    -Default $Win32OS.PSComputerName

  if ($ComputerName.ToLower() -ne $Win32OS.PSComputerName.ToLower()) {
    Rename-Computer -NewName $ComputerName -Force
  }

  $Win32OS.Description = Read-Host-With-Default `
    -Message 'What is your computer description?' `
    -Default "$ComputerName in geektr cloud"
  $Win32OS.Put()
}

Function global:Set-System() {
  Require-Administrator

  Param($WorkGroupName, $ComputerName, $Description)

  $Win32CS = Get-WMIObject -Class Win32_ComputerSystem
  $Win32OS = Get-WMIObject Win32_OperatingSystem

  if ($WorkGroupName -and ($Win32CS.Workgroup -ne $WorkGroupName)) {
    Add-Computer -WorkGroupName $WorkGroupName
  }

  if ($ComputerName -and ($ComputerName.ToLower() -ne $Win32OS.PSComputerName.ToLower())) {
    Rename-Computer -NewName $ComputerName -Force
  }

  if ($Description) {
    $Win32OS.Description = $Description
    $Win32OS.Put()
  }
}

Function global:CreateAdministrator {
  Require-Administrator

  Param($UserName, $FullName)

  If (-not(Get-LocalUser $UserName -ErrorAction SilentlyContinue)) {
    New-LocalUser $UserName
  }

  Set-LocalUser $UserName -FullName $FullName

  if (-not(Is-Administrator $UserName)) {
    Add-LocalGroupMember -Group "Administrators" -Member $UserName
  }
}
