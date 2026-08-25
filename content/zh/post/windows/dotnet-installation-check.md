---
title: .NET 安装与版本管理完全指南
slug: dotnet-installation-check
date: 2026-08-19T10:00:00+08:00
description: 详解如何检查 .NET 是否已安装、管理多个版本、辨别生命周期状态，并安全升级或卸载旧版本。
tags:
  - dotnet
  - sdk
  - runtime
  - windows
categories:
  - windows
---

本文面向有编程基础的开发者，旨在帮助你在 Windows / macOS / Linux 上快速确认 .NET 环境状态，理解版本号含义，并做出合理的升级决策。读完本文，你将能独立检查 .NET 安装、判断版本是否过时，并安全地清理旧版本。起因是台式电脑风扇出问题了需要通过[FanControl](https://getfancontrol.com/)去调控风扇，而FanControl需要.NET 10的支持。

## 检查 .NET 是否已安装

最通用的方法是使用终端（命令提示符 / PowerShell / bash）执行 `dotnet` 命令。

```bash
# 列出所有已安装的 SDK
dotnet --list-sdks

# 列出所有已安装的运行时（包括 ASP.NET Core 和 .NET Core）
dotnet --list-runtimes

# 查看当前默认使用的 SDK 版本
dotnet --version

# 输出详细的环境信息（操作系统、路径等）
dotnet --info
```

如果终端返回版本号列表，说明已安装；若提示“`dotnet` 不是内部或外部命令”，则未安装。

> **注意**：上述命令仅适用于 .NET Core / .NET 5+（即现代 .NET），不适用于传统的 .NET Framework（4.x 及以下）。检查 .NET Framework 需通过控制面板或注册表。

## 理解版本号与生命周期

你可能会看到类似 `6.0.428` 这样的版本号，其格式为 `主版本.次版本.补丁号`。微软为每个主版本设定明确的支持期限：

| 版本 | 支持类型 | 结束日期（EOL） | 当前状态（2026-08） |
| :--- | :--- | :--- | :--- |
| .NET 6 | LTS（长期支持） | 2024-11-12 | 已停止支持，建议立即升级 |
| .NET 7 | STS（标准支持） | 2024-05-14 | 已停止支持 |
| .NET 8 | LTS | 2026-11-10 | 仍在支持，但即将到期 |
| .NET 9 | STS | 2026-05-12 | 已停止支持 |
| .NET 10 | LTS | 2027-11-09 | 最新 LTS，强烈推荐 |

**关键原则**：始终使用处于支持生命周期内的 LTS 版本（当前为 .NET 10 和 .NET 8），以确保获得安全更新和修复。

## 升级与卸载策略

### 何时需要升级？

- 你当前使用的版本已 EOL（如 .NET 6、7、9）。
- 你的项目需要利用新语言特性或性能改进。
- 你希望在 CI/CD 环境中保持依赖最新。

### 安装新版本

官方下载地址：[https://dotnet.microsoft.com/download](https://dotnet.microsoft.com/download)

使用包管理器（推荐）：

```bash
# Windows (winget)
winget install Microsoft.DotNet.SDK.10

# macOS (Homebrew)
brew install dotnet-sdk

# Ubuntu/Debian (apt)
sudo apt install dotnet-sdk-10.0
```

### 安全卸载旧版本

旧版本会占用磁盘空间，且可能带来安全风险。卸载前请确认：

1. **检查项目是否锁定旧版本**：在项目根目录执行 `findstr /s /i /m "<TargetFramework>net6.0" *.csproj`，若有输出则需先修改目标框架。
2. **检查 `global.json`**：若存在且指定了旧 SDK 版本，需更新或删除该文件。

卸载方式：

- **图形界面**：通过“添加或删除程序”（Windows）或对应包管理器移除。
- **命令行**：使用微软官方卸载工具 `dotnet-core-uninstall`（[GitHub 发布页](https://github.com/dotnet/cli-lab/releases)）：

```bash
# 列出可卸载的 SDK 和运行时
dotnet-core-uninstall list

# 移除指定 SDK
dotnet-core-uninstall remove --sdk 6.0.428

# 移除指定运行时
dotnet-core-uninstall remove --runtime 6.0.36
```

> ⚠️ **特别注意**：若在 Windows 上使用 IIS 托管网站，卸载 .NET 6 的托管捆绑包可能误删共享组件，导致 IIS 网站 500 错误。建议先停止 IIS 或迁移所有站点至新版。

## 多版本共存与默认版本管理

安装多个 .NET 版本是常态。`dotnet` 命令默认选择最高已安装版本，但你可通过 `global.json` 锁定特定版本。

```json
{
  "sdk": {
    "version": "10.0.400"
  }
}
```

同时，运行时（runtime）的向前兼容性较好，.NET 8 应用可以在只安装 .NET 10 的环境下运行（通过 `rollForward` 策略），但并非所有情况都能无缝替代。若应用明确依赖旧运行时，建议保留该运行时。

## 结语

定期检查和更新 .NET 环境是保障开发安全和效率的基础操作。记住：

- 使用 `dotnet --list-sdks` / `--list-runtimes` 快速查看已安装版本。
- 避免使用已停止支持的版本（如 .NET 6、7、9）。
- 安装新版本前先备份项目，确保 `global.json` 和项目目标框架与新版本兼容。
- 卸载旧版本时，务必确认无项目依赖，并谨慎处理 IIS 场景。

现在，请运行 `dotnet --info` 查看你的环境，并根据输出采取相应行动。

## 参考

- [.NET介绍](https://learn.microsoft.com/zh-cn/dotnet/core/introduction)
- [.NET 官方下载页](https://dotnet.microsoft.com/download)
- [.NET 生命周期政策](https://dotnet.microsoft.com/en-us/platform/support/policy/dotnet-core)
- [dotnet-core-uninstall 工具](https://github.com/dotnet/cli-lab)
