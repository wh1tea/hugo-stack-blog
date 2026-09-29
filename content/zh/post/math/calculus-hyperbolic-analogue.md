---
title: 高数竞赛题的双曲函数类比
slug: calculus-hyperbolic-analogue
date: 2026-04-14T03:32:00+08:00
description: 竞赛题里 sin x = x cos y 换成双曲函数后结论不变：y < x < 2y，迭代序列趋于 0 且级数收敛，附完整证明
tags:
  - inequality
  - hyperbolic-function
  - mean-value-theorem
  - series
categories:
  - math
math: true
draft: false
---

同一套证明可以搬给双曲函数：Lagrange 中值定理把 $\operatorname{sh}$ 的差商换成中间点的 $\operatorname{ch}$ 值，剩下的只是单调性与两个带余项的不等式。

## 原题与类比题

**(A)** 已知 $\sin x = x \cos y$，$x, y \in (0, \pi/2)$。证明 $y < x < 2y$。

**(B)** 设 $x_1 = 1$，$\sin x_n = x_n \cos x_{n+1}$，$x_{n+1} \in (0, \pi/2)$。证明 $\lim_{n \to \infty} x_n = 0$，且 $\sum_{n=1}^{\infty} x_n$ 收敛。

**(C)** 已知 $\operatorname{sh} x = x \operatorname{ch} y$，$x, y \in (0, 1)$。证明 $y < x < 2y$。

**(D)** 设 $x_1 = 1$，$\operatorname{sh} x_n = x_n \operatorname{ch} x_{n+1}$。证明 $\lim_{n \to \infty} x_n = 0$，且 $\sum_{n=1}^{\infty} x_n$ 收敛。

(A)(B) 与 (C)(D) 的证明逐句对应：把 $\operatorname{ch}$ 在 $(0, 1)$ 上的单调递增换成 $\cos$ 在 $(0, \pi/2)$ 上的单调递减，把 $\operatorname{sh} t > t$ 换成 $\sin t < t$ 即可。

## 结论 (C) 的证明

由 Lagrange 中值定理，

$$\operatorname{sh} x = \operatorname{sh} x - \operatorname{sh} 0 = x \operatorname{ch} \xi, \quad \xi \in (0, x)$$

与题设 $\operatorname{sh} x = x \operatorname{ch} y$ 比较（两者都等于 $\operatorname{sh} x / x$），得 $\operatorname{ch} \xi = \operatorname{ch} y$。$\operatorname{ch}$ 在 $(0, 1)$ 上严格单调递增，且 $y, \xi \in (0, 1)$，所以 $y = \xi < x$。

另一侧：$t > 0$ 时 $\operatorname{ch} t > 1$，在 $[0, x]$ 上积分得 $\operatorname{sh} x > x$。于是

$$\operatorname{sh} x = 2 \operatorname{sh} \frac{x}{2} \operatorname{ch} \frac{x}{2} > x \operatorname{ch} \frac{x}{2}$$

再与 $\operatorname{sh} x = x \operatorname{ch} y$ 比较，得 $\operatorname{ch} y > \operatorname{ch} \frac{x}{2}$，由单调性得 $y > \frac{x}{2}$，即 $x < 2y$。

## 结论 (D) 的证明

先用中值定理把每一项锁进 $(0, 1)$。由 $x_1 = 1$ 及

$$\operatorname{sh} x_1 = \operatorname{sh} x_1 - \operatorname{sh} 0 = x_1 \operatorname{ch} \xi_1 = \operatorname{ch} \xi_1, \quad \xi_1 \in (0, 1)$$

与题设 $\operatorname{sh} x_1 = x_1 \operatorname{ch} x_2 = \operatorname{ch} x_2$，得 $\operatorname{ch} \xi_1 = \operatorname{ch} x_2$，即 $x_2 = \xi_1 \in (0, 1)$。

若 $0 < x_n < 1$，同样有

$$\operatorname{sh} x_n = x_n \operatorname{ch} \xi_n = x_n \operatorname{ch} x_{n+1}, \quad 0 < \xi_n < x_n < 1$$

于是 $x_{n+1} = \xi_n \in (0, x_n)$。归纳得 $n \ge 2$ 时 $0 < x_n < 1$，且数列 $x_n$ 单调递减。

再由 $0 < x < 1$ 上的两个不等式（都能用带余项的 Taylor 展开验证）

$$\operatorname{sh} x \le x + \frac{x^3}{5}, \qquad \operatorname{ch} x \ge 1 + \frac{x^2}{2} - \frac{x^4}{20}$$

与 $\operatorname{sh} x_n = x_n \operatorname{ch} x_{n+1}$，得

$$x_n + \frac{x_n^3}{5} \ge \operatorname{sh} x_n = x_n \operatorname{ch} x_{n+1} \ge x_n \left(1 + \frac{x_{n+1}^2}{2} - \frac{x_{n+1}^4}{20}\right)$$

两边除以 $x_n > 0$：

$$\frac{x_n^2}{5} \ge \frac{x_{n+1}^2}{2} - \frac{x_{n+1}^4}{20} \ge \frac{x_{n+1}^2}{2} - \frac{x_{n+1}^2}{20} = \frac{9}{20} x_{n+1}^2$$

第二个不等号用了 $x_{n+1}^4 \le x_{n+1}^2$（因为 $x_{n+1} < 1$）。于是 $x_{n+1} \le \frac{2}{3} x_n$，递推得

$$x_n \le \left(\frac{2}{3}\right)^{n-1} x_1 = \left(\frac{2}{3}\right)^{n-1}$$

由 $x_n > 0$ 与夹逼准则得 $\lim_{n \to \infty} x_n = 0$；又级数 $\sum_{n=1}^{\infty} (2/3)^{n-1}$ 收敛，由正项级数比较判别法得 $\sum_{n=1}^{\infty} x_n$ 收敛。

## 结语

证明只依赖两件事：$\operatorname{ch}$ 的单调性，以及一组带余项的多项式界。常数 $1/5$ 与 $1/2 - 1/20$ 的作用只是让比值落在 $(0, 1)$ 内——任何满足这一点的余项估计都能得到同样的收敛结论。
