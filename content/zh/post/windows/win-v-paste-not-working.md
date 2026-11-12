---
title: Win+V 只复制不粘贴的排查与修复
slug: win-v-paste-not-working
date: 2026-11-11T00:30:00+08:00
description: Win+V 能选中历史、内容也已进剪贴板却不粘贴：用键盘钩子对照实验确认面板从未发出粘贴事件，再重注册 Windows 功能体验包修复
tags:
  - troubleshooting
  - windows
  - clipboard
categories:
  - windows
draft: true
---

 `Win + V` 调出剪贴板历史记录能看到历史、能选中，选中项也确实进了剪贴板，但点击或回车无法粘到光标处。问题不在剪贴板数据，而在「输入体验」组件没把粘贴动作发出来。

## 症状与边界

| 操作                        | 结果                                             |
| :-------------------------- | :----------------------------------------------- |
| Ctrl+C / Ctrl+V             | 正常                                             |
| Win+V                       | 正常，能看到全部记录                             |
| 在面板里选中一条            | 正常，内容立刻进入剪贴板，`Get-Clipboard` 读得到 |
| 点选 / 回车后自动粘贴到光标 | 失效，所有程序一样                               |

环境是 Windows 11 26H2

## 先排除常见原因

| 疑点                               | 检查结果                                                     |
| :--------------------------------- | :----------------------------------------------------------- |
| 目标窗口提权，合成按键被 UIPI 拦掉 | 面板与实际输入的程序同 session、同为 Medium 完整性；普通窗口也一样失效 |
| 第三方键盘钩子吞键                 | 火绒、手心输入法、TranslucentTB 都在跑，但下面的对照实验表明合成按键没被全局拦截 |
| 策略或设置关掉了粘贴               | System>Clipboard>Clipboard history为开启状态                 |
| 组件跑久了状态坏                   | explorer、TextInputHost、ShellExperienceHost 都单独重启过，重启后依旧失效 |

## 关键实验：面板有没有发出粘贴

判断是「没发出」还是「发出后被拦」，看有没有合成按键真的进了输入队列就够了。挂 `WH_KEYBOARD_LL`，并且每 800 ms 卸载重挂一次：低层键盘钩子后挂的排在链首，这样才能压过面板自己临时挂的那一个。只记录 Win、Ctrl、V、Enter、Esc，看 `LLKHF_INJECTED` 标志和事件瞬间的前台窗口。

两轮抓取、几十次真实按键（含十几次 Win+V 与回车），`injected` 事件始终是 0。

再补两组对照：

- 进程 A 用 `SendInput` 发 Ctrl+V 到进程 B 的文本框，粘上了。合成按键、跨进程注入、UIPI 都没问题。
- Win+. 的 emoji 面板能把字符插进同一个输入框。输入体验的插入通道正常。

两组都正常，说明面板在写完剪贴板之后就停住了，没有产生任何进入应用层的输入。

## 模拟按键打不开面板

想脚本化复现，得先能打开面板。三种注入都试过：`SendInput` 带扫描码、`keybd_event`、带扩展键标志并拉长按住时间。用 WinEvent 钩子盯着，没有任何新窗口出现，前台窗口也不变；同样的组合手工按就正常。注入的 Win 组合键被系统忽略，所以这功能只能人工按键配合钩子观测。

## 修复

重注册输入体验所在的包，然后重启。只重启 explorer 或 TextInputHost 不够——故障期间两者都重启过，现象不变。

```powershell
# 管理员 PowerShell
Get-Service 'cbdhsvc_*' | Restart-Service -Force
Get-Process TextInputHost -ErrorAction SilentlyContinue | Stop-Process -Force

$cbs = Get-AppxPackage MicrosoftWindows.Client.CBS
Add-AppxPackage -Register (Join-Path $cbs.InstallLocation 'AppxManifest.xml') -DisableDevelopmentMode
```

重启后点选和回车都能正常粘贴。原本还打算重置该包的应用设置 `settings.dat`（`%LOCALAPPDATA%\Packages\MicrosoftWindows.Client.CBS_*\Settings\settings.dat`），但文件被进程占用没改成，所以起作用的是重注册加重启。

## 结语

面板类故障先分清「动作没发出」还是「发出后被拦」：向另一个进程注入同样的动作、再用同组件的相邻功能做对照，两者都正常就基本锁定组件内部状态，重注册对应包比逐项改设置有效。
