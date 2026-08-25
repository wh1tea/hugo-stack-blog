---
title: Oh My Posh 不显示 Conda 环境名：Python 段排查全流程
slug: oh-my-posh-python-segment
date: 2026-08-25T08:26:25+08:00
description: conda activate 后提示符不显示环境名，从 oh-my-posh debug 定位到 Python 段 display_mode 与 fetch_virtual_env 的根因，给出自定义主题副本修复与三场景实测。
tags:
  - oh-my-posh
  - conda
  - python
  - windows
  - pwsh
  - prompt
categories:
  - windows
---

`conda activate py_env` 之后，提示符纹丝不动：没有 `(py_env)`，没有 Python 图标。环境确实激活了（`python` 能解析到环境路径），但 Oh My Posh 就是不给面子。

本文面向 Windows + PowerShell 用户，完整走一遍从 `oh-my-posh debug` 定位、读源码找根因、自定义主题修复到三场景实测的过程。读完你能独立排查任何「段不显示」的问题。

## 现象：激活 Conda 环境后提示符无反应

环境：oh-my-posh 30.6.5（winget MSIX 安装）+ jandedobbeleer 主题 + conda 24.x + pwsh 7.6。

`conda activate py_env` 后 `CONDA_DEFAULT_ENV` 和 `CONDA_PREFIX` 都已正确设置，`python -c "import sys; print(sys.prefix)"` 也指向环境目录，但提示符完全不显示环境名。

## 第一步：oh-my-posh debug 定位

不要猜，先看段有没有启用：

```powershell
oh-my-posh debug
```

输出末尾的 Segments 表是关键：

```text
Path(true)          -   1 ms
Git(false)          -   1 ms
Node(false)         -   0 ms
Python(false)       -   1 ms
```

`Python(false)` 说明段压根没启用，不是渲染问题。`debug` 还会打印每个段的执行日志（`[DEBUG] ... segment: Python`），能直接看到它走了哪条判断分支。

## 第二步：读主题配置与源码，找根因

### 主题里的 Python 段长这样

v30 的主题段配置键是 `options`（网上老教程写的 `properties` 是旧结构）。jandedobbeleer 内置段：

```json
{
  "type": "python",
  "style": "powerline",
  "template": " \uE235 {{ if .Error }}{{ .Error }}{{ else }}{{ .Full }}{{ end }} ",
  "options": {
    "display_mode": "files",
    "fetch_virtual_env": false
  }
}
```

两个开关直接解释了现象：

- `display_mode: "files"`：只在当前目录出现 Python 文件或虚拟环境文件夹时显示，跟环境变量无关
- `fetch_virtual_env: false`：就算触发了，也不读 `VIRTUAL_ENV` / `CONDA_ENV_PATH` / `CONDA_DEFAULT_ENV`，`.Venv` 恒为空

### display_mode 四值

| 值          | 显示条件                                     |
| :---------- | :------------------------------------------- |
| `files`     | 目录里有 `.py` / `.ipynb` 或 `.venv`、`venv`、`virtualenv` 等文件夹（jandedobbeleer 内置默认） |
| `environment` | 虚拟环境激活时（`VIRTUAL_ENV` 或 `CONDA_DEFAULT_ENV` 等被设置） |
| `context`   | 上述两者任一                                   |
| `always`    | 永远显示                                     |

Conda 的 `CONDA_DEFAULT_ENV` 在 v30 源码里是认的，问题出在主题把 `display_mode` 设成了 `files`，Conda 环境变量根本不参与判断。

### 两个附加发现

- **pure 和 dracula 主题里根本没有 Python 段**：不是「默认不显示」，是压根没写。想显示环境名必须自己加段
- **网上教程的 `display_virtual_env` 是旧属性名**：v30.6.5 源码里对应开关叫 `fetch_virtual_env`，照抄旧教程会静默无效

## 第三步：修复——自定义主题副本

内置主题在 WindowsApps 目录下：只读，且 MSIX 每次升级都会换路径。正确做法是拷贝一份到用户目录再改，`--config` 指向全路径，升级不受影响。

```powershell
# 主题目录
mkdir $HOME\.config\oh-my-posh\themes
```

jandedobbeleer 补丁版，只改 Python 段的 `options` 和模板：

```json
{
  "type": "python",
  "style": "powerline",
  "template": " \uE235 {{ if .Venv }}{{ .Venv }}{{ else }}{{ .Full }}{{ end }} ",
  "options": {
    "display_mode": "environment",
    "fetch_virtual_env": true,
    "home_enabled": true
  }
}
```

`home_enabled: true` 必须加：默认 `false`，意味着在家目录（新终端默认位置）即使环境激活也不显示，这是最容易漏的坑。

dracula 没有段，就在 `node` 段后面插入同款段，配色与主题统一：

```json
{
  "type": "python",
  "style": "powerline",
  "powerline_symbol": "\uE0B0",
  "background": "#6272a4",
  "foreground": "#f8f8f2",
  "template": " \uE235 {{ if .Venv }}{{ .Venv }}{{ else }}{{ .Full }}{{ end }} ",
  "options": {
    "display_mode": "environment",
    "fetch_virtual_env": true,
    "home_enabled": true
  }
}
```

最后把 `$PROFILE` 里的 init 指向副本（主题名解析只认 MSIX 内置目录，自定义文件必须全路径）：

```powershell
oh-my-posh init pwsh --config "$HOME\.config\oh-my-posh\themes\dracula.omp.json" | Invoke-Expression
```

## 第四步：三场景实测验证

不依赖真实 conda 激活（interop 测试环境不干净），手动设环境变量模拟，逐场景跑 `oh-my-posh debug --config <副本路径>`：

| 场景                    | 设置                                | 结果         | 渲染            |
| :---------------------- | :---------------------------------- | :----------- | :-------------- |
| conda 激活 + 非家目录    | `CONDA_DEFAULT_ENV=py_env`          | `Python(true)`  | 提示符出现 `py_env` |
| conda 激活 + 家目录      | 同上，`Set-Location $HOME`          | `Python(true)`  | 正常显示（`home_enabled` 生效） |
| 无环境 + 非家目录        | 清空 `CONDA_*`                      | `Python(false)` | 不显示，行为正确 |

## 排查中的坑

- **WSL interop 下 conda hook 加载失败**：从 WSL 启动 `pwsh.exe` 时，profile 里的 `conda init` 钩子报「表达式不是有效命令」，测试环境不可信。干净的验证方式是手动设环境变量，别依赖真实激活
- **WindowsApps 目录在 WSL 里不可枚举**：拿不到主题文件路径，但 `oh-my-posh debug` 的输出里会打印解析出的主题路径，正则提出来即可
- **pwsh 执行策略挡住 WSL 路径脚本**：`\\wsl.localhost\...` 下的 `.ps1` 被判定未签名，加 `-ExecutionPolicy Bypass` 并把脚本拷到 `%TEMP%` 再跑

## 结语

根因一句话：jandedobbeleer 内置 Python 段的 `display_mode: "files"` + `fetch_virtual_env: false`，让段只认目录里的文件 / venv 文件夹，Conda 的 `CONDA_DEFAULT_ENV` 完全被无视；pure 和 dracula 则根本没有 Python 段。

行动建议：段不显示先用 `oh-my-posh debug` 看启用状态；查段配置时认准 v30 的 `options` 键和 `fetch_virtual_env` 属性名；主题修改一律走用户目录副本 + 全路径 `--config`，别动 WindowsApps 内置文件。

相关的提示符配置见 [终端提示符配置：让 Oh My Posh 显示 Conda 环境](terminal-theme-conda-prompt.md)（旧版方案，属性名已过时）；conda 激活后子命令报错的修复见 [conda activate 后报 invalid choice](../python/conda-pwsh-activate-fix.md)。

## 参考

- [Oh My Posh Python segment 文档](https://ohmyposh.dev/docs/segments/python)
- [oh-my-posh 源码 src/segments/python.go](https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/src/segments/python.go)
