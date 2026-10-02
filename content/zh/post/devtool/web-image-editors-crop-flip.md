---
title: 网页端开源图片编辑器：像素裁剪与翻转
slug: web-image-editors-crop-flip
date: 2025-09-09T20:00:00+08:00
description: 盘点支持精确像素裁剪与镜像翻转的网页端开源图片编辑器，覆盖批量处理、React 集成与桌面命令行备选方案。
tags:
  - image
  - open-source
  - web
categories:
  - devtool
---

需要给浏览器扩展准备精确尺寸素材，或者把一批截图裁成统一大小，又不想装桌面软件时，网页端编辑器是首选。本文盘点支持像素级裁剪与镜像翻转的开源工具，并给出按场景的选择建议。

## 工具速览

| 工具名称               | 精确像素裁剪 | 特点                                    |
| :--------------------- | :----------: | :-------------------------------------- |
| **webimg**             |      ✅       | 批量处理、格式转换、本地运行、镜像反转  |
| **EXTPIXEL**           |      ✅       | 手动裁剪 + 自动裁剪、预设尺寸、批量导出 |
| **Pine Crop**          |      ✅       | 批量裁剪 PNG、像素级精确定位            |
| **React Image Editor** |      ✅       | React 组件、裁剪+翻转+滤镜+AI 助手      |
| **Pixra**              |   基础裁剪   | 可扩展插件系统、多标签支持              |
| **Painterro**          |  按区域裁剪  | JS 绘画插件、可嵌入网页                 |

## 重点工具

### webimg

完全在浏览器端运行的图片编辑器，支持裁剪、调整大小、旋转、翻转和格式转换[^1]。裁剪可设置精确像素尺寸并锁定长宽比，翻转支持水平和垂直两个方向，批量处理结果可导出为 ZIP。所有处理通过 Canvas API 在本地完成，图片不上传，项目采用 MIT 许可证。

### EXTPIXEL

纯客户端图片缩放工具，同时提供手动裁剪、自动裁剪和预设尺寸，支持批量导出[^2]。图像处理全部在浏览器内通过 HTML5 Canvas API 完成，没有服务端参与。

### Pine Crop

基于 Alpine.js 的浏览器端工具，专为把多张 PNG 裁成同一尺寸设计[^3]。X、Y、宽、高四个数值输入框支持像素级定位，在预览图上拖拽裁剪框时数值同步更新，一次加载多张图片即可套用相同参数。适合处理截图、去边框或从多张图中提取相同区域。

### React Image Editor

`@unlayer/react-image-editor` 基于 Unlayer Image Editor 封装，适合在 React 项目中集成[^4]。功能包括裁剪、调整大小、绘图、文字、形状、贴纸、滤镜以及可选的 AI 助手。裁剪工具支持 90° 步进旋转、翻转和拉直滑块。

### Pixra

基于浏览器的图片编辑器，采用可扩展的插件系统，支持多标签同时打开多张图片[^5]。裁剪能力属于基础级别，适合把编辑、批注和轻量处理放在同一个界面里完成的场景；对像素级定位有严格要求的任务，还是交给 Pine Crop 或 webimg。

### Painterro

以 JavaScript 绘画插件的形式提供，可以嵌入网页或作为 WordPress 插件使用[^6]。它提供的是按区域选定的编辑能力，而不是精确到像素的裁剪框。如果你需要在自有页面里加一个轻量绘图入口，它能直接挂在现有前端代码里，不需要用户跳到别的站点。

## 桌面与命令行备选

网页端无法覆盖的场景，可以换用以下开源方案：

| 工具名称        | 类型        | 说明                                                |
| :-------------- | :---------- | :-------------------------------------------------- |
| **GIMP**        | 桌面应用    | 开源图像处理软件，裁剪工具可设置固定像素尺寸        |
| **Krita**       | 桌面应用    | 数字绘画软件，裁剪工具可直接输入宽高像素值          |
| **ImageMagick** | 命令行      | 通过 `convert` 命令指定精确像素尺寸和偏移量进行裁剪 |
| **SoloPic**     | 桌面/命令行 | 开源离线批量处理工具，支持按像素从边缘裁剪          |

## 按场景选择

- 需要翻转 + 功能全面：**webimg**
- 批量把 PNG 裁成统一尺寸：**Pine Crop**
- 为浏览器扩展准备精确尺寸素材：**EXTPIXEL**
- 在 React 项目里集成编辑器：**React Image Editor**
- 需要多标签 + 插件扩展：**Pixra**
- 要在自有页面嵌入绘图入口：**Painterro**
- 需要桌面级编辑能力：**GIMP** 或 **Krita**

## 结语

精确裁剪、镜像翻转和批量处理这三个需求，网页端工具已经能覆盖大部分场景，且都在本地完成处理，图片不出设备。先用速览表按功能筛掉不满足的，再从重点工具里挑一个试，比逐个试用快。

[^1]: [webimg](https://webimg.app/) 与 [webimg GitHub 仓库](https://github.com/gytisrepecka/webimg)
[^2]: [EXTPIXEL](https://extpixel.vercel.app/) 与 [EXTPIXEL GitHub 仓库](https://github.com/NubPlayz/EXTPIXEL)
[^3]: [Pine Crop GitHub 仓库](https://github.com/wclaytor/pine-crop)
[^4]: [React Image Editor GitHub 仓库](https://github.com/unlayer/react-image-editor)
[^5]: [Pixra GitHub 仓库](https://github.com/rxliuli/pixra)
[^6]: [Painterro WordPress 插件页](https://am.wordpress.org/plugins/painterro/)
