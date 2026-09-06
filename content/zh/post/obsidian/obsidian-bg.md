---
title: 给 Obsidian 添加背景
slug: obsidian-bg
date: 2026-09-04
description: 纯插件方案，为 Obsidian 编辑器添加自定义背景图，无需手写 CSS
tags:
  - beautify
  - obsidian
categories:
  - obsidian
---

本文提供一种纯插件方案，无需编辑 CSS，即可为编辑器添加背景图。

## 方案

- **Background Image**：核心插件，负责应用背景图（仅支持 http/https 链接）。
- **Local Bg Image Server**：辅助插件，在本地启动 HTTP 服务，将本地图片转为 `localhost` URL 供前者使用。

## 安装

1. 关闭安全模式（设置 → 第三方插件）。
2. 搜索并启用 `Background Image` 和 `Local Bg Image Server`。

## 配置

1. **启动图片服务**：服务默认运行于 `http://localhost:8989`，图片文件夹基于仓库根目录默认位置在.bg/。
2. **设置背景**：进入 Background Image 设置页，在“Background Image URL”（浅色）或“Dark theme image URL”（深色）填入图片地址，如 `http://localhost:8989/wallpaper.jpg`。按需调整透明度（Background opacity）和模糊（Image blur），并选择应用范围。
