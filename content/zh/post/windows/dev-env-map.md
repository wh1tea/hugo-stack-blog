---
title: Windows 开发环境
slug: dev-env-map
date: 2026-11-01T15:05:00+08:00
description:  Windows 环境：运行时归谁管、包管理器怎么分工、PATH 里每条路径的存在理由，附四个真实的版本与 PATH 坑。
tags:
  - windows
  - environment
  - conda
  - nodejs
categories:
  - windows
draft: true
---

`where.exe` 对同一条命令给出两三个结果，通常不是没装，而是几套系统在各自往 PATH 里塞东西。下面把每层的版本、来源、位置摊开，再说明 PATH 里那一条为什么存在。

## 分层总览

| 层        | 命令                                                         | 版本                                            | 来源                     | 位置                                                         |
| :-------- | ------------------------------------------------------------ | :---------------------------------------------- | :----------------------- | :----------------------------------------------------------- |
| Python    | `conda -v`/`python -v`/`conda env list`                      | base 3.12.4 · py_env 3.12.13 · pixel_rpg 3.9.23 | conda                    | `D:\ProgramData\anaconda3`、`%USERPROFILE%\.conda\envs`      |
| Node      | `nvm -v`/`nvm list`/`node -v`/`npm -v`                       | 22.23.4                                         | nvm-windows 2.1.0-beta.6 | `%LOCALAPPDATA%\Author Software\nvm`                         |
| JVM       | `java -version`/`javac -version`                             | Temurin 21.0.8                                  | 官方 MSI                 | `C:\Program Files\Eclipse Adoptium`                          |
| Go        | `go version`                                                 | 1.26.5                                          | 官方 MSI                 | `C:\Program Files\Go`                                        |
| .NET      | `dotnet --list-sdks`/`dotnet --list-runtimes`/`dotnet --version`/`dotnet --info` | SDK 10.0.403 · 6.0.428                          | 官方 MSI                 | `C:\Program Files\dotnet`                                    |
| Container | `docker -v`/`docker version`/`docker info`                   | Docker 29.9.1                                   | Docker Desktop           | `C:\Program Files\Docker`                                    |
| Editor    | `code -v`/`webstorm -v`                                      | VS Code · WebStorm 2026.2                       | 用户安装器               | `%LOCALAPPDATA%\Programs\Microsoft VS Code`、`D:\Program Files\JetBrains` |
| Terminal  | `pwsh -v`/`oh-my-posh version`                               | PowerShell 7.6.9 + oh-my-posh 30.6.5            | —                        | `C:\Program Files\PowerShell\7`                              |

## 运行时

三个 Python 环境的分工：`base` 本该只放 conda 自身，实际装了 402 个 pip 包——这是本机最该盯的指标；`py_env` 放数据处理与脚本（pandas、matplotlib、ruamel.yaml），`pixel_rpg` 是 3.9 时代的像素游戏项目。

Node 只留两个版本，22.23.4 走日常，26.13.0 备用。`pnpm`、`yarn` 不占全局安装，`.nodejs` 里的 shim 由 corepack 按需拉取（pnpm 12.16.1、yarn 1.22.22），全局包只有 npm 10.9.9 本身。

.NET 那两个 SDK 里，6.0.428 已停止支持，只为旧项目留着；Docker 装了但 daemon 默认不开，需要时再启动。

## 包管理器分工

| 渠道   | 该装什么             | 本机现状                                |
| :----- | :------------------- | :-------------------------------------- |
| winget | GUI 程序与少量 CLI   | Hugo 0.168、VS Code、WebStorm、Bandizip |
| scoop  | CLI 小工具           | sass 1.106.1、编程字体，共 2 个包       |
| choco  | 需要编译环境或驱动的 | VS 2022 Build Tools 等 18 个包          |

三套并存本身没问题，判据是**同一个程序只能有一个来源**，装了两遍就删一个。语言运行时例外，各自交给 conda、nvm 和官方 MSI。

## PATH 的构成

用户级 13 条、机器级 29 条，按用途分四类：

| 类别          | 典型条目                                       | 该不该在 PATH 里                      |
| :------------ | :--------------------------------------------- | :------------------------------------ |
| 版本切换入口  | `...\nvm`、`...\nvm\.nodejs`                   | 在，但只放 junction，不放具体版本目录 |
| 包管理器 shim | `scoop\shims`、`chocolatey\bin`、`WindowsApps` | 在，固定目录，装多少包都只占一条      |
| 运行时自带    | anaconda3 的 4 条、`Go\bin`、Adoptium 的 `bin` | 在，由安装器写机器级                  |
| IDE / GUI     | VS Code、WebStorm、GitHub Desktop、Obsidian    | 在，只影响命令行启动                  |

数字会变，判据不会：**每条都该是「分发目录」，不能是「版本目录」**。像 `installs\v22.23.4` 这种路径一旦进了 PATH，换版本就得改 PATH。

查失效条目：

```powershell
$path = [Environment]::GetEnvironmentVariable('Path', 'User') + ';' +
        [Environment]::GetEnvironmentVariable('Path', 'Machine')
$path -split ';' | Where-Object { $_ -and -not (Test-Path -LiteralPath $_.TrimEnd('\')) }
```

当前命中 2 条，都在机器级（Maven、Cursor），改动需要管理员权限。

## 四个坑

**IDE 升级会追加 PATH，旧条目不删。** WebStorm 在本机先后写过 2024.1.5、2026.1、2026.2 三条，前两条随卸载失效。只把 `D:\Tools\jetbrains\current` 这类 junction 放进 PATH、升级时改 junction 目标，可以避免累积。

**choco 的 `python` 是元包。** 它会连带装上 `python3`、`python314`；卸载要管理员，中途失败会留下一个只有 `Lib`、`Scripts` 的 `C:\Python314`（没有 `python.exe`）和指向它的 `python3.14.exe` shim。

**`conda clean` 释放不了 `pkgs` 目录。** 那 2.6 GB 与 `base` 环境硬链接共享，`conda clean -a` 只清 tarball，本机实测回收 275 MB。

**卸载 GUI 程序不会清 PATH。** Ollama、TeX Live、Cursor 卸载后各留一条失效路径，只有主动排查才会发现。

## 结语

判断环境有没有装重，先看 `where.exe` 返回几个来源。运行时只留一个管理者，PATH 只放分发目录，剩下的交给各自的 shim。
