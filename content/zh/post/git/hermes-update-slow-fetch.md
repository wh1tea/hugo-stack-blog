---
title: hermes update 又卡住：全量历史追赶与残留 tmp_pack
slug: hermes-update-slow-fetch
date: 2026-08-29T03:09:44+08:00
description: hermes update 卡在 Fetching updates 无报错：上游历史重写导致每次要下载 600MB 全量 pack，慢代理下被超时中断，残留 tmp_pack 越积越多，附后台重跑解法。
tags:
  - hermes
  - proxy
  - wsl
  - cli
categories:
  - git
---

上次修好空代理配置后（见《[hermes update 失败排查：空 git 代理配置作祟](hermes-update-proxy.md)》），`hermes update` 又卡住了。这次没有任何报错，卡在 `→ Fetching updates...` 几分钟不动，最终被终端超时杀掉。本文记录如何区分「死锁」与「慢速下载」、处理 `tmp_pack` 残留，以及后台重跑的正确姿势。[^1]

## 现象

```text
$ hermes update
⚕ Updating Hermes Agent...

→ Fetching updates...        # 卡在这里，5 分钟+，无任何输出
```

- 代理配置已确认正常：`git config --global --get-all http.https://github.com.proxy` 返回 `http://127.0.0.1:7897`
- 手动 `git fetch origin` 却能「秒完成」——这里埋了第一个坑（见下文）

## 排查链路

### 坑一：管道后的退出码不是 git 的

手动验证时用了管道：

```bash
timeout 60 git fetch origin 2>&1 | tail -20
echo "exit: $?"        # 输出 0 —— 但这是 tail 的退出码！
```

`$?` 取的是管道最后一个命令（`tail`）的退出码，git 其实被 `timeout` 杀了 60 秒，看似成功实则失败。判断 fetch 成败要用无管道写法或 `PIPESTATUS[0]`。

### 坑二：区分「死锁」与「慢速下载」

看进程树与 pack 目录：

```bash
ps aux | grep -E "git fetch|index-pack"
# git fetch origin
# git index-pack --stdin --fix-thin --keep=fetch-pack ... --pack_header=2,207824
```

`index-pack` 带着 207,824 个对象的 pack 头——正在下载一个大包。再用两次 `ls` 间隔对比：

```bash
ls -la .git/objects/pack/tmp_pack_4qSyK8   # 121MB
sleep 10
ls -la .git/objects/pack/tmp_pack_4qSyK8   # 139MB，在增长 = 在下载，不是死锁
```

### 坑三：反复失败留下的残包

`git count-objects -v` 报大量 `warning: garbage found: .../tmp_pack_xxx`。pack 目录里有几十个 `tmp_pack_*` 残留文件，累计 2.5GB+，其中多个是今晚多次失败尝试留下的（时间戳 02:17 / 02:19 / 02:27 / 02:41 / 02:47 / 02:48）。每次 fetch 中断都会留一个残包，git 不会自动清理，越积越多。[^2]

## 根因

- 上游 `main` 分支历史被重写（force-push / rebase），本地还是 5 月 14 日的 checkout，`git rev-list HEAD..origin/main --count` 显示 17,999 个新 commit——本地与远程完全分叉
- 一次 fetch 需要下载全部历史：约 600MB pack（207,824 对象），走 Clash 代理实测只有 0.5–2MB/s，全程 5–10 分钟
- `hermes update` 用 subprocess 同步等待 `git fetch`，中间无进度输出；短超时或 Ctrl+C 把进程杀掉，下载到一半的 `tmp_pack` 就留在原地

## 解决

1. 杀掉残留的 stopped 进程（`ps aux` 里状态为 T 的 `hermes`/git 进程），它们可能持有旧连接
2. 后台重跑，耐心等，不要用短前台超时：

```bash
hermes update --yes > /tmp/hermes_update.log 2>&1
# 实测全程约 13 分钟：fetch 6 分钟 + reset 对齐 + uv 装依赖 + Web UI 构建
```

1. 更新成功后 git 会自动清理全部残包（`git count-objects -v` 的 `garbage: 0`），无需手动删除

## 验证

```text
$ hermes --version
Hermes Agent v0.20.6 (2026.8.27) · upstream 4209d371
Up to date

$ git rev-list HEAD..origin/main --count
0
```

`hermes --version` 显示新版本、`Up to date`；与远程零差异；`git fsck --connectivity-only` 通过。

## 排查思路小结

| 层   | 检查手段                                 | 本次结论                             |
| :--- | :--------------------------------------- | :----------------------------------- |
| 进程 | `ps aux` 看 git / index-pack 是否存活    | 在下载，不是死锁                     |
| 进度 | pack 目录两次 `ls` 对比 `tmp_pack` 大小  | 121MB → 569MB，稳定增长              |
| 残留 | `git count-objects -v` 报 garbage        | 多次失败尝试累计 2.5GB 残包          |
| 根因 | `git rev-list HEAD..origin/main --count` | 17,999 commits，历史被重写，全量追赶 |

关键经验：

- 管道后 `$?` 是最后一个命令的退出码，验证 git 命令成败不要加管道
- git 卡住先看进程树 + pack 目录增长，区分「死锁」与「慢速下载」
- `tmp_pack_*` 是中断下载的残包，不自动清理，`git count-objects` 会报 garbage
- 大间隔更新 / 历史被重写时，一次 fetch 可能下载数百 MB，用后台运行 + 长等待，别用短超时

## 结语

这次「失败」其实是「没等完」：上游重写历史后，`hermes update` 需要一次性下载全部历史（约 600MB），代理慢 + 同步等待无进度 + 短超时中断，三因素叠加导致反复失败并留下大量残包。解法是后台重跑并耐心等待，成功后 git 自动清理残包。遇到 `hermes update` 卡住，先确认是在下载还是真的死锁，再决定是等还是杀。

[^1]: [hermes update 失败排查：空 git 代理配置作祟](hermes-update-proxy.md)——上一篇：空代理值导致直连超时

[^2]: [git count-objects 官方文档](https://git-scm.com/docs/git-count-objects)
