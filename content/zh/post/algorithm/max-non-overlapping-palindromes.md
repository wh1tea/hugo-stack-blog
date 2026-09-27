---
title: 动态规划求不重叠回文子串最大数目
slug: max-non-overlapping-palindromes
date: 2026-09-15T16:00:00+08:00
description: 先 O(n²) 预处理回文表，再用线性 DP 选出最多不重叠回文子串，附 LeetCode 2472 完整解法与复杂度分析。
tags:
  - leetcode
  - hard
  - dynamic-programming
  - palindrome
  - string
categories:
  - algorithm
---
LeetCode 2472[^1] 要求从字符串中选出尽可能多的不重叠回文子串，每段长度至少为 `k`。`n ≤ 2000`，O(n²) 的预处理与 DP 都在可接受范围内。解法分两步：先把所有回文子串标出来，再在回文表上做不重叠区间选择。

## 预处理回文子串

用二维布尔表 `isPalindrome[i][j]` 表示 `s[i..j]` 是否为回文，按长度从小到大填：

- 长度 1 必然是回文；
- 长度 2 看两个字符是否相同；
- 长度 ≥ 3 要求 `s[i] == s[j]` 且 `s[i+1..j-1]` 是回文。

```javascript
const isPalindrome = Array.from({ length: n }, () => new Array(n).fill(false));

for (let i = 0; i < n; i++) {
    isPalindrome[i][i] = true;
}

for (let length = 2; length <= n; length++) {
    for (let i = 0; i <= n - length; i++) {
        const j = i + length - 1;
        if (s[i] !== s[j]) continue;
        isPalindrome[i][j] = length === 2 ? true : isPalindrome[i + 1][j - 1];
    }
}
```

## 线性 DP

### 从爬楼梯理解状态转移

爬 5 级台阶，每次走 1 级或 2 级，最后一步只能从第 4 级或第 3 级迈上来，所以走法数等于这两级的走法数之和。DP 做的就是把这套"看最后一步从哪来"的思路记进表格，避免重复计算。

### 回到本题

定义 `dp[i]`：只看前 `i` 个字符（`s[0..i-1]`），最多能选出几段。对第 `i` 个字符有两种决策：

- 不选它：`dp[i] = dp[i-1]`；
- 让它作为某一段的末尾：枚举起点 `j`，长度 `i - j ≥ k`，所以 `j ≤ i - k`；若 `s[j..i-1]` 是回文，则 `dp[i] = max(dp[i], dp[j] + 1)`。

对应到"最后一步"：`dp[i]` 的最后一个回文段以 `i - 1` 结尾，它的前面就是 `dp[j]`。

```javascript
const dp = new Array(n + 1).fill(0);

for (let i = 1; i <= n; i++) {
    dp[i] = dp[i - 1];
    for (let j = i - k; j >= 0; j--) {
        if (isPalindrome[j][i - 1]) {
            dp[i] = Math.max(dp[i], dp[j] + 1);
        }
    }
}

return dp[n];
```

内层循环从 `i - k` 递减到 `0`，是因为终点固定为 `i - 1` 时，起点越靠左区间越长，枚举顺序不影响正确性，但递减写法让 `j` 的边界更直观。

## 复杂度

| 阶段       | 时间  | 空间  |
| :--------- | :---- | :---- |
| 回文预处理 | O(n²) | O(n²) |
| DP         | O(n²) | O(n)  |
| 合计       | O(n²) | O(n²) |

## 完整代码

```javascript
var maxPalindromes = function (s, k) {
    const n = s.length;
    const isPalindrome = Array.from({ length: n }, () => new Array(n).fill(false));

    for (let i = 0; i < n; i++) {
        isPalindrome[i][i] = true;
    }

    for (let length = 2; length <= n; length++) {
        for (let i = 0; i <= n - length; i++) {
            const j = i + length - 1;
            if (s[i] !== s[j]) continue;
            isPalindrome[i][j] = length === 2 ? true : isPalindrome[i + 1][j - 1];
        }
    }

    const dp = new Array(n + 1).fill(0);
    for (let i = 1; i <= n; i++) {
        dp[i] = dp[i - 1];
        for (let j = i - k; j >= 0; j--) {
            if (isPalindrome[j][i - 1]) {
                dp[i] = Math.max(dp[i], dp[j] + 1);
            }
        }
    }

    return dp[n];
};
```

## 结语

「预处理 + 线性 DP」是字符串类题目的常见组合，先解决判定问题（哪些子串是回文），再解决选择问题（怎么选最多且不重叠）。遇到新题可以先问：判定和选择能不能拆成两步？

[^1]: [LeetCode 2472. Maximum Number of Non-overlapping Palindrome Substrings](https://leetcode.com/problems/maximum-number-of-non-overlapping-palindrome-substrings/)
