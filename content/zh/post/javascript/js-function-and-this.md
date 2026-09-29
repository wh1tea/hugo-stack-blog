---
title: 函数、this 与参数
slug: js-function-and-this
date: 2026-09-29T13:10:00+08:00
description: 箭头函数与普通函数的四个区别、this 的四种绑定与「定义时决定」的机制，以及默认参数、剩余参数和 return 换行的 ASI 坑。
tags:
  - javascript
  - this
  - arrow-function
categories:
  - web
draft: false
---

函数的坑集中在三处：`this` 属于谁、参数怎么收、`return` 怎么写。
这三处出错时都不报错，只是结果悄悄变了——其中「在对象里把方法写成箭头函数」最容易看走眼。

## 箭头函数与普通函数的四个区别

四个区别里只有第一个天天咬人，后三个属于「知道就行」[^1]。

### ① `this` 指向不同

```js
const obj = {
  name: "鲸娘",
  say() {
    console.log(this.name);
  },
  sayArrow: () => {
    console.log(this.name);
  },
};

obj.say(); // "鲸娘"
obj.sayArrow(); // 取决于运行环境，见下一节
```

普通函数的 `this` 是**「谁调用我，我就是谁」**；箭头函数的 `this` 是**「我在哪出生，我就是谁家的」**，而且一辈子不变。

### ② 箭头函数没有自己的 `arguments`

```js
function f() {
  console.log(arguments); // 能用，是类数组
}

const g = () => {
  console.log(arguments); // 取外层作用域的 arguments，外层没有就 ReferenceError
};
```

注意 `arguments` 是**类数组**——只有 `length` 和下标，没有 `map`、`filter`。现代写法一律改用剩余参数 `...args`，它拿到的是真数组。

### ③ 箭头函数不能当构造函数

```js
const A = () => {};
new A(); // TypeError: A is not a constructor
```

### ④ 箭头函数没有 `prototype`

```js
function f() {}
console.log(f.prototype); // {constructor: f}

const g = () => {};
console.log(g.prototype); // undefined
```

## this 是谁，由什么决定

| 函数类型 | `this` 何时确定        | 由谁决定                     |
| :------- | :--------------------- | :--------------------------- |
| 普通函数 | **调用时**             | 点号前面的对象 / `call` 传的 |
| 箭头函数 | **定义时**（且永不改变） | 定义处外层作用域的 `this`    |

所以 `John.say()` 的 `this` 是 `John`，因为调用形式里点号前面就是 `John`；而箭头函数不看怎么调用，只看写在哪。

### 为什么对象里的箭头函数打印出空行

```js
const John = {
  name: "John",
  say() {
    console.log(this.name); // "John"
  },
  sayArrow: () => {
    console.log(this.name); // 空行
  },
};
```

箭头函数的 `this` 是**对象字面量外层**的 `this`，和 `John` 没有任何关系。
在浏览器普通 `<script>` 里，外层 `this` 是 `window`，而 **`window.name` 是个内置属性，默认值恰好是空字符串 `""`**——`console.log("")` 就打印出一个空行。

**不是 `undefined`，也不是箭头函数「返回空」**，是 `window.name` 的巧合。验证一下：

```js
console.log(window.name); // ""
```

换个环境结论就变了：

| 环境                        | 外层 `this`      | `this.name`      | 输出        |
| :-------------------------- | :--------------- | :--------------- | :---------- |
| 浏览器普通 `<script>`       | `window`         | `""`             | 空行        |
| 浏览器 ES Module / 严格模式 | `undefined`      | 抛 `TypeError`   | 异常        |
| Node.js 模块作用域          | `module.exports` | `undefined`      | `undefined` |

严格模式下 `this` 的默认值是 `undefined` 而不是 `window`，这也是普通 `<script>` 里值得加 `"use strict"` 的原因之一，详见[严格模式与作用域链](use-strict.md)。

### 四种绑定

| 绑定方式 | 写法                                          | `this`                             |
| :------- | :-------------------------------------------- | :--------------------------------- |
| 默认绑定 | `fn()`                                        | 非严格模式 `window`，严格模式 `undefined` |
| 隐式绑定 | `obj.fn()`                                    | `obj`                              |
| 显式绑定 | `fn.call(obj)` / `fn.apply(obj)` / `fn.bind(obj)()` | `obj`                        |
| 箭头函数 | 任何写法                                      | 定义处外层的 `this`，改不了        |

`new fn()` 是第五种绑定，属于面向对象话题。

`call` 和 `apply` 只有传参形式不同（`apply` 收数组），两者都**立即执行**；`bind` **不执行**，返回一个 `this` 已固定的新函数：

```js
function greet(greeting, punct) {
  console.log(greeting + ", " + this.name + punct);
}
const user = { name: "鲸娘" };

greet.call(user, "你好", "!"); // 你好, 鲸娘!
greet.apply(user, ["你好", "!"]); // 同上
const bound = greet.bind(user, "你好");
bound("!"); // 你好, 鲸娘!
```

### 一句话规则

**对象的方法不要用箭头函数**，除非你明确需要它捕获外层 `this`——典型场景是在 `setTimeout` 回调里沿用外层的 `this`[^2]。

## 参数：默认值、剩余参数与展开

```js
function greet(name = "无名鲸鱼") {
  return "你好，" + name;
}
greet(); // "你好，无名鲸鱼"
greet("主人"); // "你好，主人"

function sum(...nums) {
  return nums.reduce((a, b) => a + b, 0);
}
sum(1, 2, 3, 4); // 10
```

`...` 是同一个符号，**位置决定含义**：在函数参数位置是「收集」，在别处是「展开」。

```js
const arr = [1, 2, 3];
console.log(...arr); // 1 2 3
const copy = [...arr]; // 复制数组
const merged = [...arr, 4, 5]; // 合并
const obj2 = { ...obj1, x: 1 }; // 复制 / 合并对象
```

## 返回值与 ASI 坑

规则很短：没有 `return`、或 `return` 后面不写值，都返回 `undefined`；`return` 后面写什么就返回什么，之后的代码不执行。

```js
function f() {
  // 注意：return 后面故意不写分号
  return
  42; // 这一行永远执行不到
}
f(); // undefined
```

原因是**自动分号插入（ASI）**：JS 在 `return` 的换行处补了一个分号，函数当场返回 `undefined`，`42` 成了永远执行不到的死代码。
所以 **`return` 的值必须和 `return` 写在同一行**。

## 立即执行函数（IIFE）

```js
(function () {
  console.log("我马上执行");
})();

(() => {
  console.log("箭头版");
})();
```

作用只有一个：**创建一个独立作用域，避免污染全局**。现在基本被块级作用域和 ES Module 替代，只在读老代码时会遇到——[计数器](counter.md) 里用它配合闭包把状态私有化，就是这种用法。

## 结语

写函数前先问一句「这个 `this` 是给谁用的」：给调用者用就写普通函数，要沿用外层就写箭头函数。
读别人代码时，看到 `return` 换行、看到对象方法写成箭头函数，先怀疑这两个坑。

[^1]: [MDN Arrow functions](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Functions/Arrow_functions) 四个限制的规范说明

[^2]: [MDN this](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Operators/this) 绑定规则与严格模式下的默认值
