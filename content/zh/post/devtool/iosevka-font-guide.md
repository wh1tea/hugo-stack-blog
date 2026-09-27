---
title: Iosevka Nerd Font 安装与配置
slug: iosevka-font-guide
date: 2025-08-09T14:30:00+08:00
description: 在 Windows 上下载安装 Iosevka Nerd Font，确认它的真实字体族名，配置 VS Code 与 Windows Terminal，修复终端图标乱码并启用连字。
tags:
  - iosevka
  - font
  - nerd-font
  - vscode
categories:
  - devtool
---
Iosevka 是少数可以自行定制字形的编程字体，Nerd Font 版本则补齐了终端图标。本文在 Windows 上从 Nerd Fonts 官方 release 安装它，重点解决一个容易被忽略的环节：**这个字体的族名和你想的不一样**，填错会静默回退。字体选型的一般方法见 [编程字体怎么选：从等宽到 Maple Mono](programming-font-choosing.md)。

## 选哪两个文件

Nerd Fonts 为 Iosevka 提供两个压缩包，用途不同：

| 用途           | 字体文件                              | 特点                               |
| :------------- | :------------------------------------ | ---------------------------------- |
| VS Code 代码区 | `IosevkaNerdFontMono-SemiBold.ttf`    | `Iosevka` 面向代码区               |
| 终端（pwsh）   | `IosevkaTermNerdFontMono-Regular.ttf` | `IosevkaTerm` 面向终端，字形稍紧凑 |

两者都带 `Mono` 后缀，图标为单字符宽度，不会破坏终端对齐。

## 卸载旧版

旧版 Iosevka 与 Nerd Font 版共存会让字体列表出现重名项。以管理员身份运行 PowerShell：

```powershell
$files = 'SGr-IosevkaTerm-Regular.ttc', 'SGr-Iosevka-SemiBold.ttc'
foreach ($f in $files) { Remove-Item "$env:SystemRoot\Fonts\$f" -Force -ErrorAction SilentlyContinue }

$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
@('SGr Iosevka Term (TrueType)', 'SGr Iosevka SemiBold (TrueType)') | ForEach-Object {
    Remove-ItemProperty $regPath -Name $_ -Force -ErrorAction SilentlyContinue
}
```

## 下载并安装

```powershell
cd 'D:\Downloads'
Invoke-WebRequest -Uri 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/IosevkaTerm.zip' -OutFile 'IosevkaTerm-NF.zip'
Invoke-WebRequest -Uri 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Iosevka.zip' -OutFile 'Iosevka-NF.zip'

Expand-Archive 'IosevkaTerm-NF.zip' -Force
Expand-Archive 'Iosevka-NF.zip' -Force

@(
    '.\IosevkaTerm\IosevkaTermNerdFontMono-Regular.ttf'
    '.\Iosevka\IosevkaNerdFontMono-SemiBold.ttf'
) | ForEach-Object { Start-Process $_ -Verb InstallFont }
```

`InstallFont` 动词会弹出系统安装确认，逐个确认即可。安装完成后字体文件落在 `%LOCALAPPDATA%\Microsoft\Windows\Fonts\`，注册表项写在 **HKCU** 下，而不是系统的 `HKLM`——所以验证时要查对根：

```powershell
$keys = 'HKLM:', 'HKCU:' | ForEach-Object { "$_`\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" }
foreach ($k in $keys) {
    if (Test-Path $k) {
        (Get-ItemProperty $k).PSObject.Properties |
            Where-Object { $_.Name -like '*Iosevka*' } |
            Select-Object -ExpandProperty Name
    }
}
```

按用户安装只写 `HKCU`，全局安装才写 `HKLM`。只查一个根容易误判成安装失败。另外 `Where-Object { $_ -match 'Iosevka' }` 这种写法不成立：`Get-ItemProperty` 返回单个对象，`-match` 不会逐条比对属性名，必须展开 `.PSObject.Properties` 再过滤 `Name`。

## 先确认真实族名

**这一步不能跳过。** Nerd Fonts 的字体名同时包含 nameID 1（族名，也就是应用程序真正用来匹配的值）和 nameID 16（设计师长名）。两者不一致，而配置里必须填 nameID 1。

用 `fontTools` 读一下就能看到这个差别：

```python
from fontTools.ttLib import TTFont

f = TTFont(r"C:\Users\me\AppData\Local\Microsoft\Windows\Fonts\IosevkaTermNerdFontMono-Regular.ttf", lazy=True)
for rec in f["name"].names:
    if rec.platformID == 3 and rec.nameID in (1, 16):
        print(rec.nameID, rec.toUnicode())
```

本机两个文件的实际输出：

```text
1  IosevkaTerm NFM
16 IosevkaTerm Nerd Font Mono
1  Iosevka NFM SemiBold
16 Iosevka Nerd Font Mono
```

nameID 1 才是配置里能生效的值，即 **`IosevkaTerm NFM`** 和 **`Iosevka NFM SemiBold`**。写成 nameID 16 的 `Iosevka Nerd Font Mono` 会被当成不存在的字体，直接回退到 Courier New。

不装 `fontTools` 也可以用系统 API 列出可用族名，输出的就是可以直接填的值：

```powershell
Add-Type -AssemblyName System.Drawing
(New-Object System.Drawing.Text.InstalledFontCollection).Families |
    Where-Object { $_.Name -match 'Iosevka' } |
    ForEach-Object { $_.Name }
```

`NFM` 是 Nerd Font Mono 的缩写。不同来源、不同版本的 Iosevka 构建可能给出不同族名，所以别照抄任何教程里的名字，按上面的方法打印一次再填。

## 配置 VS Code

`Ctrl + ,` 打开设置，三处都要改：

| 设置项                             | 值                                  |
| :--------------------------------- | :---------------------------------- |
| Editor: Font Family                | `'Iosevka NFM SemiBold', monospace` |
| Terminal › Integrated: Font Family | `'IosevkaTerm NFM', monospace`      |
| Editor: Font Ligatures             | 勾选启用[^1]                        |

只留目标字体加 `monospace`，不要再列 Consolas 和 Courier New——回退列表越长，族名写错时越难发现，编辑器会安静地回退到第二项。

如果用了多个 VS Code profile，注意命名 profile **不继承 Default 配置**。在 Default 的 `settings.json` 里声明这两项对所有 profile 生效，可以省掉逐个 profile 同步：

```jsonc
"workbench.settings.applyToAllProfiles": [
  "editor.fontFamily",
  "terminal.integrated.fontFamily"
],
```

`terminal.integrated.fontFamily` 默认不在列表内，漏掉它会导致编辑器字体全局生效、集成终端却仍是旧字体。

## 配置 Windows Terminal

`Ctrl + ,` → 左侧选 PowerShell → 外观 → 字体面，填入 `IosevkaTerm NFM`。

Windows Terminal 的 `profiles.defaults` 影响所有配置文件（cmd、Git Bash 等）。只改 PowerShell 一项时，切到别的标签页还是旧字体，需要在 `defaults.font.face` 里改全局值。

## 验证

改完配置要验证实际渲染效果，而不是设置里写了什么。造一个能暴露字形特征的探针文件：

```text
-> => != >= <= === :: www
Illl1 O0 rn m
中文宽度测试：中文 ab 中文 abc 等宽对齐
```

连字合并成单个符号、中文宽度恰好等于两个英文字符，说明目标字体在生效。Iosevka 是纯英文等宽字体，中文会回退到系统默认中文字体（如微软雅黑），宽度并不严格等于 2× 英文——这是它的固有限制，需要严格中英等宽得改用自带中文字形的字体。

再跑一次 Oh My Posh 预览确认图标：

```powershell
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" --preview
```

正常结果是 Git 分支显示 ` main`、文件夹显示图标、没有乱码方框。

## 术语速查

| 缩写       | 含义               | 示例                  |
| :--------- | :----------------- | :-------------------- |
| `mono`     | 等宽               | `IosevkaNerdFontMono` |
| `sans`     | 无衬线             | `Sarasa Gothic`       |
| `gothic`   | 无衬线（日式叫法） | 更纱黑体              |
| `SC`       | 简体中文           | `Sarasa Term SC`      |
| `TC`       | 繁体中文           | `Sarasa Term TC`      |
| `J`        | 日文               | `Sarasa Gothic J`     |
| `NFM`      | Nerd Font Mono     | `IosevkaTerm NFM`     |
| `ligature` | 连字               | `=>` → `⇒`            |

## 结语

Iosevka 的安装本身是解压加 `InstallFont`，真正的坑在族名：nameID 1 与 nameID 16 不同，只有前者能用，配错就静默回退。装完先打印一次可用族名再填设置，能省掉一整轮"配置了但没变化"的排查。

[^1]: [VS Code 文档 · editor.fontLigatures](https://code.visualstudio.com/docs/getstarted/settings)
