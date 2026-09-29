---
title: Git 换行符：LF、CRLF 与整文件 diff 的坑
slug: git-line-endings
date: 2026-08-13T21:00:00+08:00
description: 解释 LF 与 CRLF 的区别、整文件 diff 的成因，以及为什么 core.autocrlf=true 下工作区无法真正统一换行符，只有 .gitattributes 能解决
tags:
  - git
  - configuration
  - troubleshooting
categories:
  - git
---

仓库里明明只有 LF，工作区却总是 CRLF；手动改成 LF，下次 checkout 又变回去，`git diff` 还看不见这次改动。这不是操作问题，是 Git for Windows 的默认配置在起作用。下面从换行符本身讲到这个坑的成因和唯一解法。

## LF 与 CRLF

换行符有两种常见表示：

| 类型 | 字符                    | 常见系统           |
| :--- | :---------------------- | :----------------- |
| LF   | `\n`（ASCII 10）        | Linux、Unix、macOS |
| CRLF | `\r\n`（ASCII 13 + 10） | Windows、DOS       |

早期电传打字机里，CR 把打印头移回行首，LF 把纸张推进一行，两个动作合起来才是「回到下一行开头」。Windows 继承了这个组合，Unix 后来简化成只用 LF。

跨平台打开文件时，Linux 下常看到 Windows 文件每行末尾多一个 `^M`，那就是 CRLF 里的 `\r`。

## 整文件 diff 是什么

Git 比较文件时，正常 diff 只显示改动的行：

```diff
 这是第一行
-这是旧内容
+这是新内容
 这是第三行
```

整文件 diff 则是整个文件被标成全删全增：

```diff
-这是第一行
-这是旧内容
-这是第三行
+这是第一行
+这是新内容
+这是第三行
```

明明只改了一行，Git 却认为每一行都变了。最常见的原因就是**换行符不一致**：文件原本是 LF，保存后变成 CRLF，Git 逐行比较时发现每行结尾都不同，于是判定整个文件都变了。其他原因还有编码改变（UTF-8 → UTF-8 BOM）、文件权限变化、编辑器自动格式化。

在 Hugo 博客里，典型表现是：只改了一个错别字，提交时 GitHub 显示「200 additions, 200 deletions」，而不是「1 addition, 1 deletion」。

## 这个坑：工作区无法真正统一

很多人以为「仓库 blob 是 LF，那工作区也改成 LF 就统一了」。实际上做不到。

### 仓库侧本来就是 LF

Git 的 blob 默认就是 LF，这点没问题。

### 工作区的 CRLF 来自 core.autocrlf=true

Git for Windows 安装时默认勾选 `core.autocrlf=true`，它是系统级 gitconfig，不在仓库里。含义是：

| 方向                    | 行为      |
| :---------------------- | :-------- |
| 提交时（工作区 → 仓库） | CRLF → LF |
| 检出时（仓库 → 工作区） | LF → CRLF |

所以仓库 blob 永远是 LF，工作区永远是 CRLF。

### 手动归一是暂时的

在工作区把文件改成 LF，`git add` 时 Git 发现工作区是 LF，`autocrlf=true` 想转成 LF 再存，结果一样，**无变化**。blob 本来就没变，`git diff` 看不见任何东西。下次 `git checkout`、`git reset --hard` 或重新 clone，Git 又按 `autocrlf=true` 把 LF 转成 CRLF 写回工作区。

更麻烦的是「看不见」：因为 blob 一直是 LF，Git 认为没改，这次归一既没被记录，也没被保留。工作区永远回不到 LF，除非改配置或加 `.gitattributes`。

## 唯一解法：.gitattributes

`.gitattributes` 的优先级**高于** `core.autocrlf`。在仓库根目录创建：

```gitattributes
*.md text eol=lf
```

含义是：`*.md` 是文本文件，无论 checkout 还是提交，工作区和仓库都用 LF。一旦这个文件进了仓库，任何人在任何系统 clone，`*.md` 都会被写成 LF，`core.autocrlf` 对 `.md` 失效。

常用配置：

```gitattributes
*.md   text eol=lf
*.txt  text eol=lf
*.yml  text eol=lf
*.yaml text eol=lf
*.toml text eol=lf
*.html text eol=lf
*.css  text eol=lf
*.js   text eol=lf

*.png  binary
*.jpg  binary
*.woff2 binary
```

操作步骤：

1. 创建 `.gitattributes` 并提交。
2. 跑 `git add --renormalize .`，如果显示很多文件被修改，说明 blob 里之前混了 CRLF，现在被统一成 LF，正常提交即可。如果什么都不显示，说明仓库侧本来就干净，问题只出在工作区。
3. 刷新工作区：`git rm --cached -r . && git reset --hard`，或者直接重新 clone。之后工作区的 `.md` 就是 LF，不会再被 `autocrlf` 转回 CRLF。

如果只想影响自己，可以在仓库里设 `git config core.autocrlf false`，但 `.gitattributes` 影响所有人，是更彻底的做法。

## 结语

换行符问题的根源不在仓库，而在 checkout 时的自动转换。手动改工作区只是一时的，`git diff` 也看不见；加一个 `.gitattributes` 声明 `*.md text eol=lf`，才能同时锁死工作区和仓库，让整文件 diff 和 CRLF 反复出现的问题永久消失。