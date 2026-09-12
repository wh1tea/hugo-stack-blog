---
title: VS Code 美化
slug: vscode-beautification
date: 2025-09-12T21:30:00+08:00
description: VS Code 主题与字体设置：主题列表的打开方式、常用主题对比、编辑器与终端字体和连字的配置写法
tags:
  - vscode
  - fonts
  - configuration
categories:
  - devtools
---

VS Code 默认的配色和字体未必适合长时间编码。本文用最少的步骤把主题、字体和连字配置好，读完能直接套用到自己的编辑器上。

## 设置主题

按 `Ctrl+K` 再按 `Ctrl+T` 打开主题列表，方向键预览，回车确认。想用命令面板也行：`Ctrl+Shift+P` 输入 `Preferences: Color Theme`。

常用主题[^1]：

| 主题                | 特点                 |
| :------------------ | :------------------- |
| Default Dark Modern | 内置默认，无色偏     |
| One Dark Pro        | Atom 风格，对比柔和  |
| Dracula Official    | 高饱和紫粉，夜间友好 |
| GitHub Theme        | 与 GitHub 网页一致   |

选定后 VS Code 会写入 `settings.json` 的 `workbench.colorTheme` 字段，想手动改直接编辑这一项即可。

## 设置字体

打开设置搜索 `font family`，或直接编辑 `settings.json`：

```json
{
  "editor.fontFamily": "'JetBrains Mono', 'Cascadia Code', Consolas, monospace",
  "editor.fontSize": 14,
  "editor.fontLigatures": true,
  "editor.lineHeight": 1.6
}
```

几点说明：

- `fontFamily` 按顺序回退，前面的字体没装就用后面的，最后一定要留一个 `monospace` 兜底。
- 等宽字体才适合代码；JetBrains Mono、Cascadia Code、Fira Code 都自带连字。
- `fontLigatures` 开启后 `!=`、`=>`、`===` 会渲染成连字符号，介意可设为 `false`。
- `lineHeight` 用倍数，1.5–1.8 之间阅读体验较好。

字体需要先装到系统里，VS Code 不会自带下载。JetBrains Mono 官网和 Cascadia Code 的 GitHub 仓库都能直接下载安装包。

## 终端字体

编辑器的字体设置不影响集成终端。想让终端也用同一套字体，补上：

```json
{
  "terminal.integrated.fontFamily": "'JetBrains Mono', Consolas, monospace",
  "terminal.integrated.fontSize": 13,
  "terminal.integrated.fontLigatures": true
}
```

## 结语

主题按喜好挑一个高对比、不刺眼的即可，字体优先选等宽且带连字的 JetBrains Mono 或 Cascadia Code。改完 `settings.json` 保存即刻生效，不需要重启。配置建议同步到 Settings Sync，换机器时一键恢复。

[^1]: [vscode 主题选择网站](https://vscodethemes.com/)
