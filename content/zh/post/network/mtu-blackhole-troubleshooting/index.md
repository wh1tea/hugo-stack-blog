---
title: 网页打不开但 ping 通：MTU 黑洞排查
slug: mtu-blackhole-troubleshooting
date: 2026-10-02T23:54:16+08:00
description: 部分网站打不开却 ping 得通，TCP 连得上但 TLS 握手收不到数据。按 DNS、代理、TLS 实现、链路、响应大小逐层排除，定位到路径 MTU 黑洞，附一个自动给出结论的 PowerShell 脚本
tags:
  - network
  - mtu
  - troubleshooting
  - pwsh
categories:
  - network
---

环境是 Windows 有线直连，网线从墙里接进来（前面是房东的商用路由器，出口在运营商 CGNAT 后面），浏览器挂着 Clash 系统代理。现象是：一部分网站打不开，另一部分完全正常。

| 类别     | 表现                                                |
| :------- | :-------------------------------------------------- |
| 打不开   | 百度、斗鱼、5EPlay、淘宝、京东、阿里云镜像          |
| 正常     | B 站、网易、QQ、知乎、微博、12306、清华与中科大镜像 |
| `ping`   | 目标全部秒回，20 次 0 丢包                          |
| TCP 443  | 全部能完成三次握手                                  |
| TLS 握手 | 打不开的那批收不到任何字节                          |

这几条同时成立，范围就已经很小：网络没断，目标没宕，丢包只发生在"服务器要发大包"的时候。

## 按层排除

| 假设                     | 验证                                        | 结果                                              |
| :----------------------- | :------------------------------------------ | :------------------------------------------------ |
| 代理把国内站送进了坏节点 | `curl --noproxy '*'` 完全绕过代理           | 一样失败；代理内核的连接表里根本没有这些目标      |
| DNS 解析被污染           | 看解析结果，再拿解析出的 IP 直接发请求      | 解析到的是真实 CDN 地址，同一 IP 的明文 HTTP 秒回 |
| 某套 TLS 实现有问题      | schannel（curl）、OpenSSL（Node）、.NET     | 三种实现卡在同一处                                |
| 本机链路或网卡故障       | 网卡错误计数、ICMP 丢包率、大文件吞吐       | 全部干净                                          |
| 中间有透明代理           | 连保留地址（`192.0.2.0/24` 等）的 80 与 443 | 全部超时，没有 accept-all 的设备                  |
| 上游线路或出口 IP 被拦   | 换手机流量做对照                            | 全部恢复正常                                      |

另一种常见形态见 [DNS hijack troubleshooting](../dns-hijack-troubleshooting.md)：那次是路由器抢答 DNS，把域名解析成固定的公共 DNS 地址，和这次的"能解析、连得上、取不回数据"正好互补。

换手机流量那条最容易得出错误结论。"换流量就好了"其实是因为那条路走 **IPv6**，换掉的是协议栈而不是出口 IP，这个误判后面又花了不少时间才纠正。

## 关键判别：小响应能过，大响应被丢

把同一台服务器换不同 SNI 各测两次，症状立刻分开：

| 发出去的 SNI                           | 服务器要回的内容    | 结果             |
| :------------------------------------- | :------------------ | :--------------- |
| `www.qq.com`、`example.com`            | 几十字节的 TLS 告警 | 秒回             |
| `www.5eplay.com`、`mirrors.aliyun.com` | 完整握手，证书数 KB | 0 字节，直到超时 |

同一个 IP 上，明文 HTTP 请求 0.01 秒返回 403，TLS 握手永远等不到响应。服务器发得出来，说明大包在半路被丢了。同一时刻从清华源下载 1.8 MB 能跑到 2 MB/s，排除带宽与断网，只剩下"特定目标或路径上的包级丢弃"。

## 根因：路径 MTU 与 MSS 钳制

TCP 建连时双方交换 MSS，客户端按本机网卡 MTU 通告（MTU 1500 → MSS 1460）。如果这条路上有一段 MTU 更小，而中间设备既没做 MSS 钳制、又把 ICMP「需要分片」报文丢掉[^1]，服务器仍会按 1460 字节发大包：它们在下游被静默丢弃，TCP 反复重传同样尺寸，于是小包能过、大包全丢。

TLS 握手恰好是最依赖大包的一步（证书链几 KB），所以表现为"TCP 连得上，TLS 永远握手不完"，而 `ping` 只有几十字节，一切正常。

改本机 MTU[^2] 让通告出去的 MSS 变小：

```powershell
netsh interface ipv4 set subinterface "Ethernet" mtu=1280 store=persistent
```

| 指标                                   | 改之前   | 改之后               |
| :------------------------------------- | :------- | :------------------- |
| 百度、斗鱼、5EPlay、淘宝、京东、阿里云 | 超时     | 200，TLS 0.03–0.14 s |
| 坏 IP 上用真实 SNI 握手                | 0 字节   | 200                  |
| 清华源 1.8 MB                          | 2.2 MB/s | 5.3 MB/s             |
| 直连 api.deepseek.com                  | 连不上   | 401，0.12 s          |

根因在房东那台商用路由器上：它支持多 WAN 与策略路由，一部分目标被分到了小 MTU 的线路。正面修法是让路由器对每个 WAN 口开启 MSS 自动钳制，之后本机 MTU 可以恢复 1500；在那之前，本机降 MTU 是零成本且可逆的绕过。

## 把排查固化成脚本

上面每一步都能单独复用，但顺序和判据容易记错，于是写成一个只读脚本 [net-diagnose.ps1](net-diagnose.ps1)（不需要管理员权限，不改动任何配置）：

- 环境快照：默认出网接口、MTU、全局 IPv6、系统代理、hosts 固定项
- 分层探测：DNS → TCP 443 → 明文 HTTP（小响应）→ TLS（大响应）→ 未知 SNI（对照）
- 数据面对照：下载一个大文件，给出实际吞吐
- 判据：`sni` 列有告警而 `tls` 列超时，就是"大响应被丢"（curl 退出码 35 是 TLS 失败、28 是超时[^3]）
- 输出一行 `VERDICT` 和若干 `NEXT`，脚本自身退出码 0 / 1 / 2，可直接接进别的流程

```powershell
# 默认目标，pwsh 7 与 Windows PowerShell 5.1 都能跑
pwsh -NoProfile -File .\net-diagnose.ps1

# 自选目标
pwsh -NoProfile -File .\net-diagnose.ps1 -Targets www.baidu.com,www.douyu.com
```

MTU 修好之后的输出：

```text
target                   dns->ip          tcp    http443  tls     sni     note
www.baidu.com            183.2.172.177    open   no-http  ok      ok
www.douyu.com            183.36.18.51     open   ok       ok      tlserr
www.5eplay.com           183.61.230.55    open   ok       ok      tlserr
www.bilibili.com         14.17.92.71      open   ok       ok      ok

VERDICT: HEALTHY  (4/4 个目标 TLS 正常)
```

再遇到故障时，异常行会变成 `tls=nodata`、`sni=tlserr`，note 写"小响应可达、大响应被丢"，`VERDICT` 直接给出该跑的那条命令。

## 结语

`ping` 通、TCP 通、只有 TLS 握手等不到响应，方向就是大响应在路径上被丢，而不是被墙或代理配置错误。下次遇到同类症状，先跑一遍 `net-diagnose.ps1`，把结论落在 DNS、TLS、路径还是上游，再决定改什么。

[^1]: [RFC 1191: Path MTU Discovery](https://www.rfc-editor.org/rfc/rfc1191)
[^2]: [netsh interface ipv4](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-interface-ipv4)
[^3]: [curl exit codes](https://curl.se/libcurl/c/libcurl-errors.html)
