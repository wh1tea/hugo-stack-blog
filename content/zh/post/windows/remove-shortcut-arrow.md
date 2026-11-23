---
title: 去掉 Windows 快捷方式的小箭头
slug: remove-shortcut-arrow
date: 2026-11-24T04:08:41+08:00
description: 把快捷方式角标指向系统透明图标，去掉 Windows 10/11 桌面快捷方式左下角的小箭头，附命令行与图形界面两种做法及恢复方法
tags:
  - windows
  - registry
  - icon
  - shortcut
categories:
  - windows
draft: true
---

Windows 10 / 11 桌面快捷方式左下角的小箭头是系统叠加的角标。把 `Shell Icons` 里编号为 `29` 的图标重定向到系统自带的透明图标，箭头就消失了，快捷方式本身不受影响。不要直接删除 `IsShortcut` 键值——那会连带破坏开始菜单磁贴、任务栏固定和右键菜单。

两种方法任选其一，改完都要重启资源管理器。

## 命令行修改（推荐）

以管理员身份打开终端：右键开始菜单 → 「终端（管理员）」或「PowerShell（管理员）」。

写入注册表项，把箭头换成透明图标：

```powershell
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /d "%systemroot%\system32\imageres.dll,197" /t reg_sz /f
```

终端提示 `操作成功完成。` 即写入成功。

重启资源管理器让改动生效：

```powershell
taskkill /f /im explorer.exe; start explorer.exe
```

桌面闪烁一次后，所有快捷方式的小箭头应已消失。若没变化，先确认终端是管理员权限，再执行一次重启命令。

## 手动修改注册表

不习惯命令行就走图形界面，全程需要管理员权限。

### 打开注册表编辑器

按 `Win + R`，输入 `regedit` 并回车；弹出用户账户控制（UAC）提示时点「是」。

### 定位到 Explorer

在顶部地址栏粘贴路径并回车，左侧目录树会展开并选中 `Explorer`：

```text
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer
```

### 新建 Shell Icons 项

右键 `Explorer` → 「新建」→「项」，命名为 `Shell Icons`（中间有一个空格）；该项已存在就直接进入。

### 设置图标值

在右侧空白处右键 → 「新建」→「字符串值」，命名为 `29`；双击它，把「数值数据」改为：

```text
%systemroot%\system32\imageres.dll,197
```

确定后，右侧应出现一条名称为 `29`、类型为 `REG_SZ`、数据为 `%systemroot%\system32\imageres.dll,197` 的记录。

### 重启资源管理器

按 `Ctrl + Shift + Esc` 打开任务管理器，在「进程」列表找到「Windows 资源管理器」，右键 → 「重新启动」。桌面刷新后箭头消失。

## 恢复默认箭头

管理员终端执行：

```powershell
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /f
taskkill /f /im explorer.exe; start explorer.exe
```

这条命令只删除 `29` 这个值，不影响 `Shell Icons` 项里的其它设置；桌面刷新后箭头恢复。

## 结语

透明图标方案只改叠加的角标，快捷方式的 `IsShortcut` 标记保持原样，开始菜单和任务栏功能不受影响。想进一步改快捷方式本身显示的图标，见 [给 .exe 更换图标的三种方法](change-exe-icon.md)。
