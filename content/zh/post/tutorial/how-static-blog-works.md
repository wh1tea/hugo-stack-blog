---
title: 小白也能懂的纯静态博客：wh1tea.github.io 是怎么工作的
date: 2026-08-03
description: 从写 Markdown 到发布上线，拆解一个零框架纯静态博客的完整技术栈与实现原理，适合想自己搭博客的小白。
tags:
  - github-pages
  - static-site
  - javascript
  - python
  - markdown
  - frontend
categories: tutorial
---

> 面向小白：拆解 wh1tea.github.io 这个纯静态博客的完整实现。读完你会明白从写一篇文章到读者看到它，每一步发生了什么。

## 这是什么

一个**不用买服务器、不用买域名、几乎零成本**的博客：

- 文章用 Markdown 写，像记笔记一样简单
- 托管在 GitHub Pages，免费
- 前端零框架，只有原生 HTML、CSS、JavaScript
- 发布靠 `git push`，自动化构建

这类网站叫**静态站点**：所有页面在访问前就生成好，服务器只负责把文件原样发给浏览器，不做任何计算。

## 一次访问发生了什么

```
浏览器输入 wh1tea.github.io
        │
        ▼
GitHub Pages 返回 index.html（首页）
        │
        ▼
浏览器加载 assets/js/main.js
        │
        ▼
main.js 用 fetch 请求 _data/posts.json（文章目录）
        │
        ▼
JS 把数据渲染成卡片 → 点击卡片 → post.html?file=_posts/xxx.md
        │
        ▼
post.html 再 fetch 那篇 .md 文件 → marked.js 转成 HTML → 显示
```

关键点：**浏览器不会"扫描文件夹"**，它只能请求明确的文件路径。所以需要一份"文章目录"（posts.json）告诉它有哪些文章、每篇在哪。

## 技术栈一览

| 层 | 技术 | 作用 |
| ---- | ------ | ------ |
| 托管 | GitHub Pages | 免费静态托管，自动部署 |
| 前端 | 原生 HTML / CSS / JS | 零框架，无构建依赖 |
| 写作 | Markdown + YAML frontmatter | 写文章 |
| 构建 | Python 3 脚本（`scripts/build.py`） | 扫描文章，生成数据 |
| Markdown 渲染 | marked.js | 把 `.md` 转成 HTML |
| 代码高亮 | highlight.js | 代码块语法着色 |
| 本地存储 | localStorage | 主题、语言、阅读计数 |
| 字体 | Google Fonts | Space Grotesk + DM Sans |
| 自动化 | GitHub Actions | push 后自动重新构建 |

## 写文章：Markdown 加头信息

每篇文章是一个 `.md` 文件，顶部有一段 YAML 头信息（frontmatter）：

```yaml
---
title: 文章标题
date: 2026-08-03
tags:
  - javascript
  - tutorial
categories: tutorial
description: 一句话摘要，用于卡片和搜索。
---
```

正文就是普通 Markdown。frontmatter 的职责：给文章打标签、分类、定日期，构建脚本靠它生成目录。

## 构建：Python 把文章变成数据

`scripts/build.py` 做四件事：

1. 递归扫描 `_posts/` 下所有 `.md` 文件
2. 解析每篇的 frontmatter（标题、日期、标签、分类）
3. 按日期倒序排序，汇总标签和分类
4. 输出 `_data/posts.json` 和 `feed.xml`（RSS）

生成的 posts.json 长这样（简化）：

```json
{
  "posts": [
    {
      "title": "文章标题",
      "date": "2026-08-03",
      "tags": ["javascript", "tutorial"],
      "categories": "tutorial",
      "url": "/post.html?file=_posts/tutorial/xxx.md"
    }
  ]
}
```

这就是网站的"数据库"——一个 JSON 文件，任何页面都能 fetch 到。

## 渲染：浏览器把数据变成页面

首页逻辑在 `assets/js/main.js`，全部是原生 JS：

- `fetch('_data/posts.json')` 拿目录
- 按分类/标签/关键词过滤，渲染卡片
- 文章页再 fetch 对应的 `.md`，用 marked.js 渲染成 HTML
- highlight.js 给代码块着色

**搜索**没有后端：JS 把标题、描述、标签、分类逐条比对，实时过滤。文章少时完全够用。

## 三个关键设计

### 为什么需要 .nojekyll

GitHub Pages 默认用 Jekyll 构建。Jekyll 会把 `_data/` 当成自己的内部数据目录，**不对外提供**——导致 `fetch('_data/posts.json')` 返回 404，页面永远卡在 Loading。

仓库根目录放一个空的 `.nojekyll` 文件，告诉 GitHub Pages"别跑 Jekyll，直接当静态文件服务器"，问题解决。

### 为什么文章地址带 ?file=

纯静态站点没有后端路由，`/post/xxx` 这种漂亮地址映射不到文件。方案是查询参数：

```text
/post.html?file=_posts/tutorial/how-static-blog-works.md
```

`post.html` 从参数里读出文章路径，再 fetch 渲染。简单直接，且本地开发服务器和线上行为完全一致。

### 用 localStorage 做的三个小功能

localStorage 是浏览器自带的键值存储，适合存"偏好"：

| 功能 | 存储内容 | 实现 |
| ------ | ---------- | ------ |
| 暗色模式 | `theme` | 切换 `<html>` 的 `data-theme` 属性 |
| 中英文切换 | `wh1tea_lang` | 翻译字典 + `data-i18n` 属性替换文本 |
| 阅读计数 | `wh1tea_views` | 打开文章 +1，首页给 Top 3 加 🔥 标 |

不需要服务器，数据存在访问者自己的浏览器里。

## GitHub Actions：自动构建

之前每写一篇文章，都要手动跑一遍构建脚本再提交生成的文件。现在 `.github/workflows/build.yml` 接管：

```yaml
on:
  push:
    paths: ['_posts/**']
```

只要 push 了 `_posts/` 下的改动，CI 自动重新生成 posts.json 和 feed.xml 并提交。写文章流程简化为：**写 `.md` → push → 上线**。

## 这个方案适合谁

适合：

- 想拥有自己的博客、不想碰服务器的小白
- 内容以文字和代码为主，不需要评论区/登录
- 喜欢"文件即内容"，随时能搬走

不适合：

- 需要实时交互、用户系统、复杂评论
- 文章非常多（上千篇）时，前端全量加载 JSON 会变慢

## 总结

- 静态博客 = Markdown 写作 + 构建脚本 + 前端渲染，三层各司其职
- GitHub Pages 免费托管，`.nojekyll` 是让 `_data/` 可访问的关键
- 零框架意味着零依赖、加载快、完全可控，代价是功能要自己写
- 想搭一个：创建 `<用户名>.github.io` 仓库，写第一篇 `.md`，push 即可

具体搭建步骤见 [GitHub Pages 博客搭建教程](./setting-up-github-io-blog.md)。

## 参考

- [GitHub Pages 官方文档](https://docs.github.com/zh/pages) 托管与自定义域名
- [marked.js](https://marked.js.org/) Markdown 解析器
- [highlight.js](https://highlightjs.org/) 代码高亮
- [Markdown 语法指南](../markdown/markdown-for-typora-cn.md) 本站文章
- [项目源码](https://github.com/wh1tea/wh1tea.github.io) 本博客仓库
