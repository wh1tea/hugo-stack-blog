---
title: pwsh 里 conda activate 后 conda 命令集体报错：排查与修复全记录
slug: conda-pwsh-activate-fix
date: 2026-08-22T07:46:42+08:00
description: "在 pwsh 7 中执行 conda activate py_env 后，提示符不变、所有 conda 子命令报 invalid choice: ''。本文完整记录从现象、排查、验证到修复的全过程，并讲透 pwsh 7 原生参数传递的坑。"
tags:
  - conda
  - powershell
  - python
  - windows
  - troubleshooting
categories:
  - python
  - windows
---

在 Windows 上用 PowerShell 7（pwsh）管理 conda 环境时，执行 `conda activate py_env` 后出现两个诡异现象：提示符没有出现 `(py_env)`，紧接着执行任何 conda 子命令（`conda env list`、`conda install` 等）都报 `invalid choice: ''`。

表面看像是「激活失败」，但排查后发现激活其实生效了，真正的坑在 conda 的 PowerShell 激活脚本和 pwsh 7 的原生参数传递方式上。本文完整记录这次 bug 从出现、排查、验证到修复的全流程，读完你不仅能修好同类问题，还能掌握一套可复用的调试方法。

## 问题现象

环境：Windows 11 + Anaconda（`D:\ProgramData\anaconda3`，conda 24.11.3）+ PowerShell 7.6.5，conda 环境 `py_env` 位于 `C:\Users\wbq20\.conda\envs\py_env`。

在 pwsh 中依次执行：

```powershell
conda activate py_env
```

没有任何报错，但提示符毫无变化。紧接着：

```powershell
conda env list
```

输出：

```text
usage: conda-script.py [-h] [-v] [--no-plugins] [-V] COMMAND ...
conda-script.py: error: argument COMMAND: invalid choice: '' (choose from 'activate', 'clean', 'commands', 'compare', 'config', 'create', 'deactivate', 'env', 'export', 'info', 'init', 'install', 'list', 'notices', 'package', 'build', 'content-trust', 'convert', 'debug', 'develop', 'doctor', 'index', 'inspect', 'metapackage', 'render', 'skeleton', 'token', 'server', 'repo', 'pack', 'remove', 'uninstall', 'rename', 'run', 'search', 'update', 'upgrade')
```

注意一个细节：`conda env list` 在 `conda activate py_env` **之前**是正常的，activate 之后才坏。这个「先好后坏」的时序，是本次排查最重要的线索。

## 排查第一步：激活到底生效没有

先排除最基础的问题——环境是否存在：

```powershell
conda env list
```

输出显示 `py_env` 确实存在。再看 Python 有没有切换：

```powershell
python -c "import sys; print(sys.prefix)"
# C:\Users\wbq20\.conda\envs\py_env
```

Python 已经指向 `py_env`！说明 **activate 本身是生效的**——环境变量、PATH、Python 解释器都切过去了。

> 关键认知：问题不是「激活失败」，而是「激活之后 conda 的调用链损坏了」。

## 顺着报错找线索

`invalid choice: ''` 是 conda 的命令行解析器（argparse）报的：它收到一个**空字符串**作为子命令，不认。问题变成：**谁往 conda.exe 传了空字符串？**

在 pwsh 里，`conda` 并不是一个可执行文件，而是一个别名：

```powershell
Get-Command conda

CommandType     Name      Version  Source
-----------     ----      -------  ------
Alias           conda     0.0      Invoke-Conda
```

`Invoke-Conda` 来自 Anaconda 自带的 PowerShell 模块 `Conda.psm1`（`D:\ProgramData\anaconda3\shell\condabin\Conda.psm1`）。它由 pwsh 的 profile 里这段 hook 加载：

```powershell
# conda.exe shell.powershell hook 的输出（节选）
$Env:CONDA_EXE = "D:\ProgramData\anaconda3\Scripts\conda.exe"
$Env:_CE_M = $null
$Env:_CE_CONDA = $null
Import-Module "$Env:_CONDA_ROOT\shell\condabin\Conda.psm1"
```

打开模块源码看 `Invoke-Conda`，普通子命令是这么透传的：

```powershell
function Invoke-Conda() {
    ...
    default {
        # 普通子命令原样透传给 conda.exe
        & $Env:CONDA_EXE $Env:_CE_M $Env:_CE_CONDA $Command @OtherArgs;
    }
}
```

注意它无条件传了两个变量：`$Env:_CE_M` 和 `$Env:_CE_CONDA`。这正是 hook 里初始化为 `$null` 的两个变量。而 `conda activate` 走的是模块里的 `Enter-CondaEnvironment`，它把激活脚本的输出用 `Invoke-Expression` 应用到当前会话。于是对比 activate 前后的变量：

| 变量 | activate 前 | activate 后 |
| :--- | :--- | :--- |
| `_CE_M` | `$null` | `""`（空字符串） |
| `_CE_CONDA` | `$null` | `""`（空字符串） |
| `CONDA_PREFIX` | 未设置 | `C:\Users\wbq20\.conda\envs\py_env` |
| `CONDA_SHLVL` | 未设置 | `1` |

**conda 的激活脚本把 `_CE_M` / `_CE_CONDA` 写成了空字符串。** 这两个变量本来只是 conda 内部调用自己的占位符，激活前后值的变化看似无关紧要——直到它撞上 pwsh 7 的参数传递规则。

## 关键差异：pwsh 7 的参数传递

PowerShell 调用原生命令（exe）时，参数里的 `$null` 和空字符串怎么处理，由 `$PSNativeCommandArgumentPassing` 决定：

| 模式 | 空字符串参数 | 适用场景 |
| :--- | :--- | :--- |
| `Legacy` | **丢弃** | Windows PowerShell 5.1、pwsh 7.3 之前 |
| `Standard` | **如实传递** | pwsh 7.3 及以上（默认） |

于是完整因果链浮出水面：

1. `conda activate py_env` 的激活脚本把 `_CE_M` / `_CE_CONDA` 置为空字符串
2. 之后每次执行 `conda xxx`，`Invoke-Conda` 都原样透传这两个变量
3. pwsh 7 的 `Standard` 模式把 `""` 如实传给 conda.exe
4. conda 的命令行解析器把第一个 `""` 当作子命令 → `invalid choice: ''`

activate 之前为什么正常？因为那时 `_CE_M` 是 `$null`，pwsh 调用原生命令时会直接丢掉 `$null` 参数，conda.exe 收到的就是干净的 `env list`。而在 Windows PowerShell 5.1 里从不会有这个问题——它的 `Legacy` 模式会把空字符串也一并丢弃。

## 验证假设

假设成立与否，用两个实验分别验证。

**实验 1：把 `_CE_M` / `_CE_CONDA` 恢复成 `$null`**

```powershell
conda activate py_env
$env:_CE_M = $null
$env:_CE_CONDA = $null
conda env list    # 恢复正常 ✓
```

**实验 2：把参数传递切回 `Legacy` 模式**

```powershell
$PSNativeCommandArgumentPassing = 'Legacy'
conda activate py_env
conda env list    # 恢复正常 ✓
```

两个方向的假设验证都通过，根因确认。

## 根因总结

这次问题不是单点故障，而是三个因素叠加：

1. **conda 24.11.3 的 PowerShell 激活脚本**把 `_CE_M` / `_CE_CONDA` 写成空字符串（而不是保持 `$null`）
2. **Conda.psm1 模块**无条件透传这两个变量给 conda.exe
3. **pwsh 7.3+ 默认的 `Standard` 参数传递**如实把空字符串传给原生命令，conda 解析器因此报 `invalid choice: ''`

另外还有两个次要因素，共同造成了「激活失败」的观感：

- **提示符不显示 `(py_env)`**：oh-my-posh（经 x-cmd 管理）在 profile 里覆盖了 conda 模块定义的 `prompt` 函数，`CONDA_PROMPT_MODIFIER` 虽然被设置，但没人渲染它
- **测试干扰**：排查时若从 WSL 启动 pwsh，会带入 WSL 的 PATH（含 `py_env` 目录），需先清理这些变量才能复现真实场景；Windows 注册表里并没有持久化任何 CONDA 变量

## 修复方案

### 方案一：一行配置（已采用）

在 pwsh profile（`$PROFILE`，即 `Documents\PowerShell\Microsoft.PowerShell_profile.ps1`）末尾加一行：

```powershell
$PSNativeCommandArgumentPassing = 'Legacy'
```

原理：让 pwsh 7 恢复 5.1 的 Legacy 行为，空字符串参数直接丢弃。副作用是全局生效——其他工具传空字符串参数时也会被丢弃，绝大多数场景无感。改完新开一个 pwsh 窗口即可。

### 方案二：函数兜底，零副作用

不想动全局参数传递的话，用函数覆盖别名，只在 `activate` / `deactivate` 之后重置两个变量：

```powershell
Remove-Item Alias:conda -ErrorAction SilentlyContinue
function conda {
    Invoke-Conda @args
    if ($args[0] -in @('activate', 'deactivate')) {
        $env:_CE_M = $null
        $env:_CE_CONDA = $null
    }
}
```

注意必须先删掉别名——PowerShell 里别名优先级高于函数，不删的话函数永远不会被执行。

### 提示符显示（可选）

想让提示符出现 `(py_env)`，需要给 oh-my-posh 的主题配置加一个 conda / 环境 segment。这与激活是否成功无关，纯显示问题，不做也不影响使用。

## 修复验证

修复后新开 pwsh，完整走一遍：

```powershell
conda activate py_env
conda env list
# py_env               *  C:\Users\wbq20\.conda\envs\py_env   ← 正常，带 * 号

python -c "import sys; print(sys.prefix)"
# C:\Users\wbq20\.conda\envs\py_env
```

`conda env list` 不再报错，python 正确指向 `py_env`，问题解决。

## 经验总结

回头看，这次排查最值钱的不是那个 `Legacy` 配置，而是方法本身：

- **把「现象」翻译成「可复现的最小问题」**：从「激活失败」到「activate 后 conda 子命令收到空字符串参数」，问题边界一下子清晰了
- **先好后坏的时序是金线索**：activate 前后对比，变量差异直接指向 `_CE_M` / `_CE_CONDA`
- **报错信息里藏着答案**：`invalid choice: ''` 里的 `''` 就是空字符串，顺着「谁传了空串」问下去就找到了 `Invoke-Conda`
- **假设必须双向验证**：手动复位变量和切换 Legacy 模式两条路都通，根因才算实锤
- **分清「观感」和「功能」**：提示符不显示 ≠ 激活失败，先确认 python 真的切换了

下次遇到「某个命令在旧环境正常、新环境报错」的问题，优先检查版本差异——这次就是 pwsh 7.3 的参数传递行为变更，坑了所有升级上来的 5.1 老用户。

## 参考

- PowerShell 官方文档：[`$PSNativeCommandArgumentPassing`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parsing?view=powershell-7.6)
- [Conda 环境激活机制说明](https://docs.conda.io/projects/conda/en/latest/dev-guide/deep-dives/activation.html)
- 相关阅读：[conda 插件崩溃修复记](conda-libmamba-solver-queryformat-fix.md)、[WSL2 安装与使用完全指南](../wsl/wsl2.md)
