---
layout: post
title: NTP Server (Network Time Protocol)
date: 2016-04-21 14:09:02.000000000 +08:00
type: post
published: true
status: publish
categories:
- Linux
- network
- RHEL
- Server
tags:
- RHCE
- RHCSA
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---
<h2>Install packages</h2>
<p><code>yum -y install ntp</code></p>
<h2>pool.ntp.org</h2>
<p>choose ntp server and add them to configure file</p>
<pre>server 0.rhel.pool.ntp.org iburst
server 1.rhel.pool.ntp.org iburst
server 2.rhel.pool.ntp.org iburst
server 3.rhel.pool.ntp.org iburst</pre>

<!--more-->

<h2>setup client range</h2>
<pre>restrict 192.168.249.0 mask 255.255.255.0 nomodify notrap</pre>
<h2>Log</h2>
<pre>logfile /var/log/ntp.log</pre>
<h2>Firewall</h2>
<pre># firewall-cmd --add-service=ntp --permanent
# firewall-cmd --reload</pre>
<h2>service management</h2>
<pre># systemctl start ntpd
# systemctl enable ntpd
# systemctl status ntpd</pre>
<h2>Verify</h2>
<pre>ntpq -p</pre>
