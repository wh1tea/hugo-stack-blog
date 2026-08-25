---
title: Tutorial of Setting Up a GitHub.io Blog
date: 2026-05-15
description: Step-by-step guide to creating a personal blog with GitHub Pages — from repository setup to first deployment.
tags:
  - github-pages
  - blog
  - getting-started
categories:
  - devtools
---

GitHub Pages is a free static site hosting service that turns a GitHub repository into a live website. This guide walks you through creating your personal blog — no server, no database, no cost.

## Creating Your Repository

1. Log in to your [GitHub](https://github.com) account.
2. Click the **+** icon (top right) → **New repository**.
3. Name it exactly `<your-username>.github.io` (e.g., `wh1tea.github.io`).
4. Set it to **Public**.
5. Click **Create repository**.

> Your site will be live at `https://<your-username>.github.io` immediately after you push content.

## Cloning to Your Local Machine

```bash
git clone https://github.com/<username>/<username>.github.io.git
cd <username>.github.io
```

## Adding Content

### Option A: Custom HTML/CSS (No Jekyll)

Create a file named `index.html` in the repository root:

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Blog</title>
  </head>
  <body>
    <h1>Hello, World!</h1>
    <p>Welcome to my GitHub Pages site.</p>
  </body>
</html>
```

To disable Jekyll processing (recommended for pure static sites), add a `.nojekyll` file:

```bash
touch .nojekyll
```

### Option B: Jekyll (Built-in Theme)

GitHub Pages supports Jekyll out of the box. Create a `_config.yml`:

```yaml
title: My Blog
theme: jekyll-theme-minimal
```

## Deploying

```bash
git add .
git commit -m "Initial commit"
git push origin main
```

Within a few minutes, your site will be live at `https://<username>.github.io`.

## Next Steps

- Add a custom domain (Settings → Pages → Custom domain)
- Use Markdown for blog posts with a static site generator
- Set up GitHub Actions for automated builds
- Enable HTTPS (automatic for GitHub Pages with custom domains)

## 参考

- [Quickstart for GitHub Pages](https://docs.github.com/en/pages/quickstart)
- [Adding content to your GitHub Pages site using Jekyll](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/adding-content-to-your-github-pages-site-using-jekyll)
- [Custom domains on GitHub Pages](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site)
