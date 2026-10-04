---
title: 网络入门：DNS、CGNAT、MTU 与常用命令
slug: network-basics
date: 2026-10-03T14:29:40+08:00
description: DNS 解析、NAT 与 CGNAT、共享出口 IP 被 CDN 风控、MTU 与 MSS 这几个常被混为一谈的概念，附 ipconfig /flushdns 等常用命令与一份入门阅读清单
tags:
  - network
  - dns
  - mtu
  - cli
  - tutorial
categories:
  - network
---

解析不到、连不上、连上了收不到数据、有数据但很慢，是四类不同的问题。这篇把各层涉及的基本概念（DNS、NAT 与 CGNAT、CDN 风控、MTU 与 MSS）和常用命令集中理一遍，读完能对着现象判断问题落在哪一层。

## 一次请求经过哪几层

| 层       | 干什么             | 出问题的典型现象               |
| :------- | :----------------- | :----------------------------- |
| DNS 解析 | 域名 → IP          | 域名打不开，用 IP 却能打开     |
| TCP 连接 | 三次握手建立连接   | 端口不通、连接超时             |
| TLS 握手 | 协商加密、验证证书 | 一直转圈、证书报错             |
| 数据传输 | 收发 HTTP 报文     | 连得上但收不到数据、大文件断流 |

## DNS：域名到 IP 的翻译

DNS 把域名解析成 IP，中间经过本机缓存 → 递归解析器 → 权威服务器，结果按 TTL 缓存；缓存让解析变快，也让"改了 DNS 却不生效"很常见——`ipconfig /flushdns` 清的就是这层缓存。

两种坏法症状完全不同：**解析不到**（域名拼错、DNS 服务器不通）与**解析到错地址**（路由器抢答、投毒、劫持）。后者表现为"域名打不开、IP 能打开"，最易误判成网站挂了；解析结果落在 `10.`、`192.168.`、`127.`、`100.64.` 这类内网或保留地址段，即可判定被污染。

```powershell
Resolve-DnsName www.baidu.com                    # 当前解析结果
Resolve-DnsName www.baidu.com -Server 223.5.5.5  # 换 DNS 服务器对比
ipconfig /flushdns                               # 清本机 DNS 缓存
```

## 公网 IP、NAT 与 CGNAT

私网地址（`10.0.0.0/8`、`172.16.0.0/12`、`192.168.0.0/16`）不能直接上公网，出口靠 NAT 把多台设备映射到同一个公网 IP。家里路由器做一次 NAT 很正常；运营商在它上面再做一次，就是 **CGNAT（运营商级 NAT）**，专用地址段 `100.64.0.0/10`[^1]。

三个实际后果：你查到的"公网 IP"是几百户共用的；端口映射与从外网访问家里设备会失效；这个 IP 的信誉由所有共享者共同承担。

```powershell
tracert -4 -d -h 3 223.5.5.5   # 第二跳落在 100.64.x.x → 你在 CGNAT 后面
curl.exe -s http://ip.3322.net # 看当前出口 IP
```

想让远程访问、做种这类事情可用，得找运营商要一个动态公网 IP。

## 共享出口 IP 与 CDN 风控

**CDN** 在各地部署边缘节点就近分发内容，顺带承担缓存与抗 DDoS；**WAF** 在边缘按来源 IP 和请求特征决定拦不拦。

风控看的是**来源 IP 的历史行为**：同一出口 IP 下只要有人刷量、跑爬虫、发起攻击，整个 IP 都可能被限速、弹验证码，严重的直接静默丢包。表现是 `ping` 通、TCP 也连得上，却拿不到数据——容易和"被墙""网站挂了"混淆，区别在于风控按 IP 判人。

能做的三件事：换出口（手机流量）、找运营商换公网 IP、换代理节点；第三条并不可靠，节点 IP 一样可能被拉黑。

## MTU 与 MSS：小请求能过、大的就卡

链路层一帧有长度上限（以太网 1500 字节），IP 包超过**路径 MTU** 就得靠分片，或者让发送方把包改小。**MSS** 是 MTU 减去 IP 头与 TCP 头后的净载荷（IPv4 下通常 1500 − 40 = 1460），双方在三次握手时互相通告。

路径 MTU 发现（PMTUD）依赖 ICMP「需要分片」报文回传[^2]。该报文被丢、上游又没做 **MSS 钳制**时，发送方会一直按 1460 字节发，超限的大包在瓶颈处静默消失：`ping` 正常、三次握手成功，但 TLS 握手（要发几 KB 证书）或大文件中途卡死。自己先降 MTU 可快速验证，根治要让路由器在每个 WAN 口开 MSS 钳制。

```powershell
netsh interface ipv4 show subinterfaces  # 看当前 MTU
ping -f -l 1472 223.5.5.5                # 不分片探测；报"需要分片"说明已超过路径 MTU
```

## 命令与现象对照

按排查顺序排，左边命令、右边对应现象与判据。

| 命令                                      | 用途         | 对应现象                 | 判据                         |
| :---------------------------------------- | :----------- | :----------------------- | :--------------------------- |
| `ipconfig /all`                           | 本机网络配置 | 完全上不了网             | 网关与 DNS 是否符合预期      |
| `nslookup <域名>` / `Resolve-DnsName`     | 查一条解析   | 域名打不开但 IP 能开     | 结果是不是真实地址           |
| `ipconfig /flushdns`                      | 清解析缓存   | 改了 DNS 或 hosts 不生效 | 清完重新解析一次             |
| `ping <主机>`                             | ICMP 可达性  | 判断"通不通"             | 只证明小包通，不代表服务可用 |
| `Test-NetConnection <主机> -Port 443`     | TCP 端口连通 | 连接超时、端口不通       | 握手层是否通                 |
| `curl.exe -v --noproxy '*' <URL>`         | 端到端请求   | 能连上但一直转圈         | 卡在 TCP、TLS 还是等响应     |
| `tracert -d <主机>`                       | 逐跳路径     | 外网访问不了内网服务     | 第二跳是否 `100.64.x.x`      |
| `netsh interface ipv4 show subinterfaces` | 本机 MTU     | 小响应能过、大响应被丢   | MTU 是否被改成非 1500        |

`--noproxy '*'` 让 curl 绕开系统代理直连，测到的才是链路本身；与"走代理"对比即可区分路坏了还是选错了路。

## 结语

网络问题几乎都能归到一句话上：先分清是**找不到路**（DNS）、**路不通**（连接与出口），还是**路上丢东西**（MTU 与 IP 信誉）；最后一类通常要改上游或换出口。

## 延伸阅读

基础与 DNS：

- [Cloudflare Learning Center](https://www.cloudflare.com/learning/)
- [What is DNS? (Cloudflare)](https://www.cloudflare.com/learning/dns/what-is-dns/)

NAT 与 CDN：

- [Carrier-grade NAT (Wikipedia)](https://en.wikipedia.org/wiki/Carrier-grade_NAT)
- [What is a CDN? (Cloudflare)](https://www.cloudflare.com/learning/cdn/what-is-a-cdn/)

MTU 与系统命令：

- [Maximum transmission unit (Wikipedia)](https://en.wikipedia.org/wiki/Maximum_transmission_unit)
- [netsh interface ipv4 (Microsoft Learn)](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-interface)

两个同类故障的实战复盘：[DNS 劫持排查](dns-hijack-troubleshooting.md)、[MTU 黑洞排查](mtu-blackhole-troubleshooting/index.md)。

[^1]: [RFC 6598: IANA-Reserved IPv4 Prefix for Shared Address Space](https://www.rfc-editor.org/rfc/rfc6598)
[^2]: [RFC 1191: Path MTU Discovery](https://www.rfc-editor.org/rfc/rfc1191)
