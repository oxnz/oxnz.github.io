---
title: System Administration - Security
categories: [sysadm]
tags: [firewalld, iptables]
---

## Introduction

This article describes security related stuff about server and workstation.

<!--more-->

## Table of Cotents

* TOC
{:toc}

## Firewall

* firewalld
	* a dynamic firewall daemon
	* provides a **dynamically managed firewall** with support for network zones to assign a level of trust to a network and its associated connections and interfaces
	* support Ethernet bridges
	* has a separation of runtime and permanent configuration options
	* has an interface for services or applications to add firewall rules directly
	* configure files
		* /usr/lib/firewalld
		* /etc/firewalld
	* other applications use DBus to communicate with firewalld
	* can change settings during runtime without connections being lost

```
system-config-firewall  firewall-config firewall-cmd
         |                     |             |
         v                     v             v
  iptables(service)      firewalld(daemon & service)
          \                          /
           -------------v------------
               iptables(command)
                      |
                      v
              kernel(netfilter)
```

* [Netfilter](http://www.netfilter.org/documentation/)
