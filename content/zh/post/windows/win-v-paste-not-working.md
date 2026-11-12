---
title: Win+V 只复制不粘贴的排查与修复
slug: win-v-paste-not-working
date: 2026-11-11T00:30:00+08:00
description: Win+V 能选中历史、内容也已进剪贴板却不粘贴：先用钩子统计确认面板没发出粘贴动作，再重注册输入体验的组件包修好
tags:
  - troubleshooting
  - windows
  - clipboard
categories:
  - windows
draft: true
---

Win+V 能打开历史、能选中，选中项也确实进了剪贴板，但点选或回车不会把它送到光标处，还得再按一次 Ctrl+V。这不是权限或第三方软件拦截，而是 Windows「输入体验」组件没有发出粘贴动作；下面给自查、诊断脚本和修法，整套流程在一台 Windows 11 26H2（`build 26300.9818`）上验证过一次。

## 先判断是不是同一个毛病

三条命令都在 **Windows PowerShell**（开始菜单里那个）里跑。PowerShell 7 没有 Appx 模块，第二条会报找不到命令。

```powershell
(Get-AppxPackage MicrosoftWindows.Client.CBS).Version
Get-ItemProperty 'HKCU:\Software\Microsoft\Clipboard' -Name EnableClipboardHistory
Get-Clipboard
```

| 观察 | 正常值 | 说明 |
| :--- | :--- | :--- |
| 包版本 | 形如 `1000.26100.x` | 这是 Win+V 面板所在的「功能体验包」 |
| `EnableClipboardHistory` | `1` | 剪贴板历史开关 |
| 选中一条后 `Get-Clipboard` | 返回那条内容 | 复制这一步是好的 |

再用两次手工操作确认：按 Win+V 能列出历史，点一条后光标处没有内容。三条都对上才往下走；面板打不开、或复制本身就失败，不属于这类问题。

## 原因

面板不抢焦点：按 Win+V 后前台窗口不变，按键由它临时挂的键盘钩子收走。选中一条时它本该做两件事——把内容写进剪贴板、合成一次 Ctrl+V，实测第二步没有发生。

两个名词：

- `TextInputHost.exe`：Windows「输入体验」的宿主进程，Win+. 表情面板和 Win+V 剪贴板面板都由它渲染。
- 功能体验包（`MicrosoftWindows.Client.CBS`）：随系统更新分发的组件包，输入体验的代码在里面，版本号形如 `1000.26100.x`。

能定位到这一步，靠的是下一节的注入统计。

## 诊断：面板到底有没有发按键

判据是键盘钩子事件里的 `LLKHF_INJECTED` 标志：它标记这个按键是人按的还是程序模拟的。存成 `probe.ps1`，跑 60 秒，期间按 Win+V、点一条历史：

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

| 输出 | 含义 | 下一步 |
| :--- | :--- | :--- |
| `injected=0`，`real` 有值 | 面板没有发出任何模拟按键 | 按下面的处理步骤修 |
| `injected` 大于 0 | 按键发出去了，但被吞掉 | 查第三方键盘钩子与安全软件，不是本文这条路径 |

每 0.8 秒重挂一次钩子是这个脚本的关键：低层键盘钩子按安装顺序排队，**后装的排在链首**，面板打开时会挂自己的钩子，不重挂就会被它压住，看不到它自己发出的按键。

再补一个不用脚本的对照：按 Win+. 选个 emoji，看能不能插进同一个输入框。能插进去说明输入体验的注入通道是好的，问题只在粘贴这一步；emoji 也插不进去，说明组件整体坏了，重注册之后还要再跑系统文件检查。

## 处理步骤

Windows PowerShell（管理员）里执行：

```powershell
$svc = Get-Service 'cbdhsvc_*' | Select-Object -First 1
Restart-Service -Name $svc.Name -Force
Get-Process TextInputHost -ErrorAction SilentlyContinue | Stop-Process -Force
$cbs = Get-AppxPackage MicrosoftWindows.Client.CBS
Add-AppxPackage -Register (Join-Path $cbs.InstallLocation 'AppxManifest.xml') -DisableDevelopmentMode
```

然后**重启**。三件事分别是：重启剪贴板用户服务、结束输入体验进程、重新注册功能体验包（重建它的注册状态）。

只重启 explorer 或 `TextInputHost` 不够——故障期间这两个进程都单独重启过，现象没变；重注册加重启才恢复。

## 验证

重启后按 Win+V 点一条历史，内容应直接出现光标处；再按一次回车确认。两条都正常即修复。

## 修不好时

先做一次系统文件检查，再考虑覆盖安装（设置 → 系统 → 恢复 → 使用 Windows 更新修复问题 → 立即重新安装，文件和已装应用会保留）：

```powershell
sfc /scannow
```

等不及排查就用第三方剪贴板管理器（Ditto、CopyQ），它们靠自己的模拟按键粘贴，不依赖输入体验。同症状在微软 Q&A 里有报告，但 `sfc`、`DISM`、重注册全部应用包这套通用流程并不总能修好[^1]。

## 结语

面板类故障先分清「动作没发出」还是「发出后被拦」：注入统计加同组件的相邻功能做对照，两者都正常就基本锁定组件状态，重注册对应包比逐项改设置有效。

[^1]: [win10 win+V 無法貼上歷史紀錄 - Microsoft Q&A](https://learn.microsoft.com/zh-hk/answers/questions/3943900/win10-win-v?orderby=oldest&page=1)
