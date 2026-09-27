---
title: Pandoc 入门：一个命令搞定文档转换
slug: pandoc
date: 2024-03-21T19:39:00+08:00
description: Pandoc 命令行文档转换工具的基础用法与高频技巧，含东亚文字换行、标题层级调整、媒体提取、直引号转换
tags:
  - pandoc
  - cli
  - markdown
categories:
  - tutorial
---
`pandoc` 是开源的命令行文档转换工具，支持几十种格式互转。日常最常用的场景之一是把 Word 文档转成 LaTeX[^1]：

```bash
pandoc -s input.docx -o output.tex
```

其中 `input.docx` 是待转换的 Word 文档，`output.tex` 是输出的 LaTeX 文件。

本文面向有编程基础、想在命令行里处理文档格式转换的开发者，读完能掌握 Pandoc 的基础用法和几个高频技巧。转换后的 LaTeX 文件通常还需进一步编辑和格式化，才能满足排版需求。

## 安装与基本用法

各平台的包管理器都能装：

```bash
# Windows (Chocolatey)
choco install pandoc

# macOS (Homebrew)
brew install pandoc

# Linux (APT)
sudo apt-get install pandoc
```

装完用 `pandoc --version` 验证。

基本调用格式：

```bash
pandoc [options] [input-file]...
```

比如把 TXT 转成 HTML：

```bash
pandoc -f markdown input.txt -t html -o output.html
```

`-f` 指定输入格式（也可写 `--from`、`-r`），`-t` 指定输出格式（也可写 `--to`、`-w`），`-o` 指定输出文件（也可写 `--output`）。格式通常可省略，Pandoc 会按扩展名推测：`.txt`、`.md`、`.markdown` 视为 Markdown，`.html` 视为 HTML。上面的命令可简写为：

```bash
pandoc input.txt -o output.html
```

## 输入输出不限于文件

没指定输入文件时 Pandoc 从 stdin 读入，没指定输出文件时写到 stdout。因此可以和其他命令行工具串联：

```bash
echo 'hello world' | pandoc
```

输出：

```html
<p>hello world</p>
```

一个实用组合是处理非 UTF-8 编码的文件：

```bash
iconv -t utf-8 input.txt | pandoc | iconv -f utf-8
```

## 处理东亚文字换行

Markdown 里单个换行会渲染成一个空格，这对「一句话换一行」的写作方式很不友好。开启 `east_asian_line_breaks` 扩展可以忽略东亚文字中的单个换行：

```bash
echo '忽略\n\n中文段落里\n单个换行符。ignore the newline\n within\n\na paragraph' \
  | pandoc --from markdown+east_asian_line_breaks --to html
```

输出：

```html
<p>忽略</p>
<p>中文段落里单个换行符。ignore the newline within</p>
<p>a paragraph</p>
```

不开启该扩展时，单个换行会变成空格。Pandoc 还有个类似的 `ignore_line_breaks` 扩展，但 `east_asian_line_breaks` 考虑了中英混排的情形，更推荐。

## 调整标题层级

`--shift-heading-level-by=NUMBER` 可整体升降标题层级，数字为 1 时一级标题降为二级，为 -1 时二级标题升为一级：

```bash
echo '## 二级标题变成一级标题\n\n### 三级标题变成二级标题\n\n开始正文' \
  | pandoc --shift-heading-level-by=-1 --to html
```

输出：

```html
<h1 id="二级标题变成一级标题">二级标题变成一级标题</h1>
<h2 id="三级标题变成二级标题">三级标题变成二级标题</h2>
<p>开始正文</p>
```

Markdown 的 `##` 变成了 HTML 的 `h1`，`###` 变成了 `h2`。

## 提取媒体文件

`--extract-media=DIR` 能把转换过程中的图片等媒体文件提取出来。以 Word 转 Markdown 为例：

```bash
pandoc test.docx --extract-media=. -o test.md
```

会得到 `test.md` 和一个 `media` 文件夹，里面是 Word 文档中的所有图片。

这个选项还能把 Markdown 里的图床链接替换为本地图片链接：

```bash
pandoc --wrap=preserve -f markdown input.md --extract-media=media -t markdown -o output.md
```

Pandoc 会下载远程图片到 `media` 文件夹，并自动替换 `output.md` 里的链接，图片名按内容的 SHA1 哈希值构建。比起用 `curl` / `wget` 下载再用正则替换，这条命令简单得多。

## 直引号转弯引号

正式英文写作中应使用弯引号，Pandoc 的 `smart` 扩展（默认开启）可自动转换：

```bash
echo I\'m a sentence with \'single quotes\', \"double quotes\". \
  | pandoc --wrap=preserve --to markdown-smart
```

输出：

```text
I’m a sentence with ‘single quotes’, “double quotes”.
```

注意上面的 `\'` 和 `\"` 是 Shell 转义写法，实际写作不需要反斜杠。当输出格式是 Markdown 时 `smart` 会有相反效果（弯引号转直引号），所以用 `--to markdown-smart` 关闭它。除引号外，`smart` 还会把 `--` 转 En-dash、`---` 转 Em-dash、`...` 转省略号。

## 结语

Pandoc 参数极多，遇到问题优先查 Pandoc 用户手册[^2]。R Markdown 开发者谢益辉的建议值得听：至少完整读一遍手册，才会真正体会到 Pandoc's Markdown 的强大。

[^1]:[Pandoc 从入门到精通，你也可以学会这一个文本转换利器 - 少数派](https://sspai.com/post/77206)
[^2]:[Pandoc 手册](https://pandoc.cn/)