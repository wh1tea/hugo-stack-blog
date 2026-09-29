---
title: 复数与欧拉公式
slug: complex-number-euler-formula
date: 2026-03-30T12:56:00+08:00
description: 复数的代数、三角与指数三种写法及其换算，欧拉公式如何把复指数与三角函数连起来，附欧拉恒等式
tags:
  - complex-number
  - euler-formula
categories:
  - math
math: true
draft: false
---

同一个复数有三种写法，各自方便不同的运算：实部与虚部直接可读，模长与辐角直接可读，而指数形式让乘除变成模长与辐角上的运算。

## 代数形式

形如

$$z = a + b\,\mathrm{i}$$

的数称为复数，其中 $a, b \in \mathbb{R}$，$\mathrm{i}$ 是虚数单位，满足

$$\mathrm{i}^2 = -1$$

- $a = \operatorname{Re}(z)$ 称为 $z$ 的**实部**；
- $b = \operatorname{Im}(z)$ 称为 $z$ 的**虚部**。

## 三角形式

把 $(a, b)$ 看成平面上的点并用极坐标表示，得到

$$z = r(\cos\theta + \mathrm{i}\sin\theta)$$

其中 $r = |z| = \sqrt{a^2 + b^2}$ 是模长，$\theta = \arg(z)$ 是辐角。

## 指数形式与欧拉公式

欧拉公式把复指数与三角函数联系起来：

$$\mathrm{e}^{\mathrm{i}\theta} = \cos\theta + \mathrm{i}\sin\theta, \quad \theta \in \mathbb{R}$$

代入三角形式即得**指数形式**：

$$z = r\,\mathrm{e}^{\mathrm{i}\theta}$$

取 $\theta = \pi$ 得到欧拉恒等式：

$$\mathrm{e}^{\mathrm{i}\pi} + 1 = 0$$

## 结语

指数形式下两复数相乘只要模长相乘、辐角相加：

$$r_1 \mathrm{e}^{\mathrm{i}\theta_1} \cdot r_2 \mathrm{e}^{\mathrm{i}\theta_2} = r_1 r_2\, \mathrm{e}^{\mathrm{i}(\theta_1 + \theta_2)}$$

与三角形式对照，这正是 $\sin$ 与 $\cos$ 的和角公式。
