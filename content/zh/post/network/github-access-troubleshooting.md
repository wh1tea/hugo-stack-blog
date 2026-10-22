---
title: GitHub 访问慢：先分清卡在哪一层
slug: github-access-troubleshooting
date: 2021-11-05T16:58:00+08:00
description: 用五条命令判断 GitHub 打不开是解析、TCP、TLS 还是应用层问题，并用当前解析数据说明 hosts 固定 IP 为什么会过期
tags:
  - github
  - network
  - dns
  - troubleshooting
categories:
  - network
---

国内访问 GitHub 的体验随运营商、时段、域名而不同，抄一份 hosts 抄不出稳定结果。可行的做法是先定位卡在哪一层，再决定改 DNS 缓存、换端口还是换线路。

## 五个域名各管一件事

| 域名                        | 作用                      |
| :-------------------------- | :------------------------ |
| `github.com`                | 页面与 git over HTTPS     |
| `api.github.com`            | API（`gh` CLI、Actions）  |
| `github.githubassets.com`   | 静态资源（CSS、JS、头像） |
| `raw.githubusercontent.com` | raw 文件                  |
| `ssh.github.com`            | SSH over 443              |

「网页能开但图片不加载」和「clone 卡住但网页正常」是不同域名的问题，先确定是哪一个。

## 五条自证命令

```powershell
Resolve-DnsName github.com -Type A                   # local resolver
Resolve-DnsName github.com -Type A -Server 8.8.8.8   # compare with public DNS
Test-NetConnection github.com -Port 443 -InformationLevel Quiet
Test-NetConnection github.com -Port 22 -InformationLevel Quiet
curl.exe -v https://github.com -o NUL                # where the handshake stops
```

2026-10-22 在能正常访问的机器上实测：`github.com` 解析到 `20.205.243.166`，本机 DNS 与 8.8.8.8 结果一致；443 与 22 都返回 `True`；`curl.exe -v` 依次打印 `Trying 20.205.243.166:443`、`ALPN: server accepted http/1.1`、若干以 `schannel:` 开头的 TLS 行，最后是 `> GET /`。

Windows 自带的 curl 用 schannel，TLS 输出以 `schannel:` 开头；Linux 与 macOS 的 curl 用 OpenSSL，会打印 `SSL connection using TLSv1.3` 这类行。判读看的是停在哪一步，不是版本号。

| 停在哪 | 判据                                              | 大致原因                    |
| :----- | :------------------------------------------------ | :-------------------------- |
| 解析   | 前两条命令结果不同，或查询超时                    | DNS 被改写、缓存脏          |
| TCP    | `Trying <IP>:443` 之后没有下文，第 3 条为 `False` | 线路或防火墙阻断            |
| TLS    | `schannel` / `TLS handshake` 行之后中断           | 中间设备干扰握手            |
| 应用   | 五条都正常，只是 `git clone` 慢                   | 单连接拉大 pack，属线路质量 |

## hosts 方案为什么会过期

2021 年流传的 hosts 片段里，两行今天已经对不上：

| 旧 hosts 条目                                | 现在的解析结果                                                                                |
| :------------------------------------------- | :-------------------------------------------------------------------------------------------- |
| `185.199.108.153 assets-cdn.github.com`      | 该域名已无 A 记录                                                                             |
| `199.232.5.194 github.global.ssl.fastly.net` | 旧的 Fastly 域名；静态资源早已换成 `github.githubassets.com`，当前解析到 `185.199.108.215` 等 |

CDN 的 IP 随地区、时段变化，写死等于把今天的最优解固化成明天的错误路由；IP 失效时症状是静态资源加载失败或页面卡住，比不写 hosts 更难排查。要改 hosts 就让工具自动维护，别手工抄 IP。

## 22 端口不通时走 443

GitHub 官方支持把 SSH 指到 `ssh.github.com:443`，写进 `~/.ssh/config`：

```text
Host github.com
    HostName ssh.github.com
    Port 443
    User git
```

之后 `ssh -T git@github.com` 返回 `successfully authenticated` 即可[^1]。

## git 走没走代理

`GIT_CURL_VERBOSE=1` 的输出里，`Establish HTTP proxy tunnel` 表示走了代理，`Trying <IP>:443` 表示直连；完整判读见 [git 走代理的排查](../git/hermes-update-proxy.md)。

换客户端只改变出口线路，不改变上面四层的判读方法。挑工具时注意时效：Clash for Windows 的作者已于 2023 年底停止更新并删除仓库，网上以它为标题的安装教程基本都已过期。

## 结语

先用五条命令把「打不开」拆到解析、TCP、TLS、应用四层中的具体一层，再决定清 DNS 缓存、换 SSH 端口还是换线路。手工抄 hosts 是最容易做、也最容易过期的一步。

[^1]: [Using SSH over the HTTPS port - GitHub Docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/using-ssh-over-the-https-port)
