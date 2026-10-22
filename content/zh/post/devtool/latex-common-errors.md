---
title: LaTeX 两个常见报错
slug: latex-common-errors
date: 2024-03-15T21:09:00+08:00
description: ctex 下 FandolSong 的 fontspec 警告、BibTeX 的 no citation commands：分别是什么原因、要不要管、怎么处理
tags:
  - latex
  - texlive
  - troubleshooting
categories:
  - devtool
---

两个报错表面上都让人以为字体或参考文献坏了，实际一个可以无视，一个必须改编译流程。

## 报错一：Font "FandolSong-Regular" does not contain requested Script "CJK"

用 XeLaTeX + ctex 编译时，日志里会反复刷这一行：

```text
Package fontspec Warning: Font "FandolSong-Regular" does not contain
requested (fontspec) Script "CJK".
```

fontspec 会检查字体有没有声明支持所请求的 script，Fandol 系列没有声明，于是每次切换字族都报一次。

**这是警告不是错误**：PDF 里的中文照常输出。Fandol 是 ctex 默认的中文字体集，字形是全的，这条属于 fontspec 的误报[^1]。

嫌日志吵就关掉 fontspec 的警告，注意 `\PassOptionsToPackage` 必须写在载入 ctex 之前——fontspec 是 ctex 内部才载入的：

```latex
\documentclass{article}
\PassOptionsToPackage{quiet}{fontspec}
\usepackage[UTF8]{ctex}
```

如果中文**真的没输出**，那不是这条警告的问题，而是字体层的问题：Windows 上可以让 ctex 用系统字体，`\usepackage[fontset=windows]{ctex}`，或换 `fontset=fandol` 后确认 TeX 发行版里装了 Fandol。

## 报错二：I found no \citation commands

BibTeX 一跑就报三条：

```text
I found no \citation commands---while reading file document.aux
I found no \bibdata command---while reading file document.aux
I found no \bibstyle command---while reading file document.aux
(There were 3 error messages)
```

`.aux` 里没有任何引用信息，BibTeX 无从下手。三种来源：

1. 正文里根本没写 `\cite`，却跑了 bibtex；
2. 写了 `\cite` 但没重新编译 LaTeX，`.aux` 还是上一版（甚至不存在）；
3. 只写了 `\bibliography{refs}` 没写 `\bibliographystyle{...}`，或反之，条目不全。

处理：确认正文有 `\cite{key}`，按 `xelatex → bibtex → xelatex → xelatex` 的顺序跑；还报同样的错就删掉 `.aux` / `.bbl` / `.blg` 重来。用 latexmk 的话一条命令代替这串：

```bash
latexmk -xelatex document.tex
```

## 结语

前一个可以无视（或在导言区关掉 fontspec 警告），后一个是编译顺序或 `\cite` 缺失，按 xelatex → bibtex → xelatex → xelatex 走一遍即可。

[^1]: [fontspec issue #346：Script option 从 v2.6j 起报出过多警告](https://github.com/latex3/fontspec/issues/346)
