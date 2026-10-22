---
title: NSGA-II 的拥挤距离与截断
slug: nsga2-crowding-distance
date: 2024-06-04T10:20:00+08:00
description: NSGA-II 用拥挤距离在同一前沿内挑解：按目标排序、边界取无穷、按极差归一化的算法，5 点算例，以及排序实现的坑
tags:
  - nsga2
  - multi-objective-optimization
  - crowding-distance
categories:
  - algorithm
math: true
---

非支配排序只回答「解在第几层」，不回答「同一层里留谁」。只要按层收解，同一层里会挤满几乎相同的点；NSGA-II 用拥挤距离做层内排序，优先保留周围稀疏的解。

## 算法

对每个前沿单独计算，逐个目标 m：

1. 按该目标的值升序排序；
2. 排序后的第一个和最后一个解，拥挤距离记为 ∞（它们决定前沿的宽度，必须保住）；
3. 中间的解累加相邻两解在该目标上的差，再除以这个目标在前沿上的极差。

$$d_i = \sum_m \frac{f_m(i+1) - f_m(i-1)}{f_m^{\max} - f_m^{\min}}$$

除极差是为了让不同量纲的目标可比：目标取值范围大的不会压倒取值范围小的。

## 五点算例

两个目标都是越小越好，同一前沿上的 5 个解：

| 解   | $f_1$ | $f_2$ |
| :--- | ----: | ----: |
| P1   |     1 |   100 |
| P2   |     2 |    50 |
| P3   |     4 |    25 |
| P4   |     5 |    20 |
| P5   |    10 |    10 |

$f_1$ 极差 9，$f_2$ 极差 90。两端 P1、P5 取 ∞。

按 $f_1$ 升序是 P1→P5：P2 得 $(4-1)/9 = 0.333$，P3 得 $(5-2)/9 = 0.333$，P4 得 $(10-4)/9 = 0.667$。

按 $f_2$ 升序是 P5→P1：P4 得 $(25-10)/90 = 0.167$，P3 得 $(50-20)/90 = 0.333$，P2 得 $(100-25)/90 = 0.833$。

合计 P2 = 1.167、P3 = 0.667、P4 = 0.833，P1 与 P5 为 ∞。P3 两侧的解最密，所以它最容易被截断丢掉。

## 选种群的顺序

按 Rank 升序收解，整层收完再看下一层；收到最后一个放不下的前沿时，按拥挤距离降序截断。也就是说：Rank 是第一关键字，拥挤距离只在同一 Rank 内起作用。

MATLAB 里常见的写法是靠**稳定排序**实现这个字典序：

```matlab
function [pop, F] = SortPopulation(pop)
    % sort by crowding distance (desc), then by rank (asc) — stable sorts
    [~, cds] = sort([pop.CrowdingDistance], 'descend');
    pop = pop(cds);
    [~, rso] = sort([pop.Rank]);
    pop = pop(rso);

    ranks = [pop.Rank];
    F = cell(max(ranks), 1);
    for r = 1:max(ranks)
        F{r} = find(ranks == r);
    end
end
```

因为 `sort` 稳定，第二次排序不会打乱同一 Rank 内部已经按拥挤距离排好的顺序。用 `sortrows` 可以一次排完：

```matlab
[~, idx] = sortrows([[pop.Rank]', -[pop.CrowdingDistance]'], [1 2]);
pop = pop(idx);
```

## 三个容易写错的地方

1. **整个种群一起算拥挤距离**：极差必须在同一前沿内取，跨前沿归一化会让不同层的解失去可比性。
2. **边界点不给 ∞**：截断时边界解可能被随机丢掉，Pareto 前沿两端会逐渐收缩。
3. **极差为 0**：该目标上所有解取值相同，分母为 0，需要跳过该目标（或按 0 贡献处理），否则会得到 NaN，排序直接失效。

## 结语

拥挤距离只干一件事：在同一 Rank 内给邻居稀疏的解更高的保留优先级。实现时守住三点——按前沿分组、两端取无穷、按目标极差归一化——剩下的就是把排序写成 Rank 主键、拥挤距离次键。
