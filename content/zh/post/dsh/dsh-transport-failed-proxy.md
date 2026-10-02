---
title: dsh 报 transport failed：Node 没走系统代理
slug: dsh-transport-failed-proxy
date: 2026-09-27T12:24:00+08:00
description: dsh 每隔几秒重试并报 transport failed，状态页、ping、API Key 都正常。真因是 Node 的原生 fetch 不读 Windows 系统代理，dsh 在直连一个本机已不可达的接口。
tags:
  - deepseek
  - dsh
  - proxy
  - nodejs
  - clash
categories:
  - ai
draft: true
---

> dsh 每隔几秒弹一次「模型重试 / 重试延迟：8587 毫秒 / 失败原因：DeepSeek Messages transport failed」。官方状态页正常、ping 通、API Key 和余额都没问题。真正的原因是 **Node 的原生 fetch 不读 Windows 的系统代理设置**，dsh 一直在直连一个当时不可达的接口；那个接口为什么不可达，是后来才查出来的路径 MTU 黑洞。下面记录定位过程、三行修复，以及为什么以前不用设也能用。

## 报错本身没给出原因

`DeepSeek Messages transport failed` 是兜底文案。翻源码可以看到它和另外两种失败并列：

```js
// @deepseek-ai/dsh-llm-deepseek
throw new LlmError("DeepSeek Messages transport failed", "TRANSPORT", { cause: error });
```

同一个 `generate()` 里还有流空闲超时（`TIMEOUT`，默认 300 秒）和请求被取消（`ABORTED`）。只有这三种都不匹配时才会落进 `TRANSPORT`，而真正的 `cause`（DNS 失败、连接被拒、TLS 握手失败）不会显示在界面上。所以看到这句话，能确定的只有一件事：**请求在拿到响应之前就断了**。

「重试延迟 8587 毫秒」也不是错误码，是重试策略的指数退避间隔。数值每次都不一样（同一轮排查里见过 516、7574、8279、8587 毫秒），它只说明已经重试了几轮。

## 三个排查方向都可以排除

| 检查                                                             | 结果           | 结论                                  |
| :--------------------------------------------------------------- | :------------- | :------------------------------------ |
| 官方状态页 [`status.deepseek.com`](https://status.deepseek.com/) | 云端正常       | 不是 DeepSeek 服务故障                |
| `ping api.deepseek.com`                                          | 35 ms、丢包 0% | 链路通，但 **ICMP 通不代表 HTTPS 通** |
| API Key 与余额                                                   | 有效           | 不是鉴权或欠费问题                    |

三步走完，问题就落到了本机到接口的**实际 HTTP 链路**上。

## 真因：Node 不读 Windows 系统代理

Windows 的「系统代理」（设置 → 网络和 Internet → 代理）只对**读这个设置的程序**生效，例如浏览器和 .NET/WinINET。Node 的原生 `fetch` 不在其中，它默认直连。

本机上 Clash 正开着系统代理 `127.0.0.1:7897`，浏览器和 `Invoke-WebRequest` 都走它；dsh 跑在 Node 里，**把系统代理整个跳过了**。而当时本机直连 `api.deepseek.com` 是不通的（不可达的原因见后面「为什么以前直接 npx 就能用」）：

| 方式                         | 结果                                  |
| :--------------------------- | :------------------------------------ |
| 直连（`curl --noproxy '*'`） | `http=000`，10 秒内 TCP 都没建起来    |
| 走 Clash `127.0.0.1:7897`    | `http=401`，TLS 0.32 秒、总计 0.89 秒 |
| Node 直连                    | `TimeoutError`，与 dsh 的报错一一对应 |

`401` 是没带 API Key 的正常响应——能拿到 401 就说明这条路是通的。问题不在 DeepSeek 服务，也不在 API Key，只在**走了哪条路**。

## 修复：把代理显式告诉 Node

Node 从 24 版起支持 `--use-env-proxy`[^1]，读取 `HTTP_PROXY` / `HTTPS_PROXY` / `NO_PROXY`，对应的环境变量开关是 `NODE_USE_ENV_PROXY`。启动 dsh 前先设好：

```powershell
$env:HTTP_PROXY  = "http://127.0.0.1:7897"
$env:HTTPS_PROXY = "http://127.0.0.1:7897"
$env:NODE_USE_ENV_PROXY = "1"

npx @deepseek-ai/dsh web
```

两点注意：

- **两个变量都要设。** 只设 `HTTPS_PROXY` 时，走 `http://` 的请求不会经过代理。
- **`NODE_USE_ENV_PROXY` 不能省。** 没有它 Node 依然会忽略这两个变量，这正是「明明设了代理还是不行」的常见原因。它等价于命令行参数 `node --use-env-proxy`。

想确认这个开关真的生效，可以故意把代理指向一个空端口：

```powershell
$env:NODE_USE_ENV_PROXY = "1"; $env:HTTPS_PROXY = "http://127.0.0.1:1"
node -e 'fetch("https://api.deepseek.com",{method:"HEAD",signal:AbortSignal.timeout(8000)}).catch(e=>console.log(e.cause?.code ?? e.name))'
# 输出 ECONNREFUSED → 变量被读到了；输出 TimeoutError → 没生效
```

## 为什么以前直接 npx 就能用

同一台机器、同一条命令，以前不需要设这些变量。当时留了两种解释，现在能定论：**直连确实不通，但原因不是运营商路由波动，而是路径 MTU 黑洞**。

**① TUN 模式（排除）。** TUN 会建虚拟网卡、接管**所有**流量，Node 不读环境变量也会被代理；切回「系统代理」模式后 Node 才被漏掉。本次排查里虚拟网卡不存在：

```powershell
Get-NetAdapter | Where-Object { $_.InterfaceDescription -match 'TUN|Wintun|Mihomo|Clash' }
# 有虚拟网卡 = TUN 模式；只剩 Disconnected 的第三方 TAP = 没开
```

**② 直连不可达（成立，原因已查明）。** 当时 `curl --noproxy '*'` 返回 `000`，判断成「直连是否可达取决于运营商路由与目标 IP，会变」。实际原因是那条线路的**路径 MTU 黑洞**：服务器一发大包（TLS 证书）就被丢，握手永远完不成，HTTPS 自然连不上——`ping` 只有几十字节，照样 0 丢包。

```powershell
curl.exe -4 -s -o NUL --max-time 10 --noproxy '*' -w '%{http_code}' https://api.deepseek.com
# 修复前 000；MTU 降到 1280 后 401、0.12 秒
```

那一刻「必须走代理」是这条路径故障造成的，不是 Node 的固有限制，也不该归咎于运营商路由变化。故障的现象、判别方法与一个自动给出结论的脚本见 [MTU blackhole troubleshooting](../network/mtu-blackhole-troubleshooting/index.md)。

## 怎么快速确认修好了

别靠「发一条长消息看它转不转圈」——重试是静默的，要等 8 秒才知道失败。用最小提示词压测更快：

```text
只回复OK，不解释
```

连发几次。这条提示词的输出只有两三个 token，失败时几乎立刻落到重试逻辑上，成功时秒回。观察点只有一个：**「重试延迟」提示是否还出现**。

## 小结

`DeepSeek Messages transport failed` 只是兜底文案，真正要查的是这台机器到 `api.deepseek.com` 的实际 HTTP 链路。`ping` 通、状态页正常、系统代理开着，这三件事都不足以说明 Node 程序能连上，因为它压根不读系统代理。给 Node 显式设置 `HTTP_PROXY` / `HTTPS_PROXY` 并打开 `NODE_USE_ENV_PROXY`，问题即解；但先分清是「路线选错」还是「路本身坏了」——本例里两条同时成立，后者是后来才查出的 MTU 黑洞。

[^1]: [Node.js CLI 文档：--use-env-proxy](https://nodejs.org/api/cli.html)
