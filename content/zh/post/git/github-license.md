---
title: GitHub 开源许可证怎么选
slug: github-license
date: 2025-12-07
description: 个人项目防商用：CC、GPL、MIT 许可证对比，附 LICENSE 文件快速模板
tags:
  - github
categories:
  - git
---

给个人练习项目加 License 时，最常见的诉求是「不允许别人拿去商用」。GitHub 上的许可证差别很大，本文按需求强度对比主流选择，并给出可以直接复制的模板。

## 许可证对比

| 许可证           | 能否商用    | 能否修改 | 分发要求         | 说明                                 |
| ---------------- | ----------- | -------- | ---------------- | ------------------------------------ |
| CC-BY-NC-4.0     | 禁止        | 可以     | 保留版权声明     | 最明确禁商用，连 AI 训练抓取都会过滤 |
| GPL v3           | 允许但极难  | 可以     | 必须开源         | 传染性强，商用必须开源全部衍生代码   |
| AGPL v3          | 同 GPL 更狠 | 可以     | 连网络服务也开源 | 连 SaaS 使用都要求开源               |
| CC-BY-NC-SA-4.0  | 禁止        | 可以     | 必须同许可       | 别人改了也只能非商业用               |
| MIT / Apache 2.0 | 完全允许    | 可以     | 保留版权声明     | 最宽松，无法阻止商用                 |

## 个人项目推荐

**想直白禁止商用** → 选 `CC-BY-NC-4.0`：全世界都认 NC 标签，法律含义清晰，几乎没有公司敢碰。

**想保留转正可能** → 选 `GPL v3`：大公司看到 GPL 就放弃商用（必须开源全部代码），实际效果接近禁商用；版权在你手里，以后想改成更宽松的许可随时可以。

## LICENSE 文件模板

选 CC-BY-NC-4.0 的最简方式：项目根目录新建 `LICENSE` 文件，粘贴以下内容：

```text
Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)
https://creativecommons.org/licenses/by-nc/4.0/

This work is licensed under a Creative Commons Attribution-NonCommercial
4.0 International License.

You are free to share and adapt the material for non-commercial purposes only.
```

选 GPL v3 则直接在 GitHub 新建仓库时选择 GPL v3 模板，或复制[官方全文](https://www.gnu.org/licenses/gpl-3.0.html)。

## 结语

练手项目不想被白嫖商用，`CC-BY-NC-4.0` 最省事、最直白；有开源意愿就上 `GPL v3`。两者都能吓退绝大多数商用场景，放一个 LICENSE 文件成本几乎为零。
