---
title: Hermes Agent 完全指南：安装、配置与模型推荐
date: 2026-07-14
description: Hermes Agent 是 Nous Research 开源的多平台 AI 智能体框架，支持 20+ LLM 提供商和 Telegram/Discord 等即时通讯平台。本文从零开始讲解安装、配置、核心功能，并推荐市面上值得使用的模型。
tags:
  - ai
  - hermes-agent
  - llm
  - cli
  - tool
  - devops
  - productivity
categories:
  - ai
---

> 如果你厌倦了网页版 ChatGPT 的频繁中断、复制粘贴的痛苦，想要一个**真正在终端里帮你干活**的 AI 助手——Hermes Agent 可能是你一直在找的东西。

---

## 一、Hermes Agent 是什么？

Hermes Agent 由 [Nous Research](https://nousresearch.com/) 开源，属于 **AI 编程/任务执行智能体（Agent）** 这个品类，与 Anthropic 的 Claude Code、OpenAI 的 Codex CLI 同类。但它有一个关键区别：

**Hermes 不绑定任何特定模型。**

你可以用 Anthropic、OpenAI、DeepSeek、本地模型、甚至是国内的大模型（阿里 Qwen、智谱 GLM、Kimi、MiniMax）来驱动它。同一套工具、同一套配置，换模型就像换衣服一样简单。

核心特性：

| 特性       | 说明                                                 |
| ---------- | ---------------------------------------------------- |
| 多提供商   | 20+ LLM 提供商自由切换，账号池自动轮转               |
| 技能系统   | 可以记住工作流，下次自动复用（Self-Improving）       |
| 持久记忆   | 跨会话记住你的偏好、环境信息、项目约定               |
| 多平台网关 | Telegram / Discord / Slack / 微信 / 邮件等平台都能用 |
| 子智能体   | 可以派生子 Agent 并行干活（delegate_task）           |
| 定时任务   | 内置 Cron 调度器，定时执行复杂工作流                 |
| MCP 协议   | 支持 Model Context Protocol，连接外部工具            |
| 配置文件   | 多 Profile 隔离，工作环境互不干扰                    |

**适用人群：**

- 开发者：代码审查、重构、调试、自动化部署
- 运维：服务器管理、日志分析、监控告警
- 研究者：论文检索、数据整理、实验管理
- 任何需要终端 + AI 的场景

---

## 二、安装 Hermes Agent

### 2.1 一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash
```

安装脚本会自动检测操作系统，下载对应二进制文件，并完成基础配置。

### 2.2 验证安装

```bash
hermes --version
hermes doctor    # 检查依赖和环境
```

`hermes doctor` 会告诉你哪些组件就绪、哪些缺少，是排查问题的第一站。

### 2.3 安装位置

Hermes 的所有数据和配置都在 `~/.hermes/` 目录下：

```bash
~/.hermes/
├── config.yaml      # 主配置文件
├── .env             # API 密钥和 secrets
├── skills/          # 安装的技能
├── sessions/        # 会话记录
├── logs/            # 网关和错误日志
└── auth.json        # OAuth 令牌和凭据池
```

### 2.4 Windows (WSL) 注意事项

如果你在 WSL 上安装，一切正常运行。几个已知坑：

- **配置文件不要用 Notepad 编辑**——Windows 默认保存 UTF-8 BOM，会导致 `hermes` 报错 "No models provided"。解决：用 `hermes config edit` 打开，或者用 VS Code 保存为 UTF-8 Without BOM。
- **Alt+Enter 在 Windows Terminal 中不会换行**——Windows Terminal 把 Alt+Enter 截胡成全屏切换了。用 **Ctrl+Enter** 代替。
- **网关在 WSL2 下可能因终端关闭而退出**——需要在 `/etc/wsl.conf` 中开启 `systemd=true`。

---

## 三、配置 LLM 提供商

这是最关键的一步——Hermes 本身不包含模型，你需要告诉它用哪个大模型。

### 3.1 交互式配置

```bash
hermes setup      # 启动设置向导
hermes model      # 选择和切换模型
```

`hermes model` 会打开一个交互式选择器，你可以先选提供商，再选具体模型。

### 3.2 手动配置

API 密钥放在 `~/.hermes/.env` 中（这个文件不会被提交到版本控制）：

```bash
# 只需配置你实际用到的提供商
OPENROUTER_API_KEY=sk-or-v1-xxxxxxxx
ANTHROPIC_API_KEY=sk-ant-xxxxxxxx
DEEPSEEK_API_KEY=sk-xxxxxxxx
GOOGLE_API_KEY=AIzaxxxxxxxx
```

配置文件和模型选择在 `~/.hermes/config.yaml`：

```yaml
model:
  default: anthropic/claude-sonnet-4
  provider: openrouter
```

### 3.3 支持的主要提供商速览

| 提供商          | 认证方式 | 环境变量              |
| --------------- | -------- | --------------------- |
| OpenRouter      | API Key  | `OPENROUTER_API_KEY`  |
| Anthropic       | API Key  | `ANTHROPIC_API_KEY`   |
| OpenAI          | API Key  | `OPENAI_API_KEY`      |
| Google Gemini   | API Key  | `GOOGLE_API_KEY`      |
| DeepSeek        | API Key  | `DEEPSEEK_API_KEY`    |
| xAI (Grok)      | API Key  | `XAI_API_KEY`         |
| 阿里 DashScope  | API Key  | `DASHSCOPE_API_KEY`   |
| 智谱 GLM        | API Key  | `GLM_API_KEY`         |
| Kimi / Moonshot | API Key  | `KIMI_API_KEY`        |
| MiniMax         | API Key  | `MINIMAX_API_KEY`     |
| 小米 MiMo       | API Key  | `XIAOMI_API_KEY`      |
| 本地模型        | Config   | 配置 `base_url`       |
| GitHub Copilot  | OAuth    | `hermes model` 中登录 |

### 3.4 API Key Pool（多 Key 轮转）

一个账号不够用？Hermes 支持为同一提供商配置多个 API Key，按负载自动轮转：

```bash
hermes auth add              # 交互式添加凭据
hermes auth list deepseek    # 查看 DeepSeek 的所有 Key
hermes auth remove deepseek 0 # 移除第 0 个 Key
# 当某个 Key 触发限流时，自动切换到下一个可用 Key
```

---

## 四、初次使用：从 Hello World 到实际干活

### 4.1 启动交互式会话

```bash
hermes
```

这会进入一个类 Shell 的交互界面，可以直接打字对话。Hermes 可以执行命令、读写文件、搜索网络、浏览网页等。

### 4.2 单次查询模式

不需要交互时，用 `-q` 参数：

```bash
hermes chat -q "列出当前目录下最大的 5 个文件"
hermes chat -q "帮我写一个 Python 脚本来批量重命名这些 .jpg 文件"
```

### 4.3 加载技能启动

技能是 Hermes 最重要的特性之一——它就像一个插件，告诉 Hermes 如何做某类事情：

```bash
hermes -s github-pr-workflow -s systematic-debugging
```

这会在启动时加载两个技能，使 Hermes 立即知道如何处理 GitHub PR 以及如何系统化调试。

### 4.4 核心 Slash 命令

进入交互会话后，以下命令最常用：

| 命令               | 作用                          |
| ------------------ | ----------------------------- |
| `/new` 或 `/reset` | 开始新会话（清空上下文）      |
| `/retry`           | 重新发送上一条消息            |
| `/undo`            | 撤销上一步对话                |
| `/model`           | 切换当前会话的模型            |
| `/yolo`            | 跳过危险命令确认（小心使用）  |
| `/help`            | 查看所有可用命令              |
| `/quit` 或 `/exit` | 退出 CLI                      |
| `/compress`        | 手动压缩上下文（减少 tokens） |
| `/skills`          | 搜索和安装技能                |
| `/save`            | 保存会话到文件                |
| `/history`         | 查看会话历史                  |

### 4.5 工作区模式（多任务隔离）

```bash
hermes -w     # worktree 模式，自动创建隔离分支
```

当你需要 Hermes 在代码仓库里干活，又不想跟自己的修改冲突时，`-w` 模式会自动创建一个 git worktree 隔离工作区。

---

## 五、深入核心功能

### 5.1 技能系统（Skills）

技能是 Hermes 最独特的设计。它不是一个僵硬的插件，而是一份**动态加载的说明书**——告诉 Hermes 遇到某类任务时该怎么做。

**内置技能分类：**

| 类别     | 示例技能                              |
| -------- | ------------------------------------- |
| 软件开发 | TDD、代码审查、项目脚手架、系统化调试 |
| DevOps   | CI/CD、Docker、Kubernetes             |
| 数据科学 | Jupyter Notebook、数据分析            |
| 创意     | ASCII 艺术、建筑设计图、信息图        |
| 职业生涯 | 简历优化、面试准备、工资谈判          |
| 研究     | 论文搜索、RSS 监控、文献管理          |
| 社交媒体 | Twitter/X 发布、GIF 搜索              |

**安装技能：**

```bash
hermes skills browse            # 浏览所有可用技能
hermes skills search "testing"  # 搜索测试相关技能
hermes skills install test-driven-development  # 安装 TDD 技能
hermes skills list              # 查看已安装的技能
```

**会话中动态加载：**

```bash
/skill systematic-debugging    # 加载调试技能
/reload-skills                 # 重新扫描已安装的技能
```

**自定义技能：**

当你完成一个复杂任务（比如配置了一套 CI/CD 流水线），可以一键保存为技能，以后遇到类似场景直接复用：

```bash
# Hermes 会自动询问你：是否将此保存为技能？
# 确认后，下次启动时加载该技能即可复用整套流程
```

### 5.2 持久记忆（Memory）

Hermes 能记住你是谁、你喜欢什么、你的项目约定是什么——跨会话跨天。

```bash
hermes memory status   # 查看记忆系统状态
hermes memory setup    # 配置记忆后端（内置 / Honcho / Mem0 等）
```

记忆分两种：

- **User Profile**：用户信息（名字、偏好、说话风格）
- **Memory**：环境信息、项目约定、工具用法

比如你说一次 "我不喜欢冗长的输出，简洁点"，之后 Hermes 就会记住这一点。

### 5.3 子智能体（Delegate Task）

复杂任务可以拆成子任务并行执行，互不干扰：

```bash
# Hermes 内部自动调用 delegate_task
# 例如：同时实现前端和后端
```

子智能体有独立的会话和终端环境，完成后返回摘要。适合：

- 并行实现多个独立功能模块
- 同时搜索多个来源的资料
- 在隔离环境中运行高风险操作

### 5.4 定时任务（Cron）

像 Linux cron 一样的调度器，但任务可以是复杂的 AI 工作流：

```bash
hermes cron create "0 9 * * *"    # 每天早上 9 点执行
hermes cron list                   # 查看所有任务
hermes cron run <job_id>          # 立即触发一次
```

例子：每天早上自动抓取 Hacker News 热门文章并生成摘要推送到 Telegram。

### 5.5 多平台网关（Gateway）

这是把 Hermes 变成"随身 AI 助手"的关键：

```bash
hermes gateway setup    # 配置要接入的平台
hermes gateway run      # 启动网关前台
hermes gateway install  # 安装为后台服务
hermes gateway status   # 查看运行状态
```

**支持的平台：**

Telegram、Discord、Slack、WhatsApp、Signal、Email、SMS、Matrix、钉钉、飞书、企业微信、Home Assistant 等 15+ 平台。

配置完成后，你可以：

- 在 Telegram 上给 Hermes 发消息，它帮你操作服务器
- 在 Discord 上 @Hermes 让它审查代码
- 通过邮件发送任务给它

---

## 六、模型推荐：2026 年 7 月市场概览

选择什么模型驱动 Hermes，直接影响使用体验。以下是我实际使用后的推荐：

### 6.1 综合最强：Claude Sonnet 4

> 提供商：Anthropic（OpenRouter 或直连）
> 模型名：anthropic/claude-sonnet-4

Claude Sonnet 4 是目前在**代码生成、工具调用、指令遵循**三个维度上都表现最好的模型之一。用它驱动 Hermes 进行开发任务体验最佳。

**适合：** 日常编码、代码审查、复杂 debug、架构设计
**价格：** 中等偏贵
**推荐度：** ★★★★★

### 6.2 性价比之选：DeepSeek V4 / V3

> 提供商：DeepSeek
> 模型名：deepseek/deepseek-v4 或 deepseek/deepseek-v3

DeepSeek 的模型在国内可直接访问，性能接近第一梯队，但价格低得多。V3 在日常任务中完全够用，V4 在编程推理上更进一步。

**适合：** 日常开发、中文场景、预算有限
**价格：** 便宜
**推荐度：** ★★★★★

### 6.3 最强推理：Claude Opus 4 / o4

> 提供商：Anthropic / OpenAI
> 模型名：anthropic/claude-opus-4 或 openai/o4

当问题特别复杂（数学证明、复杂架构决策、长链条推理）时，用这些"重"模型。不过成本较高，适合偶尔切换使用。

**适合：** 复杂推理、关键决策、数学/算法问题
**价格：** 贵
**推荐度：** ★★★★

### 6.4 轻量快速：Gemini 2.5 Flash / GPT-4o Mini

> 提供商：Google / OpenAI
> 模型名：google/gemini-2.5-flash 或 openai/gpt-4o-mini

当需要快速迭代、大量简单查询时，切换到轻量模型可以大幅降低成本并加速响应。

**适合：** 简单问答、批量处理、原型探索
**价格：** 极低
**推荐度：** ★★★★

### 6.5 国产模型推荐

> 阿里 Qwen： dashscope/qwen-max 或 qwen-plus
> 智谱 GLM-4： glm/glm-4-plus
> Kimi / Moonshot：kimi/kimi-latest
> DeepSeek： deepseek/deepseek-v3

国产模型在中文场景下表现出色，且国内网络直连延迟低。如果你在国内网络环境下使用 Hermes，DeepSeek 和阿里 Qwen 是首选。

### 6.6 本地模型

> 提供商：Local（Ollama / llama.cpp / vLLM）
> 配置：model.base_url = <http://localhost:11434/v1>

如果数据隐私要求极高，或者想零成本使用，可以跑本地模型。推荐：

- **Qwen 2.5 32B**（量化版）：本地能跑的最强中文模型
- **DeepSeek 的蒸馏版**：7B 到 33B 不等
- **Llama 3.1 8B/70B**：社区生态最完善

注意：本地模型的能力上限取决于你的硬件。32B 以上的模型需要至少 24GB 显存。

### 6.7 混合策略（推荐）

在实际使用中，最佳实践是**按任务切换模型**，而不是固守一个：

```yaml
# config.yaml 配置示例
model:
  default: anthropic/claude-sonnet-4 # 日常主力

delegation:
  model: deepseek/deepseek-v3 # 子智能体用便宜的
```

或者在会话中随时用 `/model` 命令切换：

```bash
/model deepseek/deepseek-v3   # 切换到 DeepSeek
/model anthropic/claude-sonnet-4  # 切回 Claude
```

### 6.8 模型推荐速查表

| 使用场景         | 推荐模型                      | 提供商        | 成本  |
| ---------------- | ----------------------------- | ------------- | ----- |
| 日常编码、开发   | Claude Sonnet 4               | Anthropic     | 中    |
| 中文场景、性价比 | DeepSeek V3/V4                | DeepSeek      | 低    |
| 最复杂推理       | Claude Opus 4                 | Anthropic     | 高    |
| 批量轻量任务     | Gemini 2.5 Flash              | Google        | 极低  |
| 代码审查         | Claude Sonnet 4 / DeepSeek V4 | —             | 中/低 |
| 中文写作         | DeepSeek V3 / Qwen Max        | DeepSeek/阿里 | 低    |
| 数据隐私优先     | 本地 Qwen 2.5 32B             | Local         | 免费  |

---

## 七、进阶技巧

### 7.1 配置 Credential Pool（多 Key 自动轮转）

如果你有多个 DeepSeek 或 OpenRouter 账号，配置 Pool 可以避免限流：

```bash
hermes auth add              # 添加第一个 Key
hermes auth add              # 添加第二个 Key
hermes auth list deepseek    # 确认
# 使用时会自动轮转
```

### 7.2 Profiles（多环境隔离）

工作和个人环境隔离：

```bash
hermes profile create work --clone   # 从当前配置克隆
hermes profile create personal       # 新建空 profile
hermes profile use work              # 切换到 work profile
hermes work                          # 用 work profile 启动（自动生成 alias）
```

每个 Profile 有独立的 config、.env、sessions、skills、memory。

### 7.3 MCP 服务器集成

如果你有 MCP 兼容的服务（比如数据库、文件系统等），可以让 Hermes 直接调用：

```bash
hermes mcp add my-db --command "npx @modelcontextprotocol/server-postgres"
hermes mcp list
```

### 7.4 会话恢复与分支

工作到一半被打断？下次可以无缝续接：

```bash
hermes -c                      # 恢复最近的会话
hermes -r 20260714_083021_xxx  # 恢复指定会话
# /branch 命令可以"分支"当前会话，像 git branch 一样
```

### 7.5 与 Claude Code / Codex 配合

你可以让 Hermes 协调其他 Agent 一起工作：

> "帮我写一个 React 组件，然后让 Claude Code 审查代码质量"

Hermes 会通过 `delegate_task` 或者直接启动 Claude Code 进程来完成。

---

## 八、常见问题

### Q：Hermes 与其他 Agent 有什么区别？

**Claude Code**：只支持 Anthropic 模型，专注代码开发。
**Codex CLI**：OpenAI 出品，绑定 OpenAI 模型。
**OpenCode**：开源但功能相对基础。
**Hermes**：**不限模型**，**支持多平台**，**有技能系统和持久记忆**，是目前生态最丰富的开源 Agent。

### Q：Hermes 可以安全地运行危险命令吗？

默认情况下，Hermes 在执行 `rm -rf`、`git reset --hard` 等破坏性命令前会要求你确认。你还可以：

```bash
hermes config set approvals.mode smart   # 智能审批（推荐）
hermes --yolo                            # 跳过所有确认（不推荐）
```

### Q：技能和指令（Prompt）有什么区别？

技能是**可复用的结构化知识**——包含步骤、代码片段、注意事项、验证方法。普通 Prompt 是口语化的指令。技能可以被版本管理、搜索、共享、自动加载。

### Q：如何升级到最新版本？

```bash
hermes update   # 自动检测并更新
```

### Q：在哪里找到更多技能？

```bash
hermes skills browse           # 在终端浏览技能目录
# 或者访问：https://hermes-agent.nousresearch.com/docs/reference/skills-catalog
```

---

## 九、总结

Hermes Agent 是目前生态最丰富、最灵活的开源 AI Agent 框架。它的核心竞争力在于：

1. **模型无关**——不被任何一家绑定
2. **技能系统**——越用越聪明，经验和知识可沉淀
3. **多平台**——不止在终端，Telegram、Discord 都能用
4. **开源透明**——代码在 GitHub，社区活跃

如果你正在寻找一个真正能帮你干活的 AI 助手，Hermes Agent 值得一试。从今天开始，让你的终端拥有真正的智能。

---

## 参考

- [Hermes Agent GitHub 仓库](https://github.com/NousResearch/hermes-agent)
- [官方文档](https://hermes-agent.nousresearch.com/docs/)
- [技能目录](https://hermes-agent.nousresearch.com/docs/reference/skills-catalog)
- [提供商配置指南](https://hermes-agent.nousresearch.com/docs/integrations/providers)
- [OpenRouter 模型列表](https://openrouter.ai/models)
- [DeepSeek 官网](https://deepseek.com/)
