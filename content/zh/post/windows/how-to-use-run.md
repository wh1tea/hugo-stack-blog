---
title: Win+R 运行窗口：命令速查与使用技巧
slug: how-to-use-run.md
date: 2026-07-14
description: 系统梳理 Win+R 运行窗口的常用命令清单，涵盖系统管理、控制面板、日常工具、网络远程等分类，并分享提高操作效率的使用技巧。
tags:
  - windows
  - productivity-tools
categories:
  - windows
---

> `Win + R` 或者`win`搜索`run`打开运行窗口

## 常用命令大全

### 1. 系统核心管理类

这类命令用于快速调出系统最底层的管理工具。

| 命令           | 功能说明                             | 缩写来源                       |
| -------------- | ------------------------------------ | ------------------------------ |
| `control`      | 打开控制面板                         | Control Panel                  |
| `regedit`      | 打开注册表编辑器                     | Registry Editor                |
| `gpedit.msc`   | 本地组策略编辑器（专业版/企业版）    | Group Policy Editor (MMC)      |
| `services.msc` | 本地服务管理                         | Services (MMC)                 |
| `compmgmt.msc` | 计算机管理（含磁盘管理、设备管理等） | Computer Management (MMC)      |
| `devmgmt.msc`  | 设备管理器                           | Device Management (MMC)        |
| `diskmgmt.msc` | 磁盘管理                             | Disk Management (MMC)          |
| `secpol.msc`   | 本地安全策略                         | Security Policy (MMC)          |
| `eventvwr.msc` | 时间查看器                           | Event Viewer (MMC)             |
| `msconfig`     | 系统配置实用程序（管理启动项）       | Microsoft System Configuration |
| `winver`       | 查看Windows版本信息                  | Windows Version                |
| `msinfo32`     | 查看详细系统信息                     | Microsoft Info (32-bit)        |

### 2. 控制面板扩展类（.cpl）

后缀为 `.cpl` 的命令可直接打开特定的设置面板。

| 命令           | 功能说明                   | 缩写来源                        |
| -------------- | -------------------------- | ------------------------------- |
| `appwiz.cpl`   | 程序和功能（卸载软件）     | Application Wizard              |
| `ncpa.cpl`     | 网络连接设置               | Network Connections Properties? |
| `sysdm.cpl`    | 系统属性（含环境变量设置） | System Device Manager?          |
| `firewall.cpl` | Windows防火墙设置          | Firewall                        |
| `inetcpl.cpl`  | Internet属性               | Internet Control Panel          |
| `desk.cpl`     | 显示设置/屏幕分辨率        | Desktop                         |
| `powercfg.cpl` | 电源选项                   | Power Configuration             |
| `mmsys.cpl`    | 声音和音频设备             | Multimedia System               |

### 3. 日常工具类

直接调用Windows自带的小工具。

| 命令                | 功能说明   | 缩写来源             |
| ------------------- | ---------- | -------------------- |
| `calc`              | 计算器     | Calculator           |
| `notepad`           | 记事本     | Notepad              |
| `mspaint`           | 画图工具   | Microsoft Paint      |
| `write` / `wordpad` | 写字板     | WordPad（旧名Write） |
| `snippingtool`      | 截图工具   | Snipping Tool        |
| `osk`               | 屏幕键盘   | On-Screen Keyboard   |
| `charmap`           | 字符映射表 | Character Map        |
| `magnify`           | 放大镜     | Magnifier            |

### 4. 网络与远程类

| 命令         | 功能说明       | 缩写来源                           |
| ------------ | -------------- | ---------------------------------- |
| `cmd`        | 命令提示符     | Command                            |
| `powershell` | PowerShell终端 | PowerShell                         |
| `mstsc`      | 远程桌面连接   | Microsoft Terminal Services Client |
| `\\IP地址`   | 访问共享文件夹 | 网络路径格式                       |

### 5. 故障排查与日志类

| 命令       | 功能说明                        | 缩写来源            |
| ---------- | ------------------------------- | ------------------- |
| `taskmgr`  | 任务管理器                      | Task Manager        |
| `eventvwr` | 事件查看器                      | Event Viewer        |
| `resmon`   | 资源监视器                      | Resource Monitor    |
| `perfmon`  | 性能监视器                      | Performance Monitor |
| `dxdiag`   | DirectX诊断工具（查看硬件配置） | DirectX Diagnostic  |
| `cleanmgr` | 磁盘清理工具                    | Clean Manager       |

### 6. 用户与权限类

| 命令                     | 功能说明                      | 缩写来源                       |
| ------------------------ | ----------------------------- | ------------------------------ |
| `lusrmgr.msc`            | 本地用户和组（专业版/企业版） | Local User Manager (MMC)       |
| `netplwiz`               | 高级用户账户管理              | Network Place Wizard           |
| `control userpasswords2` | 用户账户控制                  | Control Panel + User Passwords |

### 7. 系统操作与文件夹快捷访问

| 命令                  | 功能说明                    | 缩写来源         |
| --------------------- | --------------------------- | ---------------- |
| `explorer`            | 打开文件资源管理器`Win + E` | Windows Explorer |
| `%temp%`              | 打开临时文件夹              | 环境变量（Temp） |
| `shell:startup`       | 打开启动文件夹              | Shell 命令       |
| `shutdown -s -t 秒数` | 定时关机                    | Shutdown         |
| `shutdown -a`         | 取消定时关机                | Abort            |
| `shutdown -r -t 秒数` | 定时重启                    | Reboot           |
| `logoff`              | 注销当前用户                | Log Off          |

## 实用技巧

### 以管理员身份运行

对于一些需要更高权限的命令（如修改系统配置），输入命令后**不要直接回车**，而是按 **`Ctrl + Shift + Enter`**，程序将以管理员身份运行。这一技巧对修改系统文件、执行高级管理操作至关重要。

### 历史命令快速回溯

运行窗口会记忆你最近执行过的命令。打开运行窗口后，按键盘上的 **向上方向键（↑）** 即可逐条回溯历史命令，按 **向下方向键（↓）** 可正向浏览。这个功能让你无需重复输入常用命令，最多可回溯26条记录。

### 路径自动补全

在运行窗口中输入路径时，按 **`Tab` 键** 可以自动补全路径，省去手动输入的麻烦。

### 直接输入网址或文件路径

运行窗口不仅支持系统命令，还可以：

- 直接输入网址（如 `www.google.com`）打开浏览器访问该网站
- 直接输入文件夹路径（如 `C:\Windows`）打开该文件夹
- 直接输入文件名或程序名启动对应程序

### 巧用环境变量

在运行窗口中可以使用系统环境变量快速跳转：

- `%temp%` — 打开当前用户的临时文件夹
- `%appdata%` — 打开应用程序数据文件夹
- `%userprofile%` — 打开用户目录

### 自定义快捷启动

如果你希望用Win+R快速启动常用第三方软件，可以将该程序的**快捷方式（.lnk）** 复制到 `C:\Windows` 目录下。之后在运行窗口中输入快捷方式的文件名（如 `vscode`），即可一键启动对应程序。

## 命令记忆小窍门

很多Win+R命令其实是有规律可循的：

- **`taskmgr`** = task（任务）+ mgr（管理器）→ 任务管理器
- **`cleanmgr`** = clean（清理）+ mgr（管理器）→ 磁盘清理
- **`calc`** = calculator（计算器）的缩写
- **`.msc`** 后缀 = **.msc（Microsoft Management Console Snap-in）** 是 Windows 微软管理控制台（MMC）保存的管理单元配置文件，用于系统管理与运维自动化。如 `services.msc`、`devmgmt.msc`
- **`.cpl`** 后缀 = Control Panel（控制面板）项，如 `ncpa.cpl`、`appwiz.cpl`

## 典型使用场景

### 场景一：电脑卡顿死机

按下 `Win + R` → 输入 `taskmgr` → 回车，直接打开任务管理器结束无响应程序。这比 `Ctrl + Alt + Delete` 更加优雅高效。

### 场景二：电脑开机太慢

`Win + R` → 输入 `msconfig` → 回车，在"启动"选项卡中禁用不必要的开机启动项。

### 场景三：网络无法连接

`Win + R` → 输入 `ncpa.cpl` → 回车，直接进入网络连接设置，检查网卡状态或修改IP配置。

### 场景四：清理C盘空间

`Win + R` → 输入 `%temp%` → 回车，全选（Ctrl+A）后一键删除所有临时文件；或者输入 `cleanmgr` 使用磁盘清理工具。

### 场景五：查看电脑配置

`Win + R` → 输入 `dxdiag` → 回车，即可查看完整的硬件配置和系统信息。
