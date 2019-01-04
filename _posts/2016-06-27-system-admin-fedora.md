---
title: System Administration - Fedora
---

![Fedora 24](/assets/fedora-24.jpg)

<!--more-->

## Table of Contents

* TOC
{:toc}

## Service Management

### Setup SSH Server

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

## Software Management

### yum

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

### yum proxy

/etc/yum.conf

在 yum 的配置中添加如下行:

```conf
Proxy=http://ip:port/
```

Proxy 代表 proxy 的 ip, port 代表代理监听的端口.
别忘了端口后的 `/`.

### history

```shell
yum history list all
for i in {2..19}; do
	yum history info "$i"
done > install.log
```

## Networking

### Static IP

#### Without NetworkManager

`/etc/sysconfig/network-scripts/ifcfg-enp0s3`

```conf
HWADDR="00:11:22:33:44:55"
TYPE="Ethernet"
BOOTPROTO="static"
IPADDR=192.168.249.108
NETMASK=255.255.255.0
NM_CONTROLLED=no
DEFROUTE="yes"
PEERDNS="yes"
PEERROUTES="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_PEERDNS="yes"
IPV6_PEERROUTES="yes"
IPV6_FAILURE_FATAL="no"
NAME="enp0s3"
UUID="00000000-0000-0000-0000-000000000000"
ONBOOT="yes"
```

```shell
# reload network service
systemctl restart network.service
# verify addr
ip addr
```

#### Using Network Manager

`NM_CONTROLLED=yes`

Use `nmcli` to config and reload network service via systemd.

### Create Multiple IP Addresses to One Single Network Interface

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

## System Maintainance

### Gen Password

```shell
openssl rand -base64 14
```

### System Backup

```shell
sudo su
cd /
tar -cvpzf /media/sda7/backup.tgz \
        --exclude=/proc \
        --exclude=/lost+found \
        --exclude=/mnt \
        --exclude=/sys \
        --exclude=/media /
```

### Release Upgrade

```shell
dnf update --refresh
dnf install dnf-plugin-system-upgrade
dnf system-upgrade download --refresh --releasever=24
dnf system-upgrade reboot
```

## screen dump and view

```
# dump
xwd-display localhost:0 -root  > screen.xwd
# view
xwud -in screen.xwd
```

## systemd

* service.service
* socket.socket
* device.device
* mount.mount,
* automount.automount
* swap.swap
* target.target
* path.path
* timer.timer
* snapshot.snapshot
* slice.slice
* scope.scope

See `man systemd.unit` for more information.

使用 systemctl 控制单元时，通常需要使用单元文件的全名，包括扩展名（例如 sshd.service）。但是有些单元可以在systemctl中使用简写方式。

如果无扩展名，systemctl 默认把扩展名当作 .service。例如 netcfg 和 netcfg.service 是等价的。
挂载点会自动转化为相应的 .mount 单元。例如 /home 等价于 home.mount。
设备会自动转化为相应的 .device 单元，所以 /dev/sda2 等价于 dev-sda2.device。

所有可用的单元文件存放在 /usr/lib/systemd/system/ 和 /etc/systemd/system/ 目录（后者优先级更高）。

在 systemctl 参数中添加 `-H <user>@<host>` 可以实现对其他机器的远程控制。该过程使用 SSH 链接。

`systemctl` is equivalent to `systemctl list-units`

```shell
# list failed units
systemctl --failed
# list unit files
systemctl list-unit-files
# prevent a service from starting dynamically or even manually unless unmasked
systemctl mask foo
```

### Type

* Type=simple(default)

	systemd认为该服务将立即启动。服务进程不会fork。如果该服务要启动其他服务，不要使用此类型启动，除非该服务是socket激活型。

* Type=forking

	systemd认为当该服务进程fork，且父进程退出后服务启动成功。对于常规的守护进程（daemon），除非你确定此启动方式无法满足需求，使用此类型启动即可。使用此启动类型应同时指定 PIDFile=，以便systemd能够跟踪服务的主进程。

* Type=oneshot

	这一选项适用于只执行一项任务、随后立即退出的服务。可能需要同时设置 RemainAfterExit=yes 使得 systemd 在服务进程退出之后仍然认为服务处于激活状态。

* Type=notify

	与 Type=simple 相同，但约定服务会在就绪后向 systemd 发送一个信号。这一通知的实现由 libsystemd-daemon.so 提供。

* Type=dbus

	若以此方式启动，当指定的 BusName 出现在DBus系统总线上时，systemd认为服务就绪。

### Example

view configure file

```shell
$ systemctl cat sshd.service
[Unit]
Description=OpenSSH server daemon
Documentation=man:sshd(8) man:sshd_config(5)
After=network.target sshd-keygen.service
Wants=sshd-keygen.service

[Service]
EnvironmentFile=/etc/sysconfig/sshd
ExecStart=/usr/sbin/sshd -D $OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
Type=simple
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
```

### Reload

```shell
systemctl daemon-reload
systemctl restart <unitname>
systemctl restart NetworkManager
systemctl stop httpd.service
# reload configuration
systemctl reload httpd.service
systemctl try-restart httpd.service
# kill when stop not working
systemctl kill httpd.service
# show help manual in unit file
systemctl help <unit>
```

### Power Management

```shell
systemctl reboot
systemctl poweroff
systemctl suspend
systemctl hibernate
systemctl hybrid-sleep
```

### Target(Runlevel)

```shell
systemctl list-units --type=target
# telinit 5
systemctl isolate graphical.target
# modify default target
systemctl enable multi-user.target
```

### journalctl

```shell
# like tail -f
journalctl -f
# show specific program
journalctl /usr/lib/systemd/systemd
# show specific PID
journalctl _PID=1
# show specific unit
journalctl -u netcfg
```

for more information:

* `man journalctl`
* `man systemd.journal-fields`

#### Configure

`/etc/systemd/journald.conf`

```conf
SystemMaxUse=50M
```

### core dump

`/etc/sysctl.d/49-coredump.conf`

```conf
kernel.core_pattern = core
kernel.core_uses_pid = 0
```

to activate conf:

```shell
/usr/lib/systemd/systemd-sysctl
# may need unlimit too
ulimit -c unlimited
```

## References

* [DNF system upgrade](https://fedoraproject.org/wiki/DNF_system_upgrade)
* [fedora: Systemd](http://fedoraproject.org/wiki/Systemd)
* [Create Multiple IP Addresses to One Single Network Interface](http://www.tecmint.com/create-multiple-ip-addresses-to-one-single-network-interface/)
