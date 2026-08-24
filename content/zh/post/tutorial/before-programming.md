---
title: 在编程之前
slug: before-programming
date: 2026-08-13
description: 盘点我当前的开发工具链与环境：终端、WSL2、VSCode、Git、Docker 与 AI 辅助工作流，也给入门编程的新手一份开工前的地图。
tags:
  - tutorial
  - windows
  - wsl
  - vscode
  - git
  - ai
  - cli
  - docker
categories:
  - tutorial
---

这篇文章写两件事：一是把我的开发环境从头到尾盘点一遍，重新整理思路；二是给准备入门编程的朋友一份「开工前要装什么、为什么」的地图。读完你能知道：一台 Windows 电脑上，如何搭出一套完整、现代的开发环境。

## 环境总览

先看我目前的环境全貌（写于 2026 年 8 月）：

| 层级 | 工具 | 用途 |
| :--- | :--- | :--- |
| 操作系统 | Windows 11 + WSL2（Ubuntu 26.04） | 日常使用 + 开发主力 |
| 终端 | Windows Terminal + PowerShell 7 | 命令行入口 |
| 终端美化 | Oh My Bash | |
| | x-cmd | |
| 编辑器 | VSCode（Cursor 备用） | 写代码 |
| 版本控制 | Git + GitHub | 代码管理与协作 |
| 容器 | Docker Desktop | 环境隔离 |
| 语言运行时 | Node.js、Python、Go、JDK 21 | 写不同语言的程序 |
| AI 辅助 | DeepSeek 网页版 + Hermes Agent（WSL2） | 问答与自动化 |

## 终端：cmd、PowerShell 与包管理器

新手最先接触的是那个「黑框框」。Windows 上有三代命令行：

- `cmd`：DOS 时代的遗产，只能执行简单命令，没有现代脚本能力。
- `PowerShell 5.1`：Windows 内置，基于对象管道，比 cmd 强一个时代。
- `PowerShell 7`（`pwsh`）：跨平台的新一代，日常推荐用它。

判断标准很简单：能用 `pwsh` 就不用 `cmd`。常用命令两边写法差异不大，`cd`、`ls`、`mkdir` 都认，但 `pwsh` 有 `Get-Process`、管道传对象这类现代能力。

比命令更重要的是装软件的方式。Windows 装软件有三条路：

- 官网下载安装包，一路下一步（最原始，也最易留垃圾）。
- **Winget**：微软官方包管理器，Windows 11 自带。
- **Scoop**：社区包管理器，装在用户目录，主打便携与干净。

Winget 一条命令装完软件，还能统一升级：

```bash
winget install Microsoft.PowerShell
winget install Microsoft.VisualStudioCode
winget upgrade --all
```

Scoop 的哲学是「便携 + 不改注册表」，装 Python、Node 这类开发工具很干净，缺点是仓库更新略慢。我目前主力是 Winget，PowerShell 7、Docker Desktop、DBeaver 等软件都靠它管理。

> **提示**：装软件优先用包管理器，卸载干净、版本可控，别去官网下安装包。

## WSL2：Windows 上的 Linux

真正的开发环境在 Linux 上。WSL2 是微软官方实现的「Windows 内嵌 Linux 内核」，我在里面跑 Ubuntu 26.04。

为什么要 WSL2：

- 命令行和线上服务器一致，本地跑通 = 部署不踩坑。
- 软件用 `apt` 装，一行命令搞定依赖。
- AI 工具链、Docker 都能原生跑在 Linux 里。

从 Windows 终端输入 `wsl` 即进入 Linux。两个系统共享文件系统：Windows 的 C 盘在 WSL 里挂载为 `/mnt/c/`，D 盘是 `/mnt/d/`。

我的习惯：代码和博客项目放在 Windows 侧（`D:\Projects`），用 WSL 里的工具链操作它们——编辑器用 Windows 版 VSCode 连进 WSL，构建、Git、AI 任务在 WSL 里跑。

## 编辑器：VSCode 与必装插件

编辑器选 VSCode：免费、插件生态最大、微软长期维护。AI 编辑器 Cursor 本质是 VSCode 加 AI，插件经验完全通用。

必装插件按功能分组：

| 分组 | 插件 |
| :--- | :--- |
| 中文 | Chinese Language Pack |
| Python | Python + Pylance + Black Formatter |
| 前端 | ESLint + Prettier |
| Git | GitLens + Git Graph |
| 容器 | Docker + Remote - Containers |
| 远程 | Remote - WSL（最重要） |
| Markdown | Markdown All in One + markdownlint |
| 效率 | Todo Tree + Code Runner + Project Manager |

`Remote - WSL` 是核心：装上后 VSCode 直接连进 WSL 开发，插件装在 Linux 侧，写代码、跑命令、调试都是 Linux 环境，界面仍是 Windows 的。

配置建议做两件事：装 Prettier 并开启「保存时自动格式化」；装 EditorConfig 统一团队风格。

## Git 与 GitHub：版本控制

写代码必须有版本控制。Git 是事实标准，GitHub 是最常用的托管平台。

核心流程只有三条命令：

```bash
git add .
git commit -m "feat: 添加新功能"
git push
```

我的做法：在 WSL 里跑 Git 操作代码，凭证交给 Windows 侧的 Git Credential Manager，一次登录长期免密。新手也可以用 GitHub Desktop 这类图形界面先理解提交、推送的概念，再回到命令行。

## Docker：一键装环境

每个项目的依赖环境都不一样（Python 3.12 还是 3.14？MySQL 8 还是 5.7？），一台机器装多了必乱。Docker 用容器把环境隔离成一个个「轻量虚拟机」，拉一个镜像就能跑：

```bash
docker run -d -p 3306:3306 mysql:8.0
```

Docker Desktop 直接集成 WSL2，容器跑在 Linux 侧，速度和本地进程几乎一样。我本地的 MySQL、Redis 都用容器起，删掉重来不留垃圾。

## AI 辅助：两种用法

写代码离不开 AI。我的用法分两层，各管一段。

### 网页版解决日常问题

概念不懂、报错看不懂、代码不知道怎么写——这类「问一句就有答案」的问题，直接开 DeepSeek 网页版，新建对话就问，零成本零负担。

### Hermes Agent 处理重活

真正重的工作交给跑在 WSL2 里的 Hermes Agent（模型为 DeepSeek v4）。它不只是聊天，而是能执行命令、读写文件、操作 Git 的 CLI Agent。

典型工作流：

```bash
hermes "检查这个项目的结构，然后按 README 规范写一篇新博客，最后构建并预览"
```

它会自己读项目文档、写 Markdown、跑构建脚本、起本地服务器。像这篇《在编程之前》，就是 Hermes 盘点完机器环境后写出来的——文中的每个工具版本都是现查的，不是凭记忆编的。

分工原则：一句话能说清的问题用网页版；要动手改文件、跑命令、多步骤的任务交给 CLI Agent。

## 总结

我的环境浓缩成一句话：**Windows 管日常，WSL2 管开发，VSCode 写代码，Git 管版本，Docker 管环境，AI 做辅助。**

给新手的三条行动建议：

- 装软件用 Winget，别去官网下安装包。
- 环境装完立刻配好 Git 身份和 VSCode 的 Remote-WSL，其余按需补。

工具只是脚手架，编程的核心永远是思路。把环境一次搭好，把精力留给代码本身。

## 参考

- [WSL 官方文档](https://learn.microsoft.com/zh-cn/windows/wsl/)
- [Winget 官方文档](https://learn.microsoft.com/zh-cn/windows/package-manager/)
- [VSCode 官方文档](https://code.visualstudio.com/docs)
- [Git 官方文档](https://git-scm.com/doc)
- [Docker 官方文档](https://docs.docker.com/)
