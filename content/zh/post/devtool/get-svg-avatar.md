---
title: 获取 SVG 头像
slug: get-svg-avatar
date: 2026-11-08T10:09:23+08:00
description: 用 DiceBear 的 HTTP API 直接拿到可缩放、可改色的 SVG 头像，再用 SVGO 把体积压下来。
tags:
  - svg
  - avatar
  - cli
categories:
  - devtool
---

技术博客的头像用 SVG 比用照片省事：文件小、放大到任意尺寸都不糊、配色和形状可以直接改。最省事的做法是让 DiceBear 按一个固定 seed 生成，再按站点配色改两个色值；只有需要更具体的科技元素时，才值得打开在线生成器。

## DiceBear：一条 URL 拿到 SVG

DiceBear 的 HTTP API 不需要认证，把下面的地址当头像地址用即可[^1]：

```text
https://api.dicebear.com/10.x/<styleName>/svg?seed=<your-id>
```

`styleName` 换成样式名，`seed` 换成稳定的标识符（用户名或站点名都行）。同一个 seed 每次返回同一张图，seed 里有空格或特殊字符时先做 URL 编码。

以 `rings` 为例，直接下载成文件：

```bash
curl "https://api.dicebear.com/10.x/rings/svg?seed=your-blog-name" -o avatar.svg
```

打开 `avatar.svg`，文件开头是 `<svg ...>`，说明拿到的是矢量图，而不是一张改了后缀的位图。

## 挑一种几何风格

DiceBear 的样式很多，偏几何抽象、适合放在技术博客侧边栏的有这几个：

- `rings`：分段同心圆环和圆弧，单色、透明背景，像工程图纸上的标记。
- `squircles`：层叠的圆角矩形，带轻微偏移。
- `blobs`：同一色相下逐层变浅的有机形状。
- `waves`：同一颜色的波纹条带层叠。

这些样式都能直接把 API 地址当图片源，写进页面或主题配置就行：

```html
<img src="https://api.dicebear.com/10.x/rings/svg?seed=your-blog-name" alt="avatar" />
```

## 改配色：预设与查询参数

`rings` 内置 8 组预设，`Duotone` 是最克制的一组：浅灰蓝背景配深靛蓝圆环。把两个色值直接写进查询参数就得到同样的效果，十六进制颜色不用带 `#`[^2]：

```text
https://api.dicebear.com/10.x/rings/svg?seed=your-blog-name&backgroundColor=dfe3f5&ringColor=3d4272
```

需要多色时，颜色参数接受逗号分隔的数组：`ringColor=3d4272,8a6a48` 把颜色分给几个圆环。`ringColorFill` 还能设成 `linear` 或 `radial`，配 `ringColorAngle` 调角度。

版本号写在 URL 里。`10.x` 是当前主版本，`9.x` 仍在服务；`5.x` 到 `8.x` 已标记弃用，官方计划在 2028-04-30 停掉这些版本的 HTTP API[^1]。

## 只能出 PNG 的在线工具

有两个常被提到的生成器适合快速定风格，但都拿不到 SVG：

- **Profile Icon Generator**：在浏览器里基于用户名生成图案，内置 Geometric、Circuit、Tech Grid、Blueprint、Monogram 等一批抽象风格，可以换配色、叠加首字母，下载结果是 256×256 的 PNG[^3]。先用它挑中构图，再回到 DiceBear 或矢量工具复刻，比直接拿 PNG 当头像耐放大。可以从[在线版](https://henrylok0.github.io/profile-icon-generator/)直接试。
- **Gopherize.me**：Go 博客的 Gopher 拼图工具，选中各个部位后保存出来也是 PNG（美术素材来自 Ashley McNamara，原作是 Renee French 的 Gopher）[^4]。它是在线应用，只输出位图。

## 用 SVGO 压掉冗余

从 API 或编辑器导出的 SVG 常带着元数据、注释和多余路径。SVGO 是 Node.js 写的 SVG 优化器，命令行就能处理[^5]：

```bash
npm install -g svgo
svgo --multipass avatar.svg
```

`--multipass` 会反复优化直到结果不再变化；想保留原文件就用 `-o` 指定输出：

```bash
svgo --multipass avatar.svg -o avatar.min.svg
```

命令跑完会打印优化前后的体积和百分比，看到体积下降、浏览器打开图片显示正常，就说明没有压坏。

## 结语

先把 `rings` 加 `Duotone` 挂上去，再按站点配色微调那两个十六进制值；以后想换风格，换掉 URL 里的样式名重新下一张即可。

[^1]: [DiceBear HTTP API](https://www.dicebear.com/integrations/http-api/)
[^2]: [Rings presets](https://www.dicebear.com/styles/rings/presets/)
[^3]: [Profile Icon Generator](https://github.com/HenryLok0/profile-icon-generator)
[^4]: [Gopherize.me](https://gopherize.me/)
[^5]: [SVGO](https://github.com/svg/svgo)
