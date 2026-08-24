---
title: "切热点后游戏平台连不上？DNS 劫持排查实录"
slug: dns-hijack-troubleshooting
date: 2026-08-24T03:26:16+08:00
description: 换手机热点上网后，5E 与完美平台连不上、网站和 Steam 却正常。记录一次 DNS 劫持排查：现象、定位、根因与修复。
tags:
  - dns
  - network
  - windows
  - clash
  - troubleshooting
categories:
  - windows
  - tutorial
---

把电脑从网线切换到手机热点上网，同时开着 Clash 代理，浏览器访问一切正常，Steam 也没问题，但 5E Client（5E 对战平台）和完美世界竞技平台出现明显的网络故障：登录、接口请求全部连不上。

本文记录完整排查过程。核心结论先放前面：出网和代理都没问题，真正的原因是**以太网那一路的路由器在抢答 DNS，把域名解析污染成 114.114.114.114**，而游戏客户端不走代理、直接吃下了这个假地址。

读完你可以学会：如何用几条 PowerShell 命令区分"网络不通 / 代理问题 / DNS 问题"，以及多网卡环境下 Windows 的 DNS 选择逻辑。

## 现象

环境：Clash Verge（verge-mihomo 内核）系统代理模式，监听 `127.0.0.1:7897`；Wi-Fi 连接手机热点；网线仍插在电脑上，以太网处于活动状态。

| 服务 | 状态 |
| :--- | :--- |
| 浏览器 / 网页 | 正常 |
| Steam | 正常 |
| 5E Client | 连不上 |
| 完美世界竞技平台 | 连不上 |

这类游戏平台客户端不走系统代理，登录与接口请求靠自己的域名解析和 HTTPS 连接，恰好是最容易踩 DNS 坑的一类软件。

## 排查过程

### 确认代理与路由

先用 `Get-NetAdapter` 确认网卡状态，再用 `Find-NetRoute` 看默认出网路径：

```powershell
Get-NetAdapter | Select-Object Name, Status
Find-NetRoute -RemoteIPAddress 223.5.5.5
```

结果：出网流量实际走 Wi-Fi（热点），以太网只是"在线但没在出网"。代理是系统代理模式、未开 TUN，说明游戏客户端的流量并不会经过代理。

### 直连与代理对比

对游戏平台域名做直连 / 走代理对比测试：

```bash
curl --noproxy '*' -m 6 https://www.5eplay.com                 # 直连：超时
curl -x http://127.0.0.1:7897 -m 10 https://www.5eplay.com     # 走代理：200 OK
```

直连超时、代理正常——如果只看到这里，很容易误判成"网络被封"。但注意：curl 直连用的是系统解析，走代理时是 Clash 自己解析域名，差异可能出在解析上。

### 发现 DNS 异常

用系统默认方式解析，结果很反常：

```powershell
Resolve-DnsName www.5eplay.com
# www.5eplay.com  A  114.114.114.114   ← 这是 DNS 服务器地址，不是 5E 的服务器！
```

114.114.114.114 是国内知名公共 DNS 服务商 114DNS 的地址，绝不是 5eplay.com 的真实 IP。继续对比不同 DNS 服务器的解析结果：

```powershell
Resolve-DnsName www.5eplay.com -Server 192.168.45.163   # 热点 DNS：14.29.50.69 ✓
Resolve-DnsName www.5eplay.com -Server 114.114.114.114  # 114DNS：14.29.50.67 ✓
Resolve-DnsName www.5eplay.com -Server 223.5.5.5        # 阿里 DNS：14.29.50.66 ✓
Resolve-DnsName www.5eplay.com -Server 192.168.99.1     # 以太网路由器：114.114.114.114 ✗
```

所有正常 DNS 都能给出真实 IP，唯独以太网网关 192.168.99.1 对所有域名（包括 www.baidu.com）都返回 114.114.114.114。元凶锁定：那台路由器在污染 DNS 应答。

### 排除网络封锁

再用真实 IP 直连，确认热点网络本身没封游戏服务器：

```powershell
Test-NetConnection 14.29.50.69 -Port 443    # True
```

结论：直连真实 IP 完全通。问题 100% 出在 DNS 解析，而不是网络封锁或代理。

## 根因分析

拓扑示意：

```
手机热点 ──Wi-Fi──► Wi-Fi 网卡 ──► 出网（正常）
路由器 ──网线──► 以太网卡 ──► DNS 污染源（192.168.99.1）
```

Windows 的 DNS 客户端会遍历**所有活动网卡**提供的 DNS 服务器。之前用网线 + PPPoE 拨号时，拨号会话自带运营商 DNS，路由器通过 DHCP 下发的 DNS 根本排不上用场；切换到热点后不再拨号，以太网那一路路由器的 DNS（192.168.99.1）就进入了系统解析队列，而它（无论 WAN 断开后的异常回落，还是固件自带的劫持逻辑）对几乎所有域名都回 114.114.114.114。

于是出现"一半正常、一半崩溃"的割裂现象：

- 浏览器、Steam 走 Clash 系统代理，Clash 用 DoH（doh.pub / alidns）自己解析域名，绕开了被污染的系统 DNS → 正常
- 游戏客户端不走代理，自己用系统 DNS 解析 → 拿到假 IP → 连接失败

严格说不是"以太网适配器劫持了你"，适配器只是通道；真正回假答案的是 192.168.99.1 那台设备。

## 修复

最直接的办法：既然出网走热点，把网线拔掉（或禁用以太网适配器）。需要保留这条线时，只改它的 DNS：

```powershell
# 适配器名称以 Get-NetAdapter 输出为准
# 以太网适配器 DNS 改为公共 DNS
Set-DnsClientServerAddress -InterfaceAlias "以太网" -ServerAddresses 223.5.5.5,119.29.29.29

# 顺手固定 Wi-Fi 的 DNS，避免热点 DNS 不稳
Set-DnsClientServerAddress -InterfaceAlias "WLAN" -ServerAddresses 223.5.5.5,119.29.29.29
```

验证：

```powershell
ipconfig /flushdns
Resolve-DnsName www.5eplay.com    # 应返回真实 IP
```

## 经验总结

- 多网卡环境下，**默认网关 ≠ DNS 来源**。以太网没在出网，它的 DNS 依然可能被系统使用
- `114.114.114.114` 出现在 A 记录里是典型的"假地址"特征，直接起疑
- 排查网络问题先分清三条路径：走系统 DNS 的、走代理的、直连 IP 的，逐条测试才能定位
- 代理软件只救得了走代理的进程。游戏客户端的核心连接通常绕开系统代理，DNS 被污染时它们最先倒下

## 结语

这次故障的根因不是网络封锁，也不是代理配置错误，而是一台闲置路由器的 DNS 污染。拔掉网线后问题立即消失，游戏平台恢复正常。排查的关键在于把"解析"和"连接"拆开验证：先确认域名解析结果，再确认真实 IP 连通性，两步就能锁定问题层级。

## 延伸阅读

DNS 基础科普：

- [什么是 DNS？（Cloudflare 学习中心）](https://www.cloudflare.com/learning/dns/what-is-dns/)
- [域名系统（维基百科）](https://zh.wikipedia.org/wiki/%E5%9F%9F%E5%90%8D%E7%B3%BB%E7%BB%9F)
- [DNS 解析过程详解（Cloudflare）](https://www.cloudflare.com/learning/dns/how-dns-works/)

DNS 劫持与安全：

- [DNS 劫持（维基百科）](https://zh.wikipedia.org/wiki/DNS%E5%8A%AB%E6%8C%81)
- [什么是 DNS 劫持？（Cloudflare）](https://www.cloudflare.com/learning/dns/dns-hijacking/)
- [加密 DNS（DoH / DoT）科普（Cloudflare）](https://www.cloudflare.com/learning/dns/encrypted-dns/)
- [RFC 8484：基于 HTTPS 的 DNS（DoH）](https://www.rfc-editor.org/rfc/rfc8484)

Windows 网络排查：

- [Windows Server 域名系统（DNS）概述（Microsoft Learn）](https://learn.microsoft.com/en-us/windows-server/networking/dns/dns-top)
- [Test-NetConnection 文档（Microsoft Learn）](https://learn.microsoft.com/en-us/powershell/module/nettcpip/test-netconnection)
- [Resolve-DnsName 文档（Microsoft Learn）](https://learn.microsoft.com/en-us/powershell/module/dnsclient/resolve-dnsname)

代理与游戏客户端：

- [mihomo（Clash Meta 内核）](https://github.com/MetaCubeX/mihomo)
- [Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev)
- [114DNS 官网](https://www.114dns.com/)
