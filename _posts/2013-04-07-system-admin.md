---
layout: post
title: System Administration
categories: [sysadm]
tags: [RHEL]
---

## Introduction

System administration

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

## References

* [Red Hat Enterprise Linux 5.1 Deployment Guide](https://www.centos.org/docs/5/html/5.1/Deployment_Guide/index.html)
* [Tuning and Optimizing Red Hat Enterprise Linux For Oracle 9i and 10g Databases](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/5/html/Tuning_and_Optimizing_Red_Hat_Enterprise_Linux_for_Oracle_9i_and_10g_Databases)
* [kernel.txt](https://www.kernel.org/doc/Documentation/sysctl/kernel.txt)
* [Linux kernel profiling with perf](https://perf.wiki.kernel.org/index.php/Tutorial)

*[RAID]: Redundant Array of Independent Disks
*[iSCSI]: Internet Small Computer System Interface
