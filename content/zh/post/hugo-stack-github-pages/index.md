---
title: "用 Hugo + Stack 主题 + GitHub Pages 搭建博客"
description: "从模板到上线：双语博客的完整搭建记录，附项目结构全解析"
slug: "hugo-stack-github-pages"
date: 2026-08-12T16:00:00+08:00
tags: ["hugo", "stack", "github-pages", "博客搭建"]
categories: ["hugo"]
image: cover.svg
---

这篇博客就是最终成果。记录一下我是如何用 Hugo + Stack 主题 + GitHub Pages 三件套，从零搭出一个中英双语的静态博客。

## 为什么是这三件套

| 组件         | 选择理由                                                                   |
| ------------ | -------------------------------------------------------------------------- |
| Hugo         | 单二进制、无依赖，构建以毫秒计；原生支持多语言（i18n）                     |
| Stack 主题   | 卡片式设计简洁耐看，自带暗色模式、搜索、归档、标签云；官方维护中文界面文案 |
| GitHub Pages | 免费托管，配合 GitHub Actions 推送即部署，零服务器成本                     |

对折腾成本敏感的开发者来说，这是一条非常顺滑的路径：**本地写 Markdown → push → 自动构建上线**。

## 环境准备

| 工具          | 用途                               | 安装方式                            |
| ------------- | ---------------------------------- | ----------------------------------- |
| Git           | 版本管理                           | `winget install Git.Git`            |
| Go            | Hugo 模块机制（拉取主题）          | `winget install GoLang.Go`          |
| Hugo Extended | 构建站点，extended 版才能编译 SCSS | `winget install Hugo.Hugo.Extended` |
| Dart Sass     | 编译主题的 SCSS                    | GitHub Releases 下载后加入 PATH     |

验证环境：

```bash
hugo version    # 需显示 +extended
go version
```

## 从模板创建仓库

Stack 官方提供了 starter 模板（`CaiJimmy/hugo-theme-stack-starter`），直接省去手搓主题接入的步骤：

1. 在 GitHub 上点 **Use this template**，仓库名随意（本文是 `hugo-stack-blog`）
2. 到仓库 **Settings → Pages**，把 Build and deployment 的 Source 设为 **GitHub Actions**
3. 克隆到本地，把 `config/_default/config.toml` 里的 `baseurl` 改成自己的地址：

```toml
baseurl = "https://<username>.github.io/hugo-stack-blog/"
```

模板内部用 Hugo Modules 引入主题（而非 git submodule），`go.mod` + `config/_default/module.toml` 负责这件事，克隆后首次构建会自动下载主题。

## 本地开发

```bash
hugo server     # 默认 http://localhost:1313，支持热更新
hugo            # 构建到 public/
```

## 中英双语切换

这是本博客最值得说的部分。Hugo 的多语言是**一等公民**，不需要任何插件。

### 1. 定义语言（config/\_default/languages.toml）

```toml
[zh]
    weight     = 1
    label      = "简体中文"
    title      = "Wh1tea 的博客"
    contentDir = "content/zh"
    locale     = "zh-cn"

    [zh.params.sidebar]
        subtitle = "代码 · 随笔 · 生活"

[en]
    weight     = 2
    label      = "English"
    title      = "Wh1tea's Blog"
    contentDir = "content/en"
    locale     = "en-us"

    [en.params.sidebar]
        subtitle = "Code · Grad School · Life"
```

### 2. 指定默认语言（config/\_default/config.toml）

```toml
defaultContentLanguage = "zh"
defaultContentLanguageInSubdir = false   # 中文在根路径，英文在 /en/
hasCJKLanguage = true                    # 保证中文字数统计 / 阅读时长正确
```

### 3. 按语言分目录存放内容

```
content/
├── zh/   # 中文版：_index.md、page/、post/
└── en/   # 英文版：结构与中文一一对应
```

同一篇文章的两个语言版本放在对应目录下即可，标题、标签都可以不同。

### 4. 语言切换器与界面文案

切换器**不需要任何配置**：主题检测到站点是多语言的，就会在侧边栏自动渲染一个下拉框，遍历 `AllTranslations` 生成选项（显示的就是 languages.toml 里的 `label`）。

界面文案（归档、搜索、阅读时长、404 等）由主题的 `i18n/zh.toml` 提供，简体中文开箱即用，无需自己翻译。

## 写一篇文章

文章放在 `content/<语言>/post/<slug>/index.md`，同目录放图片等页面资源：

```markdown
---
title: "文章标题"
description: "一句话摘要，会显示在首页卡片上"
date: 2026-08-12T16:00:00+08:00
tags: ["Hugo", "博客搭建"]
categories: ["教程"]
cover:
  image: cover.svg
---

正文用 Markdown 写即可。
```

## 部署到 GitHub Pages

模板自带 `.github/workflows/deploy.yml`，推送 `main` 分支即自动部署，流程大致是：

1. 安装 Go / Node / Dart Sass / Hugo Extended
2. `hugo --gc --minify` 构建
3. 上传产物 → `actions/deploy-pages` 发布

也就是说 **public/ 目录永远不需要提交**（模板的 .gitignore 已排除），改完文章直接 push 就上线。

## 项目结构总览

```
hugo-stack-blog/
├── .github/workflows/
│   ├── deploy.yml          # 推送即部署到 GitHub Pages
│   └── update-theme.yml    # 每日自动更新主题的定时任务
├── assets/
│   ├── img/                # 头像、favicon
│   ├── audio/              # 站内音频资源
│   └── scss/custom.scss    # 自定义样式覆盖
├── config/_default/
│   ├── config.toml         # 全局配置（baseurl、默认语言）
│   ├── languages.toml      # 多语言定义（zh/en）
│   ├── params.toml         # 主题参数（侧边栏、组件、评论）
│   ├── menu.zh.toml        # 中文社交菜单
│   ├── menu.en.toml        # 英文社交菜单
│   ├── markup.toml         # Markdown 渲染设置
│   ├── module.toml         # Hugo 模块：引入 Stack 主题
│   ├── permalinks.toml     # 链接结构
│   └── related.toml        # 相关文章推荐
├── content/
│   ├── zh/                 # 中文内容（默认语言，根路径）
│   │   ├── _index.md
│   │   ├── page/           # 归档 / 搜索 / 友链
│   │   └── post/           # 文章
│   └── en/                 # 英文内容（/en/）
├── go.mod / go.sum         # 主题模块依赖
└── .gitignore
```

## 常见问题

**Q：样式全乱 / 资源 404？** 大概率是 `baseurl` 没改，或没按 Pages 的子路径部署。

**Q：如何更新主题？** 模板自带每日自动更新（update-theme.yml），也可手动：

```bash
hugo mod get -u github.com/CaiJimmy/hugo-theme-stack/v4
hugo mod tidy
```

**Q：中文阅读时长不准？** 检查 `hasCJKLanguage = true` 是否设置。

**Q：本地报 Dart Sass 相关错误？** 主题 SCSS 需要 Dart Sass（不是 libsass），确认已安装并加入 PATH。

## 结语

整个流程最重的部分其实是写文章，工具链本身半小时就能跑通。静态博客 + Markdown + Git 的工作流，专注内容、零维护成本，适合长期使用。接下来打算吧其他平台分散的博客也沉淀到这里，欢迎交换友链。
