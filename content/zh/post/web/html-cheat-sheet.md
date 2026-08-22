---
title: HTML 语法与常见任务速查表
slug: html-cheat-sheet
date: 2026-07-27
description: 一份面向开发者的 HTML 速查表，涵盖常用标签、属性、语义化写法与代码片段，助你快速查阅与规范书写。
tags:
  - html
  - cheatsheet
  - web
  - frontend
categories:
  - web
---

使用 HTML 时，若能有一种简单的方法记住如何正确使用和应用 HTML 标签，将会非常方便。这份速查表面向有编程基础的开发者，旨在为常见用法提供快速、准确、现成的代码片段。

> **核心原则**：HTML 标签应根据其**语义价值**而非外观使用。完全可以使用 CSS 改变特定标签的外观和特性。使用 HTML 时，要花时间留意标签的**语义**，而非它们的外观。

---

## 文档结构与基础

### 基本 HTML 文档

每个 HTML 文档都以文档类型声明开始，并遵循标准结构。

```html
<!DOCTYPE html>
<html lang="zh-CN">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>页面标题</title>
  </head>
  <body>
    <!-- 页面内容放在这里 -->
  </body>
</html>
```

### Head 中的常用元数据

```html
<!-- 字符编码 -->
<meta charset="UTF-8" />
<!-- 响应式视口 -->
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<!-- 页面描述（SEO） -->
<meta name="description" content="页面描述" />
<!-- 链接 CSS -->
<link rel="stylesheet" href="styles.css" />
<!-- 链接 favicon -->
<link rel="icon" href="favicon.ico" />
```

### HTML 注释

```html
<!-- 这是一个单行注释 -->

<!--
  这是一个多行注释
  用于更长的解释
-->
```

---

## 文本内容元素

### 标题（h1–h6）

定义内容层次结构和重要性。`<h1>` 应作为主标题使用一次，然后是 `<h2>`、`<h3>` 等。

```html
<h1>主标题</h1>
<h2>章节标题</h2>
<h3>子章节标题</h3>
<h4>次级子章节标题</h4>
<h5>小标题</h5>
<h6>最小标题</h6>
```

### 段落与文本

```html
<p>这是包含文本的段落。它可以包含多个句子，并且会自动换行。</p>
<p>这是另一个段落。段落之间有边距间隔。</p>
```

### 行内文本格式化

| 用途              | 元素       | 示例                                |
| ----------------- | ---------- | ----------------------------------- |
| 重要/强调（粗体） | `<strong>` | `<strong>我很重要！</strong>`       |
| 强调（斜体）      | `<em>`     | `<em>我很时髦</em>`                 |
| 粗体（无语义）    | `<b>`      | `<b>加粗单词或短语</b>`             |
| 斜体（无语义）    | `<i>`      | `<i>斜体标记短语</i>`               |
| 高亮              | `<mark>`   | `<mark>注意这里！</mark>`           |
| 删除线            | `<s>`      | `<s>我无关紧要。</s>`               |
| 下划线            | `<u>`      | `<u>带下划线的文本</u>`             |
| 小字              | `<small>`  | `<small>小字</small>`               |
| 上标              | `<sup>`    | `x<sup>2</sup>`                     |
| 下标              | `<sub>`    | `H<sub>2</sub>O`                    |
| 插入文本          | `<ins>`    | `<ins>已插入文本</ins>`             |
| 删除文本          | `<del>`    | `<del>已删除文本</del>`             |
| 代码格式          | `<code>`   | `<code>console.log('Hello')</code>` |
| 预格式化          | `<pre>`    | 保留空格和换行                      |

### 换行与分隔线

```html
<!-- 换行 -->
第 1 行<br />第 2 行

<!-- 水平分隔线 -->
<hr />
```

### 引用与地址

```html
<!-- 内联引用 -->
<q>我？</q>，她说道。

<!-- 文献引用 -->
<cite>《怪物书》</cite>

<!-- 联系信息 -->
<address>主大街 67 号</address>

<!-- 块级引用 -->
<blockquote>
  <p>这是一个块级引用。</p>
</blockquote>
```

### 日期与时间

```html
<time datetime="2020-05-24">发布于 2020 年 5 月 23 日</time>
```

---

## 链接与图片

### 链接（`<a>`）

```html
<!-- 普通链接 -->
<a href="https://example.org">至 example.org 的链接</a>

<!-- 在新标签页打开 -->
<a href="https://example.org" target="_blank">新窗口打开</a>

<!-- 邮件链接 -->
<a href="mailto:someone@example.com">发送邮件</a>

<!-- 页面内锚点 -->
<a href="#section">跳转到某章节</a>
```

### 图片（`<img>`）

```html
<img src="beast.png" alt="替换文本" width="50" />
```

---

## 列表

### 无序列表（`<ul>`）

```html
<ul>
  <li>第一项</li>
  <li>第二项</li>
  <li>第三项</li>
</ul>
```

### 有序列表（`<ol>`）

```html
<ol>
  <li>第一项</li>
  <li>第二项</li>
  <li>第三项</li>
</ol>
```

### 嵌套列表

```html
<ul>
  <li>
    项目
    <ul>
      <li>子项目</li>
    </ul>
  </li>
</ul>
```

### 定义列表（`<dl>`）

```html
<dl>
  <dt>术语</dt>
  <dd>术语的定义</dd>
</dl>
```

---

## 表格（`<table>`）

### 基础表格结构

```html
<table>
  <thead>
    <tr>
      <th>表头 1</th>
      <th>表头 2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>数据 1</td>
      <td>数据 2</td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td>表尾 1</td>
      <td>表尾 2</td>
    </tr>
  </tfoot>
</table>
```

### 表格常用属性

- `colspan`：跨列合并
- `rowspan`：跨行合并

```html
<td colspan="2">跨两列</td>
```

---

## 表单（`<form>`）

### 基本表单结构

```html
<form action="/submit" method="POST">
  <!-- 表单控件 -->
</form>
```

### 常用表单控件

| 类型     | 元素                      | 示例                                             |
| -------- | ------------------------- | ------------------------------------------------ |
| 文本输入 | `<input type="text">`     | `<input type="text" name="username" />`          |
| 密码     | `<input type="password">` | `<input type="password" name="pwd" />`           |
| 邮箱     | `<input type="email">`    | `<input type="email" name="email" />`            |
| 数字     | `<input type="number">`   | `<input type="number" name="age" />`             |
| 单选     | `<input type="radio">`    | `<input type="radio" name="gender" value="M" />` |
| 复选框   | `<input type="checkbox">` | `<input type="checkbox" name="hobby" />`         |
| 提交按钮 | `<input type="submit">`   | `<input type="submit" value="提交" />`           |
| 文本域   | `<textarea>`              | `<textarea name="desc" rows="4"></textarea>`     |
| 下拉列表 | `<select>`                | `<select><option>选项</option></select>`         |
| 标签     | `<label>`                 | `<label for="name">姓名</label>`                 |

### 表单分组与语义化

```html
<fieldset>
  <legend>个人信息</legend>
  <label for="name">姓名</label>
  <input type="text" id="name" name="name" />
</fieldset>
```

> **提示**：每个 `<input>` 标签对应的说明文本都应使用 `<label>` 标签，并通过 `for` 属性与 `id` 关联。

---

## 语义化结构标签

| 标签           | 用途                |
| -------------- | ------------------- |
| `<header>`     | 页眉或区块头部      |
| `<nav>`        | 导航链接            |
| `<main>`       | 页面主内容          |
| `<article>`    | 独立、完整的内容块  |
| `<section>`    | 文档中的节/区段     |
| `<aside>`      | 侧边栏或补充内容    |
| `<footer>`     | 页脚或区块底部      |
| `<figure>`     | 插图/图表等独立内容 |
| `<figcaption>` | `<figure>` 的标题   |

```html
<header>
  <h1>网站标题</h1>
  <nav>导航链接</nav>
</header>
<main>
  <article>
    <h2>文章标题</h2>
    <p>文章内容</p>
  </article>
</main>
<footer>版权信息</footer>
```

---

## 容器与分组

| 标签     | 用途               |
| -------- | ------------------ |
| `<div>`  | 块级容器（无语义） |
| `<span>` | 行内容器（无语义） |

```html
<div>
  <span style="color:blue">蓝色文字</span>
</div>
```

---

## 媒体与嵌入

### 音频（`<audio>`）

```html
<audio controls>
  <source src="audio.mp3" type="audio/mpeg" />
</audio>
```

### 视频（`<video>`）

```html
<video controls width="400">
  <source src="video.mp4" type="video/mp4" />
</video>
```

### 内联框架（`<iframe>`）

```html
<iframe src="https://example.org" width="600" height="400"></iframe>
```

---

## 全局属性（常用）

所有 HTML 元素均可使用以下属性：

| 属性       | 说明                    |
| ---------- | ----------------------- |
| `id`       | 唯一标识符              |
| `class`    | 类名（用于 CSS/JS）     |
| `style`    | 内联样式                |
| `title`    | 提示信息                |
| `lang`     | 语言代码                |
| `dir`      | 文字方向（`ltr`/`rtl`） |
| `hidden`   | 隐藏元素                |
| `tabindex` | Tab 键顺序              |
| `data-*`   | 自定义数据属性          |

---

## 常用实体字符

| 实体     | 显示     | 说明       |
| -------- | -------- | ---------- |
| `&lt;`   | `<`      | 小于号     |
| `&gt;`   | `>`      | 大于号     |
| `&amp;`  | `&`      | 和号       |
| `&quot;` | `"`      | 双引号     |
| `&copy;` | `©`      | 版权符号   |
| `&nbsp;` | （空格） | 不换行空格 |

[More…](html-entities)

---

## 总结

这份速查表涵盖了 HTML 开发中最常用的标签、属性和代码片段。核心要点：

1. **语义优先**：根据内容选择最恰当的标签，而非根据外观。
2. **结构清晰**：合理使用标题层级（h1–h6）和语义化标签（header、nav、main、article 等）。
3. **表单可访问性**：始终使用 `<label>` 关联表单控件。
4. **保持简洁**：能用 HTML 语义表达的，不滥用 `<div>` 和 `<span>`。

建议将本速查表打印或收藏，日常开发中随时查阅。深入理解可参考 [MDN HTML 元素参考](https://developer.mozilla.org/zh-CN/docs/Web/HTML/Reference/Elements)。

---

## 参考

- [MDN HTML 语法与常见任务速查表](https://developer.mozilla.org/zh-CN/docs/Web/HTML/Guides/Cheatsheet)
- [MDN HTML 元素参考](https://developer.mozilla.org/zh-CN/docs/Web/HTML/Reference/Elements)
- [菜鸟教程 HTML 速查列表](https://www.runoob.com/html/html-quicklist.html)
- [LabEx HTML 速查表](https://labex.io/cheatsheets/zh/html)
