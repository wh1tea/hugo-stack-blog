---
title: 大小为 K 的不重叠线段的数目
slug: max-non-overlapping-line-segments
date: 2026-09-20
description: LeetCode 1621 题解，用组合数学与两种 DP 状态定义求恰好 k 条不重叠线段方案数，附完整代码与复杂度分析
tags:
  - leetcode
  - dynamic-programming
  - combinatorics
  - medium
categories:
  - algorithm
---
LeetCode 1621[^1] 要求在一维平面的 `n` 个点上，选出恰好 `k` 个不重叠线段，每个线段至少覆盖两个点，端点可重合。`2 ≤ n ≤ 1000`，标准解法有两条路：**组合数学**一步到位，或**动态规划**逐步递推。本文给出 DP 的两种状态定义与完整实现。

## 问题理解

线段端点可重合意味着相邻线段可以共享端点。

## 组合解法

先考虑端点**不能**重合的情况：从 `n` 个点中选出 `2k` 个点，配对成 `k` 条线段，方案数为 `C(n, 2k)`。

题目允许端点重合，相当于每条线段可以在前一条的右端点上“续接”。加入 `k - 1` 个虚拟点表示这种续接，问题转化为在 `n + k - 1` 个点中选 `2k` 个点：

```javascript
const MOD = 1e9 + 7;

function comb(n, r) {
    if (r > n) return 0;
    let res = 1;
    for (let i = 0; i < r; i++) {
        res = res * (n - i) % MOD;
        res = res * modInverse(i + 1) % MOD;
    }
    return res;
}

var numberOfSets = function (n, k) {
    return comb(n + k - 1, 2 * k);
};
```

需要预处理模逆元，时间复杂度 O(k log MOD)。

## DP 解法（两状态）

设 `dp[i][j][0]`：前 `i` 个点中选 `j` 条线段，且**最后一条线段不以点 `i` 结尾**；`dp[i][j][1]`：最后一条线段**以点 `i` 结尾**。

转移时考虑点 `i` 的角色：

```javascript
var numberOfSets = function (n, k) {
    const MOD = 1e9 + 7;
    // dp[i][j][0]: 前 i 个点，j 条线段，最后一条不以 i 结尾
    // dp[i][j][1]: 前 i 个点，j 条线段，最后一条以 i 结尾
    const dp = Array.from({ length: n }, () =>
        Array.from({ length: k + 1 }, () => [0, 0])
    );
    dp[0][0][0] = 1;

    for (let i = 1; i < n; i++) {
        for (let j = 0; j <= k; j++) {
            // 点 i 不是任何线段的终点：继承 i-1 的状态
            dp[i][j][0] = (dp[i - 1][j][0] + dp[i - 1][j][1]) % MOD;

            // 点 i 是某条线段的终点
            // 情况 A：线段长度 > 1，i-1 也是终点，延续过来
            dp[i][j][1] = dp[i - 1][j][1];

            // 情况 B：线段长度为 1（即覆盖 i-1 到 i），j >= 1
            // 前 i-1 个点构造 j-1 条线段，然后新增一条 (i-1, i)
            if (j > 0) {
                dp[i][j][1] = (dp[i][j][1] + dp[i - 1][j - 1][0] + dp[i - 1][j - 1][1]) % MOD;
            }
        }
    }

    return (dp[n - 1][k][0] + dp[n - 1][k][1]) % MOD;
};
```

时间 O(nk)，空间 O(nk)。第三维可用滚动数组压成 O(k)。

## DP 解法（前缀和优化）

另一种更紧凑的定义：`dp[i][j]` 表示用前 `i` 个点构造 `j` 条线段的方案数。枚举最后一条线段的右端点 `t`，转移为：

`dp[i][j] = dp[i-1][j] + sum(dp[t][j-1] for t from j to i-1)`

内层求和用前缀和预处理，可将 O(n²k) 优化到 O(nk)。

```javascript
var numberOfSets = function (n, k) {
    const MOD = 1e9 + 7;
    let dp = Array.from({ length: n + 1 }, () => new Array(k + 1).fill(0));
    for (let i = 1; i <= n; i++) dp[i][0] = 1;

    for (let j = 1; j <= k; j++) {
        const prefix = new Array(n + 1).fill(0);
        for (let i = 1; i <= n; i++) {
            prefix[i] = (prefix[i - 1] + dp[i][j - 1]) % MOD;
        }
        const next = new Array(n + 1).fill(0);
        for (let i = j + 1; i <= n; i++) {
            next[i] = (next[i - 1] + prefix[i - 1] - prefix[j] + MOD) % MOD;
        }
        dp = dp.map((row, idx) => {
            const copy = [...row];
            if (idx > j) copy[j] = next[idx];
            return copy;
        });
    }

    return dp[n][k];
};
```

## 复杂度

| 解法      | 时间         | 空间  |
| :-------- | :----------- | :---- |
| 组合数学  | O(k log MOD) | O(1)  |
| 两状态 DP | O(nk)        | O(nk) |
| 前缀和 DP | O(nk)        | O(nk) |

组合解法最优，但需要推公式；DP 解法通用性更强，适合推广到带权或带约束的变体。

## 完整代码（推荐：组合解法）

```javascript
const MOD = 1e9 + 7;

function modPow(base, exp) {
    let res = 1;
    base %= MOD;
    while (exp > 0) {
        if (exp & 1) res = res * base % MOD;
        base = base * base % MOD;
        exp >>= 1;
    }
    return res;
}

function comb(n, r) {
    if (r > n) return 0;
    r = Math.min(r, n - r);
    let num = 1, den = 1;
    for (let i = 0; i < r; i++) {
        num = num * (n - i) % MOD;
        den = den * (i + 1) % MOD;
    }
    return num * modPow(den, MOD - 2) % MOD;
}

var numberOfSets = function (n, k) {
    return comb(n + k - 1, 2 * k);
};
```

## 结语

端点可重合的组合题，本质是「允许相邻线段共享端点」带来的重复计数修正：从 `C(n, 2k)` 推广到 `C(n + k - 1, 2k)`。若不想推公式，DP 的两种状态定义都够用——`[0/1]` 标记末段是否以当前点结尾，或用前缀和压缩枚举范围。

[^1]: [LeetCode 1621. Number of Sets of K Non-Overlapping Line Segments](https://leetcode.com/problems/number-of-sets-of-k-non-overlapping-line-segments/)