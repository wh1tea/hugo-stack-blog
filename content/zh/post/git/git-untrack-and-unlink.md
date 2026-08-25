---
title: Git 取消追踪与仓库解绑
slug: git-untrack-and-unlink
date: 2025-09-04
description: git rm --cached 停止跟踪、只追踪指定文件、移除远程关联、删除整个仓库
tags:
  - git
categories:
  - git
---

配置文件、密钥、`node_modules` 不小心被提交了？想让 Git 只跟踪某些文件？本文覆盖取消追踪的三种场景：停用单个文件跟踪、解除远程关联、彻底删除仓库。

## 停止跟踪文件但保留本地

把文件移出版本控制、磁盘文件保留，分两步：

```bash
git rm --cached file.txt          # 单个文件
git rm -r --cached node_modules/  # 整个目录
git commit -m "Stop tracking file.txt"
git push
```

配合 `.gitignore` 先写规则再移除，避免下次又加回来：

```text
file.txt
node_modules/
```

协作者需要手动删除本地副本再拉取，远程历史里仍能看到旧版本。

## 只追踪特定文件

想让 Git 只跟踪 `.cpp` / `.h`，忽略其他一切，在`.gitignore`用 `*` 全忽略 + `!` 取反：

```text
*
!*.cpp
!*.h
!.gitignore
```

先忽略所有文件，再用 `!` 规则收回指定类型。注意 `!` 无法匹配已被忽略目录内的文件，规则要写在正确层级。

## 解除远程仓库关联

```bash
git remote -v                # 查看当前远程
git remote remove origin     # 移除关联
```

移除关联不影响本地提交历史，想重新关联随时 `git remote add origin <url>`。

## 彻底删除仓库

想停止版本控制、把项目变成普通目录，删除 `.git` 目录即可：

```bash
rm -rf .git
git status    # 提示 not a git repository
```

此操作**不可逆**，所有提交历史、分支、配置一并消失，操作前务必确认已备份或不再需要历史。

## 结语

取消追踪的三个层次：`git rm --cached` 停止跟踪单个文件、`git remote remove` 解除远程关联、`rm -rf .git` 终止整个仓库。日常最常用的是第一种，配合 `.gitignore` 从源头避免误提交。
