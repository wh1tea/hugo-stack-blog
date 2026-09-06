---
title: hermes update 失败排查：空 git 代理配置作祟
slug: hermes-update-proxy
date: 2026-08-29T02:11:06+08:00
description: hermes update 报网络错误，排查发现 git 全局配置的空代理覆盖项强制直连 github.com 导致超时，附修复与验证命令
tags:
  - hermes
  - git
  - proxy
  - wsl
  - cli
categories:
  - git
---

`hermes update` 拉取更新时失败，报 135 秒网络超时。curl 直连与代理都通，问题出在 git 的代理配置：一条空的 `http.https://github.com.proxy` 覆盖项让 git 对 github.com 强制直连，绕开了代理环境变量。本文记录排查链路、git 代理优先级机制与修复方法，可与《GitHub 推送失败排查》对照阅读。

## 报错现象

```text
$ hermes update
⚕ Updating Hermes Agent...

→ Fetching updates...
✗ Network error — cannot reach the remote repository.
  fatal: unable to access 'https://github.com/NousResearch/hermes-agent.git/':
  Failed to connect to github.com port 443 after 135040 ms: Could not connect to server
```

- 超时 135 秒：TCP 层丢包（github.com 直连被墙的典型表现），不是 DNS 也不是 TLS
- `hermes update` 本质是在源码目录执行 `git fetch origin`，所以问题收敛到 git 的网络链路

## 排查链路

1. 先排除代理本身：`curl -x http://127.0.0.1:7897 https://github.com` 返回 200，代理端口 7897 正常
2. 直连也通：`curl --noproxy '*' -I https://github.com` 返回 200——网络层没问题
3. 检查 git 全局配置，发现一条可疑的空值：

```bash
git config --global --list --show-origin
# file:/home/wh1tea_unix/.gitconfig  http.https://github.com.proxy=
```

1. 用 `GIT_CURL_VERBOSE=1` 看 git 的真实连接方式，对比两种配置：

```bash
# 带空覆盖项：直连 github.com
GIT_CURL_VERBOSE=1 git ls-remote origin HEAD
# == Info: Trying 20.205.243.166:443...        # 直连，不走代理

# 显式指定代理：建立隧道
git -c http.https://github.com.proxy=http://127.0.0.1:7897 ls-remote origin HEAD
# == Info: Establish HTTP proxy tunnel to github.com:443   # 走代理
```

结论：git 对 github.com 完全绕过了代理，直连时恰好撞上被墙的 IP，TCP 连接被丢弃，135 秒后超时。

## 根因：空代理值 = 禁用代理

### git 代理优先级

git 读取代理设置的顺序：

| 优先级 | 来源 | 示例 |
| :--- | :--- | :--- |
| 1 | URL 级配置 | `http.https://github.com.proxy` |
| 2 | 全局配置 | `http.proxy` |
| 3 | 环境变量 | `https_proxy` / `http_proxy` |

URL 级配置的优先级最高，会覆盖环境变量。`http.https://github.com.proxy` 表示「仅对 github.com 生效的代理」。

### 空值的语义

关键坑：**空值不等于「未设置」，而是「明确禁用代理」**。git 文档规定 `http.proxy` 及其 URL 级变体为空时，对该 URL 取消代理；而环境变量里的 `https_proxy` 优先级更低，被一并覆盖。所以这条配置一写，git 对 github.com 永远直连，环境变量再对也没用。

### 这条配置的来历

回查历史会话，这条空值配置是此前排查 GitHub 推送失败时设的：当时代理的 TLS 握手失败（`GnuTLS handshake failed`），临时用 `git config --global http.https://github.com.proxy ""` 让 github.com 直连绕过坏代理。当时直连恰好通畅，问题被掩盖——直到今天直连也被墙，才彻底暴露。

这也是 TUN 模式救不回来的原因：TUN 拦截的是网络层的包，但 git 在配置层已经明确要求直连，方向就错了。

## 解决：显式配置代理

把空值改成显式代理地址：

```bash
git config --global http.https://github.com.proxy http://127.0.0.1:7897
```

验证：

```bash
GIT_CURL_VERBOSE=1 git ls-remote origin HEAD
# == Info: Establish HTTP proxy tunnel to github.com:443
```

之后 `hermes update` 恢复可用。回滚方式：`git config --global --unset http.https://github.com.proxy`。

## 排查思路小结

| 层 | 检查手段 | 本次结论 |
| :--- | :--- | :--- |
| 网络 | `curl -I https://github.com` 直连 / 走代理 | 两层都通，网络无问题 |
| 机制 | 查看 `hermes update` 实现：实为 `git fetch origin` | 问题收敛到 git |
| 配置 | `git config --global --list --show-origin` | 发现空代理覆盖项 |
| 行为 | `GIT_CURL_VERBOSE=1` 观察真实连接 | 直连 vs 代理隧道，实锤 |

关键经验：

- `hermes update` 的「网络错误」多数是 git 网络问题，先按 git 排查，别只盯着代理软件
- git 配置的优先级高于环境变量，`git config --list --show-origin` 能看清每条配置的来源
- **空代理值会禁用代理**，不是「不设置」；怀疑代理不生效时先查有没有空值覆盖项
- `GIT_CURL_VERBOSE=1` 是验证 git 是否走代理的终极大法：输出 `Establish HTTP proxy tunnel` 表示走代理，`Trying <IP>:443` 表示直连
- 「上次修好的问题」可能是埋在配置里的雷：绕过型 workaround 会掩盖环境变化，条件反转时爆发

## 结语

git 的代理优先级是「URL 级配置 > 全局配置 > 环境变量」，一条空的 `http.https://github.com.proxy` 会静默禁用 github.com 的代理，让 git 在墙内直连超时。排查时用 `GIT_CURL_VERBOSE=1` 确认 git 的真实连接方式，修复时写显式代理地址而非空值。如果代理节点本身不稳定，治本还是换稳定节点，而不是在直连与代理之间反复横跳。

## 参考

- [GitHub 推送失败排查](github-push-failures.md)——本文空代理配置的由来
- [hermes update 又卡住：全量历史追赶与残留 tmp_pack](hermes-update-slow-fetch.md)——续篇：代理修好后再次卡住的排查
- [git-config 官方文档](https://git-scm.com/docs/git-config)
