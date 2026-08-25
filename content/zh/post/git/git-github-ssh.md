---
title: GitHub SSH 认证配置指南
slug: git-github-ssh
date: 2025-09-05
description: 生成 SSH 密钥、启动 ssh-agent、上传公钥，彻底解决 Permission denied (publickey)
tags:
  - git
  - github
  - ssh
categories:
  - git
---

每次 `git push` 都要输密码很烦，而且 GitHub 早已禁用密码认证，HTTPS 方式会直接报 `Authentication failed`。配置 SSH 密钥后可以永久免密推送，本文给出完整流程与排错方法。

## 检查并生成密钥

先看本地是否已有密钥：

```bash
ls ~/.ssh
```

若没有 `id_ed25519`，用邮箱作为注释生成一对新密钥：

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

一路回车即可（口令可留空）。生成后 `~/.ssh` 下应有两个文件：私钥 `id_ed25519`（留在本地）和公钥 `id_ed25519.pub`（上传 GitHub）。

## 启动 ssh-agent 并加载密钥

Windows 上 SSH 代理默认未启动，需要手动开启（管理员 PowerShell）：

```powershell
Set-Service -Name ssh-agent -StartupType Manual
Start-Service -Name ssh-agent
ssh-add $HOME\.ssh\id_ed25519
ssh-add -l    # 验证密钥已加载
```

输入口令时注意键盘数字键是否开启——空口令是认证失败的常见原因。

## 上传公钥到 GitHub

复制公钥内容：

```powershell
Get-Content $HOME\.ssh\id_ed25519.pub | Set-Clipboard
```

登录 GitHub，进入 **Settings → SSH and GPG keys → New SSH key**，标题随意（如 "Windows PC"），粘贴公钥保存。

## 测试连接

```bash
ssh -T git@github.com
```

看到 `Hi username! You've successfully authenticated...` 即配置成功。

## 切换远程 URL 到 SSH

检查现有仓库的远程地址：

```bash
git remote -v
```

若是 HTTPS 格式，改为 SSH：

```bash
git remote set-url origin git@github.com:your-username/your-repository.git
```

没有远程关联的新仓库则直接添加：

```bash
git remote add origin git@github.com:your-username/your-repository.git
git push -u origin main
```

## 常见排错

| 现象                            | 排查方向                                     |
| ------------------------------- | -------------------------------------------- |
| `Permission denied (publickey)` | 密钥未加载到 agent、口令错误或公钥未上传     |
| `The agent has no identities`   | 未执行 `ssh-add` 或 agent 未运行             |
| 公钥配置了仍失败                | 用 `ssh -vT git@github.com` 查看详细认证过程 |

密钥口令忘记时，可用 `ssh-keygen -p -f ~/.ssh/id_ed25519` 重设，或重新生成密钥并更新 GitHub。

## 结语

SSH 认证是 Git 日常使用的第一道坎，配置一次终身受益。核心三步：生成密钥、agent 加载、上传公钥，之后所有仓库的 `git push` / `git pull` 都不再需要任何密码。
