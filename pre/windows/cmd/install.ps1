function InitServer {
  scoop install extras/dismplusplus
  scoop install extras/googlechrome
  scoop install main/iperf3
  scoop install main/nircmd
  scoop install extras/sysinternals
}

function InitDesktop {
  InitServer
  scoop install extras/snipaste
  scoop install extras/wox
}

function InstallMediaApps {
  scoop install extras/potplayer
  scoop install extras/imageglass
  scoop install extras/foobar2000
  scoop install extras/foobar2000-encoders
  scoop install extras/mediainfo
}

function InstallMediaWorkApps {
  InstallMediaApps
  scoop install extras/obs-studio
  scoop install extras/licecap
  scoop install dorado/aegisub
  scoop install main/exiftool
  scoop install main/ffmpeg
  scoop install main/imagemagick
  scoop install main/x264
}

function InstallStorageApps {
  scoop install scevils/baidupcs-go
  scoop install extras/cyberduck
  scoop install extras/fastcopy
  scoop install extras/oss-browser
  scoop install extras/qbittorrent
  scoop install main/rclone
  scoop install main/speedtest-cli
  scoop install extras/winscp
  scoop install main/youtube-dl
}