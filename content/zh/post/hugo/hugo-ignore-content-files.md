---
title: Hugo 构建失败排查：跳过不该解析的文件
slug: hugo-ignore-content-files
date: 2026-09-11T21:52:00+08:00
description: 一个 Obsidian 模板文件让整站构建中断。从报错定位到 mounts 配置的完整排查过程，附官方文档、实测结论与自证方法。
tags:
  - obsidian
  - configuration
  - github-pages
categories:
  - hugo
draft: false
---

博客一直构建得好好的，某天 `hugo` 一跑就直接报错退出，错误信息里全是 YAML 解析细节——这就是我这次的起点：`content/` 下多了一个 Obsidian 模板文件，`{{date:...}}` 占位符写在了 front matter 里，Hugo 读到就崩，整站构建中断。

这篇文章完整记录排查过程：先看懂报错，再依次排除三个不奏效的修法，最后用挂载层面的 `files` 过滤解决，并给出可复现的验证方法。中途还撞上一个官方文档没写清的坑——否定前缀是「感叹号 + 一个空格」，写错会让内容**静默消失**。

> 实测环境：Hugo 0.164 extended + Stack v4 主题 + GitHub Pages 部署，命令在 WSL 下执行。

## 先给结论

- 根因：`content/` 里混进了 front matter 非法的文件（Obsidian 模板把 `{{date:...}}` 写进了 `date` 字段），Hugo 在**解析页面元数据**阶段就中断整站构建，退出码非 0。
- 三个反直觉点：`draft: true` 救不了（解析在前）；顶层 `ignoreFiles` 也救不了（实测对 `content` 无效）；改名加 `_` 前缀同样无效（实测）。
- 正解：在 `config/_default/module.toml` 里给**每个语言**写显式 `[[mounts]]`，在包含该目录的那条挂载上写 `files = ["! templates/**"]`——感叹号后必须有一个空格，写错会让那个语言的内容静默消失。

只想要配置的可以直接跳到[正解：mounts + files](#正解mounts--files)；想把排查思路走一遍、尤其是学会“怎么自证改动有效”，按顺序往下读。

## 现象：一个文件搞崩整站

```text
$ hugo --gc
ERROR error building site: assemble: failed to create page from pageMetaSource /templates/daily:
"…/content/private/templates/daily.md:4:8": [3:8] could not find flow map content
   1 | title: '{{date:YYYY-MM-DD}}'
   2 | slug: '{{date:YYYY-MM-DD}}'
>  3 | date: {{date:YYYY-MM-DD}}
              ^
   4 | tags:
```

三件事值得注意。

第一，报错精确指到 `date: {{date:YYYY-MM-DD}}`。`{{...}}` 是 Obsidian 模板插件的占位符语法[^1]，它给 Obsidian 用没问题，但写进 front matter 就不是合法 YAML 了。

第二，`could not find flow map content` 的意思是：YAML 里的 `{` 会被当成映射（flow map）的开始，Hugo 找不到它的收尾。

第三，也是最关键的一点——**这不是渲染错误，而是“解析页面元数据”阶段的错误**。Hugo 还没开始渲染就退出了。结论很直接：要救它，必须在 Hugo 读这个文件之前就把它挡掉，而不是在 front matter 里加开关。

## 背景：Hugo 怎么读 content

Hugo 把 `content/` 下每个 Markdown 文件变成一个“页面”，读的过程分两步：先解析 front matter（YAML / TOML / JSON），再把正文渲染成 HTML。第一步失败，第二步根本不会开始。

而“读哪些文件”这件事由**挂载（mounts）**决定。Hugo 内部把所有目录挂进一个统一文件系统：`content/zh`、`content/en`、`assets`、`layouts`……每一项都是一次挂载[^2]。默认挂载由 Hugo 按约定自动生成（比如每个语言的 `contentDir`），也可以在配置文件里自己写。

这就解释了为什么“跳过某个文件”的正确口子在挂载层：能在文件被解析成页面之前把它拦住。

## 先排除两个想当然的办法

### draft: true 为什么没用

front matter 里的 `draft: true` 只是告诉 Hugo“读完之后先别发布”。而我们的文件在解析 front matter 时就炸了，`draft` 这个键根本还没被读到——解析在前，开关在后。

### 加下划线前缀不可行

常见说法是“Hugo 会跳过 `_` 开头的文件”，实测不成立：把 `daily.md`、`weekly.md` 改名成 `_daily.md`、`_weekly.md` 后，报错一字不差（Hugo 0.164，未加任何 mounts）：

```text
ERROR error building site: assemble: failed to create page from pageMetaSource /templates/_daily:
"…/content/private/templates/_daily.md:4:8": [3:8] could not find flow map content
```

Hugo 忽略的是 **`.` 开头**的文件和目录；`_templates/` 这种下划线目录也照样解析，`_index.md` 是分支包的专用文件名而非“忽略”语义。所以这条路没有零配置的逃生口，只能动配置。

## ignoreFiles 为什么也不管用

官方全量配置文档对 `ignoreFiles` 的描述看起来正是我们要的：一串正则、用于“排除构建中的特定文件”、匹配绝对路径、作用于 `content`、`data`、`i18n` 目录[^3]。实测（Hugo 0.164）全部落空：

| 试过的写法                                                                   | 结果                               |
| :--------------------------------------------------------------------------- | :--------------------------------- |
| `content/private/templates/.*`、`/templates/.*`、`.*templates.*` 等 8 种正则 | 构建照旧失败，文件仍被当成页面解析 |
| 精确匹配绝对路径的正则（`/…/content/private/templates/.*`）                  | 同上                               |
| 用一个 front matter 完全合法的测试页 + `.*zz-ignore-test.*`                  | 该页面照样出现在 `public/`         |
| 用同一正则排除 `content/` 下的非页面文件（`.txt`）                           | 该资源照样被拷贝进 `public/`       |

结论：至少在 0.164 上，`ignoreFiles` 对 `content` 目录没有实际效果，页面和非页面资源都不受影响。别在这上面耗时间——官方文档同一页也留了提示：“更灵活的文件排除方式见 module mounts”。

## 正解：mounts + files

思路：给包含该目录的那个语言写一条**显式挂载**，并在挂载上过滤文件。

### 为什么要写全每个语言

**只要在 module 配置里自定义了任何挂载，Hugo 自动生成的按语言 `content` 挂载就会被取代。** 实测只写 `content/private` 那一条时：中文站点从 414 页掉到 9 页、英文从 49 页掉到 7 页——构建“成功”，内容却没了。

所以每个语言都要写全，以后新增语言也要补一条。可以用这条命令校验挂载是否齐全[^4]：

```bash
hugo config | sed -n '/\[module\]/,/^\[outputformats\]/p'
```

输出里应当每个语言各有一条 `[[module.mounts]] source = 'content/<lang>'`，并带上 `[mounts.sites.matrix] languages = [...]` 做语言限定。

### 排除语法的空格坑

排除模式的前缀是「感叹号 + 一个空格」。Hugo 源码里写得很直白[^5]：

```go
// NegationPrefix is the prefix that makes a pattern an exclusion.
const NegationPrefix = "! "
```

官方文档示例也写成 `'! docs/*'`。如果写成 `"!templates/**"`（感叹号后没空格），Hugo 会把它当成**包含**模式，而没有任何文件匹配它——结果整个挂载被清空：构建照常成功，那个语言的内容静默消失（实测私有区页面从 49 掉到 8，全程零报错）。

第二条规则：过滤按列表顺序匹配、**首个命中即返回**，所以排除项必须写在包含项前面：

```toml
files = ["! templates/**"]            # 只排除，其余默认包含
files = ["! templates/**", "**"]      # 同上，写全更直观
files = ["**", "! templates/**"]      # 无效：先命中 ** 就直接返回包含
```

### 完整配置

```toml
[[imports]]
    path = "github.com/CaiJimmy/hugo-theme-stack/v4"

[[mounts]]
    source = "content/zh"
    target = "content"

    [mounts.sites.matrix]
        languages = ["zh"]

[[mounts]]
    source = "content/en"
    target = "content"

    [mounts.sites.matrix]
        languages = ["en"]

[[mounts]]
    source = "content/private"
    target = "content"
    files = ["! templates/**"]      # 注意：感叹号后有一个空格

    [mounts.sites.matrix]
        languages = ["private"]
```

还有两点容易踩：

- `excludeFiles`、`includeFiles`、`lang` 从 Hugo 0.153 起已弃用，替代者是 `files` 和 `sites`，文档里标注了 Deprecated[^2]；`files` 需要 0.153 及以上版本。旧写法本身仍然可用，见下一节。
- 模式路径相对**挂载源**：写 `templates/**`，不要写成 `content/private/templates/**`。

### 旧写法还能不能用

`lang` / `excludeFiles` 虽然弃用，但**弃用不等于失效**：把上面的 `files` 换回旧键（`lang = "private"` + `excludeFiles = ["templates/**"]`），实测同样能排除，构建通过、三个语言的页面数不变，只是每次多两条警告：

```text
WARN  deprecated: module.mounts.lang was deprecated in Hugo v0.153.0 ... Replaced by the more powerful 'sites.matrix' setting
WARN  deprecated: module.mounts.excludeFiles was deprecated in Hugo v0.153.0 ... Replaced by the simpler 'files' setting
```

所以“旧写法失败”基本都发生在**迁移那一步**：旧键的值是 `templates/**`，换成 `files` 时必须补上否定前缀，写漏那个空格就掉进上面那个静默清空挂载的坑。改这类配置一次只动一个变量，否则分不清是键换了还是语法错了。

顺带一个容易多写的：自定义挂载只取代**同一组件**的默认挂载（这里只有 `content`），`data` / `layouts` / `i18n` / `archetypes` / `assets` / `static` 的默认挂载不受影响——上面那份配置只写三条 `content` 挂载就够，把默认挂载再抄一遍是噪音。

## 怎么验证真的排除了

改完不验证等于没改——尤其是上面那个空格坑，写错时构建“成功”，只是内容没了。三步自证：

1. 负向对照：故意把模式改错（例如 `files = ["! nonexistent/**"]`），构建必须重新报出最初那个错误。报不出来，说明过滤压根没生效。
2. 逐文件比对：在 `/tmp` 里复制一份项目当试验田，分别构建“过滤生效”和“把目录临时移走”两个版本，比对输出的**完整文件清单**（含 sitemap、搜索索引、分页别名）：

```bash
rm -rf public resources && hugo --gc
find public -type f | sed 's|^public/||' | sort > /tmp/fixed.txt
```

3. 看统计：构建结尾会打印每个语言的页面数（本次为 zh 414 / en 49），和改动前对比；数字不对就别提交。

另外注意：`hugo --gc` **不会**清理 `public/` 里的旧文件，验证前先 `rm -rf public resources`，否则 `find`、`grep` 的结果会骗你。

## 本地预览与线上要分开

排查完上面，又发现线上还有第二个问题：本地上锁、只在本地预览的私有内容区（`content/private/`）在 CI 上是空的，但 Hugo 依然会给它生成一个空站点，并且**每个页面的语言切换器里都多出一个指向它的入口**。修法是“按环境拆分配置”：

- Hugo 会按环境加载配置目录：`config/_default/` 是所有环境的公共部分，`config/<environment>/` 只在该环境生效[^6]。
- 运行时用 `--environment` 指定环境[^7]，也可用环境变量 `HUGO_ENVIRONMENT`；默认值是 `hugo build` 用 production、`hugo server` 用 development。所以把覆盖放进 `config/ghpages/`，本地预览完全不受影响。
- 关掉一个语言用语言配置里的 `disabled` 字段[^8]（同一页也提供 `disableLanguages`，但文档建议用前者）。新建 `config/ghpages/languages.toml`，内容如下：

```toml
[private]
    disabled = true
```

- GitHub Actions 里给构建命令补上参数（工作流语法[^9]）：

```yaml
hugo \
--gc \
--minify \
--environment ghpages \
--baseURL "${{ steps.pages.outputs.base_url }}/"
```

这里还有一个 shell 层面的坑：**不要把注释写在续行（行尾反斜杠）中间**。`#` 会就地结束这条逻辑命令，后面的 `--environment`、`--baseURL` 等参数会被静默丢掉，CI 照样“成功”但用的是错的参数。注释要写在 `hugo` 那一行之前。改完把这段命令抽出来、把 `hugo` 换成 `echo` 跑一遍，用肉眼确认参数齐全。

## 结语

- 核心结论：front matter 非法会让 Hugo 在**解析阶段**就中断整站构建，`draft`、`ignoreFiles`、`_` 前缀改名都救不了。正确的口子在挂载层：在 `module.toml` 里为每个语言写显式 `[[mounts]]`，在包含目标目录的那条挂载上写 `files = ["! 目录/**"]`。
- 两个最容易翻车的点：否定前缀是 `"! "`（感叹号后必须有空格，写错会静默清空挂载）；自定义挂载只取代**同组件**的自动挂载，所以三个语言的 `content` 挂载必须写全、其余默认挂载不用抄。旧键 `lang` / `excludeFiles` 仍可用，只是带弃用警告——别把警告当成失效。
- 行动建议：改完先做“负向对照 + 逐文件比对”再提交；本地预览与线上部署的差异用 `--environment` 加 `config/<env>/` 拆开。遇到同类问题，先翻官方 Modules 与 Configuration 两页，再看构建时的弃用警告——那通常就是版本变化的线索。
- 想先弄清整站是怎么搭起来的，可以看本站的构建记录：[用 Hugo + Stack 主题 + GitHub Pages 搭建博客](hugo-stack-github-pages/index.md)。

[^1]: [Obsidian 官方 Templates 文档（模板占位符语法）](https://help.obsidian.md/plugins/templates)

[^2]: [Hugo：模块与挂载配置（files / sites，excludeFiles 弃用说明）](https://gohugo.io/configuration/module/)

[^3]: [Hugo：全量配置项（ignoreFiles 的定义）](https://gohugo.io/configuration/all/)

[^4]: [Hugo：hugo config 命令](https://gohugo.io/commands/hugo_config/)

[^5]: [Hugo 源码：hugofs/hglob/filename_filter.go（NegationPrefix 定义）](https://github.com/gohugoio/hugo/blob/v0.164.0/hugofs/hglob/filename_filter.go)

[^6]: [Hugo：配置文件与目录（config 目录按环境拆分、HUGO_ENVIRONMENT 默认值）](https://gohugo.io/configuration/introduction/)

[^7]: [Hugo：命令行文档（`--environment` 参数）](https://gohugo.io/commands/hugo/)

[^8]: [Hugo：语言配置（disabled / disableLanguages）](https://gohugo.io/configuration/languages/)

[^9]: [GitHub：Workflow syntax for GitHub Actions](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions)
