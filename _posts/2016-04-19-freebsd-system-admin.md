---
layout: post
title: FreeBSD System Admin
date: 2016-04-19 19:02:42.000000000 +08:00
type: post
published: true
status: publish
categories:
- Server
tags:
- bsd
- sysadm
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---
<p>Env</p>
<pre><code>root@:/home/will # uname -a</code>
FreeBSD  10.2-RELEASE FreeBSD 10.2-RELEASE #0 r286666: Wed Aug 12 19:31:38 UTC 2015     root@releng1.nyi.freebsd.org:/usr/obj/usr/src/sys/GENERIC  i386</pre>

<!--more-->
<h2>Install</h2>
<h2>System Config</h2>
<h3>Boot Loader</h3>
<p><code>/boot/loader.conf</code></p>
<pre>autoboot_delay="0"</pre>
<h3>Network</h3>
<p><code>/etc/rc.conf</code></p>
<pre>ifconfig_em0="inet 192.168.249.170 netmask 255.255.255.0"
defaultrouter="192.168.249.2"
hostname="freebsd.vmg"</pre>
<p><code>/etc/resolv.conf</code><br />
<code>server 192.168.249.2</code></p>
<h2>Services</h2>
<h3>ssh server</h3>
<p>1. server auto start<br />
<code>/etc/rc.conf</code><br />
<code>sshd_enable="YES"</code><br />
2. config file<br />
<code>/etc/ssh/sshd_config</code></p>
<pre>AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication no
AuthenticationMethods publickey
</pre>
<p>3. public key</p>
<pre>mkdir .ssh
vi .ssh/authorized_keys
chmod 0600 .ssh/authorized_keys
</pre>
<p>4. start/stop<br />
<code>service sshd start/stop/status</code></p>
<h3>NFS</h3>
<p>1. setup<br />
<code>/etc/rc.conf</code></p>
<pre>nfs_server_enable="YES"
nfsv4_server_enable="YES"
nfsuserd_enable="YES"</pre>
<p>2. share<br />
<code>/etc/exports</code><br />
V3:</p>
<pre>/var/nfs -ro</pre>
<p>V4:</p>
<pre>V4: /
/</pre>
<p>3. service start/stop<br />
there's a bug when restart, you need to reload <code>mountd</code> manually. otherwise the share won't be aviable<br />
<code>service nfsd start/stop/restart</code><br />
<code>/etc/rc.d/mountd reload</code><br />
4. inspect</p>
<pre>linux-qxrh:/home/will # showmount -e 192.168.249.170
Export list for 192.168.249.170:
/var/nfs (everyone)</pre>
<p>5. mount<br />
<b>Local</b><br />
<code>mount -t nfs localhost:/var/nfs /mnt</code><br />
<b>Remote</b><br />
<code>mount -t nfs -o nfsvers=3 192.168.249.170:/var/nfs /mnt</code></p>
