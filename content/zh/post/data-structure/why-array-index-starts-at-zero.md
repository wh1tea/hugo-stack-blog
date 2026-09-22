---
title: 为什么数组下标从 0 开始
slug: why-array-index-starts-at-zero
date: 2026-09-10T00:00:00+08:00
description: 从内存偏移量、C 语言指针运算到 Dijkstra 的区间论证，说清数组下标从 0 开始的历史与数学原因
tags:
  - c
  - best-practices
categories:
  - data-structures
---

数组下标从 0 开始，源于内存偏移量的零开销寻址，被 C 语言固化，又因 Dijkstra 的区间论证获得了数学上的辩护。

## 从内存地址说起

数组是一段**连续的内存空间**。下标不是「第几个」的标签，而是**距离起始地址的偏移量**。

假设数组起始地址是 `1000`，每个元素占 4 字节：

| 位置   | 习惯说法 | 内存地址 | 下标 |
| :----- | :------- | :------- | :--- |
| 第一个 | 第 1 个  | 1000     | 0    |
| 第二个 | 第 2 个  | 1004     | 1    |
| 第三个 | 第 3 个  | 1008     | 2    |

起始地址就是第一个元素自身的地址，因此第一个元素的偏移量必然是 0。寻址公式随之变得极简：`起始地址 + i × 元素大小`。若从 1 开始，每次寻址都要先做一次减法。

## C 语言的固化

C 语言把下标与指针运算绑死：`a[i]` 完全等价于 `*(a + i)`[^1]。这种对应关系要求下标从 0 起，否则表达式不再成立。C 的成功让 0 基索引成为事实标准，C++、Java、JavaScript、Python 相继沿用。

在 C 之前，**Fortran、Algol、COBOL** 默认从 1 开始，Pascal 甚至允许自定义索引范围。0 基不是「自古以来」，而是 C 生态的胜利。

## Dijkstra 的数学论证

Edsger W. Dijkstra 在 1982 年的短文《Why numbering should start at zero》中，从数学角度给出了论证[^2]。他表示 `2` 到 `12` 的范围时，列出四种写法：

| 写法 | 表示         |
| :--- | :----------- |
| a)   | `2 ≤ i < 13` |
| b)   | `1 < i ≤ 12` |
| c)   | `2 ≤ i ≤ 12` |
| d)   | `1 < i < 13` |

他论证 **a) 最优**，理由有两点：

1. **差值为长度**：上界减下界（13 − 2 = 11）恰好是元素个数。
2. **空集表示自然**：上下界相等时（`2 ≤ i < 2`）自然表示空序列。

用这个**左闭右开区间**表示长度为 N 的数组索引：从 1 开始会得到 `1 ≤ i < N+1`，从 0 开始则是 `0 ≤ i < N`，后者干净得多。Dijkstra 的结论是：元素的序号等于它前面元素的个数。

## 争议与补充

Dijkstra 的论证并非无懈可击。Ned Batchelder[^3]和 Hacker News[^4]转载该文时，评论区有人指出：

- 「`0 ≤ i < N` 更漂亮」是一个**审美判断**，无法说服已经习惯从 1 开始的人。
- 半开区间方便求长度和相邻拼接，但**求最大元素**反而不如闭区间直观。
- 人类语言天然用「第一个」「第二个」，0 基与直觉存在**阻抗失配**，这也是 C 指针差一错误的经济代价来源。

换句话说，0 基是**工程效率与数学优雅的合流**，而不是纯粹的「正确」。

## 结语

理解 0 基的来源，能更自然地读写切片、循环与指针运算，也能在遇到「第 N 个」这类表述时，立刻反应过来该用 `N-1`。

[^1]: [Zero-based numbering — Wikipedia](https://en.wikipedia.org/wiki/Zero-based_numbering)
[^2]: [EWD831: Why numbering should start at zero — Dijkstra](https://www.cs.utexas.edu/~EWD/transcriptions/EWD08xx/EWD831.html)
[^3]: [Why numbering should start at zero — Ned Batchelder](https://nedbatchelder.com/blog/200909/why_numbering_should_start_at_zero)
[^4]:[Hacker News 讨论：Why numbering should start at zero](https://news.ycombinator.com/item?id=36742920)
