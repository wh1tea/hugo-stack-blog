---
title: 本地项目推送到已有远程仓库
description: 解决 refusing to merge unrelated histories：本地与远程仓库合并的完整方案
slug: git-push-existing-remote
date: 2025-09-02
tags:
  - git
  - github
categories:
  - tutorial
---

本地用 `git init` 建好的项目，想推送到 GitHub 上已存在的仓库，经常碰到一堆报错：先是认证失败，再是 `refusing to merge unrelated histories`。本文给出完整的排坑流程。

## 完整的失败路径

首次推送常见三步错误：

```bash
git remote add origin https://github.com/your-username/your-repository.git
git push -u origin main
```

1. `Invalid username or token`：GitHub 已禁用密码认证，HTTPS 需要 token 或改用 SSH
2. 切换 SSH 后推送报 `rejected (non-fast-forward)`：远程仓库非空，双方历史无共同祖先
3. 直接 `git pull` 报 `fatal: refusing to merge unrelated histories`

SSH 配置见 [GitHub SSH 认证配置指南](git-github-ssh.md)，下面的命令假设已切换为 SSH 地址。

## 方案一：合并两边历史（推荐）

保留本地和远程的提交，用 `--allow-unrelated-histories` 强制合并：

```bash
git pull origin main --allow-unrelated-histories
```

遇到冲突（如两边都有 README）时手动解决，然后：

```bash
git add .
git commit
git push origin main
```

适合想保留远程 README / LICENSE，同时保留本地全部提交的场景。

## 方案二：强制推送覆盖远程

远程仓库内容不重要（只是创建时自动生成的默认文件），直接覆盖：

```bash
git push -f origin main
```

**警告**：会删除远程全部历史，多人协作时严禁使用。

## 方案三：重置本地跟随远程

想以远程内容为基础重新开始：

```bash
git fetch origin
git reset --hard origin/main
git add .
git commit -m "Add local files"
git push origin main
```

## 预防措施

- 创建仓库时不要勾选 "Add a README file" 等初始化选项，空仓库直接推送永无冲突
- 推送前先 `git pull origin main` 保持同步
- 常用分支直接推送，多人协作请开特性分支

## 结语

`refusing to merge unrelated histories` 的本质是本地与远程没有共同祖先。个人项目首选 `--allow-unrelated-histories` 合并，远程默认文件无所谓就强制推送，最重要的是创建仓库时选空仓库，从源头避开这个问题。
