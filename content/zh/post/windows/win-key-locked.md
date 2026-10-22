---
title: Win 键失灵：先确认是不是被锁了
slug: win-key-locked
date: 2023-05-12T17:00:00+08:00
description: Win 键按了没反应的三类原因：键盘 Fn 锁定、Scancode Map 被改写、软件劫持吞键，附各自的确认命令与恢复方法
tags:
  - windows
  - keyboard
  - shortcut
categories:
  - windows
---

Win 键单独按没反应、组合键也失效时，先别急着重装驱动：多半是键盘自己被锁了，或者系统里的键盘映射被改过。

## 一、键盘自带锁定（最常见）

不少机械键盘和外接键盘提供锁 Win 功能，防止打游戏时误触。组合键因厂商而异：

- `Fn + Win` 切换
- `Fn + 左 Win` 锁定、`Fn + 右 Win` 解锁（部分 104 键键盘）
- 个别品牌把它塞进功能键（如 `Fn + F12`），以键盘说明书为准

笔记本的「游戏模式」开关也可能顺带锁 Win。按一遍试，能恢复就是这一类。

## 二、系统里的键盘映射被改写

读一下这个注册表键：

```powershell
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout' |
  Select-Object -ExpandProperty 'Scancode Map' -ErrorAction SilentlyContinue
```

干净系统上该键下没有 `Scancode Map` 这个值（Win 11 实测缺省）。如果它存在，说明有程序改过扫描码映射——键位重映射工具、某些手柄驱动、远程控制软件都会写它，Win 键可能被映射成了空操作。处理顺序：先导出备份该注册表键，再删除 `Scancode Map`，重启。

## 三、软件劫持

全屏游戏、键盘宏工具（PowerToys 的 Keyboard Manager、AutoHotkey 脚本）、远控软件都可能吞掉 Win 组合键。确认方法：任务管理器里退出可疑进程后再试；或用「干净启动」（`msconfig` 里关掉全部非微软服务）复现。

## 四、网页键盘测试帮不上忙

浏览器收不到 Win 键：按下时系统会先把它交给自己处理（打开开始菜单），网页拿不到这个事件。所以拿键盘测试网站判断 Win 键是否损坏没有意义，直接换一把键盘插上试更快。

## 结语

顺序是：先按 Fn 组合键解锁，再查 `Scancode Map`，最后排除软件劫持；三者都排除后才轮到驱动与键盘硬件。
