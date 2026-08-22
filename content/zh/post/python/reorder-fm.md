---
title: reorder_fm.py：批量重排 Markdown Front Matter
slug: reorder-fm
date: 2026-08-22T07:40:19+08:00
description: 博客文章开头的 front matter 键顺序有规范？手动整理太累？用 reorder_fm.py 一条命令批量重排，本文把原理和用法讲到小白也能懂。
tags:
  - python
  - hugo
  - front-matter
  - yaml
categories:
  - python
  - tutorial
---

写 Markdown 博客时，每篇文章开头都有一块用 `---` 包裹的元数据，叫 **front matter**（标题、日期、标签、分类都在里面）。这个博客的写作规范对 front matter 的键顺序有明确要求：`title` → `slug` → `date` → `description` → `tags` → `categories` → `image`（如果有）。

手动写新文章时顺序还算容易控制，但要批量整理几十篇旧文章，一篇篇打开调整顺序就很痛苦。本文介绍博客仓库 `scripts/` 下的小工具 `reorder_fm.py`：一条命令递归重排整个目录的 front matter，并尽量讲清楚它背后的原理，零基础也能看懂。

## Front Matter 是什么

front matter 是 Markdown 文件开头的 YAML 块，被两个 `---` 夹在中间，用来存放文章的元数据：

```yaml
---
title: "我的第一篇文章"
date: 2026-08-22
tags:
  - python
categories:
  - tutorial
---

正文从这里开始。
```

像 Hugo、Hexo 这类静态博客生成器，会读取这个块来渲染页面标题、归档日期、标签页和分类页。没有它，文章就没有标题、没有日期、也没有标签。

## 为什么要固定键顺序

键顺序不影响渲染结果——Hugo 不关心 `title` 写在 `date` 前面还是后面。统一顺序纯粹是**给人看的规范**：

- **可读性**：打开任何一篇文章，第一眼就知道「标题、slug、日期、描述、标签、分类」在哪
- **一致性**：用 Front Matter CMS 新建的文章就是这个顺序，手写文章对齐后全站统一
- **易对比**：`git diff` 时，同一位置的键互相比较，改动一目了然

所以规范定下来之后，剩下的问题就是：**怎么把不符合顺序的文件批量改对？**

## 环境准备

`reorder_fm.py` 依赖两个东西：

- Python 3（任意版本均可）
- `ruamel.yaml` 库（用于保留格式地读写 YAML）

安装依赖：

```bash
pip install ruamel.yaml
```

如果用的是 Anaconda 环境（比如本机 `py_env`），`ruamel.yaml` 已经预装，可以直接运行。脚本本身约 110 行，放在博客仓库的 `scripts/` 目录。

## 基本用法

脚本用法只有一条命令，路径可以是文件，也可以是目录：

```bash
python reorder_fm.py 目标文件.md
python reorder_fm.py ./docs          # 递归处理目录下所有 .md
```

以 `scripts/reorder_fm.py` 重排博客文章目录为例：

```bash
python reorder_fm.py content/zh/post
```

执行后每个被修改的文件会打印 `已更新: <路径>`，顺序本来就对的打印 `无变化: <路径>`。

### 自定义键顺序

默认顺序是 `title slug date description tags categories`，与博客规范一致。需要别的顺序时用 `--order` 指定：

```bash
python reorder_fm.py document.md --order title date tags
```

参数说明：

| 参数     | 说明                                             | 默认值                                     |
| :------- | :----------------------------------------------- | :----------------------------------------- |
| `path`   | 要处理的文件或目录，目录会递归查找所有 `.md`     | 必填                                       |
| `--order`| 键顺序列表，空格分隔                             | `title slug date description tags categories` |

## 脚本原理

`reorder_fm.py` 的核心逻辑只有三步：**切出 front matter → 按顺序重建字典 → 写回文件**。

### 第一步：找到 front matter 的边界

第一行必须是 `---`，然后往下找到第二个 `---`，中间就是 YAML：

```python
lines = content.splitlines()
if not lines or lines[0].strip() != "---":
    return content                      # 没有 front matter，原样返回

end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
fm = "\n".join(lines[1:end])            # 两个 --- 之间的部分
```

这就是为什么**没有 front matter 的文件会被自动跳过**，混在目录里的普通笔记不会被误改。

### 第二步：按顺序重建字典

普通的 Python 字典不保证键的插入顺序，所以脚本用了 `ruamel.yaml` 的 `CommentedMap`（一个保持顺序的字典子类）：

```python
from ruamel.yaml import YAML
from ruamel.yaml.comments import CommentedMap

DEFAULT_ORDER = ["title", "slug", "date", "description", "tags", "categories"]

yaml = YAML()                            # round-trip 模式
data = yaml.load(fm)

new_data = CommentedMap()
for key in DEFAULT_ORDER:                # 先放规范顺序里的键
    if key in data:
        new_data[key] = data.pop(key)
for key in list(data):                   # 剩下的键保持原来的相对顺序
    new_data[key] = data[key]
```

`ruamel.yaml` 的 round-trip 模式会尽量保留注释和缩进等格式细节，这是它比 `json` 或普通 `yaml.safe_load` 更适合这类工具的原因。

### 第三步：写回文件

重排后的 YAML 再拼回 `---` 框架，如果内容有变化就覆盖写入，没有变化则不碰文件：

```python
out = YAML()
out.indent(mapping=2, sequence=4, offset=2)   # 对齐博客规范的缩进风格
buf = StringIO()
out.dump(new_data, buf)
new_lines = lines[:1] + buf.getvalue().splitlines() + lines[end:]

if new_content != orig:
    open(filepath, "w", encoding="utf-8").write(new_content)
    print(f"已更新: {filepath}")
else:
    print(f"无变化: {filepath}")
```

只读不写的幂等设计意味着：**重复运行是安全的**，顺序已经正确的文件不会被反复改动。

## 实测效果

一个键顺序打乱的 front matter：

```yaml
---
categories:
  - python
date: 2026-08-21
description: 测试用文件，键顺序故意打乱。
tags:
  - test
title: "测试文档"
slug: "test-doc"
---
```

运行 `python reorder_fm.py test.md` 之后：

```yaml
---
title: 测试文档
slug: test-doc
date: 2026-08-21
description: 测试用文件，键顺序故意打乱。
tags:
  - test
categories:
  - python
---
```

键顺序完全对齐规范。注意两个细节：`title` / `slug` 的引号会被规范化掉（脚本输出统一不带引号，对 Hugo 渲染无影响）；再跑一次则输出 `无变化`。

## 常见问题

**报 `ModuleNotFoundError: No module named 'ruamel'`**

没有安装依赖，先执行 `pip install ruamel.yaml`。

**Windows 的 Python 打不开 `/mnt/...` 路径**

Windows 原生 Python 不认 WSL 的 `/mnt/` 路径，要把参数写成 Windows 格式：

```bash
python D:\Projects\hugo-stack-blog\scripts\reorder_fm.py D:\docs
```

或者干脆用 WSL 里的 `python3` 配合 `/mnt/d/...` 路径。

**目录里混着非博客文件会被改吗**

不会。脚本只处理以 `---` 开头、且包含完整 front matter 的 `.md` 文件，其余原样跳过。

**想保留引号或自定义缩进**

脚本输出统一用无引号形式，缩进固定为 2 空格、序列缩进 4 空格。有特殊需求可以改脚本里 `out.indent(...)` 和 dump 部分的参数。

## 结语

`reorder_fm.py` 解决的问题很具体：把「front matter 键顺序」这条规范变成一条可重复执行的命令。核心思路——用保持顺序的 `CommentedMap` 重排 YAML、无变化不写盘——也适用于其他「批量整理元数据」的场景。如果还想更进一步，可以在 git 提交前加一个 pre-commit 检查，让顺序问题在源头就被拦截。

## 参考

- `reorder_fm.py` 源码：`scripts/reorder_fm.py`
- [ruamel.yaml 官方文档](https://yaml.dev/doc/ruamel.yaml/)
- 相关阅读：[YAML 入门](../yaml/yaml-intro.md)、[Markdown 指南](../markdown/markdown-for-typora-cn.md)
