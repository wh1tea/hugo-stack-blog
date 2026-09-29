---
title: Windows 休眠唤醒后自动拨号
slug: windows-wake-up-auto-dial
date: 2026-01-28T00:00:00+08:00
description: 用任务计划程序监听 Kernel-Power 事件 107，在 Windows 从休眠唤醒后自动执行 rasdial 拨号，并附网卡电源管理排查
tags:
  - windows
  - configuration
  - troubleshooting
  - network
  - shortcut
categories:
  - windows
---

Windows 从休眠唤醒后，PPPoE 宽带连接不会自动重拨，需要手动点一次。本文用任务计划程序监听唤醒事件，触发 `rasdial` 自动拨号，适合拨号账号固定在机器上的台式机，或长期插电的笔记本。

## 使用命令连接

在 CMD / PowerShell 中运行 `rasdial`，也可以写成脚本、快捷方式或计划任务，由系统调用。格式：

```text
rasdial "Broadband Connection" username password
```

想快速手动拨号，可创建桌面快捷方式，把 `Broadband Connection` 换成你实际创建的连接名。注意：密码会以明文写在快捷方式里，任何能接触这台机器的人都能读到。介意的话，把密码换成 `*`，运行时系统会弹窗要求手输：

```text
rasdial "Broadband Connection" 505 *
```

## 用事件触发器监听唤醒

Windows 没有「从休眠唤醒后执行某程序」的图形化预设触发器，但可以用任务计划程序的事件触发器间接实现。

按 `Win + R`，输入 `taskschd.msc` 打开任务计划程序，右侧点击「创建任务」。

### 常规

- 名称：`WakeAndConnect`
- 勾选「使用最高权限运行」
- 「配置为」选择 Windows 10 或 Windows 11

### 触发器

点击「新建」，开始任务选「发生事件时」，设置选「自定义」，点击「编辑事件筛选器」→「XML」标签页，勾选「手动编辑查询」，粘贴：

```xml
<QueryList>
  <Query Id="0" Path="System">
    <Select Path="System">*[System[Provider[@Name='Microsoft-Windows-Kernel-Power'] and EventID=107]]</Select>
  </Query>
</QueryList>
```

下方「延迟任务」填 `15 seconds`，给网卡初始化留出时间。

`Kernel-Power` 事件 107 是系统从睡眠 / 休眠恢复时写入的，用它比用「工作站解锁」更贴近「唤醒」这个动作。

### 操作

点击「新建」，操作选「启动程序」：

- 程序或脚本：`rasdial`
- 添加参数：`"Broadband Connection" username password`

连接名两侧要加双引号，三段之间各留一个空格。

> 如果系统找不到 `rasdial`，可填完整路径，例如 `C:\Windows\System32\rasdial.exe`。

### 条件

取消勾选「只有在计算机使用交流电源时才启动任务」，否则笔记本用电池时不会执行。

### 设置

勾选「允许按需运行任务」，取消勾选「如果任务运行时间超过……则停止任务」。拨号本身瞬间完成，不需要超时限制。

## 唤醒后仍连不上：查网卡电源管理

如果任务确实执行了，但网络没起来，问题通常在网卡本身没有恢复工作，而不在拨号命令。

设备管理器 → 网络适配器 → 你的网卡 → 属性 → 电源管理，取消勾选：

```text
允许计算机关闭此设备以节约电源
```

另外确认电源选项中允许使用唤醒定时器：

```text
powercfg.cpl → 更改计划设置 → 更改高级电源设置 → 睡眠 → 允许使用唤醒定时器 → 启用
```

## 中英对照

| 中文                           | English                                                  |
| :----------------------------- | :------------------------------------------------------- |
| 任务计划程序                   | Task Scheduler                                           |
| 创建任务                       | Create Task                                              |
| 触发器                         | Triggers                                                 |
| 发生事件时                     | On an event                                              |
| 操作                           | Actions                                                  |
| 启动程序                       | Start a program                                          |
| 条件                           | Conditions                                               |
| 电源管理                       | Power Management                                         |
| 允许计算机关闭此设备以节约电源 | Allow the computer to turn off this device to save power |

## 结语

事件触发器负责「什么时候拨」，`rasdial` 负责「怎么拨」，网卡电源管理负责「拨得通不通」——三处都对了，休眠唤醒后网络才会自己回来。密码明文写在参数里有泄露风险，公用机器上建议改用 `*` 手输。
