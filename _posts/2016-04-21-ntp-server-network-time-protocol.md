---
layout: post
title: NTP Server (Network Time Protocol)
date: 2016-04-21 14:09:02.000000000 +08:00
type: post
published: true
status: publish
categories:
- network
- sysadm
tags:
- ntp
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---

![NTP Server](/assets/ntp-server.png)

## Introduction

Setting your servers's clock and timezone properly is essential in ensuring the healthy operation of distrubted systems and maintain accurate log timestamps. This article will show you how to install and configure the NTP time synchronization service on an Red Hat Enterprise Linux 7.2 Server.

<!--more-->

## Set Timezone


```shell
# list available timezones
$ timedatectl list-timezones
# set desired timezone
sudo timedatectl set-timezone Asia/Shanghai
# verify the timezone has been set properly
$ timedatectl
```

## Install

```shell
yum -y install ntp
```

## Configure

Choose ntp servers and add them to the configure file

```conf
server 0.rhel.pool.ntp.org iburst
server 1.rhel.pool.ntp.org iburst
server 2.rhel.pool.ntp.org iburst
server 3.rhel.pool.ntp.org iburst
```

### Setup Client Range

```
restrict 192.168.249.0 mask 255.255.255.0 nomodify notrap
```

### Log File

```conf
logfile /var/log/ntp.log

### Firewall

```shell
# firewall-cmd --add-service=ntp --permanent
# firewall-cmd --reload
```

## Service Management

```shell
# systemctl start ntpd
# systemctl enable ntpd
# systemctl status ntpd
```

### Verify Server Configure

```shell
ntpq -p
```
