---
title: 合并两个仓库：merge、rebase、graft 怎么选
slug: git-merge-rebase-graft
date: 2026-10-14T14:57:00+08:00
description: 两个仓库的历史要合成一个，文件树却可能只要一边。merge、rebase、graft 分别改的是父指针还是快照？先看模型，再选方案。
tags:
  - git
  - merge
  - rebase
  - history-rewrite
categories:
  - git
draft: true
---

两个仓库要合成一个，历史也要接上。很多人搜到 `--allow-unrelated-histories` 就直接开跑，但如果你的真实要求是「最终只要新仓库的文件，旧仓库只提供历史」，跑完会发现旧文件全都还在。区别不在命令，在于每种做法改的是**父指针**还是**文件快照**。

## 先建立一个模型

一个提交由三部分组成：一张完整文件快照（tree）、一个或多个指向父提交的指针（parent）、作者与时间等元数据。历史关系只由 parent 决定，文件内容只由 tree 决定。

分支只是一个指向提交的指针，`HEAD` 表示你当前站在哪个分支上。`git diff` 不是存下来的，是拿两张快照现算的。

所以「合并历史」本质上只做两件事：改父指针、造新快照。下面三种做法的所有差异，都从这里来。

## merge：新增一个双父提交

```bash
git merge --allow-unrelated-histories old/main
```

merge 会新建一个提交，它有两个父提交：当前分支的末端和 `old/main` 的末端。快照是两边文件合并后的结果，所以可能冲突。历史形状是两条线在顶端汇合，不是一条线。

如果只要当前分支的文件、但想保留旧仓库历史，用 `-s ours`：

```bash
git merge --allow-unrelated-histories -s ours old/main -m "merge old history"
```

它同样有两个父提交，但快照只用当前分支的树，因此零冲突。注意是 `-s ours`（策略，丢弃对方整棵树），不是 `-X ours`（递归合并时冲突偏向 ours）。

## rebase：重放补丁，不是搬快照

```bash
git checkout -b old-linear old/main
git rebase main
git checkout main
git merge --ff-only old-linear
```

rebase 会把旧仓库每个提交的**改动**重放到新基底上，生成一串新提交。历史是一条线，每个提交只有一个父。

但它不会替换文件树。旧仓库的根提交在 Git 眼里是「新增这些文件」，重放到新仓库上，结果就是新仓库的文件加旧仓库的文件——两套目录都在。很多人以为 rebase 能「只保留一边的文件」，就是在这里踩坑。

rebase 后所有被重放的提交 hash 都会变，作者时间保留，提交者时间更新。改写历史前先看 [undo and rewrite history](git-undo-and-rewrite.md)。

## graft：只换父指针，不碰树

如果最终只要新仓库的文件，旧仓库只作为「前传」，那就不能合并文件树，只需要把新仓库**根提交的父提交**接到旧仓库末端：

```bash
git replace --graft $(git rev-list --max-parents=0 HEAD) old/main
```

`git log` 看起来立刻变成「旧仓库在前、新仓库在后」，而且新仓库的提交 hash 都没变。但 `replace` 只是本地便签，写在 `refs/replace/*` 下，默认不随 clone / push 传播；去掉它，历史又变回两条。

要让它变成真历史，得固化：

```bash
git filter-repo --force --replace-refs delete-no-add
```

或者用 `git commit-tree` 以原 tree、新 parent 逐条重建提交。固化后，新仓库的提交 hash 全变，旧仓库的 hash 不变，最终文件树一个字节都不动。旧仓库内部已有的 merge 提交会原样保留；这里说的「单线」指两段历史之间没有新增合并提交。完整步骤和校验方法见 [join unrelated histories](git-join-unrelated-histories.md)。

## 一张表

| 做法            | 父指针               | 快照                      | 历史形状   | 冲突 | hash |
| :-------------- | :------------------- | :------------------------ | :--------- | :--- | :--- |
| merge（普通）   | 新增提交，2 个父     | 两边合并                  | 分叉后汇合 | 可能 | 不改 |
| merge `-s ours` | 新增提交，2 个父     | 只用当前分支              | 分叉后汇合 | 无   | 不改 |
| rebase          | 每条提交改父，单父   | 基底 + 补丁（通常是并集） | 一条线     | 可能 | 改写 |
| graft + 固化    | 只改根提交的父，单父 | 原样不动                  | 一条线     | 无   | 改写 |

一个容易忽略的点：merge 和 rebase 的最终文件树可能完全一样，但历史结构完全不同；`merge -s ours` 和 graft 的最终文件树也可能完全一样，但一个分叉、一个单线。所以「文件一样」不等于「历史一样」。

## 怎么选

按顺序问三个问题：

1. **最终工作区要谁的文件？** 两边都要 → merge 或 rebase；只要一边 → graft 或 `-s ours`。
2. **历史要不要一条线？** 要 → rebase 或 graft；不要 → merge。
3. **能不能接受 hash 改写？** 不能 → merge（包括 `-s ours`）；能 → rebase 或 graft。

还有一个前提：两边的提交可以都有用，但只有一边的文件是最终形态，这属于 graft 的场景；如果两边文件都要保留，就别用 graft，因为它会把旧文件全部丢掉。

## 结语

先确定最终工作区要谁的文件，再决定历史要不要单线，最后确认能否接受 hash 改写。三句话定完，merge、rebase、graft 该用哪个就没有歧义了。[^1]

[^1]: [Pro Git: Git Internals](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects)
