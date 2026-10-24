---
title: Hugo 弃用 libsass：切到 Dart Sass
slug: hugo-dart-sass-migration
date: 2026-10-23T14:20:00+08:00
description: 主题模板里的裸 toCSS 每次构建都触发 libsass 弃用警告。覆盖主题模板改用 dartsass、只压掉主题触发的两类弃用，再用声明级 diff 证明样式没变。
tags:
  - hugo
  - sass
  - troubleshooting
categories:
  - hugo
---

`hugo` 每次构建都在最前面打印一行 `WARN deprecated: css.Sass: libsass was deprecated in Hugo v0.153.0`，而主题已是最新版、项目配置里也没有任何 Sass 选项。这行警告来自主题模板里一次裸 `toCSS` 调用：Hugo 没有全局开关，只能在项目里覆盖同名模板，覆盖之后主题 scss 的弃用警告还得单独处理。

> 环境：Hugo 0.168.0 extended + hugo-theme-stack v4.0.3（Hugo Modules），Windows。

## 警告的来源

先确认不是自己的代码：`assets/`、`layouts/`、`config/` 里搜 `toCSS` 与 `css.Sass`，0 处。警告来自主题的 `layouts/_partials/head/style.html`：

```go-html-template
{{ $sass := resources.Get "scss/style.scss" }}
{{ $style := $sass | toCSS | minify | resources.Fingerprint "sha256" }}
<link rel="stylesheet" href="{{ $style.RelPermalink }}">
```

`toCSS` 是 `css.Sass` 的别名，`transpiler` 选项默认为 `libsass`，也就是 Hugo extended 自带的那套实现——从 v0.153.0 起标记为弃用，未来版本移除[^1]。

`transpiler` 只能在调用处传参。主题不改，项目侧唯一的办法是放一个同路径模板覆盖它：Hugo 的模板查找顺序是项目 → 模块，项目里的 `layouts/_partials/head/style.html` 会盖掉主题那份。

顺便把当前状态查清楚。`hugo env` 的输出里：

```text
github.com/sass/libsass="3.6.6"
github.com/sass/dart-sass/compiler="1.106.1"
```

有 libsass 那一行不代表在用 libsass，它是 Hugo 二进制自带的模块信息，永远都在。**有没有 `dart-sass/compiler` 才决定 `dartsass` 能不能用**。

## 覆盖模板并指定 transpiler

Hugo 不捆绑 Dart Sass，只调用 PATH 里的 `sass`。所以先装依赖，再改模板。

| 平台           | 安装方式                                                                                               | 备注                                                                         |
| :------------- | :----------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------- |
| Windows        | `scoop install sass`                                                                                   | shim 目录本就在 PATH，装完 `hugo env` 立刻能看见 1.106.1                     |
| WSL / Linux    | 解压 [prebuilt](https://github.com/sass/dart-sass/releases/latest) 到 `~/.local/dart-sass` 并加进 PATH | 目录要进 PATH，不是只解压                                                    |
| GitHub Actions | 构建前下载同一份 prebuilt，再把目录追加进 `$GITHUB_PATH`                                               | 本站 `deploy.yml` 早就有这步，见[构建记录](hugo-stack-github-pages/index.md) |

覆盖文件只比主题那三行多两行：

```go-html-template
{{ $sass := resources.Get "scss/style.scss" }}
{{ $opts := dict "transpiler" "dartsass" }}
{{ $style := $sass | css.Sass $opts | minify | resources.Fingerprint "sha256" }}
<link rel="stylesheet" href="{{ $style.RelPermalink }}">
```

`minify` 与 `Fingerprint` 原样保留，产物仍是 `scss/style.min.<sha256>.css`，页面侧不用改任何引用，只是哈希会变。

## 一条警告换成 25 条

只改 `transpiler` 的话，Dart Sass 立刻开始抱怨主题的 scss：`DEPRECATED [import]`（`@import` 被弃用，Dart Sass 3.0 移除[^2]）和 `DEPRECATED [global-builtin]`（`map-get` 这类全局内建函数要改成 `map.get`）。日志里多出 25 条，其中 18 条被 Hugo 折叠成一句 `repetitive deprecation warnings omitted`。

主题不改的前提下，用 `silenceDeprecations` 精确压掉这两类：

```go-html-template
{{ $opts := dict
  "transpiler" "dartsass"
  "silenceDeprecations" (slice "import" "global-builtin")
}}
```

只压这两个 ID，其它类别（`slash-div`、`color-functions` 等）保持可见。它们现在没出现，一旦出现说明主题或自己的 scss 真的有问题，提前静音等于把迁移提醒一起埋掉；换成 `--logLevel error` 同理，是静音而不是处理。

## 验证零警告与等价样式

`--panicOnWarning` 让任何 WARN 变成构建失败，正好用来测「警告是否真的没了」。输出与缓存都挪到临时目录，仓库里不写 `public/`：

```powershell
hugo --destination $env:TEMP\hugo-out --cacheDir $env:TEMP\hugo-cache --panicOnWarning
```

`ghpages` 环境（CI 用的那套配置）与默认环境各跑一遍，都是 exit 0、零 WARN。

样式等价要单独确认。两个版本各生成一个 `style.min.<hash>.css`，去掉 `@charset` 后按 `}` 切块、每块按 `;` 切声明，排序后比对：

```powershell
$t = (Get-Content $css -Raw) -replace '@charset\s*"[^"]*";', ''
$t = $t -replace '(?<=[^;{}])\}', ';}'
[regex]::Matches($t, '([a-zA-Z-]+)\s*:\s*([^;{}]+);') | ForEach-Object {
  ($_.Groups[1].Value + ':' + ($_.Groups[2].Value -replace '\s+', ' ').Trim()).ToLower()
} | Sort-Object
```

第二行 `-replace` 是关键：Dart Sass 省略块尾最后一条声明的分号，libsass 保留。不补分号，两边各有一批声明被正则漏掉，diff 里全是假差异。补完两边都是 **1493 条声明**，唯一差异是 `calc(100% - (var(--x) * 2))` 少了一层冗余括号——语义相同。

## 还没覆盖的两处

主题里还有两个模板走裸 `toCSS`：`_partials/comments/provider/artalk.html` 与 `disqusjs.html`，只在启用对应评论 provider 时渲染。本站 `[comments] enabled = false`，所以不触发；哪天开 Artalk 或 DisqusJS，同样的警告会回来，届时照上面的方式再加两个覆盖文件。

## 结语

覆盖文件是过渡方案——主题上游 `master` 目前也还是裸 `toCSS`，它修好后删掉这个文件即可。升级主题后先跑一次 `hugo --panicOnWarning`：不再报 libsass 警告，就说明可以删了。

[^1]: [css.Sass 文档](https://gohugo.io/functions/css/sass/)
[^2]: [Sass @import 弃用说明](https://sass-lang.com/d/import)
