---
title: DeepSeek Harness 安装
slug: dsh-installation
date: 2026-09-07T21:30:00+08:00
description: dsh 是 DeepSeek 官方开源的 Agent 工具，一条 npx 命令即可启动 Web UI。记录安装与首次使用，并解释 node-domexception 弃用警告：可放心忽略。
tags:
  - deepseek
  - dsh
  - nodejs
  - npm
  - dom-exception
categories:
  - ai
---

> dsh（DeepSeek Harness）是 DeepSeek 官方开源的 Agent 工具，架构上「一切皆插件」。安装只需一条 `npx` 命令，无需全局安装；过程中的 `node-domexception` 弃用警告可以放心忽略。[^1]

---

## 一、安装

前置：Node.js 18+（推荐 LTS），官网下载或用包管理器安装。

```bash
npx @deepseek-ai/dsh web
```

首次运行会下载依赖并启动 Web UI，默认地址 `http://127.0.0.1:3080`，自动打开浏览器。不想自动打开，加 `--no-open`：

```bash
npx @deepseek-ai/dsh web --no-open
```

> 注意：dsh 目前是 developer preview，迭代很快、可能有破坏性更新，别把它当稳定依赖。

---

## 二、首次使用

启动后在 Web UI 里完成两件事即可用：

1. **配置模型**：在 Settings → Models 中填入 DeepSeek API Key，添加后立即可用，无需重启。
2. **选择工作目录**：通过 Choose workspace 选中要操作的目录，不选则无法新建会话。

端口 3080 被占用会导致启动失败，先停掉占用进程。其他启动参数见 `npx @deepseek-ai/dsh web --help`。

---

## 三、node-domexception 弃用警告

安装时终端会输出：

```bash
npm warn deprecated node-domexception@1.0.0: Use your platform's native DOMException instead
```

- **是什么**：`node-domexception` 是老包，曾在旧版 Node.js 中模拟浏览器原生错误类型 `DOMException`。
- **为何弃用**：Node.js v17 起原生内置 `DOMException`，不再需要第三方模拟，npm 将其标记为 deprecated。
- **为何还出现**：dsh 的某个间接依赖仍引用该包，但运行时 Node 会使用内置实现，此包**不会被执行或加载**。[^2]

结论：**不影响任何功能，直接忽略**。等 dsh 依赖链更新后，警告会自然消失。

---

[^1]: [deepseek-harness GitHub 仓库](https://github.com/deepseek-ai/deepseek-harness)

[^2]: [Node.js v17.0.0 发布说明（原生 DOMException）](https://nodejs.org/en/blog/release/v17.0.0)
