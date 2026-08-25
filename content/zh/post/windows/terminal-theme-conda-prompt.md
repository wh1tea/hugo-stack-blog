---
title: 终端提示符配置：让 Oh My Posh 显示 Conda 环境与主题推荐
slug: terminal-theme-conda-prompt
date: 2026-08-23T14:30:00+08:00
description: 配置 Oh My Posh 在 Dracula 主题中显示 Conda 环境名，附带 Oh My Bash 主题推荐与恢复默认的方法。
tags:
  - wsl
  - terminal
  - oh-my-posh
  - oh-my-bash
  - conda
  - prompt
categories:
  - windows
---

终端提示符是开发者每天面对最多的界面元素。一个好的提示符不仅能展示 Git 分支、Python 虚拟环境等关键信息，还能提升工作效率。

本文解决两个场景的问题：

- **Windows / WSL 用户**：使用 Oh My Posh 主题，让提示符显示当前 Conda 环境名（如 `(py_env)`），并避免与 Conda 自带提示重复。
- **Linux / macOS 用户**：在 Oh My Bash 中挑选合适的主题，以及如何恢复默认提示符。

读完本文后，你将能根据自己的终端环境完成配置，并理解故障排查的基本思路。

---

## Oh My Posh：让 Dracula 主题显示 Conda 环境

Oh My Posh 的 Dracula 主题默认不显示 Conda 环境名。核心解决思路是修改主题配置文件，为 `python` segment 添加正确的属性。

### 定位并备份主题文件

首先找到 Dracula 主题的配置文件 `dracula.omp.json`：

- **常见位置**：`C:\Users\<你的用户名>\AppData\Local\Programs\oh-my-posh\themes\`
- **查找方法**：在 PowerShell 中运行 `Get-PoshThemes`，可以列出所有主题及其路径

**操作前请先备份**该文件，以防修改出错。

### 添加配置代码

用代码编辑器（如 VS Code）打开 `dracula.omp.json`，在 `"blocks"` 数组中找到想让 Conda 环境名显示的位置（通常在 `path` 或 `git` 信息附近），在对应的 `"segments"` 数组中添加或修改一个 `"type": "python"` 的配置段：

```json
{
  "type": "python",
  "style": "plain",
  "foreground": "#98C379",
  "properties": {
    "display_mode": "environment",
    "display_virtual_env": true,
    "display_version": false,
    "home_enabled": true,
    "prefix": "(",
    "postfix": ") "
  }
}
```

**配置项说明**：

| 字段                                 | 说明                                                |
| :----------------------------------- | :-------------------------------------------------- |
| `"type": "python"`                   | 告诉 Oh My Posh 这是一个 Python 相关的段            |
| `"style": "plain"`                   | 纯文本样式，与 Dracula 主题风格融合                 |
| `"foreground": "#98C379"`            | 柔和绿色，与 Dracula 主题搭配                       |
| `"display_mode": "environment"`      | **核心设置**，显示环境名而非 Python 版本            |
| `"display_virtual_env": true`        | 启用虚拟环境名显示（Conda 环境也属于此类）          |
| `"display_version": false`           | 隐藏 Python 版本号，避免与环境名重复                |
| `"home_enabled": true`               | 确保在用户主目录下也能显示                          |
| `"prefix": "("` 和 `"postfix": ") "` | 控制显示格式，如 `(py_env)`                         |

保存文件后，**重启终端**（PowerShell 或 Windows Terminal）即可生效。

### 验证与故障排查

如果修改后未生效，按以下步骤检查：

1. **运行诊断命令**：在 PowerShell 中执行 `oh-my-posh debug`，检查输出中 `python` segment 是否有错误信息。
2. **确认 Conda 已初始化**：确保在 PowerShell 中能正常执行 `conda activate <环境名>`。
3. **检查主题文件路径**：确认 PowerShell 配置文件（`$PROFILE`）中 `oh-my-posh init ... --config` 命令指向的是修改后的 `dracula.omp.json`。
4. **检查 Conda 设置**：运行 `conda config --show changeps1`，确保值为 `False`。如果不是，执行 `conda config --set changeps1 False` 关闭 Conda 自带的提示符修改。
5. **备选配置**：如果上述配置无效，可尝试以下简化方案：

```json
{
  "type": "python",
  "style": "plain",
  "foreground": "#98C379",
  "properties": {
    "display_virtual_env": true,
    "display_version": false,
    "home_enabled": true,
    "prefix": "(",
    "postfix": ") "
  }
}
```

该配置通过 `"display_virtual_env": true` 显示环境名，并用 `"display_version": false` 隐藏版本号。

### 避免重复显示 `(base)`

有时会出现两个 `(base)` 同时显示，原因是 Conda 自身和 Oh My Posh 都在提示符中显示了环境名。

**解决方法**：调整 PowerShell 配置文件的加载顺序。确保 `conda init` 的初始化代码在 `oh-my-posh init` **之前**执行，这样 Oh My Posh 后定义的 `prompt` 函数会覆盖 Conda 的提示符，避免重复显示。在 `$PROFILE` 文件中调整这两行代码的顺序即可。

---

## Oh My Bash：主题推荐与切换

Oh My Bash 内置了超过 100 款主题，从极简到华丽，选择丰富。

### 热门主题推荐

| 主题名称      | 风格特点                 | 核心功能                                     | 注意事项                                      |
| :------------ | :----------------------- | :------------------------------------------- | :-------------------------------------------- |
| **agnoster**  | 现代化、色彩丰富、分段式 | 显示完整路径、Git 状态、命令执行状态         | **需要安装 Powerline 字体**，否则可能显示乱码 |
| **powerline** | 类似 Powerline 风格      | 分段显示路径，信息一目了然                   | 同样需要 Powerline 字体支持                   |
| **roderik**   | 彩色显示                 | 显示完整路径，包含 Git 状态信息              | —                                             |
| **font**      | 极简、克制（默认主题）   | 只显示用户名、主机名和当前目录名             | 适合喜欢极致简洁的用户                        |
| **purity**    | 干净、信息聚焦           | 可自定义扩展，例如显示 Python、Go、Java 环境 | 适合需要多语言环境提示的开发者                |
| **morris**    | 传统、清晰               | 提示符风格传统，易于阅读和复制               | 适合偏好经典风格的用户                        |

### 切换主题的步骤

1. 打开 Bash 配置文件 `~/.bashrc`。
2. 找到 `OSH_THEME` 变量，将主题名称填入，例如：

   ```bash
   OSH_THEME="agnoster"
   ```

3. 保存文件后执行 `source ~/.bashrc` 使更改生效。

**小技巧**：

- 如果拿不定主意，可以设置 `OSH_THEME="random"`，每次打开终端随机切换主题。
- 通过 `OMB_THEME_RANDOM_CANDIDATES` 和 `OMB_THEME_RANDOM_IGNORED` 两个变量，控制随机主题的候选范围或排除不喜欢的主题。

### 如何发现更多主题

- **官方 Wiki**：Oh My Bash 官方 Wiki 上有所有主题的截图和详细说明，是挑选主题的最佳去处。
- **社区分享**：GitHub 等社区有许多开发者分享的自用或修改主题。
- **主题切换器**：可使用社区开发的 `oh-my-bash-theme-switcher` 工具，在终端里模糊搜索并快速切换主题。

---

## 恢复默认提示符

如果想停止使用主题，恢复到默认的 Bash 样式，有以下几种方法：

### 方法一：切换回默认主题（最推荐）

保留 Oh My Bash 框架，仅将主题换回默认的 `font`：

1. 编辑 `~/.bashrc`，将 `OSH_THEME` 修改为：

   ```bash
   OSH_THEME="font"
   ```

2. 执行 `source ~/.bashrc` 生效。

### 方法二：恢复原始 `.bashrc` 备份

想完全回到安装 Oh My Bash 之前的状态，可使用安装时自动生成的备份文件：

1. 查找备份文件：

   ```bash
   ls ~/.bashrc.omb-*
   ```

   会看到类似 `~/.bashrc.omb-20230520-123456` 的文件。

2. 用备份文件覆盖当前 `.bashrc`（**将时间戳替换为实际文件名**）：

   ```bash
   cp ~/.bashrc.omb-时间戳 ~/.bashrc
   ```

3. 执行 `source ~/.bashrc` 生效。

### 方法三：完全卸载 Oh My Bash

如果想彻底移除 Oh My Bash 及其所有配置，运行自带卸载脚本：

```bash
uninstall_oh_my_bash
```

该命令会自动清理并恢复原始 `.bashrc` 文件。

---

## 结语

终端提示符配置看似琐碎，但直接影响日常开发体验。本文提供了两个主流终端美化工具的关键配置方法：

- **Oh My Posh（Windows / WSL）**：通过修改 Dracula 主题的 `python` segment，让 Conda 环境名正确显示；调整加载顺序避免重复；并提供完整的故障排查步骤。
- **Oh My Bash（Linux / macOS）**：推荐了 6 款常用主题及其适用场景；三种方法可随时恢复默认提示符。

**行动建议**：先备份配置文件再动手修改；遇到问题优先运行 `oh-my-posh debug` 或检查 `$PROFILE` 加载顺序；主题选择以实用为主，不必追求过度复杂。

---

## 参考

- [Oh My Posh 官方文档](https://ohmyposh.dev/docs)
- [Oh My Bash 官方仓库](https://github.com/ohmybash/oh-my-bash)
- [Conda 官方文档 — 提示符配置](https://docs.conda.io/en/latest/)
