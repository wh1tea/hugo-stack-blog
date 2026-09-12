---
title: 把 Hermes 的记忆与技能迁入 DeepSeek Harness
slug: hermes-to-dsh-migration
date: 2026-09-08T21:11:05+08:00
description: 把 Hermes 的 md 资产接进 dsh 原生技能机制的完整记录：压平目录、接上自动注入的 AGENTS.md，并记下几个踩过的坑。
tags:
  - deepseek
  - dsh
  - hermes-agent
  - migration
  - skill
categories:
  - ai
---

> dsh（DeepSeek Harness）没有「从 Hermes 导入」按钮，也没有记忆服务，但它的技能发现机制是现成的：把 Hermes 的分类嵌套压平一层放进 `~/.dsh/skills/`，144 个技能立刻生效、无需重启；记忆则靠 `~/.dsh/AGENTS.md` 这条全局指令挂上指针。下面记录整个过程和踩过的坑。[^1]

---

## 一、Hermes 里有什么

要搬的两类资产都是 markdown：

| 数据 | 位置（WSL / Linux）   | 形态                                                        | 迁移方式              |
| ---- | --------------------- | ----------------------------------------------------------- | --------------------- |
| 记忆 | `~/.hermes/memories/` | `MEMORY.md`（环境与工具链）、`USER.md`（个人偏好）          | 复制 + 挂全局指令指针 |
| 技能 | `~/.hermes/skills/`   | 每个技能一目录：`SKILL.md` + 可选 `references/`、`scripts/` | 压平后放技能根目录    |

Windows 原生版路径同理，在 `%USERPROFILE%\.hermes`。本次实测的库是 145 个 `SKILL.md`（含 1 个归档在 `.archive/` 下的），活跃技能 144 个。

---

## 二、导出

在 Hermes 所在侧执行。技能和记忆一次拷出：

```bash
mkdir -p ~/hermes-migrate
cp ~/.hermes/memories/MEMORY.md ~/.hermes/memories/USER.md ~/hermes-migrate/
cp -r ~/.hermes/skills ~/hermes-migrate/skills
```

如果 dsh 装在 Windows、而 Hermes 在 WSL，绕开 `wsl` 命令的引号地狱，直接用 UNC 路径：`\\wsl.localhost\<发行版>\home\<用户>\.hermes\`。

---

## 三、核心坑：dsh 的技能发现只扫一层

dsh 的技能发现（`dsh-skill-filesystem`）只认两种形态：

- 目录包：`<根>/<name>/SKILL.md`
- 单文件：`<根>/<name>.md`

**嵌套的 `**/SKILL.md`一律不认。** 而 Hermes 是分类嵌套的：技能躺在`<分类>/<技能名>/SKILL.md` 里。原样拷进去，dsh 一个都发现不了。

所以第一步是压平分类层，把每个技能目录提升到根下直接一层：

```bash
SRC="$HOME/.hermes/skills"
DST="$HOME/.hermes-migrate-flat"
mkdir -p "$DST"
# 只走真实分类树：-.cache 之类的隐藏目录里有大量无关的 SKILL.md
find "$SRC" -mindepth 2 -maxdepth 4 -name SKILL.md -not -path '*/.*' |
  while read -r f; do
    cp -r "$(dirname "$f")" "$DST/$(basename "$(dirname "$f")")"
  done
```

技能包内部结构原样保留，所以正文里对 `references/`、`scripts/` 的相对引用照常有效。

目录名建议与 `SKILL.md` front matter 的 `name` 保持一致（本次实测 144 个里有 3 个不一致，例如目录 `creative-ideation`、`name: ideation`）。发现机制虽然主要看 front matter，但两者对齐能避免日后的困惑。

---

## 四、放进 dsh：`~/.dsh/skills/`

dsh 按优先级扫描技能根，数字越小越优先：

| 优先级 | 位置                      | 说明                                    |
| ------ | ------------------------- | --------------------------------------- |
| 100    | `<项目根>/.dsh/skills`    | 项目级，项目根 = 最近的 `.git` 祖先目录 |
| 200    | `<项目根>/.agents/skills` | 项目级（通用 agent 约定）               |
| 400    | `<dshHome>/skills`        | **用户级，本次落点**                    |
| 500    | `~/.agents/skills`        | 用户级（通用 agent 约定）               |

放 400 的理由：它是 dsh 专门给个人技能预留的用户级根，跨项目全局可用，且不会把几十 MB 的 markdown 塞进 git 仓库。

```bash
mkdir -p ~/.dsh/skills
cp -r ~/hermes-migrate-flat/* ~/.dsh/skills/
```

不需要重启 dsh：技能目录被实时监听，增删改会在下一个模型步骤反映到技能目录里。

---

## 五、记忆：没有服务，就挂全局指令

dsh 没有 Hermes 那种持久记忆服务，所以「迁移记忆」只能做成两件事：

1. 把 `MEMORY.md`、`USER.md` 放到 agent 读得到的地方；
2. 让 agent 每次会话都知道去哪读。[^2]

第二步靠 `~/.dsh/AGENTS.md`——由 `dsh-agent-instructions` 插件在**每个会话首个请求自动注入**（用户级，注入顺序在项目级之前）。文件里只写指针，不复制正文：

```markdown
## 个人记忆

任务相关时先读：

- `~/.dsh/MEMORY.md` —— 环境与工具链
- `~/.dsh/USER.md` —— 个人偏好

这两个文件含个人信息，禁止复制进任何仓库、禁止提交。
```

于是记忆的可用性从「每次人工提醒」变成「每个会话自动被告知去哪读」。三层分工是：`AGENTS.md` 负责注入指针，技能根负责提供技能，`MEMORY.md` 负责存内容。

---

## 六、验证

**技能数对得上**（Windows PowerShell）：

```powershell
(Get-ChildItem "$env:USERPROFILE\.dsh\skills" -Directory).Count
```

**目录已生效**：新会话的技能目录里应出现导入的技能，无需重启。本次实测技能目录从 1 个变为 145 个（144 个迁入 + 本机原有的 1 个）。

**记忆已注入**：`~/.dsh/AGENTS.md` 的内容会出现在会话上下文中。

**front matter 的坑**：dsh 要求 `name`（小写 kebab-case）与 `description` 齐全，缺失或格式非法就**静默丢弃**该技能——目录里不出现，而且不给任何提示。所以导入后建议逐个核一遍，别只看总数。

---

## 七、踩过的坑

- **`~/.hermes/skills/.cache/` 里有大量无关的 `SKILL.md`**：裸跑 `find ~/.hermes/skills -name SKILL.md` 会把 `uv` 缓存里的嵌套副本一起捞出来。必须限定只走真实分类树（`-not -path '*/.*'`）。
- **`maxdepth` 的语义**：`find` 的 `-maxdepth` 从基目录算起。三层目录结构（`分类/子类/技能/SKILL.md`）需要 `-maxdepth 4`，写 3 会静默漏掉最深的那一层。
- **`.archive/` 不是活跃技能**：Hermes 会把归档技能留在技能根下，按目录名排除。
- **`AGENTS.md` 的刷新是触碰驱动的**：dsh 不 watch 它，改动后靠新会话或一次文件操作生效；技能目录则是真 watcher，即时生效。

---

## 八、和 Hermes 机制怎么对应

迁移只搬数据，机制得另配。两边的对应关系：

| 能力     | Hermes                            | dsh 现状                                  |
| -------- | --------------------------------- | ----------------------------------------- |
| 技能     | markdown + front matter，分类嵌套 | markdown + front matter，**必须压平一层** |
| 记忆     | `MEMORY.md` / `USER.md`           | 无服务，靠 `AGENTS.md` 挂指针             |
| 全局偏好 | 记忆自动注入                      | `AGENTS.md` 自动注入                      |
| 子智能体 | `delegate_task`                   | `subagent` / `subagent_fork`              |
| MCP      | 原生支持                          | 经 `dsh-mcp-client` 接入第三方记忆 MCP    |

需要真正可检索的记忆，再按官方文档[^3]接 MCP 记忆服务（Reference Memory、Memorix、Engram 三选一）。本次没做——文件参考库加全局指令已经够用，md 资产本身也永远可以再搬。[^4]

---

## 结语

dsh 的迁移路径可以概括成一句话：**结构对齐优先，机制按需再补。**

- 动手前先确认目标端的发现规则。技能发现只扫一层这件事，决定了整个流程是「压平」而不是「复制」。
- 记忆别指望自动加载，用 `~/.dsh/AGENTS.md` 挂一个指针，成本最低、效果最稳定。
- 放在用户级技能根（`~/.dsh/skills/`）而不是项目里，一份资产全场可用，也不污染任何仓库。

dsh 仍是 developer preview，机制会变；但只要资产是纯 markdown，搬家永远只是复制粘贴的事。[^5]

[^1]: [Hermes Agent 完全指南](../ai/hermes-agent-guide.md)

[^2]: [MCP Reference Memory 服务器](https://github.com/modelcontextprotocol/servers/tree/main/src/memory)

[^3]: [官方文档：连接第三方记忆 MCP 服务](https://github.com/deepseek-ai/deepseek-harness/blob/master/docs/user/guide/mcp-memory.zh.md)

[^4]: [deepseek-harness（GitHub）](https://github.com/deepseek-ai/deepseek-harness)

[^5]: [dsh 安装与首次使用](dsh-installation.md)
