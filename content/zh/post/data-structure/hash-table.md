---
title: 哈希表：冲突、装载因子与扩容
slug: hash-table
date: 2022-08-27T21:20:00+08:00
description: 哈希表的桶数组、哈希函数、两种冲突处理与装载因子：链地址法与开放寻址怎么选、扩容为什么是均摊 O(1)，附可运行实现
tags:
  - data-structure
  - hash-table
  - complexity
categories:
  - data-structures
---

哈希表用「M 条数据塞进 N 个桶（M > N）」把查找压到 O(1)。冲突不可避免，所有设计都围绕怎么处理冲突、以及冲突多了怎么扩容。

## 结构

一个数组存桶，桶里存表项。写入时用哈希函数把 key 映射成桶下标：

- 桶空，直接放；
- 桶里已有数据，就挂到桶内的链表上（链地址法），或按探测序列往后找空位（开放寻址）。

## 冲突是必然的

M > N 时按鸽巢原理一定有两个 key 落到同一个桶，所以「好的哈希函数」不是消除冲突，而是让 key 分布均匀、计算足够快。

直接用 `% 桶数` 有个陷阱：hash 值的低位不一定均匀。Python 里浮点数的 hash 是 `int(x * 2**53)` 量级的整数，桶数取 2 的幂时低位全是 0：

```python
>>> [hash(x) % 16 for x in (0.844, 0.758, 0.421)]
[0, 0, 0]
```

把 128 个浮点 key 插进桶数 16 的表里，它们会全部挤进同一个桶。所以实际实现会先做混合：Java 的 `HashMap` 用 `h ^ (h >>> 16)` 把高位折进低位，Python 用扰动序列做探测。

## 装载因子与扩容

装载因子 α = 元素数 / 桶数。α 越大，桶内链表越长，查找越接近 O(n)。超过阈值就翻倍扩容并重新散列：单次扩容是 O(n)，但均摊到每次写入是 O(1)。

字符串 key、阈值 0.75 的链地址法实测：

| 元素数 n | 桶数 | 非空桶 | 最长链 |
| -------: | ---: | -----: | -----: |
|       32 |   64 |     25 |      2 |
|       64 |  128 |     50 |      3 |
|      128 |  256 |    102 |      3 |

α 维持在 0.5 左右时，最长链只有 3 个节点，桶内查找基本是常数。

## 链地址法与开放寻址

|          | 链地址法                            | 开放寻址                 |
| :------- | :---------------------------------- | :----------------------- |
| 冲突处理 | 桶内挂链表（可升级红黑树）          | 按探测序列找下一个空位   |
| 装载因子 | 可以超过 1                          | 必须小于 1（通常 ≤ 0.7） |
| 缓存     | 差，指针跳来跳去                    | 好，扫描连续数组         |
| 删除     | 直接摘链                            | 需要墓碑标记             |
| 典型实现 | Java `HashMap`、C++ `unordered_map` | Python `dict`、Go `map`  |

## 一个最小实现

```python
class ChainedMap:
    def __init__(self, capacity=8, load_factor=0.75):
        self.buckets = [[] for _ in range(capacity)]
        self.size = 0
        self.load_factor = load_factor

    def _index(self, key):
        return hash(key) % len(self.buckets)

    def put(self, key, value):
        bucket = self.buckets[self._index(key)]
        for i, (k, _) in enumerate(bucket):
            if k == key:
                bucket[i] = (key, value)
                return
        bucket.append((key, value))
        self.size += 1
        if self.size > self.load_factor * len(self.buckets):
            self._resize()

    def get(self, key, default=None):
        for k, v in self.buckets[self._index(key)]:
            if k == key:
                return v
        return default

    def _resize(self):
        pairs = [pair for bucket in self.buckets for pair in bucket]
        self.buckets = [[] for _ in range(len(self.buckets) * 2)]
        self.size = 0
        for k, v in pairs:
            self.put(k, v)
```

写入 10 条后桶数从 8 翻到 16，`get("k3")` 返回 9；重复写同一个 key 只更新值，不增加元素数。

## 复杂度

| 操作 | 平均      | 最坏 |
| :--- | :-------- | :--- |
| 查找 | O(1)      | O(n) |
| 写入 | O(1) 均摊 | O(n) |
| 删除 | O(1)      | O(n) |

最坏情况是所有 key 落进同一个桶——哈希函数选得差，或者有人刻意构造碰撞，表退化成一条链表。

## 结语

选型看两点：要不要频繁删除（链地址法不用处理墓碑），以及是否吃缓存（开放寻址在连续数组上更快）。但真正决定性能的是哈希函数的混合方式与装载因子阈值，「O(1)」只是平均意义上的结论。
