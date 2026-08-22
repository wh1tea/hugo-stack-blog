---
title: YAML 入门：从语法到陷阱
slug: yaml-intro
date: 2026-08-16T22:28:16+08:00
description: YAML 基础语法、数据类型、列表映射、多行字符串与常见坑，附 Hugo front matter 实战，读完能读写规范的 YAML 配置
tags:
  - yaml
  - hugo
  - config
categories:
  - tutorial
---

YAML（YAML Ain't Markup Language）是一种面向配置的数据序列化格式，和 JSON 同样表达数据结构，但更强调可读性。Hugo 的 front matter、GitHub Actions 的工作流、Docker Compose、Ansible 乃至 Kubernetes 的配置，全是 YAML 写的。

本文面向有编程基础、见过 YAML 但没系统学过的读者，从语法到常见陷阱一次讲清。读完你能读懂并写出规范的 YAML 配置，也能看懂本站每篇文章开头的 front matter。

## 基本语法

YAML 的核心是**键值对**和**缩进**：

```yaml
# 键: 值，冒号后必须有空格
title: 我的博客
author: wh1tea

# 缩进表示层级，用空格，禁止 Tab
site:
  name: wh1tea 的博客
  language: zh
```

三个要点：

- 缩进用空格（习惯 2 格），**禁止 Tab**，混用直接解析失败
- `#` 开头是注释，注释到行尾
- 键默认是字符串，值可以是任意数据类型

## 数据类型

| 类型     | 写法示例                                  | 说明                                 |
| :------- | :---------------------------------------- | :----------------------------------- |
| 字符串   | `hello`、`"hello"`、`'hello'`             | 裸字符串最常用；含特殊字符时加引号   |
| 数字     | `42`、`3.14`、`1e3`、`0x1F`               | 整数 / 浮点 / 科学计数 / 十六进制    |
| 布尔     | `true`、`false`                           | YAML 1.2 只认这两个                  |
| 空值     | `null`、`~`、留空                         | 三种写法等价                         |
| 日期时间 | `2026-08-16`、`2026-08-16T22:00:00+08:00` | 裸日期会被解析为日期对象（见常见坑） |

引号规则：双引号支持转义（`"\n"` 是换行），单引号是字面量。需要保留前导零、含 `:` 或 `#` 的字符串，都建议加引号。

## 列表与映射

列表（数组）用 `-` 开头，或内联写法 `[...]`：

```yaml
tags:
  - yaml
  - hugo
  - config

# 等价内联写法
tags: [yaml, hugo, config]
```

映射（对象）就是键值对，可以任意嵌套。列表里套映射是配置文件最常见的结构：

```yaml
menu:
  - name: 首页
    url: /
  - name: 归档
    url: /archives/
```

## 多行字符串

长文本用块标量，`|` 保留换行，`>` 把换行折叠成空格：

```yaml
description: |
  第一行
  第二行

summary: >
  这一整段
  会被折叠成
  一行
```

`|` 适合代码块、保留原文格式；`>` 适合长段落。块标量最后一行换行会被保留，可用 `|-`、`>-` 去掉末尾换行。

## 锚点与别名

用 `&` 定义锚点、`*` 引用，避免重复配置：

```yaml
defaults: &defaults
  timeout: 30
  retries: 3

job-a:
  <<: *defaults
  command: build

job-b:
  <<: *defaults
  command: deploy
```

`<<` 是合并键，把锚点的内容展开到当前映射。多环境部署、CI 任务复用配置时很实用。

## 常见坑

- **Tab 缩进**：YAML 只认空格。编辑器里显示正常不代表没有 Tab，报错时先查缩进
- **前导零变数字**：`001` 会被解析成 `1`。学号、编号、版本号这类字符串要加引号：`"001"`
- **`yes` / `no` / `on` / `off` 是布尔陷阱**：YAML 1.1 解析器（如旧版 PyYAML）会把它们当布尔值。保险起见一律加引号或写 `true` / `false`
- **冒号后必须有空格**：`key:value` 会解析失败，除非整个字符串在引号里
- **裸日期被解析**：`date: 2026-08-16` 会被当日期对象，再输出可能变成别的格式。要当字符串就加引号
- **特殊字符开头要引号**：`*`、`&`、`!`、`|`、`>`、`@` 等开头的值会被当语法符号，加引号最稳妥
- **中文不需要引号**：YAML 原生支持 UTF-8，但注意不要用全角冒号 `：` 当键值分隔符

## 与 Hugo 结合

本站每篇文章的 front matter 就是一段 YAML，最常用的两个约定：

- `tags` / `categories` 用块序列（每行一个 `-`），不写内联数组
- `date` 用 RFC3339 带时区（`2026-08-16T22:28:16+08:00`），避免时区歧义
- `slug` 必须显式写，中文标题不写会被 URL 编码成乱码

front matter 的完整规范见 [Front Matter CMS 教程](../vscode/front-matter-cms.md)，博客搭建与 front matter 示例见 [Hugo 博客搭建记录](../hugo/hugo-stack-github-pages.md)。

## 结语

YAML 语法不多，半小时就能上手：键值对加缩进是骨架，列表映射是血肉，引号和块标量处理特殊情况。真正容易翻车的是隐式类型转换——`001`、`yes`、裸日期这些"看起来没问题"的值。记住一条原则：**拿不准就加引号**。

配合 Front Matter CMS 这类可视化工具，front matter 基本不用手写；但读得懂 YAML，排查配置问题、写 CI 工作流时才能得心应手。

## 参考

- [YAML 官方规范（yaml.org）](https://yaml.org/) —— 规范主页与最新 Spec 1.2.2
- [Learn X in Y minutes — YAML](https://learnxinyminutes.com/docs/yaml/) —— 一页速查，覆盖全部语法点
- [yaml-multiline.info](https://yaml-multiline.info/) —— 多行字符串（`|` / `>`）行为对照速查
- [Hugo 官方文档 — Front Matter](https://gohugo.io/content-management/front-matter/) —— Hugo 对 front matter 字段的定义
