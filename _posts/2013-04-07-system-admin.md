---
layout: post
title: System Administration
categories: [sysadm]
tags: [RHEL]
---

## Introduction

System administration handbook.

<!--more-->

## Table of Contents

* TOC
{:toc}

## Overview

0. select system
0. setup
	* CPU
	* memory
	* storage
		* RAID
		* LVM
	* network
	* virtualization
0. deploy service
	* httpd
	* mysql
0. security
	* solution
		* SELinux
		* AppArmor
	* intrusion
		* Detection
		* Recovery

## Storage

* Storage Consideration During Installation
* File System Check
* Partitions
* Create and Maintaining Snapshots
	* snapper
* Swap Space
* System Storage Manage
	* SSM
* Disk Quotas
* RAID
* mount
* volumn-key
* Access Control Lists
* Solide-State Disk Deploymen Guidelines
* Write barriers
* Storage I/O Allignment and Size
* Setting up A Remote Diskless System
* Outline Storage Management
* Device Mapper and Multipathing and Virtual Storage
* Extend Array Management

software iSCSI

IP-based (IP packets) standard for connecting storage devices

scsi command

iSCSI architecture

* server: target
* client: initiator
	* hardware-based HBA
	* software
		* kernel-resident device driver
		* NIC
		* network stack

emulate

topology

```
-------------------
| iSCSI initiator |
-------------------
        |                    ---------------------
-----------------------------| IP-based Intranet |---------
             |               ---------------------
      -------------------
      | iSCSI initiator |
      -------------------
```

TPG: target Dortal Group

LUN: Logical Unit Number

* write-through: no cache
* write-back: write cache

mount option

_netdev: prevent mount attempt until the network has been enabled

* Device Multipathing
	* connection rebalancing
	* failover compatibility
	* load balancing
	* improved performance

Device-Mapper Multipath: DM-Multipath
: represent multiple I/O paths between a server and a storage device as a single path

* btrfs
	* don't support swap
	* Integerated logical volumn management
		* RAID 0
		* RAID 1
		* RAID 10
	* copy-on-write
		* expanding scalability request of large storage system
	* B tree
	* 50 TB
	* transparent
		* compression
		* defragmentation
* ext4
	* physical blocks (extents)
	* pre-allocation
	* delayed allocation
	* faster file system checking
* xfs
	* high performance
	* high scalability for I/O threads
	* 16TB/500TB
	* lazy counters
* NFS
	* v3
		* rpcbind
		* separate service
			* mount protocol
			* lock protocol
	* v4
		* TCP: 2049 -> service requests

LVM

DM

MD

```
LV1      LV2     LV3
--------------------
         |
       --v---
       | vg |
       ------
         |
         v
--------------------
sda1    sda2    sdb1
```

Automatic Storage Management ASM

raw disk

partition align on Megabyte bourdaries

mount discard (TRIM) has an impact on system performance

fstrim (SSD) either:

* before install
* before creating a new file system

FCoE: Fibre Channel over Ehternet

## Device

Device Files

* /dev/
	* dev special files
	* device nodes
		* block/char -> major/minor as ident
	* pseudo devices
		* null
		* random
		* urandom
		* zero

## Network

ipvlan (L2, L3)

Network Bridge
: forward traffic based on table of mac addresses

ssh -L 8000:server:25 intermediary

local:8000 -> intermediary -> server:25

TCP

SPT: server process time

## Service

### MySQL

* turn off engery saving
	* cpuspeed
* swappiness -> 0
* mount options
	* noatime
	* nobarrier
* I/O scheduler
	* deadline

### Others


* acpi-support 这个是关于电源支持的默认是1,2,3,4,5下启动
* acpid acpi的守护程序，默认是2-5开启
* alsa alsa声音子系统
* alsa-utils
* apmd power management
* anacron 这是一个用于执行到时间没有执行的程序的服务
* atd 和anacron: task management
* bluez-utiles
* bootlogd
* cron 指定时间运行程序的服务
* cupsys 打印机服务
* dbus 消息总线系统
* dns-clean 拨号连接用的
* evms 企业卷管理系统
* fetchmail
* gdm gnome
* halt
* hdparm
* hotkey-setup
* hotplug 这个是用于热插拔的
* hplip hp打印机专用的
* ifrename 网络接口重命名
* ifupdown 这个使用来打开网络的
* ifupdown-clean 同上
* klogd linux守护程序，接受来自内核和发送信息到syslogd的记录，并记录为一个文件
* linux-restricted-modules-common 这个使用来使用受限制的模块的，你可以从/lib/linux-restricted-modules下查看
* lvm 逻辑卷管理器
* makedev 用来创建设备到/dev/
* mdamd 管理raid用
* module-init-tools 从/etc/modules 加在扩展模块的
* networking 增加网络接口和配置dns用
* ntp-server 与ubuntu时间服务器进行同步的
* pcmcia 激活pcmica设备
* powernowd 用于管理cpu的客户端程序，如果有变频功能，比如amd的quite' cool 那么就开启它
* ppp 拨号用的
* ppp-dns 一样
* readahead 预加载服务
* reboot 重启用的
* rmnologin
* rsync rsync协议守护
* screen-cleanup
* sendsigs 重启和关机时向所有进程发送消息
* stop-bootlogd 从2,3,4,5级别停止bootlogd
* sudo
* sysklogd 用于记录系统日志信息
* udev 用户空间dev文件系统
* udev-mab 同上
* umountfs 用来卸载文件卷的
* urandom 生成随即数的
* usplash 那个漂亮的启动画面
* vbesave 显卡bios配置工具
* xorg-common 设置x服务ice socket

## Command

### kill

```shell
# kill a process group
kill -1234
```

### find

find

```shell
find $MYPLACE -type mosquito | xargs kill
```

删除创建时间在 30 天之前的文件:

```shell
find . -type f -ctime +30 -ctime -3600 -exec rm {} ;
```

统计当前目录下所有 jpg 文件的尺寸:

```shell
find . -name *.jpg -exec wc -c {} ;|awk '{print $1}'|awk '{a+=$1}END{print a}'
```

显示一小时以内的包含 xxxx 的文件:

```shell
find . -type f -mmin -60|xargs -i grep -l xxxx '{}'
```

修改 CPU 模式为 ondemand
在启动应用程序里添加上这一命令，开机运行即可

```
cpufreq-selector -g ondemand
```

以此类推，可以更改为任意模式:

* conservitive
* ondemand
* powersave
* performance

shutdown

```shell
sudo shutdown -h +200
```

表示等200分钟后关机。 可以 `shutdown --help` 看其他选项。

sudo

如何切换到 root 帐号:  `sudo -Hs`

修改系统登录信息:  `sudo vim /etc/motd`

显示 nsd 进程现在打开的文件: `lsof -c nsd`

显示包含字符串的文件名:  `grep -l -r 字符串 路径`

增加用户:  `sudo adduser 用户名`

查看域名的注册备案情况:  `whois baidu.cn`

设置日期:  `date -s mm/dd/yy`

设置电脑的时区为上海:

```shell
sudo cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

转换 bin/cue 到 iso 文件:

```shell
sudo apt-get install bchunk
bchunk image.bin image.cue image
```

手工增加一条路由:

```shell
sudo route add -net 192.168.0.0 netmask 255.255.255.0 gw 172.16.0.1
```

清理所有软件缓存:

```shell
sudo apt-get clean
```

按内存从大到小排列进程:

```shell
ps -eo "%C : %p : %z : %a" | sort -k5 -nr
```

按 cpu 利用率从大到小排列进程:

```shell
ps -eo "%C : %p : %z : %a" | sort -nr
```

延迟5秒抓当前激活窗口: `gnome-screenshot -w -d 5`

统计当前目录个数: `ls -l |grep ^d|wc -l`

临时重启一个服务:  `/etc/init.d/服务名 restart`

查看 IDE 硬盘信息:  `sudo hdparm -i /dev/hda`

查看路由信息:

```shell
netstat -rn
# or
sudo route -n
```

查看到某一个域名的路由情况:  `tracepath t.co`

转换 mp3 标签编码:

```shell
sudo apt-get install python-mutagen
find . -iname '*.mp3' -execdir mid3iconv -e GBK {} ;
```

检查本地是否存在安全隐患:  `sudo apt-get install rkhunter;rkhunter --checkall`

命令关机:  `sudo halt`

增加用户到 admin 组:  `usermod -G admin -a username`

备份当前系统安装的所有包的列表:

```shell
dpkg --get-selections | grep -v deinstall &gt; ~/somefile
```

统计当前 IP 连接的个数:

```shell
netstat -na | grep ESTABLISHED | awk '{print $5}' | awk -F: '{print $1}' | sort | uniq -c | sort -r -n
```

批量将 rmvb 转为 avi:

```shell
for i in ./*;
do mencoder -oac mp3lame -lameopts vbr=3 -ovc xvid -xvidencopts fixed_quant=4 -of avi $i -o `echo $i | sed -e 's/rmvb$/avi/'`
done
```

把所有文件名中的大写改为小写:  `rename 'tr/A-Z/a-z/' *`

查找文件属于哪个包:  `dpkg -S filename`

查看当前 IP 地址:  `ifconfig eth0 | awk '/inet/ {split($2,x,":");print x[2]}'`

制作 ISO 文件:  `mkisofs -o test.iso -Jrv -V test_disk /home/carla/`

查询软件 xxx 被哪些包依赖:  `apt-cache rdepends xxx`

查看硬盘的分区:  `sudo fdisk -l`

立即让网络支持nat:

```shell
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
sudo iptables -t nat -I POSTROUTING -j MASQUERADE
```

根据 IP 查网卡地址:  `arping IP地址`

使用 sun 的 java 编译器:  `sudo update-java-alternatives -s java-6-sun`

修改计算机名

```shell
sudo gedit /etc/hostname
# or
sudo hostname 新名称
```

安装 RAR 支持

```shell
sudo apt-get install rar unrar
```

## Ramdisk

Ubuntu 默认将内存的一半作为 ramdisk 空间使用。
挂载点为 /dev/shm
文件类型为 tmpfs

/dev/shm 不完全是 RamDisk，若它使用超过电脑一半以上的 RAM，就会开始吃 SWAP。
另外它没用到的部份，会自动释放出来给系统使用

ramdisk 作用可以将缓存放到其中，这样延长硬盘寿命，并且提高电脑速度

1. 修改 ramdisk 操作

	调整 /dev/shm 目录的大小

	1. 查看大小

       ```
       df -h /dev/shm
       ```

	2. 修改大小

       ```
       vi /etc/fstab
       tmpfs /dev/shm tmpfs defaults,size=4096M 0 0
       # 如果没有这行，可以自己加入并修改 size 大小
       # size 参数也可以用 G 作单位: `size=1G`。
       ```

	3. 重新挂载

       ```shell
       umount /dev/shm
       mount /dev/shm
       ```

	4. 查看修改后的大小

       ```
       df -h /dev/shm
       ```

2. 将 /tmp 目录设置到 RamDisk 的方法

	基本上只要打以下指令，就能将 /tmp 绑定到 /dev/shm

       ```shell
       mkdir /dev/shm/tmp
       chmod 1777 /dev/shm/tmp
       mount --bind /dev/shm/tmp /tmp
       ```

	注: 为何是用 mount --bind 绑定，而不是 ln -s 软连结，原因是 /tmp 目录，系统不给删除。

## References

* [Red Hat Enterprise Linux 5.1 Deployment Guide](https://www.centos.org/docs/5/html/5.1/Deployment_Guide/index.html)
* [Tuning and Optimizing Red Hat Enterprise Linux For Oracle 9i and 10g Databases](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/5/html/Tuning_and_Optimizing_Red_Hat_Enterprise_Linux_for_Oracle_9i_and_10g_Databases)
* [kernel.txt](https://www.kernel.org/doc/Documentation/sysctl/kernel.txt)
* [Linux kernel profiling with perf](https://perf.wiki.kernel.org/index.php/Tutorial)

*[RAID]: Redundant Array of Independent Disks
*[iSCSI]: Internet Small Computer System Interface
