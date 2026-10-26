---
title: 把两段无关的 Git 历史拼成一条线
slug: git-join-unrelated-histories
date: 2026-10-04T14:16:00+08:00
description: 两个仓库没有共同祖先，却要旧历史在前、新仓库历史在后，且新仓库文件树不变。merge 和 rebase 都不行，只能改写根提交的父节点。
tags:
  - git
  - history-rewrite
  - migration
categories:
  - git
draft: true
---

旧仓库退役、新仓库是它重构后的结果，两边各自独立提交，却要求最终历史是「旧仓库全部提交在前、新仓库全部提交在后」，并且新仓库工作区的文件一个都不变。`git merge` 和 `git rebase` 都满足不了这两个条件，得直接重建提交、只改父节点。

## 为什么 merge 和 rebase 都不行

`git merge --allow-unrelated-histories` 会生成一个有两个父提交的合并节点：历史从一条线变成两条线的汇合点，冲突还得手工处理。

`git rebase --onto old/main --root main` 看起来更接近，但它重放的是**补丁**而不是快照。新仓库的根提交在 Git 眼里是「新增这些文件」，不是「把整棵树替换成这些文件」；重放完成后，旧仓库的文件会原样留在工作区，最终得到两套目录的并集。撤销与改写的基础操作见 [undo and rewrite history](git-undo-and-rewrite.md)。

## 换父节点，不换树

一个提交由三部分组成：文件树（tree）、父提交（parent）、元数据。历史关系只由 parent 决定，文件内容只由 tree 决定。

因此，只要把新仓库**根提交**的 parent 指向旧仓库的 tip，同时让新仓库每个提交的 tree 保持原样，就能得到一条「旧库 → 新库」的单线历史，且最终工作区完全不变。代价有两个：

- 新仓库所有提交的 hash 都会变（parent 变了，hash 必然变）；
- 拼接点那次提交的 diff 会非常大：旧结构整体删除、新结构整体加入。这不是重建出错，而是两套目录结构本来就不兼容的真实快照。

旧仓库自身已有的 merge 提交会原样保留；这里的「线性」指两段历史之间没有新增合并提交。

## 操作步骤

### 备份

```bash
git branch backup/pre-merge
```

### 取出旧仓库的历史

```bash
git fetch D:/path/to/old-repo main
base=$(git rev-parse FETCH_HEAD)
old=$(git rev-parse main)
N=$(git rev-list --count main)
```

旧仓库是本地目录时直接 `fetch` 路径即可，不必配置 remote。

### 用原树和新父节点重建提交

```bash
new=$base
for c in $(git rev-list --reverse main); do
  tree=$(git show -s --format=%T "$c")
  msg=$(mktemp)
  git show -s --format=%B "$c" > "$msg"
  export GIT_AUTHOR_NAME=$(git show -s --format=%an "$c")
  export GIT_AUTHOR_EMAIL=$(git show -s --format=%ae "$c")
  export GIT_AUTHOR_DATE=$(git show -s --format=%aI "$c")
  export GIT_COMMITTER_NAME=$(git show -s --format=%cn "$c")
  export GIT_COMMITTER_EMAIL=$(git show -s --format=%ce "$c")
  export GIT_COMMITTER_DATE=$(git show -s --format=%cI "$c")
  new=$(git commit-tree "$tree" -p "$new" -F "$msg")
  rm -f "$msg"
done
```

`commit-tree` 接收三个输入：原 tree、新 parent、原提交信息；作者与提交者信息从原提交读出，通过 `GIT_*` 环境变量传入，时间戳和身份都不变。

### 校验

```bash
git diff --quiet "$old" "$new" && echo OK   # 最终树必须与原 main 完全一致
git rev-parse "$new~$N"                     # 必须等于 $base
git rev-list --count "$new"                 # 必须等于旧库提交数 + N
```

三条都通过，再往下走。

### 移动分支

```bash
git update-ref refs/heads/main "$new" "$old"
```

`update-ref` 只改 ref 指针，不碰 index 和工作区；有未提交改动也不会被清掉。用 `git reset --soft "$new"` 效果相同，但 `update-ref` 的第三个参数会校验旧值，指错时会直接报错而不是悄悄覆盖。

### 接上远程

```bash
git remote add origin git@github.com:you/notes.git
git fetch origin
git branch -u origin/main
```

远程 tip 是旧仓库 tip 或它的祖先时，`git push` 是快进；否则需要 `git push --force-with-lease`。两边历史完全无关时，先看 [pushing to an existing remote](git-push-existing-remote.md)。

## 几个容易踩的点

- `git replace --graft` 能一行完成同样的嫁接，但 `refs/replace/*` 默认不会被推送，别人 clone 下来看到的还是两条历史。要真正改写，只能用 `commit-tree` 重建。
- 时间戳沿用原值，拼接后出现「父提交比子提交新」很正常；看结构用 `git log --graph`，不要按日期推断先后。
- 拼接点是整树替换，`git log --follow` 依赖重命名检测，跨过拼接点不一定能接上原文件历史。
- 脚本假设新仓库自身是线性历史（`git rev-list --reverse` 才能保证父提交在前）；新仓库里有 merge 时，先按拓扑序生成列表，或先压平再拼。
- 备份分支在确认远程和历史都正常之前不要删；`git reflog` 只在本地有效。

## 结语

需要「历史拼接 + 工作区不变」时，merge 会引入第二个父提交，rebase 会把旧文件带进新树。用 `commit-tree` 以原树重建提交、只换根提交的父节点，再用 `update-ref` 移动分支，才能同时满足两个条件。[^1]

[^1]: [git-commit-tree manual](https://git-scm.com/docs/git-commit-tree)
