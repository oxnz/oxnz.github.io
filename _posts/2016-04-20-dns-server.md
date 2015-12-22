---
layout: post
title: DNS Server
date: 2016-04-20 17:49:10.000000000 +08:00
type: post
published: true
status: publish
categories:
- network
- sysadm
tags:
- bind
- dns
- named
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---

![DNS Server](/assets/dns-server.png)

## Introduction

DNS(Domain Name System) is a basic facility in the Internet as well as some intranets.

This article will show you how to setup and configure the BIND DNS Server. The environment used is Red Hat Enterprise Linux 7. So this article also applies to Fedora and CentOS, meantime the procedure would be look alike on other releases.

<!--more-->

## Install

To begin, we need the BIND and BIND Utilities packages are installed on the system.

```shell
yum install bind bind-utils
```

## Configure

### generate `rndc.key`

```shell
rndc-config -a
chown named:named /etc/rndc.key
```

The `chown(1)` is necessary, otherwise the operation will fail with a message like this:

```shell
/etc/named.conf:10: open: /etc/rndc.key:
Apr 21 01:41:28 rhel.vmg named[21793]: loading configuration: permission denied
```

### Edit configuration file `/etc/named.conf`

After edit, use `named-checkconf` to verify syntax

### Generate zone file

please make sure the ownership of the zone file is right, otherwise the server would fail when startup.

```shell
one 249.168.192.in-addr.arpa/IN: loading from master file named.vmg failed: perm
one 249.168.192.in-addr.arpa/IN: not loaded due to errors.
one vmg/IN: loading from master file named.vmg failed: permission denied
one vmg/IN: not loaded due to errors.
```

### Use `named-checkzone` to validate zone file(s)

```shell
[root@dns will]# named-checkzone -dD vmg.com /var/named/named.vmg
loading "vmg.com" from "/var/named/named.vmg" class "IN"
zone vmg.com/IN: loaded serial 0
dumping "vmg.com"
vmg.com.				      86400 IN SOA	dns.vmg.com. root.vmg.com. 0 86400 3600 604800 10800
vmg.com.				      86400 IN NS	dns.vmg.com.
174.vmg.com.				      86400 IN PTR	dns.vmg.com.
174.vmg.com.				      86400 IN PTR	vmg.com.
195.vmg.com.				      86400 IN PTR	suse.vmg.com.
vmg.com.vmg.com.			      86400 IN A	192.168.249.174
dns.vmg.com.				      86400 IN A	192.168.249.174
suse.vmg.com.				      86400 IN A	192.168.249.195
www.vmg.com.				      86400 IN CNAME	suse.vmg.com.
OK
```

An alternative way of generating zone file is using `named-compilezone`.

```shell
[root@dns will]# named-compilezone -o - vmg.com /var/named/named.vmg
zone vmg.com/IN: loaded serial 0
vmg.com.				      86400 IN SOA	dns.vmg.com. root.vmg.com. 0 86400 3600 604800 10800
vmg.com.				      86400 IN NS	dns.vmg.com.
174.vmg.com.				      86400 IN PTR	dns.vmg.com.
174.vmg.com.				      86400 IN PTR	vmg.com.
195.vmg.com.				      86400 IN PTR	suse.vmg.com.
vmg.com.vmg.com.			      86400 IN A	192.168.249.174
dns.vmg.com.				      86400 IN A	192.168.249.174
suse.vmg.com.				      86400 IN A	192.168.249.195
www.vmg.com.				      86400 IN CNAME	suse.vmg.com.
OK
```

## Name server admin

`rndc` is the name server control utility come along with bind name server. It sends commands through TCP to the server to acheive admin tasks.

### Check Status

{% highlight bash %}
[root@rhel will]# rndc status
version: 9.9.4-RedHat-9.9.4-29.el7_2.3
CPUs found: 1
worker threads: 1
UDP listeners per interface: 1
number of zones: 103
debug level: 0
xfers running: 0
xfers deferred: 0
soa queries in progress: 0
query logging is OFF
recursive clients: 0/0/1000
tcp clients: 0/100
server is up and running
{% endhighlight %}
