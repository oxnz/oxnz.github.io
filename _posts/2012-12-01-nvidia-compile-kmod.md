---
layout: post
title: NVIDIA 驱动安装指南
date: 2012-12-01 12:08:21.000000000 +08:00
type: post
published: true
status: publish
categories:
- sysadm
- driver
tags:
- nvidia
---

## 自动化 NVIDIA 驱动模块编译

如果你使用的是在NVIDIA的官方网站下载的驱动，每当内核升级后，你必须重新手动安装nv驱动。本指南目标是当内核升级后自动进行安装驱动的过程，而不需要手工干预。

本文假定你已经正确的安装了nvidia官方驱动，并在安装后已经重启了至少一次（这非常重要，因为如果你没有正确安装并重启，下述将不能正常工作）。使用非官方驱动的请跳过。

<!--more-->

第一步，把你使用的驱动放到/usr/src下，并生成链接。例如：

```shell
sudo mv NVIDIA-Linux-x86-190.42-pkg0.run /usr/src
sudo ln -s /usr/src/NVIDIA-Linux-x86-190.42-pkg0.run /usr/src/nvidia-driver
```

这样做的目的是当你更换所用的驱动时，只需要删除原来的链接后再指定新的链接即可，不需要改变我们将使用的脚本。

自动安装NVIDIA驱动的脚本如下：

```shell
#!/bin/bash
#
# Set this to the exact path of the nvidia driver you plan to use
# It is recommended to use a symlink here so that this script doesn't
# have to be modified when you change driver versions.
DRIVER=/usr/src/nvidia-driver
# recompile if nvidia.ko not exists
if [ -e /lib/modules/$1/kernel/drivers/video/nvidia.ko ] ; then
    echo "NVIDIA driver already exists for this kernel." >&2
else
    echo "Building NVIDIA driver for kernel $1" >&2
    sh $DRIVER -K -k $1 -s -n 2 >1 > /dev/null
    if [ -e /lib/modules/$1/kernel/drivers/video/nvidia.ko ] ; then
        echo "NVAUTO: SUCCESS: Driver installed for kernel $1" >&2
    else
        echo "NVAUTO: FAILURE: See /var/log/nvidia-installer.log" >&2
    fi
fi
exit 0
```

基本上，原理是检查新安装的内核是否安装了正确的nv驱动，如果没有，脚本将自动为新内核安装驱动模块。

把上面的脚本命名为update-nvidia，并通过如下命令安装：

```shell
sudo mkdir -p /etc/kernel/postinst.d
sudo install update-nvidia /etc/kernel/postinst.d
```

## NVIDIA驱动安装指南

<p>Ubuntu默认有个jockey-gtk的程序，可以自动搜索ubuntu源里的显卡驱动，但是其提供的显卡驱动往往比较旧，而且没有opengl模块，所以最好还是自己手动编译安装，这样才可以物尽其用，下面就说说如何安装显卡官方释放的驱动程序</p>

1. 首先需要去NVIDIA的官网去下载驱动，下载回来是一个.run后缀的文件，保存在英文路径，最简单就是保存在自己的家里(～),因为安装的时候要命令行输入驱动文件路径

	我的机器是32位的，所以下载的文件名为:NVIDIA-Linux-x86-310.19.run
2. 然后需要安装驱动所依赖的包，对于ubuntu来说是linux-headers,安装命令如下:</h2>

   ```
   sudo apt-get install linux-headers-`(uname -r)` -y
   ```

3. 第三步我们需要清除旧的驱动和系统自己带的驱动

	命令如下:

   ```
   sudo apt-get --purge remove nvidia* -y
   sudo apt-get --purge remove xserver-xorg-video-noveau -y
   ```

4. 第四步需要重启

	否则刚才虽然卸载了原有的驱动，但是他们在内存之中还是存在的，重启之后就没有了，此时可以看到分辨率已经明显降低了，我的机器上变成了800x600的分辨率，不过不要紧，我们马上就要安装新的驱动了

	Ctrl + Alt + F1 # 同时按这三个建切换到第一个tty,然后输入用户名和密码进行登录

   ```
   cd # 假设保存驱动在自己家里
   sudo stop service lightdm # 停止图形界面的活动
   sudo sh NVIDIA-Linux-x86-310.19.run
   ```

	接下来回显示对话框询问，接受协议，然后我的机器上好像还有个什么pre-script执行失败的对话框还是什么的，选择继续就OK,安装完成之后回提醒是否创建新的xorg.conf配置文件，选择是,到此，驱动安装完成

	此时，输入<code>sudo reboot </code>重启一下，然后就可以看到NVIDIA的logo了.
	如果不喜欢的话，可以在/usr/X11/xorg.conf文件中的section device里边加上
	<code>Option "NoLogo"</code>来禁止显示logo

