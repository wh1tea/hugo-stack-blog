---
title: Sysmon 安装与 sysmonconfig 配置
slug: sysmon-install-config
date: 2026-11-15T06:12:00+08:00
description: 用管理员权限装好 Sysmon、加载 sysmonconfig 让网络与 DNS 事件真正产生，并让普通终端免提权读日志
tags:
  - sysmon
  - windows
  - security
  - uac
  - event-log
categories:
  - windows
draft: true
---

装 Sysmon 失败最常见的一幕是双击 `Sysmon.exe` 窗口一闪而过，再在终端里敲 `sysmon -accepteula -i` 也直接退出，而原因往往只是权限和调用方式。这篇面向能看懂 PowerShell 输出的 Windows 用户，走完安装、加载 sysmonconfig 与免提权读日志三步，就能在事件日志里查到进程创建、网络连接和 DNS 查询。

## 先看清失败点

Sysmon 是系统活动监视器：一个常驻服务加一个内核驱动，把系统事件写进 Windows 事件日志。它没有图形界面，双击 exe 时无参数只打印用法就退出，所以「点了没反应」是正常现象。另一个前提是安装目录一般不在 `PATH`（命令行查找可执行文件的目录列表，`$env:PATH` 可查看）里，`sysmon` 这条命令基本敲不出来。三类失败的区分方式：

| 现象                                                | 原因                                     | 验证                        |
| :-------------------------------------------------- | :--------------------------------------- | :-------------------------- |
| 窗口一闪而过                                        | 无参数运行，只打印 usage 后退出          | 带 `-?` 在终端里跑          |
| `sysmon : 无法将"sysmon"项识别为 cmdlet`             | `sysmon` 不在 `PATH`（命令行搜索目录）里 | `Get-Command sysmon`        |
| `You need to launch Sysmon as an Administrator.`     | 当前进程未提权，退出码 `740`             | 下面的提权判定              |

```powershell
Get-Command sysmon

$id = [Security.Principal.WindowsIdentity]::GetCurrent()
(New-Object Security.Principal.WindowsPrincipal($id)).IsInRole(
  [Security.Principal.WindowsBuiltInRole]::Administrator)
```

第二条在普通终端返回 `False`，在管理员终端返回 `True`——即使账号本身属于 `Administrators` 组，未提权的进程也是 `False`。提权与 UAC 的关系见[关闭 UAC 的代价](dont-disable-uac.md)。

压缩包里有三个同名构建，架构不同：

| 文件            | 架构  | 适用                |
| :-------------- | :---- | :------------------ |
| `Sysmon.exe`    | x86   | 32 位系统           |
| `Sysmon64.exe`  | x64   | 64 位系统（本文）   |
| `Sysmon64a.exe` | ARM64 | ARM64 设备          |

架构从 PE 头的 `Machine` 字段读，`0x014C` 是 x86、`0x8664` 是 x64、`0xAA64` 是 ARM64：

```powershell
$fs = [IO.File]::OpenRead('D:\Other Program Files\Sysmon\Sysmon64.exe')
$br = New-Object IO.BinaryReader($fs)
$fs.Position = 0x3C
$fs.Position = $br.ReadInt32() + 4
'0x{0:X4}' -f $br.ReadUInt16()
$br.Close()
```

## 用管理员终端安装

在管理员终端里进安装目录，加 `-accepteula` 跳过交互式 EULA 确认：

```powershell
cd 'D:\Other Program Files\Sysmon'
.\Sysmon64.exe -accepteula -i
```

成功时依次输出安装服务、安装驱动、启动驱动、启动服务：

```text
Sysmon64 installed.
SysmonDrv installed.
Starting SysmonDrv.
SysmonDrv started.
Starting Sysmon64..
Sysmon64 started.
```

`SysmonDrv` 是 boot-start 驱动——开机时在文件系统就绪前加载，因此能记录开机早期的进程活动。它的镜像路径写的是 `\SystemRoot\SysmonDrv.sys`，所以文件落在 `C:\Windows` 根目录，而不是 `System32\drivers`。

```powershell
Get-Service Sysmon64
sc.exe qc SysmonDrv
Get-ChildItem C:\Windows\SysmonDrv.sys
```

期望结果：服务 `Sysmon64` 为 `Running` / `Automatic`；驱动 `START_TYPE` 是 `0`（`BOOT_START`）、`BINARY_PATH_NAME` 是 `\SystemRoot\SysmonDrv.sys`。

## 默认配置漏掉网络和 DNS

`-i` 不带配置文件时用内置默认配置。官方文档写明默认设置是「用 SHA1 计算进程哈希、不监控网络」[^1]。实测安装后日志里最早的 9 条事件只出现 `ID 16`（配置加载）、`ID 4`（服务状态变化）、`ID 1`（进程创建）、`ID 5`（进程终止），没有 `ID 3`（网络连接）。

```powershell
Get-WinEvent -LogName 'Microsoft-Windows-Sysmon/Operational' -Oldest |
  Select-Object -First 9 | Format-Table TimeCreated, Id
```

## 加载 sysmonconfig

社区事实标准是 SwiftOnSecurity 维护的配置，规则按进程、路径、签名逐条写了排除项[^2]：

```powershell
$url = 'https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml'
Invoke-WebRequest -Uri $url -OutFile '.\sysmonconfig.xml'
.\Sysmon64.exe -c .\sysmonconfig.xml
```

换配置同样需要管理员权限，非提权执行 `-c` 会得到和安装时一样的 `You need to launch Sysmon as an Administrator.`。这是装完之后唯一还需要反复提权的操作。

配置文件里的 `schemaversion` 是配置语法版本，和程序版本相互独立。实测该文件声明 `4.50`，程序是 `4.91`，加载时逐行打印：

```text
Loading configuration file with schema version 4.50
Sysmon schema version: 4.91
Configuration file validated.
Configuration updated.
```

验证配置真的换了：

```powershell
Get-WinEvent -LogName 'Microsoft-Windows-Sysmon/Operational' -MaxEvents 300 |
  Where-Object Id -eq 16 | Select-Object -First 1 |
  ForEach-Object { $_.Message }
```

消息里应出现 `Configuration: .\sysmonconfig.xml` 和 `Configurat      ionFileHash: SHA256=...`。同时事件数量会明显上升——实测 400 条窗口内的 ID 分布为 `1`、`3`、`5`、`11`、`16`、`22`。

## 让普通终端也能读日志

Sysmon 的事件通道默认只对管理员和 `Event Log Readers` 组可读。非提权读取会报 `Attempted to perform an unauthorized operation.`。

`Event Log Readers` 是内置组（`S-1-5-32-573`），只授予读事件日志的权限，不含写入或管理：

```powershell
# 管理员终端执行一次
net localgroup "Event Log Readers" $env:USERNAME /add
```

```powershell
whoami /groups | Select-String 'Event Log Readers'
```

`whoami /groups` 能列出该组、且 `Get-WinEvent` 不再抛异常，就说明生效了。注意这只解决读：`-i`、`-c`、`-u` 依然要管理员。

## 查询事件

按 ID 统计是最快的健康检查，某个 ID 一直是 0 说明对应规则没启用：

```powershell
Get-WinEvent -LogName 'Microsoft-Windows-Sysmon/Operational' -MaxEvents 300 |
  Group-Object Id | Sort-Object { [int]$_.Name } |
  Format-Table @{ n = 'ID'; e = { $_.Name } }, Count
```

要取具体字段就解析事件的 XML：

```powershell
$e = Get-WinEvent -LogName 'Microsoft-Windows-Sysmon/Operational' -MaxEvents 300 |
  Where-Object Id -eq 1 | Select-Object -First 1
$xml = [xml]$e.ToXml()
$xml.Event.EventData.Data | Format-Table Name, @{ n = 'Value'; e = { $_.'#text' } }
```

实测见过的 ID 与含义：

| ID   | 事件     | 触发方式               |
| :--- | :------- | :--------------------- |
| `1`  | 进程创建 | 安装与换配置的命令自身 |
| `3`  | 网络连接 | 一次 `:443` 出站连接   |
| `5`  | 进程终止 | 随进程退出产生         |
| `11` | 文件创建 | 配置文件写入           |
| `16` | 配置变更 | `-c` 加载新配置        |
| `22` | DNS 查询 | 进程解析域名           |

进程创建事件里 `IntegrityLevel` 是进程的完整性级别，`High` 表示它提权运行，因此从事件本身就能看出某条命令是不是管理员执行的；`ParentImage` 与 `ParentCommandLine` 则给出调用链。

## 卸载

```powershell
# 管理员终端
.\Sysmon64.exe -u
```

```powershell
Get-Service *sysmon*
Test-Path C:\Windows\SysmonDrv.sys
```

两条都没有输出 / 返回 `False`，说明服务和驱动都已移除。

## 结语

需要管理员的只有两个动作：`-i` 安装、`-c` 换配置；读日志交给 `Event Log Readers` 组，普通终端直接 `Get-WinEvent`。配置改动走 `-c` 热加载，不必重装服务。

[^1]: [Sysmon - Sysinternals official documentation](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon)
[^2]: [SwiftOnSecurity/sysmon-config exported config](https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml)
