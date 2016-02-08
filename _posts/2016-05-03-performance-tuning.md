---
layout: post
title: Performance Tuning
date: 2016-05-03 06:23:10.000000000 +08:00
type: post
published: true
status: publish
categories:
- Linux
- RHEL
- Server
- UNIX
tags:
- prlimit
- sysctl
- ulimit
meta:
  _edit_last: '1'
  _wp_old_slug: system-tweak
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---

## Abstract

After the system is up and running, maybe there's something need to tweak according workload

You could use `sysctl -w key=value` or write to the proc fs, after that, validate the system behaves as you expected, if yes, then you may write the configuration to `/etc/sysctl.conf`

<!--more-->

<h2>kernel</h2>
<h2>network</h2>
<pre># Default Socket Receive Buffer
net.core.rmem_default = 31457280

# Maximum Socket Receive Buffer
net.core.rmem_max = 12582912

# Default Socket Send Buffer
net.core.wmem_default = 31457280

# Maximum Socket Send Buffer
net.core.wmem_max = 12582912

# Increase number of incoming connections
net.core.somaxconn = 4096

# Increase number of incoming connections backlog
net.core.netdev_max_backlog = 65536

# Increase the maximum amount of option memory buffers
net.core.optmem_max = 25165824

# Increase the maximum total buffer-space allocatable
# This is measured in units of pages (4096 bytes)
net.ipv4.tcp_mem = 65536 131072 262144
net.ipv4.udp_mem = 65536 131072 262144

# Increase the read-buffer space allocatable
net.ipv4.tcp_rmem = 8192 87380 16777216
net.ipv4.udp_rmem_min = 16384

# Increase the write-buffer-space allocatable
net.ipv4.tcp_wmem = 8192 65536 16777216
net.ipv4.udp_wmem_min = 16384

# Increase the tcp-time-wait buckets pool size to prevent simple DOS attacks
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1</pre>
<h3>Security</h3>
<pre># Number of times SYNACKs for passive TCP connection.
net.ipv4.tcp_synack_retries = 2

# RHEL 7 default: 32768	61000
net.ipv4.ip_local_port_range = 2000 65535

# Protect Against TCP Time-Wait
net.ipv4.tcp_rfc1337 = 1

# Decrease the time default value for tcp_fin_timeout connection
net.ipv4.tcp_fin_timeout = 15

# Decrease the time default value for connections to keep alive
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15</pre>
<h2>memory</h2>
<pre># Do less swapping
vm.swappiness = 10
vm.dirty_ratio = 60
vm.dirty_background_ratio = 2
</pre>
<h2>file system</h2>
<pre>fs.file-max = 2097152</pre>
<p>Above setting is specified for system-wide configuration. For user, there's a configure item in <code>/etc/security/limits.conf</code> named <code>nofile</code>, which means max number of open file descriptors.</p>
<p><code>prlimit</code> and <code>ulimit</code> can be used to inspect the limit:</p>
<pre>ulimit -&lt;H|S&gt;n</pre>
<p>or</p>
<pre>prlimit -n</pre>
<h2>Resource Limits</h2>
<p><b>ulimit</b> provides control over resources available to each user via a shell. You can type <code>ulimit -a</code> to get a list of all current settings. In parentheses you will see one or two items: the units in measurements (e.g. kbytes, blocks, seconds) as well as a letter option (e.g. -s, -t, -u). The letter option will let you view/edit one particular setting at a time.</p>
<pre>[root@dns will]# ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 7823
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 7823
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited</pre>
<ul>
<li><code>ulimit -S -a</code> view all soft limits</li>
<li><code>ulimit -H -a</code> view all hard limits</li>
<li><code>ulimit -S [option] [number]</code> set a specific soft limit for one variable<br />
e.g. ulimit -S -s 8192 set a new soft stacksize limit, “-s” is for stack</li>
<li><code>ulimit -H [option] [number]</code> set a specific hard limit for one variable<br />
e.g. ulimit -H -s 8192 set a new hardstacksize limit, “-s” is for stack</li>
<li><code>/etc/security/limits.conf</code> file where you can set soft and hard limits per user or for everyone<br />
e.g. Add in the following to <code>/etc/security/limits.conf</code> will set a soft stacksize of 8192 adn a hard stacksize of unlimited for username “toor”:</p>
<pre>toor soft stack 8192
toor hard stack unlimited</pre>
</li>
</ul>
<p><b>limit type</b></p>

>
**hard**
>
for enforcing hard resource limits. These limits are set by the superuser and enforced by the Kernel. The user cannot raise his requirement of system resources above such values.
>
**soft**
>
for enforcing soft resource limits. These limits are ones that the user can move up or down within the permitted range by any pre-existing hard limits. The values specified with this token can be thought of as default values, for normal system usage.
from `limits.conf(5)`

## SEE ALSO

* <code>getrlimit(2)</code>
* <code>setrlimit(2)</code>
