---
title: VS Code Profiles：当前配置全览
slug: vscode-profiles
date: 2026-07-18T01:06:27+08:00
description: 用 VS Code Profiles 按项目隔离插件环境：全局 20 个通用扩展 + 6 个语言专属 Profile，逐插件说明作用，附工作区关联与鸡肋插件备忘
tags:
  - extensions
  - ide
  - profiles
  - vscode
  - personal
categories:
  - devtools
---

本文是 VS Code Profiles 配置的现状快照（2026-08）：内置 Default 之外共 6 个命名 Profile，每个插件一句话说明作用。前一篇 [VS Code 插件配置](vscode-extensions-config.md) 是 82 插件的全量档案，本文只讲当前实际在用的配置，并把鸡肋插件单独列为备忘。

## 当前结构

| Profile              | 定位                                         |
| -------------------- | -------------------------------------------- |
| 全局（Apply to All） | 语言无关的通用工具                           |
| Default              | 个人主 Profile（新窗口默认，Notes/Obsidian） |
| Java-Spring          | Java / Maven / Gradle / Spring Boot          |
| Web-Frontend         | 前端 / Flutter / 博客                        |
| Python               | Python 开发                                  |
| C/C++                | C/C++ / CMake                                |
| SQL                  | 数据库                                       |
| Remote-Dev           | 远程 / 容器                                  |

## 全局扩展

| 插件               | 作用                                    |
| ------------------ | --------------------------------------- |
| Dracula Theme      | 暗色主题                                |
| 中文语言包         | 中文界面                                |
| GitLens            | Git 历史、作者标注、文件对比            |
| Git Graph          | Git 提交图可视化                        |
| GitHub Actions     | Actions 工作流语法高亮与校验            |
| EditorConfig       | 跨编辑器统一编码风格                    |
| Prettier           | 通用格式化器（html/json/css/yaml 默认） |
| YAML               | YAML 语法高亮、校验、补全               |
| markdownlint       | Markdown 语法与风格检查、格式化器       |
| Code Runner        | 一键运行代码片段                        |
| Better Comments    | 注释按 TODO/FIXME 分类着色              |
| dotenv             | `.env` 文件语法高亮                     |
| indent-rainbow     | 缩进层级彩色标注                        |
| Project Manager    | 快速切换项目                            |
| Comment Translate  | 选中注释翻译（英→中）                   |
| Code Spell Checker | 拼写检查                                |
| SonarLint          | 代码质量静态分析                        |
| LeetCode           | LeetCode 刷题                           |

Prettier 与 YAML 必须在 All：settings 里 html / json / jsonc / dockercompose / yaml 的默认格式化器指向它们。Prettier 使用`_`而不是`*`作为斜体语法，个人改用markdownlint用于md格式化器。

## 各 Profile 专属扩展

### Java-Spring（13）

| 插件                                     | 作用                       |
| ---------------------------------------- | -------------------------- |
| Java Extension Pack                      | 汇总启动器                 |
| Language Support for Java（redhat.java） | Java 语言服务器，格式化器  |
| Debugger for Java                        | Java 调试（F5）            |
| Test Runner for Java                     | JUnit 测试运行             |
| Project Manager for Java                 | 依赖与项目视图             |
| Maven for Java                           | Maven 构建支持             |
| Gradle for Java                          | Gradle 构建支持            |
| Spring Boot Extension Pack               | 汇总启动器                 |
| Spring Boot Tools                        | 配置提示、导航             |
| Spring Boot Dashboard                    | 启动、停用、监控 Boot 应用 |
| Spring Initializr                        | Spring 项目创建向导        |
| XML                                      | pom.xml 等 XML 支持        |
| Rainbow CSV                              | CSV 列着色                 |

已裁掉：pleiades（与 Pack 重叠）、Live Server（前端工具误入）、Trailing Spaces（原生 `files.trimTrailingWhitespace` 可替）、Code Spell Checker（升为全局）。

### Web-Frontend（9）

| 插件                    | 作用                                                  |
| ----------------------- | ----------------------------------------------------- |
| Vue - Official（Volar） | Vue 3 语言工具                                        |
| ESLint                  | JS/TS 代码检查                                        |
| Auto Close Tag          | HTML/JSX 自动闭合标签                                 |
| Auto Rename Tag         | 同步修改配对标签                                      |
| Live Server             | 本地服务器 + 自动刷新（快捷键 `Alt+B`）               |
| npm Intellisense        | npm 包名补全                                          |
| Dart                    | Dart 语言支持（并入）                                 |
| Flutter                 | Flutter 框架支持（并入）                              |
| Front Matter CMS        | 博客 front matter 管理，仅 hugo-stack-blog 工作区启用 |

### Python（5）

| 插件                       | 作用                                  |
| -------------------------- | ------------------------------------- |
| Python                     | 核心支持：补全、调试、环境            |
| Pylance                    | 语言服务器（Pyright）                 |
| debugpy                    | Python 调试器                         |
| Python Environment Manager | 环境可视化                            |
| Black Formatter            | Black 格式化（[python] 默认格式化器） |

### C/C++（5）

| 插件                 | 作用                           |
| -------------------- | ------------------------------ |
| C/C++ Extension Pack | 汇总启动器                     |
| C/C++                | 语言服务器、调试、IntelliSense |
| CMake Tools          | CMake 构建                     |
| C/C++ Themes         | 语法配色                       |
| C/C++ DevTools       | 开发工具增强                   |

### SQL（7）

| 插件                  | 作用                       |
| --------------------- | -------------------------- |
| mssql                 | SQL Server 连接与查询      |
| SQL Data Workspace    | SQL 数据工作区             |
| SQL Bindings          | Azure SQL Bindings         |
| SQL Database Projects | SQL 数据库项目管理         |
| SQLTools              | 通用数据库客户端（多驱动） |
| Prettier SQL          | SQL 专用格式化             |
| .NET Runtime          | mssql 依赖的运行时         |

### Remote-Dev（8）

| 插件                       | 作用                |
| -------------------------- | ------------------- |
| Remote Development（汇总） | 远程开发扩展包      |
| Remote - Containers        | 连接容器            |
| Remote - SSH               | SSH 远程开发        |
| Remote - WSL               | WSL 远程开发        |
| Remote Explorer            | 远程资源视图        |
| Remote Server              | 远程服务器支持      |
| hadolint                   | Dockerfile 静态分析 |

### Default

个人主 Profile，只吃全局扩展；`window.newWindowProfile` 指向它，新窗口默认打开。关联 Notes / Obsidian 等文档目录，不背任何语言工具。

## 工作区关联

打开文件夹时按关联自动套用 Profile，无需手动切换。关联在 `User\globalStorage\storage.json` 的 `profileAssociations.workspaces`，也可在命令面板 Profiles: Manage 里改。

## 手动配置流程（精简）

1. 扩展视图 `Ctrl+Shift+X` → 右键 → Apply to All Profiles 标记通用扩展
2. 命令面板 → Profiles: Create Profile → Duplicate Current Profile 继承 settings
3. 切到新 Profile，Disable 不属于它的扩展（或 Extensions: Disable All Installed Extensions 后逐个 Enable）
4. 打开目标文件夹 → 命令面板 Profiles: Manage → 关联到对应 Profile

## 文件落点

- `AppData\Roaming\Code\User\profiles\<hash>\settings.json`：各 Profile 独立设置
- `profiles\<hash>\extensions.json`：该 Profile 的扩展注册表
- `AppData\Roaming\Code\User\globalStorage\storage.json`：Profile 元数据与工作区关联
- `C:\Users\<用户名>\.vscode\extensions\`：扩展本体文件（所有 Profile 共用一份）

Profile 名称等元数据存 SQLite（`state.vscdb`），命名、勾选只能走 UI。

## 插件备忘（备而不装）

需要时搜索安装即可，作用如下：

| 插件                | 作用                     | 什么时候用                |
| ------------------- | ------------------------ | ------------------------- |
| Project Tree        | 项目目录树图示生成       | 写文档要目录结构图时      |
| Power Mode          | 敲代码粒子/震动特效      | 娱乐，勿长期开            |
| Format Context Menu | 右键格式化菜单           | 已可用 `Shift+Alt+F` 替代 |
| Markdown All in One | 目录、表格、数学公式增强 | 写长 Markdown 时          |
| Marp for VS Code    | Markdown 转 PPT          | 要做幻灯片时              |
| Blockman            | 代码块嵌套高亮           | 看深嵌套代码时            |
| Bookmarks           | 行书签跳转               | 大文件多处标记时          |
| Kubernetes          | K8s 集群管理             | 做 k8s/云原生开发时       |
| Vim                 | Vim体验模拟              | 熟练或重度Vim用户         |
| Todo Tree           | TODO/FIXME 标记树形视图  | 大量TODO需要管理的时候    |

详细扩展 ID 见 [VS Code 插件配置](vscode-extensions-config.md)。

## 结语

配置一次、按文件夹自动切换：Java 项目不再背 Python 扩展，前端项目没有 C++ 语言服务器。本次整理还修了两处格式化器指向（[java] → redhat.java、Python 补装 Black），清理了 settings 里未装扩展的残留配置。以后装新扩展先想归属：语言无关 → All，语言专属 → 对应 Profile，偶尔用 → 备忘里待命。

## 参考

- [VS Code Profiles 官方文档](https://code.visualstudio.com/docs/editor/profiles)
- [VS Code 插件配置](vscode-extensions-config.md)
- [Front Matter CMS：在 VS Code 里管理 Hugo 博客](front-matter-cms.md)
