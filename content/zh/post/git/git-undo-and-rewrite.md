---
title: Git 撤销与修改提交历史
description: reset、revert、amend、rebase -i 全面梳理：提交出错后的补救方案
slug: git-undo-and-rewrite
date: 2025-09-03
tags:
  - git
categories:
  - tutorial
---

提交信息写错、提交内容不对、已经推送了才发现问题——这些在 Git 里都有对应的补救手段。本文按「是否已推送」梳理撤销与改写历史的完整方案。

## 撤销未推送的提交

只撤销提交、保留改动，用于重新整理提交：

```bash
git reset --soft HEAD~1
```

完全撤销并丢弃改动（代码将回退，**不可找回**）：

```bash
git reset --hard HEAD~1
```

`HEAD~n` 表示回退 n 条。不确定时先用 `git log --oneline` 确认位置。

## 修改最近一次提交信息

```bash
git commit --amend -m "修正后的提交信息"
```

`--amend` 同时会把当前暂存区的改动并入上一次提交，注意别混入无关内容。

## 撤销已推送的提交

已推送的提交影响他人，两种思路：

- `git revert HEAD`：生成一个反向新提交，保留原历史，**团队协作首选**
- `git reset --hard HEAD~1` + `git push --force-with-lease`：彻底抹掉旧提交，改写远程历史

改写历史必须用 `--force-with-lease` 而不是 `--force`：前者会检查远程是否有你未知的新提交，更安全。

## 修改历史提交信息

用交互式 rebase 改任意一条历史提交的 message：

```bash
git rebase -i HEAD~5
```

编辑器里把目标行开头的 `pick` 改为 `reword`，保存退出后逐条修改信息。完成后同样需要强制推送：

```bash
git push --force-with-lease
```

## 撤销多条已推送的提交

想把最近 5 条撤销后重新整理成一条，完整流程：

```bash
git log --oneline -5          # 1. 确认目标提交
git reset --soft HEAD~5       # 2. 软回退，改动全部保留
git commit -m "新的提交信息"    # 3. 重新提交
git push --force-with-lease origin main   # 4. 覆盖远程
```

## rebase 中断恢复

rebase 遇到冲突或意外中断时，先 `git status` 看状态，然后三选一：

```bash
git rebase --continue    # 解决冲突后继续
git rebase --abort       # 放弃本次 rebase，回到之前状态
git rebase --skip        # 跳过当前有问题的提交
```

`--abort` 是最安全的选择，能完整回到操作前。

## 误操作恢复

reset 掉的提交并非立即消失，`reflog` 记录了所有 HEAD 移动：

```bash
git reflog                       # 找到回退前的提交哈希
git reset --hard <哈希>           # 恢复过去的状态
```

## 彻底清理本地旧提交

改写历史后，VS Code 的 Source Control → Graph 里可能仍显示旧提交——它们残留在本地 reflog 中，尚未被垃圾回收。彻底清除：

```bash
git push --force-with-lease origin main   # 1. 确保远程已是最新

git gc --prune=now --aggressive           # 2. 删除悬空对象（被 reset 掉的旧 commit）

git reflog expire --expire=now --all      # 3. 过期全部 reflog
git gc --prune=now                        # 4. 再次清理
```

刷新 VS Code（`Git: Fetch` 或重启），Graph 中旧提交即消失。验证：

```bash
git reflog | grep <旧commit的hash前7位>    # 无输出即清理干净
```

多人协作时其他成员需 `git fetch` 后 `git reset --hard origin/main` 同步，否则本地仍会看到旧历史。

## 结语

撤销操作按优先级记忆：未推送用 `reset`，已推送优先 `revert`，必须改写历史时用 `rebase -i` + `--force-with-lease`。强制推送会改写远程历史，多人协作前务必沟通，或先建备份分支 `git branch backup`。

## 参考

[gitignore](https://github.com/github/gitignore)
