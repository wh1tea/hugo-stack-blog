---
title: "WSL2 安装与使用完全指南"
description: "从安装到日常使用：WSL2 环境搭建完全指南，含发行版管理、资源限制与常见问题排查。"
slug: "wsl2"
date: 2026-05-13
tags:
  - wsl
  - wsl2
  - linux
  - windows
categories:
  - windows
---

WSL（Windows Subsystem for Linux）是微软为 Windows 10/11 提供的 Linux 兼容层，无需虚拟机或双系统即可原生运行 Linux 命令与应用。WSL2 作为第二代版本，在性能、兼容性和资源占用之间取得了更好的平衡。

本文面向有编程基础的开发者，介绍 WSL2 的安装、初始化配置、资源限制与常见问题排查。读完你就能在 Windows 上顺畅搭建 Linux 开发环境。

## WSL1 与 WSL2 怎么选

WSL2 于 2019 年随 Windows 10 发布，核心改进在于：WSL1 通过翻译层将 Linux 系统调用转换为 Windows 系统调用，仅部分兼容；WSL2 运行在轻量级虚拟机中，使用真实 Linux 内核，提供完整的系统调用兼容性。

| 对比维度          | WSL1         | WSL2               | 传统虚拟机 |
| :---------------- | :----------- | :----------------- | :--------- |
| Linux 内核        | 无（翻译层） | 完整内核           | 完整内核   |
| 系统调用          | 部分支持     | 完全支持           | 完全支持   |
| Linux 目录 I/O    | 较慢         | 快 3-5 倍          | 快         |
| 访问 Windows 目录 | 较快         | 稍慢（跨文件系统） | 慢         |
| 内存占用          | 低           | 稍高               | 高         |
| 启动速度          | 快           | 秒级               | 慢         |

WSL2 解压 tar 包可达 WSL1 最高 20 倍速度，`git clone` 等操作快约 2-5 倍，还支持 GPU 加速与 Linux GUI 应用。

> 结论：绝大多数场景选 WSL2。若需频繁访问 Windows 目录下的文件，可考虑在特定发行版保留 WSL1。

## 安装步骤

### 先决条件

- 系统版本：Windows 10 2004（内部版本 19041）及以上，或 Windows 11
- CPU：支持并开启虚拟化（Intel VT-x / AMD-V）

> 提示：按 `Win + R` 输入 `winver` 回车，可查看系统版本。

### 一键安装（推荐）

以管理员身份打开 PowerShell 或 Windows 终端：

```powershell
wsl --install
```

该命令会自动启用 WSL 与虚拟机平台组件、安装最新内核、将 WSL2 设为默认并安装 Ubuntu。完成后需重启计算机。

### 安装其他发行版

```powershell
wsl --list --online        # 查看可用发行版
wsl --install -d Debian    # 指定安装
```

| 选项             | 说明                             |
| :--------------- | :------------------------------- |
| `--distribution` | 指定发行版名称                   |
| `--no-launch`    | 安装后不自动启动                 |
| `--web-download` | 从网络下载，而非 Microsoft Store |
| `--location`     | 自定义安装目录                   |

### 手动安装（备选）

`wsl --install` 不可用时：

1. `Win + R` 输入 `appwiz.cpl` 回车，点击「启用或关闭 Windows 功能」
2. 勾选「适用于 Linux 的 Windows 子系统」和「虚拟机平台」，重启
3. 管理员 PowerShell 执行 `wsl --set-default-version 2`
4. 从 Microsoft Store 安装所需发行版

## 初始化配置

### 用户名与密码

首次启动发行版会提示创建 Linux 用户名和密码。该账户独立于 Windows 账户，默认拥有 `sudo` 权限。

> 注意：输入密码时屏幕无显示，属正常安全策略。

忘记密码时，在 PowerShell 中以 root 进入后重置：

```powershell
wsl -u root
# 或指定发行版：wsl -d Ubuntu -u root
```

```bash
passwd <用户名>
```

### 更新软件包

```bash
sudo apt update
sudo apt upgrade -y
```

### 更换软件源（国内用户）

```bash
bash <(curl -sSL https://linuxmirrors.cn/main.sh)
```

### 安装 Windows Terminal

从 Microsoft Store 安装「Windows Terminal」，多标签管理 WSL / PowerShell / CMD。建议将 Ubuntu 设为默认配置文件。

## 资源限制

WSL2 默认可能占用高达 80% 的物理内存。在 `%UserProfile%\.wslconfig`（即 `C:\Users\<用户名>\.wslconfig`）中限制：

```ini
[wsl2]
memory=8GB                # 最大内存
processors=4              # CPU 核心数
swap=4GB                  # 交换分区大小
localhostForwarding=true  # localhost 转发
```

> 提示：修改后执行 `wsl --shutdown` 完全关闭，约 8 秒后重新启动生效。

## 常用命令

### WSL 管理命令（PowerShell / CMD 中执行）

| 命令                               | 说明                         |
| :--------------------------------- | :--------------------------- |
| `wsl --status`                     | 查看 WSL 状态与默认版本      |
| `wsl -l -v`                        | 列出发行版及版本             |
| `wsl` / `wsl -d <发行版>`          | 启动默认或指定发行版         |
| `wsl -t <发行版>`                  | 终止指定发行版               |
| `wsl --shutdown`                   | 终止所有 WSL 及虚拟机        |
| `wsl --set-default-version 2`      | 设置 WSL2 为默认             |
| `wsl --set-version <发行版> 2`     | 转换发行版到 WSL2            |
| `wsl --update`                     | 更新 WSL 内核                |
| `wsl --unregister <发行版>`        | 卸载发行版（删除根文件系统） |
| `wsl --export <发行版> <文件.tar>` | 导出为 tar 备份              |

### Linux 基础命令（WSL 终端内执行）

| 命令       | 说明                   |
| :--------- | :--------------------- |
| `uname -a` | 内核版本与架构         |
| `df -h`    | 磁盘空间               |
| `free -h`  | 内存用量               |
| `pwd`      | 当前目录               |
| `ls -lah`  | 列出全部文件（含隐藏） |

## 常见问题

**Q：提示命令未识别或安装失败？**
确认 BIOS 已开启虚拟化（Intel VT-x / AMD-V），并检查 WSL 与虚拟机平台功能是否启用。

**Q：`wsl --list --online` 无法获取列表？**
多为网络问题（无法访问 `raw.githubusercontent.com`），可修改 DNS 或配置代理。

**Q：WSL2 内存占用过高？**
通过 `.wslconfig` 限制内存与 CPU，见上文。

**Q：WSL2 无法使用代理？**
WSL2 默认 NAT 网络与主机隔离。可在 `.wslconfig` 启用镜像网络：

```ini
[wsl2]
networkingMode=mirrored
```

或在 WSL 内手动设置代理环境变量。

## 结语

WSL2 让 Windows 开发者无需虚拟机或双系统即可使用完整 Linux 环境。核心建议：

- 用 `wsl --install` 一键安装
- 安装 Windows Terminal 提升体验
- 用 `.wslconfig` 限制资源占用
- 国内用户更换软件源

## 参考

- [Microsoft Learn - 设置 WSL 开发环境](https://learn.microsoft.com/zh-cn/windows/wsl/setup/environment)
- [Microsoft Learn - 比较 WSL 版本](https://learn.microsoft.com/zh-cn/windows/wsl/compare-versions)
- [Microsoft Learn - WSL 高级设置配置](https://learn.microsoft.com/zh-cn/windows/wsl/wsl-config)
- [Ubuntu - Install Ubuntu on WSL 2](https://ubuntu.com/tutorials/install-ubuntu-on-wsl2)
- [Linux Mirrors - 一键更换软件源](https://linuxmirrors.cn/)
