---
layout: post
title: Openconnect Used as an Alternative for Cisco Anyconnect
categories: [sysadm, network]
tags: [openconnect,vpn,anyconnect]
---

## Introduction

Open client for Cisco AnyConnect VPN
: OpenConnect is a client for Cisco's AnyConnect SSL VPN, which is supported by
the ASA5500 Series, by IOS 12.4(9)T or later on Cisco SR500, 870, 880, 1800,
2800, 3800, 7200 Series and Cisco 7301 Routers, and probably others.

**Homepage** [http://www.infradead.org/openconnect/](http://www.infradead.org/openconnect/)

## Install

### Ubuntu

{% highlight shell %}
[will@ubuntu.vmg ~]$ sudo apt-get install network-manager-openconnect-gnome
{% endhighlight %}

### OS X

[homebrew openconnect.rb](https://github.com/Homebrew/homebrew-core/blob/master/Formula/openconnect.rb)
## Configure

Gateway: server address
