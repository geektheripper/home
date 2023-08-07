# https://chromium.googlesource.com/chromium/src/+/main/chrome/browser/profiles/profile_avatar_icon_util.cc#414
$AvatarMap = @{
  "old_generic"             = 0
  "old_generic_aqua"        = 1
  "old_generic_blue"        = 2
  "old_generic_green"       = 3
  "old_generic_orange"      = 4
  "old_generic_purple"      = 5
  "old_generic_red"         = 6
  "old_generic_yellow"      = 7
  "old_secret_agent"        = 8
  "old_superhero"           = 9
  "old_volley_ball"         = 10
  "old_businessman"         = 11
  "old_ninja"               = 12
  "old_alien"               = 13
  "old_awesome"             = 14
  "old_flower"              = 15
  "old_pizza"               = 16
  "old_soccer"              = 17
  "old_burger"              = 18
  "old_cat"                 = 19
  "old_cupcake"             = 20
  "old_dog"                 = 21
  "old_horse"               = 22
  "old_margarita"           = 23
  "old_note"                = 24
  "old_sun_cloud"           = 25
  "placeholder"             = 26
  "origami_cat"             = 27;
  "cat"                     = 27;
  "origami_corgi"           = 28;
  "corgi"                   = 28;
  "origami_dragon"          = 29;
  "dragon"                  = 29;
  "origami_elephant"        = 30;
  "elephant"                = 30;
  "origami_fox"             = 31;
  "fox"                     = 31;
  "origami_monkey"          = 32;
  "monkey"                  = 32;
  "origami_panda"           = 33;
  "panda"                   = 33;
  "origami_penguin"         = 34;
  "penguin"                 = 34;
  "origami_pinkbutterfly"   = 35;
  "pinkbutterfly"           = 35;
  "origami_rabbit"          = 36;
  "rabbit"                  = 36;
  "origami_unicorn"         = 37;
  "unicorn"                 = 37;
  "illustration_basketball" = 38;
  "basketball"              = 38;
  "illustration_bike"       = 39;
  "bike"                    = 39;
  "illustration_bird"       = 40;
  "bird"                    = 40;
  "illustration_cheese"     = 41;
  "cheese"                  = 41;
  "illustration_football"   = 42;
  "football"                = 42;
  "illustration_ramen"      = 43;
  "ramen"                   = 43;
  "illustration_sunglasses" = 44;
  "sunglasses"              = 44;
  "illustration_sushi"      = 45;
  "sushi"                   = 45;
  "illustration_tamagotchi" = 46;
  "tamagotchi"              = 46;
  "illustration_vinyl"      = 47;
  "vinyl"                   = 47;
  "abstract_avocado"        = 48;
  "avocado"                 = 48;
  "abstract_cappuccino"     = 49;
  "cappuccino"              = 49;
  "abstract_icecream"       = 50;
  "icecream"                = 50;
  "abstract_icewater"       = 51;
  "icewater"                = 51;
  "abstract_melon"          = 52;
  "melon"                   = 52;
  "abstract_onigiri"        = 53;
  "onigiri"                 = 53;
  "abstract_pizza"          = 54;
  "pizza"                   = 54;
  "abstract_sandwich"       = 55;
  "sandwich"                = 55;
}

function WebKitNowTimestamp {
  return [Int64]([Float]::Parse((Get-Date -UFormat %s)) * 1000) * 1000 + 11644473600141050
}

function global:InstallGoogleChrome {
  if (CmdNotExist chrome) { scoop install extras/googlechrome }
  
  $default_data_dir = "$env:LOCALAPPDATA\Google\Chrome\User Data"
  $scoop_chrome_data_dir = "$env:SCOOP\persist\googlechrome\User Data"

  if (Test-Path $default_data_dir) {
    Write-Warning "Google Chrome is already installed."
    Write-Warning "Please delete $default_data_dir and run this script again."
    return
  }

  New-Item -ItemType Junction -Path $default_data_dir -Target $scoop_chrome_data_dir
}

function global:NewChromeProfile {
  Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$ProfileName,

    [ValidateNotNullOrEmpty()]
    [ValidatePattern('^[a-zA-Z][a-zA-Z0-9_-]*$')]
    [string]$DisplayName,

    [ValidateNotNullOrEmpty()]
    [ValidateSet('scoop', 'desktop')]
    [string]$ShortcutDir = 'desktop',

    [ValidatePattern('^[0-9a-fA-F]{6}$')]
    [string]$ThemeColor = '000000',

    [string]$Avatar = 'fox'
  )

  # Sys
  $ScoopShortcutDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Scoop Apps"
  $DesktopDir = "$env:USERPROFILE\Desktop"

  # Lnk
  $TargetDir = switch ($ShortcutDir) {
    'scoop' { $ScoopShortcutDir }
    'desktop' { $DesktopDir }
  }
  $LnkTemplate = "$ScoopShortcutDir\Google Chrome.lnk"
  $TempDir = "$env:TEMP\temp.lnk"
  $_DisplayName = if ($DisplayName) { $DisplayName } else { $ProfileName }
  $Destination = "$TargetDir\$_DisplayName.lnk"

  # Data
  $UserDataDir = "$env:SCOOP\apps\googlechrome\current\User Data"
  $_ProfileName = "Profile $ProfileName"
  $ProfileDir = "$UserDataDir\$_ProfileName"
  $PrefsFile = "$ProfileDir\Preferences"

  if (!(Test-Path $LnkTemplate)) {
    Write-Warning "Google Chrome is not installed."
    Write-Warning "Please run InstallGoogleChrome first."
    return 1
  }

  if (Test-Path $ProfileDir) {
    Write-Warning "Profile dir $ProfileName ($ProfileDir) already exists."
    return 1
  }

  $AvatarIndex = $AvatarMap[$Avatar]
  if ($null -eq $AvatarIndex) {
    Write-Warning "Invalid avatar name: $Avatar"
    return 1
  }

  $ColorValue = [Int32]("0xff$ThemeColor")
  $Timestamp = WebKitNowTimestamp

  $Prefs = @"
{
  "autogenerated": {
    "theme": {
      "color": $ColorValue
    }
  },
  "browser": {
    "default_browser_infobar_last_declined": "$Timestamp",
    "has_seen_welcome_page": true,
    "should_reset_check_default_browser": false
  },
  "extensions": {
    "theme": {
      "id": "autogenerated_theme_id"
    }
  },
  "profile": {
    "avatar_index": $AvatarIndex,
    "managed_user_id": "",
    "name": "$_DisplayName",
    "using_default_avatar": false,
    "using_default_name": false,
    "using_gaia_avatar": false,
    "were_old_google_logins_removed": true
  }
}
"@

  # Create Lnk
  Copy-Item -Force $LnkTemplate $TempDir

  $shell = New-Object -COM WScript.Shell
  $shortcut = $shell.CreateShortcut($TempDir)
  $shortcut.TargetPath = "$env:SCOOP\apps\googlechrome\current\chrome.exe"
  $shortcut.Arguments = "--user-data-dir=`"$UserDataDir`" --profile-directory=`"$_ProfileName`""
  $shortcut.Description = "$_DisplayName (Google Chrome)"
  $shortcut.Save()

  Move-Item $TempDir $Destination

  # Config Profile
  New-Item -ItemType Directory -Path $ProfileDir
  New-Item -ItemType File -Path $PrefsFile -Value $Prefs
}

# https://community.spiceworks.com/how_to/194087-how-to-install-a-chrome-extension-using-a-powershell-script
function global:ChromeInstallExtension {}
