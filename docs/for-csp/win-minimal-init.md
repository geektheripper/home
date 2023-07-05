# 最简 Windows 初始化

::: tip Update At:
2022.12 更新系统镜像
:::

这是一篇给云服务商的文章，如果您是手动安装系统请参考后面的内容。

如果您已有系统模板，请确保您已经正确设置了防火墙和注册表（`HKLM:\System\CurrentControlSet\Control\Terminal Server`）。

无论我选购的是MC游戏服务器还是任何其他商品名，都请提供给我最纯净的系统。

## 0. 安装

下载镜像：[winserver-2022-2108.9-en-update-2022-12.iso](https://anita.minio.geektr.co:9002/planetarian-base/system-images/winserver-2022-2108.9-en-update-2022-12.iso)

安装选项：Windows Server 2022 Datacenter (Desktop Experience)

::: danger 重要提示
不分区！不分区！不分区！
:::

## 1. 启用 RDP 远程访问

::: warning 提示
以下脚本试用 Powershell 执行，不要用 CMD 执行
:::

```ps1
Write-Host "allow remote desktop access..."
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -Group "@FirewallAPI.dll,-28752"
```
