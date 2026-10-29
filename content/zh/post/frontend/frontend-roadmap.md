---
title: （自用）前端入门实战路线：8 周从零到上线
slug: frontend-roadmap
date: 2026-07-10
description: 按周排期的前端自学路线：环境、Git、HTML/CSS 布局、JavaScript、DOM 与异步、Vite + React，12 个项目逐个给出验收标准、常见卡点与演示。
tags:
  - frontend
  - web
  - html
  - css
  - javascript
categories:
  - tutorial
draft: true
---

零基础学前端最常见的结局不是学不会，而是卡在环境、卡在布局、卡在一个没人回答的报错上，然后放弃。这份路线把 8 周拆成 12 个能验收的交付物：每周结束时，你手上都有一个能打开、能上线、能写进简历的页面。

已有完整教程的项目（计数器、猜数字、小球大战）不在本文重复代码，直接跟做对应文章，本文只给排期、验收标准和扩展题。

## 这份路线怎么用

### 适合谁

| 你的情况                   | 怎么用这份路线                                     |
| :------------------------- | :------------------------------------------------- |
| 完全没写过代码             | 从第 1 周按顺序做，不要跳                          |
| 会一点 HTML/CSS，没写过 JS | 第 1–4 周当复习，用验收清单查漏；重点从第 5 周开始 |
| 只想要一个个人网站         | 做完第 4 周即可，直接跳到「收尾」                  |
| 目标是前端实习或转行       | 全部做完，再补 TypeScript 与工程化（见「自测」L4） |

### 8 周排期

| 周   | 主线                     | 小时 | 交付物                |
| :--- | :----------------------- | ---: | :-------------------- |
| 1    | 环境、Git、HTML、调试    |   10 | 纯 HTML 简历          |
| 2    | CSS 基础与盒模型         |   10 | 简历样式版            |
| 3    | Flex、Grid、响应式       |   12 | 三页静态博客          |
| 4    | 样式工程、CSS 框架、部署 |   10 | 博客上线              |
| 5    | JavaScript 语法核心      |   13 | 计数器、猜数字        |
| 6    | DOM、事件、表单          |   12 | 待办 v1               |
| 7    | 持久化、异步、动画       |   14 | 待办 v2、番茄钟、天气 |
| 8    | Vite 与 React            |   14 | 鸡尾酒 SPA            |

每周 10–14 小时（平均每天 2 小时，休一天），全程约 95 小时。只能投入一半时间，就把 8 周拉成 16 周，**不要压缩验收**——验收是这份路线唯一防止「假学会」的机制。

### 五条硬规则

1. **一次只开一个任务**。第 1 周没验收完，不要去看第 3 周的 Flex。
2. **验收清单全打勾才往下走**。打不了勾说明还没会，留在原地，不是失败。
3. **每天至少一次提交**。哪怕只改了一行颜色，`git commit` 让进度可见、可回退。
4. **卡满 30 分钟就换方法**：读报错 → 查 MDN → 搜精确报错 → 问 AI。问法见「卡住的时候怎么办」。
5. **先跑通再优化**。第一版可以丑、可以重复，能运行就是胜利；重构放到下一周。

### 环境清单

| 工具           | 用途        | 检查                   | 备注                                 |
| :------------- | :---------- | :--------------------- | :----------------------------------- |
| VS Code        | 写代码      | `code -v`              | 插件见 1.1                           |
| Chrome/Firefox | 运行与调试  | 保持最新版             | DevTools 是本路线的主力工具          |
| Git            | 版本管理    | `git --version` ≥ 2.40 | 装完先配 `user.name` 与 `user.email` |
| Node.js        | 第 8 周才用 | `node -v` ≥ 22         | 只装 LTS，不要装 Current             |
| Live Server    | 本地预览    | VS Code 插件           | 默认端口 5500                        |
| Prettier       | 代码格式化  | VS Code 插件           | 设为保存时自动格式化                 |

Windows 上还有三条容易踩的：

- 项目路径不要含中文和空格，用 `D:\code\frontend-lab` 这种路径。
- 换行符统一 LF，否则改一行会显示整个文件被改，原因和设置见 [Git 换行符](../git/git-line-endings.md)。
- 终端用 Windows Terminal 加 PowerShell（或 Git Bash），不要用 cmd。

版本以写作时为准，装最新的稳定版即可；命令报「不支持某选项」时，先查该工具的官方文档确认版本要求。

### 仓库与目录

练习项目放同一个 `frontend-lab` 仓库，按周编号分目录；三个里程碑项目（博客、天气、SPA）单独建仓库，因为它们要部署、要写进简历。

```text
frontend-lab/
├── 01-resume-html/
│   └── index.html
├── 02-resume-css/
│   ├── index.html
│   ├── style.css
│   └── assets/avatar.webp
├── 03-blog/
│   ├── index.html
│   ├── post.html
│   ├── about.html
│   └── style.css
└── README.md
```

每个项目目录先只放一个 `index.html`，需要时再加 `style.css` 和 `main.js`。单文件超过 300 行再拆目录，不要一上来就设计架构。

### 关于演示代码

HTML/CSS/JS 的完整示例用 CodePen 嵌入，可以直接在页面里改着看效果。命令行（Git、npm）、目录结构和提问模板放不进 CodePen，仍以代码块给出。

## 第 1 周：环境、Git 与第一个页面

本周结束：一个只有 HTML 的简历页面在 GitHub 上，提交记录不少于 5 条。

### 1.1 装编辑器与四个插件

必装两个：**Live Server**（保存即刷新，省掉手动 F5）、**Prettier**（保存即格式化，避免缩进混乱）。可选两个：**Chinese (Simplified) Language Pack** 把界面变中文；**Error Lens** 把报错直接显示在行尾，省得开面板。

再改四项设置，在设置里搜名字即可：

| 设置                  | 值     | 为什么                   |
| :-------------------- | :----- | :----------------------- |
| `editor.formatOnSave` | `true` | 保存即格式化             |
| `editor.tabSize`      | `2`    | 前端生态的通用缩进       |
| `editor.wordWrap`     | `on`   | 长行不横向滚动           |
| `files.eol`           | `"\n"` | 统一 LF，避免整文件 diff |

`!` 加 Tab 展开 HTML 骨架依赖 Emmet 的 Tab 触发，配置方式见 [VS Code 中 Emmet 的 Tab 展开](../vscode/vscode-emmet-tab.md)。其余插件按需加，别一次装二十个——扩展配置与踩坑见 [VS Code 插件配置](../vscode/vscode-extensions-config.md)。

**验收**：新建一个 `.html` 文件，输入 `!` 按 Tab 能展开骨架；保存时缩进自动对齐。

### 1.2 写出第一个页面

新建 `01-resume-html/index.html`，展开骨架后改三处：`<title>` 改成「张三的简历」，`<h1>` 写名字，`<p>` 写一句话简介，再加一张 `<img>`。

骨架里有四行不能删，各自对应一个真实故障：

| 行                           | 作用         | 删掉的后果                         |
| :--------------------------- | :----------- | :--------------------------------- |
| `<!DOCTYPE html>`            | 声明标准模式 | 浏览器进入怪异模式，盒模型计算不同 |
| `lang="zh-CN"`               | 页面语言     | 读屏器按英文发音念中文             |
| `<meta charset="UTF-8">`     | 编码         | 中文变乱码                         |
| `<meta name="viewport" ...>` | 视口宽度     | 手机上整页被缩成一小块             |

<!-- CODEPEN D1 · 演示：最小页面与图片 -->

**验收**：浏览器标签页显示你写的标题；DevTools 切到 375px 宽度，文字大小不变；把图片路径改错，页面显示 `alt` 文字而不是空白。

### 1.3 本地服务器与实时刷新

右键 `index.html`，选 **Open with Live Server**，地址栏会出现 `http://127.0.0.1:5500/01-resume-html/`。之后每次 `Ctrl+S`，浏览器自动刷新。

不要双击文件打开。`file://` 下浏览器把每个文件当成独立来源，第 7 周调接口时会直接报 CORS；换成 `127.0.0.1` 才是正常的网页来源，相对路径的行为也才和线上一致。

**卡点**：端口 5500 被占用时 Live Server 会提示换端口，按提示点即可；地址栏仍是 `file://` 说明没点右下角的 **Go Live**。

**验收**：改 `<h1>` 保存，浏览器不刷新也自己变了，地址以 `127.0.0.1` 开头。

### 1.4 Git 与 GitHub

安装、配置身份、建仓库、配 SSH 这一整套步骤见 [Git 入门：从安装到第一次推送](../git/git-quickstart.md)；认证方式见 [GitHub SSH 认证配置](../git/git-github-ssh.md)。这里只规定第 1 周之后的日常动作：

```bash
git status          # 先看改了什么
git add .           # 全部加入暂存区
git commit -m "feat: add resume skeleton"
git push
```

提交信息用「动词 + 范围」：`feat: 简历增加技能列表`、`fix: 头像路径错误`、`style: 调整卡片间距`。不要写 `update`、`修改一下`。

`.gitignore` 从一开始就建好，写上 `node_modules/`、`dist/`、`.DS_Store`。

**验收**：`git log --oneline` 至少 3 条（本周结束累计 5 条以上）；GitHub 仓库页面能看到文件；本地再改一行并推送，网页端能看到新内容。

**卡点**：推送失败先看报错类型，[GitHub 推送失败排查](../git/github-push-failures.md) 覆盖了认证、代理、非快进三类；Windows 上出现整文件 diff 看 [Git 换行符](../git/git-line-endings.md)；误提交了不该提交的文件，用 [Git 撤销与修改提交历史](../git/git-undo-and-rewrite.md) 回滚，别删仓库重来。

### 1.5 HTML：先掌握这 10 组标签（2.5 小时）

不要背标签表，先能用这 10 组把内容组织清楚：

| 标签                                  | 作用       | 必须记住                                               |
| :------------------------------------ | :--------- | :----------------------------------------------------- |
| `h1`–`h6`                             | 标题层级   | 一页只有一个 `h1`，层级不跳级                          |
| `p`                                   | 段落       | 文字不要用 `<br>` 硬换行分段                           |
| `a`                                   | 链接       | `href`；新窗口加 `target="_blank"` 与 `rel="noopener"` |
| `img`                                 | 图片       | `src` 加 `alt`，`alt` 写内容，不写「图片」             |
| `ul` / `ol` / `li`                    | 列表       | 导航本质是列表，不是一堆 `a`                           |
| `div` / `span`                        | 无语义容器 | 能用语义标签就不用它们                                 |
| `header` / `nav` / `main` / `footer`  | 页面区块   | 一个页面只有一个 `main`                                |
| `form` / `input` / `button` / `label` | 表单       | `label` 的 `for` 等于 `input` 的 `id`                  |
| `table`                               | 表格       | 只放数据，不用来排版                                   |
| `section` / `article`                 | 内容分块   | 有标题才用 `section`                                   |

四条规则：

- **块级与行内**：`div`、`p`、`h1` 独占一行；`span`、`a`、`img` 与其他内容同行。
- **`class` 与 `id`**：`class` 可重复，用来写样式；`id` 全页唯一，用来做锚点和 `label` 关联。
- **语义化**：用 `header`、`nav`、`main` 代替一层层 `div`，换来的是读屏器可导航、搜索引擎能识别、半年后你自己看得懂。
- **可访问性三条**：图片有 `alt`、表单控件有 `label`、链接文字能独立看懂（不要写「点击这里」）。

标签和属性查不完时看 [HTML 语法与常见任务速查表](../web/html-cheat-sheet.md)；页面上要显示 `<`、`>`、`&` 这些字符，写法见 [HTML 实体](../web/html-entities.md)。

**练习**：做一个「我的收藏夹」页面，放 3 个链接，每个链接配一句为什么收藏它。

### 1.6 DevTools：会看比会写更重要（1 小时）

F12 打开，本周只练这六个面板：

| 面板           | 用来做什么                         |
| :------------- | :--------------------------------- |
| Elements       | 看 DOM 结构，临时改文字、删元素    |
| Styles         | 看哪条样式生效，被划掉的是输给了谁 |
| Computed       | 看最终计算值（宽高、字号、颜色）   |
| Console        | 看报错、直接跑一行 JS              |
| Network        | 看请求状态码、返回的 JSON          |
| Device Toolbar | 切 375px 等宽度，模拟手机          |

十分钟练习：打开任意网站，改标题颜色；删掉导航；在 Network 里找一个 404；切到 iPhone SE 宽度看布局怎么变。

记住一件事：**DevTools 里的修改都是临时的**，刷新就没了。它是手术台，不是病历本。

### 项目 A：纯 HTML 简历（2 小时）

用 1.5 节的标签把简历搭出来，不加任何样式。

- `header`：头像、姓名（`h1`）、一句话简介
- `main`：技能列表（至少 5 项）、教育经历、一段项目经历
- `footer`：两个以上社交链接，`target="_blank"` 配 `rel="noopener"`
- 图片放 `assets/`，用相对路径引用

**验收**：

- [ ] 全页只有一个 `h1`
- [ ] 每张图片都有描述性 `alt`
- [ ] 按 Tab 能依次走过所有链接，焦点看得见
- [ ] 用 [W3C Validator](https://validator.w3.org/) 检查，0 个 error
- [ ] 提交信息能看出这一步改了什么

<!-- CODEPEN A · 答案：纯 HTML 简历 -->

**扩展**：用 `<time>` 标日期；用 `<dl>` 写技能等级；加一段 `<blockquote>` 的个人评价。

## 第 2 周：CSS 基础（10 小时）

本周结束：简历有了完整样式，手机宽度下不横向滚动。

### 2.1 选择器、层叠与优先级（2 小时）

样式写在外部文件里，用 `<link rel="stylesheet" href="style.css">` 引入。行内 `style` 和内嵌 `<style>` 只用于临时试验。

| 选择器 | 写法        | 选中什么              |
| :----- | :---------- | :-------------------- |
| 标签   | `p`         | 所有 `p`              |
| 类     | `.card`     | `class="card"` 的元素 |
| ID     | `#logo`     | `id="logo"` 的元素    |
| 后代   | `.card a`   | 卡片里所有链接        |
| 子代   | `.card > a` | 卡片直接子级链接      |
| 伪类   | `a:hover`   | 鼠标悬停的链接        |

同一条属性被多处声明时，赢家由优先级决定：行内样式（1000）> `id`（100）> `class`（10）> 标签（1）；优先级相同则**后写的赢**。字体、颜色会从父元素继承，`margin`、`padding` 不会。

判断方法只有一个：在 Styles 面板里找被划掉的那条，鼠标移上去能看到它来自哪个文件、哪一行。

> 两条纪律：不用 `!important`；选择器嵌套不超过 3 层。这两样都是「当时能跑，三个月后没人敢改」的典型来源。

**验收**：随便改一条样式让它不生效，你能在 Styles 面板指出是哪条规则、因为什么覆盖了它。

### 2.2 盒模型（2 小时）

每个元素都是一个盒子，从里到外四层：内容（content）→ 内边距（padding）→ 边框（border）→ 外边距（margin）。

```text
margin
  border
    padding
      content
```

默认 `width` 只算 content，所以 `width: 300px; padding: 20px; border: 1px` 的元素实际占 342px。全局给 `*`、`*::before`、`*::after` 设上 `box-sizing: border-box`，宽高就包含 padding 和 border，这是现代 CSS 的默认做法。

<!-- CODEPEN D2 · 演示：box-sizing 两种模式对比 -->

两个真会遇到的坑：

- **margin 合并**：上下相邻的两个块，间距取两个 margin 的较大值，不是相加。别用 margin 调垂直间距，用 `gap`。
- **父子 margin 穿透**：子元素的 `margin-top` 会顶穿父元素。给父元素加 `padding-top` 或 `display: flow-root` 即可。

**验收**：`width: 300px; padding: 20px` 在两种 `box-sizing` 下分别占多宽？答 340px 和 300px 才算过关。

### 2.3 单位、字体与颜色（2 小时）

| 单位      | 相对谁                                   | 什么时候用                       |
| :-------- | :--------------------------------------- | :------------------------------- |
| `px`      | 无                                       | 边框、细线、图标尺寸             |
| `rem`     | 根字号（默认 16px）                      | 字号、间距——用户放大字体时跟着变 |
| `em`      | 元素自身字号（`font-size` 里相对父元素） | 组件内部的相对间距               |
| `%`       | 父元素                                   | 宽高、图片                       |
| `vw`/`vh` | 视口                                     | 整屏区块                         |
| `ch`      | 字符宽度                                 | 正文行宽                         |

排版四条经验：正文 `16–18px`；行高用无单位数字 `1.6` 左右；正文行宽限制在 `65ch` 内（一行 45–75 个字符最舒服）；标题用 `clamp()` 做流体字号，例如 `clamp(1.75rem, 4vw, 2.5rem)`，小屏不挤、大屏不散。

字体先用系统字体栈，加载零成本：`system-ui, -apple-system, "Segoe UI", "Microsoft YaHei", sans-serif`。要用 Google Fonts 时，`<link>` 各参数的含义和替换步骤见 [Google Fonts 引用方式](../web/how-to-use-googel-frots-in-css-dev.md)。

颜色用 `#rrggbb` 或 `hsl()` 都行，关键是对比度：正文与背景至少 4.5:1，大字号至少 3:1，DevTools 的颜色选择器会直接标出通过与否。

### 项目 B：给简历上样式（4 小时）

- 外部 CSS，居中容器，最大宽度 720px
- 卡片式区块：圆角、阴影、内边距
- 头像裁成圆形，宽高比不能变形
- 链接悬停时下划线滑入（`transition`）
- 字号、行高、颜色按 2.3 节的建议设置

**验收**：

- [ ] 375px 宽度下没有横向滚动条
- [ ] 行内样式为 0，样式全在 `style.css` 里
- [ ] 正文与背景的对比度 ≥ 4.5:1（DevTools 颜色面板显示通过）
- [ ] 用 Tab 键时链接和按钮有可见的焦点样式
- [ ] 头像圆形且不变形（`border-radius: 50%` 加 `object-fit: cover`）
- [ ] 浏览器字号放大到 200% 时文字不重叠、不溢出

<!-- CODEPEN B · 答案：简历样式版 -->

**卡点**：容器同时设了 `width: 100%` 和 `padding`，总宽超过屏幕，于是出现横向滚动条——这正是 2.2 节 `box-sizing` 要解决的问题。

## 第 3 周：Flex、Grid 与响应式（12 小时）

本周结束：一个三页的静态博客，电脑三列、平板两列、手机一列。

### 3.1 Flex：一维布局（3 小时）

给容器加 `display: flex`，子元素自动排成一行。容器管整体，项目管自己：

| 属性              | 加在   | 作用                                              |
| :---------------- | :----- | :------------------------------------------------ |
| `flex-direction`  | 容器   | 主轴方向：`row` 横排、`column` 竖排               |
| `justify-content` | 容器   | 主轴对齐：`flex-start`、`center`、`space-between` |
| `align-items`     | 容器   | 交叉轴对齐，常用 `center`                         |
| `flex-wrap`       | 容器   | 放不下时换行                                      |
| `gap`             | 容器   | 子元素间距，比 margin 干净                        |
| `flex`            | 子元素 | `1` 表示占满剩余空间                              |

三个够用的套路：导航栏 `justify-content: space-between` 加 `align-items: center`；水平垂直居中 `justify-content: center` 加 `align-items: center`（容器要有高度）；侧栏固定宽 `flex: 0 0 240px`、主区 `flex: 1`。

<!-- CODEPEN D3 · 演示：导航栏、居中、侧栏三种 Flex 布局 -->

一个必踩的坑：Flex 子元素里的长文本会撑破容器，因为它的最小宽度默认是内容宽度。给子元素加 `min-width: 0` 就能正常换行或省略。

### 3.2 Grid：二维布局（3 小时）

`display: grid` 先定义列，再往里放东西：

| 属性                    | 作用                              |
| :---------------------- | :-------------------------------- |
| `grid-template-columns` | 列宽，`repeat(3, 1fr)` 是三列等宽 |
| `gap`                   | 行列间距                          |
| `grid-column: span 2`   | 这个项目横跨两列                  |
| `grid-template-areas`   | 用名字画出页面骨架                |
| `place-items: center`   | 容器内所有项目水平垂直居中        |

一行解决「卡片列表自适应」：`grid-template-columns: repeat(auto-fit, minmax(240px, 1fr))`。容器够宽就自动多列，不够就掉成一行，不需要写媒体查询。

页面骨架用 `grid-template-areas` 最直观：三行两列的「头部 / 侧栏 + 正文 / 页脚」，改布局只改一行字符串。

<!-- CODEPEN D4 · 演示：卡片自适应网格 + 页面骨架 -->

**什么时候用哪个**：只管一行或一列用 Flex；要同时管行和列、或要卡片自动换列用 Grid。两者可以嵌套，不要互相替代。

### 3.3 响应式与移动优先（2 小时）

`<meta name="viewport">` 已经有了，剩下的是断点。移动优先的意思是：**默认样式写给手机**，再用 `min-width` 往上加。

| 断点     | 典型布局           |
| :------- | :----------------- |
| 默认     | 单列，导航竖排     |
| `640px`  | 两列卡片           |
| `768px`  | 导航横排，两栏正文 |
| `1024px` | 三列卡片           |

断点按内容决定，不要照抄设备尺寸——布局开始难看的地方就是断点。

图片默认会撑破容器，全局加 `img { max-width: 100%; height: auto; }`。导航在手机上先允许换行（`flex-wrap: wrap`），折叠菜单留到第 6 周学了 JS 再做。

<!-- CODEPEN D5 · 演示：同一份 HTML 的三档布局 -->

**验收**：在 375、768、1440 三个宽度下都没有横向滚动条；缩放浏览器到 200% 时文字不重叠。

### 项目 C：三页静态博客（4 小时）

三个页面：`index.html` 文章列表、`post.html` 文章详情、`about.html` 关于我。文章用占位内容，重点是布局和跳转。

- 导航用 Flex 做「Logo 在左、三个菜单在右」，当前页加 `aria-current="page"`
- 文章列表用 Grid 的 `auto-fit` 写法，不写死列数
- 三页共用一份 `style.css`
- 每页结构用 `header` / `nav` / `main` / `footer`

**验收**：

- [ ] 三个页面互相可达，导航能看出当前在哪一页
- [ ] 375、768、1440 三档布局都成立，没有横向滚动
- [ ] 卡片列数由 `auto-fit` 决定，改窗口宽度自动变化
- [ ] 所有图片有 `alt`，加上了 `max-width: 100%`
- [ ] 全站没有 `!important`
- [ ] 提交记录能看出「搭骨架 → 加样式 → 调响应式」三个阶段

<!-- CODEPEN C · 答案：三页静态博客 -->

**扩展**：给文章页加一个「目录」侧栏（Grid 两栏）；给卡片加悬停上浮效果（`transform` 加 `transition`）。

## 第 4 周：样式工程、CSS 框架与上线（10 小时）

本周结束：博客换一套框架重写，有一个别人能打开的网址。

### 4.1 把 CSS 组织起来（2 小时）

三件事，做完你的 CSS 才不会失控：

- **变量**：颜色、间距、圆角、字号全放 `:root`，换主题只改一处。
- **命名**：小写加连字符，按组件起名（`.site-header`、`.post-card`），不按外观起名（`.red`、`.left`）。
- **顺序**：重置 → 变量 → 基础元素 → 布局 → 组件 → 工具类。新样式往对应段落里加，不要追加到文件末尾。

单文件超过 300 行就拆成 `base.css`、`layout.css`、`components.css`，在 HTML 里按顺序引入。

### 4.2 选一个 CSS 框架（3 小时）

| 框架           | 给你什么                         | 适合                         |
| :------------- | :------------------------------- | :--------------------------- |
| Bootstrap 5    | 现成组件：导航、卡片、按钮、表单 | 想最快看到成品，接受默认外观 |
| Tailwind CSS 4 | 原子类，样式直接写在 HTML 里     | 想精确控制设计，愿意记类名   |

选一个，只学一个。初学者先 Bootstrap：组件复制过来就能用，正反馈快。Tailwind 的优点是不用起类名、改样式不用来回跳文件，代价是 HTML 变长。

迁移分三步，不要一次重写：先用框架的容器和栅格搭骨架 → 再把导航、卡片、按钮换成框架组件 → 最后删掉不再使用的旧 CSS。覆盖框架样式时改它的 CSS 变量（Bootstrap 的 `--bs-*`），不要用 `!important` 硬压。

### 4.3 部署上线（2 小时）

三条路，选一条即可：

| 平台         | 适合             | 关键点                                 |
| :----------- | :--------------- | :------------------------------------- |
| GitHub Pages | 纯静态，零配置   | 仓库 Settings → Pages → 选分支和根目录 |
| Vercel       | 前端项目，含 SPA | 导入仓库，框架选 Other，输出目录填 `.` |
| Netlify      | 同上，拖拽即可   | 直接把文件夹拖进后台                   |

GitHub Pages 的项目页地址是 `https://用户名.github.io/仓库名/`，**多了一层子路径**。所以样式和图片全用相对路径（`./style.css`），写成 `/style.css` 线上一定 404。这个机制在 [纯静态博客是怎么工作的](../hugo/how-static-blog-works.md) 里讲过。

部署完做三件事：用手机流量打开一次（不是同一个 Wi-Fi，排除「只有我能访问」）；F12 看 Network 有没有 404；把链接发给一个真人让他打开。

### 项目 D：框架版博客上线（3 小时）

用第 3 周的三个页面，换成框架重写首页和文章页，然后部署。

**验收**：

- [ ] 线上地址能直接打开，不是 `localhost`
- [ ] 手机宽度下导航可用、不横向滚动
- [ ] CSS 行数比第 3 周少 30% 以上（把两个数字记在 README 里）
- [ ] 没有为了覆盖框架样式而使用 `!important`
- [ ] README 第一行就是线上地址

**扩展**：绑一个自定义域名；加一个 404 页面。

## 第 5 周：JavaScript 语法核心（13 小时）

本周结束：两个能玩的小游戏，代码里没有一行内联 `onclick`。

### 5.1 代码怎么跑起来（1 小时）

`<script src="main.js" defer></script>` 放在 `<head>` 里，`defer` 保证 DOM 解析完再执行。直接写在 `<body>` 末尾也可以，但别两样都不做——脚本在元素之前执行，`querySelector` 拿到 `null`，后面就报错。

控制台是主战场：`console.log` 看值，`console.table` 看数组和对象，`console.dir` 看对象结构。报错只看三行就够定位：错误类型、错误消息、`文件:行号`。

```text
Uncaught TypeError: Cannot read properties of null (reading 'addEventListener')
    at main.js:12
```

这句的意思只有一个：第 12 行的选择器没选中元素。先在上一行打印 `document.querySelector("#btn")`，看是不是 `null`，再检查 id 拼写和脚本执行时机。

断点调试：Sources 面板点行号打红点，刷新页面，代码会停在那里，F10 单步、F11 进入函数、鼠标悬停看变量。比十行 `console.log` 快。

### 5.2 值与类型（2 小时）

`const` 优先，需要重新赋值时才用 `let`，`var` 不用。原始类型七个：`string`、`number`、`boolean`、`null`、`undefined`、`symbol`、`bigint`；其余都是对象。

模板字符串用反引号：`你好，${name}`。比较一律用 `===`，`==` 会做隐式转换。六个假值记牢：`false`、`0`、`""`、`null`、`undefined`、`NaN`，其余都为真。

`typeof` 和类型转换的完整规则、`typeof null === "object"` 这类坑，见 [JS 类型检测与类型转换](../javascript/js-type-conversion.md)，不在这里重复。

**验收**：能口算 `1 + "2"`（`"12"`）、`"3" * "2"`（`6`）、`[] + []`（`""`）的结果并说出原因。

### 5.3 控制流（1.5 小时）

`if / else if / else` 处理分支，简单的二选一用三元运算符。循环先学 `for` 和 `for...of`，遍历数组用 `forEach`。

两个习惯从第一天就养成：**提前 return** 把嵌套的 `if` 拉平；循环里需要索引和跳出时用 `for`，只是遍历就用 `forEach`。

**练习**：打印 1 到 100，3 的倍数输出 `Fizz`，5 的倍数输出 `Buzz`，15 的倍数输出 `FizzBuzz`。写不出来说明条件顺序还没想清楚。

### 5.4 函数（2 小时）

函数把逻辑封起来：参数进、`return` 出。写法有三种：`function add(a, b) { ... }` 是声明，`const add = function (a, b) { ... }` 是表达式，`const add = (a, b) => a + b` 是箭头函数。声明适合顶层函数，箭头函数适合回调和短逻辑。

默认参数 `function greet(name = "访客")` 处理缺省值。写函数时追求「纯」：同样输入给同样输出，不改外部变量，这样的函数最好测也最好复用。

箭头函数的 `this`、默认参数、剩余参数和 `return` 换行的 ASI 坑，见 [函数、this 与参数](../javascript/js-function-and-this.md)。

**练习**：`formatPrice(1230)` 返回 `"¥12.30"`；`clamp(n, min, max)` 把数字限制在区间内。

### 5.5 数组与对象（2.5 小时）

数组管顺序，对象管属性，两者组合就是前端最常见的数据形状：`[{ id, name, price }]`。

| 操作   | 方法                                             |
| :----- | :----------------------------------------------- |
| 增删   | `push`、`pop`、`shift`、`unshift`、`splice`      |
| 取子集 | `slice`、`filter`                                |
| 变换   | `map`、`reduce`                                  |
| 查找   | `find`、`findIndex`、`includes`、`some`、`every` |
| 排序   | `sort`（会改原数组，比较函数返回数字）           |

对象三件套：解构 `const { name } = product`、展开 `{...product, price: 9}`、可选链 `user?.address?.city`。`JSON.stringify` 与 `JSON.parse` 是对象和字符串之间最常用的转换方式，第 7 周存 localStorage 就靠它。

**练习**：给一组商品，筛出 50 元以上的，把名称和价格拼成 `<li>` 字符串，`join("")` 后一次性插入页面。

### 5.6 作用域与严格模式（1 小时）

`let` 和 `const` 是块级作用域，`var` 是函数级——这就是为什么循环里用 `var` 声明索引，回调拿到的永远是最后一个值。

严格模式让「静默失败」变成报错，比如给未声明的变量赋值。现代项目用模块或打包工具时默认开启，写普通 `<script>` 时值得显式加一行。机制与作用域链的查找规则见 [JavaScript 严格模式与作用域链](../javascript/use-strict.md)。

### 项目 E：计数器（1.5 小时）

跟做 [从零实现计数器](../javascript/counter.md)，它分四次迭代，最后有一轮自测题。

**验收**：

- [ ] `+`、`−`、`Reset` 三个功能都正常
- [ ] 负数变红，正数变绿，0 是黑色
- [ ] 控制台没有任何报错
- [ ] 事件用 `addEventListener` 绑定，HTML 里没有 `onclick`

**改造**：加上键盘支持（`+` / `-` / `0` 三个键）；把颜色值提取到 CSS 变量。

### 项目 F：猜数字（1.5 小时）

跟做 [从零实现猜数字游戏](../javascript/guess-game-tutorial.md)。

**验收**：

- [ ] 随机数范围 1–100，每局重新生成
- [ ] 提示「大了 / 小了 / 猜对了」
- [ ] 显示已猜次数，猜对后出现「再来一局」
- [ ] 输入空值、非数字、超出范围时有提示，不崩溃

**改造**：记录历史猜测并列表展示；限制 10 次机会。

## 第 6 周：DOM、事件与表单（12 小时）

本周结束：一个能增删改查的待办清单，输入恶意字符串也不会弹窗。

### 6.1 查询与修改 DOM（2.5 小时）

| 操作    | 写法                                                        |
| :------ | :---------------------------------------------------------- |
| 查一个  | `document.querySelector(".card")`                           |
| 查全部  | `document.querySelectorAll("li")`，得到类数组，用 `forEach` |
| 改文字  | `el.textContent = "新标题"`                                 |
| 改 HTML | `el.innerHTML = "<span>...</span>"`                         |
| 改类名  | `el.classList.add / remove / toggle / contains`             |
| 改属性  | `el.dataset.id`、`el.setAttribute("aria-expanded", "true")` |
| 建节点  | `document.createElement("li")` 加 `append`                  |

两条底线：

- **用户输入永远用 `textContent` 渲染**。用 `innerHTML` 拼接用户输入就是 XSS：任务文本里写 `<img src=x onerror=alert(1)>`，页面一刷新就弹窗。
- **静态样式写在 CSS 里**，`el.style` 只用于运行时才算得出的值（比如进度条宽度）。

### 6.2 事件与委托（3 小时）

`addEventListener("click", handler)` 是唯一推荐写法，它允许同一元素绑多个监听，也方便移除（移除时传入同一个函数引用）。

事件对象里两个属性最容易混：`e.target` 是真正被点的元素（可能是里面的 `<span>`），`e.currentTarget` 是绑监听的那个元素。事件会从目标往上冒泡，这就是**事件委托**的基础：在列表容器上绑一个监听，用 `e.target.closest("li")` 找到被点的行。列表增删一百次也不用重新绑事件。

<!-- CODEPEN D6 · 演示：事件委托做列表删除 -->

常用事件：`click`、`input`（每次输入触发）、`change`（失焦或选项变化）、`submit`（表单提交）、`keydown`（按键）。`e.preventDefault()` 阻止默认行为，表单提交和链接跳转都要用。

### 6.3 表单与校验（2 小时）

HTML 先做一层免费校验：`required`、`type="email"`、`type="number"`、`minlength`、`pattern`。`label` 的 `for` 必须等于控件的 `id`，点文字也能聚焦。

JS 层做三件事：监听 `submit` 并 `preventDefault`；用 `form.checkValidity()` 或逐项判断做业务校验；提交时禁用按钮，防止双击提交两次。取值用 `new FormData(form)` 配合 `Object.fromEntries`，比一个个 `querySelector` 稳。

### 项目 G：待办 v1（4.5 小时）

数据结构先定下来：`[{ id, text, done }]`。所有操作只改数组，改完调用 `render()` 整体重绘——这是「数据驱动 UI」，第 8 周的 React 只是把它做成了内置机制。

功能清单：输入框加「添加」按钮（回车也能加）、勾选完成（加删除线）、删除单条、底部显示剩余数量、列表为空时显示空状态。

**验收**：

- [ ] 空输入和纯空格不会添加
- [ ] 回车与按钮都能添加，不会重复添加
- [ ] 输入 `<img src=x onerror=alert(1)>` 作为任务文本不弹窗
- [ ] 删除后剩余数量同步更新
- [ ] 事件委托实现，新增任务不需要重新绑事件
- [ ] 刷新后清空（v1 就该清空，持久化是下周的事）

<!-- CODEPEN G · 答案：待办 v1 -->

**扩展**：双击任务文字进入编辑；加「全部完成 / 清除已完成」。

## 第 7 周：持久化、异步与动画（14 小时）

本周结束：待办刷新不丢、番茄钟切标签页回来仍然准、天气应用能处理三种状态。

### 7.1 localStorage（2 小时）

只能存字符串，对象先 `JSON.stringify`，读出来再 `JSON.parse`。key 加前缀和版本（`todo.v1`），读的时候给兜底值：`JSON.parse(localStorage.getItem("todo.v1") ?? "[]")`。

包一层 `try/catch`，解析失败时退回空数组——用户手动改过存储、旧版本数据结构变过，都会让 `JSON.parse` 抛错，不处理就是白屏。

三条边界：容量约 5MB；同源共享，换端口就是另一份数据（5500 和 5173 不互通）；绝不存密码和 token。

### 7.2 定时器与时间（2 小时）

`setInterval` 和 `setTimeout` 返回 id，`clearInterval` / `clearTimeout` 取消。倒计时不要用 `count--` 每秒减一：定时器本身有误差，后台标签页还会被浏览器节流到 1 秒一次，跑十分钟就偏了几十秒。

正确做法是记结束时间戳：开始时算一次 `endAt = Date.now() + 25 * 60 * 1000`，之后每次 tick 用 `Math.max(0, endAt - Date.now())` 算剩余。

这样切到别的标签页五分钟再回来，剩余时间依然正确。显示时用 `String(min).padStart(2, "0")` 补零。

**验收**：暂停再继续不重置；切标签页 5 分钟回来，剩余时间与真实时间一致。

### 7.3 fetch 与三种状态（3 小时）

请求分三步：`const res = await fetch(url)` 拿到响应，检查 `res.ok`，再 `await res.json()` 解析。`res.ok` 为 `false` 时直接抛错，比等到 `res.json()` 炸掉好定位。

**`fetch` 对 404 和 500 不会 reject**，它只在网络层失败时抛错。不检查 `res.ok`，接口返回错误页时你会拿着一段 HTML 去 `res.json()`，报一个和真实原因无关的解析错误。状态码怎么排查见 [HTTP 4xx 状态码排查指南](../web/http-4xx-error.md)。

页面必须处理三种状态：加载中（骨架或文字）、成功（渲染数据）、失败（错误信息加重试按钮）。再加两种边界：空结果、以及快速输入导致的**竞态**——先发的请求后返回会覆盖新结果，用 `AbortController` 取消上一个请求。

<!-- CODEPEN D7 · 演示：fetch 的加载 / 成功 / 失败三态 -->

安全提醒：前端代码里的 API key 一定看得见。只用免费额度受限的 key，把配额用完当作熔断，别指望「藏起来」。

### 项目 H：待办 v2（2 小时）

在 v1 上改造：每次增删改后写入 localStorage，页面加载时读回；加「清空全部」；把 HTML/CSS/JS 拆成独立文件。

**验收**：

- [ ] 刷新、关标签页再打开，数据都在
- [ ] 清空后刷新还是空的
- [ ] 存储里的 JSON 结构能看懂，字段名和代码一致
- [ ] 手动把 storage 里的值改成 `{`，页面不白屏

<!-- CODEPEN H · 答案：待办 v2 -->

### 项目 I：番茄钟（2 小时）

25 分钟倒计时，开始 / 暂停 / 重置，归零后提示休息。用 7.2 的时间戳方案，不要用递减计数。

**验收**：

- [ ] 暂停后剩余时间不变，继续时从暂停处接着走
- [ ] 归零后按钮状态正确，不能重复开始
- [ ] 切到别的标签页 5 分钟回来，剩余时间正确

<!-- CODEPEN I · 答案：番茄钟 -->

**扩展**：标签页标题显示剩余时间；结束时播一声提示音。

### 项目 J：天气应用（3 小时）

注册 [OpenWeatherMap](https://openweathermap.org/) 拿免费 key，请求 `https://api.openweathermap.org/data/2.5/weather?q=北京&appid=KEY&units=metric&lang=zh_cn`，显示温度、天气描述、图标。

**验收**：

- [ ] 空输入不发请求
- [ ] 请求中显示加载状态
- [ ] 城市不存在时提示「没找到这个城市」，不是白屏或 `undefined`
- [ ] 断网时有错误提示和重试
- [ ] key 放在单独的配置里，`.gitignore` 排除，README 说明怎么配

<!-- CODEPEN J · 答案：天气应用 -->

新注册的 key 可能不会立刻生效，等几分钟再试；`q=` 里的中文由浏览器自动编码，不用手动转。

### 项目 K：小球大战（选做，4 小时）

跟做 [Ball Battle：像素风小球对战](../javascript/ball-battle.md)，它从画一个矩形讲到碰撞、粒子、ES Module 重构。这条线是通往 canvas 和游戏开发的入口。

**验收**：用 `requestAnimationFrame` 而不是 `setInterval`；用两帧时间差 `dt` 做位移，换台 120Hz 的屏幕速度不变；边界反弹正确；点击能加球。

## 第 8 周：Vite 与 React（14 小时）

本周结束：一个带搜索、列表、详情、路由的 SPA，部署在线上。

### 8.1 Node、npm 与 Vite（2 小时）

Node 与包管理器的安装、镜像、常用命令见 [npm、pnpm 与 Node.js 入门指南](../web/npm-pnpm-nodejs-guide.md)。这里只跑脚手架：

```bash
npm create vite@latest cocktail-explorer -- --template react
cd cocktail-explorer
npm install
npm run dev
```

打开 `http://localhost:5173` 看到默认页面就成功。三个命令要分清：`npm run dev` 本地开发（热更新）、`npm run build` 产出 `dist/`、`npm run preview` 本地预览构建结果。`node_modules` 永远不进 git，`dist` 也不进。

### 8.2 组件、props 与状态（3 小时）

页面拆成组件，组件是返回 JSX 的函数，名字大写。props 是只读输入，父传子；state 是组件自己的记忆，用 `useState` 声明。

本路线用 React 举例；选 Vue 也一样走得通，对应概念是单文件组件、`ref`、`onMounted` 和 Vue Router，前面的 HTML/CSS/JS 部分完全不变。

三条必须改掉的旧习惯：

- **不直接操作 DOM**。要改界面就改状态，React 负责重绘。
- **不直接改数组和对象**。用 `setItems([...items, newItem])`，原地 `push` 不会触发渲染。
- **列表的 `key` 用稳定 id**，不要用数组下标——删除中间一项时，下标会让 React 认错元素。

事件写成 `onClick={() => setCount(count + 1)}`，不要 `onClick={setCount(count + 1)}`（那会在渲染时立刻执行）。

<!-- CODEPEN D8 · 演示：React 的状态、列表与条件渲染 -->

### 8.3 副作用与数据请求（3 小时）

渲染函数必须是纯的，请求、定时器、订阅这些副作用放 `useEffect`。依赖数组决定何时重跑：`[]` 只跑一次，`[query]` 是 `query` 变了才跑，不写数组是每次渲染都跑。

返回的函数是清理函数，用来取消请求、清定时器——不清理就会在组件卸载后继续 `setState`，控制台一片警告。开发环境下 `StrictMode` 会让副作用执行两次，这是故意的压力测试；正确的做法是写好清理函数，而不是用标志位绕过。

### 8.4 路由（2 小时）

`npm install react-router-dom` 后，用 `BrowserRouter`、`Routes`、`Route` 配两条路由：`/` 搜索页、`/cocktail/:id` 详情页。跳转用 `Link`，不要用 `<a>`——后者会整页刷新，SPA 就白搭了。详情页用 `useParams()` 拿 id，再发请求。加一条 `*` 路由做 404。

部署时记得配 SPA 回退：Vercel 加一条 rewrite 把所有路径指回 `/index.html`，Netlify 在根目录放 `_redirects`。不配的话，直接访问详情页会 404，因为服务器上根本没有那个路径的文件。

### 项目 L：鸡尾酒 SPA（4 小时）

用 [TheCocktailDB](https://www.thecocktaildb.com/api.php)（免费、无需 key）：搜索 `search.php?s=名称`，查详情 `lookup.php?i=id`。

- 搜索页：输入框加按钮，回车也能搜，空输入不发请求
- 列表页：图片加名称，网格布局，点击进详情
- 详情页：图片、配料表（过滤掉空的配料字段）、制作步骤
- 状态齐全：加载中、成功、无结果、出错、图片加载失败

**验收**：

- [ ] 搜索、列表、详情、返回都能走通
- [ ] 直接访问 `/cocktail/11007` 并刷新不 404（回退配好了）
- [ ] 无结果显示「没找到」，不是空白页
- [ ] 请求失败有重试按钮
- [ ] 列表 `key` 用 `idDrink`
- [ ] 线上地址可访问，写进 README

<!-- CODEPEN L · 答案：鸡尾酒 SPA -->

**扩展**：按原料筛选；把搜索词写进 URL（`?q=margarita`），刷新后保留。

## 收尾：作品集与简历（4 小时）

做完第 8 周，你手上有简历、上线的博客、待办、番茄钟、天气、SPA 六个项目，外加计数器、猜数字、小球大战三个跟做的小游戏。把它们变成作品集只要三步。

**一、一个作品集页**。挑 6 个项目，每个给四样东西：截图、一句话说明、技术栈、线上链接加源码链接。放在 Vercel 上，地址写进简历。

**二、每个仓库写 README**。六段：项目是什么、截图、技术栈、本地怎么跑、线上地址、遇到的问题和解决方式。最后一段在面试里最值钱，它证明你真的做过而不是抄过。

**三、简历上写结果，不写过程**。把「用 React 做了个鸡尾酒应用」改成「用 React 加 React Router 做的鸡尾酒查询应用，搜索响应在 300ms 内，已部署上线，源码 12 个组件」。有数字、有链接、有可验证的东西。

## 自测：你在第几级

### L1 静态页面（第 1–4 周）

- 不看教程，从空文件写出三页站点并部署上线
- 能解释盒模型、优先级、`box-sizing` 三件事
- Flex 和 Grid 各能默写出一个常用布局
- 手机宽度下不横向滚动，图片不变形

### L2 原生交互（第 5–7 周）

- 用原生 JS 完成增删改查加持久化
- 能读 Console 报错并定位到具体行
- 会用 `fetch` 处理加载、成功、失败、空结果
- 知道为什么用户输入不能用 `innerHTML`

### L3 框架（第 8 周）

- 能把页面拆成组件，用 props 和 state 组织数据流
- 能说清为什么不用直接操作 DOM
- 会配路由，并知道部署 SPA 为什么要回退
- 能独立部署一个带路由的项目

### L4 下一站

- **TypeScript**：给现有项目加类型，从 props 和 API 返回值开始
- **测试**：Vitest 写单元测试，Playwright 写一条端到端
- **工程化**：ESLint、Prettier 配置、Git Hooks、CI
- **框架深入**：状态管理、服务端渲染（Next.js / Nuxt）、性能优化
- **后端**：Node 加数据库，或直接上 [Express 脚手架](../web/npx-express-generator-guide.md) 摸一遍接口

## 卡住的时候怎么办

### 报错只看三行

最后一行是错误类型和消息，倒数第二行是文件和行号，点开那一行看用了哪个变量。先打印那个变量，确认它是 `null`、`undefined` 还是拼错的选择器。大多数「诡异 bug」都是「以为拿到了元素，其实没有」。

### 30 分钟法则

| 时间       | 做什么                                     |
| :--------- | :----------------------------------------- |
| 0–10 分钟  | 读报错，在关键位置打印中间值               |
| 10–20 分钟 | 查 MDN 对应条目，搜带引号的精确报错        |
| 20–30 分钟 | 新建一个 CodePen，只留能复现问题的最少代码 |
| 30 分钟后  | 问 AI，按下面的模板给信息                  |

```text
目标：我想让搜索框回车时触发查询
代码：<相关的最少代码>
报错：<完整报错，含文件行号>
已试过：<改了什么、结果如何>
期望：<现在的行为 vs 期望的行为>
```

这五行的信息量，比「我的代码不工作，帮我看看」具体得多。AI 工具怎么选、怎么省 token 见 [程序员 AI 使用指南](../ai/ai-usage-guide-for-programmers.md)。

### 六个放弃点

| 卡点               | 对策                                                      |
| :----------------- | :-------------------------------------------------------- |
| 环境装不上         | 先用 CodePen 写代码，环境放在周末单独解决，别让它拦住学习 |
| CSS 写不出设计稿   | 临摹现成页面，先复制再改；审美靠量堆出来                  |
| 教程看懂了但写不出 | 关掉教程，从空白文件重写一遍，写不出来再回去看            |
| 项目做到一半卡住   | 砍功能到最小可用版，先让它跑起来                          |
| 学了两周没反馈     | 每周日把成果截图发出去，公开进度是最便宜的正反馈          |
| 收藏了几十篇教程   | 只跟这一份路线，其它收藏夹当不存在                        |

## 资源

### 文档

- [MDN Web 文档](https://developer.mozilla.org/zh-CN/)：HTML/CSS/JS 的权威参考，查 API 首选
- [JavaScript.info](https://zh.javascript.info/)：从语言机制讲到浏览器，例子扎实
- [web.dev Learn](https://web.dev/learn)：CSS、性能、可访问性的系统课程
- [CSS-Tricks Flexbox 指南](https://css-tricks.com/snippets/css/a-guide-to-flexbox/) 与 [Grid 指南](https://css-tricks.com/snippets/css/complete-guide-grid/)：两张图讲清所有属性
- [roadmap.sh 前端路线](https://roadmap.sh/frontend)：用来查漏，不是用来一次学完
- [Can I use](https://caniuse.com/)：确认某个 CSS/JS 特性能不能用

### 工具

- [CodePen](https://codepen.io/)：写小 demo、复现问题
- [W3C Validator](https://validator.w3.org/)：检查 HTML 结构错误
- [Lighthouse](https://developer.chrome.com/docs/lighthouse/overview)：DevTools 内置，跑性能与可访问性
- [Vercel](https://vercel.com/)、[Netlify](https://www.netlify.com/)：静态站点与 SPA 部署

### 练手 API

- [TheCocktailDB](https://www.thecocktaildb.com/api.php)：鸡尾酒数据，无需 key，适合第一个真实请求
- [OpenWeatherMap](https://openweathermap.org/)：天气，免费 key，适合练错误处理
- [JSONPlaceholder](https://jsonplaceholder.typicode.com/)：假数据接口，适合练列表与详情

## 结语

先做完第 1 周那个纯 HTML 简历并提交，比选哪条路线重要；做完第 8 周，你会有六个能拿出手的项目和一个能讲清楚的技术栈。中间任何一周卡住，回到那一周的验收清单，把没打勾的项补上再往前走。
