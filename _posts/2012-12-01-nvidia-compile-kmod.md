---
layout: post
title: 自动化Nvidia驱动模块编译
date: 2012-12-01 12:08:21.000000000 +08:00
type: post
published: true
status: publish
categories:
- Linux
- Driver
tags:
- driver
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---
<p>在内核升级后自动安装NVIDIA驱动</p>
<p>如果你使用的是在NVIDIA的官方网站下载的驱动，每当内核升级后，你必须重新手动安装nv驱动。本指南目标是当内核升级后自动进行安装驱动的过程，而不需要手工干预。</p>
<p>本文假定你已经正确的安装了nvidia官方驱动，并在安装后已经重启了至少一次（这非常重要，因为如果你没有正确安装并重启，下述将不能正常工作）。使用非官方驱动的请跳过。<br />
<!--more--><br />
第一步，把你使用的驱动放到/usr/src下，并生成链接。例如：</p>
<pre>sudo mv NVIDIA-Linux-x86-190.42-pkg0.run /usr/src
sudo ln -s /usr/src/NVIDIA-Linux-x86-190.42-pkg0.run /usr/src/nvidia-driver
</pre>
<p>这样做的目的是当你更换所用的驱动时，只需要删除原来的链接后再指定新的链接即可，不需要改变我们将使用的脚本。</p>
<p>自动安装NVIDIA驱动的脚本如下：</p>
<pre class="lang:default decode:true crayon-selected">#!/bin/bash
#
# Set this to the exact path of the nvidia driver you plan to use
# It is recommended to use a symlink here so that this script doesn't
# have to be modified when you change driver versions.
DRIVER=/usr/src/nvidia-driver
# 如果nvidia.ko不存在就重新编译
if [ -e /lib/modules/$1/kernel/drivers/video/nvidia.ko ] ; then
    echo "NVIDIA driver already exists for this kernel." &gt;&amp;2
else
    echo "Building NVIDIA driver for kernel $1" &gt;&amp;2
    sh $DRIVER -K -k $1 -s -n 2 &gt;1 &gt; /dev/null
    if [ -e /lib/modules/$1/kernel/drivers/video/nvidia.ko ] ; then
        echo "NVAUTO: SUCCESS: Driver installed for kernel $1" &gt;&amp;2
    else
        echo "NVAUTO: FAILURE: See /var/log/nvidia-installer.log" &gt;&amp;2
    fi
fi
exit 0</pre>
<p>基本上，原理是检查新安装的内核是否安装了正确的nv驱动，如果没有，脚本将自动为新内核安装驱动模块。</p>
<p>把上面的脚本命名为update-nvidia，并通过如下命令安装：</p>
<pre>sudo mkdir -p /etc/kernel/postinst.d
sudo install update-nvidia /etc/kernel/postinst.d
</pre>
