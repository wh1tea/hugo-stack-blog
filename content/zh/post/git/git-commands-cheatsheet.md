---
title: Git 命令速查手册
description: 覆盖仓库、暂存、分支、历史、撤销、远程六大场景的 Git 命令速查表，附常用示例与进阶阅读链接
slug: git-commands-cheatsheet
date: 2026-08-14
tags:
  - git
  - cheatsheet
  - command-line
categories:
  - tutorial
---

> 本文面向已会基本操作的开发者：按场景分类速查 Git 常用命令，每条附作用与示例。
> 安装配置、SSH 认证、历史改写等完整流程见文末「扩展阅读」链接。

---

## 一、仓库生命周期

| 命令         | 缩写来源       | 说明                   | 示例                                         |
| ------------ | -------------- | ---------------------- | -------------------------------------------- |
| `git init`   | **Init**ialize | 初始化新仓库           | `git init`                                   |
| `git clone`  | —              | 克隆远程仓库到本地     | `git clone git@github.com:user/repo.git`     |
| `git status` | —              | 查看工作区与暂存区状态 | `git status -s`（精简输出）                  |
| `git remote` | —              | 管理远程仓库关联       | `git remote -v`、`git remote add origin URL` |
| `git rm`     | **R**e**m**ove | 删除文件并从版本库移除 | `git rm --cached .env`（仅取消跟踪）         |
| `git mv`     | **M**o**v**e   | 移动或重命名文件       | `git mv old.txt new.txt`                     |

---

## 二、暂存与提交

| 命令                 | 说明                         | 示例                                                    |
| -------------------- | ---------------------------- | ------------------------------------------------------- |
| `git add`            | 添加文件到暂存区             | `git add .`、`git add src/*.py`                         |
| `git commit`         | 提交暂存区内容               | `git commit -m "feat: add login"`                       |
| `git commit --amend` | 修改最近一次提交信息         | `git commit --amend -m "新信息"`                        |
| `git stash`          | 暂存未提交的改动，清空工作区 | `git stash`、`git stash pop` 恢复                       |
| `git stash list`     | 查看暂存队列                 | `git stash list`                                        |
| `git restore`        | 撤销工作区或暂存区的改动     | `git restore file.txt`、`git restore --staged file.txt` |

---

## 三、分支与合并

| 命令              | 说明                         | 示例                                           |
| ----------------- | ---------------------------- | ---------------------------------------------- |
| `git branch`      | 查看 / 创建 / 删除分支       | `git branch -a`、`git branch -d old`           |
| `git switch`      | 切换分支                     | `git switch -c feature/x`（新建并切换）        |
| `git checkout`    | 切换分支或还原文件（旧写法） | `git checkout main`                            |
| `git merge`       | 合并指定分支到当前分支       | `git merge feature/x`                          |
| `git rebase`      | 变基：把提交重放到新基线     | `git rebase main`                              |
| `git cherry-pick` | 把其他分支的提交挑到当前分支 | `git cherry-pick abc1234`                      |
| `git tag`         | 打标签（版本号）             | `git tag v1.0.0`、`git tag -a v1.0.0 -m "msg"` |

---

## 四、查看历史

| 命令        | 缩写来源       | 说明                         | 示例                              |
| ----------- | -------------- | ---------------------------- | --------------------------------- |
| `git log`   | —              | 查看提交历史                 | `git log --oneline --graph --all` |
| `git show`  | —              | 查看某次提交的详情与改动     | `git show abc1234`                |
| `git diff`  | **Diff**erence | 查看工作区与暂存区差异       | `git diff`、`git diff --staged`   |
| `git blame` | —              | 逐行追溯文件每行的最后修改者 | `git blame file.txt`              |
| `git grep`  | —              | 在版本库中搜索内容           | `git grep "TODO"`                 |

---

## 五、撤销与恢复

| 命令         | 缩写来源              | 说明                                 | 示例                                                 |
| ------------ | --------------------- | ------------------------------------ | ---------------------------------------------------- |
| `git reset`  | —                     | 回退提交指针，可选保留改动           | `git reset --soft HEAD~1`、`git reset --hard HEAD~1` |
| `git revert` | —                     | 生成反向提交撤销指定提交（保留历史） | `git revert HEAD`                                    |
| `git clean`  | —                     | 删除未跟踪文件                       | `git clean -fd`（含目录，谨慎）                      |
| `git reflog` | **Ref**erence **Log** | 查看所有 HEAD 移动记录，找回误删提交 | `git reflog`                                         |

`reset` 与 `revert` 的选择：未推送用 `reset`，已推送优先 `revert`；改写历史需 `git push --force-with-lease`。详细场景见 [Git 撤销与修改提交历史](git-undo-and-rewrite.md)。

---

## 六、远程协作

| 命令                          | 说明                   | 示例                                |
| ----------------------------- | ---------------------- | ----------------------------------- |
| `git fetch`                   | 拉取远程更新，不合并   | `git fetch origin`                  |
| `git pull`                    | 拉取并合并远程分支     | `git pull --rebase`（变基方式拉取） |
| `git push`                    | 推送本地提交到远程     | `git push -u origin main`           |
| `git push --force-with-lease` | 强制推送（带安全检查） | `git push --force-with-lease`       |

---

## 七、配置与技巧

| 命令                        | 缩写来源          | 说明            | 示例                                                          |
| --------------------------- | ----------------- | --------------- | ------------------------------------------------------------- |
| `git config`                | **Config**uration | 查看 / 设置配置 | `git config --global user.name`、`git config --global --list` |
| `git config --global alias` | —                 | 设置命令别名    | `git config --global alias.co checkout`                       |
| `git help`                  | —                 | 查看命令文档    | `git help log`、`git log --help`                              |

高频组合速记：

```bash
git log --oneline --graph --all   # 分支图
git log -p                        # 带 diff 的历史
git diff HEAD                     # 未提交的全部改动
git show HEAD                     # 最近一次提交
```

## 结语

Git 命令虽多，日常八成工作只集中在 `status`、`add`、`commit`、`push`、`log`、`branch`、`switch` 这七条上。先背熟基础流程，再按场景查表即可。遇到报错不要慌，多数错误信息都自带修复提示。

扩展阅读：

- [Git 入门：从安装到第一次推送](git-quickstart.md)
- [GitHub SSH 认证配置指南](git-github-ssh.md)
- [Git 撤销与修改提交历史](git-undo-and-rewrite.md)
- [Git 取消追踪与仓库解绑](git-untrack-and-unlink.md)
- [本地仓库推送到已有远程仓库](git-push-existing-remote.md)
