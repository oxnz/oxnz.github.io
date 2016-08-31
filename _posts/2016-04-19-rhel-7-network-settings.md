---
layout: post
title: Network Settings
date: 2016-04-19 09:31:32.000000000 +08:00
type: post
published: true
status: publish
categories:
- sysadm
tags:
- nmcli
- rhel
---

## Introduction

A basic understanding of networking is important for system admin. Not only is it essential for getting your services online and running smoothly, it also give you the insight to diagnose problems.

This article will privides an overview of the common network related operations.
## Network Connection

<!--more-->

### New connection

{% highlight bash %}
nmcli connection add type ethernet ifname eno0 con-name wired
{% endhighlight %}

### Assign static ip addresses

{% highlight bash %}
nmcli connection modify wired ipv4.method static ipv4.address 192.168.249.174/24
{% endhighlight %}

### Bring it up/down

**up**

{% highlight bash %}
[will@rhel ~]$ sudo nmcli connection up ethernet-eno0
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/9)
{% endhighlight %}

**down**

{% highlight bash %}
[will@rhel ~]$ sudo nmcli connection down ethernet-eno0
Connection 'ethernet-eno0' successfully deactivated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/7)
{% endhighlight %}

### View connections

{% highlight bash %}
nmcli connection show
{% endhighlight %}

sample output:

{% highlight bash %}
[will@rhel ~]$ nmcli connection show
NAME UUID TYPE DEVICE
ethernet-eno0 5e9bb5b5-6be7-4de4-8fb2-7a221f07a0ac 802-3-ethernet eno0
{% endhighlight %}

### Rename a connection

{% highlight bash %}
nmcli connection modify wired connection.id ethernet-eno0
{% endhighlight %}

## Consistent network device name

>
A rule in `/usr/lib/udev/rules.d/60-net.rules` instructs the udev helper utility, `/lib/udev/rename_device`, to look into all `/etc/sysconfig/network-scripts/ifcfg-suffix` files. If it finds an ifcfg file with a `HWADDR` entry matching the MAC address of an interface it renames the interface to the name given in the ifcfg file by the `DEVICE` directive.

{% highlight bash %}
nmcli connection modify ethernet-eno0 802-3-ethernet.mac-address 00:0c:29:73:d9:04
{% endhighlight %}

this will write HWADDR to ifcfg-suffix file, verify it

{% highlight bash %}
[will@rhel ~]$ grep HWADDR /etc/sysconfig/network-scripts/ifcfg-*
/etc/sysconfig/network-scripts/ifcfg-ethernet-eno0:HWADDR=00:0C:29:73:D9:04
{% endhighlight %}

## Hostname

### Show hostname

{% highlight bash %}
[will@rhel ~]$ nmcli general hostname
localhost.localdomain
{% endhighlight %}

### Modify hostname

{% highlight bash %}
nmcli general hostname rhel.vmg
{% endhighlight %}

### Verify hostname

{% highlight bash %}
[will@rhel ~]$ cat /etc/hostname
rhel.vmg
{% endhighlight %}
