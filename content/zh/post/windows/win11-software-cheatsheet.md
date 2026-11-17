---
title:  Windows 11 本地软件速查表
slug: win11-software-cheatsheet
date: 2026-11-16T06:00:00+08:00
description: 从 x86、x64、ARM64 讲起，把 Win11 本地软件按用途分类整理成表，附标签、路径和自查命令
tags:
  - windows
  - software
  - cheatsheet
  - installation
categories:
  - windows
---


本文不是「必装推荐」，而是一张「电脑上有什么、分别干什么、授权怎么算」的底图。日常操作和快捷键见 [Win11 高效操作指南](win11-efficient-operations-guide.md)。

读表前先约定标签：

- **开源**：源码公开，通常可以免费使用；商用和二次分发仍要看具体许可证。
- **免费**：可以免费使用，源码不一定公开。
- **Freemium**：核心功能免费，Pro、高级功能或商用授权收费。
- **付费**：需要买断或订阅。

## 先看懂安装包：x86、x64、ARM64

下载软件时最先遇到的不是功能，而是架构。选错架构，安装程序可能直接拒绝，也可能装上了却闪退。

| 写法   | 含义                                 | 能装在哪              | 备注                                         |
| :----- | :----------------------------------- | :-------------------- | :------------------------------------------- |
| x86    | 32 位 x86，也叫 32-bit、i386         | 32 位和 64 位 Windows | 内存寻址上限 4 GB，老软件常见                |
| x64    | 64 位 x86，也叫 x86-64、AMD64、win64 | 64 位 Windows         | 最常见，不能装 32 位 Windows                 |
| ARM64  | 64 位 ARM，也叫 aarch64              | ARM64 Windows         | 骁龙笔记本等，可模拟运行 x64/x86             |
| x86_64 | x64 的另一种写法                     | 同 x64                | 看到它不要当成「x86 的 64 位版」             |
| amd64  | x64 的另一种写法                     | 同 x64                | 不是 AMD（超威半导体）处理器专用，Intel 也用 |

几个容易混淆的点：

- **先查本机**：设置 → 系统 → 系统信息 → 系统类型；或者 PowerShell 执行 `$env:PROCESSOR_ARCHITECTURE`。返回 `AMD64` 就是 x64；ARM 笔记本返回 `ARM64`；老机器可能返回 `x86`。
- **兼容关系**：64 位 Windows 能跑 x86 和 x64；ARM64 Windows 能跑 ARM64，并通过模拟层跑 x64/x86；32 位 Windows 只能跑 x86。
- **两个 Program Files**：`C:\Program Files` 默认放 64 位程序，`C:\Program Files (x86)` 默认放 32 位程序。32 位程序在 64 位系统上通过 WOW64 运行，所以同一个软件可能两套都有。
- **下载页怎么选**：优先 x64；页面只给 x86 时，64 位系统也能装；ARM 笔记本优先 ARM64，没有 ARM64 再选 x64 模拟。驱动必须匹配架构，32 位驱动不能装在 64 位系统上。

## 安装包不止 EXE：MSI、便携版与包管理器

同样是「双击安装」，背后的机制差别很大。看懂形态，能少踩一半的坑。

| 形态       | 常见文件                            | 安装方式            | 卸载方式               | 特点                                                                      |
| :--------- | :---------------------------------- | :------------------ | :--------------------- | :------------------------------------------------------------------------ |
| MSI        | `.msi`                              | 双击或 `msiexec /i` | 应用和功能             | Windows Installer 数据库，支持静默安装，企业部署常用                      |
| EXE 安装器 | `setup.exe`、`install.exe`          | 向导下一步          | 应用和功能或自带卸载器 | 常见 NSIS（Nullsoft 脚本安装系统）、Inno Setup、InstallShield，可能带捆绑 |
| 便携版     | `.zip`、`.7z`、单 exe               | 解压即用            | 删目录                 | 不写卸载项，配置可能在程序目录，可放 U 盘                                 |
| MSIX/Store | `.msix`（微软应用包格式）、商店应用 | 商店或双击          | 应用和功能             | 沙箱化，权限受限，更新走商店                                              |
| 包管理器   | `winget`、`scoop`、`choco`          | 命令行              | 命令行                 | 统一安装和升级，scoop 接近便携                                            |

再补几个名词：

- **MSI 不是「更高级的 EXE」**。它把安装信息写成数据库，修复、卸载、静默安装都更规范，所以企业批量部署喜欢用。`msiexec /i 包名.msi /qn` 就是不弹界面的静默安装。
- **EXE 安装器**常见 NSIS（Nullsoft 脚本安装系统）、Inno Setup、InstallShield 几种壳。「下一步」里可能塞浏览器、压缩软件或工具栏，选自定义安装，把不需要的勾去掉。
- **便携版**也叫绿色版、免安装版。它通常不写注册表和卸载项，删目录就是卸载；但有的仍会在 `%APPDATA%` 写配置，删之前先看程序目录里有没有 `data`、`config` 之类的文件夹。
- **MSIX/Store 应用**（微软应用包格式）像手机 App，装在沙箱里，不能随便改 `Program Files`，权限也受限制。
- **包管理器**适合命令行工具和常用 GUI。`winget list` 看已装，`winget upgrade` 看可升级，`scoop list` 看 scoop 装了什么。
- **在线安装包和离线安装包**：文件名带 `web` 的通常只带下载器，安装时还要联网；带 `offline`、`full` 的才是完整包，没网时选后者。
- **单文件 EXE 不一定便携**。有的单文件只是自解压安装器，仍会写注册表、弹向导；看它有没有卸载项最准。

几个最常打交道的写法：

```text
setup.exe / install.exe       EXE 安装器常见文件名
包名.msi                      MSI 安装包
msiexec /i 包名.msi /qn       静默安装
scoop list                    scoop 已装列表
where.exe 命令名              查命令在 PATH 的哪个位置
```

## 装到哪，怎么卸

Windows 默认把程序分几个地方放：

- 64 位程序：`C:\Program Files`
- 32 位程序：`C:\Program Files (x86)`
- 仅当前用户：`%LOCALAPPDATA%\Programs`
- 自定义目录：例如 `D:\Program Files`

几个判断：

- **装到 D 盘只改变程序文件的位置**，注册表、开始菜单、卸载项仍在 C 盘。
- **卸载优先用「设置 → 应用 → 已安装的应用」或软件自带卸载器**，不要直接删 `Program Files` 文件夹。直接删会留下服务、驱动和注册表项，下次装同款还可能冲突。
- **便携版反过来**：删目录就是卸载。重要配置在程序目录里的，先把整个文件夹复制走再删。
- **用户数据常在 `%APPDATA%`、`%LOCALAPPDATA%`、`Documents`**，卸载不一定删。浏览器配置、编辑器插件、聊天记录，重装前先备份。
- **安装时选「仅为我安装」通常不需要管理员**，程序落在 `%LOCALAPPDATA%\Programs`；选「为所有用户安装」需要管理员，落在 `Program Files`。

## 系统、文件与截图

这一组解决「找文件、解压、看图、截图、卸载」这些每天都会碰到的事。

| 软件             | 版本   | 介绍                                                             | 标签     |
| :--------------- | :----- | :--------------------------------------------------------------- | :------- |
| Everything       | 1.4.1  | 按文件名秒搜全盘，比资源管理器快得多；只建索引，不搬文件         | 免费     |
| PowerToys        | 0.96.1 | 微软官方效率工具集，窗口布局、批量重命名、取色、键盘映射都在里面 | 开源     |
| Bandizip         | 6.29   | 压缩解压，右键菜单顺手，支持图片预览和自动解压                   | Freemium |
| Honeyview        | 5.53   | 看漫画和图片很快，支持压缩包内直接翻页                           | 免费     |
| Geek Uninstaller | 1.6    | 卸载软件并清残留，比系统卸载更干净；                             | Freemium |
| UsbTreeView      | 4.8    | 把 USB 设备按端口树展开，排查「插了没反应」                      | 免费     |
| Snipaste         | 2.11   | 截图后把图钉在屏幕上，对照资料时不用来回切窗口；F1 截图、F3 贴图 | Freemium |
| 火绒安全         | 6.0    | 轻量杀毒加弹窗拦截，个人版免费；一台机器装一个杀毒软件就够了     | 免费     |

## 硬件监控与性能

这些工具只在装机、压测、排查卡顿时打开，平时不用常驻。

| 软件                | 版本  | 介绍                                                             | 标签 |
| :------------------ | ----- | :--------------------------------------------------------------- | :--- |
| OpenHardwareMonitor | 0.9.6 | 开源硬件监控，看温度、电压、风扇；版本较老，新平台可能读不全     | 开源 |
| Core Temp           | 1.18  | 只看 CPU 温度和功耗，可常驻托盘，压测时盯温度很方便              | 免费 |
| FanControl          | 285   | 按温度画风扇曲线，统一管 CPU 和机箱风扇；免费但源码不公开        | 免费 |
| GPU-Z               | 2.61  | 显卡参数、传感器、BIOS 查看，买卡验卡时常用                      | 免费 |
| CrystalDiskMark     | 9.0   | 硬盘顺序和随机读写跑分，换 SSD 后验性能                          | 免费 |
| NVIDIA App          | 11.0  | N 卡驱动更新、游戏优化、ShadowPlay 录屏，替代 GeForce Experience | 免费 |
| GPU Tweak III       | 1.7   | 华硕显卡的超频、风扇曲线和监控，非华硕卡功能可能受限             | 免费 |
| PawnIO              | 2.2   | 给 FanControl 等工具读主板传感器的底层驱动，装完不用打开         | 开源 |
| WPTx64              | 8.100 | Windows Performance Toolkit，用 wpr 和 wpa 抓系统级性能数据      | 免费 |

## 浏览器、网络与通讯

浏览器留两三个就够，关键是账号和书签能同步；网络工具则按场景选。

| 软件        | 版本 | 介绍                                                             | 标签 |
| :---------- | ---- | :--------------------------------------------------------------- | :--- |
| Chrome      | 157  | 主力浏览器，扩展和账号同步最省心                                 | 免费 |
| Edge        | 157  | 系统自带，PDF 阅读、翻译、IE 模式都能顶，建议保留                | 免费 |
| Firefox     | 160  | 独立内核，适合做备用或隐私浏览，有些站点兼容性更好               | 开源 |
| Clash Verge | 2.5  | 基于 mihomo 内核的代理客户端，规则分流；本身不带节点，要自备订阅 | 开源 |
| TeamSpeak   | 5.0  | 低延迟语音开黑，可以连自建服务器                                 | 免费 |

## 办公、阅读与写作

这一组覆盖文档、笔记、电子书和公式输入。核心矛盾不是「哪个最好」，而是「文件最后要交给谁」：交付 Word 就用 Office，长期维护笔记就用 Markdown。

| 软件            | 版本  | 介绍                                                         | 标签     |
| :-------------- | ----- | :----------------------------------------------------------- | :------- |
| Office          | 2019  | 本地版 Word、Excel、PPT，买断制，不订阅 Microsoft 365        | 付费     |
| 微软 OfficePLUS | —     | 微软官方模板和素材插件，做 PPT、简历时找版式                 | 免费     |
| Typora          | 1.14  | 所见即所得的 Markdown 编辑器，导出 PDF、Word 很顺            | 付费     |
| Obsidian        | 1.14  | 本地 Markdown 笔记库，双链和插件强；个人免费，同步和发布付费 | Freemium |
| calibre         | 9.15  | 电子书库管理、格式转换、元数据抓取，Kindle 用户常备          | 开源     |
| Pandoc          | 3.3   | 命令行文档转换瑞士军刀，Markdown、DOCX、HTML、PDF 互转       | 开源     |
| Mathpix         | 03.00 | 截图公式转 LaTeX，写论文和笔记少敲很多代码；免费额度有限     | Freemium |
| 手心输入法      | 3.3   | 轻量中文输入法，无广告、不弹窗；词库比大厂弱一些             | 免费     |

## 图像、视频与音频

播放、录屏、动态壁纸、按键可视化都在这一组。它们大多只在特定场景打开，不需要开机自启。

| 软件             | 版本  | 介绍                                                 | 标签     |
| :--------------- | ----- | :--------------------------------------------------- | :------- |
| PotPlayer        | 26.08 | 本地视频播放器，启动快、占用低、字幕支持好           | 免费     |
| VLC              | 3.0   | 万能播放器，坏文件、网络流、冷门格式都能试，还能转码 | 开源     |
| OBS Studio       | 32.2  | 录屏和直播推流，场景与来源可编排                     | 开源     |
| Wallpaper Engine | —     | Steam 动态壁纸，创意工坊资源多                       | 付费     |
| keyviz           | 2.1   | 把按键和鼠标操作显示在屏幕上，录教程和演示时用       | 开源     |
| MeowMic          | 0.2   | 麦克风实时降噪、BGM 混音、全局快捷键，直播和开黑用   | 免费     |
| 网易云音乐       | 3.1   | 听歌、歌单、评论，黑胶 VIP 解锁音质和部分曲库        | Freemium |

## 开发与运行环境

这一组最杂：编辑器、版本控制、语言运行时、容器和 Linux 子系统都在这里。更细的分层和 PATH 说明在 [Windows 开发环境](dev-env-map.md) 里，下面只列「装了什么、干什么」。

### 编辑器与版本控制

| 软件             | 版本   | 介绍                                                   | 标签     |
| :--------------- | ------ | :----------------------------------------------------- | :------- |
| VS Code          | 1.146  | 主力代码编辑器，扩展生态大，远程开发也方便             | 免费     |
| WebStorm         | 2026.2 | JetBrains 的 JS/TS IDE，重构和调试强；个人非商业可免费 | Freemium |
| Git              | 2.55   | 版本控制命令行，提交、分支、合并都靠它                 | 开源     |
| GitHub Desktop   | 3.6    | Git 图形客户端，不想记命令时用来提交和看 diff          | 开源     |
| DeepSeek Harness | 0.2    | AI 编程 Agent 桌面端；应用免费，模型 API 另算          | 免费     |

### 语言与运行时

| 软件            | 版本     | 介绍                                                            | 标签     |
| :-------------- | -------- | :-------------------------------------------------------------- | :------- |
| Anaconda3       | 2024.06  | Python 发行版加 conda 包管理，科学计算库开箱即用；个人免费      | Freemium |
| Node.js         | 22 与 25 | JS 运行时，通过 nvm-windows 切换版本；22.23.4 日常用，25.1 备用 | 开源     |
| Eclipse Temurin | 21       | OpenJDK 21 LTS 构建，Java 开发和运行用                          | 开源     |
| Go              | 1.26     | Go 工具链，编译单文件二进制                                     | 开源     |
| .NET SDK        | 10 与 6  | C# 和 .NET 的开发包，含运行时；旧项目还留着 6.0                 | 开源     |
| PowerShell      | 7.6      | 跨平台新版 PowerShell，和系统自带的 5.1 并存                    | 开源     |

### 容器、站点与系统

| 软件           | 版本   | 介绍                                                        | 标签     |
| :------------- | ------ | :---------------------------------------------------------- | :------- |
| Docker Desktop | 4.96   | 容器开发环境，WSL2 后端；个人和小团队免费                   | Freemium |
| Hugo           | 0.168  | 静态站点生成器，适合搭建博客和文档                          | 开源     |
| Vim            | 9.1    | 终端里的模态编辑器，服务器上改配置很快，上手曲线陡          | 开源     |
| Unity Hub      | 3.17   | Unity 引擎和项目管理器；个人版在营收阈值内免费              | Freemium |
| WSL            | 2.6    | Windows 里的 Linux 子系统，跑 Ubuntu 和 Linux 工具链        | 免费     |
| MATLAB         | R2024b | 矩阵运算、仿真和 Simulink，工科常用；商业软件，按许可证使用 | 付费     |

## 数据库

本地数据库只装了三种：一个通用客户端、一个 MySQL、一个 SQL Server Express。

| 软件名     | 版本   | 介绍                                                                    | 标签     |
| :--------- | ------ | :---------------------------------------------------------------------- | :------- |
| DBeaver    | 26.1   | 通用数据库客户端，MySQL、SQL Server、PostgreSQL 都能连；社区版开源      | 开源     |
| MySQL      | 8.0.43 | 关系型数据库，含 Server、Workbench、Shell、Router；GPL 开源             | 开源     |
| SQL Server | 2022   | 微软关系库，Express 免费版，实例名 `TEW_SQLEXPRESS`；Developer 版也免费 | Freemium |

## 便携软件

便携版无卸载项，所以系统卸载列表里看不到它们。

| 软件                | 版本      | 说明                                      |
| :------------------ | :-------- | :---------------------------------------- |
| Geek Uninstaller    | 1.6.0.200 | 卸载工具，清残留和右键菜单；放 U 盘也能用 |
| UsbTreeView         | 4.8.0.0   | USB 设备树和端口占用，排查外设问题        |
| OpenHardwareMonitor | 0.9.6.0   | 开源硬件监控，免安装                      |
| Snipaste            | 2.11.3    | 截图加贴图，配置在程序目录                |
| LibreSprite         | 1.0.0.0   | 开源像素画编辑器，Aseprite 的分支，开发版 |

LibreSprite 单独说一句：它是 Aseprite 的开源分支，适合画 sprite、像素图和简单动画，许可证是 GPLv2。目录名里的 `development` 说明这是开发版，功能和稳定性不如正式 release；如果只是画画，优先找稳定版。

便携版也不是绝对干净：有的程序会在 `%APPDATA%` 写配置，有的会在注册表写文件关联。判断方法很简单，看它有没有卸载项、配置是不是跟着程序目录走。

## 底层组件：这些不要随手卸

安装列表里有相当一部分不是「软件」，而是运行库、驱动和开发组件。看到一堆 VC++、.NET、SQL Server 条目不用慌，它们通常是别的程序依赖。

| 组件                            | 作用                                                | 建议                               |
| :------------------------------ | :-------------------------------------------------- | :--------------------------------- |
| Visual C++ 运行库 2010–2022     | 很多游戏和软件依赖，x86 与 x64 是两套               | 都留着，别看到重复就卸             |
| .NET Runtime 与 Desktop Runtime | C# 和 .NET 程序的运行基础，6、8、10 可能并存        | 按应用要求保留，旧版本不一定能替代 |
| NVIDIA 驱动组件                 | 显卡驱动、HD Audio、PhysX、FrameView 等             | 用 NVIDIA App 统一更新，别单独卸   |
| SQL Server 共享组件             | ODBC、OLE DB、Browser、Shared Management Objects    | 还在连 SQL Server 就留着           |
| WebView2                        | 很多应用内嵌的浏览器内核，Office 和各类客户端都会用 | 不要卸，卸了可能白屏               |
| Windows SDK 与 WPT              | 开发和性能分析工具，wpr、wpa 在里面                 | 不搞开发可以卸，搞开发就留         |
| Epic、XNA、VSTO 等依赖          | 游戏启动器或开发框架的前置组件                      | 不确定就先留，占用通常不大         |
| PawnIO                          | 硬件传感器驱动，FanControl 需要                     | 用 FanControl 就别卸               |

## 自己盘点一遍

看完别人的清单，最好能生成自己的。下面几条命令可以直接在 PowerShell 中运行。

### 用 winget 看已装软件

```powershell
winget list
winget upgrade
```

`winget` 是 Windows 自带的包管理器，能列出商店应用和传统桌面程序。`winget list` 看已经装了什么，`winget upgrade` 看哪些有更新。如果提示找不到命令，去商店安装「应用安装程序」。

### 用注册表补全卸载列表

```powershell
$paths = @(
  'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
  'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
Get-ItemProperty $paths -ErrorAction SilentlyContinue |
  Where-Object DisplayName |
  Sort-Object DisplayName |
  Select-Object DisplayName, DisplayVersion, Publisher, InstallLocation
```

三个路径分别对应 64 位程序、32 位程序和当前用户安装的程序。`Where-Object DisplayName` 过滤掉没有名字的更新补丁；`InstallLocation` 有时为空，说明安装器没写这个字段，不代表程序没装。

### 确认本机架构

```powershell
$env:PROCESSOR_ARCHITECTURE
Get-CimInstance Win32_Processor | Select-Object Name, Architecture
```

`AMD64` 是 x64，`ARM64` 是 ARM，`x86` 是 32 位。`Win32_Processor` 的 `Architecture` 里，9 表示 x64，12 表示 ARM64。

### 找便携软件

```powershell
Get-ChildItem 'D:\Program Files' -Recurse -Filter *.exe -File |
  Select-Object FullName
```

把路径换成你自己的便携软件目录即可。便携软件本质上就是 exe 文件。换一个目录就改路径；想找某个命令在哪，用 `where.exe 命令名`，它会列出 PATH 里所有同名程序。

### 用 Geek 导出清单

Geek 的导出功能会生成 HTML 清单。导出后按 Publisher 和安装位置筛一遍，比在设置里逐个翻快。

### 看一个程序到底装在哪

```powershell
Get-Command code | Select-Object Source
where.exe code
```

`Get-Command` 显示最终解析到的命令，`where.exe` 列出 PATH 里所有匹配项。两个结果不一致，通常说明装了两份，或者 PATH 里有一条旧路径。

## 怎么用这份清单

- **先按需求选，不要照着装一遍**。同类工具留一个，浏览器最多两三个，杀毒软件只留一个。
- **命令行工具优先 winget 或 scoop**，GUI 程序走官网安装包；下载页看清 x64、ARM64，别下错架构。
- **安装时选自定义**，取消捆绑勾选；能选「仅当前用户」就不必给管理员权限。
- **装 D 盘可以省 C 盘**，但卸载项仍在 C 盘；想要复制即用，选便携版。
- **定期 `winget upgrade`**，显卡驱动用 NVIDIA App 更新，别装来路不明的「驱动大师」。
- **商业使用先看许可证**。个人免费不等于商用免费，Bandizip、TeamSpeak、Unity 这类软件尤其要看清楚。
- **备份便携目录和 `%APPDATA%` 里的配置**，重装系统时能省很多重新配置的时间。

这份清单会随着机器变化继续改。下次重装时，先跑一遍上面的命令，再决定装什么。
