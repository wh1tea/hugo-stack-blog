---
title: Android APK 的 ABI 版本怎么选
slug: android-apk-abi
date: 2026-09-26
description: 解释 arm64-v8a、armeabi-v7a、x86_64 与 universal APK 的区别，给出按设备架构选包的优先级
tags:
  - android
  - apk
  - abi
  - arm64
categories:
  - android
---

从 GitHub Release 下载 Android 应用时，常会看到 `app-arm64-v8a-release.apk`、`app-armeabi-v7a-release.apk`、`app-x86_64-release.apk`、`app-release.apk` 四个文件。它们对应不同的 CPU 架构（ABI），选错会装不上或白占空间。本文说明四者区别与选择顺序。

## 四个文件的区别

| 文件名                        | CPU 架构      | 适用设备                           | 说明                                     |
| :---------------------------- | :------------ | :--------------------------------- | :--------------------------------------- |
| `app-arm64-v8a-release.apk`   | `arm64-v8a`   | 2015 年后的主流安卓手机、平板      | 64 位 ARM，当前主流，性能最好            |
| `app-armeabi-v7a-release.apk` | `armeabi-v7a` | 2015 年前的旧机、低端入门设备      | 32 位 ARM；64 位设备可兼容运行，但非原生 |
| `app-x86_64-release.apk`      | `x86_64`      | 安卓模拟器、Intel 平板、Chromebook | 手机用户几乎用不到                       |
| `app-release.apk`             | 通用包        | 所有设备                           | 内含多种架构代码，兼容性最好，体积最大   |

补充：

- **arm64-v8a**：市面上绝大多数 2015 年后发布的安卓设备都是这个架构，包括华为、小米、OPPO、vivo、三星等品牌的大部分型号。
- **armeabi-v7a**：64 位设备通常也能跑 32 位包，但性能不如原生 64 位。
- **x86_64**：主要用于电脑上的安卓模拟器（MuMu、BlueStacks、Nox 等），普通手机用户用不到。
- **universal APK**：也叫 fat APK，内部同时打包 arm64-v8a、armeabi-v7a 等多套代码，所以体积最大。

## 怎么选

按优先级：

1. **首选 `app-arm64-v8a-release.apk`**：近 5–7 年购买的手机几乎都是这个架构，性能与兼容性最佳。
2. **备选 `app-armeabi-v7a-release.apk`**：装 arm64 版本失败、提示「应用与您的设备不兼容」时，再试这个——说明设备可能是较老的 32 位机型。
3. **不确定时选 `app-release.apk`**：通用包肯定能装上，代价是文件明显更大。
4. **模拟器才选 `app-x86_64-release.apk`**：普通手机直接忽略。

## 结语

直接下 `app-arm64-v8a-release.apk`，99% 的情况是对的；装不上再换 armeabi-v7a 或通用包。想确认自己设备的 ABI，可用 `adb shell getprop ro.product.cpu.abi` 查。
