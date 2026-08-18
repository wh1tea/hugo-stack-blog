---
title: "Building a Blog with Hugo, the Stack Theme, and GitHub Pages"
description: "From template to live: a complete bilingual blog setup guide with a full project structure breakdown"
slug: "hugo-stack-github-pages"
date: 2026-08-12T16:00:00+08:00
tags:
  - hugo
  - stack
  - github-pages
  - blogging
categories:
  - hugo
image: /hugo-stack-blog/en/post/hugo/assets/cover-en.svg
---

This post is the result. Here's how I built a bilingual (Chinese/English) static blog from scratch with three tools: **Hugo**, the **Stack theme**, and **GitHub Pages**.

## Why this stack

| Component    | Why                                                                                               |
| ------------ | ------------------------------------------------------------------------------------------------- |
| Hugo         | Single binary, no dependencies, millisecond builds; first-class multi-language (i18n) support     |
| Stack theme  | Clean card-style design, dark mode, search, archives, tag cloud; official Chinese UI translations |
| GitHub Pages | Free hosting; push-to-deploy via GitHub Actions, zero server cost                                 |

For developers who want to minimize setup friction, the workflow is smooth: **write Markdown locally → push → auto-built and live**.

## Prerequisites

| Tool          | Purpose                                         | Install                             |
| ------------- | ----------------------------------------------- | ----------------------------------- |
| Git           | Version control                                 | `winget install Git.Git`            |
| Go            | Hugo Modules (fetching the theme)               | `winget install GoLang.Go`          |
| Hugo Extended | Build the site (extended edition compiles SCSS) | `winget install Hugo.Hugo.Extended` |
| Dart Sass     | Compile the theme's SCSS                        | GitHub Releases, then add to PATH   |

Verify:

```bash
hugo version    # should show +extended
go version
```

## Create the repo from a template

The Stack team provides an official starter (`CaiJimmy/hugo-theme-stack-starter`), which saves all the theme-integration boilerplate:

1. On GitHub, click **Use this template**; name the repo whatever you like (`hugo-stack-blog` here)
2. In the repo **Settings → Pages**, set Build and deployment Source to **GitHub Actions**
3. Clone locally and update `baseurl` in `config/_default/config.toml`:

```toml
baseurl = "https://<username>.github.io/hugo-stack-blog/"
```

The template loads the theme via **Hugo Modules** (not a git submodule) — `go.mod` plus `config/_default/module.toml` handle that, and the theme is downloaded automatically on the first build.

## Local development

```bash
hugo server     # http://localhost:1313, live reload
hugo            # build to public/
```

## Bilingual setup

This is the most interesting part of this blog. Hugo treats multilingual sites as a **first-class citizen** — no plugins needed.

### 1. Define languages (config/\_default/languages.toml)

```toml
[zh]
    weight     = 1
    label      = "简体中文"
    title      = "Wh1tea 的博客"
    contentDir = "content/zh"
    locale     = "zh-cn"

    [zh.params.sidebar]
        subtitle = "代码 · 博客 · 生活"

[en]
    weight     = 2
    label      = "English"
    title      = "Wh1tea's Blog"
    contentDir = "content/en"
    locale     = "en-us"

    [en.params.sidebar]
        subtitle = "Code · Blog · Life"
```

### 2. Set the default language (config/\_default/config.toml)

```toml
defaultContentLanguage = "zh"
defaultContentLanguageInSubdir = false   # Chinese at root, English at /en/
hasCJKLanguage = true                    # correct word counts / reading time for CJK
```

### 3. Separate content directories per language

```txt
content/
├── zh/   # Chinese version: _index.md, page/, post/
└── en/   # English version: mirrors the Chinese structure
```

Write each language's version of an article in its own directory — titles and tags can differ.

### 4. Language switcher & UI strings

The switcher needs **zero configuration**: when the theme detects a multilingual site, it renders a dropdown in the sidebar, iterating over `AllTranslations` (labels come from `languages.toml`).

UI strings (archives, search, reading time, 404, etc.) come from the theme's `i18n/zh.toml` — Simplified Chinese works out of the box.

## Writing a post

Put articles at `content/<lang>/post/<topic>/<slug>.md`, with images in the `<topic>/assets/` folder:

```markdown
---
title: "Post Title"
description: "One-line summary shown on the homepage card"
slug: "article-slug"
date: 2026-08-12T16:00:00+08:00
tags:
  - hugo
categories:
  - hugo
image: /hugo-stack-blog/en/post/hugo/assets/cover-en.svg
---

Write the body in Markdown.
```

## Deploy to GitHub Pages

The template ships with `.github/workflows/deploy.yml` — pushing to `main` deploys automatically:

1. Install Go / Node / Dart Sass / Hugo Extended
2. `hugo --gc --minify`
3. Upload artifact → `actions/deploy-pages` publishes it

In other words, **the `public/` directory is never committed** (already gitignored). Just push your Markdown and it goes live.

## Project structure

```txt
hugo-stack-blog/
├── .github/workflows/
│   ├── deploy.yml          # push-to-deploy to GitHub Pages
│   └── update-theme.yml    # daily theme auto-update cron
├── assets/
│   ├── img/                # avatar, favicon
│   ├── audio/              # site audio assets
│   └── scss/custom.scss    # custom style overrides
├── config/_default/
│   ├── config.toml         # global config (baseurl, default language)
│   ├── languages.toml      # language definitions (zh/en)
│   ├── params.toml         # theme params (sidebar, widgets, comments)
│   ├── menu.zh.toml        # Chinese social menu
│   ├── menu.en.toml        # English social menu
│   ├── markup.toml         # Markdown rendering settings
│   ├── module.toml         # Hugo Module: imports the Stack theme
│   ├── permalinks.toml     # URL structure
│   └── related.toml        # related-post recommendations
├── content/
│   ├── zh/                 # Chinese content (default language, at root)
│   │   ├── _index.md
│   │   ├── page/           # archives / search / links
│   │   └── post/           # articles
│   └── en/                 # English content (at /en/)
├── go.mod / go.sum         # theme module dependency
└── .gitignore
```

## FAQ

**Q: Styles broken / assets 404?** Most likely `baseurl` is wrong, or the site isn't served under the expected subpath.

**Q: How do I update the theme?** The template includes a daily auto-update workflow (`update-theme.yml`), or manually:

```bash
hugo mod get -u github.com/CaiJimmy/hugo-theme-stack/v4
hugo mod tidy
```

**Q: Chinese reading time is inaccurate?** Make sure `hasCJKLanguage = true` is set.

**Q: Dart Sass errors locally?** The theme's SCSS requires Dart Sass (not libsass) — install it and add it to PATH.

## Wrap-up

The heaviest part of this whole workflow is writing; the toolchain itself takes half an hour to get running. A static blog with Markdown + Git means content focus and near-zero maintenance — perfect for long-term use. I'm planning to also publish my graduate-exam study notes here. Feel free to exchange links!
