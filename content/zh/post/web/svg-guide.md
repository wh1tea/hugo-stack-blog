---
title: SVG 入门：格式对比、AI 生成与 VSCode 预览
slug: svg-guide
date: 2026-08-20
description: 梳理 SVG 的核心优势与格式选型，给出 AI 生成矢量图的三条路径，以及 VSCode 实时预览的配置方法，并记录 Better SVG 的 SVGO 优化陷阱。
tags:
  - svg
  - frontend
  - ai
  - vscode
categories:
  - web
---

SVG 用数学路径描述图形，而不是存储像素阵列。这个区别决定了它在缩放、体积和可编辑性上的优势，也决定了它的适用边界。本文梳理 SVG 的核心特性与格式选型，给出 AI 生成矢量图的三条路径，以及 VSCode 里实时预览的配置方法，并补充一个 Better SVG 优化导致主题色失效的实际问题。

## 核心特点与适用边界

SVG 是 W3C 标准的 XML 标记语言[^1]，本质是存储“绘制方法”而非“像素阵列”，放大多少倍都不会出现锯齿。它相对于位图，类似 HTML 相对于纯文本。

四个优势：

- **无损缩放**：单一文件适配从图标到广告牌的所有尺寸。
- **体积轻量**：只存数学描述，简单图形远小于同效果的位图。
- **文本可编辑可检索**：作为 XML，文字内容可修改、可被搜索引擎索引。
- **可被 CSS 与 JS 控制**：SVG 元素内嵌于 DOM，能做样式和交互动画，位图做不到。

局限同样明确：色彩过渡复杂、细节丰富的摄影图像不适合 SVG，强行转换会让文件膨胀。它最擅长的领域是 Logo、图标、矢量插画和技术图表。

## 格式横向对比

| 维度          | **SVG**              | **PNG**         | **JPEG/JPG**       | **WebP**         |
| :------------ | :------------------- | :-------------- | :----------------- | :--------------- |
| 图像类型      | 矢量（数学路径）     | 栅格（像素）    | 栅格（像素）       | 栅格（像素）     |
| 压缩方式      | 无损（矢量）         | 无损            | 有损               | 有损 / 无损      |
| 支持透明背景  | ✅                    | ✅               | ❌                  | ✅                |
| 支持动画      | ✅（CSS / JS）        | ❌               | ❌                  | ✅                |
| 无限缩放      | ✅                    | ❌               | ❌                  | ❌                |
| 文本可编辑    | ✅                    | ❌               | ❌                  | ❌                |
| CSS / JS 控制 | ✅                    | ❌               | ❌                  | ❌                |
| 文件大小      | 极小（简单图形）     | 较大            | 较小               | 最小             |
| 最佳应用场景  | 品牌标识、图标、插画 | UI 元素、透明图 | 照片、色彩丰富图像 | 现代网页、移动端 |

## AI 生成 SVG 的三条路径

AI 生成 SVG 的实质是让模型输出符合 W3C 标准的矢量代码，目前分三类。

### 文本直接生成代码

模型根据描述输出原生 SVG，这是当前最主流的模式。

- **Recraft V4**：少数能直接生成原生 SVG 的平台之一。V4 Pro 支持 1:1、16:9 等比例，输出可直接导入 Figma、Adobe Illustrator。[^2]
- **QuiverAI（Arrow 1.1）**：支持文本和图像双模态输入，适用于 Logo、图标、插画及技术绘图。[^3]

### 图片矢量化

把现有的 JPG、PNG 草稿或设计图转换为可编辑的 SVG。Arrow 1.1 同样支持。

### 自然语言生成技术架构图

**fireworks-tech-graph** 面向技术文档，用自然语言描述系统架构即可生成 SVG 和 PNG。内置 7 种视觉风格与 1 种 AI 手绘风格，支持 14 种 UML 图类型。[^4]

其他工具：**Nakkas**（MCP 服务器，通过声明式 JSON 让 Claude 等助手生成带动画的 SVG）、**sh-icon-genie**（交互式 CLI，把描述转为 Phosphor 风格图标）、**LottieFiles Prompt to Vector**（在 LottieFiles Creator 中生成分层 SVG 素材）。

## VSCode 实时预览

SVG 是文本代码，搭配扩展[SVG](https://marketplace.visualstudio.com/items?itemName=jock.svg)可以做到编码即所见。

## Bug：Better SVG 的 SVGO 优化陷阱

Better SVG 集成了 SVGO 一键优化，但它对含 `<style>` 和媒体查询的 SVG 可能改出问题。以 `test-bug.svg` 为例，优化前：

```html
<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200" viewBox="0 0 200 200">
  <title>inline style bug test</title>
  <style>
    circle {
      fill: #121212;
    }
    @media (prefers-color-scheme: dark) {
      circle {
        fill: #e0e0e0;
      }
    }
  </style>
  <circle cx="100" cy="100" r="80" stroke="#FF6B35" stroke-width="5" />
</svg>
```

优化后变成：

```html
<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200" viewBox="0 0 200 200"><title>inline style bug test</title><style>@media (prefers-color-scheme:dark){circle{fill:#e0e0e0}}</style><circle cx="100" cy="100" r="80" stroke="#ff6b35" stroke-width="5" style="fill:#121212"/></svg>
```

格式化：

```html
<svg xmlns="http://www.w3.org/2000/svg" width="200" height="200" viewBox="0 0 200 200">
  <title>inline style bug test</title>
  <style>
    @media (prefers-color-scheme:dark) {
      circle {
        fill: #e0e0e0
      }
    }
  </style>
  <circle cx="100" cy="100" r="80" stroke="#ff6b35" stroke-width="5" style="fill:#121212" />
</svg>
```

问题在于：SVGO 把基础规则 `path { fill: #121212; }` 提取成了 `path` 元素的内联 `style="fill:#121212"`。内联样式优先级高于 `<style>` 中的普通选择器规则，因此 `@media (prefers-color-scheme: dark)` 里的 `path { fill:#e0e0e0; }` 无法覆盖它，暗色模式实际仍然显示 `#121212`，主题自适应失效。

结论：**含 `<style>`、媒体查询或主题色切换的 SVG，不要使用 Better SVG 的 SVGO 优化功能。** 日常预览建议直接使用 SVG Preview 等只做预览、不改写代码的插件；如果必须优化，先备份并检查 `fill` 是否被内联到元素 `style` 中。

工具选择上，预览优先用 SVG Preview；Better SVG 功能虽全，但对含主题媒体查询的 SVG 要避开其 SVGO 优化，否则容易出现 `test-bug.svg` 这类暗色模式失效问题。

## 结语

几何图形、图标、Logo 用 SVG，照片用 JPEG 或 WebP。AI 生成矢量图已经能覆盖文本生成、图片矢量化和技术图表三类场景，配合 VSCode 的实时预览，从描述到成品的路径比手写路径短得多。

[^1]: [SVG 指南 - MDN](https://developer.mozilla.org/zh-CN/docs/Web/SVG)
[^2]: [Introducing Recraft V4 Pro Text To Vector - WaveSpeedAI](https://wavespeed.ai/blog/posts/introducing-recraft-ai-recraft-v4-pro-text-to-vector-on-wavespeedai/#1)
[^3]: [Introducing Arrow 1.1 - QuiverAI](https://quiver.ai/blog/introducing-arrow-1-1)
[^4]: [fireworks-tech-graph 项目介绍](https://github.com/ninehills/fireworks-tech-graph)
[^5]: [Better SVG GitHub README](https://github.com/midudev/better-svg)
