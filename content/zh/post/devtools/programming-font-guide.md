---
title: 极客级编程字体全攻略：从 Iosevka 到 Nerd Font 一步到位
slug: programming-font-guide
date: 2025-08-09T14:30:00+08:00
description: VS Code 与终端字体配置完整指南，覆盖 Iosevka Nerd Font 安装、Oh My Posh 图标修复及连字设置，三步搞定开发环境字体体验。
tags:
  - font
  - iosevka
  - nerd-font
  - windows
  - vscode
categories:
  - devtools
draft: true
---

## 为什么要用等宽字体

写代码必须用等宽字体（Monospaced Font），因为每个字符宽度相同，缩进和对齐才能准确。比例字体（Proportional Font）中 `i` 窄而 `m` 宽，会导致代码对齐错乱。

| 类型     | 英文         | 编程适用  |
| :------- | :----------- | :-------: |
| 等宽字体 | Monospaced   |  ✅ 必须  |
| 比例字体 | Proportional | ❌ 不适合 |

示例对比：

```text
等宽字体：    iiii    mmmm    1111    OOOO
比例字体：    i   mmmm     1   OOOO
```

## 衬线 vs 无衬线

| 类型     | 英文       |    编程推荐     |
| :------- | :--------- | :-------------: |
| 衬线体   | Serif      | ❌ 小字号下模糊 |
| 无衬线体 | Sans-Serif |   ✅ 清晰耐看   |

编程场景选 **无衬线 + 等宽** 组合。

## 编程字体的四个核心要求

1. **等宽**：保证缩进对齐
2. **高辨识度**：`I` `l` `1` `O` `0` 能清晰区分
3. **中英文等宽**：中文宽度恰好为英文的两倍
4. **Nerd Font 补丁**：终端图标（`` `` 等）正常显示[^1]

> 中英文等宽能否完美实现，取决于终端 / 编辑器的 fallback 字体配置。Iosevka Nerd Font Mono 本身是英文等宽字体，中文字符会回退到系统默认中文字体（如微软雅黑），宽度并不严格等于 2× 英文。如需严格中英文等宽，可改用 Sarasa Gothic（更纱黑体）等自带中文的字体。

## 终极推荐：Iosevka Nerd Font Mono

| 用途           | 字体文件                              | 显示名称                          |
| :------------- | :------------------------------------ | :-------------------------------- |
| VS Code 代码区 | `IosevkaNerdFontMono-SemiBold.ttf`    | `Iosevka Nerd Font Mono SemiBold` |
| 终端（pwsh）   | `IosevkaTermNerdFontMono-Regular.ttf` | `Iosevka Term Nerd Font Mono`     |

选择 `Mono` 版是因为图标为单宽，不会破坏终端对齐。

## 操作流程（Windows + pwsh）

### 1. 卸载旧版 Iosevka（避免冲突）

以管理员身份运行 PowerShell：

```powershell
$files = 'SGr-IosevkaTerm-Regular.ttc', 'SGr-Iosevka-SemiBold.ttc'
foreach ($f in $files) { Remove-Item "$env:SystemRoot\Fonts\$f" -Force -ErrorAction SilentlyContinue }

$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
@('SGr Iosevka Term (TrueType)', 'SGr Iosevka SemiBold (TrueType)') | ForEach-Object {
    Remove-ItemProperty $regPath -Name $_ -Force -ErrorAction SilentlyContinue
}
```

### 2. 下载并安装 Nerd Font 版 Iosevka

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

### 3. VS Code 设置（UI 方式）

1. `Ctrl + ,` 打开设置
2. 搜索 `font family`
3. 分别填入：

| 设置项                             | 值                                                     |
| :--------------------------------- | :----------------------------------------------------- |
| Editor: Font Family                | `Iosevka Nerd Font Mono SemiBold, Consolas, monospace` |
| Terminal › Integrated: Font Family | `Iosevka Term Nerd Font Mono, Consolas, monospace`     |
| Editor: Font Ligatures             | 勾选启用                                               |

### 4. Windows Terminal 设置

1. `Ctrl + ,` → 左侧选 **PowerShell**
2. **外观** → **字体面** → 输入：

```text
Iosevka Term Nerd Font Mono
```

## 验证配置

```powershell
# 查看已安装的 Iosevka Nerd 字体
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' | Where-Object { $_ -match 'Iosevka.*Nerd' }

# 预览 Oh My Posh 主题
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" --preview
```

正常结果：Git 分支显示 ` main`，文件夹显示 ``，无 `` 乱码。

## 术语速查表

| 缩写       | 含义               | 示例                  |
| :--------- | :----------------- | :-------------------- |
| `mono`     | 等宽               | `IosevkaNerdFontMono` |
| `sans`     | 无衬线             | `Sarasa Gothic`       |
| `gothic`   | 无衬线（日式叫法） | 更纱黑体              |
| `SC`       | 简体中文           | `Sarasa Term SC`      |
| `TC`       | 繁体中文           | `Sarasa Term TC`      |
| `J`        | 日文               | `Sarasa Gothic J`     |
| `ligature` | 连字               | `=>` → `⇒`            |

## 结语

按上述步骤操作后，开发环境字体配置为：

- VS Code 代码区：`Iosevka Nerd Font Mono SemiBold`
- 终端：`Iosevka Term Nerd Font Mono Regular`
- Oh My Posh 图标全部正常
- 连字（`=>` → `⇒`）优雅显示[^2]

整个过程约 3 分钟，建议立即执行。[^3]

[^1]: [Nerd Fonts 官网](https://www.nerdfonts.com)

[^2]: [编程字体推荐 - HowieZhao](https://howiezhao.github.io/2018/09/23/code-font/)

[^3]: [知乎：有哪些适合编程的字体？](https://www.zhihu.com/question/32058777/answer/3561707776)
