---
title: WSL2 安装 Hermes Agent 排障
slug: hermes-agent-wsl2-install
date: 2026-05-14
description: 在 WSL2 Ubuntu 上用官方脚本安装 Hermes Agent，处理 Provider 选择、API 余额不足与模型 500 错误，直到能正常对话。
tags:
  - hermes-agent
  - wsl
  - troubleshooting
  - configuration
categories:
  - ai
---

在 Windows 的 WSL2（Ubuntu）里安装 Hermes Agent 时，官方一键脚本能搞定环境，但 Provider 与模型配置常卡在 API 密钥、余额和上游 500 错误上。本文按实际命令与报错，走完从安装到能对话的路径。

## 安装

WSL 终端执行：

```bash
sudo apt update
sudo apt install git -y
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
source ~/.bashrc
```

安装器通过 uv 自动准备 Python 3.11，不依赖系统 `python` 命令。装完后可用 `hermes doctor` 检查环境；多数 optional 依赖（如 telegram-bot、Playwright Chromium）可后续再装。

## 选择 Provider 与模型

首次运行会提示选择 Provider。优先选 **OpenRouter**：一个 API Key 可切换大量模型，配置成本低。

进入交互配置：

```bash
hermes model
```

或完整向导：

```bash
hermes setup
```

若直接配 DeepSeek，Base URL 保持默认 `https://api.deepseek.com/v1` 即可，按 Enter 确认。

把 OpenRouter Key 写进 `~/.hermes/.env`（或通过 `hermes config set OPENROUTER_API_KEY ...`）。确认当前凭证：

```bash
hermes auth list
```

## 常见失败与切换模型

### DeepSeek 402 Insufficient Balance

```text
HTTP 402: Insufficient Balance
Provider: deepseek Model: deepseek-reasoner
```

账号无余额。要么充值，要么立刻切回 OpenRouter。

### 免费模型持续 500

默认或 fallback 可能落到 `openrouter/owl-alpha` 或 `nvidia/nemotron-3-super-120b-a12b:free`，两者都曾出现：

```text
HTTP 500: Internal Server Error
```

免费端点不稳定时，不要反复重试。强制换成稳定模型：

```bash
hermes config set model anthropic/claude-3.5-sonnet
```

或

```bash
hermes config set model google/gemini-2.5-pro
hermes config set model openai/gpt-4o
```

改完后新开会话：

```bash
hermes
```

继续旧会话用 `hermes --resume <session-id>`。

### 其他检查

```bash
hermes doctor --fix
hermes config show
```

Playwright 浏览器工具若缺失，可在仓库目录执行：

```bash
cd ~/.hermes/hermes-agent && npx playwright install --with-deps chromium
```

## 结语

安装本身只需一条 curl；真正耗时的是 Provider 与模型是否可用。优先 OpenRouter + 付费稳定模型，遇到 402 或持续 500 就立刻 `hermes config set model ...` 换掉，不要死磕免费端点。配置落在 `~/.hermes/.env` 与 `config.yaml`，随时可用 `hermes model` 重配。
