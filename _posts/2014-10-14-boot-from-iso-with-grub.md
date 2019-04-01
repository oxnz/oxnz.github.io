---
layout: post
title: Grub 引导 ISO
type: post
categories: [sysadm]
tags: [grub]
---

GRUB
: GRand Unified Boot loader

因为光盘安装和U盘安装都比较慢，所以最快还是从硬盘上的ISO文件引导开始安装，前提是有个现有的GRUB，可以在 `/etc/grub.d/40_custom` 文件中加入如下代码来生成启动项

<!--more-->

## Table of Contents

* TOC
{:toc}

## Windows 10

grub2

```
search --no-floppy --fs-uuid --set=root XXXX-AAAA
ntldr /bootmgr
boot
```

## CentOS 7

EasyBCD

```
root (hd0,4)
kernel (hd0,4)/isolinux/vmlinuz linux repo=hd:/dev/sda5:/
initrd (hd0,4)/isolinux/initrd.img
boot
```

## Ubuntu 12.10

```grub
menuentry "Ubuntn 12.10 LiveCD" {
set root=(hd0, gpt4)
loopback loop /.../ubuntu-12.10-desktop-i386.iso
linux (loop)/casper/vmlinuz boot=casper iso-scan/filename=/.../ubuntu-12.10-desktop-i386.iso noprompt noeject
initrd (loop)/casper/initrd.lz
}
```

## 用grub2引导ISO硬盘安装ubuntu方法两则

之前一直是用光碟刻录再安装的，这次看到ubuntu11.10正式版还要到13号才出，忍不往先安装个beta版，为了不浪费光碟学起了硬盘安装。

之前找了很多教程都是安装grub引导iso安装的，这次我不用grub安装，选用grub2引导安装。。为什么不用grub安装呢，原因是从ubuntu9.10开始就使用了grub2了，

而我的硬盘上有windows7和ubuntu11.04，使用的是grub2引导。

### 操作步骤

1. 步骤一,要有 gurb2 的命令行环境,如果以前安装了 ubutnu9.10 以上的版本，则开机就是 gurb2 (注: burg 也是 gurb2，一样的操作),在选择菜单按 <kbd>c</kbd> 键自动进入命令行模式(按 <kbd>ESC</kbd> 退出命令行模式)
2. 步骤二,下载 ubuntu的iso镜像,放在硬盘分区的根目录下,建议放在根目录下,这样在命令行下好找,不容易出问题,比如我的放在了 c 盘。
3. 步骤三,重启电脑,进入 grub2 的命令行模式,一步一步输入以下命令代码:

   ```
   1.grub> loopback loop (hd0,1)/ubuntu.iso
   2.grub> set root=(loop)
   3.grub> linux /casper/vmlinuz boot=casper iso-scan/filename=/ubuntu.iso
   4.grub> initrd /casper/initrd.lz
   5.grub> boot
   ```

4. 步骤四,上一步的 boot 命令执行后计算机开始命令行的滚屏,最后如果成功,会提示很多选项 ok ,然后 ubuntu 的 iso 镜像顺利引导,进入 ubuntu 的 live cd 桌面,桌面上有 install ubuntu 的字样,和光盘启动时的样子一模一样，不过与光盘安装有一点不同，也很重要，就是之前我们挂载了 iso 设备，现在要卸载它，不然会出现分区表问题。
在终端里输入:

   ```shell
   sudo umount -l /isodevice
   ```

5. 步骤五,双击 install ubuntu 图标安装。

### 命令解释

1. grub> loopback loop (hd0,1)/ubuntu.iso

	利用grub2的回放设备，挂iso,这样可以使你不用把casper文件夹提取出来，就能从iso中启动。

2. grub> set root=(loop)

	这是设置grub的根目录。

3. grub> linux /casper/vmlinuz boot=casper iso-scan/filename=/ubuntu.iso

	这是让grub挂内核。并传递参数boot=casper 给initramfs<br />

4. grub> initrd /casper/initrd.lz

设置系统引导

5. grub> boot

	开始启动引导

	再解释一下硬盘分区，硬盘是从0开始计数的，而分区是从1开始计数的，扩展分区是从5开始计数的。

## grub.cfg引导iso安装ubuntu: (已测试)

打开grub.cfg

```
sudo gedit /boot/grub/grub.cfg
```

在文件最后添加:

```
menuentry "ubuntu iso install" {
  loopback loop (hd0,1)/ubuntu.iso
  set root=(loop)
  linux /casper/vmlinuz boot=casper iso-scan/filename=/ubuntu.iso
  initrd /casper/initrd.lz
}
```

重启，选择ubuntu iso install进入ubuntu的live cd桌面。再进行上面步骤四，就可以安装系统了。

## chainloader

### Boot

```
chainloader (hd0,1)+1
boot
```

### Menu

```
menuentry "Windows" {
    chainloader (hd0,1)+1
}
```

```
grub2-mkconfig --output=/boot/grub2/grub.cfg
```

## grub rescue

```
ls
set root=hd0,1
set prefix=(hd0,1)/boot/grub
insmod normal
normal
```

## References

* [https://www.gnu.org/software/grub/manual](https://www.gnu.org/software/grub/manual)
* [https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Installation_Guide/](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Installation_Guide/)
* [https://wiki.gentoo.org/wiki/GRUB2/Chainloading](https://wiki.gentoo.org/wiki/GRUB2/Chainloading)
