---
title: Win+V 只复制不粘贴的排查与修复
slug: win-v-paste-not-working
date: 2026-11-11T00:30:00+08:00
description: Win+V 能选中历史、内容也已进剪贴板却不粘贴：先确认面板是否发出粘贴动作，再重注册输入体验的组件包修好
tags:
  - troubleshooting
  - clipboard
  - shortcut
categories:
  - windows
---

`Win+V` 能打开历史、能选中，选中项也确实进了剪贴板，但点选或回车不会把它送到光标处，还得再按一次 `Ctrl+V`。这不是权限或第三方软件拦截，而是 Windows「输入体验」（负责 `Win+.` 表情面板和 `Win+V` 剪贴板面板的系统组件）没有发出粘贴动作。下面用包版本、剪贴板历史开关和 `Get-Clipboard` 自查，用脚本统计模拟按键区分“没发出”和“被拦截”，再重注册输入体验的组件包修复；整套流程在一台 Windows 11 26H2（`build 26300.9818`）上验证过一次。

**`Win+V` 选中一条历史后，正常应该自动做两步：①把内容写进剪贴板；②替你模拟按一次 `Ctrl+V`。这个故障是第①步成功、第②步没发生。**

## 问题

```powershell
# 查 Win+V 面板所属组件包的版本
# 正常应形如 1000.26100.x
(Get-AppxPackage MicrosoftWindows.Client.CBS).Version
# 查当前用户的剪贴板历史开关
# 正常输出里应有 EnableClipboardHistory : 1
Get-ItemProperty 'HKCU:\Software\Microsoft\Clipboard' -Name EnableClipboardHistory
# 读当前剪贴板里的文本
Get-Clipboard
```

| 观察                       | 正常值              | 说明                                    |
| :------------------------- | :------------------ | :-------------------------------------- |
| 包版本                     | 形如 `1000.26100.x` | 这是 `Win+V` 面板所在的组件包           |
| `EnableClipboardHistory`   | `1`                 | 剪贴板历史开关，若为 `0` 按下方路径打开 |
| 选中一条后 `Get-Clipboard` | 返回那条内容        | 复制这一步是好的                        |

```text
Win+I > System > Clipboard > Clipboard history
```

发现按 `Win+V` 能列出历史，点一条 / 回车后光标处却没有内容。

## 原因

面板不抢焦点：按 `Win+V` 后前台窗口不变，按键由它临时挂的键盘钩子（低层键盘钩子：程序在按键到达目标窗口前先收到事件，可被脚本统计）收走。选中一条时它本该做两件事——把内容写进剪贴板、模拟一次 `Ctrl+V`，实测第二步没有发生。

两个名词：

- `TextInputHost.exe`：Windows「输入体验」的宿主进程，打开 `Win+.` 或 `Win+V` 能看到的面板由它渲染。
- 功能体验包（`MicrosoftWindows.Client.CBS`）：随系统更新分发的组件包，输入体验的代码在里面，版本号形如 `1000.26100.x`。用 `(Get-AppxPackage MicrosoftWindows.Client.CBS).Version` 能查到它。

能定位到这一步，靠的是键盘钩子统计。

## 诊断：面板到底有没有发按键

按 `Win+.` 选个 emoji，看能不能插进同一个输入框。能插进去说明输入体验的模拟按键通道是好的，问题只在粘贴这一步；emoji 也插不进去，说明组件整体坏了，重注册之后还要再跑系统文件检查。

再补一个用脚本的对照：判据是键盘钩子事件里的 `LLKHF_INJECTED` 标志：它标记这个按键是人按的还是程序模拟的。存成 `probe.ps1`，跑 60 秒，期间按 `Win+V`、点一条历史：

```powershell
param([int]$Seconds = 60)
Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class KbdProbe {
  const int WH_KEYBOARD_LL = 13;
  delegate IntPtr Proc(int n, IntPtr w, IntPtr l);
  [StructLayout(LayoutKind.Sequential)] struct K { public uint vk, scan, flags, time; public IntPtr extra; }
  [DllImport("user32.dll")] static extern IntPtr SetWindowsHookEx(int id, Proc p, IntPtr m, uint t);
  [DllImport("user32.dll")] static extern bool UnhookWindowsHookEx(IntPtr h);
  [DllImport("user32.dll")] static extern IntPtr CallNextHookEx(IntPtr h, int n, IntPtr w, IntPtr l);
  static Proc _p = Call; static IntPtr _h;
  public static int Injected, Real;
  static IntPtr Call(int n, IntPtr w, IntPtr l) {
    if (n >= 0) {
      var k = (K)Marshal.PtrToStructure(l, typeof(K));
      if ((k.flags & 0x10) != 0) Injected++; else Real++;
    }
    return CallNextHookEx(_h, n, w, l);
  }
  public static void Hook() { if (_h != IntPtr.Zero) UnhookWindowsHookEx(_h); _h = SetWindowsHookEx(WH_KEYBOARD_LL, _p, IntPtr.Zero, 0); }
  public static void Unhook() { if (_h != IntPtr.Zero) { UnhookWindowsHookEx(_h); _h = IntPtr.Zero; } }
}
"@
$end = (Get-Date).AddSeconds($Seconds)
[KbdProbe]::Hook()
while ((Get-Date) -lt $end) {
  [KbdProbe]::Hook()
  [System.Windows.Forms.Application]::DoEvents()
  Start-Sleep -Milliseconds 800
}
[KbdProbe]::Unhook()
"real={0} injected={1}" -f [KbdProbe]::Real, [KbdProbe]::Injected
```

| 输出                      | 含义                     | 下一步                                       |
| :------------------------ | :----------------------- | :------------------------------------------- |
| `injected=0`，`real` 有值 | 面板没有发出任何模拟按键 | 按下面的处理步骤修                           |
| `injected` 大于 0         | 按键发出去了，但被吞掉   | 查第三方键盘钩子与安全软件，不是这个故障路径 |

每 0.8 秒重挂一次钩子是这个脚本的关键：低层键盘钩子按安装顺序排队，**后装的排在链首**，面板打开时会挂自己的钩子，不重挂就会被它压住，看不到它自己发出的按键。

## 处理步骤

Windows PowerShell（管理员）里执行：

```powershell
# 1. 找到当前用户的剪贴板历史服务，名字通常像 cbdhsvc_xxxx
$svc = Get-Service 'cbdhsvc_*' | Select-Object -First 1

# 2. 强制重启这个服务
Restart-Service -Name $svc.Name -Force

# 3. 结束“输入体验”宿主进程；系统会自动重新拉起它
Get-Process TextInputHost -ErrorAction SilentlyContinue | Stop-Process -Force

# 4. 找到功能体验包 MicrosoftWindows.Client.CBS
$cbs = Get-AppxPackage MicrosoftWindows.Client.CBS

# 5. 用包安装目录里的 AppxManifest.xml 重新注册它
#    不下载、不删除文件；-DisableDevelopmentMode 表示按非开发模式注册
Add-AppxPackage -Register (Join-Path $cbs.InstallLocation 'AppxManifest.xml') -DisableDevelopmentMode
```

然后**重启**。三件事分别是：重启剪贴板用户服务、结束输入体验进程、重新注册功能体验包（重建它的注册状态）。

只重启资源管理器（`explorer.exe`）或 `TextInputHost.exe` 不够——故障期间这两个进程都单独重启过，现象没变；重注册加重启才恢复。

## 验证

重启后按 `Win+V` 点一条历史，内容应直接出现光标处；再按一次回车确认。两条都正常即修复。

## 修不好时

先做一次系统文件检查：

```powershell
# 系统文件检查器，扫描并修复系统文件
sfc /scannow
```

还修不好再考虑覆盖安装，文件和已装应用会保留：

```text
设置 > 系统 > 恢复 > 使用 Windows 更新修复问题 > 立即重新安装
```

等不及排查就用第三方剪贴板管理器（Ditto、CopyQ），它们靠自己的模拟按键粘贴，不依赖输入体验。同症状在微软 Q&A 里有报告，但 `sfc`、`DISM`、重注册全部应用包这套 Windows 系统“万金油”修复方法并不总能修好[^1]。

## 结语

面板类故障先分清「动作没发出」还是「发出后被拦」：键盘钩子统计显示 `injected=0`，且同组件的 emoji 注入正常，就基本锁定组件状态；重注册对应包比逐项改设置有效。

[^1]: [Microsoft Q&A report on Win+V paste failure](https://learn.microsoft.com/zh-hk/answers/questions/3943900/win10-win-v?orderby=oldest&page=1)

## 附件 fix-clipboard-paste.ps1

```powershell
# requires -Version 5.1
<#
  Win+V 剪贴板面板"只复制、不粘贴"修复脚本
  必须在【管理员】PowerShell 中运行

  用法：
    powershell -NoProfile -ExecutionPolicy Bypass -File .\fix-clipboard-paste.ps1
    powershell -NoProfile -ExecutionPolicy Bypass -File .\fix-clipboard-paste.ps1 -SkipHealth   # 跳过 DISM/SFC
#>
[CmdletBinding()]
param([switch]$SkipHealth)

$ErrorActionPreference = 'Continue'
function Step($t) { Write-Host "`n=== $t ===" -ForegroundColor Cyan }

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
  Write-Host "需要管理员权限：请在管理员终端里重新运行本脚本。" -ForegroundColor Red
  exit 1
}

Step "0/5 系统信息"
$cv = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
"版本: {0} build {1}.{2}" -f $cv.DisplayVersion, $cv.CurrentBuild, $cv.UBR
$cbs = Get-AppxPackage -Name MicrosoftWindows.Client.CBS
"Windows 功能体验包 (CBS): {0}" -f $(if ($cbs) { $cbs.Version } else { "未找到" })

Step "1/5 重启剪贴板用户服务 (Clipboard User Service)"
$svc = Get-Service 'cbdhsvc_*' | Select-Object -First 1
if ($svc) {
  "服务: {0}" -f $svc.Name
  Restart-Service -Name $svc.Name -Force
  Start-Sleep -Seconds 2
  "状态: {0}" -f (Get-Service $svc.Name).Status
}

Step "2/5 结束输入体验进程 (TextInputHost)"
Get-Process -Name TextInputHost -ErrorAction SilentlyContinue | ForEach-Object {
  "结束 pid {0}" -f $_.Id
  Stop-Process -Id $_.Id -Force
}
Start-Sleep -Seconds 2

Step "3/5 重新注册 Windows 功能体验包"
if ($cbs) {
  $manifest = Join-Path $cbs.InstallLocation 'AppxManifest.xml'
  if (Test-Path $manifest) {
    "注册: {0}" -f $manifest
    Add-AppxPackage -Register $manifest -DisableDevelopmentMode -ErrorAction Continue
  } else {
    "找不到 AppxManifest.xml，跳过"
  }
}

Step "4/5 重置输入体验的应用设置 (settings.dat)"
$settings = Join-Path $env:LOCALAPPDATA 'Packages\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\Settings\settings.dat'
if (Test-Path $settings) {
  $bak = "$settings.bak-$(Get-Date -Format yyyyMMddHHmmss)"
  try {
    Rename-Item -LiteralPath $settings -NewName (Split-Path $bak -Leaf) -Force -ErrorAction Stop
    "已备份为: {0}" -f $bak
  } catch {
    "重命名失败（进程仍占用？）: {0}" -f $_.Exception.Message
  }
} else {
  "未找到 settings.dat，跳过"
}

if (-not $SkipHealth) {
  Step "5/5 系统组件健康检查（DISM + SFC，10-30 分钟，可 Ctrl+C 跳过）"
  Write-Host ">> DISM /Online /Cleanup-Image /RestoreHealth" -ForegroundColor Yellow
  DISM.exe /Online /Cleanup-Image /RestoreHealth
  Write-Host ">> sfc /scannow" -ForegroundColor Yellow
  sfc.exe /scannow
} else {
  Step "5/5 已跳过 DISM/SFC"
}

Write-Host "`n全部步骤完成。请【重启】，然后测试：输入框 → Win+V → 点/回车一条历史。" -ForegroundColor Green
Write-Host "若仍然只复制不粘贴，说明是该 Windows 版本输入体验组件的缺陷，下一步只能做覆盖安装修复（保留文件和应用）。" -ForegroundColor Yellow
```
