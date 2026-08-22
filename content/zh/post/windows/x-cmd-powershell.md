---
title: 在 PowerShell 中配置 x-cmd 并设置主题
slug: x-cmd-powershell
date: 2026-08-22T16:00:00+08:00
description: 在 PowerShell 中安装配置 x-cmd 并设置 Oh My Posh 或 Starship 终端主题的完整指南。
tags:
  - powershell
  - x-cmd
  - terminal
  - theme
  - oh-my-posh
  - starship
  - pwsh
categories:
  - windows
---

## 一、安装 x-cmd

在 PowerShell 中使用 x-cmd，目前需要通过 Git-Bash 调用。官方提供了一键安装脚本，会自动处理依赖和配置。

在 **PowerShell** 终端中执行以下命令：

```powershell
[System.Text.Encoding]::GetEncoding("utf-8").GetString($(Invoke-WebRequest -Uri "https://get.x-cmd.com/x-cmd.ps1").RawContentStream.ToArray()) | Invoke-Expression
```

这条命令会自动下载安装 Git-Bash 和 x-cmd，并执行 `x pwsh --setup` 完成 PowerShell 环境配置（安装目录为 `~/.x-cmd.root`，不会污染系统全局）。

> **提示**：如果 PowerShell 默认执行策略为 `Restricted`，需要先调整策略允许运行脚本：
>
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

安装完成后，**重启 PowerShell**，x-cmd 就会自动加载。

---

## 二、配置 PowerShell 环境（x pwsh --setup）

安装脚本已自动执行 `x pwsh --setup`，你也可以在 PowerShell 中手动执行该命令（通常无需重复执行）。

`x pwsh --setup` 会在 PowerShell 配置文件（`Microsoft.PowerShell_profile.ps1`）中注入以下启动代码：

```powershell
if (Test-Path "$Home\.x-cmd.root\local\data\pwsh\_index.ps1") {
    Set-ExecutionPolicy Bypass -Scope Process
    . "$Home\.x-cmd.root\local\data\pwsh\_index.ps1"
}; # boot up x-cmd.
```

- `Set-ExecutionPolicy Bypass -Scope Process`：仅对当前进程临时绕过执行策略，确保脚本顺利运行
- `. "$Home\...\_index.ps1"`：加载 x-cmd 主程序

以后每次打开 PowerShell，x-cmd 的环境都会自动就绪。

---

## 三、设置终端主题

`x theme` 模块虽然主要支持 POSIX Shell，但 PowerShell 用户可以通过 **Oh My Posh** 和 **Starship** 获得同样惊艳的视觉效果。

自 x-cmd v0.5.7 beta 起，`ohmyposh` 和 `starship` 模块已正式支持 PowerShell。

> **选择建议**：Oh My Posh 主题丰富、高度可定制，适合追求个性化界面的用户；Starship 更轻量、配置简洁，适合偏好极简风格的用户。您可根据偏好任选其一。

### 方式一：使用 Oh My Posh（推荐）

Oh My Posh 是用 Go 编写的跨平台终端美化工具，支持 PowerShell、bash、zsh 等多种 Shell。

**应用 Dracula 主题**（在 PowerShell 中可直接省略 `--shell powershell`，模块会自动识别当前 Shell）：

```bash
x ohmyposh use dracula
```

**应用其他主题**（如 `montys`）：

```bash
x ohmyposh use montys
```

**查看所有可用主题**：

```bash
x ohmyposh ls
```

**查看当前主题**：

```bash
x ohmyposh current
```

**禁用主题**（恢复默认提示符）：

```bash
x ohmyposh disable
```

> 该命令会将主题配置写入 x-cmd 的本地状态（`~/.x-cmd.root/local/data/ohmyposh/current`），并在每次 PowerShell 启动时自动加载，无需额外设置。

### 方式二：使用 Starship

Starship 是 Rust 编写的跨 Shell 提示符，同样支持 Dracula 风格。

**应用主题**（主题名以 `x starship ls` 列出的为准，以下为示例）：

```bash
x starship use pastel-powerline
```

**查看所有可用主题**：

```bash
x starship ls
```

**禁用主题**：

```bash
x starship disable
```

> **注意**：Oh My Posh 和 Starship 的 Dracula 风格主题都需要安装 **Nerd Fonts** 才能完整显示所有图标。推荐安装 [Meslo Nerd Font](https://github.com/ryanoasis/nerd-fonts) 并在终端中设置使用。

---

## 四、常见问题

**Q：x-cmd 命令在 PowerShell 中无法识别？**

检查执行策略：`Get-ExecutionPolicy -List`，确保不是 `Restricted`。执行 `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` 调整。

**Q：@ 开头的命令无法使用？**

PowerShell 中 `@` 有特殊含义，x-cmd 已将 `@gpt`、`@gemini` 等命令改为 `a:gpt`、`a:gemini`（`a:` 表示 alias 前缀），在 PowerShell 中使用 `a:` 替代即可。

**Q：主题图标显示为方块？**

安装 Nerd Fonts 并在终端的字体设置中选用该字体。

**Q：如何恢复默认提示符？**

执行 `x ohmyposh disable` 或 `x starship disable` 即可禁用主题。

---

## 五、结语

在 PowerShell 中配置 x-cmd 只需一条安装命令，`x pwsh --setup` 自动完成环境注入。主题方面，`x ohmyposh use dracula` 一键应用主题，让终端兼具效率与美感。

**行动建议**：

1. 执行一键安装命令
2. 重启 PowerShell 验证 x-cmd 可用
3. 运行 `x ohmyposh use dracula` 应用主题
4. 安装 Nerd Fonts 获得完整图标体验

---

## 参考

- [x-cmd 官方文档 — PowerShell](https://cn.x-cmd.com/start/powershell)
- [x-cmd v0.5.7 发布说明](https://www.x-cmd.com/blog/250316/)
- [x-cmd ohmyposh 模块文档](https://cn.x-cmd.com/mod/ohmyposh)
- [Oh My Posh 官方文档](https://ohmyposh.dev/)
