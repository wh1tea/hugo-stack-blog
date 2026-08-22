---
title: 从零搭建 Ball Battle — 一个像素风小球对战游戏的诞生
date: 2026-07-30
description: 从画布上画一个绿色矩形开始，一步步构建出包含碰撞、技能、粒子特效的 4 球对战游戏。每个阶段都有完整可运行的代码。
tags:
  - javascript
  - canvas
  - game-development
  - tutorial
  - web
categories:
  - tutorial
---

这是一个从零开始用纯前端技术构建像素风小球对战游戏的系列教程。
读者需要基础 HTML/JavaScript 知识，不需要游戏开发经验。

最终项目代码在：[ball-battle](https://github.com/wh1tea/ball-battle)。
Git 仓库里每一步都有对应的 commit，可以随时 `git checkout` 查看某阶段的状态。

---

## 在画布上画出一个像素小球

### 创建画布

使用 HTML 的 `<canvas>` 元素创建画布

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Ball Battle</title>
  </head>
  <body>
    <canvas id="gameCanvas" width="300" height="300">
      抱歉，你的浏览器不支持 canvas
    </canvas>
    <script src="main.js"></script>
  </body>
</html>
```

在 `main.js` 中获取画布上下文：

```js
var canvas = document.getElementById("gameCanvas");
var ctx = canvas.getContext("2d");
ctx.fillStyle = "green";
ctx.fillRect(10, 10, 100, 100);
```

`VScode`使用插件`Live Server`在浏览器打开 `index.html`，你会在左上角看到一个绿色方块。这就是最基础的「能跑了」。

> `ctx` 是 **context** 的缩写，代表 2D 渲染上下文。通过它调用 `fillRect`、`fillText` 等方法在画布上绘制。

### 像素风 CSS

我们希望游戏看起来是像素风格，通过 CSS 让画布放大但不模糊：

```css
body {
  background: #1a1b1c;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
}
canvas {
  border: 2px solid #ff0000;
  width: 600px;
  height: 600px;
  image-rendering: pixelated;
  image-rendering: crisp-edges;
}
```

`pixelated`—— 像素化，`crisp-edges`——清晰边缘

### 绘制像素小球

用 `ctx.fillRect` 堆出一个圆形。核心思路：遍历一个正方形区域，只绘制那些落在圆内的方块。

```js
function drawPixelCircle(cx, cy, r, size, color) {
  for (let y = -r; y < r; y += size) {
    for (let x = -r; x < r; x += size) {
      const dx = x + size / 2;
      const dy = y + size / 2;
      if (dx * dx + dy * dy <= r * r) {
        ctx.fillStyle = color;
        ctx.fillRect(cx + x, cy + y, size, size);
      }
    }
  }
}
```

调用 `drawPixelCircle(150, 150, 30, 4, '#ffffff')` 就能在画布中央画出一个白色像素小球。

### 显示调试信息

```js
ctx.fillStyle = "#aaa";
ctx.font = "14px monospace";
ctx.fillText("位置 (150, 150)", 10, 20);
```

`fillText` 是 Canvas 绘制文本的方法，常用于调试信息的显示。

---

## 第二阶段：让小球动起来并实现边界反弹

### 动画循环

用 `requestAnimationFrame` 驱动游戏循环，保证帧率与浏览器刷新同步：

```js
var x = 150,
  y = 150;
var vx = 3,
  vy = 2;
var radius = 30;

function update() {
  x += vx;
  y += vy;
}

function draw() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  drawPixelCircle(x, y, radius, 4, "#ffffff");
}

function gameLoop() {
  update();
  draw();
  requestAnimationFrame(gameLoop);
}
requestAnimationFrame(gameLoop);
```

### 边界反弹

当小球碰到画布边缘时反转速度方向，同时把位置「夹」回边界内，防止卡在边缘：

```js
function update() {
  x += vx;
  y += vy;

  if (x < radius || x > canvas.width - radius) {
    vx = -vx;
    x = Math.max(radius, Math.min(canvas.width - radius, x));
  }
  if (y < radius || y > canvas.height - radius) {
    vy = -vy;
    y = Math.max(radius, Math.min(canvas.height - radius, y));
  }
}
```

碰撞检测的本质就这三步：移动 → 检查是否越界 → 反弹 + 修正位置。今后所有物理系统都基于这个模式扩展。

---

## 第三阶段：两个球碰撞 + 血量系统

### 多球对象

从单球变成多球，用对象存储状态：

```js
var ball1 = { x: 120, y: 200, vx: 3, vy: 2, radius: 30, hp: 100, maxHp: 100, color: '#
             ' };
var ball2 = { x: 480, y: 200, vx: -4, vy: -3, radius: 30, hp: 100, maxHp: 100, color: '#e94560' };
```

### 球与球的碰撞检测

两圆碰撞检测：计算圆心距离，如果小于半径之和则发生碰撞。

```js
function handleCollisions() {
  var dx = ball2.x - ball1.x;
  var dy = ball2.y - ball1.y;
  var dist = Math.sqrt(dx * dx + dy * dy);
  var minDist = ball1.radius + ball2.radius;
  if (dist >= minDist) return;

  // 位置修正：把两个球沿碰撞法线方向推开
  var overlap = (minDist - dist) / 2;
  var nx = dx / dist;
  var ny = dy / dist;
  ball1.x -= nx * overlap;
  ball1.y -= ny * overlap;
  ball2.x += nx * overlap;
  ball2.y += ny * overlap;

  // 速度交换（完全弹性碰撞，质量相等时简化）
  var dvx = ball1.vx - ball2.vx;
  var dvy = ball1.vy - ball2.vy;
  var dvn = dvx * nx + dvy * ny;
  if (dvn > 0) {
    ball1.vx -= dvn * nx;
    ball1.vy -= dvn * ny;
    ball2.vx += dvn * nx;
    ball2.vy += dvn * ny;
  }
}
```

### 血条绘制

每个球上方显示 HP 条，颜色随血量变化：

```js
function drawHpBar(ball) {
  var barWidth = ball.radius * 1.6;
  var barHeight = 6;
  var barX = ball.x - barWidth / 2;
  var barY = ball.y - ball.radius - 14;
  ctx.fillStyle = "#333";
  ctx.fillRect(barX, barY, barWidth, barHeight);
  var ratio = ball.hp / ball.maxHp;
  ctx.fillStyle =
    ratio > 0.5 ? "#4caf50" : ratio > 0.25 ? "#ff9800" : "#f44336";
  ctx.fillRect(barX, barY, barWidth * ratio, barHeight);
}
```

点击画布重置血量，让玩家可以反复测试碰撞效果。

---

## 第四阶段：面向对象重构 + 音效

### Ball 类

用 ES6 class 封装小球的所有属性和方法，让代码更整洁、易扩展：

```js
export class Ball {
  constructor(x, y, radius, color, blockSize) {
    this.x = x;
    this.y = y;
    this.vx = (Math.random() - 0.5) * 6;
    this.vy = (Math.random() - 0.5) * 6;
    this.radius = radius;
    this.color = color;
    this.blockSize = blockSize;
    this.hp = 100;
    this.maxHp = 100;
    this.alive = true;
  }
  update(canvasW, canvasH) {
    // 移动 + 反弹
  }
  draw(ctx) {
    // 像素块圆形绘制 + 血条
  }
  takeDamage(amount) {
    this.hp -= amount;
    if (this.hp <= 0) {
      this.hp = 0;
      this.alive = false;
    }
  }
}
```

> `export` 是 ES Module 的关键字，把当前文件中的类暴露给其他文件使用。

### Web Audio API 音效

用纯代码生成音效，不需要任何音频文件：

```js
// 碰撞音效 — 白噪声 + 指数衰减
export function playHitSound() {
  var ctx = new (window.AudioContext || window.webkitAudioContext)();
  var size = ctx.sampleRate * 0.08;
  var buffer = ctx.createBuffer(1, size, ctx.sampleRate);
  var data = buffer.getChannelData(0);
  for (var i = 0; i < size; i++) {
    data[i] = (Math.random() * 2 - 1) * Math.exp(-i / (size * 0.4));
  }
  var source = ctx.createBufferSource();
  source.buffer = buffer;
  source.connect(ctx.destination);
  source.start();
}
```

死亡音效用 sawtooth 波形 + 频率下降（从 500Hz 降到 80Hz），听起来像一声哀鸣。

### 死亡检测

用 `prevAlive` 数组追踪每球上一帧的存活状态，只在状态从「生」变「死」时播放一次死亡音效，避免重复触发。

---

## 第五阶段：特殊能力 + 回血道具

### 吸血鬼球

红色大球（半径 45），碰撞时按伤害的 30% 回血：

```js
// 在 handleCollisions 中计算伤害时
if (ball1 === vampireBall) {
  vampireBall.heal(baseDamage * (ball2.radius / avgRadius) * 0.3);
}
```

### 速度球

黄色小球（半径 15），每次碰撞速度提升 5%，上限 10：

```js
if (ball1 === speedBall && speedBall.alive) {
  var maxSpd = 10;
  speedBall.vx = Math.max(-maxSpd, Math.min(maxSpd, speedBall.vx * 1.05));
  speedBall.vy = Math.max(-maxSpd, Math.min(maxSpd, speedBall.vy * 1.05));
}
```

### 心形回血道具

随机位置生成一颗爱心，碰到了就回 5 HP，5 秒后重生：

```js
export class Heart {
  spawn() {
    this.x = Math.random() * (canvasW - 2 * margin) + margin;
    this.y = Math.random() * (canvasH - 2 * margin) + margin;
    this.active = true;
  }
  checkCollision(ball) {
    var dx = ball.x - this.x;
    var dy = ball.y - this.y;
    return Math.sqrt(dx * dx + dy * dy) < ball.radius + this.radius;
  }
}
```

### 半径加权伤害

大球打人更疼，小球被打更疼。avgRadius 让伤害与半径成正比：

```js
var avgRadius = (a.radius + b.radius) / 2;
a.takeDamage(baseDamage * (b.radius / avgRadius));
b.takeDamage(baseDamage * (a.radius / avgRadius));
```

---

## 第六阶段：粒子特效 + 帧率无关计时

### 粒子系统

碰撞时生成 14 个粒子，飞散、减速、淡出：

```js
function spawnCollisionParticles(x, y, colorA, colorB) {
  for (var i = 0; i < 14; i++) {
    var angle = Math.random() * Math.PI * 2;
    var spd = 1 + Math.random() * 4;
    particles.push({
      x,
      y,
      vx: Math.cos(angle) * spd,
      vy: Math.sin(angle) * spd,
      life: 0.5 + Math.random() * 0.5,
      maxLife: 1.0,
      color: Math.random() > 0.5 ? colorA : colorB,
      size: 2 + Math.random() * 4,
    });
  }
}
```

每帧更新位置、减速（乘 0.96），生命值耗尽时从数组移除。

### 像素风爱心

用 7×7 的 0/1 矩阵来描述爱心形状，逐像素绘制：

```js
this.bitmap = [
  [0, 1, 0, 0, 0, 1, 0],
  [1, 1, 1, 0, 1, 1, 1],
  [1, 1, 1, 1, 1, 1, 1],
  [1, 1, 1, 1, 1, 1, 1],
  [0, 1, 1, 1, 1, 1, 0],
  [0, 0, 1, 1, 1, 0, 0],
  [0, 0, 0, 1, 0, 0, 0],
];
```

### 帧率无关的 dt

`requestAnimationFrame` 的回调参数 `timestamp` 是精确到毫秒的时间戳。计算两帧的时间差 `dt`（秒），所有运动都乘以 `dt`：

```js
function gameLoop(timestamp) {
  var dt = Math.min((timestamp - lastTime) / 1000, 0.05); // 上限 50ms
  lastTime = timestamp;
  update(dt);
  draw();
  requestAnimationFrame(gameLoop);
}
```

这样不管帧率是 30fps 还是 144fps，小球的移动速度都是一致的。

---

## 第七阶段：ES Module 重构 + 配置驱动

### 模块化

把所有文件改为 ES Module 方式：

```html
<script type="module" src="main.js"></script>
```

`Ball.js` 用 `export class Ball` 导出，`main.js` 用 `import { Ball } from './Ball.js'` 导入。

### 配置集中管理

用 `BALL_INIT` 对象统一管理每球的初始参数（位置、速度、半径等）：

```js
var BALL_INIT = {
  vampire: {
    x: 120,
    y: 200,
    vx: 3.2,
    vy: 1.6,
    radius: 45,
    color: "#ff0000",
    blockSize: 3,
  },
  speed: {
    x: 480,
    y: 200,
    vx: -5.6,
    vy: -4.4,
    radius: 15,
    color: "#ffff00",
    blockSize: 3,
  },
};

function createBall(key) {
  var cfg = BALL_INIT[key];
  var b = new Ball(cfg.x, cfg.y, cfg.radius, cfg.color, cfg.blockSize);
  b.vx = cfg.vx;
  b.vy = cfg.vy;
  return b;
}
```

加新球只需要往 `BALL_INIT` 加一行，不再需要到处复制粘贴构造函数调用。

---

## 第八阶段：4 球大战 — 毒刺与蛛网

从 2 球扩展到 4 球，引入两个带全新机制的小球。

### Stinger（毒刺球）

绿色小球（半径 22），碰墙时在边框上生成一个毒刺三角形。毒刺持续 6 秒，**底部贴合边框**，**尖头指向场内**。

```js
if (stinger.x <= stinger.radius) {
  // 左墙
  sx = sz / 2; // 底部压在 x=0
  sy = stinger.y;
  angle = Math.PI / 2; // 尖头朝右
}
```

其他球碰到毒刺会中毒：每秒 2 点伤害，持续 3 秒。**但 Stinger 自己不会中毒**。

### Spider（蜘蛛球）

白色小球（半径 16），碰墙时从球心到墙边拉一根蛛网线。蛛网持续 5 秒，任何球穿过蛛网线扣 1 HP。

```js
function distToSegment(px, py, x1, y1, x2, y2) {
  // 计算点到线段的距离
  // 用于检测球是否「穿过」蛛网
}
```

### 绘制分层

各元素按层级渲染，确保正确的视觉叠放次序：

```js
function draw() {
  drawWebs();       // 底层：蛛网
  drawStings();     // 中层：毒刺
  for (...) ball.draw(ctx);  // 球
  heart.draw(ctx);  // 心形
  drawParticles();  // 顶层：粒子
}
```

---

## 第九阶段：钩子机制 — 最终架构

每球的特殊行为（吸血、加速、放刺、放网）之前都硬编码在 `main.js` 的 `handleCollisions` 和 `update` 中，靠 `if (vampire.alive)` 这样的分支判断。随着球种增多，`main.js` 会越来越臃肿。

### 基类增加钩子

在 `Ball.js` 中定义三个可覆写的方法：

```js
// 碰墙时调用
onBounce(canvasW, canvasH) {}

// 碰撞另一球时调用
onCollision(other, dvn, damage, avgRadius) {}

// 是否免疫某类伤害
isImmuneTo(sourceType) { return false; }
```

### 每种球独立为子类

```bash
balls/
├── VampireBall.js     onCollision → 吸血 30%
├── SpeedBall.js       onCollision → 提速 5%
├── StingerBall.js     onBounce → 放刺 + isImmuneTo('sting')
└── SpiderBall.js      onBounce → 放网
```

### main.js 薄层化

删除所有 `if (vampire)`、`if (speed)` 分支，改为统一调用钩子：

```js
// 碰墙
for (const ball of balls) ball.onBounce(canvas.width, canvas.height);

// 碰撞
a.onCollision(b, dvn, baseDamage, avgRadius);
b.onCollision(a, dvn, baseDamage, avgRadius);

// 毒刺免疫
if (ball.isImmuneTo('sting')) continue;
```

加新球不再需要改碰撞和更新逻辑，只新建文件、填配置即可。

---

## 总结

| 阶段 | 核心成果        | 关键概念                   |
| ---- | --------------- | -------------------------- |
| 1    | 画布 + 像素小球 | Canvas 2D API、像素渲染    |
| 2    | 运动 + 反弹     | 动画循环、边界检测         |
| 3    | 双球碰撞 + HP   | 圆碰撞检测、物理反弹、血条 |
| 4    | OOP + 音效      | ES6 class、Web Audio API   |
| 5    | 特殊能力 + 回血 | 继承、多态、游戏道具       |
| 6    | 粒子 + 帧率无关 | 粒子系统、dt 计时          |
| 7    | 模块化 + 配置   | ES Modules、配置驱动       |
| 8    | 4 球大战        | 毒刺 DOT、蛛网、绘制分层   |
| 9    | 钩子架构        | 钩子模式、子类化、免疫系统 |

这个项目从 4 行代码画出绿色矩形开始，经过 9 个阶段演变为一个包含碰撞物理、特殊技能、粒子系统、音效、状态效果的完整游戏。每个阶段都可独立运行，Git 仓库中的 commit 记录了每一步的变化。

下一步可以尝试：添加新球种（如冰冻球、爆炸球）、联机对战模式、AI 对手等。框架已经搭好，你只需要新建一个子类覆写钩子方法。

## 参考

- [Canvas 2D API](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D)
- [requestAnimationFrame](https://developer.mozilla.org/en-US/docs/Web/API/window/requestAnimationFrame)
- [Web Audio API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API)
- [ES6 Classes](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes)
