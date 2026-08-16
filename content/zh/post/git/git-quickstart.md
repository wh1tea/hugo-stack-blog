---
title: "Git 入门：从安装到第一次推送"
description: "从零开始：安装 Git、配置身份、初始化仓库、提交代码并推送到 GitHub"
slug: "git-quickstart"
date: 2026-08-14T09:00:00+08:00
tags:
  - git
  - github
categories:
  - tutorial
---

本文面向刚开始使用 Git 的开发者：带你从安装、配置，到完成第一次 `git push`，把代码托管到 GitHub。读完你就能独立管理一个小项目的版本历史。

## 安装 Git

Windows 用户推荐用包管理器安装，或从官网下载安装包：

```bash
winget install Git.Git
git --version    # 验证安装
```

安装向导中有三个关键选项，直接决定日后的使用体验：

| 选项       | 推荐选择           | 说明                                  |
| ---------- | ------------------ | ------------------------------------- |
| SSH 客户端 | Bundled OpenSSH    | Git 自带完整工具集，开箱即用          |
| HTTPS 后端 | Schannel           | 使用系统证书、自动更新，省心          |
| 行尾处理   | 检出 CRLF、提交 LF | 即 `core.autocrlf true`，Windows 推荐 |

## 配置用户信息

首次使用必须设置用户名和邮箱，它们会写进每一次提交：

```bash
git config --global user.name "yourname"
git config --global user.email "youremail@example.com"
git config --global --list    # 验证配置
```

## 初始化仓库

在项目根目录执行：

```bash
git init
git status          # 查看文件状态
git add .           # 添加所有文件到暂存区
git commit -m "Initial commit"
```

`git status` 是使用频率最高的命令：它会告诉你哪些文件未跟踪、哪些已暂存、哪些已修改。

## 编写 .gitignore

`.gitignore` 用来排除不需要版本控制的文件。规则很简单：`node_modules/` 忽略目录，`*.log` 忽略一类文件，`!keep.txt` 取反保留。提交前先写好它，避免把缓存、密钥、依赖目录推上远程。

## 连接远程仓库

在 GitHub 新建空仓库（不要勾选 "Add a README file"），然后关联本地：

```bash
git remote add origin https://github.com/your-username/your-repository.git
git push -u origin main
```

首次推送若报 `Authentication failed`，是因为 GitHub 已禁用密码认证。推荐改用 SSH 免密推送，完整流程见 [GitHub SSH 认证配置指南](git-github-ssh.md)。

## 结语

Git 的核心流程就三件事：`add` 暂存、`commit` 提交、`push` 推送。先把这几条命令练熟，再逐步接触分支、变基和撤销技巧。配置好 SSH 之后，整个工作流就是本地提交 → 一键推送，非常顺滑。
