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

## References

* [Red Hat Enterprise Linux 5.1 Deployment Guide](https://www.centos.org/docs/5/html/5.1/Deployment_Guide/index.html)
* [Tuning and Optimizing Red Hat Enterprise Linux For Oracle 9i and 10g Databases](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/5/html/Tuning_and_Optimizing_Red_Hat_Enterprise_Linux_for_Oracle_9i_and_10g_Databases)
* [kernel.txt](https://www.kernel.org/doc/Documentation/sysctl/kernel.txt)
* [Linux kernel profiling with perf](https://perf.wiki.kernel.org/index.php/Tutorial)

*[RAID]: Redundant Array of Independent Disks
*[iSCSI]: Internet Small Computer System Interface
