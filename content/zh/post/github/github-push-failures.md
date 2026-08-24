---
title: WSL 下 GitHub 推送失败排查
slug: github-push-failures
date: 2026-07-23T13:57:07+08:00
description: WSL 里 git push 到 GitHub 失败的两类问题排查：凭据读取失败与代理 TLS 握手失败，附完整命令与解决方案
tags:
  - git
  - github
  - wsl
  - proxy
categories:
  - windows
---

在 WSL（Ubuntu）里向 GitHub 推送代码，一次成功需要同时满足三个条件：git 身份已配置、凭据可读取、网络链路可用。本文记录一次真实的完整排查：先后遇到 `could not read Username`（凭据）和 `GnuTLS handshake failed`（代理）两类报错，每一步的排查命令与最终方案都写在下面，可直接对照复现。

## 场景一：读不到凭据

### 报错现象

第一次 `git push` 先报身份缺失：

```text
fatal: empty ident name (for <wh1tea_unix@wh1tea.localdomain>) not allowed
```

配置 `user.name` / `user.email` 后再次推送，换成凭据报错：

```text
fatal: could not read Username for 'https://github.com': No such device or address
```

### 排查链路

按「身份 → 凭据」逐层排查：

1. 身份缺失：WSL 内仓库未配置 git 身份，从历史提交记录里沿用已有身份补上
2. 凭据缺失：`gh` 命令不存在、没有 SSH 密钥、`git config --global credential.helper` 为空——WSL 侧没有任何可用的凭据来源
3. 发现 Windows 侧已有凭据：Windows 版 Git 自带 Git Credential Manager（GCM），且已经缓存了 GitHub 账号（`username=wh1tea`）。GCM 程序位于 `/mnt/d/Program Files/Git/mingw64/bin/git-credential-manager.exe`

WSL 与 Windows 共享文件系统，既然 Windows 侧有现成的凭据缓存，直接让 git 调用 Windows 的 GCM 即可，无需重新认证。

### 解决：包装脚本调用 Windows GCM

直接把 GCM 配成 credential helper 会失败：

```bash
git config --global credential.helper "/mnt/d/Program Files/Git/mingw64/bin/git-credential-manager.exe"
git push   # 报错: /mnt/d/Program Files/Git/mingw64/bin/git-credential-manager.exe get: 1: /mnt/d/Program: not found
```

原因：git 用 shell 执行 helper 命令，路径中的空格把 `/mnt/d/Program Files/...` 拆成了两个参数。解决办法是创建一个无空格的包装脚本：

```bash
mkdir -p ~/.local/bin

cat > ~/.local/bin/git-credential-win << 'EOF'
#!/bin/sh
exec "/mnt/d/Program Files/Git/mingw64/bin/git-credential-manager.exe" "$@"
EOF

chmod +x ~/.local/bin/git-credential-win
git config --global credential.helper "$HOME/.local/bin/git-credential-win"
```

再次 `git push` 即成功，凭据由 Windows GCM 缓存提供，后续推送不再需要输入。

## 场景二：代理导致 TLS 握手失败

### 报错现象

第二次推送遇到完全不同的报错，且重试依旧：

```text
fatal: unable to access 'https://github.com/wh1tea/hugo-stack-blog.git/':
GnuTLS, handshake failed: The TLS connection was non-properly terminated.
```

### 排查链路

报错发生在 TLS 握手阶段，优先怀疑代理：

1. 检查代理环境变量：`env | grep -i proxy` 发现 `https_proxy=http://127.0.0.1:7897`（Clash 类代理）
2. 走代理测连通性：`curl -x http://127.0.0.1:7897 -I https://github.com` 返回 `HTTP/1.1 200 Connection established`——代理隧道本身能建立
3. 绕过代理直连：`curl --noproxy '*' -I https://github.com` 返回 `HTTP/2 200`——github.com 可直连，问题只出在 git 过代理
4. 定位结论：Ubuntu 自带 git 的 GnuTLS 实现经该代理握手失败，代理环境变量是元凶

补充测试：Windows 侧 Git 同样推送失败（`Recv failure: Connection was reset`），说明当时代理对 GitHub 的转发本身就不稳定，不限于 WSL 内 git。

### 解决：绕过代理推送

按代价从小到大有三种做法：

1. 单次绕过代理：

```bash
env -u https_proxy git push
```

1. Windows 侧手动推送：在 Windows 仓库目录里执行 `git push`，走 Windows 的凭据与网络栈
2. 永久方案：让 git 对 github.com 跳过代理（代理环境变量仍在，其余流量不受影响）：

```bash
git config --global http.https://github.com.proxy ""
```

## 排查思路小结

两次报错对应两层问题，可复用这套分层法：

| 层    | 检查手段                                          | 本次结论           |
| :---- | :------------------------------------------------ | :----------------- |
| 身份  | `git config user.name` / `user.email`             | 未配置 → 补齐       |
| 凭据  | `git config --global credential.helper`、`gh auth` | WSL 无凭据 → 复用 GCM |
| 网络  | `curl -I https://github.com`（直连 vs 代理）      | 代理 TLS 握手失败   |

关键经验：

- `curl` 是区分网络层与应用层问题的最佳工具：直连通、代理通但 git 失败，基本可锁定是 git 与代理的 TLS 兼容问题
- WSL 与 Windows 共享凭据缓存，优先复用 Windows 的 GCM，避免二次认证；路径含空格时用包装脚本包裹
- `https_proxy` 是 TLS 类报错的头号嫌疑，先用 `env -u https_proxy git push` 快速验证

## 结语

GitHub 推送失败不要急着怀疑账号，先按「身份 → 凭据 → 网络」分层排查：身份缺失补 `user.name` / `user.email`；凭据缺失在 WSL 下优先复用 Windows 的 Git Credential Manager（包装脚本解决路径空格）；TLS 握手失败用 `curl` 对比直连与代理，确认是代理问题后按域名跳过即可。本次两个问题都在这套思路下几分钟内定位，推送链路从此稳定。

## 参考

- [Git 远程推送失败排查（认证与合并）](../git/git-push-existing-remote.md)
- [GitHub SSH 认证配置](../git/git-github-ssh.md)
- [WSL2 安装与使用完全指南](../wsl/wsl2.md)
- [Git Credential Manager 官方文档](https://github.com/git-ecosystem/git-credential-manager)
