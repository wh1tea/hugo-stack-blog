---
title: 编程字体怎么选：从等宽到 Maple Mono
slug: programming-font-choosing
date: 2026-09-22T12:00:00+08:00
description: 从字体分类讲清编程字体的硬指标，以 Maple Mono NF CN 为例完成 Windows 安装、族名确认与 VS Code／终端配置，并给出族名填错导致静默回退的排查方法。
tags:
  - font
  - vscode
  - windows
  - pwsh
  - configuration
categories:
  - devtool
---

编辑器默认字体把 `I` `l` `1` 显示成几乎一样的竖线，字体名少写一个词就整段回退到 Courier New——这两个问题的成因不同，前者是选型，后者是配置。本文先讲清编程字体的筛选指标，再以 Maple Mono NF CN 为例走完安装、确认族名、配置编辑器的完整流程。

## 字体分类里和编程有关的部分

字体按字形结构分成几大类，其中只有两类和写代码直接相关。

**衬线体（serif）** 笔画末端有装饰性的"脚"，如 Times New Roman、宋体。**无衬线体（sans-serif）** 没有这些装饰，如 Arial、微软雅黑。衬线体的装饰笔画在小字号、高密度屏幕上会糊成一片，所以代码编辑器基本只用无衬线体。

按字符宽度是否一致，字体又分为**等宽（monospace）** 和**比例（proportional）**。比例字体里 `i` 比 `W` 窄得多，一段代码缩进后列与列对不齐；等宽字体每个字符占同样的水平宽度，缩进和对齐才有意义。这是编程字体必须是等宽的根本原因。

除这两组对立概念外，还有两个常见后缀：

| 后缀               | 含义                | 影响                                   |
| :----------------- | :------------------ | :------------------------------------- |
| `Mono`             | 等宽                | 图标按单字符宽度渲染，不破坏终端对齐   |
| `NF` / `Nerd Font` | 打过 Nerd Font 补丁 | 内置私有区图标，终端提示符不再显示方框 |

## 编程字体的筛选标准

在上述分类基础上，一个适合编程的字体还要满足几条可验证的指标。

**字符辨识度**：`I` `l` `1`、`O` `0`、`rn` 与 `m` 必须一眼可分。这是编程字体最核心的指标，直接决定读代码时会不会看错变量名。

**连字（ligature）**：把 `=>`、`!=`、`>=` 这类多字符运算符合并渲染成单个符号。连字是可选偏好，但它要求编辑器显式开启，且只有支持连字的字体才有。

**中文宽度**：中文字符宽度应等于两个英文字符宽度。多数英文等宽字体的中文靠系统回退字体渲染，宽度并不严格对齐，混排时表格和注释会错位。需要严格对齐就得选自带中文的字体。

**Nerd Font 补丁**：终端提示符（如 Oh My Posh）依赖私有区图标字符，没有补丁就会渲染成方框。

**字重齐全**：至少要有 Regular 和 Bold，否则语法高亮里的粗体关键词会回退到合成粗体，边缘发虚。

指标再多也不如直接看字形。[programmingfonts.org](https://www.programmingfonts.org/) 把常见编程字体集中在一处，可逐一切换预览、改字号行高与主题[^1]；[Google Fonts](https://fonts.google.com/) 覆盖开源字体更全，Noto 系列、思源系列都在上面，能在线预览再决定是否下载[^2]。

## 常见候选

Consolas 和 Courier New 是 Windows 自带，但都没有连字和 Nerd Font 图标。Cascadia Code 自带连字，图标仍需额外补丁。Iosevka 系列可定制性最强，但默认不带中文，中文回退后宽度对不齐（安装与配置见 [Iosevka Nerd Font 安装与配置](iosevka-font-guide.md)）。Sarasa Gothic（更纱黑体）自带中文且宽度对齐，代价是字形偏圆、连字少。

Maple Mono NF CN 同时满足上面全部指标：等宽、带连字、内置 Nerd Font 图标，且 `CN` 版本自带中文字形，中英文宽度严格成 2:1。代价是体积——每个字重约 20 MB，16 个字重合计约 330 MB，首次加载会有一次性字体缓存开销。

### 中文阅读场景：等宽不是最优

上面所有指标都指向等宽，但等宽中文字体有一个绕不开的代价：为了让缩进和表格对齐，中文字形必须占满 **2×** 英文宽度。同样的字号下，一行能放下的汉字因此少了很多。字形也在起作用：等宽字体的拉丁字母本身偏宽，一段纯英文文字同样比比例字体占更多横向空间。

不想被这个约束绑住时，可以选**比例中文字体**。Noto Sans SC 是个典型选择，它是 Adobe 与 Google 合作设计的[思源黑体](https://en.wikipedia.org/wiki/Source_Han_Sans)（Source Han Sans）的 Google 发行名——同一套设计、不同发布名，简体中文子集在 Google Fonts 上就叫 Noto Sans SC[^2]。实测中英宽度比（`中` 宽度 ÷ `m` 宽度）：

| 字体             | 中英宽度比 | 字形特点       | 适用场景             |
| :--------------- | ---------: | :------------- | :------------------- |
| Noto Serif SC    |       1.04 | 衬线           | 纸感阅读             |
| Microsoft YaHei  |       1.07 | 黑体，系统自带 | 通用阅读             |
| Noto Sans SC     |       1.13 | 黑体           | 屏幕阅读、中英混排   |
| LXGW WenKai Mono |       2.00 | 楷体           | 长文耐读，但不省空间 |
| Maple Mono NF CN |       2.00 | 等宽，带连字   | 代码对齐             |

后两行都是等宽、中英比 2.00，**换用它们不会提高信息密度** ，差别只在字形观感：霞鹜文楷是楷体骨架，Maple Mono 是几何黑体、带连字。靠密度取胜的是前三行比例字体。

比例字体比等宽每行多容纳约 40% 的汉字，代价是缩进、表格与代码列全部失准，连字也没有。个人偏好是**代码用等宽、中文长文用比例**：VS Code 可以在 profile 的 `[markdown]` 块里单独覆盖字体，只让 Markdown 走比例字体，其余语言文件不受影响。终端与代码保持一致用等宽，中文在终端里宽度对不齐也不影响使用。

如果只需要英文环境，`Maple Mono NF`（不带 `CN`）是同一字体的英文版，文件小得多。

## 用 Scoop 安装

Scoop 是 Windows 上的命令行包管理器，用它装字体比手动下载解压省事，卸载时也会自动清掉注册表项。先安装 Scoop：

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

官方 nerd-fonts bucket 在国内网络下可能连接失败：

```text
ERROR 'https://github.com/matthewjberger/scoop-nerd-fonts' doesn't look like a valid git repository
fatal: unable to access '...': Recv failure: Connection was reset
```

改用国内镜像 bucket，再装字体：

```powershell
scoop bucket add cn https://gh-proxy.org/https://github.com/lvyuemeng/scoop-cn
scoop install Maple-Mono-NF-CN
```

## 确认字体真的装上了

scoop 默认按**当前用户**安装字体（Windows 10 1809 及以后支持），字体文件放在 `%LOCALAPPDATA%\Microsoft\Windows\Fonts\`，注册表项写在 **HKCU**，而不是系统的 `HKLM`。只查 `HKLM` 会得到空结果，让人误判成没装上：

```powershell
$keys = 'HKLM:', 'HKCU:' | ForEach-Object { "$_`\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" }
foreach ($k in $keys) {
    if (Test-Path $k) {
        (Get-ItemProperty $k).PSObject.Properties |
            Where-Object { $_.Name -like '*Maple*' } |
            Select-Object -ExpandProperty Name
    }
}
```

有 16 行输出（每个字重一项）说明注册成功。两个根都要查，是因为全局安装（`scoop install -g`）会写 `HKLM`，按用户安装写 `HKCU`。

注意 `Where-Object { $_ -match 'Maple' }` 这种写法**不成立**：`Get-ItemProperty` 返回的是单个对象，把它交给 `-match` 并不会逐条比对属性名。必须显式展开 `.PSObject.Properties` 再过滤 `Name`。

## 填对字体族名

**字体文件名和字体族名（family name）是两回事**，配置里要填的是族名。填错不会报错，编辑器会静默回退到列表里下一个可用字体——表现是"设置了但没变化"。

以本机安装的字体为例，几个文件与真实族名的对应关系是：

| 文件名                           | 真实族名           |
| :------------------------------- | :----------------- |
| `MapleMono-NF-CN-Regular.ttf`    | `Maple Mono NF CN` |
| `MapleMono-NF-CN-Bold.ttf`       | `Maple Mono NF CN` |
| `MapleMono-NF-CN-Italic.ttf`     | `Maple Mono NF CN` |
| `MapleMono-NF-CN-ExtraLight.ttf` | `Maple Mono NF CN` |

字重与斜体都不是族名的一部分，它们由 `editor.fontWeight` 之类的设置选择，所以 16 个文件只对应一个族名。同理，填 `Maple Mono NF`（少一个 `CN`）是无效名。

确认族名的可靠办法是让 GDI 解析一次，看它是否原样返回。返回别的名字就说明发生了回退：

```powershell
Add-Type -AssemblyName System.Drawing
(New-Object System.Drawing.Text.InstalledFontCollection).Families |
    Where-Object { $_.Name -match 'Maple' } |
    ForEach-Object { $_.Name }
```

输出里出现的名字就是可以直接填进配置的值。把 `Maple` 换成 `Iosevka`、`Sarasa` 等关键词，同样适用于其它字体。

## 配置 VS Code

`Ctrl + ,` 打开设置，把两个字体项都改成族名加 `monospace` 兜底：

| 设置项                             | 值                              |
| :--------------------------------- | :------------------------------ |
| Editor: Font Family                | `'Maple Mono NF CN', monospace` |
| Terminal › Integrated: Font Family | `'Maple Mono NF CN', monospace` |

只留目标字体加 `monospace`，不要继续列 Consolas 和 Courier New。回退列表越长，字体名写错时越难发现——它会安静地回退到列表第二项，看起来像"配置已生效"。

连字要在编辑器里单独开启。VS Code 默认不启用，需要显式设置[^3]：

```jsonc
"editor.fontLigatures": true,
```

有些字体把连字编译进字形（Maple Mono 的 `config.json` 里 `ligature: true`），即使不开这个选项也能看到部分连字，但依赖默认行为不如显式开启可靠。

### 多个 profile 时改哪里

VS Code 的命名 profile（Python、Java、Markdown 等）**不继承 Default 配置**，只在 Default 里改字体，切到别的 profile 就会失效。逐个 profile 重复填一遍很容易漏，于是有了 `workbench.settings.applyToAllProfiles`——它把 Default 里列出的设置**强推到所有 profile**[^4]：

```jsonc
"workbench.settings.applyToAllProfiles": [
  "editor.fontFamily",
  "terminal.integrated.fontFamily"
],
```

这个列表是把双刃剑。它在列表里包含 `editor.fontFamily` 时，**任何 profile 都不能再有自己的编辑器字体**：你在 Default 设为 Noto Sans SC，即使某个 profile 的 `settings.json` 里写着 Maple Mono，切过去看到的仍然是 Noto Sans SC。表现是"某个 profile 单独改了字体却完全不生效"，很容易误判成配置没保存或 profile 没生效。

想让不同 profile 用不同字体，就得把 `editor.fontFamily` 从列表里移除，只留终端字体：

```jsonc
"workbench.settings.applyToAllProfiles": [
  "terminal.integrated.fontFamily"
],
```

之后分工就自由了：Default 与代码 profile 用 `'Maple Mono NF CN', monospace`，Markdown profile 在自己的 `[markdown]` 块里覆盖成 `'Noto Sans SC', monospace`：

```jsonc
// Markdown profile 的 settings.json
"[markdown]": {
  "editor.fontFamily": "'Noto Sans SC', monospace"
},
```

这样 Markdown 文档走比例中文字体、信息密度最高，其余语言文件与终端保持等宽对齐。终端字体留在 `applyToAllProfiles` 里统一用等宽——终端要的是列对齐，不需要中文比例字体。

`applyToAllProfiles` 只作用于**键名完全相同**的设置。`[markdown].editor.fontFamily` 是 `[markdown]` 作用域下的独立键，不叫 `editor.fontFamily`，所以它不受这个列表控制，可以在单个 profile 里自由覆盖。

## 配置 Windows Terminal

`Ctrl + ,` → 左侧选 PowerShell → 外观 → 字体面，填入 `Maple Mono NF CN`。

Windows Terminal 的 `profiles.defaults` 也会影响其它配置文件（cmd、Git Bash 等）。只改了 PowerShell 一项时，切到别的标签页还是旧字体，需要按需在 `defaults.font.face` 里改全局默认值。

## 验证字体已生效

改完配置要验证的是"实际渲染用的哪个字体"，而不是"设置里写了什么"。最直接的办法是造一个能暴露字形特征的探针文件，比如：

```text
-> => != >= <= === :: www
Illl1 O0 rn m
中文宽度测试：中文 ab 中文 abc 等宽对齐
```

在编辑器里打开它，看两点：连字是否合并成单个符号（`=>` 呈现为 `⇒` 的形态），中文字符宽度是否恰好等于两个英文字符。都是，就说明目标字体在生效；如果 `->` 是两个独立字符、中文宽度不是 2:1，说明配置回退到了别的字体，回去用上面 `InstalledFontCollection` 的方法核对族名。

跑一次 Oh My Posh 预览可以确认图标：

```powershell
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" --preview
```

Git 分支、文件夹图标正常显示、没有方框，字体配置就算完成。

## 结语

编程字体的硬指标是等宽、字符辨识度和 Nerd Font 图标，中文对齐则要求字体自带中文字形。配置环节真正的坑不是选型而是族名：文件名和族名不一致，写错就静默回退，所以装完先用 `InstalledFontCollection` 打印一次真实族名，再把它填进设置。多 profile 场景下把 `terminal.integrated.fontFamily` 一并加进 `applyToAllProfiles`，省掉逐 profile 同步的麻烦。

[^1]: [Programming Fonts · Test Drive](https://www.programmingfonts.org/)
[^2]: [Google Fonts](https://fonts.google.com/)
[^3]: [VS Code 文档 · editor.fontLigatures](https://code.visualstudio.com/docs/getstarted/settings)
[^4]: [VS Code 文档 · workbench.settings.applyToAllProfiles](https://code.visualstudio.com/docs/configure/settings#_settings-precedence)
