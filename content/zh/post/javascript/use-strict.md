---
title: JavaScript 严格模式与作用域链：从一道题彻底吃透
slug: javascript-strict-mode-scope
date: 2026-09-09T16:30:00+08:00
description: 通过一道关于 'use strict' 的问答，深入理解作用域链的逐层查找机制，以及严格模式如何帮助开发者避免隐性全局变量等常见错误。
tags:
  - javascript
  - strict-mode
  - scope
  - referenceerror
categories:
  - web
---

## 一道题引出的话题

在[计数器](counter.md)的 review 中，有开发者问：Counter 页面的脚本里为什么要写 `"use strict";`？

直接回答是：**对于普通 `<script>` 标签，强烈推荐写上；但如果改用 `<script type="module">`，严格模式会默认开启，无需显式声明。**

这个回答引出了更深层的追问：严格模式下，给未声明的变量赋值到底会不会报错？作用域链在查找过程中究竟怎么走？

## 严格模式的核心机制

`"use strict"` 告诉 JavaScript 引擎：用更严格的语法规则解析代码，把旧版本中那些「静默失败」的错误全部抛出。[^1]

对代码最实际的保护体现在三点：

| 保护机制               | 非严格模式       | 严格模式              |
| :--------------------- | :--------------- | :-------------------- |
| 意外创建全局变量       | 静默创建         | 抛出 `ReferenceError` |
| 删除不可删除的属性     | 静默返回 `false` | 抛出 `TypeError`      |
| 函数中 `this` 的默认值 | 指向 `window`    | 指向 `undefined`      |

其中第一点对日常开发帮助最大。假设在函数里把 `currentCount` 拼写成 `currenCount`：

- 非严格模式：JS 在全局作用域创建一个新变量 `currenCount`，原变量不变，页面静默失效
- 严格模式：直接抛出 `ReferenceError: currenCount is not defined`，控制台报错，一击即中

## 作用域链的查找规则

理解严格模式为什么能捕获这类错误，需要深入作用域链的查找机制。

当引擎执行赋值操作（如 `newValue = currentCount`）时，会进行 **LHS 查询**（Left-Hand Side lookup），沿着作用域链逐级向上查找目标标识符：

1. 在当前函数作用域内查找
2. 如未找到，向外层函数作用域查找
3. 逐级向上，直至全局作用域

**关键分水岭**出现在查找链走完仍找不到的时候：

- 非严格模式：引擎在全局作用域「好心」创建新变量，赋值成功，不报错
- 严格模式：引擎拒绝自动创建，立即抛出 `ReferenceError`

## 嵌套作用域的逐层演示

以下 HTML 代码展示了三层嵌套作用域中的查找过程，可直接运行并查看控制台输出：

```html
<!DOCTYPE html>
<html lang="zh">
  <head>
    <meta charset="UTF-8" />
    <title>作用域链透视演示</title>
  </head>
  <body>
    <h3>打开控制台 (F12) 查看作用域链查找过程</h3>
    <script>
      "use strict";

      // 第 0 层：全局作用域
      let globalVar = "🌍 全局变量 (第0层)";

      // 第 1 层：外部函数 outer
      function outerFunction() {
        let outerVar = "📦 外层函数变量 (第1层)";

        // 第 2 层：内部函数 inner
        function innerFunction() {
          let innerVar = "🧩 内层函数变量 (第2层)";

          console.log("===== 查找 innerVar =====");
          // 第2层找到，停止
          console.log(innerVar);

          console.log("===== 查找 outerVar =====");
          // 第2层没有 -> 第1层找到，停止
          console.log(outerVar);

          console.log("===== 查找 globalVar =====");
          // 第2层没有 -> 第1层没有 -> 第0层找到
          console.log(globalVar);

          // 取消注释下面这行，严格模式会抛出 ReferenceError
          // notExist = "未声明的赋值";
        }

        innerFunction();
      }

      outerFunction();

      console.log("查找顺序：当前作用域 -> 外层函数 -> ... -> 全局");
    </script>
  </body>
</html>
```

## 与 Counter 代码的实际关联

原始 Counter 页面中，`loadCount` 函数定义在脚本最顶层，未被任何函数包裹。因此它的作用域链只有两层：`loadCount` 局部 → 全局。

若某天在 `loadCount` 里不小心把 `let newValue = currentCount` 写成 `newValue = currentCount`（漏掉了 `let`）：

- 无 `"use strict"`：`newValue` 被挂载到 `window` 上，页面不报错，后续逻辑可能产生难以追踪的 bug
- 有 `"use strict"`：立即抛出 `ReferenceError: newValue is not defined`，开发者一秒定位问题

## 为什么现代前端项目很少显式写它

Vue、React 等现代项目主要通过两种方式默认启用严格模式：

1. **构建工具**：Vite、Webpack 打包后的代码默认带有 `"use strict"`
2. **ES Module**：`<script type="module">` 强制运行在严格模式下，无需显式声明[^2]

因此，在普通 HTML 页面中用 `<script>` 标签引入代码时，显式写上 `"use strict"` 仍然是最廉价的保险丝。

## 结语

严格模式的核心价值在于：**把 JavaScript 的设计缺陷暴露为明确的错误，而非静默失效**。理解作用域链的逐层查找机制，才能真正理解 `"use strict"` 为什么能捕获「未声明变量赋值」这类常见错误。[^3]

建议在所有非模块化脚本顶部加上 `"use strict"` —— 一行代码，换来整个脚本的运行时安全保障。

[^1]: [MDN：严格模式](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Strict_mode)

[^2]: [ECMAScript 规范：严格模式](https://tc39.es/ecma262/#sec-strict-mode-code)

[^3]: [现代 JavaScript 教程：严格模式](https://zh.javascript.info/strict-mode)
