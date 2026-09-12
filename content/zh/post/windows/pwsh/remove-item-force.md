---
title: PowerShell 删除目录的等效命令
slug: remove-item-force
date: 2025-09-04
description: 在 PowerShell 中实现 rm -rf public 的等效写法，对比标准命令、别名与完整写法，并说明 -Force 与 CMD 的对应命令
tags:
  - pwsh
  - cli
categories:
  - windows
---

在 PowerShell 中，`rm -rf public` 最直接的等效命令是 `Remove-Item -Recurse -Force public`。PowerShell 也支持 `rm` 作为 `Remove-Item` 的别名，你可以直接使用 `rm`，但参数需要对应修改。Bash 侧 `-rf` 的含义见 [rm -rf 的含义与风险](rm-rf.md)。[^1]

## 等效命令及写法

| 命令类型 | 命令写法                                   | 说明                                                  |
| :------- | :----------------------------------------- | :---------------------------------------------------- |
| 标准命令 | `Remove-Item -Recurse -Force public`       | 功能完整，最清晰的标准写法。                          |
| 使用别名 | `rm -r -fo public`                         | `-r` 是 `-Recurse` 的别名，`-fo` 是 `-Force` 的别名。 |
| 完整写法 | `Remove-Item -Path public -Recurse -Force` | 显式指定了 `-Path` 参数，可读性最好。                 |

> 请注意：在 PowerShell 中直接使用 `rm -rf public` 通常不会生效，因为 `-rf` 会被解析为一个整体，而不是两个独立的参数。

## 执行前的重要提醒

1. 操作不可逆：`Remove-Item -Recurse -Force` 命令会永久删除文件，不会将其移动到回收站。请务必在执行前确认路径正确。
2. 关于 `-Force` 参数：这个参数主要用于删除具有隐藏或只读属性的文件。即使不使用 `-Force`，PowerShell 通常也会提示确认，而 `-Force` 会跳过这些提示，实现静默删除。
3. 权限问题：如果遇到「拒绝访问」的错误，可能需要以管理员身份运行 PowerShell。

## 进阶技巧：创建自定义函数

如果你频繁使用这个命令，可以像在 Bash 中一样，在 PowerShell 里创建一个简单的自定义函数来缩短指令：

```powershell
function rmrf($path) { Remove-Item $path -Recurse -Force }
```

之后，你只需要输入 `rmrf public` 即可。

## 补充：CMD 环境下的命令

如果你是在 CMD（命令提示符）环境下，对应的命令是：

```cmd
rmdir /s /q public
```

其中 `/s` 用于删除目录及其所有内容，`/q` 用于静默执行，不提示确认。

[^1]: [PowerShell 与 Linux 命令对比](https://github.com/shiwenxin123/PowerShell-Linux-Command-Manual)
