---
title: System Administration - Fedora
---

## Table of Contents

* TOC
{:toc}

## Setup SSH Server

1. install openssh-server

   ```shell
   yum install openssh-server
   ```

2. verify if openssh-server is installed

   ```shell
   rpm -qa | grep openssh-server
   ```

3. modifying ssh configure files (optional)

   there are a lot of configure options in the configure file `/etc/ssh/ssh_config`, most of them are commented out

   ```conf
   #Port 22
   #Protocol 2,1    
   #PermitRootLogin yes
   ```

4. open the TCP port 22 if the firewall is active

   ```shell
   iptables -I INPUT -p tcp --dport 22 -j ACCEPT
   ```

5. auto start when booting

   ```shell
   sudo systemctl enable sshd.service
   ```

<!--more-->

## Release Upgrade

```shell
dnf update --refresh
dnf install dnf-plugin-system-upgrade
dnf system-upgrade download --refresh --releasever=24
dnf system-upgrade reboot
```

## yum

* 使用yum解决依赖关系来安装你硬盘上的rpm包 `yum localinstall 程序名称`
* 查找程序的信息 `yum info 程序名称`
* 启用源 `yum –enablerepo=repo_name`
* 禁用源 `yum –disablerepo=repo_name`
* 导入 fedora GPG 钥
fedora有两个名叫"fedora"和"updates"的基本源.为了使用他们并不获得未标记的软件包的误信息,你必需导入它们的GPG钥.输入:
`rpm –import /etc/pki/rpm-gpg/*`
* 现在我们就安装livna的源,一个提供了很多多媒体解码器和额外软件的第三方的源.

	在接下来的文章中,我会认为你已经安装好了livna的源.输入:

	rpm -hiv <a href="http://rpm.livna.org/livna-release-9.rpm%27">http://rpm.livna.org/livna-release-9.rpm</a>

	rpm –import <a href="http://rpm.livna.org/RPM-LIVNA-GPG-KEY%27">http://rpm.livna.org/RPM-LIVNA-GPG-KEY</a>

### 配置yum的代理

/etc/yum.conf

在 yum 的配置中添加如下行:

```conf
Proxy=http://ip:port/
```

Proxy 代表 proxy 的 ip, port 代表代理监听的端口.
别忘了端口后的 `/`.

## 单网卡绑定多 IP

1. 我们先打开网络接口的文件

   ```shell
   sudo gedit /etc/network/interfaces
   ```

2. 照上边 eth0 添加

   ```conf
   eth0:0
   auto eth0
   iface eth0 inet static
   name Ethernet Lan card
   address 192.168.1.1
   netmask 255.255.255.0
   network 192.168.1.0
   broadcast 192.168.1.255
   gateway 192.168.1.1
   auto eth0:0
   iface eth0:0 inet static
   name Ethernet
   address 192.168.1.2
   netmask 255.255.255.0
   network 192.168.1.0
   broadcast 192.168.1.255
   gateway 192.168.1.1
   ```

3. 重启服务

   ```shell
   sudo /etc/init.d/networking restart
   ```

4. 测试新的ip地址是否生效

   ```shell
   ping 192.168.0.1
   ping 192.168.0.2
   ```

## System Backup

```shell
sudo su
cd /
tar -cvpzf /media/sda7/backup.tgz --exclude=/proc --exclude=/lost+found --exclude=/mnt --exclude=/sys --exclude=/media /
```

## screen dump and view

```
# dump
xwd-display localhost:0 -root  > screen.xwd
# view
xwud -in screen.xwd
```

## References

* [DNF system upgrade](https://fedoraproject.org/wiki/DNF_system_upgrade)
