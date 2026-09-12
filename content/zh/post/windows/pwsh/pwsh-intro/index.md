---
title: PowerShell 7 入门与配置
slug: pwsh-intro
date: 2026-07-12T00:00:00+08:00
description: 介绍 PowerShell 7 与 5.1 的区别，整理一份实用配置文件，涵盖 oh-my-posh 提示符、x-cmd 集成与 conda 兼容性修复
tags:
  - pwsh
  - terminal
  - oh-my-posh
  - conda
categories:
  - windows
---

## 引言

你还在用 Windows 自带的“蓝色窗口”吗？那其实是 **Windows PowerShell 5.1**，一个已经停更多年的版本。**PowerShell 7**（命令为 `pwsh`）是它的继任者，跨平台、性能更强，并且能与旧版并行运行。本文带你快速了解 PowerShell 7，并整理一份实用的配置文件指南，帮你打造顺手的终端环境。非常推荐的阅读[**What is a command shell?**](https://learn.microsoft.com/en-us/powershell/utility-modules/aishell/concepts/what-is-a-command-shell?view=ps-modules)

## 一、PowerShell 7 是什么

PowerShell 7 与 Windows PowerShell 5.1 最根本的区别在于底层运行时：5.1 基于 .NET Framework，而 PowerShell 7 基于 **.NET Core**（后续版本基于 .NET 5+）。这意味着它能在 Windows、macOS、Linux 上运行，并且可执行文件名从 `powershell.exe` 改成了 `pwsh.exe`，方便两个版本共存。

### 安装与启动

从 GitHub Releases 或 Microsoft Store 安装后，在终端输入 `pwsh` 即可进入。输入 `exit` 退出。

如果你想**不加载任何配置文件**启动一个纯净会话（排查配置问题时非常有用），使用：

```powershell
pwsh -NoProfile
```

## 二、配置文件是什么

PowerShell 配置文件是在每次启动时自动执行的脚本。你可以把别名、函数、变量、模块导入等自定义内容放进去，让它们在所有会话中生效。

配置文件有多个位置，`$PROFILE` 变量指向的是**当前用户、当前主机**的配置文件，通常位于：

```text
$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

注意：PowerShell 7 和 Windows PowerShell 5.1 的配置文件**是分开存放的**，互不影响。用记事本快速编辑：

```powershell
notepad $PROFILE
```

如果文件不存在，记事本会提示创建，选择“是”即可。

## 三、一份实用的配置文件

下面这份配置涵盖了 oh-my-posh 提示符、x-cmd 集成，以及一个针对 conda 的兼容性修复。

### 1. oh-my-posh 提示符初始化

oh-my-posh 是当前最流行的 PowerShell 提示符美化工具，可以显示 Git 状态、Python 环境、路径等信息。

```powershell
oh-my-posh init pwsh --config 'dracula' | Invoke-Expression
```

**做了什么**：让 oh-my-posh 用指定的主题文件（`dracula`）初始化提示符。你可以换成其他主题文件，或者用 `oh-my-posh init pwsh | Invoke-Expression` 使用默认主题。`dracula`不支持`conda`补丁版教程见[此处](......\ohmyposh\terminal-theme-conda-prompt.md)

### 2. conda 兼容性修复（关键）

如果你使用 conda 管理 Python 环境，并且 PowerShell 版本是 **7.5 及以上**，很可能会遇到 `conda activate` 报错：

```text
error: argument COMMAND: invalid choice: ''
```

**原因**：PowerShell 7.5 改变了空环境变量的传递方式。conda 内部依赖两个环境变量 `_CE_M` 和 `_CE_CONDA`，在旧版 PowerShell 中它们被设为空字符串时会被“丢弃”，但在 7.5+ 中空字符串会被**如实传递给 conda 子进程**，导致 conda 把空字符串当成命令名来解析。

**修复**：在配置文件中加入：

```powershell
$PSNativeCommandArgumentPassing = 'Legacy'
```

这行设置让 PowerShell 恢复旧版的行为：**丢弃空字符串参数**，conda 就能正常工作了。

> **更彻底的方案**：将 conda 升级到 **25.1.1 或更高版本**，该版本已官方修复此问题，不再需要这行配置。

## 四、完整配置文件一览

```powershell
# ══ oh-my-posh 提示符 ═══════════════════════════════════════
# 自定义主题目录: ~\.config\oh-my-posh\themes\ (内置主题在 WindowsApps 只读且升级会换路径, 勿直接改)
# 已备补丁版: dracula.omp.json (python 段已修: conda 环境显示 + home 目录可见)
# 切换: 改下面 --config 后的文件名即可 (jandedobbeleer / dracula)
oh-my-posh init pwsh --config "$HOME\.config\oh-my-posh\themes\dracula.omp.json" | Invoke-Expression

# ══ conda 兼容性修复 ═══════════════════════════════════════
# PowerShell 7.5+ 将空字符串如实传给 conda，导致 invalid choice 错误
# 恢复 Legacy 行为：丢弃空字符串参数
$PSNativeCommandArgumentPassing = 'Legacy'
```

## 结语

PowerShell 7 是 Windows 终端体验的一次实质升级。核心要点有三：**用 `pwsh` 启动**、**配置文件位于 `$PROFILE`**、**conda 用户注意 PowerShell 7.5 的兼容性修复**。

如果你刚接触，建议先安装 `pwsh`，用 `pwsh -NoProfile` 体验一下默认状态，再逐步把上面的配置按需加入自己的 `$PROFILE`。
