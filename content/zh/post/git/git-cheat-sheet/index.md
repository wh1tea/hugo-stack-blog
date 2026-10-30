---
title: Git 常用命令速查表
slug: git-cheat-sheet
date: 2026-10-26
description: 按提交、撤销、分支、历史、远程五类场景整理 Git 高频命令，说清 switch、restore、reset 分别该在什么时候用。
tags:
  - cli
  - cheatsheet
  - troubleshooting
categories:
  - git
---

内容翻译整理自 git-scm 官方速查表[^1]。

## 入门

| 场景             | 命令               |
| ---------------- | ------------------ |
| 初始化一个新仓库 | `git init`         |
| 克隆一个已有仓库 | `git clone <repo>` |

## 准备提交

| 场景                             | 命令                                                      |
| -------------------------------- | --------------------------------------------------------- |
| 添加未跟踪文件或未暂存的更改     | `git add <file>`                                          |
| 添加所有未跟踪文件和未暂存的更改 | `git add .`                                               |
| 选择文件中的哪些部分要暂存       | `git add -p`                                              |
| 移动文件                         | `git mv <old> <new>`                                      |
| 删除文件                         | `git rm <file>`                                           |
| 让 Git 忘记某个文件但不删除它    | `git rm --cached <file>`                                  |
| 取消暂存一个文件                 | `git reset <file>`<br>或<br>`git restore --staged <file>` |
| 取消暂存所有内容                 | `git reset`<br>或<br>`git restore --staged .`             |
| 检查你添加了什么                 | `git status`                                              |

## 进行提交

| 场景                                         | 命令                       |
| -------------------------------------------- | -------------------------- |
| 进行一次提交（并打开文本编辑器编写提交信息） | `git commit`               |
| 进行一次提交                                 | `git commit -m 'message'`  |
| 提交所有未暂存的更改                         | `git commit -am 'message'` |

## 在分支间切换

| 场景                       | 命令                                                         |
| -------------------------- | ------------------------------------------------------------ |
| 切换分支                   | `git switch <branch>`<br>或<br>`git checkout <branch>`       |
| 创建分支                   | `git switch -c <branch>`<br>或<br>`git checkout -b <branch>` |
| 列出分支                   | `git branch`                                                 |
| 按最近提交时间排序列出分支 | `git branch --sort=-committerdate`                           |
| 删除分支                   | `git branch -d <branch>`                                     |
| 强制删除分支               | `git branch -D <branch>`                                     |

## 比较已暂存/未暂存的更改

| 场景                         | 命令                |
| ---------------------------- | ------------------- |
| 比较所有已暂存和未暂存的更改 | `git diff HEAD`     |
| 仅比较已暂存的更改           | `git diff --staged` |
| 仅比较未暂存的更改           | `git diff`          |

## 比较提交

| 场景                           | 命令                                   |
| ------------------------------ | -------------------------------------- |
| 显示某提交与其父提交之间的差异 | `git show <commit>`                    |
| 比较两个提交                   | `git diff <commit1> <commit2>`         |
| 比较某提交以来的某个文件       | `git diff <commit> <file>`             |
| 显示差异摘要                   | `git diff --stat`<br>`git show --stat` |

## 引用提交的方式

每当我们说 `<commit>` 时，你都可以使用以下任意一种：

| 引用方式     | 示例                  |
| ------------ | --------------------- |
| 一个分支     | `main`                |
| 一个标签     | `v0.1`                |
| 一个提交 ID  | `3e887ab`             |
| 一个远程分支 | `origin/main`         |
| 当前提交     | `HEAD`                |
| 3 次提交之前 | `HEAD^^^` 或 `HEAD~3` |

## 丢弃你的更改

| 场景                                 | 命令                                                         |
| ------------------------------------ | ------------------------------------------------------------ |
| 删除某个文件的未暂存更改             | `git restore <file>`<br>或<br>`git checkout <file>`          |
| 删除某个文件的全部已暂存和未暂存更改 | `git restore --staged --worktree <file>`<br>或<br>`git checkout HEAD <file>` |
| 删除全部已暂存和未暂存更改           | `git reset --hard`<br>或<br>`git restore --staged --worktree .` |
| 删除未跟踪文件                       | `git clean`                                                  |
| 暂存（stash）全部已暂存和未暂存更改  | `git stash`                                                  |

## 编辑历史

| 场景                                 | 命令                                                         | 备注                     |
| ------------------------------------ | ------------------------------------------------------------ | ------------------------ |
| 回退最近一次提交（保持工作目录不变） | `git reset HEAD^`                                            | `git reset --soft HEAD^` |
| 将最近 5 次提交压缩为一次            | `git rebase -i HEAD~5`<br>然后将需与上一提交合并的提交的 `pick` 改为 `fixup` |                          |
| 撤销首个提交                         | `git update-ref -d HEAD`                                     |                          |
| 撤销失败的 rebase                    | `git reflog BRANCHNAME`<br>在 reflog 中手动找到正确的提交 ID 后，再运行：<br>`git reset --hard <commit>` |                          |
| 修改提交信息（或添加忘记的文件）     | `git commit --amend`                                         |                          |

## 代码考古

| 场景                                         | 命令                                                            |
| -------------------------------------------- | --------------------------------------------------------------- |
| 查看某个分支的历史                           | `git log main`<br>`git log --graph main`<br>`git log --oneline` |
| 显示修改过某个文件的每次提交                 | `git log <file>`                                                |
| 显示修改过某个文件的每次提交，包括重命名之前 | `git log --follow <file>`                                       |
| 查找添加或删除某些文本的每次提交             | `git log -G banana`                                             |
| 显示文件每一行最后是谁修改的                 | `git blame <file>`                                              |

## 合并分叉的分支

### 使用 rebase 合并

| 场景                         | 命令                                     |
| ---------------------------- | ---------------------------------------- |
| 将 banana 分支变基到 main 上 | `git switch banana`<br>`git rebase main` |

**之前：**

![rebase 之前](git.svg)

**之后：**

![rebase 之后](rebase.svg)

### 使用 merge 合并

| 场景                         | 命令                                    |
| ---------------------------- | --------------------------------------- |
| 将 banana 分支合并到 main 上 | `git switch main`<br>`git merge banana` |

**之前：**

![merge 之前](git.svg)

**之后：**

![merge 之后](merge.svg)

### 使用 squash merge 合并

| 场景                       | 命令                                                             |
| -------------------------- | ---------------------------------------------------------------- |
| 压缩合并 banana 分支并提交 | `git switch main`<br>`git merge --squash banana`<br>`git commit` |

**之前：**

![squash merge 之前](git.svg)

**之后：**

![squash merge 之后](squash.svg)

### 使一个分支与另一个分支保持最新（又称“快进合并”）

| 场景                    | 命令                                    |
| ----------------------- | --------------------------------------- |
| 快进合并 banana 到 main | `git switch main`<br>`git merge banana` |

**之前：**

![快进合并之前](fast-forward-before.svg)

**之后：**

![快进合并之后](fast-forward-after.svg)

### 将某个提交复制到当前分支

| 场景                   | 命令                       |
| ---------------------- | -------------------------- |
| 复制单个提交到当前分支 | `git cherry-pick <commit>` |

**之前：**

![复制单个提交之前](cherry-pick-before.svg)

**之后：**

![复制单个提交之前](cherry-pick-after.svg)

## 恢复旧文件

| 场景                     | 命令                                                                              |
| ------------------------ | --------------------------------------------------------------------------------- |
| 从另一个提交获取文件版本 | `git checkout <commit> -- <file>`<br>或<br>`git restore --source <commit> <file>` |

## 添加远程仓库

| 场景         | 命令                          |
| ------------ | ----------------------------- |
| 添加远程仓库 | `git remote add <name> <url>` |

## 推送你的更改

| 场景                              | 命令                          |
| --------------------------------- | ----------------------------- |
| 将 `main` 分支推送到远程 `origin` | `git push origin main`        |
| 将当前分支推送到其远程“跟踪分支”  | `git push`                    |
| 推送一个从未推送过的分支          | `git push -u origin <branch>` |
| 强制推送                          | `git push --force-with-lease` |
| 推送标签                          | `git push --tags`             |

GitHub 在 **2020 年 10 月 1 日**正式将新仓库的默认分支名从 `master` 改为 `main`。

## 拉取更改

| 场景                                | 命令                                       |
| ----------------------------------- | ------------------------------------------ |
| 获取更改（但不改变任何本地分支）    | `git fetch origin main`                    |
| 获取更改，然后对当前分支执行 rebase | `git pull --rebase`                        |
| 获取更改，然后将其合并到当前分支    | `git pull origin main`<br>或<br>`git pull` |

## 配置 Git

| 场景                   | 命令                               |
| ---------------------- | ---------------------------------- |
| 设置一个配置选项       | `git config user.name 'Your Name'` |
| 全局设置选项           | `git config --global ...`          |
| 添加别名               | `git config alias.st status`       |
| 查看所有可能的配置选项 | `man git-config`                   |

## 重要文件

| 文件           | 用途             |
| -------------- | ---------------- |
| `.git/config`  | 本地 Git 配置    |
| `~/.gitconfig` | 全局 Git 配置    |
| `.gitignore`   | 要忽略的文件列表 |

[^1]: [Git cheat sheet](https://git-scm.com/cheat-sheet)
