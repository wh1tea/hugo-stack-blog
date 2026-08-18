---
title: 为右键菜单“新建”添加 Markdown 文件类型
date: 2026-07-16
tags:
  - windows
  - registry
  - typora
  - markdown
  - productivity-tools
categories:
  - windows
description: 详细介绍了三种为 Windows 右键菜单“新建”添加 Markdown 文件类型的方法，包括手动修改注册表、一键导入 .reg 文件以及利用 Typora 自带功能，助你提升日常写作与笔记管理的效率。
---

在日常写作或笔记管理中，Markdown 已经是我最离不开的格式。无论是用 Typora 写技术文档，还是用 Obsidian 管理知识库，`.md` 文件都是绝对的主力。然而，Windows 系统的右键菜单“新建”里默认只有文本文档、Word 等常见格式，却没有 Markdown。每次新建文件后还要手动重命名后缀，着实不够优雅。

那么，怎么把 `.md` 文件类型也加入到右键新建菜单里呢？下面分享三种方法，从手动改注册表到一键导入 `.reg` 文件，再到 Typora 自带的“一键注册”，总有一种适合你。

---

## 方法一：手动修改注册表（最通用）

如果你对注册表操作不陌生，可以按以下步骤亲手添加。**操作前建议先导出注册表备份**，以防误操作。

1. **安装一个 Markdown 编辑器**（这里以 Typora 为例，若使用其他编辑器，稍后需替换对应的程序路径）。
2. 按下 `Win + R`，输入 `regedit` 并回车，打开注册表编辑器。
3. 在顶部地址栏粘贴或导航到：

   ```bash
   Computer\HKEY_CLASSES_ROOT\.md
   ```

   （也可直接输入 `HKEY_CLASSES_ROOT\.md` 跳转）

4. 点击左侧的 `.md` 文件夹，在右侧找到`(Default)`项，双击打开，将其**数值数据**修改为 `Typora.md`（若使用其他编辑器，请填写对应的 ProgID，例如 Obsidian 可填 `Obsidian.md`）。
5. 在左侧 `.md` 文件夹上右键 → 新建 → **项（key）**，将新项命名为 `ShellNew`。
6. 选中 `ShellNew`，在右侧空白处右键 → 新建 → **字符串值**，命名为 `NullFile`（数值数据留空即可）。
7. 关闭注册表编辑器，**重启电脑**（或重启资源管理器）即可生效。

重启后，在桌面或文件夹内右键 → 新建，就能看到“Markdown 文件”选项了。新建的 `.md` 文件会默认用 Typora 打开（由第 4 步的关联决定）。

---

## 方法二：一键导入 `.reg` 文件（省心版）

如果觉得手动操作繁琐，可以直接将下面的内容保存为 `add_md_new.reg` 文件，双击导入即可。**注意**：以下脚本默认关联 Typora，且路径为常见安装位置。如果你的 Typora 装在非默认路径，请自行修改 `FriendlyAppName` 和 `FriendlyCache` 中的可执行文件路径。

```reg
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\.md]
@="Typora.md"

[HKEY_CLASSES_ROOT\.md\ShellNew]
"NullFile"=""

[HKEY_CLASSES_ROOT\Typora.md]
@="Markdown File"
"FriendlyCache"="D:\\Program Files\\Typora\\Typora.exe"
"FriendlyAppName"="Typora"

[HKEY_CLASSES_ROOT\Typora.md\DefaultIcon]
@="D:\\Program Files\\Typora\\Typora.exe,0"

[HKEY_CLASSES_ROOT\Typora.md\shell\open\command]
@="\"D:\\Program Files\\Typora\\Typora.exe\" \"%1\""
```

保存后双击，按提示确认导入，然后重启资源管理器即可。如果想改为 Obsidian 或其他编辑器，只需将上述 `Typora.md` 换成对应的 ProgID，并将程序路径修正为你电脑上的实际路径。

---

## 方法三：利用 Typora 的“一键注册”功能（最新版）

Typora 在较新版本中提供了图形化的注册选项，本应是最便捷的方式。打开 Typora，进入 **文件 → 偏好设置 → 通用**，在“文件关联”区域点击“**添加到右键菜单**”或类似按钮，理论上就能自动完成注册。

不过，我在实际测试时（版本 1.14.1-dev）点击后并未成功添加，原因可能与当前用户的权限或系统策略有关。**如果这个按钮对你无效**，请优先使用方法一或二，它们更可靠，且不依赖 Typora 的内部实现。

---

## 注意事项与扩展

- **权限问题**：修改 `HKEY_CLASSES_ROOT` 需要管理员权限。若导入 `.reg` 文件时提示失败，请右键选择“以管理员身份运行”注册表编辑器，或右键 `.reg` 文件选择“合并”时确保当前用户有写入权限。
- **关联其他编辑器**：如果你常用 Obsidian、VS Code 等，只需将上述注册表中的 `Typora.md` 替换为相应标识，并修改程序路径即可。例如 VS Code 的 ProgID 常为 `VisualStudioCode.md`，路径为 `"C:\Users\<用户名>\AppData\Local\Programs\Microsoft VS Code\Code.exe" "%1"`。
- **移除该功能**：如果后续不需要了，删除注册表中的 `HKEY_CLASSES_ROOT\.md\ShellNew` 项，并将 `.md` 的默认值恢复为 `txtfile` 或其他值即可。
- **多种 Markdown 编辑器共存**：若系统中安装了多个 Markdown 编辑器，右键新建的文件会由默认打开方式（即 `.md` 关联的程序）决定。你可以在任意 `.md` 文件上右键 → 打开方式 → 选择其他应用，勾选“始终使用此应用”来调整。

---

## 结语

添加右键新建 Markdown 文件后，工作流会顺畅不少——无论是快速记录灵感，还是创建新的文章草稿，都无需再手工改后缀或打开编辑器再新建。推荐先试试 `.reg` 文件，若失败再手动调整。

---

## 参考

- [Windows 注册表 ShellNew 项说明](https://learn.microsoft.com/en-us/windows/win32/shell/launch)
