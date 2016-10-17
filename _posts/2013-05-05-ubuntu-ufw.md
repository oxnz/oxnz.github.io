---
layout: post
title: UFW - Ubuntu FireWall
type: post
categories:
- sysadm
tags: [ufw]
---

安装

```
sudo apt-get install ufw
```

配置

```shell
sudo ufw enable
sudo ufw default deny
```

上边的配置已经可以了，对一般用户而言 :)

高级配置

3.开启/禁用

* sudo ufw allow\|deny [service]
* 打开或关闭某个端口，例如：
* sudo ufw allow smtp　允许所有的外部IP访问本机的25/tcp (smtp)端口
* sudo ufw allow 22/tcp 允许所有的外部IP访问本机的22/tcp (ssh)端口
* sudo ufw allow 53 允许外部访问53端口(tcp/udp)
* sudo ufw allow from 192.168.1.100 允许此IP访问所有的本机端口
* sudo ufw allow proto udp 192.168.0.1 port 53 to 192.168.0.2 port 53
* sudo ufw deny smtp 禁止外部访问smtp服务
* sudo ufw delete allow smtp 删除上面建立的某条规则

4.查看防火墙状态

```
sudo ufw status
```
