---
title: npm、pnpm 与 Node.js 入门指南
date: 2026-08-07
description: 全面对比 npm 与 pnpm，详解 Node.js 安装与包管理核心用法，助你快速选型并高效管理项目依赖。
tags:
  - nodejs
  - npm
  - pnpm
  - package-manager
  - tutorial
categories:
  - web
---

Node.js 已成为服务端 JavaScript 的事实标准，而 npm 和 pnpm 则是其生态中最主流的包管理工具。本文面向有 JavaScript 基础的开发者，介绍三者核心概念与基本操作，对比 npm 与 pnpm 的优劣，并给出选型建议。读完你将能独立安装 Node.js、使用 npm/pnpm 管理依赖，并理解它们在 Docker 环境中的应用。

---

## Node.js 简介与安装

Node.js 是基于 Chrome V8 引擎的 JavaScript 运行时，提供异步、非阻塞 I/O 模型，适合高并发 Web 服务、命令行工具和实时应用。

### 安装方式

**官方安装包（Windows / macOS）**  
访问 [Node.js 官网](https://nodejs.org/)，下载 LTS 版本（推荐生产环境）或 Current 版本（尝鲜新特性）。运行安装程序即可。

**Linux（Ubuntu/Debian）**  
使用系统包管理器：

```bash
sudo apt update
sudo apt install nodejs npm
```

**Docker 快速体验**  

```bash
docker pull node:22-alpine
docker run -it --rm --entrypoint sh node:22-alpine
node -v   # v22.18.0
npm -v    # 10.9.3
```

**版本管理（推荐 nvm）**  
管理多版本 Node.js，避免权限和兼容问题：

```bash
nvm install 18
nvm use 18
```

安装后验证：

```bash
node -v
npm -v
```

---

## npm 包管理工具

npm（Node Package Manager）是 Node.js 默认的包管理器，连接全球最大包仓库 [npmjs.com](https://www.npmjs.com/)。随 Node.js 自动安装，可独立更新：

```bash
npm install -g npm@latest
```

### 常用命令

| 操作         | 命令                               |
| ------------ | ---------------------------------- |
| 初始化项目   | `npm init -y`                      |
| 安装生产依赖 | `npm install <package>`            |
| 安装开发依赖 | `npm install <package> --save-dev` |
| 运行脚本     | `npm run <script>`                 |
| 发布包       | `npm login && npm publish`         |
| 查看依赖树   | `npm list`                         |
| 更新依赖     | `npm update`                       |
| 安全审计     | `npm audit`                        |

### 配置国内镜像（加速下载）

```bash
npm config set registry https://registry.npmmirror.com
```

---

## pnpm 高效包管理器

pnpm 定位为 npm 的替代品，通过**硬链接**和**符号链接**复用全局存储的模块，大幅节省磁盘空间并提升安装速度。同时它严格隔离依赖，避免“幽灵依赖”（即未在 `package.json` 声明的模块被意外引用）。

### 安装 pnpm

通过 npm 全局安装：

```bash
npm install -g pnpm
```

或使用独立脚本：

```bash
curl -fsSL https://get.pnpm.io/install.sh | sh -
```

验证：

```bash
pnpm -v
```

### 常用命令（与 npm 高度相似）

| 操作         | pnpm 命令               |
| ------------ | ----------------------- |
| 初始化项目   | `pnpm init`             |
| 安装生产依赖 | `pnpm add <package>`    |
| 安装开发依赖 | `pnpm add -D <package>` |
| 运行脚本     | `pnpm run <script>`     |
| 发布包       | `pnpm publish`          |
| 查看依赖     | `pnpm list`             |
| 更新依赖     | `pnpm update`           |

### 配置镜像与存储路径

```bash
pnpm config set registry https://registry.npmmirror.com
pnpm config set store-dir /path/to/store   # 默认 ~/.pnpm-store
```

---

## npm vs pnpm 对比

| 特性         | npm                            | pnpm                               |
| ------------ | ------------------------------ | ---------------------------------- |
| **磁盘占用** | 每个项目独立存储依赖，重复严重 | 全局存储，硬链接共享，节省大量空间 |
| **安装速度** | 串行下载，较慢                 | 并行下载 + 缓存，明显更快          |
| **依赖隔离** | 扁平结构，可能引入幽灵依赖     | 严格隔离，只暴露声明的依赖         |
| **生态兼容** | 原生支持 npm 生态              | 完全兼容，命令基本一致             |
| **学习曲线** | 低，广泛使用                   | 略高，但命令类似，迁移成本低       |

**选型建议**：  

- 小型项目、快速原型：npm 足矣。  
- 大型项目、monorepo、磁盘受限环境：pnpm 更优。

---

## 与 Docker 结合

在容器化构建中，pnpm 能进一步缩减镜像体积。示例 Dockerfile：

```dockerfile
FROM node:18
WORKDIR /app
COPY package.json .
RUN npm install -g pnpm && pnpm install
COPY . .
CMD ["pnpm", "start"]
```

若使用 npm，则替换为 `RUN npm install` 即可。

---

## 注意事项

- **Node.js 版本**：使用 `nvm` 管理多个版本，确保与依赖兼容。
- **缓存清理**：  
  - npm：`npm cache clean --force`  
  - pnpm：`pnpm store prune`
- **安全审计**：定期执行 `npm audit` 或 `pnpm audit` 修复漏洞。
- **镜像源**：国内用户务必配置国内镜像，否则下载极慢。

---

## 总结

- **Node.js** 是服务端 JavaScript 运行基石。  
- **npm** 是最通用的包管理器，简单可靠，适合绝大多数场景。  
- **pnpm** 在性能和空间上更具优势，尤其适合大型项目或 monorepo。

建议初学者从 npm 入手，熟悉生态后再尝试 pnpm。无论选择哪种，都请配合 `nvm` 管理 Node 版本，并定期审计依赖安全。结合 Docker 时优先考虑 pnpm 以优化镜像大小。

---

## 参考

- [Node.js 官方文档](https://nodejs.org/zh-cn)  
- [npm 官网](https://www.npmjs.com/)  
- [pnpm 官方文档](https://pnpm.io/zh/pnpm-vs-npm)  
- [nvm GitHub 仓库](https://github.com/nvm-sh/nvm)
