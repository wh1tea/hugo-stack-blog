---
title: 从零实现计数器：一个前端小项目的完整迭代之路
slug: counter
date: 2026-09-01T10:00:00+08:00
description: 从空白文件开始，用四次迭代构建一个带正负变色与本地存储的计数器，再检验你对 HTML、CSS、JavaScript 的真实掌握。
tags:
  - javascript
  - html
  - css
  - tutorial
  - frontend
categories:
  - web
---

## 引言

面向刚接触前端、会基础 HTML/CSS/JS 语法却不知如何组织项目的开发者。我们将把一个计数器拆成 **4 次迭代**，从"能用"到"好用"，最后用**拷问**检验你是否真的掌握了每行代码。

最终效果：`+` `−` 增减计数并自动变色（正绿负红零黑），`Reset` 归零并弹出提示，`Save` / `Load` 用 `localStorage` 持久化，刷新页面后自动恢复上次保存的值。

**阅读建议**：跟着迭代动手写，写完后遮住下半部分先自测拷问题目，再对答案。

## 第一次迭代：HTML 骨架与静态界面

先搭最小可运行的静态页面。新建 `index.html`，写入完整结构：

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Counter</title>
    <style>
      * {
        margin: 0;
        padding: 0;
      }
      body {
        font-family: Arial, sans-serif;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        min-height: 100vh;
      }
      .container {
        padding: 2rem;
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        text-align: center;
        max-width: 300px;
        width: 100%;
      }
      button {
        font-size: 20px;
        margin: 5px;
        border: none;
        padding: 10px 20px;
        border-radius: 8px;
        cursor: pointer;
        transition: background-color 0.3s;
      }
      button:hover {
        background-color: lightgray;
      }
      #count {
        font-size: 40px;
      }
    </style>
  </head>
  <body>
    <main class="container">
      <h1>Counter</h1>

      <output id="count">0</output>

      <div>
        <button type="button" id="btnPlus" aria-label="Increase count">
          +
        </button>
        <button type="button" id="btnMinus" aria-label="Decrease count">
          −
        </button>
        <button type="button" id="btnReset" aria-label="Reset count">
          Reset
        </button>
        <button type="button" id="btnSave" aria-label="Save count">Save</button>
        <button type="button" id="btnLoad" aria-label="Load count">Load</button>
      </div>

      <p id="message" role="alert"></p>
    </main>
  </body>
</html>
```

此时页面没有逻辑，点按钮无反应，但三个细节是为后面铺路：

- **`<output>` 显示计数**：它语义上代表"计算或操作的结果"，浏览器内置 `role="status"` 角色，读屏软件会把它当作实时区域播报变化（详见第一轮拷问）。

- **`button type="button"`**：按钮默认 `type="submit"`，放进 `<form>` 会触发提交刷新页面，下面是演示代码。显式声明是防御习惯。

  ```html
  <form action="" method="GET">
    <label for="search">Search</label>
    <input id="search" type="text" name="q" placeholder="Input something" />
    <button>Submit (default)</button>
    <button type="button">Don't Submit</button>
  </form>
  <p>
    Click the first button: The page will refresh, and the address bar will show
    <code>?q=xxx</code> parameter (submission successful)<br />
    Click the second button: Nothing will happen
  </p>
  ```

详见[Your_first_form](https://developer.mozilla.org/zh-CN/docs/Learn_web_development/Extensions/Forms/Your_first_form)[^1]

- [`aria-label`](https://developer.mozilla.org/zh-CN/docs/Web/Accessibility/ARIA/Reference/Attributes/aria-label) 为无可见文本的交互元素（如图标按钮）提供屏幕阅读器专用的语音名称，并会覆盖元素自身的文本、`alt` 或关联 `<label>`，优先作为无障碍标签。[^2]

## 第二次迭代：让数字动起来

在 `</body>` 前追加 `<script>`，先实现增减与重置：

```html
<script>
  "use strict";

  const RESET_VALUE = 0;

  const countElement = document.getElementById("count");
  const plusButton = document.getElementById("btnPlus");
  const minusButton = document.getElementById("btnMinus");
  const resetButton = document.getElementById("btnReset");

  let currentCount = 0;

  function renderCount() {
    countElement.textContent = currentCount;
    countElement.classList.toggle("positive", currentCount > 0);
    countElement.classList.toggle("negative", currentCount < 0);
    countElement.classList.toggle("zero", currentCount === 0);
  }

  function setCount(newValue) {
    if (currentCount !== newValue) {
      currentCount = newValue;
      renderCount();
    }
  }

  function incrementCount() {
    setCount(currentCount + 1);
  }

  function decrementCount() {
    setCount(currentCount - 1);
  }

  function resetCount() {
    setCount(RESET_VALUE);
  }

  plusButton.addEventListener("click", incrementCount);
  minusButton.addEventListener("click", decrementCount);
  resetButton.addEventListener("click", resetCount);
</script>
```

同时在 CSS 里面添加 `.positive` / `.negative` / `.zero` 三种颜色类，使用 JS 切换类名。

```css
#count.positive {
  color: green;
}
#count.negative {
  color: red;
}
#count.zero {
  color: black;
}
#message {
  color: red;
  margin-top: 10px;
}
```

四个关键设计：

1. **DOM 引用一次性缓存**：`getElementById` 只查一次 DOM，之后全部走变量。查询放在脚本顶部，保证元素已渲染完毕。
2. **监听器传函数名不调用**：`incrementCount` 后面**没有括号**——括号是立刻执行，这里是把函数交给浏览器"点击时再调用"。
3. **状态与渲染分离**：所有改动经 `setCount` 写入 `currentCount` 再调 `renderCount()`，这是"单一数据源 + 集中渲染点"的雏形。

### Toggle

**`classList.toggle(class, boolean)`**：第二个参数是"强制开关"，`currentCount > 0` 为真就加类、为假就移除。三个类互斥，正好表达正/负/零三态。`.zero` 显式设黑保证三态配色恒定防止颜色飘逸：以后 `body` 的继承文字色无论怎么变，正绿、负红、零黑都不会漂移。

```js
(method) DOMTokenList.toggle(token: string, force?: boolean): boolean

The toggle() method of the DOMTokenList interface removes an existing token from the list and returns false. If the token doesn't exist it's added and the function returns true.

MDN Reference
```

force 强制开关

- 如果 `force` 是 **`true`**：不管这个类现在有没有，**强制加上**。
- 如果 `force` 是 **`false`**：不管这个类现在有没有，**强制移除**。
- 如果 **不写** 第二个参数：才是真正的“切换”——有就删，没有就加。

所以，它本质上不是“切换”，而是“**根据布尔值设定类的存在状态**”。

验证：

把第二行改成 `countElement.classList.toggle("negative", currentCount >= 0);`，当 `currentCount = 0` 时，`positive`、`negative`、`zero` 三个类会变成`positive` 被移除，`negative` 和 `zero` 同时存在，最终颜色由 CSS 样式表中规则的先后顺序决定显示为**黑色**。

[MDN Reference](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/toggle)

## 第三次迭代：即时反馈消息

`Reset` 后用户不知道发生了什么，加一条 3 秒后自动消失的提示。先取 `message` 元素并追加函数：

```javascript
// ... 第二次迭代的代码保持不变

const MESSAGE_DURATION = 3000;
const messageElement = document.getElementById("message");

let messageTimer = null;

function showMessage(text) {
  messageElement.textContent = text;
  if (messageTimer) {
    clearTimeout(messageTimer);
  }
  messageTimer = setTimeout(() => {
    messageElement.textContent = "";
    messageTimer = null;
  }, MESSAGE_DURATION);
}
```

`resetCount` 里加一行：

```javascript
function resetCount() {
  setCount(RESET_VALUE);
  showMessage("Count reset!");
}
```

`showMessage` 里有一处容易被忽略的细节：**先 `clearTimeout` 再设新定时器**。如果用户 1 秒内连点两次 `Reset`，第一个定时器还没触发就被清掉重计——消息不会提前消失。若省略这行，第二次点击后旧定时器仍会按时清空新消息，表现为"提示只闪一下就没了"。

`#message` 带 `role="alert"`，读屏软件会立即播报其中的文本（alert 角色隐含"打断式"实时区域），适合错误与重要反馈。

## 第四次迭代：保存与恢复

最后加入 `Save` / `Load`，让计数在刷新后不丢失：

```javascript
// ... 前三次迭代的代码保持不变

const STORAGE_KEY = "count";

const saveButton = document.getElementById("btnSave");
const loadButton = document.getElementById("btnLoad");

function saveCount() {
  try {
    localStorage.setItem(STORAGE_KEY, String(currentCount));
    showMessage("Count saved!");
  } catch (e) {
    console.error("Failed to save count:", e);
    showMessage("Failed to save count. Please check storage permissions.");
  }
}

function loadCount(silent) {
  let msg = "";
  let newValue = currentCount;

  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved === null) {
      msg = "No saved data found";
    } else {
      const parsed = Number(saved);
      if (!Number.isNaN(parsed)) {
        newValue = parsed;
        msg = "Count loaded!";
      } else {
        msg = "Invalid saved data";
      }
    }
  } catch (e) {
    console.error(e);
    msg = "Failed to load count. Please check storage permissions.";
  }

  setCount(newValue); // setCount 内部会判断是否变化，避免重复渲染

  if (!silent) {
    showMessage(msg);
  }
}

saveButton.addEventListener("click", saveCount);
loadButton.addEventListener("click", () => loadCount(false));

// 启动时静默加载：刷新后自动恢复上次保存的值
loadCount(true);
```

要理解的知识点：

- **`localStorage` 只能存字符串**：`setItem` 前用 `String(currentCount)` 显式转换；`getItem` 无数据时返回 `null`（不是 `undefined` 或 `""`），这是判断"从未保存过"的依据。
- **`try-catch` 的必要性**：隐私模式、禁用 Cookie 的浏览器里访问 `localStorage` 会抛 `SecurityError`，不捕获的话整个脚本中断。
- **脏数据校验**：存储内容可被用户或脚本篡改。`Number(saved)` 把字符串转数字，`Number.isNaN` 检查转换失败的情况（`Number` 和 `isNaN` 的差异见第四轮拷问）。
- **`silent` 参数**：启动恢复不应该弹提示打扰用户，所以传 `true` 静默执行；点 `Load` 按钮则要反馈，用箭头函数 `() => loadCount(false)` 显式传 `false`（为什么不直接绑 `loadCount`，见第五轮拷问）。
- **启动即恢复**：`loadCount(true)` 放在脚本末尾，页面一打开就回到上次 Save 的数值，`Load` 按钮则用于运行中手动恢复。[^3]

## 组装与试玩

把代码按顺序拼进同一个 `index.html`（迭代一的 HTML/CSS + 迭代二三四追加进 `<script>`），浏览器打开：

- 连点 `+` 数字变绿、`−` 变红、归零回黑；
- 点 `Reset` 弹出 "Count reset!"，3 秒后自动消失；
- 点 `Save` 后再刷新页面，计数自动恢复（启动静默加载）；
- 清空数据后点 `Load`，提示 "No saved data found"。

代码里留了两个"坑"，先别修，等拷打部分揭晓：`Reset` 后按 `−` 会出现什么？存储被改成 `"Infinity"` 会怎样？

## 检验你的掌握

下面是 10 道针对本项目的拷问，按主题分 5 轮、难度递增。**先遮住答案自己回答**，再看解析。每轮解析里会标注新手（包括当初的我）最容易掉进去的"常见误区"。

### 第一轮：HTML 语义与可访问性

1. 为什么计数显示用 `<output>` 而不是 `<div>` 或 `<span>`？
2. `aria-live="polite"` 的作用是什么？改成 `assertive` 对读屏用户有何不同？`#count` 需要加 `aria-valuenow` 吗？

**参考答案与解析**

1. `<output>` 是 HTML5 表单元素，语义为"计算或用户操作的结果"，正好对应计数器。它的隐式 ARIA 角色是 `role="status"`，而 status 角色自带 `aria-live="polite"` 的实时播报行为——值变化时读屏软件会自动读出，`<div>` / `<span>` 没有这些语义，改了也不播报。它还支持 `for` 属性关联触发它的表单控件。代码里在 `<output>` 上又显式写了 `aria-live="polite"`，属于冗余但无害的双保险，教学上更直白（对比[猜数字游戏](../guess-game-tutorial.md)那篇用 `<output>` 直接取代显式 `aria-live` 的更简写法）。[^4]

2. `polite` 表示"等读屏软件当前语音播完再播报"；`assertive` 表示"立刻打断当前语音、马上播报"。计数器每点一下数字就变，若用 `assertive` 会反复打断用户听别的，体验很差；`polite` 排队播报才是对的。`aria-valuenow` 是给范围类控件（`slider` / `progressbar` / `spinbutton` 等）声明"当前取值"用的属性；`<output>` 的文本本身就会被读出，加它不产生额外作用，当前计数器也没有上限/范围语义，**不加完全没问题**。

> 常见误区：`assertive` 是"立即打断播报"；`aria-valuenow` 也不是 live region 的必配项，加了不等于"方便用户选择"——这里根本没有"选择"的交互。

### 第二轮：CSS 布局与按钮设计

1. 容器 `max-width: 300px`，手机竖屏下按钮容易换行。如果希望按钮在窄屏**水平滚动**而不是换行，怎么改？更通用的响应式思路呢？
2. 五个按钮 hover 样式完全一样（变 `lightgray`），UX 上有什么缺点？如何按操作类型区分？

**参考答案与解析**

1. 先给按钮容器加个类名（原代码的 `<div>` 没有类，是隐患），再：

```css
.controls {
  display: flex; /* 弹性盒让按钮排成一行 */
  overflow-x: auto; /* 溢出时水平滚动 */
  white-space: nowrap; /* 防止子元素换行 */
}

.controls button {
  flex-shrink: 0; /* 关键：禁止按钮被压缩变形 */
}
```

两条路各有适用场景：**横向滚动**适合按钮很多（10+）时保留一行；本项目只有 5 个按钮，**`flex-wrap: wrap` 换行成两排**更自然，用户不用滑动就能看到全部。更细的做法是加媒体查询，窄屏时缩小按钮 `padding` 和字号，让 5 个按钮能放下。

1. 五个按钮分属三种职责：**数值操作**（`+` `−`）、**破坏性操作**（`Reset` 清空计数）、**持久化操作**（`Save` / `Load`）。hover 全部灰成一片，用户无法预判操作风险——误触 `Reset` 会丢掉当前计数。

建议分层：

| 分组     | 按钮            | 视觉建议                         |
| -------- | --------------- | -------------------------------- |
| 数值操作 | `+` `−`         | 主按钮：大触区、高对比背景色     |
| 破坏性   | `Reset`         | 警示色（如红），与主按钮明显区分 |
| 持久化   | `Save` / `Load` | 次级按钮：描边或文字样式         |

注意不能只靠颜色区分（色弱用户看不出差别），配合文字、`aria-label` 与位置分组才完整。代码已给每个按钮写了 `aria-label`，这步做得对。

### 第三轮：JavaScript 核心逻辑

1. `setCount` 里的 `if (currentCount !== newValue)` 有什么好处？代码中是否存在绕过 `setCount` 直接改 `currentCount` 的路径？
2. `loadCount` 在本地无数据（`saved === null`）时保持当前值不变、只提示 "No saved data found"。这个行为合理吗？如果希望"加载"时无数据则归零，怎么改？

**参考答案与解析**

1. 好处是**避免无意义的 DOM 写入**：值没变时 `textContent` 赋值和三次 `classList.toggle` 都是白做。而且它让"加载无数据"这种场景天然不触发重渲染。逐条检查写入点：`incrementCount` / `decrementCount` / `resetCount` / `loadCount` 全部是先算新值再调 `setCount`，**没有任何绕过**。`currentCount` 是唯一状态源，`setCount` 是唯一入口，"状态必与界面同步"的不变量由此成立。

2. 合理——"加载"的语义是"恢复已保存的值"，从未保存过就不该动界面，这正是产品语义的边界。如果你想要的是"**加载默认值**"语义（无数据时归零），不需要碰 `localStorage`，只需改变量初值：

```javascript
// loadCount 里把默认值从 currentCount 改为 RESET_VALUE
let newValue = RESET_VALUE;
```

或者给 `loadCount` 加一个 `useDefaultWhenEmpty` 参数，让两种语义共存。两种设计都行，但要先想清楚产品要哪种。

> 常见误区：原回答"在 localStorage 里设置成 0"方向错了——那是**写**存储，而这里讨论的是**读**不到数据时怎么办，改 `newValue` 的初值即可。

### 第四轮：错误处理与健壮性

1. 为什么用 `Number.isNaN` 而不是全局 `isNaN`？`Number.isFinite` 缺失会埋下什么雷？换成 `JSON.parse` 解析存储值会怎样？
2. `loadCount` 的 `catch` 分支里有一处重复赋值，你发现了吗？有什么问题？[^5]

**参考答案与解析**

1. 两者最核心的区别是**是否先做类型转换**：

| 表达式                             | 结果            | 原因                             |
| ---------------------------------- | --------------- | -------------------------------- |
| `isNaN("abc")`                     | `true`          | 先把 `"abc"` 转数字得 `NaN`      |
| `Number.isNaN("abc")`              | `false`         | 不做转换，`"abc"` 本身不是 `NaN` |
| `isNaN(NaN)` / `Number.isNaN(NaN)` | `true` / `true` | 两者一致                         |

`localStorage` 的值是外部输入、类型不可信，用 `Number.isNaN` 可以避免"非数字字符串被误判为非法数字"这类脏类型误判，这就是代码注释里那句选择的理由。

真正的雷在 `Number.isFinite`：`Number("Infinity")` 返回 `Infinity`，`Number.isNaN(Infinity)` 是 `false`——校验通过！于是计数器显示 `Infinity`，之后加减运算结果依然是 `Infinity`，界面永久卡死。**NaN 检查不等于数值安全**，修复只需加一个条件：

```javascript
if (!Number.isNaN(parsed) && Number.isFinite(parsed)) {
  newValue = parsed;
  msg = "Count loaded!";
}
```

换成 `JSON.parse` 的话，行为完全不同：`JSON.parse("42")` 得 `42` 可用，但 `JSON.parse("abc")` 会**抛 `SyntaxError`**（而不是返回 `NaN`），`JSON.parse("Infinity")` 同样抛错——JSON 语法里根本没有 `Infinity`。所以 `JSON.parse` 更严格、天然挡掉 `Infinity`，但非 JSON 内容要靠 `catch` 兜底。若未来存储结构升级为 JSON 对象，就必须切换到它。

> 常见误区：以为 `Number.isNaN` 通过就万事大吉——字符串 `"Infinity"`、超大数（溢出为 `Infinity`）都会溜进来，数值校验要 `isNaN` + `isFinite` 成对使用。

1. 发现了——`catch` 里先给 `msg` 赋了带具体错误信息的字符串（`Load failed: ...`，含 `e.message`），紧接着又被下一行 `msg = "Failed to load count. Please check storage permissions.";` **覆盖**，第一行成了永不生效的死代码。问题在于：开发期最需要的具体错误信息（`e.message`）被丢掉了，用户只看到笼统提示。修复是删掉其中一行，或合并成更细粒度的消息（如 `Load failed: ${e.message}`）。这正是"写了 try-catch 但没走查一遍"的典型漏网之鱼。

### 第五轮：事件绑定与代码组织

1. 为什么 `Load` 按钮绑 `() => loadCount(false)`，而 `Save` 直接绑 `saveCount`？可以直接绑 `loadCount` 吗？
2. 所有函数都挂在全局作用域。若要嵌入大项目或写单元测试，如何重构得更模块化、可测试？给出两种方案。

**参考答案与解析**

1. 直接绑会出 bug，原因是 `addEventListener` 的回调**总会收到一个 `Event` 对象作为第一个实参**：

```javascript
// loadCount(silent) 的 silent 会被 MouseEvent 对象占据（truthy）
loadButton.addEventListener("click", loadCount);
// 等价于 loadCount(mouseEvent)，silent 永远为真 → 永远静默
```

点击后 `silent` 是事件对象而不是 `false`，`if (!silent)` 恒为假，消息永不显示，用户以为按钮坏了。箭头函数 `() => loadCount(false)` 显式传参绕开了这个问题；也可以用 `bind` 固定参数：

```javascript
loadButton.addEventListener("click", loadCount.bind(null, false));
```

`saveCount` 不接收参数，直接绑定时多收一个事件对象也无害，所以两种写法都行。规律是：**回调期望的签名与函数参数对不上时，就用箭头函数包一层或 `bind` 预置参数**。[^6]

> 常见误区：把带参函数名直接传给 `addEventListener`，参数被事件对象悄悄覆盖——这是"看起来能跑、行为全错"的隐蔽 bug。

1.  全局作用域的问题：所有变量/函数挂到 `window` 上互相污染；函数隐式共享状态，无法单独测试（测 `renderCount` 得先造出 DOM）；脚本加载顺序敏感；换个页面无法复用。两种重构方案：

方案 A，**类 + 构造注入**（可测试性最好）：

```javascript
class Counter {
  #count = 0; // 私有字段，外部无法直接改
  #countElement; // DOM 依赖由外部注入

  constructor(countElement) {
    this.#countElement = countElement;
  }

  get value() {
    return this.#count;
  }

  increment() {
    this.#set(this.#count + 1);
  }

  #set(value) {
    // 唯一的写入口
    if (this.#count !== value) {
      this.#count = value;
      this.#countElement.textContent = value;
    }
  }
}

const counter = new Counter(document.getElementById("count"));
counter.increment();
```

方案 B，**IIFE + 闭包**（隐藏内部实现，暴露最小接口）：

```javascript
const Counter = (() => {
  let count = 0; // 闭包变量，外部不可见
  return {
    increment() {
      count++;
    },
    get value() {
      return count;
    },
  };
})();
```

两者都把"状态私有化"作为核心：外部只能通过公开方法改状态，DOM 依赖要么注入要么藏在闭包里，测试时传一个假的元素即可。进一步还可以用 ES Module（`export` / `import`）把代码拆成独立文件。

## 结语

回顾整条路径：**骨架 → 核心交互 → 反馈打磨 → 持久化健壮**，和[猜数字游戏](../guess-game-tutorial.md)的"先跑通、再完善、后打磨"是同一套 MVP 迭代思维。而十道拷问暴露的薄弱点也很有代表性：读屏语义的精确含义、数值边界的成对校验、回调参数被事件对象覆盖、全局状态与模块化——每一条都是真实项目里会咬人的坑。

动手验证：

1. 修掉 `Infinity` 漏洞（第四轮第 7 题，一行 `isFinite` 判断）；
2. 给 `loadCount` 增加"空数据归零"的可选参数，两种加载语义共存；
3. 用"类 + 注入"重构整个计数器（第五轮第 10 题）；
4. 把同样的问题拿去拷问猜数字游戏那篇代码，看它有没有类似的坑。

[^1]: [MDN `addEventListener`](https://developer.mozilla.org/zh-CN/docs/Web/API/EventTarget/addEventListener) 回调参数传递规则

[^2]: [MDN `aria-live`](https://developer.mozilla.org/zh-CN/docs/Web/Accessibility/ARIA/Attributes/aria-live) polite 与 assertive 的播报差异

[^3]: [MDN `localStorage`](https://developer.mozilla.org/zh-CN/docs/Web/API/Window/localStorage) 字符串存取与 SecurityError

[^4]: [MDN `<output>` 元素](https://developer.mozilla.org/zh-CN/docs/Web/HTML/Element/output) 计算结果语义与 `for` 属性

[^5]: [MDN `Number.isNaN` / `isFinite`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Number/isNaN) 无类型转换的数值判断

[^6]: [MDN `Function.prototype.bind`](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Function/bind) 预置函数参数
