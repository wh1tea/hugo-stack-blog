---
title: JS 类型检测与类型转换
slug: js-type-conversion
date: 2026-09-28T12:45:00+08:00
description: JS 的 7 种原始类型、typeof 的 8 种返回值与 3 类类型检测手段，以及显式与隐式类型转换的完整规则表和踩坑点。
tags:
  - javascript
  - type-coercion
  - typeof
categories:
  - web
draft: false
---

判断一个值「到底是什么」，在 JS 里有两件事要做：先分清原始类型和引用类型，再用对检测手段。
做错这两步不会报错，只会静默给出错误结果——`typeof null`、`"4px" - 2`、`0 == ""` 都属于这一类。

## 原始类型与引用类型

JS 有 7 种原始类型：`number`、`string`、`boolean`、`null`、`undefined`、`symbol`、`bigint`[^1]。
其余全是引用类型——`object` 一个类型统管数组、函数、`Date`、`Map`。

两个容易记错的地方：`number` 没有 int / float 之分，整数和小数是同一个类型；`null` 是**人为赋的空值**，`undefined` 是**系统给的未定义**，语义不能互换。

## typeof 的 8 种返回值

`typeof` 是**一元运算符**，不是函数——`typeof(x)` 里的括号只是分组[^2]。

| 表达式                    | 结果          |
| :------------------------ | :------------ |
| `typeof undefined`        | `"undefined"` |
| `typeof true`             | `"boolean"`   |
| `typeof 42`               | `"number"`    |
| `typeof 42n`              | `"bigint"`    |
| `typeof "hi"`             | `"string"`    |
| `typeof Symbol()`         | `"symbol"`    |
| `typeof function () {}`   | `"function"`  |
| `typeof {}` / `typeof []` | `"object"`    |

**没有** `"null"`、`"array"`、`"NaN"` 这几种返回值——这是初学时最常找错的地方。

### 坑 1：`typeof null === "object"`

JS 最古老的 bug，一直没修（修了会破坏大量老代码）。判断 `null` 必须单独写：

```js
const isNull = (v) => v === null;
```

### 坑 2：数组也是 `"object"`

```js
Array.isArray([]); // true
Object.prototype.toString.call([]); // "[object Array]"
```

`Array.isArray` 够用；需要区分 `Date`、`RegExp` 等具体内置类型时才用 `Object.prototype.toString`。

### 坑 3：`typeof` 未声明变量不报错，TDZ 里的会

```js
typeof notDefined; // "undefined"，不报错

typeof x; // ReferenceError
let x;
```

第一行是 `typeof` 的特权，别的运算符直接引用未声明变量会抛 `ReferenceError`。
第二行是例外：`let` / `const` 声明的变量在**暂时性死区（TDZ）**里，`typeof` 一样会抛错。

## 判断类型的三种手段

| 目的            | 写法                                  |
| :-------------- | :------------------------------------ |
| 判断原始类型    | `typeof v`                            |
| 判断数组 / 数字 | `Array.isArray(v)`、`Number.isNaN(v)` |
| 判断具体内置类  | `Object.prototype.toString.call(v)`   |

判数字时 `typeof v === "number"` 不等于安全：`NaN` 和 `Infinity` 都是 `"number"`。
需要「真数字」时两个条件要成对出现：

```js
typeof n === "number" && Number.isFinite(n); // NaN 与 Infinity 都被挡掉
```

## 显式转换

`Number` / `String` / `Boolean` 三个构造函数能当转换函数用，一元 `+` 等价于 `Number()`。

| 输入                 | `Number()`  | `String()`                 | `Boolean()` |
| :------------------- | :---------- | :------------------------- | :---------- |
| `""` / `"  "`        | `0`         | `""`                       | `false`     |
| `"12px"`             | `NaN`       | `"12px"`                   | `true`      |
| `null` / `undefined` | `0` / `NaN` | `"null"` / `"undefined"`   | `false`     |
| `[]` / `{}`          | `0` / `NaN` | `""` / `"[object Object]"` | `true`      |

两处反直觉：空数组转数字得 `0`，`String(null)` 得到的是字符串 `"null"`（不是空串）。
`Boolean()` 只对 **8 个 falsy 值**返回 `false`：`false`、`0`、`-0`、`0n`、`""`、`null`、`undefined`、`NaN`。
**`[]` 和 `{}` 都是 truthy**。

需要从字符串里「尽量抠出数字」时用 `parseInt`，它遇到非数字字符就停：

```js
parseInt("12px", 10); // 12
parseInt("08", 10);   // 8     第二个参数是进制，必须写
Number("12px");       // NaN
```

## 隐式转换

`+` 和 `-` 对字符串的态度完全不同，由此产生了整张需要背下来的表：

| 表达式          | 结果        | 原因                                          |
| :-------------- | :---------- | :-------------------------------------------- |
| `"" + 1 + 0`    | `"10"`      | `"" + 1` 得到字符串 `"1"`，再加 `0` 得 `"10"` |
| `"" - 1 + 0`    | `-1`        | `-` 把 `""` 转成 `0`，`0 - 1 = -1`，再 `+ 0`  |
| `true + false`  | `1`         | `true → 1`，`false → 0`                       |
| `6 / "3"`       | `2`         | `"3"` 被转成数字                              |
| `"2" * "3"`     | `6`         | 两个字符串都转成数字                          |
| `4 + 5 + "px"`  | `"9px"`     | 先算 `4 + 5 = 9`，再与字符串拼接              |
| `"$" + 4 + 5`   | `"$45"`     | 一旦是字符串拼接，后面全变字符串              |
| `"4" - 2`       | `2`         | `"4" → 4`                                     |
| `"4px" - 2`     | `NaN`       | `"4px"` 转不成有效数字                        |
| `"  -9  " + 5`  | `"  -9  5"` | `+` 遇到字符串就是拼接，不转数字              |
| `"  -9  " - 5`  | `-14`       | `-` 会把 `"  -9  "` 转成 `-9`                 |
| `null + 1`      | `1`         | `null → 0`                                    |
| `undefined + 1` | `NaN`       | `undefined → NaN`                             |
| `" \t \n" - 2`  | `-2`        | 纯空白字符串 `→ 0`                            |

四条规律覆盖了全表：

1. **`+` 只要有一边是字符串，就是字符串拼接**，不做数学加法。
2. **`-`、`*`、`/`、`%` 一律把操作数强制转成数字**。
3. **`null → 0`，`undefined → NaN`，纯空白字符串 `→ 0`。**
4. **转不成数字的字符串参与数学运算得 `NaN`**，且 `NaN` 会污染后续所有运算。

比较运算符同样会走隐式转换。`==` 的规则可以压成三条：**`null == undefined` 成立，且这两个值与其它任何值都不相等**；**布尔值先转数字**；**对象先经 `ToPrimitive` 转成原始值**，之后按「字符串与数字比较时字符串转数字」处理[^3]。
所以默认写 `===`；只有判断「值为空」时用 `v == null`，一次挡掉 `null` 和 `undefined`。

## 结语

养成两个反射：写判断先想「这个值可能是 `null`、数组还是 `NaN`」，写运算先看「有没有字符串混进来」。
`typeof` 只管原始类型，数组和数字边界必须另配 `Array.isArray` 与 `Number.isFinite`。

[^1]: [MDN primitive](https://developer.mozilla.org/zh-CN/docs/Glossary/Primitive) 原始值与包装对象的区别

[^2]: [MDN typeof](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Operators/typeof) 返回值表与暂时性死区行为

[^3]: [MDN Equality comparisons and sameness](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Operators/Equality) `==` 的类型转换步骤
