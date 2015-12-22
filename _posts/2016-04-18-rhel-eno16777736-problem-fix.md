---
layout: post
title: NIC eno16777736 problem fix
date: 2016-04-18 14:46:16.000000000 +08:00
type: post
published: true
status: publish
categories:
- sysadm
tags:
- udev
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---

## Introduction

NIC under Linux is sometimes mis-named as eno16777736. This article describes why this happend and how to fix it with either `udev` or `ifcfg-conn` network configuration scripts.

<!--more-->

*[NIC]: Network Interface Card

## Inspect NIC

{% highlight bash %}
udevadm info -p /sys/class/net/eno16777736 -a
{% endhighlight %}


## References

* [writing udev rules](http://reactivated.net/writing_udev_rules.html)
* [what-does-eno-mean-in-network-interface-name-eno16777736-for-centos-7-or-rhel](http://unix.stackexchange.com/questions/153785/what-does-eno-mean-in-network-interface-name-eno16777736-for-centos-7-or-rhel)

