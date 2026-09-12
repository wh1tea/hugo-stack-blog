---
title: 从零实现猜数字游戏：一个前端小项目的完整迭代之路
slug: guess-game-tutorial
date: 2026-09-03T10:00:00+08:00
description: 从空白文件开始，逐步构造一个完整的猜数字游戏，涵盖 HTML 骨架、样式美化、交互逻辑与状态管理，适合前端初学者建立项目思维。
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

本文面向刚接触前端、只会基础 HTML/CSS/JS 语法，却不知如何组织一个小项目的开发者。我们将抛弃“一口气贴完所有代码”的教学方式，把一个完整的猜数字游戏拆解为 **4 个迭代版本**，从“能用”到“好用”，让小白理解工程化的渐进式思维。完整代码见[codepen](https://codepen.io/wh1tea/pen/MWmPMab)

## 第一次迭代：搭起 HTML 骨架（最小可执行界面）

我们不做任何交互，先完成最小的静态界面。新建 `index.html`，写入基础结构：

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Number Guessing Game</title>
  </head>
  <body>
    <h1>Number Guessing Game</h1>
    <p>Random number range 1~100, you have only 10 chances.</p>

    <div class="form">
      <label for="guessField">Enter your guess: </label>
      <input type="number" id="guessField" min="1" max="100" />
      <button id="submitBtn">Submit</button>
    </div>

    <div class="resultParas">
      <p class="guesses"></p>
      <p class="lastResult"></p>
      <p class="lowOrHi"></p>
    </div>

    <button id="resetBtn" hidden>New Game</button>
  </body>
</html>
```

此时页面没有逻辑，点击按钮无反应，但语义化的标签（`label`、`button`）已经为无障碍和后续 JS 选挂载点做好了准备。

## 第二次迭代：植入 JavaScript 灵魂（核心玩法）

第二步引入核心脚本：生成随机数、读取输入、比较大小并给出即时反馈。直接在 `body` 末尾添加 `<script>` 标签：

```html
<script>
  const MIN = 1;
  const MAX = 100;
  let randomNumber = Math.floor(Math.random() * (MAX - MIN + 1)) + MIN;

  const guessInput = document.querySelector("#guessField");
  const submitBtn = document.querySelector("#submitBtn");
  const lastResult = document.querySelector(".lastResult");
  const lowOrHi = document.querySelector(".lowOrHi");

  function checkGuess() {
    const rawValue = guessInput.value;
    if (rawValue === "") {
      lastResult.textContent = "Please enter a number!";
      return;
    }
    const userGuess = Number(rawValue);
    if (userGuess < MIN || userGuess > MAX) {
      lastResult.textContent = `Please enter a number between ${MIN} and ${MAX}!`;
      guessInput.value = "";
      return;
    }

    if (userGuess === randomNumber) {
      lastResult.textContent = "Congratulations, you got it!";
      lastResult.style.backgroundColor = "green";
      lastResult.style.color = "white";
      lowOrHi.textContent = "";
    } else {
      const hint = userGuess < randomNumber ? "Too low!" : "Too high!";
      lowOrHi.textContent = `Last guess: ${hint}`;
      lastResult.textContent = "Wrong!";
      lastResult.style.backgroundColor = "red";
      lastResult.style.color = "white";
    }
    guessInput.value = "";
    guessInput.focus();
  }

  submitBtn.addEventListener("click", checkGuess);
</script>
```

此时游戏已可运行，但缺乏回合限制，且重置需要刷新页面。

## 第三次迭代：完善游戏闭环（状态与重置）

为了提升完整性，引入 `guessCount` 计数和 **10 次封顶** 逻辑，并实现 `resetGame` 函数：

```html
<script>
  // ... previous global variables
  let guessCount = 0;
  const MAX_GUESSES = 10;
  const guessesPara = document.querySelector(".guesses");
  const resetBtn = document.querySelector("#resetBtn");

  function recordGuess(guess) {
    if (guessCount === 0) guessesPara.textContent = "Previous guesses: ";
    guessesPara.textContent += guess + " ";
  }

  function endGame() {
    guessInput.disabled = true;
    submitBtn.disabled = true;
    resetBtn.hidden = false;
  }

  function resetGame() {
    randomNumber = Math.floor(Math.random() * (MAX - MIN + 1)) + MIN;
    guessCount = 0;
    guessesPara.textContent = "";
    lastResult.textContent = "";
    lastResult.style.backgroundColor = "transparent";
    lastResult.style.color = "black";
    lowOrHi.textContent = "";
    guessInput.disabled = false;
    submitBtn.disabled = false;
    resetBtn.hidden = true;
    guessInput.value = "";
    guessInput.focus();
  }

  function checkGuess() {
    // ... validation
    recordGuess(userGuess);
    guessCount++;

    if (userGuess === randomNumber) {
      // ... success feedback
      endGame();
    } else if (guessCount === MAX_GUESSES) {
      lowOrHi.textContent = `No more chances, the correct number was ${randomNumber}`;
      lastResult.textContent = "Game Over!";
      lastResult.style.backgroundColor = "red";
      endGame();
    } else {
      // ... error feedback
    }
    guessInput.value = "";
  }

  resetBtn.addEventListener("click", resetGame);
</script>
```

此时游戏具备完整的生命周期：开始、进行、胜利/失败、重置。

## 第四次迭代：打磨细节（无障碍与键盘交互）

为了让产品更专业，做两项优化：

1. **键盘支持**：输入框按 `Enter` 触发提交。
2. **无障碍实时反馈**：使用 `<output>` 替代 `<p>` 作为结果显示容器，替代冗余的 `aria-live` 和 `role`。规范指出，`<output>` 默认具有 `aria-live="polite"` 语义，且无需额外角色声明。

修改 HTML 结构（关键行）：

```html
<!-- Replace the original <p class="lastResult"></p> with -->
<output class="lastResult"></output>
<!-- Remove the aria-live and role attributes from the parent .resultParas container -->
```

JS 追加键盘事件：

```javascript
guessInput.addEventListener("keydown", (event) => {
  if (event.key === "Enter") {
    event.preventDefault();
    submitBtn.click();
  }
});
```

同时，为了符合现代 CSS 规范，将样式中的背景色逻辑剥离为独立类（`.success`、`.error`），由 JS 切换类名而非直接操作内联样式。这是可维护性的重要一步。

## 最终完整代码

经过 4 次迭代，我们得到了一个逻辑清晰、交互流畅、适配无障碍标准的最小项目。

## 结语

回顾整个开发过程，我们并非一次成型，而是通过 **“界面搭建 → 逻辑验证 → 状态闭环 → 体验优化”** 的节奏逐步推进。这种“最小可行产品”（MVP）的迭代思路同样适用于任何复杂项目：先跑通核心流程，再横向扩展功能，最后纵向打磨细节。

**行动建议**：将此代码保存为本地 `.html` 文件，亲手在浏览器中打开，按 `F12` 调试逐行理解。然后尝试为其增加难度选择（如 1~1000）、计分板或暗色模式——那将是你迈向下一个台阶的起点。
