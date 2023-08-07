# function global:Shell-Config {
#   scoop install SarasaGothic-SC
#   scoop install colortool
#   scoop cache rm *

#   Install-Module posh-git -Scope CurrentUser -Force
#   Install-Module oh-my-posh -Scope CurrentUser -Force

#   colortool -b OneHalfDark.itermcolors
#   Set-Prompt
#   if (!(Test-Path -Path $PROFILE )) { New-Item -Type File -Path $PROFILE -Force }
#   Add-Content $PROFILE @"
# Import-Module posh-git
# Import-Module oh-my-posh
# Set-Theme Agnoster
# "@
# }
