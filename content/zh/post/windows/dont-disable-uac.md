---
title: 关闭 UAC 的代价
slug: dont-disable-uac
date: 2022-01-13T09:48:00+08:00
description: 把 EnableLUA 改成 0 能让所有程序默认以管理员运行，代价是丢掉唯一的确认点、部分商店应用打不开、luafv 驱动加载失败，附改回方法
tags:
  - windows
  - uac
  - security
categories:
  - windows
---

网上常见的「让所有程序默认以管理员身份运行」的做法是改一个注册表值：

```text
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System
    EnableLUA = 0
```

重启后确实不再弹 UAC 确认框，代价比想象的大。

## 正常状态长什么样

```powershell
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' |
  Select-Object EnableLUA, ConsentPromptBehaviorAdmin, PromptOnSecureDesktop
Get-Service luafv
```

Windows 11 实测：`EnableLUA = 1`、`ConsentPromptBehaviorAdmin = 5`（默认值，管理员提权时询问）、`luafv` 服务 `Running / Automatic`。`luafv` 是 UAC 的文件与注册表虚拟化驱动，它的状态直接说明 UAC 在不在工作。

## 代价一：唯一的确认点没了

那次弹窗是「某个程序要改系统」时唯一一次让你确认的机会。`EnableLUA = 0` 之后，任何进程都能直接写 `HKLM`、装服务、改驱动，系统不再区分标准用户与管理员权限。

## 代价二：右键「以管理员身份运行」消失

所有进程已经是提升状态，这个菜单项不再显示，想单独给某个程序提权也没有入口。

## 代价三：部分应用打不开

- 标准用户下计算器、照片等商店应用会提示「为了对电脑进行保护，已经阻止此应用」或直接闪退[^1]。
- 系统日志里出现 `luafv` 服务启动失败、`此驱动程序被阻止加载`，因为 UAC 关掉后它的虚拟化文件系统被禁用[^2]。

## 只想少弹窗怎么办

别关 UAC 本体，改提示行为：

| 注册表值                         | 含义                                             |
| :------------------------------- | :----------------------------------------------- |
| `ConsentPromptBehaviorAdmin = 0` | 提权时直接放行，不弹窗（UAC 仍在，边界保留）     |
| `ConsentPromptBehaviorAdmin = 5` | 默认值，每次询问                                 |
| `PromptOnSecureDesktop = 0`      | 提示框不切到安全桌面，别的程序能模拟点击，不建议 |

只想让某个程序每次都提权，用的是另一个办法：右键快捷方式 → 属性 → 兼容性 → 勾选「以管理员身份运行此程序」；或到任务计划程序里建一个「使用最高权限运行」的任务。

## 改回来

把 `EnableLUA` 改回 `1` 并重启，然后到「控制面板 → 用户账户 → 更改用户账户控制设置」确认滑块没有停在「从不通知」。

## 结语

`EnableLUA = 0` 解决的是弹窗烦，换来的是没有确认点加部分应用坏掉。要减少打扰就调 `ConsentPromptBehaviorAdmin`，要单程序提权就用快捷方式属性，别动 UAC 本体。

[^1]: [Windows 怎么解决关闭 UAC 后标准用户无法打开计算器和照片的问题](https://www.php.cn/faq/2982361.html)

[^2]: [系统日志出现 luafv 服务启动失败：此驱动程序被阻止加载](https://cloud.tencent.cn/developer/article/2446313)
