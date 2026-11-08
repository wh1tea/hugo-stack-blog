---
title: 头像
slug: avatar
date: 2026-11-08
description: 用 DiceBear API、生成器和 SVGO 为技术博客制作简洁可定制的 SVG 头像。
tags:
  - svg
  - avatar
  - profile
  - cli
categories:
  - devtool
draft: true
---

技术博客的头像不需要照片，也不应该是一张随手截图。简洁的 SVG 头像是更合适的选择：文件体积小、任意尺寸不模糊，配色和形状可以直接改。下面按从“零操作”到“可脚本化”的顺序，给出几种生成或获取技术风格 SVG 头像的路径。

## 用 DiceBear HTTP API 直接拿到 SVG

DiceBear 提供无需认证的 HTTP API，把 URL 当作头像地址即可。基本形式是：

```text
https://api.dicebear.com/10.x/<styleName>/svg?seed=<your-id>
```

`styleName` 替换为具体样式，`seed` 换成你的用户名或任意稳定标识符。同一个 seed 每次返回同一张图，适合作为博客的作者头像或评论默认头像。如果 seed 包含空格或特殊字符，先做 URL 编码。

以下是几个几何抽象、视觉上偏“技术感”的样式：

- `rings`：分段同心圆环，单色透明背景，像工程图纸。
- `squircles`：层叠的圆角矩形，带轻微偏移高光。
- `blobs`：同一色相下逐层变浅的柔和有机形状。
- `waves`：同一颜色的波纹条带层叠，节奏感强。

以 `rings` 为例，获取一个 SVG 头像：

```bash
curl "https://api.dicebear.com/10.x/rings/svg?seed=your-blog-name" -o avatar.svg
```

DiceBear 的 `rings` 样式还提供预设配色，可以直接通过 `backgroundColor` 和 `ringColor` 查询参数覆盖默认色板。例如 `Duotone` 预设（浅灰蓝背景 + 深靛蓝圆环）：

```text
https://api.dicebear.com/10.x/rings/svg?seed=your-blog-name&backgroundColor=dfe3f5&ringColor=3d4272
```

配色数组在 URL 中用逗号分隔。`10.x` 是当前活跃版本，旧版本有明确的停止维护时间，不建议新项目使用。

## 使用专业生成器挑选科技主题风格

如果希望头像是“电路”“网格”“蓝图”这类更直白的科技元素，Profile Icon Generator 是一个开源的网页工具，提供 15 种以上抽象风格，其中与技术感直接相关的包括：

- `Geometric`：干净对称的几何图形，现代技术感。
- `Circuit`：电路板线条与节点。
- `Tech Grid`：未来感网格与点阵。
- `Blueprint`：工程图纸式的网格与圆圈。
- `Monogram`：首字母叠加在几何背景上，兼顾个人标识与简洁。

该工具完全在浏览器中运行，基于用户名或姓名生成图案，可以切换配色，并叠加首字母。它导出的直接结果是 **256×256 PNG**，而不是 SVG。如果坚持使用 SVG，DiceBear 的几何样式是更原生的选择；Profile Icon Generator 适合快速预览和确定风格方向。

## 语言专属头像：Go 的 Gopher

博客如果专注 Go 语言，使用 Gopher 形象有明确的社区归属感。`gopherize-me` 支持命令行生成 Gopher 头像：

```bash
go install github.com/mvdan/gopherize-me/cmd/gopherize-me@latest

gopherize-me -output avatar.png -color "#00ADD8" -pose "coding"
```

`-pose` 支持 `default`、`coding`、`thinking` 等语义化姿态，`-color` 可以设为 Go 官方蓝 `#00ADD8`。CLI 默认输出 PNG，也可以访问 gopherize.me 网站在线拖拽生成并导出 SVG。

Go 社区推崇的头像设计原则是“少即是多”：清晰的几何结构、高对比配色、避免复杂渐变和过度装饰。这个原则并不限于 Go，任何追求技术感的头像都可以套用。

## 用 SVGO 压缩最终 SVG

无论来自 DiceBear API 还是其他生成器，导出的 SVG 通常包含编辑器元数据、注释和冗余路径。SVGO 是 Node.js 编写的 SVG 优化工具，通过命令行可以快速去除这些不影响渲染的内容。

全局安装后优化单个文件：

```bash
npm install -g svgo
svgo --multipass avatar.svg
```

`--multipass` 让优化器多次运行直到收敛，通常比单次优化得到更小的体积。如果不想覆盖原文件，用 `-o` 指定输出路径：

```bash
svgo --multipass avatar.svg -o avatar.min.svg
```

## 结语

优先从 DiceBear 的 `rings` 或 `blobs` 样式开始：一个 URL 就能拿到稳定、可定制的 SVG，不需要安装任何工具。需要更直白的科技元素时，用 Profile Icon Generator 确定方向；Go 技术博客则直接用 `gopherize-me`。最后把 SVG 过一遍 `svgo --multipass`，让头像文件尽可能轻。

[^1]: [DiceBear HTTP API documentation](https://www.dicebear.com/how-to-use/http-api/index.md)
[^2]: [DiceBear Rings presets](https://www.dicebear.com/styles/rings/presets/index.md)
[^3]: [Profile Icon Generator on GitHub](https://github.com/HenryLok0/profile-icon-generator)
[^4]: [gopherize-me CLI usage](https://datasea.cn/go0624618490.html)
[^5]: [SVGO command-line usage](https://github.com/svg/svgo)
