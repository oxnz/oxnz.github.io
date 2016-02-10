---
layout: post
title: NFS server
date: 2016-04-19 19:00:02.000000000 +08:00
type: post
published: true
status: publish
categories:
- Linux
- RHEL
- Server
tags:
- NFS
- share
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---
## Server setup (openSUSE)

{% highlight bash %}
zypper in nfs-kernel-server
{% endhighlight %}

## Make share

{% highlight bash %}
mkdir /var/nfs
echo 'hello' > /var/nfs/readme # create test file
echo '/var/nfs' >> /etc/exports
{% endhighlight %}

## Start service

{% highlight bash %}
systemctl start nfs-server.service
{% endhighlight %}

## Client setup (RHEL7)

{% highlight bash %}
yum install nfs-utils
{% endhighlight %}

## Mount

{% highlight bash %}
mount -t nfs 192.168.249.195:/var/nfs /mnt/
{% endhighlight %}

<!--more-->

## Verify

**local**

{% highlight bash %}
[will@rhel ~]# exportfs
/var/nfs
{% endhighlight %}

**remote**

{% highlight bash %}
[will@rhel ~]$ showmount -e 192.168.249.195
Export list for 192.168.249.195:
/var/nfs *
{% endhighlight %}

