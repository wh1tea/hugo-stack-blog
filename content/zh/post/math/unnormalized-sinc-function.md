---
title: 非归一化 Sinc 函数
slug: unnormalized-sinc-function
date: 2026-10-28
description: 从三维径向函数 sin r / r 出发，梳理非归一化 Sinc 的定义域、零点、包络与极值，并说明它在球面波、信号采样和衍射中的来源。
tags:
  - sinc
  - signal-processing
categories:
  - math
draft: true

---

先在 $\mathbb{R}^3\setminus\{r=0\}$ 上考察

$$
f(x,y,z)=\frac{\sin\sqrt{x^2+y^2}}{\sqrt{x^2+y^2}}
$$

表达式中没有 $z$。令 $r=\sqrt{x^2+y^2}$，它退化成一元函数 $f(r)=\sin r/r$（$r>0$），即非归一化 Sinc 函数[^1]。这个函数在 $r=0$（整条 $z$ 轴）处有可去奇点，在 $r>0$ 上以 $r=n\pi$ 为零点振荡衰减，也是球面波和理想低通滤波器的共同原型。

## 定义域与可去奇点

$r>0$ 时表达式处处有定义；$r=0$（整个 $z$ 轴）时分母为零。由 $\sin r$ 的泰勒展开

$$
\frac{\sin r}{r}=1-\frac{r^2}{6}+\frac{r^4}{120}-\cdots
$$

可得 $\lim_{r\to0}\sin r/r=1$。把 $z$ 轴上的函数值补为 $1$，$f$ 就在整个 $\mathbb{R}^3$ 上连续，并且实际上光滑。数值实现时对 $r=0$ 单独赋值，可以避免 `0/0`。

## 圆柱对称与水平集

$f$ 只依赖 $r$，所以固定 $x,y$ 后函数值不随 $z$ 变化，绕 $z$ 轴旋转也不改变取值。水平集 $f=c$ 因此是一组以 $z$ 轴为轴的同轴圆柱面，而不是球面。$|c|<1$ 时是若干同轴圆柱面；补值后 $c=1$ 的水平集退化为 $z$ 轴本身；$c=-1$ 与 $|c|>1$ 时水平集为空集，因为 $r>0$ 时 $|\sin r/r|<1$。

## 零点、包络与极值

零点出现在 $\sin r=0$ 且 $r\neq0$ 处，即 $r=n\pi$（$n=1,2,\dots$）。对应到空间中，是半径 $\pi,2\pi,3\pi,\dots$ 的一组同轴圆柱面，函数在这些面上严格为零。归一化版本 $\sin(\pi r)/(\pi r)$ 的零点落在整数 $r$ 上，两者只差自变量尺度。

振幅由 $|\sin r/r|\le 1/r$ 约束，按 $1/r$ 衰减。这个衰减来自分母的 $r$，在球面波里对应能量随球面面积扩散的几何因子。

对 $r>0$，极值点满足

$$
f'(r)=\frac{r\cos r-\sin r}{r^2}=0
$$

即 $\tan r=r$。这是超越方程，没有解析解；第 $n$ 个正解略偏离 $(n+\tfrac12)\pi$（$n=1,2,\dots$）。$r=0$ 是补值后的极大点，$f(0)=1$。

## 为什么它反复出现

球面波：点源发出的声波或电磁波，行波解写作 $e^{ikr}/r$，$\sin(kr)/r$ 是它的驻波组合。振幅按 $1/r$ 衰减，使得通过球面的能流不随 $r$ 增大而衰减。

信号处理：在归一化截止频率下，$\sin x/x$ 是理想低通滤波器的冲激响应；更一般地写作 $\sin(\omega_c t)/(\pi t)$。它也是 Nyquist–Shannon 采样定理中重建带限信号的核。

光学：圆孔衍射的 Airy 图样光强为

$$
I(\theta)=I_0\left[\frac{2J_1(ka\sin\theta)}{ka\sin\theta}\right]^2,
$$

其中 $J_1$ 是一阶贝塞尔函数，$a$ 为圆孔半径，$k=2\pi/\lambda$，$\theta$ 为衍射角。单缝衍射的光强为 $I_0\,\mathrm{sinc}^2(u)$，$u= d\pi\sin\theta/\lambda$（sinc 取非归一化）。两者是不同孔径的结果：圆孔对应 $J_1(x)/x$ 的平方，单缝对应 $\sin x/x$ 的平方。Sinc 函数不是 Airy 图样的精确简化公式。[^2]

量子力学：无限深球方势阱中 $l=0$ 态的径向波函数含 $\sin(kr)/r$。

这些场景共享同一个结构：分子负责振荡，分母负责衰减。

## 结语

遇到 $\sin r/r$ 形式的表达式，先确认原点能否补值为 $1$；能补就按连续函数处理，数值上对 $r=0$ 单独赋值。零点、包络和极值都只由 $r$ 决定，分析时把三维问题降成一元问题即可。

[^1]: [Sinc function](https://en.wikipedia.org/wiki/Sinc_function)

[^2]: [衍射](https://en.wikipedia.org/wiki/Diffraction)