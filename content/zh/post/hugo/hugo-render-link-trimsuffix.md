---
title: Hugo 模板函数参数写反，站内链接全变死链
slug: hugo-render-link-trimsuffix
date: 2026-09-11T22:22:00+08:00
description: 一个函数参数顺序写反，全站站内链接变成 href=.md 死链，构建却零报错。记录定位、修复与验证方法。
tags:
  - templates
  - troubleshooting
categories:
  - hugo
---

站点上线后，我发现文章里的站内互链全点不动了：点一下直接 404。翻看构建产物，每一条站内链接都长这样——`<a class="link" href=".md">某篇文章</a>`。

最坑的地方在于，Hugo 构建全程没有报错也没有警告，页面数、sitemap、RSS 全都正常，只有链接悄悄坏掉。这篇记录一下定位、修复和验证过程，也顺便说清一个很容易踩的坑：**Hugo 的模板函数参数顺序，和 Go 标准库不一样**。

## 症状：站内链接全部变成死链

构建产物里的链接：

```html
<a class="link" href=".md">某篇文章</a>
```

浏览器把 `.md` 当成相对路径，于是去请求「当前页目录 + .md」，也就是 `/p/<当前文章>/.md`，自然是 404。全站 49 处站内链接、20 个文件都是这个下场。

## 根因：参数顺序写反了

出问题的是项目的链接渲染钩子 `layouts/_default/_markup/render-link.html`，它把 `.md` 后缀处理写成了：

```go-html-template
{{- $href = strings.TrimSuffix $href ".md" -}}
```

Hugo 的函数签名是 `strings.TrimSuffix SUFFIX STRING`，**后缀在前**[^1]；而 Go 标准库是 `strings.TrimSuffix(s, suffix)`，字符串在前[^2]。直觉上按 Go 的顺序写——「从 `$href` 里去掉 `.md` 后缀」——在 Hugo 里就翻车了。

于是它实际执行的是「从字符串 `.md` 里去掉后缀 `$href`」，两者根本不匹配，函数老老实实把 `.md` 原样返回。参数写反不会报错：函数照样返回一个合法字符串，问题就静默地进了产物。

实测对照（Hugo 0.164）：

| 写法                                | 返回值 | 说明                                                       |
| :---------------------------------- | :----- | :--------------------------------------------------------- |
| `strings.TrimSuffix ".md" "foo.md"` | `foo`  | 正确：后缀在前                                             |
| `strings.TrimSuffix "foo.md" ".md"` | `.md`  | 写反：从字符串 `.md` 里去掉后缀 `foo.md`，去不掉就原样返回 |

## 修：换回参数顺序，并解析目标页

最直接的修复是把参数换回来：

```go-html-template
{{- $href = strings.TrimSuffix ".md" $href -}}
```

但只换参数还不够稳。去掉后缀得到的是相对路径，它只在「文件名 = slug」时刚好等于扁平 URL `/p/<slug>/`；碰上没写 slug 的文章（URL 由标题编码生成）或跨文件夹的 `../topic/x.md`，浏览器解析出来依旧是错的。

更稳的做法是**解析成目标页面，再输出该页的 RelPermalink**——它自带 baseURL 子路径，本地预览和线上都对[^3]。钩子的上下文里可以用 `PageInner` 查页面[^4]：

```go-html-template
{{- $href := .Destination -}}
{{- $isExternal := or (strings.HasPrefix $href "http") (strings.HasPrefix $href "mailto:") (strings.HasPrefix $href "#") -}}
{{- if not $isExternal -}}
    {{- $path := strings.TrimSuffix ".md" (strings.TrimPrefix "./" $href) -}}
    {{- $target := .PageInner.GetPage $path -}}
    {{- if not $target -}}
        {{- with .PageInner.File -}}{{- $target = site.GetPage (path.Join .Dir $path) -}}{{- end -}}
    {{- end -}}
    {{- with $target -}}{{- $href = .RelPermalink -}}{{- end -}}
{{- end -}}
<a class="link" href="{{ $href | safeURL }}" {{ with .Title}} title="{{ . }}"
    {{ end }}>{{ .Text | safeHTML }}</a>
```

第二层 `path.Join` 是给 leaf bundle 准备的：`xxx/index.md` 这类页面用 `GetPage` 解析不了 `../topic/x.md`，得先把链接按当前页的文件目录拼好，再交给 `site.GetPage`。Hugo 自带的默认链接钩子也是同一套思路：解析出目标页，然后输出它的 `.RelPermalink`[^5]。如果还想支持「只写文件名」的 Obsidian 式链接，再加一层按 `.File.ContentBaseName` 匹配的兜底就行。

## 怎么发现死链并验证修好了

模板类 bug 不会报错，所以只能查产物，不能只看构建是否成功。

- 快速筛查：`grep -ro 'href="\.md"' public/ | wc -l`。改造前这个数字是 49，修完是 0。
- 全站核对：写个脚本遍历 `public/` 下所有 HTML，抽出每个站内 `href`，映射回构建产物里的文件路径逐个检查是否存在。上千条链接里哪一条坏掉都会被列出来，比抽查可靠得多；改模板、改 permalink、改文件夹之后都值得跑一遍。
- 负向验证：故意把参数再写反一次，确认问题能复现。只有能复现，才能证明修复真的生效——否则很可能只是碰巧看起来好了。

## 结语

- 抄模板函数之前先看官方文档的 Syntax 行：Hugo 的参数顺序常与 Go 标准库相反，`strings.TrimSuffix` 就是典型的「后缀在前」[^1]。
- 这类静默失败的 bug，靠「构建成功」判断不了，只能靠产物级检查兜底：把链接核对脚本固化下来，改模板或改 URL 结构后跑一遍。
- 站内链接机制与本站其它机械细节，见构建记录：[用 Hugo + Stack 主题 + GitHub Pages 搭建博客](hugo-stack-github-pages/index.md)。

[^1]: [Hugo：strings.TrimSuffix 函数文档（Syntax: `strings.TrimSuffix SUFFIX STRING`）](https://gohugo.io/functions/strings/trimsuffix/)

[^2]: [Go 官方文档：strings.TrimSuffix（签名是 `func TrimSuffix(s, suffix string) string`，与 Hugo 相反）](https://go.dev/pkg/strings/#TrimSuffix)

[^3]: [Hugo：Page.RelPermalink 方法（相对 baseURL 的永久链接）](https://gohugo.io/methods/page/relpermalink/)

[^4]: [Hugo：链接渲染钩子文档（Destination / PageInner 等钩子上下文）](https://gohugo.io/render-hooks/links/)

[^5]: [Hugo 源码：内置链接钩子 render-link.html（解析目标页后输出 .RelPermalink）](https://github.com/gohugoio/hugo/blob/v0.164.0/tpl/tplimpl/embedded/templates/_markup/render-link.html)
