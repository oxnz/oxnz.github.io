---
layout: post
title: DNS Server
date: 2016-04-20 17:49:10.000000000 +08:00
type: post
published: true
status: publish
categories:
- Linux
- network
- RHEL
- Secure
- Server
tags:
- bind
- dns
- named
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
<p>1. install package<br />
<code>yum install bind bind-utils</code><br />
2. generate rndc.key</p>
<pre>rndc-config -a
chown named:named /etc/rndc.key</pre>
<p>the `chown(1)` is necessary, otherwise will fail with message like this:</p>
<pre>/etc/named.conf:10: open: /etc/rndc.key: 
Apr 21 01:41:28 rhel.vmg named[21793]: loading configuration: permission denied</pre>

<!--more-->

<p>3. edit configuration file <code>/etc/named.conf</code><br />
after edit, use <code>named-checkconf</code> to verify syntax<br />
4. generate zone file<br />
after zone file edited, ownership need transfer, otherwise would fail</p>
<pre>one 249.168.192.in-addr.arpa/IN: loading from master file named.vmg failed: perm
one 249.168.192.in-addr.arpa/IN: not loaded due to errors.
one vmg/IN: loading from master file named.vmg failed: permission denied
one vmg/IN: not loaded due to errors.</pre>
<p>use named-checkzone to validate zone file</p>
<pre>[root@dns will]# named-checkzone -dD vmg.com /var/named/named.vmg 
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
</pre>
<p>an alternate way to generate zone file is to use <code>named-compilezone</code></p>
<pre>[root@dns will]# named-compilezone -o - vmg.com /var/named/named.vmg 
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
</pre>
<p>5. <code>rndc</code></p>
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
