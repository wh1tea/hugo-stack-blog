---
title: VS Code 插件配置
date: 2025-07-15
tags:
  - configuration
  - extensions
  - ide
  - productivity
  - vscode
  - personal
categories:
  - vscode
description: 完整收录了我当前 82 个 VS Code 插件配置，按功能分类逐一说明用途，并对冗余、冲突、废弃的插件给出改进建议和清理方案。
---

# （自用）VS Code 插件配置

> VS Code 的插件生态是其最大优势，但安装过多后容易积累冗余和冲突。本文整理了当前环境下的 82 个插件，按功能分组说明，并给出精简建议。

---

## 一、Python 开发

| 插件 ID                               | 用途                                                      |
| ------------------------------------- | --------------------------------------------------------- |
| `ms-python.python`                    | Python 语言核心支持：IntelliSense、调试、环境管理         |
| `ms-python.vscode-pylance`            | Python 语言服务器，基于 Pyright，提供类型检查、补全、导航 |
| `ms-python.debugpy`                   | Python 调试器，支持断点、变量监视、调用栈                 |
| `ms-python.black-formatter`           | Black 代码格式化（PEP 8 自动格式化）                      |
| `ms-python.flake8`                    | Flake8 代码检查（风格 + 逻辑错误）                        |
| `ms-python.isort`                     | import 语句自动排序分组                                   |
| `ms-python.vscode-python-envs`        | Python 环境可视化管理                                     |
| `ms-toolsai.jupyter`                  | Jupyter Notebook 原生支持                                 |
| `ms-toolsai.vscode-jupyter-cell-tags` | Jupyter Cell 标签管理                                     |
| `ms-toolsai.vscode-jupyter-slideshow` | Jupyter Notebook 转幻灯片                                 |

> Python 工具链完整，Pylance + Black + Flake8 + isort 是业界标准组合，Jupyter 生态也覆盖到位，无冗余。

---

## 二、Java / Spring 开发

| 插件 ID                                | 用途                                                      |
| -------------------------------------- | --------------------------------------------------------- |
| `redhat.java`                          | Java 语言服务器（基于 Eclipse JDT），代码补全、导航、重构 |
| `vscjava.vscode-java-pack`             | Java 插件包（汇总启动器）                                 |
| `vscjava.vscode-java-debug`            | Java 调试器                                               |
| `vscjava.vscode-java-dependency`       | Java 项目依赖管理视图                                     |
| `vscjava.vscode-java-test`             | Java 单元测试运行器（JUnit）                              |
| `vscjava.vscode-gradle`                | Gradle 构建工具支持                                       |
| `vscjava.vscode-maven`                 | Maven 构建工具支持                                        |
| `vscjava.vscode-spring-boot-dashboard` | Spring Boot 项目仪表盘（启动、停用、监控）                |
| `vscjava.vscode-spring-initializr`     | Spring Initializr 项目创建向导                            |
| `vmware.vscode-boot-dev-pack`          | Spring Boot 开发包（汇总）                                |
| `vmware.vscode-spring-boot`            | Spring Boot 应用支持（配置提示、导航）                    |
| `pleiades.java-extension-pack-jdk`     | JDK 自动配置 + Java + Spring Boot 扩展包集合              |
| `oracle.oracle-java`                   | Oracle Java 平台支持                                      |

> Java/Spring 领域覆盖非常全，Maven/Gradle 双支持、Spring Boot 全套工具链齐备。  
> **建议**：`pleiades.java-extension-pack-jdk` 与 `vscjava.vscode-java-pack` + `vmware.vscode-boot-dev-pack` 功能高度重叠——如果 JDK 环境已稳定配置（`JAVA_HOME` 已设置），可移除 `pleiades`。`oracle.oracle-java` 与 `redhat.java` 重叠，二者选一即可，建议保留 `redhat.java`（更活跃）。

---

## 三、C / C++ 开发

| 插件 ID                             | 用途                                               |
| ----------------------------------- | -------------------------------------------------- |
| `ms-vscode.cpptools`                | C/C++ 核心支持（语言服务器、调试器、IntelliSense） |
| `ms-vscode.cpptools-extension-pack` | C/C++ 扩展包（汇总启动器）                         |
| `ms-vscode.cpptools-themes`         | C/C++ 语法主题配色                                 |
| `ms-vscode.cpp-devtools`            | C/C++ 开发者工具增强                               |
| `ms-vscode.cmake-tools`             | CMake 构建工具支持（含语法高亮）                   |

> cpptools + CMake 标准组合。

---

## 四、Dart / Flutter

| 插件 ID               | 用途                                          |
| --------------------- | --------------------------------------------- |
| `dart-code.dart-code` | Dart 语言核心支持                             |
| `dart-code.flutter`   | Flutter 框架支持（热重载、Widget 补全、调试） |

> 标准组合，无冗余。

---

## 五、Web / 前端开发

| 插件 ID                         | 用途                                                   |
| ------------------------------- | ------------------------------------------------------ |
| `vue.volar`                     | Vue 3 官方语言工具（语法高亮、补全、格式化、类型检查） |
| `formulahendry.auto-close-tag`  | HTML/JSX 自动闭合标签                                  |
| `formulahendry.auto-rename-tag` | 同步修改配对标签名                                     |
| `formulahendry.code-runner`     | 一键运行代码片段                                       |
| `ritwickdey.liveserver`         | 本地 HTTP 服务器 + 自动刷新                            |

> **变更**：已用 `vue.volar` 替换 `octref.vetur`（Vue 2 已过时），移除了重复的 `ms-vscode.live-server` 和冗余的 `techer.open-in-browser`。当前组合精简有效。

---

## 六、Git / 版本控制

| 插件 ID              | 用途                                              |
| -------------------- | ------------------------------------------------- |
| `eamodio.gitlens`    | Git 历史追踪、代码作者标注、文件对比、Branch 管理 |
| `mhutchie.git-graph` | Git 提交图可视化                                  |

> **精简**：移除了 `donjayamanne.githistory` 和 `mk12.better-git-line-blame`，这两者功能已被 GitLens 完全覆盖。现保留 GitLens + Git Graph 组合，前者处理日常操作，后者提供直观拓扑图。

---

## 七、代码质量 / 格式化

| 插件 ID                                 | 用途                                         |
| --------------------------------------- | -------------------------------------------- |
| `esbenp.prettier-vscode`                | Prettier 通用代码格式化（JS/TS/CSS/JSON/MD） |
| `dbaeumer.vscode-eslint`                | ESLint JavaScript 代码检查                   |
| `sonarsource.sonarlint-vscode`          | SonarLint 代码质量分析                       |
| `davidanson.vscode-markdownlint`        | Markdown 语法及风格检查                      |
| `inferrinizzard.prettier-sql-vscode`    | SQL 专用 Prettier 格式化                     |
| `editorconfig.editorconfig`             | EditorConfig 支持（跨编辑器统一编码风格）    |
| `streetsidesoftware.code-spell-checker` | 拼写检查器                                   |

> **移除冗余**：已删除 `rvest.vs-code-prettier-eslint`（功能已内置于官方 Prettier 插件）、`lacroixdavid1.vscode-format-context-menu`（可用 `Shift+Alt+F` 或 `editor.formatOnSave` 替代）。SQL 格式化仅保留一个实现，无冲突。

---

## 八、数据库 / SQL

| 插件 ID                                 | 用途                       |
| --------------------------------------- | -------------------------- |
| `ms-mssql.mssql`                        | SQL Server 连接与查询      |
| `ms-mssql.data-workspace-vscode`        | SQL 数据工作区             |
| `ms-mssql.sql-bindings-vscode`          | Azure SQL Bindings         |
| `ms-mssql.sql-database-projects-vscode` | SQL 数据库项目管理         |
| `mtxr.sqltools`                         | SQL Tools 通用数据库客户端 |
| `mtxr.sqltools-driver-mysql`            | SQL Tools MySQL 驱动       |

> 若仅使用 SQL Server，`mtxr.sqltools` 可为冗余；若需连接 MySQL/PostgreSQL 等多类型数据库，保留 `sqltools` 更灵活。`data-workspace` 和 `sql-bindings` 为 Azure Data Studio 迁移而来的实验性功能，非必需时可移除。

---

## 九、Docker / Kubernetes / 容器

| 插件 ID                                       | 用途                                   |
| --------------------------------------------- | -------------------------------------- |
| `ms-azuretools.vscode-docker`                 | Docker 容器管理（镜像、容器、Compose） |
| `ms-vscode-remote.remote-containers`          | 远程开发 - 连接到容器（新标识符）      |
| `ms-kubernetes-tools.vscode-kubernetes-tools` | Kubernetes 集群管理                    |
| `exiasr.hadolint`                             | Dockerfile 静态分析                    |

> **注意**：`ms-azuretools.vscode-containers` 与 `ms-vscode-remote.remote-containers` 功能完全重叠，前者是旧标识符，现已弃用，**所以只保留了后者**。

---

## 十、Markdown / 文档

| 插件 ID                          | 用途                                              |
| -------------------------------- | ------------------------------------------------- |
| `yzhang.markdown-all-in-one`     | Markdown 增强（目录、自动编号、数学公式、快捷键） |
| `davidanson.vscode-markdownlint` | Markdown 语法检查（同上）                         |
| `marp-team.marp-vscode`          | Marp Markdown 转幻灯片（PPT 替代方案）            |
| `hediet.vscode-drawio`           | draw.io 流程图/架构图编辑器                       |
| `eliostruyf.vscode-front-matter` | Front Matter 元数据管理（用于博客/文档）          |

> Markdown 环境完善，新增 `front-matter` 便于管理文档元数据，无冗余。

---

## 十一、主题 / 视觉优化

| 插件 ID                       | 用途                                       |
| ----------------------------- | ------------------------------------------ |
| `dracula-theme.theme-dracula` | Dracula 暗色主题                           |
| `oderwat.indent-rainbow`      | 缩进层级彩色标注                           |
| `leodevbro.blockman`          | 代码块嵌套高亮                             |
| `hoovercj.vscode-power-mode`  | 敲代码时屏幕震动/粒子特效                  |
| `mechatroner.rainbow-csv`     | CSV 文件列着色                             |
| `aaron-bond.better-comments`  | 注释颜色分类（TODO/FIXME/INFO 按颜色区分） |
| `mikestead.dotenv`            | `.env` 文件语法高亮                        |
| `zhucy.project-tree`          | 项目文件树图示生成器                       |

> **建议**：`hoovercj.vscode-power-mode` 属娱乐向，长期使用易疲劳，建议按需启用。`zhucy.project-tree` 为一次性工具（生成目录结构图），非常用插件，可酌情移除。

---

## 十二、生产力 / 效率工具

| 插件 ID                                  | 用途                         |
| ---------------------------------------- | ---------------------------- |
| `alefragnani.bookmarks`                  | 行书签管理（跳转、标记）     |
| `alefragnani.project-manager`            | 项目管理器（快速切换项目）   |
| `gruntfuggly.todo-tree`                  | TODO/FIXME/HACK 标记树形视图 |
| `intellsmi.comment-translate`            | 注释翻译（选中英文→中文）    |
| `ms-ceintl.vscode-language-pack-zh-hans` | VS Code 中文界面语言包       |
| `christian-kohler.npm-intellisense`      | npm 包名自动补全             |
| `tushortz.pygame-snippets`               | Pygame 代码片段              |
| `leetcode.vscode-leetcode`               | LeetCode 刷题插件            |

> **移除冗余**：已移除 `wayou.vscode-todo-highlight`（被 Todo Tree 覆盖）和 `shardulm94.trailing-spaces`（可通过 `"files.trimTrailingWhitespace": true` 原生实现）。`tushortz.pygame-snippets` 仅在 Pygame 项目中有用，非通用场景可移除。

---

## 十三、Vim 使用者专属

| 插件 ID         | 用途                                         |
| --------------- | -------------------------------------------- |
| `vscodevim.vim` | Vim 按键绑定模拟（操作符待决模式、宏录制等） |

> **提示**：若启用，建议在 `settings.json` 中设置 `"vim.useCtrlKeys": false`，仅保留 Vim 导航模式，避免与 VS Code 原生快捷键冲突。

---

## 十四、其他工具

| 插件 ID                                | 用途                                      |
| -------------------------------------- | ----------------------------------------- |
| `github.vscode-github-actions`         | GitHub Actions 工作流文件语法高亮与验证   |
| `juanallo.vscode-dependency-cruiser`   | 可视化项目依赖关系图                      |
| `sidhantsriv.visor`                    | 代码概览/小地图增强（提供类缩略图导航）   |
| `redhat.vscode-xml`                    | XML 语言支持（语法高亮、验证、格式化）    |
| `redhat.vscode-yaml`                   | YAML 语言支持（语法高亮、验证、自动补全） |
| `ms-dotnettools.vscode-dotnet-runtime` | .NET 运行时环境支持（用于运行 .NET 项目） |

> 这些插件服务于特定场景，若日常工作中不涉及 GitHub Actions、依赖分析、XML/YAML 编辑或 .NET 开发，可按需禁用。

---

## 总量分析

**当前总数：82 个插件**

按类别统计：

| 类别              | 数量   |
| ----------------- | ------ |
| Python 工具链     | 10     |
| Java / Spring     | 13     |
| C / C++           | 5      |
| Dart / Flutter    | 2      |
| Web / 前端        | 5      |
| Git 工具          | 2      |
| 代码质量 / 格式化 | 7      |
| 数据库 / SQL      | 6      |
| Docker / K8s      | 4      |
| Markdown / 文档   | 5      |
| 主题 / 视觉       | 8      |
| 生产力            | 8      |
| Vim 绑定          | 1      |
| 其他工具          | 6      |
| **合计**          | **82** |

---

## 精简方案小结（针对当前列表）

以下插件建议优先清理：

| 插件                                                     | 问题                                                    | 操作 |
| -------------------------------------------------------- | ------------------------------------------------------- | ---- |
| `pleiades.java-extension-pack-jdk`                       | 与 Java Pack + Boot Dev Pack 重叠，JDK 环境已配好则冗余 | 移除 |
| `oracle.oracle-java`                                     | 与 `redhat.java` 重叠，后者更活跃                       | 移除 |
| `lacroixdavid1.vscode-format-context-menu`               | 快捷键 `Shift+Alt+F` 或 `formatOnSave` 可替代           | 移除 |
| `hoovercj.vscode-power-mode`                             | 娱乐向，建议按需启用或移除                              | 按需 |
| `tushortz.pygame-snippets`                               | 仅 Pygame 项目有用，非通用                              | 移除 |
| `zhucy.project-tree`                                     | 一次性工具，非必需                                      | 移除 |
| `ms-mssql.data-workspace-vscode` / `sql-bindings-vscode` | Azure Data Studio 实验功能，非必需可移除                | 按需 |
| `mtxr.sqltools`                                          | 若仅使用 SQL Server，可移除                             | 按需 |

按上述建议清理后，预计可减少 **8–12 个插件**，总数降至 **71–75 个**，进一步降低启动开销和内存占用。

---

## 总结

82 个插件覆盖了 Python、Java/Spring、C/C++、Dart/Flutter、前端、数据库、容器、文档、Git 等主流开发场景，工具链完整且无明显冲突。通过移除重复、被取代以及非常用插件，可有效减轻插件管理负担。

建议利用 VS Code 的 [Profiles 功能](https://code.visualstudio.com/docs/editor/profiles) 按项目类型创建不同插件集合（如“Python 开发”、“Java 后端”、“通用写作”），按需切换，避免所有插件在所有场景下同时激活。

---

## 参考

- [VS Code Extension Marketplace](https://marketplace.visualstudio.com/vscode)
- [VS Code Profiles 官方文档](https://code.visualstudio.com/docs/editor/profiles)
- [Vue Volar 官方指南](https://github.com/vuejs/language-tools)
- [GitLens 文档](https://gitlens.amod.io/)
- [EditorConfig 官网](https://editorconfig.org/)
