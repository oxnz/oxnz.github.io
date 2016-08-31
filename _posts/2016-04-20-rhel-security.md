---
layout: post
title: Securing SSH Server
date: 2016-04-20 03:29:11.000000000 +08:00
type: post
published: true
status: publish
categories:
- sysadm
tags:
- ssh
---

![Securing SSH](/assets/securing-ssh.png)

## Introduction

SSH(Secure Shell) provides a secure way of logging into a remote server. On many relases, the ssh service is ready to use without configuration. But it use a general settings for most circumstances.

This article introduces some useful tips to securing a ssh service against attacks.

<!--more-->

## Setup Openssh Server

0. Update Server Configuration(`/etc/ssh/sshd_config`)

   ```conf
   # Disable protocol 1
   Protocol 2
   # Disable password auth
   PasswordAuthentication no
   # Use a non-standard port
   Port 2345
   ```

0. Setup firewall

   ```shell
   $ firewall-cmd --add-port 2345/tcp
   $ firewall-cmd --add-port 2345/tcp --permanent
   ```

0. Setup Selinux label

   ```shell
   $ semanage port -a -t ssh_port_t -p tcp 2345
   ```

## Setup Client

{% highlight shell %}
# Client ~/.ssh/config
Host myserver
HostName 72.232.194.162
        User bob
        Port 2345
{% endhighlight %}

## References

[https://wiki.centos.org/HowTos/Network/SecuringSSH](https://wiki.centos.org/HowTos/Network/SecuringSSH)
