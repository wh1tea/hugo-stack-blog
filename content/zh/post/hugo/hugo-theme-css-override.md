---
title: Hugo 主题 CSS 覆盖与选择器优先级
slug: hugo-theme-css-override
date: 2026-10-22T14:30:00+08:00
description: custom.scss 写了规则却不生效，多半是选择器具体性不够。以缩小 Stack 主题侧边栏 emoji 为例，给出定位规则、覆盖 CSS 变量、验证产物的完整流程
tags:
  - hugo
  - css
  - theme
  - troubleshooting
categories:
  - hugo
---

`params.toml` 里填一个 emoji，Stack 主题就把它渲染成头像角上的圆形徽标；嫌太大，往 `custom.scss` 写了一条规则却毫无反应。原因不是文件没加载，而是选择器具体性比主题低——排在文件最后也压不过。下面用这次真实排查，给出定位「某个 CSS 细节该改哪里」的流程。

## 症状：自定义样式动不了这个徽标

`config/_default/params.toml` 的 `[sidebar] emoji = "🥰"`，主题把它渲染成头像右下角的一个圆形徽标：直径 40px、字形 20px，压在本就 100px 的头像上相当显眼。

习惯性往 `assets/scss/custom.scss` 加一条：

```scss
.site-avatar .emoji {
  font-size: 2rem;
}
```

重新构建，视觉上没有任何变化。

## 先分清：样式没加载，还是被覆盖了

改 CSS 不生效只有两种可能，先用构建产物区分。主题的样式表经过 `resources.Fingerprint "sha256"`，文件名带哈希，直接搜产物里的规则：

```powershell
Select-String -Path public\scss\*.css -Pattern 'emoji'
```

两条规则都在：

```text
.sidebar header .site-avatar .emoji{…;font-size:var(--emoji-font-size);…}
.site-avatar .emoji{font-size:2rem}
```

自定义规则进了产物，说明文件加载正常、`@import` 也没写错——问题出在层叠上。

## 主题源码在哪

Hugo 主题是 Go module，源码不在项目里，而在模块缓存：

```text
%LOCALAPPDATA%\hugo_cache\modules\filecache\modules\pkg\mod\github.com\!cai!jimmy\hugo-theme-stack\v4@v4.0.3\
```

直接按 class 名搜，比一层层翻目录快：

```powershell
$t = "$env:LOCALAPPDATA\hugo_cache\modules\filecache\modules\pkg\mod\github.com\!cai!jimmy\hugo-theme-stack\v4@v4.0.3"
Select-String -Path "$t\assets\scss\*.scss", "$t\assets\scss\partials\*.scss" -Pattern 'emoji'
```

搜到两处关键代码。模板 `layouts/_partials/sidebar/left.html` 把 emoji 包进头像的 `figure`：

```html
<figure class="site-avatar">
    …
    <span class="emoji">🥰</span>
</figure>
```

样式 `assets/scss/partials/sidebar.scss` 则在侧边栏上定义两个 CSS 变量，再由徽标规则消费：

```scss
.left-sidebar {
    --emoji-size: 40px;
    --emoji-font-size: 20px;
}

.sidebar header {
    .site-avatar {
        .emoji {
            width: var(--emoji-size);
            height: var(--emoji-size);
            line-height: var(--emoji-size);
            font-size: var(--emoji-font-size);
        }
    }
}
```

## 输在具体性，也输在值

`.sidebar header .site-avatar .emoji` 是 3 个类加 1 个元素，`.site-avatar .emoji` 只有 2 个类：

| 规则                                  | 具体性                  |
| :------------------------------------ | :---------------------- |
| `.sidebar header .site-avatar .emoji` | 3 类 + 1 元素 = (0,3,1) |
| `.site-avatar .emoji`                 | 2 类 = (0,2,0)          |

具体性不同时根本不比先后顺序，所以 `.site-avatar .emoji` 就算排在样式入口的最后一个 `@import`，也压不过主题那条。

值的方向也是反的：`2rem = 32px`，比主题默认的 20px 更大。而徽标的 `width` / `height` / `line-height` 都由 `--emoji-size` 驱动，只改字号不会缩底盘，观感只会更挤。

## 改法：覆盖主题暴露的 CSS 变量

主题自己的 `assets/scss/style.scss` 把 `custom.scss` 放在最后一行 `@import`[^1]，等于官方允许项目侧覆盖。所以只要具体性持平，后写的就生效：

```scss
.left-sidebar {
    --emoji-size: 28px;      /* 圆形底盘直径，同时决定 width / height / line-height */
    --emoji-font-size: 16px; /* 字形大小 */
}
```

两边都是 (0,1,0)，`custom.scss` 排在后面，新值覆盖主题的 40px / 20px。

媒体查询不增加具体性，所以主题在 `@media (min-width: 1536px)` 里对 `--emoji-size` 的那次重置（大屏下头像放大到 120px，徽标重新给 40px）同样被盖掉，各宽度下都是 28px。

两个变量分工明确：只嫌字形大就改 `--emoji-font-size`，连底盘一起缩才需要动 `--emoji-size`。

有一处需要留意：`.left-sidebar.compact` 也是变量来源，具体性 (0,2,0)，会反过来压过上面这条。本站的 `[sidebar] compact` 用主题默认值 `false`，不冲突；开了紧凑模式，就得把自己的选择器提到同一级。

## 没有变量可用时

不是每个属性都有变量兜着。碰上裸属性，就让选择器具体性大于等于主题那条——照抄主题的写法最省事：

```scss
.sidebar header .site-avatar .emoji {
    bottom: 4px; /* 只想让徽标往内挪一点 */
}
```

也可以照 HTML 实际结构补类名（徽标所在的 `aside` 带 `sidebar`、`left-sidebar` 两个类）。`!important` 能赢，但会把后来者的覆盖路径一起堵死，本站不用。

## 定位任意一个 CSS 细节的三步

1. **DevTools 看谁赢了**：F12 选中元素，Styles 面板里生效的声明在上、被覆盖的带删除线，谁压谁一目了然。主题 SCSS 不产出 sourcemap，这里只能看到 `style.min.<hash>.css` 的行号，拿不到原始 SCSS 路径，所以还有第 2 步。
2. **回主题源码找写法**：进模块缓存，按 class 或属性名搜。看到 `var(--xxx)` 就说明主题把这一处做成了可覆盖的接口，优先改变量而不是加选择器。
3. **在 `custom.scss` 里改，按具体性核对**：变量同分靠顺序，裸属性要比主题更具体。

查资料的顺序：主题仓库的 `assets/scss/` 最准（官方文档常滞后）→ 主题文档站 → 通用概念查 MDN，比如具体性怎么算[^2]。本站的样式管线（含为什么显式指定 Dart Sass）记在构建记录里：[用 Hugo + Stack 主题 + GitHub Pages 搭建博客](hugo-stack-github-pages/index.md)。

## 验证

样式表带 sha256 指纹，改了就会生成新文件名，浏览器不会拿旧缓存，普通刷新即可，不用 `Ctrl+F5`。如果刷新后 CSS 内容一点没变，才需要删掉 `resources/_gen/` 让 Hugo 重算资源。

确认改对了同样看产物：

```powershell
Select-String -Path public\scss\*.css -Pattern '--emoji-size:\s*28px'
```

## 结语

再遇到「规则写了没反应」，先查产物确认 CSS 已加载，再算具体性——这比继续叠 `!important` 快得多。主题升级后要复查 `custom.scss` 里覆盖的变量名是否还在：主题改名变量不会报错，只会静默失效。

[^1]: [Stack theme source: assets/scss/style.scss](https://github.com/CaiJimmy/hugo-theme-stack/blob/v4.0.3/assets/scss/style.scss)

[^2]: [MDN: CSS specificity](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_cascade/Specificity)
