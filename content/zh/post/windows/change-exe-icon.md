---
title: 给 .exe 更换图标的三种方法
slug: change-exe-icon
date: 2026-08-24T01:24:05+08:00
description: 想换 Windows 程序图标，改 exe 本身还是改快捷方式？本文从一次快捷方式改图标报错实战出发，对比专用工具、命令行与快捷方式三条路线。
tags:
  - windows
  - exe
  - icon
  - shortcut
  - powershell
  - git
categories:
  - windows
---

Windows 下想换程序图标，本质有两条路线：修改 `.exe` 文件内的图标资源，或只改快捷方式的显示图标。前者一劳永逸但动原文件，后者安全但只对快捷方式生效。本文先记录一次改快捷方式图标失败的排查过程，再对比三种常用方法的优劣，读完即可按需选择。

## 实战：快捷方式改图标报错

给 Git for Windows 自带的快捷方式更换图标时，属性框报错：

> The folder 'D:\Program Files\Git\mingw64\binwintoast.exe' specified in the Start In box is not valid. Make sure that the folder exists and that the path is correct.

表面看是「起始位置」非法，实际上根因是这个快捷方式文件本身有缺陷。

### 原因

用 PowerShell 读取快捷方式字段后发现，TargetPath 指向 `wintoast.exe` 正常，但 WorkingDirectory（起始位置）被错误地填成了 exe 文件本身，而不是它的所在目录：

```powershell
$sh = New-Object -ComObject WScript.Shell
$s = $sh.CreateShortcut("$env:AppData\Microsoft\Windows\Start Menu\Programs\Git for Windows.lnk")
$s.TargetPath         # D:\Program Files\Git\mingw64\bin\wintoast.exe  正常
$s.WorkingDirectory   # D:\Program Files\Git\mingw64\bin\wintoast.exe  问题所在
```

这个快捷方式由 Git for Windows 安装器自动生成，起始位置字段写错了。平时双击还能运行（Target 有效），但属性框保存任何修改时都会校验 Start In 必须是存在的文件夹，校验失败导致包括图标在内的整个修改被拒绝。

### 修复

用脚本一次性修正起始位置并设置图标：

```powershell
$sh = New-Object -ComObject WScript.Shell
$s = $sh.CreateShortcut("$env:AppData\Microsoft\Windows\Start Menu\Programs\Git for Windows.lnk")
$s.WorkingDirectory = "D:\Program Files\Git\mingw64\bin"
$s.IconLocation = "D:\Program Files\Git\mingw64\share\git\git-for-windows.ico,0"
$s.Save()
```

保存后属性框恢复正常，图标也替换完成。教训：遇到「属性框保存失败」先读一下快捷方式字段，多半是起始位置或目标路径异常。

## 方法一：专用工具（推荐，最简单）

直接改 `.exe` 文件本身，对新手最友好：

- **Resource Hacker**：经典免费的资源编辑器。`File -> Open` 打开 exe，左侧资源树展开 `Icon`，右键图标选 `Replace Icon...`，选择 `.ico` 文件后 `Save`。
- **QIcon Changer**：拖拽式操作。把 exe 拖到左侧、ico 拖到右侧，点 `Apply` 即可。
- **GUI-EXE-Icon-Editor**：支持预览原图标、自动把 PNG/JPG 转成 ICO，修改前自动备份原文件。

## 方法二：命令行工具（适合批量）

**rcedit** 是流行的资源编辑命令行工具，还可修改版本信息等资源：

```bash
rcedit "你的程序.exe" --set-icon "你的图标.ico"
```

速度快、可脚本化，适合批量处理多个文件。

## 方法三：创建快捷方式（不修改原文件）

右键 exe 选择「创建快捷方式」，再右键快捷方式 -> 属性 -> 快捷方式选项卡 -> 更改图标，浏览选择 `.ico` 即可。仅改变快捷方式的显示图标，原文件完全不动，最安全。

## 注意事项

1. **备份原文件**：修改 exe 前先备份，防止操作失误损坏文件
2. **图标格式**：确保是 `.ico` 格式，否则先用在线工具或 IcoFX 转换
3. **管理员权限**：目标文件在系统目录（如 `C:\Windows`）时，修改工具需要以管理员身份运行
4. **程序兼容性**：带高强度数字签名或自我保护机制的程序可能无法成功修改图标

## 总结对比

| 方法           | 优点                     | 缺点                   | 适合人群             |
| :------------- | :----------------------- | :--------------------- | :------------------- |
| 专用工具       | 操作简单，界面友好       | 需要安装第三方软件     | 所有用户，尤其是新手 |
| 命令行工具     | 速度快，适合批量，可脚本 | 需要记命令，不友好     | 开发者、高级用户     |
| 创建快捷方式   | 最安全，不修改原文件     | 仅改快捷方式，非原文件 | 只想临时改图标的用户 |

## 结语

给程序换图标按需求选路线：想永久改变 exe 图标，用 Resource Hacker 或 rcedit；只是想让桌面图标好看，创建快捷方式改图标最稳妥；遇到属性框报「Start In 无效」，先用 PowerShell 检查快捷方式的 WorkingDirectory 字段，修好起始位置再改图标即可。
