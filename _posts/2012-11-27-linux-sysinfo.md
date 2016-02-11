---
layout: post
title: 收集Linux系统信息
date: 2012-11-27 23:32:38.000000000 +08:00
type: post
published: true
status: publish
categories:
- sysadm
- Linux
tags:
- dmesg
- lsblk
- lscpu
- lshw
- lspci
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---
<h2 id="abs">摘要</h2>
<p>早些时候在 stackoverflow 上看到有人问有关系统驱动问题，而驱动是和硬件分不开的，所以回答问题的人很热心的反反复复问了好多有关具体的硬件信息，到最后却发现是软件问题。由此可见，系统的问题往往涉及很多方面，而提问的时候最好能附上自己的系统信息，这样懂的人很容易就可以帮你找到问题所在，下面简单介绍几种信息的收集方法。</p>
<ol>
<li><a href="#abs">摘要</a></li>
<li><a href="#lshw">硬件信息</a>
<ol>
<li><a href="#pci">PCI 信息</a></li>
<li><a href="#usb">USB信息</a></li>
<li><a href="#blk">块设备信息</a></li>
<li><a href="#cpu">CPU信息</a></li>
</ol>
</li>
<li><a href="#soft">软件信息</a>
<ol>
<li><a href="#env">环境信息</a></li>
<li><a href="#log">系统日志</a></li>
<li><a href="#initf">initramfs信息</a></li>
<li><a href="#mod">模块信息</a></li>
</ol>
</li>
</ol>

<!--more-->

<h2 id="lshw">硬件信息</h2>
<p>硬件信息可以使用lshw来收集</p>
<p><code>sudo lshw &gt; info.hw.txt</code></p>
<p>下列的命令更精确的显示了某个方面硬件的信息</p>
<h3 id="pci">PCI信息</h3>
<p>PCI和PCI Express，是计算机常使用的一种高速总线。操作系统中的PCI/PCI-E设备驱动以及操作系统内核，都需要访问PCI及PCI-E配置空间。PCI/PCI-E设备的正常运行，离不开PCI/PCI-E配置空间。 通过读写PCI/PCI-E配置空间，可以更改设备运行参数，优化设备运行。本文介绍用户空间可以读取、修改、扫描PCI/PCIE设备的用户命令及使用。</p>
<p>在Linux内核中，为PCI和PCI-E只适用了一种总线PCI（内核提供的总线系统），故访问PCI-E配置空间，也包括了PCI设备配置空间。</p>
<p>读取PCI-E设备配置空间的命令是<code>lspci</code>。</p>
<p>常用参数：</p>
<p>-v 显示设备的详细信息。<br />
-vv 显示设备更详细的信息。<br />
-vvv 显示设备所有可解析的信息。<br />
-x 以16进制显示配置空间的前64字节，或者CardBus桥的前128字节。<br />
-xxx 以16进制显示整个PCI配置空间（256字节）。<br />
-xxxx 以16进制显示整个PCI-E配置空间（4096字节）。<br />
-nn 使用数字显示PCI制造商和设备号<br />
-s [[[[]:]]:][][.[]]：</p>
<p><code>lspci &gt; info.pci.txt</code></p>
<h3 id="usb">USB信息</h3>
<p><code>lsusb &gt; info.usb.txt</code></p>
<p>我机器上的输出如下:</p>
<pre>Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub&lt;br &gt;
Bus 002 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
...
Bus 006 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 007 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 001 Device 002: ID 174f:5a31 Syntek Sonix USB 2.0 Camera
Bus 004 Device 002: ID 09da:8090 A4 Tech Co., Ltd X-718BK Oscar Optical Gaming Mouse
Bus 006 Device 002: ID 0b05:1712 ASUSTek Computer, Inc. BT-183 Bluetooth 2.0+EDR adapter
Bus 006 Device 003: ID 08ff:1600 AuthenTec, Inc. AES1600
...</pre>
<ul>
<li>Bus后的数字范围从001到007表示总共有7个usb主控制器，也可以通过<code>lspci | grep USB</code>查看</li>
<li>Device 表示系统给USB设备分配的设备号，例如我的系统上的奥斯卡游戏鼠标的设备号位002</li>
<li>ID表示USB设备的ID，这个ID由芯片制造商设置，可以唯一表示该设备,例如我的系统上的摄像头的ID位174f:5a31</li>
</ul>
<h3 id="blk">块设备信息</h3>
<p>块设备是指读写数据以整块的方式进行的设备，常见的就是磁盘了</p>
<p><code>lsblk &gt; info.blk.txt</code></p>
<p>我的系统输出如下:</p>
<pre>NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda 8:0 0 232.9G 0 disk
├─sda6 8:6 0 5.7G 0 part /
├─sda7 8:7 0 17.9G 0 part /home
├─sda13 8:13 0 1.9G 0 part
└─sda14 8:14 0 20.2G 0 part
sr0 11:0 1 1024M 0 rom
mmcblk0 179:0 0 1.9G 0 disk</pre>
<h3 id="cpu">CPU信息</h3>
<p><code>lscpu &gt; info.cpu.txt</code> 我的机器的cpu信息如下:</p>
<pre>Architecture: i686
CPU op-mode(s): 32-bit, 64-bit
Byte Order: Little Endian
CPU(s): 2
On-line CPU(s) list: 0,1
Thread(s) per core: 1
Core(s) per socket: 2
Socket(s): 1
Vendor ID: GenuineIntel
CPU family: 6
Model: 15
Stepping: 13
CPU MHz: 1000.000
BogoMIPS: 3990.77
L1d cache: 32K
L1i cache: 32K
L2 cache: 2048K
</pre>
<h2 id="uname">系统总览信息</h2>
<p>一般用<code>uname -a</code>就可以了</p>
<h2 id="env">环境信息</h2>
<p><code>env</code>可以显示所有的环境变量，也可以制定特定的环境变量，例如:<code>echo $PATH</code>即显示<code>PATH</code>变量</p>
<h2 id="log">系统日志</h2>
<p>系统日志一般使用<code>dmesg</code>查看</p>
<h3 id="mod">模块信息</h3>
<p>lsmod 用于显示Linux 内核中的模块信息</p>
<p><code>lsmod &gt; info.mod.txt</code></p>
<p>我的12.04输出如下:</p>
<pre>Module Size Used by
nls_iso8859_1 12617 0
nls_cp437 12751 0
vfat 17308 0
fat 55605 1 vfat
rfcomm 38139 12
...
bnep 17830 2
vesafb 13516 1
cfg80211 178679 3 iwl3945,iwl_legacy,mac80211
crc_itu_t 12627 1 firewire_core
r8169 56321 0
</pre>
<h3 id="initrf">initramfs信息</h3>
<p>lsinitramfs用于列出initramfs image的内容,initramfs image 指的就是:</p>
<p><code>/boot/initrd.img-3.2.0-33-generic-pae</code></p>
<p><code>lsinitramfs /boot/initrd.img-3.2.0-33-generic-pae &gt; info.initramfs.txt</code></p>
<p>输出如下:</p>
<pre>/boot/initrd.img-3.2.0-33-generic-pae
.
bin
bin/dd
scripts/local-premount/fixrtc
scripts/init-top
lib/modules/3.2.0-33-generic-pae/kernel/fs/fscache
....
lib/modules/3.2.0-33-generic-pae/kernel/fs/fscache/fscache.ko
lib/modules/3.2.0-33-generic-pae/kernel/fs/nls
lib/modules/3.2.0-33-generic-pae/modules.alias
lib/modules/3.2.0-33-generic-pae/modules.order
</pre>
