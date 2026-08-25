---
title: Git 开发工作流：VS Code 与 Docker 集成
slug: git-workflow-vscode-docker
date: 2026-07-14
description: VS Code Source Control 面板与 GitLens 的日常用法，以及 Docker + Node.js 项目的 Git 工作流与忽略规则配置
tags:
  - git
  - vscode
  - docker
categories:
  - git
---

终端之外，VS Code 的内置 Git 集成让提交、分支、推送变得更直观；配合 Dev Containers，容器内的版本控制体验与本地一致。本文介绍这两套工作流，以及配套的忽略规则配置。

## VS Code 内置 Git

点击左侧栏 Git 图标（或 `Ctrl+Shift+G`）打开 Source Control 面板，日常操作全部可视化：

| 操作        | 面板操作                         |
| ----------- | -------------------------------- |
| 暂存        | 点击文件旁的 `+` 加入暂存区      |
| 提交        | 输入提交信息，点击 `✔`           |
| 分支        | 点击底部状态栏分支名，创建或切换 |
| 推送 / 拉取 | `...` 菜单选择 `Push` / `Pull`   |

### GitLens 扩展

[GitLens](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens) 是 Git 增强的首选扩展：代码行尾直接显示最后修改者与提交信息，还提供提交历史图谱、文件历史、行级 blame 等功能，点击即可查看完整 diff。

## Docker + Node.js 工作流

以 Node.js 项目为例，容器化开发的 Git 流程与普通项目一致，关键是配好两套忽略规则。

### 初始化与提交

```bash
git init
git add .
git commit -m "Initial commit with Node.js project"
```

### .gitignore 与 .dockerignore

`node_modules` 体积大且可随时重建，必须排除；容器构建同样不需要它和 `.git`：

```text
# .gitignore
node_modules/
```

```text
# .dockerignore
node_modules/
.git/
```

### 推送远程

```bash
git remote add origin <remote-url>
git push -u origin main
```

首次推送若报认证失败，先配置 SSH 免密：[GitHub SSH 认证配置指南](git-github-ssh.md)。

### 容器内开发

用 VS Code 的 Dev Containers 扩展打开项目进入容器环境，容器内提交与本地无异：

```bash
git add .
git commit -m "Add new feature"
git push
```

容器不共享宿主机的全局 Git 身份，首次提交前确认 `user.name` / `user.email` 已设置，配置方法见 [Git for Windows 配置指南](git-for-windows.md)。

## 常见问题

| 问题       | 解决                                                                      |
| ---------- | ------------------------------------------------------------------------- |
| 误删文件   | 已提交用 `git checkout HEAD -- file.txt`；已暂存用 `git restore file.txt` |
| 推送失败   | `git pull --rebase` 拉取最新，再检查权限与分支名                          |
| 行尾不一致 | 配置 `.gitattributes` + `core.autocrlf`，运行 `git add --renormalize .`   |
| 证书错误   | OpenSSL 检查 `http.sslCAInfo`；Schannel 确认证书已导入 Windows 证书存储   |

## 结语

VS Code 面板适合直观管理小改动，命令行适合批量与复杂操作，两者互补。容器开发的关键是同时维护 `.gitignore` 与 `.dockerignore`，避免把依赖目录推进仓库；完整命令速查见 [Git 命令速查手册](git-commands-cheatsheet.md)。

## 参考

- [GitLens — Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=eamodio.gitlens)
- [VS Code 文档 — Source Control](https://code.visualstudio.com/docs/sourcecontrol/overview)
