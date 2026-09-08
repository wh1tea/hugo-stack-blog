---
title: 用 Hugo + Stack 主题 + GitHub Pages 搭建博客
slug: hugo-stack-github-pages
date: 2026-08-12
description: 从模板到上线：双语博客的完整搭建记录，附项目结构全解析
tags:
  - hugo
  - stack
  - github-pages
  - blogging
categories:
  - devtools

image: /hugo-stack-blog/post/hugo/assets/cover.svg
---

这篇博客就是最终成果。记录一下我是如何用 Hugo + Stack 主题 + GitHub Pages，从零搭出一个中英双语的静态博客。

## 简介

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

验证环境：

```bash
hugo version    # 需显示 +extended
go version
```

## 主题：从模板创建仓库

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

这是本博客最值得说的部分。Hugo 的多语言是**一等公民**（First-Class Citizen），不需要任何插件。

### 1. 定义语言（config/\_default/languages.toml）

```toml
[zh]
    weight     = 1
    label      = "简体中文"
    title      = "你的博客"
    contentDir = "content/zh"
    locale     = "zh-cn"

    [zh.params.sidebar]
        subtitle = "代码 · 随笔 · 生活"

[en]
    weight     = 2
    label      = "English"
    title      = "Your Blog"
    contentDir = "content/en"
    locale     = "en-us"

    [en.params.sidebar]
        subtitle = "Code · Blog · Life"
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

文章放在 `content/<语言>/post/<主题>/<slug>.md`，图片放在该主题文件夹的 `assets/` 目录：

```markdown
---
title: "文章标题"
description: "一句话摘要，会显示在首页卡片上"
slug: "article-slug"
date: 2026-08-12T16:00:00+08:00
tags:
  - hugo
categories:
  - hugo
image: /hugo-stack-blog/post/hugo/assets/cover.svg
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
│   ├── icons/              # 自定义 SVG 图标（社交链接等，见下节）
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

## 自定义社交图标（以 CodePen 为例）

侧边栏社交链接的 `icon` 值不是内置枚举，而是**按文件名查找** `assets/icons/<名字>.svg`：主题的 `helper/icon.html` 用 `resources.GetMatch` 匹配，找不到就直接报错终止构建。主题模块只内置了 tabler 系的 `brand-github.svg`、`brand-twitter.svg` 两个品牌图标。

当时想把 CodePen 加进社交菜单，排查发现 tabler 图标集本身没有 CodePen 品牌图标，需要自己补一个 SVG。

修复分两步。

**第一步：新增 `assets/icons/brand-codepen.svg`**——CodePen 的 path 数据取自 [Tabler Icons](https://tabler.io/icons)（搜 CodePen 复制即可）：

注：[Tablericons](https://tablericons.com/) 也能提供相关图标 [Simple Icons](https://simpleicons.org)

```xml
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="icon icon-tabler icons-tabler-outline icon-tabler-brand-codepen">
	<path stroke="none" d="M0 0h24v24H0z" fill="none" />
	<path d="M3 15l9 6l9 -6l-9 -6l-9 6" />
	<path d="M3 9l9 6l9 -6l-9 -6l-9 6" />
	<path d="M3 9l0 6" />
	<path d="M21 9l0 6" />
	<path d="M12 3l0 6" />
	<path d="M12 15l0 6" />
</svg>
```

[备用-CodePen Badge Logo](https://codepen.io/wh1tea/pen/bNqpBKQ)/[备用-CodePen Logo as Inline SVG](https://codepen.io/team/codepen/pen/RaqmEW)

**第二步：改 `config/_default/menu.zh.toml`** 里的图标名：

```toml
[[social]]
    identifier = "codepen"
    name       = "CodePen"
    url        = "https://codepen.io/username"
    [social.params]
        icon = "brand-codepen"
```

验证很简单：图标名拼错时构建会直接报错 `icon 'xxx.svg' is not found under 'assets/icons' folder`，能构建成功基本等于图标就位；再在预览页右键检查元素确认 CodePen 链接里是 CodePen 的 logo 即可。项目自己的 `assets/icons/` 会覆盖主题模块的同名文件，其它品牌图标同理：下载 SVG → 丢进 `assets/icons/` → 菜单里指过去。

## 清理 public 构建产物

`public/` 是纯本地构建产物：已被 `.gitignore` 排除，线上部署走 GitHub Actions **每次全新构建**，所以本地 `public/` 再脏也不影响线上。但它会误导本地预览和产物检查，原因在于：

> Hugo 重建**不会清空** `public/`。`hugo --gc` 只清缓存、不碰输出目录。

重命名内容、删除文章、移动资源、改 `permalinks` 或 `baseurl` 之后，旧路径的文件会原样残留（比如老文章的 `cover.svg`、拼错目录名遗留的整段页面），`find public` / 页面检查的结果都是过期的。

**什么时候该清**：任何结构类改动之后、以及做产物验证之前。命令：

```bash
rm -rf public          # 清空产物
hugo                   # 全量重建

# 一步到位（参数与 CI 一致）：
rm -rf public resources && hugo --gc --minify
```

`resources/` 是 Hugo 的处理缓存（图片缩放、SCSS 编译产物），删掉只是下次构建变慢一点，无副作用。顺带记住：`public/` 永远不要提交进 Git。

## Hugo 常用命令速查

| 命令 | 用途 |
| ---- | ---- |
| `hugo server` | 本地预览 http://localhost:1313，改文件热更新 |
| `hugo server --buildDrafts` | 预览带 `draft: true` 的未发布文章 |
| `hugo` | 构建到 `public/` |
| `hugo --gc --minify` | 清理缓存 + 压缩产物（CI 同款参数） |
| `hugo new content <路径>` | 按 archetype 新建内容页 |
| `hugo list all` | 罗列全部页面（诊断重复渲染、语言挂载问题） |
| `hugo config` | 打印合并后的完整配置（模块挂载、语言都在里面） |
| `hugo mod get -u github.com/CaiJimmy/hugo-theme-stack/v4` | 更新主题（记得跟 `hugo mod tidy`） |
| `hugo env` | 查看版本与编译特性（确认 `+extended`） |

本地日常就是 `hugo server` 写文章、`rm -rf public && hugo` 做干净验证这两条；其余多为诊断用。更新主题的另一条路是仓库自带的 `update-theme.yml` 定时任务，见下方常见问题。

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
