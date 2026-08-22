---
title: Linux 命令速查手册
slug: linux-commands-cheatsheet
date: 2026-04-01
description: 覆盖常用 Linux 命令的分类速查手册，每条注明命令的全称缩写来源，适合日常参考和面试复习。
tags:
  - linux
  - shell
  - cheatsheet
  - command-line
categories:
  - linux
---

> 本文档覆盖常用 Linux 命令，每条注明命令的全称缩写来源。
> 反引号 `` ` `` 在 Bash 中表示命令替换。若没有闭合，Bash会进入多行输入模式，按 `Ctrl + C` 可退出。
> 比如：
>
> ```bash
> echo "Today is `date`"
> ```
>
> - Bash 看到 `` `date` ``，会先执行 `date` 命令（显示当前时间）。
> - 然后把 `date` 的输出结果（比如 `Wed Apr 01 12:30:00 CST 2026`）替换到原位置。
> - 最终实际执行的命令变成：`echo "Today is Wed Apr 01 12:30:00 CST 2026"`
>   所以你会看到输出：`Today is Wed Apr 01 12:30:00 CST 2026`

---

## 一、目录操作

| 命令      | 缩写来源                            | 说明                       | 示例                                   |
| --------- | ----------------------------------- | -------------------------- | -------------------------------------- |
| `pwd`     | **P**rint **W**orking **D**irectory | 显示当前所在目录的绝对路径 | `pwd` → `/home/user`                   |
| `ls`      | **L**i**s**t                        | 列出目录内容               | `ls -la`（含隐藏文件+详细信息）        |
| `cd`      | **C**hange **D**irectory            | 切换工作目录               | `cd ~`（家目录）、`cd -`（上一个目录） |
| `mkdir`   | **M**a**k**e **Dir**ectory          | 创建空目录                 | `mkdir -p a/b/c`（递归创建）           |
| `rmdir`   | **R**e**m**ove **Dir**ectory        | 删除空目录                 | `rmdir empty_dir`                      |
| `tree`    | —                                   | 以树形结构显示目录         | `tree -L 2`（只显示两层）              |
| `dirname` | **Dir**ectory **Name**              | 取路径中的目录部分         | `dirname a/b/c` → `a/b`                |

---

## 二、文件操作

| 命令       | 缩写来源             | 说明                                      | 示例                                |
| ---------- | -------------------- | ----------------------------------------- | ----------------------------------- |
| `touch`    | —                    | 创建空文件 / 更新文件时间戳               | `touch newfile.txt`                 |
| `cp`       | **C**o**p**y         | 复制文件或目录                            | `cp -r src/ dst/`（递归复制目录）   |
| `mv`       | **M**o**v**e         | 移动或重命名文件/目录                     | `mv old.txt new.txt`                |
| `rm`       | **R**e**m**ove       | 删除文件或目录                            | `rm -rf dir/`（强制递归删除）       |
| `cat`      | **Cat**enate         | 连接并显示文件内容                        | `cat file1 file2`                   |
| `tac`      | **Tac**（cat 倒写）  | 反向显示文件内容（最后一行在前）          | `tac file.txt`                      |
| `head`     | —                    | 显示文件开头（默认前 10 行）              | `head -n 20 file.txt`               |
| `tail`     | —                    | 显示文件末尾（默认后 10 行）              | `tail -f log.txt`（实时跟踪）       |
| `less`     | —                    | 分页查看文件（支持上下翻页）              | `less large.log`                    |
| `more`     | —                    | 分页查看文件（只支持下翻）                | `more file.txt`                     |
| `nl`       | **N**umber **L**ines | 显示文件并加行号                          | `nl file.txt`                       |
| `file`     | —                    | 检测文件类型                              | `file secret.bin` → `ELF 64-bit`    |
| `stat`     | **Stat**us           | 查看文件/目录的元信息（大小、权限、时间） | `stat file.txt`                     |
| `wc`       | **W**ord **C**ount   | 统计行数、单词数、字符数                  | `wc -l file.txt`（仅行数）          |
| `sort`     | —                    | 排序文件内容                              | `sort -n numbers.txt`（按数值排序） |
| `uniq`     | **Uniq**ue           | 去重（必须配合 sort）                     | `sort file \| uniq -c`（计数去重）  |
| `cut`      | —                    | 按字段截取文本                            | `cut -d: -f1 /etc/passwd`           |
| `diff`     | **Diff**erence       | 比较两个文件的差异                        | `diff -u file1 file2`（统一格式）   |
| `basename` | **Base** **Name**    | 取路径中的文件名部分                      | `basename a/b/c.txt` → `c.txt`      |
| `realpath` | **Real** **Path**    | 解析为绝对路径                            | `realpath ./file`                   |
| `readlink` | **Read** **Link**    | 显示符号链接的目标                        | `readlink -f symlink`               |

---

## 三、文本搜索与处理

| 命令     | 缩写来源                                        | 说明                                    | 示例                               |
| -------- | ----------------------------------------------- | --------------------------------------- | ---------------------------------- |
| `grep`   | **G**lobal **R**egular **E**xpression **P**rint | 在文件中搜索匹配的行                    | `grep -r "error" /var/log/`        |
| `egrep`  | **E**xtended **grep**                           | 支持扩展正则（等价于 `grep -E`）        | `egrep "foo\|bar" file`            |
| `fgrep`  | **F**ixed-string **grep**                       | 不解释正则（等价于 `grep -F`）          | `fgrep "$*." file`                 |
| `sed`    | **S**tream **Ed**itor                           | 流式编辑文本                            | `sed -i 's/old/new/g' file`        |
| `awk`    | 作者姓氏：Aho, Weinberger, **K**ernighan        | 按列处理文本                            | `awk '{print $1}' file`            |
| `tr`     | **Tr**anslate                                   | 替换或删除字符                          | `tr '[:lower:]' '[:upper:]'`       |
| `tee`    | T 形管道（分岔）                                | 同时输出到文件与标准输出                | `echo hi \| tee log.txt`           |
| `paste`  | —                                               | 按列合并多个文件                        | `paste file1 file2`                |
| `join`   | —                                               | 按公共字段连接两个文件（类似 SQL JOIN） | `join -t: file1 file2`             |
| `comm`   | **Comm**on                                      | 比较两个已排序文件的行                  | `comm file1 file2`                 |
| `xargs`  | —                                               | 将标准输入转为命令行参数                | `find . -name "*.log" \| xargs rm` |
| `sponge` | —                                               | 吸收标准输入再写出（解决管道覆盖问题）  | `sort file \| sponge file`         |

---

## 四、查找

| 命令      | 说明                             | 示例                            |
| --------- | -------------------------------- | ------------------------------- |
| `find`    | 在目录树中查找文件               | `find / -name "*.conf" -type f` |
| `locate`  | 通过数据库快速查找文件           | `locate myfile.txt`             |
| `which`   | 查找命令的可执行文件路径         | `which python3`                 |
| `whereis` | 查找命令的二进制、源码、手册页   | `whereis ls`                    |
| `type`    | 判断命令是内建、别名还是外部程序 | `type cd` → `shell builtin`     |

---

## 五、权限与用户

| 命令       | 缩写来源                  | 说明                         | 示例                    |
| ---------- | ------------------------- | ---------------------------- | ----------------------- |
| `chmod`    | **Ch**ange **Mod**e       | 修改文件权限                 | `chmod +x script.sh`    |
| `chown`    | **Ch**ange **Own**er      | 修改文件所有者               | `chown user:group file` |
| `chgrp`    | **Ch**ange **Gr**ou**p**  | 修改文件所属组               | `chgrp staff file`      |
| `umask`    | **U**ser **Mask**         | 设置新建文件/目录的默认权限  | `umask 022`             |
| `whoami`   | **Who** **a**m **I**      | 显示当前用户名               | `whoami`                |
| `id`       | **ID**entify              | 显示当前用户和组信息         | `id`                    |
| `who`      | —                         | 显示当前登录系统的用户       | `who`                   |
| `w`        | —                         | 显示登录用户及其活动         | `w`                     |
| `users`    | —                         | 列出当前登录的用户名         | `users`                 |
| `last`     | —                         | 显示最近的登录记录           | `last -n 10`            |
| `sudo`     | **S**uper **U**ser **Do** | 以超级用户或其他用户身份执行 | `sudo apt update`       |
| `su`       | **S**witch **U**ser       | 切换用户身份                 | `su - user1`            |
| `passwd`   | **Pass**wor**d**          | 修改用户密码                 | `passwd`                |
| `useradd`  | **User** **Add**          | 创建新用户                   | `useradd -m newuser`    |
| `usermod`  | **User** **Mod**ify       | 修改用户属性                 | `usermod -aG sudo user` |
| `userdel`  | **User** **Del**ete       | 删除用户                     | `userdel -r user`       |
| `groupadd` | **Group** **Add**         | 创建新组                     | `groupadd mygroup`      |

---

## 六、进程管理

| 命令         | 缩写来源                        | 说明                       | 示例                       |
| ------------ | ------------------------------- | -------------------------- | -------------------------- |
| `ps`         | **P**rocess **S**tatus          | 显示当前进程快照           | `ps aux`（所有进程）       |
| `top`        | **Top**                         | 实时显示进程与资源占用     | `top`                      |
| `htop`       | **H**euristic **top**           | 增强版 top（彩色、可滚动） | `htop`                     |
| `kill`       | —                               | 向进程发送信号             | `kill -9 PID`（强制终止）  |
| `killall`    | **Kill** **All**                | 按名称终止所有匹配进程     | `killall nginx`            |
| `pkill`      | **P**rocess **kill**            | 按名称/模式终止进程        | `pkill -f "python server"` |
| `nohup`      | **No** **H**ang **Up**          | 在退出终端后继续运行       | `nohup python script.py &` |
| `nice`       | —                               | 设置进程运行优先级         | `nice -n 10 ./slow`        |
| `renice`     | **Re**- **nice**                | 修改运行中进程的优先级     | `renice -n 5 PID`          |
| `bg`         | **B**ack**g**round              | 将暂停的进程放到后台运行   | `bg %1`                    |
| `fg`         | **F**ore**g**round              | 将后台进程调回前台         | `fg %1`                    |
| `jobs`       | —                               | 列出当前终端的后台作业     | `jobs -l`                  |
| `wait`       | —                               | 等待后台进程完成           | `wait %1`                  |
| `pgrep`      | **P**rocess **grep**            | 查询匹配条件的进程 PID     | `pgrep -u root sshd`       |
| `pidof`      | **PID** **of**                  | 查找指定程序的 PID         | `pidof nginx`              |
| `crontab`    | **Cron** **Tab**le              | 管理定时任务               | `crontab -e`（编辑）       |
| `at`         | —                               | 一次性定时任务             | `at now + 5 minutes`       |
| `systemctl`  | **System** **C**on**t**ro**l**  | 管理 systemd 服务          | `systemctl start nginx`    |
| `journalctl` | **Journal** **C**on**t**ro**l** | 查看 systemd 日志          | `journalctl -u nginx -f`   |

---

## 七、磁盘与存储

| 命令        | 缩写来源                         | 说明                             | 示例                                 |
| ----------- | -------------------------------- | -------------------------------- | ------------------------------------ |
| `df`        | **D**isk **F**ree                | 显示文件系统磁盘空间             | `df -h`（人类可读）                  |
| `du`        | **D**isk **U**sage               | 统计目录或文件占用的磁盘空间     | `du -sh *`（各项目总大小）           |
| `lsblk`     | **L**i**s**t **Bl**oc**k**       | 列出所有块设备                   | `lsblk`                              |
| `blkid`     | **Bl**oc**k** **ID**             | 显示块设备的 UUID 和文件系统类型 | `blkid`                              |
| `fdisk`     | **F**ixed **Disk**               | 管理分区表                       | `fdisk -l`                           |
| `mkfs`      | **M**a**k**e **F**ile**s**ystem  | 格式化分区创建文件系统           | `mkfs.ext4 /dev/sdb1`                |
| `mount`     | —                                | 挂载文件系统                     | `mount /dev/sdb1 /mnt/data`          |
| `umount`    | **U**n-**mount**                 | 卸载文件系统                     | `umount /mnt/data`                   |
| `dd`        | **D**ata **D**uplicator          | 低级别复制（可做磁盘镜像）       | `dd if=/dev/sda of=backup.img bs=4M` |
| `sync`      | **Sync**hronize                  | 将缓存写入磁盘                   | `sync`                               |
| `fsck`      | **F**ile**s**ystem **C**hec**k** | 检查并修复文件系统               | `fsck /dev/sdb1`                     |
| `badblocks` | **Bad** **Blocks**               | 扫描坏道                         | `badblocks -v /dev/sdb`              |
| `parted`    | **Part**ition **Ed**itor         | 高级分区工具                     | `parted /dev/sda`                    |
| `eject`     | —                                | 弹出光驱/可移动介质              | `eject /dev/cdrom`                   |
| `tmpwatch`  | **T**e**mp** **Watch**           | 删除长时间未访问的临时文件       | `tmpwatch 10 /tmp`                   |
| `fallocate` | **F**all**ocate**                | 快速预分配文件空间               | `fallocate -l 1G bigfile`            |

---

## 八、归档与压缩

| 命令      | 缩写来源                          | 说明                          | 示例                           |
| --------- | --------------------------------- | ----------------------------- | ------------------------------ |
| `tar`     | **T**ape **AR**chive              | 打包/解包文件（常与压缩配合） | `tar -czf archive.tar.gz dir/` |
| `gzip`    | **G**NU **Zip**                   | 压缩单个文件（.gz）           | `gzip file.txt`                |
| `gunzip`  | **G**NU **Un**-**Zip**            | 解压 .gz 文件                 | `gunzip file.txt.gz`           |
| `bzip2`   | **B**zi**p** **2**                | 更高压缩比的压缩工具（.bz2）  | `bzip2 file.txt`               |
| `bunzip2` | **B**zi**p** **Un**-**Zip** **2** | 解压 .bz2 文件                | `bunzip2 file.txt.bz2`         |
| `xz`      | —                                 | 高压缩比工具（.xz）           | `xz file.txt`                  |
| `unxz`    | **Un**- **xz**                    | 解压 .xz 文件                 | `unxz file.txt.xz`             |
| `zcat`    | **Z**ip **Cat**                   | 查看 gz 压缩文件内容          | `zcat log.gz`                  |
| `zip`     | —                                 | 打包并压缩为 .zip 格式        | `zip -r archive.zip dir/`      |
| `unzip`   | **Un**- **zip**                   | 解压 .zip 文件                | `unzip archive.zip`            |
| `zstd`    | **Z**-**St**an**d**ard            | Facebook 开发的高性能压缩工具 | `zstd file.txt`                |
| `unzstd`  | **Un**- **zstd**                  | 解压 .zst 文件                | `unzstd file.txt.zst`          |
| `7z`      | **7**-**Z**ip                     | 7-Zip 压缩/解压               | `7z a archive.7z dir/`         |
| `ar`      | **Ar**chive                       | 创建/管理静态库 .a 文件       | `ar rcs libfoo.a a.o b.o`      |

---

## 九、网络

| 命令            | 缩写来源                                        | 说明                             | 示例                                |
| --------------- | ----------------------------------------------- | -------------------------------- | ----------------------------------- |
| `ping`          | 声纳回声的拟声词                                | 测试网络连通性                   | `ping -c 4 google.com`              |
| `curl`          | **C**lient **URL**                              | 发送 HTTP/FTP 等网络请求         | `curl -I https://example.com`       |
| `wget`          | **W**orld **W**ide **Web** **Get**              | 下载文件                         | `wget https://example.com/file.zip` |
| `ssh`           | **S**ecure **Sh**ell                            | 远程登录到服务器                 | `ssh user@host`                     |
| `scp`           | **S**ecure **C**o**p**y                         | 通过 SSH 远程复制文件            | `scp file user@host:/path/`         |
| `rsync`         | **R**emote **Sync**hronization                  | 高效同步文件（增量传输）         | `rsync -avz src/ user@host:dst/`    |
| `nc` / `netcat` | **Net** **Cat**                                 | TCP/UDP 瑞士军刀                 | `nc -zv host 80`（端口扫描）        |
| `nslookup`      | **N**ame **S**erver **Lookup**                  | DNS 域名查询                     | `nslookup google.com`               |
| `dig`           | **D**omain **I**nformation **G**roper           | 更强大的 DNS 查询                | `dig google.com ANY`                |
| `host`          | —                                               | DNS 简单查询                     | `host google.com`                   |
| `traceroute`    | **Trace** **Route**                             | 追踪到目标的网络路径             | `traceroute google.com`             |
| `mtr`           | **M**y **T**race**r**oute                       | ping + traceroute 实时结合       | `mtr google.com`                    |
| `ip`            | **I**nternet **P**rotocol                       | 网络配置管理（替代 ifconfig）    | `ip addr show`                      |
| `ifconfig`      | **I**nter**f**ace **Config**uration             | 显示/配置网络接口（已淘汰）      | `ifconfig`                          |
| `iwconfig`      | **I**nter**W**ireless **Config**uration         | 显示/配置无线网络接口            | `iwconfig wlan0`                    |
| `ss`            | **S**ocket **S**tatistics                       | 查看 socket 状态（替代 netstat） | `ss -tuln`                          |
| `netstat`       | **Net**work **Stat**istics                      | 显示网络连接与端口（已淘汰）     | `netstat -tuln`                     |
| `route`         | —                                               | 查看/操作路由表                  | `route -n`                          |
| `nmcli`         | **N**etwork**M**anager **Cl**ient **I**nterface | 命令行管理网络连接               | `nmcli dev wifi list`               |
| `tcpdump`       | **TCP** **Dump**                                | 抓包分析网络流量                 | `tcpdump -i eth0 port 80`           |
| `nmap`          | **N**etwork **Map**per                          | 网络扫描器                       | `nmap -sP 192.168.1.0/24`           |
| `iptables`      | **IP** **Tables**                               | Linux 防火墙规则管理             | `iptables -L`                       |
| `ufw`           | **U**ncomplicated **F**ire**W**all              | 简化版防火墙                     | `ufw enable`                        |
| `ethtool`       | **Eth**ernet **Tool**                           | 查看/修改网卡参数                | `ethtool eth0`                      |
| `telnet`        | **Tel**ecommunication **Net**work               | 远程登录（明文，不安全）         | `telnet host 80`                    |
| `hostnamectl`   | **Host**name **C**on**t**ro**l**                | 查看/修改主机名                  | `hostnamectl set-hostname myserver` |

---

## 十、系统信息

| 命令          | 缩写来源                              | 说明                           | 示例                                |
| ------------- | ------------------------------------- | ------------------------------ | ----------------------------------- |
| `uname`       | **U**nix **Name**                     | 显示系统内核信息               | `uname -a`                          |
| `hostname`    | **Host** **Name**                     | 显示/设置主机名                | `hostname`                          |
| `uptime`      | **Up** **Time**                       | 显示系统运行时间与负载         | `uptime`                            |
| `dmesg`       | **D**iagnostic **Mes**sa**g**e        | 显示内核环形缓冲区日志         | `dmesg \| tail -20`                 |
| `lscpu`       | **L**i**s**t **CPU**                  | 显示 CPU 信息                  | `lscpu`                             |
| `lsmem`       | **L**i**s**t **Mem**ory               | 显示内存布局                   | `lsmem`                             |
| `free`        | —                                     | 显示内存使用情况               | `free -h`                           |
| `vmstat`      | **V**irtual **M**emory **Stat**istics | 显示虚拟内存、进程、CPU 统计   | `vmstat 1`（每秒刷新）              |
| `iostat`      | **IO** **Stat**istics                 | 显示 I/O 性能统计              | `iostat -x 1`                       |
| `mpstat`      | **M**ulti**P**rocessor **Stat**istics | 显示每个 CPU 核心的使用率      | `mpstat -P ALL 1`                   |
| `sar`         | **S**ystem **A**ctivity **R**eport    | 系统性能数据收集与报告         | `sar -u 1 3`                        |
| `lsof`        | **L**i**s**t **O**pen **F**iles       | 列出当前系统打开的文件         | `lsof -i :80`（监听 80 端口的进程） |
| `ldd`         | **L**ist **D**ynamic **D**ependencies | 查看 ELF 文件的动态链接库      | `ldd /bin/ls`                       |
| `ldconfig`    | **L**o**a**d **Config**uration        | 更新动态链接库缓存             | `ldconfig -p`（列出缓存）           |
| `locale`      | **Loc**al**e**                        | 显示/设置系统语言环境          | `locale -a`（列出所有）             |
| `timedatectl` | **Time**/**Date** **C**on**t**ro**l** | 查看/设置系统时间与时区        | `timedatectl list-timezones`        |
| `cal`         | **Cal**endar                          | 显示日历                       | `cal 2026`                          |
| `date`        | —                                     | 显示/设置日期时间              | `date +"%Y-%m-%d %H:%M"`            |
| `hwclock`     | **H**ard**w**are **Clock**            | 查看/设置硬件时钟（BIOS 时间） | `hwclock --show`                    |
| `nproc`       | **N**umber of **Proc**essors          | 显示 CPU 核心数                | `nproc`                             |
| `arch`        | **Arch**itecture                      | 显示系统架构                   | `arch` → `x86_64`                   |

---

## 十一、包管理

### Debian/Ubuntu

| 命令        | 缩写来源                                      | 说明                     | 示例                                       |
| ----------- | --------------------------------------------- | ------------------------ | ------------------------------------------ |
| `apt`       | **A**dvanced **P**ackaging **T**ool           | 包管理工具               | `apt update && apt upgrade`                |
| `apt-get`   | **A**dvanced **P**ackaging **T**ool **get**   | 包管理旧版命令           | `apt-get install nginx`                    |
| `apt-cache` | **A**dvanced **P**ackaging **T**ool **cache** | 搜索与查询包信息         | `apt-cache search nginx`                   |
| `dpkg`      | **D**ebian **P**acka**g**e                    | Debian 包管理器底层工具  | `dpkg -i package.deb`                      |
| `snap`      | —                                             | Canonical 的容器化包管理 | `snap install lxd`                         |
| `flatpak`   | **Flat** **P**ac**k**age                      | Linux 通用沙箱应用管理   | `flatpak install flathub org.videolan.VLC` |

### Red Hat / CentOS / Fedora

| 命令  | 缩写来源                                  | 说明                        | 示例                   |
| ----- | ----------------------------------------- | --------------------------- | ---------------------- |
| `yum` | **Y**ellowdog **U**pdater **M**odified    | RHEL/CentOS 7 及以下包管理  | `yum install nginx`    |
| `dnf` | **D**andified **YUM** (**N**o **F**ormal) | Fedora/RHEL 8+ 新一代包管理 | `dnf install nginx`    |
| `rpm` | **R**PM **P**ackage **M**anager           | RPM 包管理器底层工具        | `rpm -ivh package.rpm` |

### Arch Linux

| 命令     | 缩写来源                       | 说明            | 示例                   |
| -------- | ------------------------------ | --------------- | ---------------------- |
| `pacman` | **Pac**kage **Man**ager        | Arch 包管理工具 | `pacman -S nginx`      |
| `yay`    | **Y**et **A**nother **Y**ogurt | AUR 包管理助手  | `yay -S google-chrome` |

---

## 十二、文件传输 & 远程复制

| 命令     | 缩写来源                                   | 说明                              | 示例                                    |
| -------- | ------------------------------------------ | --------------------------------- | --------------------------------------- |
| `scp`    | **S**ecure **C**o**p**y                    | 基于 SSH 的远程复制               | `scp file user@host:/remote/path`       |
| `rsync`  | **R**emote **Sync**hronization             | 增量同步（远程/本地）             | `rsync -avz --progress src/ dst/`       |
| `ftp`    | **F**ile **T**ransfer **P**rotocol         | 传统文件传输                      | `ftp ftp.example.com`                   |
| `sftp`   | **S**SH **F**ile **T**ransfer **P**rotocol | 基于 SSH 的安全文件传输           | `sftp user@host`                        |
| `lftp`   | —                                          | 增强版命令行 FTP 客户端           | `lftp ftp.example.com`                  |
| `rclone` | **R**emote **Clone**                       | 云存储同步（Google Drive, S3 等） | `rclone sync local: remote:backup`      |
| `curl`   | **C**lient **URL**                         | 支持众多协议的传输工具            | `curl -O https://example.com/file.zip`  |
| `wget`   | **W**orld **W**ide **Web** **Get**         | 递归下载、断点续传                | `wget -c https://example.com/large.iso` |

---

## 十三、链接与设备

| 命令       | 缩写来源                      | 说明                   | 示例                               |
| ---------- | ----------------------------- | ---------------------- | ---------------------------------- |
| `ln`       | **L**i**n**k                  | 创建硬链接或符号链接   | `ln -s target link_name`（软链接） |
| `readlink` | **Read** **Link**             | 读取符号链接的目标路径 | `readlink -f /usr/bin/python3`     |
| `mknod`    | **M**a**k**e **Nod**e         | 创建设备文件           | `mknod /dev/mydev c 240 0`         |
| `udevadm`  | **U**ser **Dev**ice **Adm**in | 管理 udev 设备规则     | `udevadm info -a -n /dev/sda`      |

---

## 十四、Shell 内建 & 编程相关

| 命令           | 缩写来源                | 说明                           | 示例                               |
| -------------- | ----------------------- | ------------------------------ | ---------------------------------- |
| `echo`         | —                       | 输出字符串到标准输出           | `echo "Hello, World!"`             |
| `printf`       | **Print** **F**ormatted | 格式化输出                     | `printf "%s %d\n" "count" 42`      |
| `read`         | —                       | 从标准输入读取一行             | `read -p "Name: " name`            |
| `alias`        | —                       | 创建命令别名                   | `alias ll='ls -la'`                |
| `unalias`      | **Un**- **alias**       | 移除别名                       | `unalias ll`                       |
| `export`       | —                       | 设置环境变量                   | `export PATH=$PATH:/my/bin`        |
| `source`       | —                       | 在当前 shell 中执行脚本        | `source ~/.bashrc`                 |
| `.`            | —                       | 等同于 source                  | `. ~/.bashrc`                      |
| `set`          | —                       | 设置/查看 Shell 选项与位置参数 | `set -e`（出错即停）               |
| `unset`        | **Un**- **set**         | 删除变量或函数                 | `unset MY_VAR`                     |
| `env`          | **Env**ironment         | 查看/运行带临时环境变量的命令  | `env \| grep PATH`                 |
| `shift`        | —                       | 左移位置参数                   | `shift 2`                          |
| `let`          | —                       | Shell 算术运算                 | `let a=5+3`                        |
| `exec`         | **Exec**ute             | 执行命令替换当前进程           | `exec bash`（替换当前 shell）      |
| `eval`         | **Eval**uate            | 执行字符串作为命令             | `eval "$cmd"`                      |
| `test` / `[ ]` | —                       | 条件测试                       | `test -f file.txt && echo exists`  |
| `[[ ]]`        | —                       | 增强版条件测试（Bash 特有）    | `[[ $a > $b ]] && echo yes`        |
| `(())`         | —                       | 算术计算（Bash 特有）          | `(( result = a + b ))`             |
| `trap`         | —                       | 捕获信号执行自定义操作         | `trap cleanup EXIT`                |
| `exit`         | —                       | 退出 Shell 并返回退出码        | `exit 1`                           |
| `return`       | —                       | 从函数中返回                   | `return 42`                        |
| `break`        | —                       | 跳出循环                       | `break 2`（跳出两层）              |
| `continue`     | —                       | 跳过本次循环迭代               | `continue`                         |
| `case`         | —                       | 模式匹配分支语句               | `case $x in a) ...;; esac`         |
| `select`       | —                       | 生成菜单供用户选择             | `select opt in a b c; do ... done` |

---

## 十五、输入输出重定向 & 管道

---

| 符号/命令  | 说明                                           | 示例                         |
| ---------- | ---------------------------------------------- | ---------------------------- |
| `>`        | 标准输出重定向（覆盖）                         | `echo hi > file.txt`         |
| `>>`       | 标准输出重定向（追加）                         | `echo hi >> file.txt`        |
| `<`        | 标准输入重定向                                 | `wc -l < file.txt`           |
| `2>`       | 标准错误重定向                                 | `cmd 2> error.log`           |
| `2>&1`     | 将标准错误合并到标准输出                       | `cmd > all.log 2>&1`         |
| `&>`       | 同时重定向 stdout + stderr                     | `cmd &> out.log`             |
| `\|`       | **管道**：将一个命令的输出传给下一个命令的输入 | `ls \| grep .txt`            |
| `\| &`     | 管道 + 重定向 stderr                           | `cmd \| & tee log`           |
| `tee`      | 分叉输出（写到文件 + 打印到终端）              | `ls \| tee files.txt`        |
| `()`       | **子 Shell**：在子 shell 中执行命令            | `(cd /tmp && ls)`            |
| `{}`       | **当前 Shell 组合**：在当前 shell 中组合命令   | `{ echo a; echo b; }`        |
| `$(...)`   | **命令替换**：嵌入命令结果                     | `echo "Today is $(date)"`    |
| `` ` ``    | **命令替换**（旧语法）                         | ``echo "Today is `date`"``   |
| `$((...))` | **算术扩展**                                   | `echo $((5 + 3))`            |
| `<(...)`   | **进程替换**：将命令输出作为文件传入           | `diff <(ls dir1) <(ls dir2)` |

---

## 十六、信号

| 信号      | 数值 | 说明                 | 用途                   |
| --------- | ---- | -------------------- | ---------------------- |
| `SIGHUP`  | 1    | 挂起（终端断开）     | 让守护进程重新加载配置 |
| `SIGINT`  | 2    | 中断（Ctrl + C）     | 终止前台进程           |
| `SIGQUIT` | 3    | 退出（Ctrl + \）     | 终止并产生 core dump   |
| `SIGKILL` | 9    | 强制终止（不可捕获） | 强制杀死卡死的进程     |
| `SIGTERM` | 15   | 终止（默认信号）     | 请求优雅终止进程       |
| `SIGSTOP` | 19   | 暂停（不可捕获）     | 冻结进程执行           |
| `SIGCONT` | 18   | 恢复停止的进程       | 让暂停的进程继续运行   |
| `SIGTSTP` | 20   | 终端暂停（Ctrl + Z） | 将前台进程放到后台暂停 |
| `SIGUSR1` | 10   | 用户自定义信号 1     | 应用自定义用途         |
| `SIGUSR2` | 12   | 用户自定义信号 2     | 应用自定义用途         |

---

## 十七、实用技巧速查

### 快捷键（Bash 默认）

| 快捷键     | 说明                             |
| ---------- | -------------------------------- |
| `Ctrl + C` | 终止当前命令                     |
| `Ctrl + D` | 退出 Shell / 输入 EOF            |
| `Ctrl + Z` | 暂停进程（放到后台）             |
| `Ctrl + L` | 清屏（等同于 `clear`）           |
| `Ctrl + A` | 跳到行首                         |
| `Ctrl + E` | 跳到行尾                         |
| `Ctrl + U` | 删除光标前所有字符               |
| `Ctrl + K` | 删除光标后所有字符               |
| `Ctrl + W` | 删除光标前一个单词               |
| `Ctrl + R` | 反向搜索历史命令                 |
| `Ctrl + Y` | 粘贴被删除的内容（yank）         |
| `Alt + .`  | 粘贴上一条命令的最后一个参数     |
| `!!`       | 重复上一条命令                   |
| `!$`       | 上一条命令的最后一个参数         |
| `!?string` | 执行包含 string 的最近一条命令   |
| `↑ / ↓`    | 浏览命令历史                     |
| `Tab`      | 自动补全（按两次显示所有候选项） |

### 常用退出码

| 退出码    | 含义                                      |
| --------- | ----------------------------------------- |
| `0`       | 成功                                      |
| `1`       | 一般错误                                  |
| `2`       | 误用 Shell 内建命令                       |
| `126`     | 命令不可执行                              |
| `127`     | 命令未找到                                |
| `128`     | 无效退出参数                              |
| `128 + N` | 被信号 N 终止（例如 `130` = Ctrl+C 终止） |
| `255`     | 退出码超出范围                            |

### 常用环境变量

| 变量          | 说明                          |
| ------------- | ----------------------------- |
| `$HOME` / `~` | 当前用户家目录                |
| `$PATH`       | 可执行文件搜索路径            |
| `$PWD`        | 当前工作目录                  |
| `$OLDPWD`     | 上一个工作目录（`cd -` 使用） |
| `$SHELL`      | 当前使用的 Shell 路径         |
| `$USER`       | 当前用户名                    |
| `$HOSTNAME`   | 主机名                        |
| `$LANG`       | 系统语言环境                  |
| `$EDITOR`     | 默认编辑器                    |
| `$TERM`       | 终端类型                      |
| `$PS1`        | 命令行提示符格式              |
| `$?`          | 上一条命令的退出码            |

---
