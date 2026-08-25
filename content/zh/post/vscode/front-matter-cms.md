---
title: Front Matter CMS：在 VS Code 里管理 Hugo 博客
slug: front-matter-cms
date: 2026-08-16T21:50:51+08:00
description: 用 Front Matter CMS 插件以仪表盘管理 Hugo 博客的 front matter 与文章，含 frontmatter.json 完整配置与踩坑记录
tags:
  - vscode
  - front-matter
  - hugo
  - cms
categories:
  - devtools
---

静态博客的内容管理一直是痛点：文章是纯 Markdown，front matter 只能手写，标签和分类没有可视化管理，新建文章还要记模板。Front Matter CMS 是一个 VS Code 插件，把这一切变成可视化的仪表盘。

本文以本博客（Hugo + Stack v4）为例，从安装、配置到日常使用完整走一遍，并记录配置过程中踩过的四个坑。读完你就能在 VS Code 里用仪表盘管理自己的博客。

## 简介

Front Matter CMS（插件 ID `eliostruyf.vscode-front-matter`）是一个面向静态站点的 Headless CMS：不引入数据库和后台服务，所有数据仍是 Markdown 文件，插件只是提供一个可视化编辑界面。

它适合这样的场景：站点用 Hugo / Next.js / 11ty 等 SSG，内容以 Markdown 为主，想摆脱手写 front matter 但又不愿意上重量级 CMS（Content Management System）。核心能力：

- 内容仪表盘：按文件夹展示文章，支持搜索、筛选、排序
- 表单式编辑 front matter：标题、日期、标签、分类、封面图都是输入框
- 内容类型模板：定义好字段，新建文章自动套用
- 分类法管理：标签和分类在侧边栏统一维护

## 安装与仪表盘

在扩展市场搜索 `Front Matter` 安装即可，作者是 Esteban Sastre。

安装后侧边栏出现 Front Matter 图标，点击打开仪表盘（也可用命令「打开仪表盘」）。内容区左侧是配置过的文件夹树，右侧是文章列表，顶部有搜索框和排序下拉。点开一篇文章，会进入表单视图，front matter 的每个字段对应一个输入控件，正文是 Markdown 编辑区。

## 配置文件 frontmatter.json

插件的项目配置是根目录的 `frontmatter.json`，用 `$schema` 声明格式，VS Code 里编辑时有补全和校验：

```json
{
  "$schema": "https://frontmatter.codes/frontmatter.schema.json"
}
```

本博客的完整配置见下文各节。注意版本差异：v10 系列只读取根目录 `frontmatter.json` 和 `.frontmatter/config/` 目录，旧文档里说的 `.frontmatter/config.json` 文件已不再读取。

### 内容文件夹 pageFolders

`frontMatter.content.pageFolders` 声明内容目录，只有配置过的文件夹才会出现在仪表盘：

```json
"frontMatter.content.pageFolders": [
  {
    "title": "zh/post",
    "path": "[[workspace]]/content/zh/post",
    "contentTypes": ["default"],
    "excludePaths": [".obsidian", ".obsidian/**"]
  },
  {
    "title": "en/post",
    "path": "[[workspace]]/content/en/post",
    "contentTypes": ["default"]
  }
]
```

两个要点：

- `path` 必须写成 `[[workspace]]/...` 前缀或绝对路径。裸相对路径 `content/zh/post` 不会拼上工作区根目录，Windows 上必然报「Folder does not exist」（详见踩坑记录）
- `excludePaths` 排除子目录，比如本站 `content/zh/post/` 下 Obsidian 生成的 `.obsidian` 配置目录

### 内容类型 contentTypes

`frontMatter.taxonomy.contentTypes` 定义新建文章时的字段模板，字段对应 front matter 的键：

```json
"frontMatter.taxonomy.contentTypes": [
  {
    "name": "default",
    "pageBundle": false,
    "clearEmpty": true,
    "fields": [
      { "title": "Title", "name": "title", "type": "string", "required": true },
      { "title": "Slug", "name": "slug", "type": "string", "required": true },
      { "title": "Publishing date", "name": "date", "type": "datetime", "default": "{{now}}", "isPublishDate": true, "required": true },
      { "title": "Description", "name": "description", "type": "string" },
      { "title": "Categories", "name": "categories", "type": "categories" },
      { "title": "Tags", "name": "tags", "type": "tags" },
      { "title": "Featured image", "name": "image", "type": "image", "isPreviewImage": true },
      { "title": "Is in draft", "name": "draft", "type": "draft", "default": false }
    ]
  }
]
```

**fields 数组的顺序就是新建文章 front matter 的键顺序**——插件按数组顺序逐个写入字段，输出时不做任何重排。想控制键顺序，直接把字段按目标顺序排列即可（本文的顺序是 title → slug → date → description → categories → tags → image → draft）。编辑已有文章时则保持文件原有顺序，不会被 fields 重排。

其他要点：

- `required: true` 的字段不填无法保存，适合强制 slug 必填（中文标题不写 slug 会被 URL 编码成乱码）
- `default: "{{now}}"` 让 date 新建时自动填当前时间
- `isPublishDate: true` 标记该字段为发布日期，仪表盘内置的 Published 排序按它排
- `type: "draft"` 对应 Hugo 的 `draft` 字段，表单里是个开关；配 `default: false` 让新建文章默认已发布（不配的话插件会默认写 `draft: true`）
- `clearEmpty: true` 跳过空字段，新建时不会出现 `slug: ""`、`tags: []` 这类空值噪音
- 内容类型名保持 `default`：自定义名字（如 `post`）新建时会在 front matter 里多写一个 `fmContentType: <名字>` 字段（详见踩坑记录）

### 排序 sorting

排序下拉的选项分内置和自定义两类。内置三组：LastModified（修改时间）、Published（发布时间）、FileName（文件名），始终出现在下拉里；`frontMatter.content.sorting` 用于追加自定义选项，`defaultSorting` 指定默认项。

本站不配自定义排序——内容类型里 date 字段标了 `isPublishDate: true`，内置的 Published 排序就是按 date 排的，再自定义 date / 文件名 / 发布日期排序都是重复添加。所以配置只留一行默认项：

```json
"frontMatter.content.defaultSorting": "PublishedDesc"
```

`defaultSorting` 填内置枚举值（`LastModifiedAsc` / `LastModifiedDesc`、`FileNameAsc` / `FileNameDesc`、`PublishedAsc` / `PublishedDesc`）即可，也可以填自定义排序的 `id`。如果确实需要自定义排序（比如想要中文标签），`name` 是 front matter 字段名，`type` 决定按字符串还是日期比较（详见踩坑记录「文件名排序的字段名」）。

### 日期格式 dateFormat

`frontMatter.taxonomy.dateFormat` 控制所有日期字段的写入格式，用 date-fns 的格式串：

```json
"frontMatter.taxonomy.dateFormat": "yyyy-MM-dd'T'HH:mm:ssxxx"
```

不配置的话，插件写日期会回退到 `toISOString()`，生成 `2026-08-16T13:00:00.000Z` 这种 UTC 加毫秒的格式，和 Hugo 博客习惯的 RFC3339 带时区（`2026-08-16T21:00:00+08:00`）不一致。上面这个格式串在 +08:00 时区下就输出 RFC3339。

## 日常使用流程

配置完成后，日常写文章就是一套固定流程：

1. 打开仪表盘，选中目标文件夹（zh/post 或 en/post）
2. 点排序下拉，默认已经是「日期 新→旧」
3. 点 + 新建文章，选 `default` 内容类型：填标题、slug、描述，date 已自动填当前时间
4. 正文在 Markdown 编辑区写，front matter 在表单里改
5. 保存后文章就位，正常走 Hugo 构建部署

一个小提醒：本站的布局是 `content/<lang>/post/<topic>/`，新建时记得选到具体的主题子文件夹（git、hugo、vscode 等）下，而不是直接落在 `post/` 根目录。

## 踩坑记录

### 相对路径报「文件夹不存在」

`pageFolders` 的 `path` 写成 `content/zh/post` 这种相对路径后，仪表盘报错「Folder does not exist. Please remove it from the settings.」。翻插件源码发现，路径解析只做两件事：把 `[[workspace]]` 替换成工作区根目录、处理 `../` 上跳；裸相对路径不会拼接工作区，直接拿去 `existsSync` 检查，Windows 上必然失败。修法是恢复 `[[workspace]]/` 前缀。

### 插件内存回写覆盖外部修改

插件会把配置缓存在内存里。先打开 VS Code 再手动改 `frontmatter.json`，之后插件一旦保存（比如在 UI 里改了任何设置），会用内存里的旧配置整体回写，手工改动全被吞掉。这是最隐蔽的一个坑。修法：改完配置文件立刻 `Developer: Reload Window` 让插件重新读取；之后要改配置直接编辑 `frontmatter.json`，不要通过 UI 面板改。

### 文件名排序的字段名

内置的 By filename 排序已经覆盖文件名排序，一般不需要自定义。如果确实要自定义（比如想要中文标签），`name` 必须写虚拟字段 `fmFileName`：自定义排序按 `name` 去文章对象上取值，文章对象的虚拟字段是 `fmFileName`（文件名）、`fmModified`（修改时间）、`fmPublished`（发布日期），写 `filename` 不会报错但结果恒为空，排查起来很费劲。

### 命名内容类型会写入 fmContentType

内容类型名字换成自定义值（如 `post`）后，新建文章会自动在 front matter 里多一个 `fmContentType: post` 字段，而且没有设置可以关闭。Hugo 会忽略未知字段，但会让 front matter 不干净。修法：内容类型名保持 `default`，`fmContentType` 就不会写入。这也是为什么上文示例用 `default` 而不是 `post`。

## 结语

Front Matter CMS 把静态博客的内容管理体验提升了一个档次：可视化仪表盘、字段模板、排序筛选，全部不脱离 VS Code 和 Markdown。配置上有几个坑（`[[workspace]]` 前缀、内存回写、`fmFileName`、`fmContentType`），本博客的完整配置就在 `frontmatter.json`，可以直接抄。

如果你的博客也是 Hugo + Stack 主题，这套配置开箱即用；其他 SSG 只需调整 `framework.id` 和 `pageFolders`。想进一步了解字段类型和高级功能，看官方文档。

## 参考

- [IvonBlog — VS Code Front Matter CMS 教學](https://ivonblog.com/posts/vscode-front-matter-cms/) —— 中文教程，覆盖安装与基础配置
- [Front Matter CMS 官方文档](https://frontmatter.codes/docs) —— 设置项与字段类型的权威参考
- [VS Code 扩展市场 — Front Matter](https://marketplace.visualstudio.com/items?itemName=eliostruyf.vscode-front-matter)
- 相关文章：[VS Code 插件配置](../vscode/vscode-extensions-config.md)、[Hugo 博客搭建记录](../hugo/hugo-stack-github-pages.md)
