---
title: HTML 速查表
slug: html-cheat-sheet
date: 2026-07-27
description: HTML 常用标签、属性与易错点的极简速查表，按文本、列表、表格、媒体、表单、语义结构分组。
tags:
  - html
  - cheatsheet
  - frontend
categories:
  - web
---

只记写法与易错点。标签定义以 MDN 为准[^1]。

## 文档骨架

```html
<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="页面描述" />
    <title>页面标题</title>
    <link rel="icon" href="favicon.ico" />
    <link rel="stylesheet" href="styles.css" />
  </head>
  <body>
    ...
  </body>
</html>
```

- `<!doctype html>`：标准模式，放首行。
- `lang`：页面语言，影响翻译与朗读。
- `charset`：UTF-8，放 `head` 最前。
- `viewport`：移动端布局。
- `description`：搜索结果摘要；`keywords` 已被主流搜索引擎忽略，可省。
- `author`：作者信息，可选。
- `title`：标签页与搜索结果标题，每页唯一。

## 文本

### 标题

`h1` 每页一个，`h2`–`h6` 按层级递进，不跳级。

### 行内语义

| 元素              | 用途           | 示例                              |
| :---------------- | :------------- | :-------------------------------- |
| `<strong>`        | 重要           | `<strong>重要</strong>`           |
| `<em>`            | 强调           | `<em>强调</em>`                   |
| `<b>`             | 加粗，无语义   | `<b>加粗</b>`                     |
| `<i>`             | 斜体，无语义   | `<i>斜体</i>`                     |
| `<mark>`          | 高亮           | `<mark>高亮</mark>`               |
| `<s>`             | 已过时         | `<s>旧价</s>`                     |
| `<del>`           | 已删除         | `<del>删除</del>`                 |
| `<ins>`           | 已插入         | `<ins>插入</ins>`                 |
| `<u>`             | 下划线，无语义 | `<u>下划线</u>`                   |
| `<small>`         | 小字           | `<small>小字</small>`             |
| `<sup>` / `<sub>` | 上标 / 下标    | `x<sup>2</sup>`、`H<sub>2</sub>O` |
| `<kbd>`           | 键盘输入       | `<kbd>Ctrl</kbd>`                 |
| `<samp>`          | 程序输出       | `<samp>OK</samp>`                 |
| `<var>`           | 变量名         | `<var>x</var>`                    |
| `<code>`          | 行内代码       | `<code>npm i</code>`              |
| `<pre>`           | 预格式化文本   | 代码块                            |

### 引用与联系

```html
<blockquote cite="https://example.com/source">
  <p>块级引用。</p>
</blockquote>

<p>他说：<q cite="https://example.com/source">行内引用</q>。</p>

<p>参考 <cite>HTML Living Standard</cite>。</p>

<address>主大街 67 号</address>
```

`q` 自动加引号；`cite` 属性只存来源 URL，不显示；`<cite>` 元素显示作品名；`address` 表示联系信息。

### 代码

```html
<p>行内：<code>const x = 1;</code></p>

<pre><code>function greet(name) {
  return `Hello, ${name}`;
}</code></pre>
```

`pre` 保留空格与换行；代码里的 `<` 写成 `&lt;`。

### 时间、数据与其他

```html
<time datetime="2026-08-01T10:30:00+08:00">2026 年 8 月 1 日</time>
<data value="P-1024">P-1024</data>
<ruby>汉<rp>（</rp><rt>hàn</rt><rp>）</rp></ruby>
<bdo dir="rtl">right to left</bdo>
Supercalifragilistic<wbr />expialidocious
<abbr title="HyperText Markup Language">HTML</abbr>
<dfn title="HyperText Markup Language">超文本标记语言</dfn>
```

- `wbr` 只给浏览器换行机会，不强制换行。
- `rp` 是不支持 `ruby` 的浏览器回退。
- `bdo dir="rtl"` 覆盖文字方向。
- `time` 的 `datetime` 与 `data` 的 `value` 都是机器可读值。
- `abbr` 用 `title` 给全称；`dfn` 标记术语首次定义。

### 换行与分隔

`br` 只用于强制换行，间距交给 CSS；`hr` 表示主题切换。

## 列表

```html
<ul>
  <li>无序</li>
</ul>

<ol type="1">
  <li>有序</li>
</ol>

<dl>
  <dt>术语</dt>
  <dd>定义</dd>
</dl>

<menu>
  <li><button type="button">命令</button></li>
</menu>
```

- `ol` 的 `type` 可取 `1`、`a`、`A`、`i`、`I`。
- `menu` 表示命令列表，结构同 `ul`。

## 表格

```html
<table>
  <caption>学生成绩</caption>
  <colgroup>
    <col />
    <col span="3" />
    <col />
  </colgroup>
  <thead>
    <tr>
      <th scope="col">姓名</th>
      <th scope="col">语文</th>
      <th scope="col">数学</th>
      <th scope="col">英语</th>
      <th scope="col">总分</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">张三</th>
      <td>85</td>
      <td>92</td>
      <td>78</td>
      <td>255</td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td colspan="4">平均分</td>
      <td>259.7</td>
    </tr>
  </tfoot>
</table>
```

- `caption` 是第一个子元素；`colgroup` 在 `caption` 后、`thead` 前。
- `th` 加 `scope="col"` / `scope="row"`。
- `colspan` 合并列，`rowspan` 合并行。
- `border` 属性废弃，边框用 CSS；表格只放数据。

## 链接

```html
<a href="https://example.org">外链</a>
<a href="https://example.org" target="_blank" rel="noopener">新标签页</a>
<a href="mailto:hi@example.com?subject=Hello">邮件</a>
<a href="tel:+8613800000000">电话</a>
<a href="#forms">页内锚点</a>
```

`target="_blank"` 配 `rel="noopener"`；链接文本写目标，不写「点击这里」。

## 图片

```html
<img src="beast.png" alt="描述" width="640" height="360" loading="lazy" decoding="async" />

<figure>
  <img src="beast.png" alt="描述" width="640" height="360" loading="lazy" />
  <figcaption>图注</figcaption>
</figure>

<picture>
  <source media="(min-width: 720px)" srcset="wide.webp" />
  <source media="(min-width: 480px)" srcset="mid.webp" />
  <img src="small.webp" alt="描述" width="640" height="360" loading="lazy" />
</picture>
```

- `alt` 必填；装饰图写 `alt=""`。`title` 只作补充提示。
- `width` / `height` 预留比例，防止布局抖动。
- `source` 自上而下匹配 `media` 与 `type`；最后的 `img` 兜底，承载 `alt` 与尺寸。

## 音频、视频与嵌入

```html
<audio controls preload="metadata">
  <source src="audio.ogg" type="audio/ogg" />
  <source src="audio.mp3" type="audio/mpeg" />
  浏览器不支持 audio。
</audio>

<video controls preload="metadata" width="640">
  <source src="video.mp4" type="video/mp4" />
  浏览器不支持 video。
</video>

<iframe
  src="https://example.org"
  title="嵌入内容说明"
  width="640"
  height="360"
  loading="lazy"
></iframe>
```

- `source` 按顺序选第一个支持的 `type`；`ogg` 免专利，`mp3` 兼容更广。
- 后备文本写在不支持时显示的位置。
- `iframe` 必须有描述性 `title`；`loading="lazy"` 延迟加载。
- `preload="metadata"` 只取时长，`auto` 会预加载全部。

图像映射：

```html
<img src="workplace.png" alt="桌面：电脑、咖啡、手机" usemap="#workmap" width="480" height="320" />
<map name="workmap">
  <area shape="rect" coords="20,40,250,280" alt="电脑" href="https://example.com/pc" />
  <area shape="circle" coords="350,110,60" alt="咖啡" href="https://example.com/coffee" />
</map>
```

`shape` 支持 `rect`、`circle`、`poly`；`coords` 是像素坐标；`area` 也要写 `alt`。

## 表单

### 基本结构

```html
<form action="/submit" method="post">
  <fieldset>
    <legend>账号</legend>
    <label for="username">用户名</label>
    <input
      type="text"
      id="username"
      name="username"
      autocomplete="username"
      required
    />
  </fieldset>
</form>
```

- `action` 提交地址，`method` 为 `get` / `post`。
- `label` 的 `for` 对应控件的 `id`；`name` 是提交时的键名。
- 演示页可用 JavaScript 的 `preventDefault()` 拦截提交。

### 输入类型

| `type`                        | 用途         | 关键属性                               |
| :---------------------------- | :----------- | :------------------------------------- |
| `text`                        | 单行文本     | `placeholder`、`required`、`minlength` |
| `email`                       | 邮箱         | 浏览器校验格式                         |
| `password`                    | 密码         | 输入掩码                               |
| `number`                      | 数字         | `min`、`max`、`step`                   |
| `radio`                       | 单选         | 同组同 `name`                          |
| `checkbox`                    | 多选         | 同组同 `name`                          |
| `file`                        | 文件         | `accept`                               |
| `color`                       | 颜色         | 值为十六进制                           |
| `range`                       | 滑块         | `min`、`max`、`value`                  |
| `date`                        | 日期         | —                                      |
| `datetime-local`              | 本地日期时间 | —                                      |
| `hidden`                      | 隐藏字段     | 随表单提交                             |
| `submit` / `reset` / `button` | 按钮         | `value` 是按钮文字                     |

`button` 默认 `type="submit"`，不提交时必须写 `type="button"`；`button` 内可以放元素，`input` 不能。

### 下拉、文本域与候选

```html
<label for="country">国家</label>
<select id="country" name="country">
  <option value="cn" selected>中国</option>
  <option value="us">美国</option>
</select>

<label for="bio">简介</label>
<textarea id="bio" name="bio" rows="4" cols="40"></textarea>

<label for="browser">浏览器</label>
<input list="browsers" id="browser" name="browser" />
<datalist id="browsers">
  <option value="Chrome"></option>
  <option value="Firefox"></option>
</datalist>
```

- `selected` 指定默认项。
- `textarea` 用 `rows` / `cols` 定尺寸。
- `datalist` 提供候选，但不限制输入。

### 计算与按钮

```html
<form id="calc">
  <input type="range" id="a" name="a" min="0" max="100" value="40" />
  <input type="number" id="b" name="b" min="0" max="100" value="60" />
  <output name="sum" for="a b">100</output>
</form>

<button type="submit">提交</button>
<button type="reset">重置</button>
<button type="button">普通按钮</button>
```

`output` 只负责显示，值由 JavaScript 用 `parseInt` 或 `Number` 写入；`for` 列出参与计算的控件 `id`。

## 语义结构

| 标签           | 用途                |
| :------------- | :------------------ |
| `<header>`     | 页眉或区块头部      |
| `<nav>`        | 导航链接            |
| `<main>`       | 页面主内容          |
| `<article>`    | 独立、完整的内容块  |
| `<section>`    | 文档中的节/区段     |
| `<aside>`      | 侧边栏或补充内容    |
| `<footer>`     | 页脚或区块底部      |
| `<figure>`     | 插图/图表等独立内容 |
| `<figcaption>` | `<figure>` 的图注   |

```html
<header>
  <h1>站点标题</h1>
  <nav aria-label="主导航">导航</nav>
</header>

<main>
  <article>
    <header>文章页眉</header>
    <p>正文</p>
    <aside>旁注</aside>
    <footer>文章页脚</footer>
  </article>
</main>

<footer>版权信息</footer>
```

- 每页一个 `main`。
- `aria-label` / `aria-labelledby` 给没有可见标题的区块命名。
- `article` 可嵌套：列表 → 单篇 → 评论。
- 无语义容器：`div` 块级，`span` 行内；优先用语义标签。
- `noscript` 在禁用 JavaScript 时显示提示。

### 标题组与折叠

```html
<hgroup>
  <h2>HTML 语义化</h2>
  <p>结构与含义一致</p>
</hgroup>

<details>
  <summary>展开</summary>
  <p>折叠内容。</p>
</details>
```

`hgroup` 在大纲中只保留最高级标题；`details` 加 `open` 默认展开。

### 对话框

```html
<dialog id="dialog" aria-labelledby="dialog-title">
  <h2 id="dialog-title">标题</h2>
  <p>内容。</p>
  <button type="button" data-close>关闭</button>
</dialog>
```

```js
const dialog = document.querySelector("#dialog");
dialog.showModal(); // 模态；show() 为非模态
dialog.close();
```

`open` 属性默认打开；`Esc` 关闭；`::backdrop` 改遮罩。

### 进度与模板

```html
<progress value="70" max="100">70%</progress>
<meter value="0.65" min="0" max="1" low="0.3" high="0.8" optimum="0.5">65%</meter>

<template id="card">
  <article><h3>标题</h3></article>
</template>
```

`progress` 表示任务进度；`meter` 表示已知范围的度量；`template` 不渲染、不执行脚本，`content.cloneNode(true)` 后插入。

## 全局属性与实体

| 属性       | 作用                                     |
| :--------- | :--------------------------------------- |
| `id`       | 唯一标识，锚点与 `label for` 使用        |
| `class`    | 可复用的类名                             |
| `style`    | 内联样式，少用                           |
| `title`    | 悬停提示                                 |
| `lang`     | 元素语言                                 |
| `dir`      | 文字方向，`ltr` / `rtl`                  |
| `hidden`   | 隐藏元素                                 |
| `tabindex` | Tab 顺序                                 |
| `data-*`   | 自定义数据，JavaScript 用 `dataset` 读取 |
| `aria-*`   | 无障碍名称与状态                         |

| 实体     | 显示     | 说明       |
| :------- | :------- | :--------- |
| `&lt;`   | `<`      | 小于号     |
| `&gt;`   | `>`      | 大于号     |
| `&amp;`  | `&`      | 和号       |
| `&quot;` | `"`      | 双引号     |
| `&copy;` | `©`      | 版权符号   |
| `&nbsp;` | （空格） | 不换行空格 |

完整列表见 [HTML 实体表](html-entities.md)。

[^1]: [MDN HTML 元素参考](https://developer.mozilla.org/zh-CN/docs/Web/HTML/Reference/Elements)
