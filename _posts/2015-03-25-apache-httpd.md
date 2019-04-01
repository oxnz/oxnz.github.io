---
layout: post
title: Apache httpd
type: post
categories:
- Linux
- ubuntu
tags:
- apache
- apache2
- httpd
---

## Table of Contents

* TOC
{:toc}

## Configuration

### 配置文件目录

```shell
[a2di@F8SG:~/Public]$ ls /etc/apache2/
apache2.conf  envvars     magic           mods-enabled  sites-available
conf.d        httpd.conf  mods-available  ports.conf    sites-enabled
```

### 缺省的主目录

/var/www/

<!--more-->

### Log 文件的位置

Apache有二个log文件

* 一个是所有登陆本apache服务器的记录，/var/log/httpd-access.log，文件记录了登陆的ip，时间，浏览器类型等；
* 另一个是联机错误记录文件， /var/log/httpd-error.log，这个文件对于调试apache参数是很有作用的。

两个文件都是文本文件，可以由 nano 等文本编辑器来浏览、编辑，记录文件的位置及文件名是由 httpd.conf 中的相应配置来改变。

### 启动、停止和重新启动httpd服务器的运行

apapche2ctl start(stop restart) 这个命令比较有用，尤其是在修改配置文件之后。

### 个人用户目录的问题

不同于 apache1，重要修改配置文件中的 UserDir，apache2 把个人用户作为一个模块，则需要先:

```shell
cd /etc/apache2/mods_enabled
ln -s /etc/apache2/mods_available/userdir.conf userdir.conf
ln -s /etc/apache2/mods_available/userdir.load userdir.load
apache2ctl restart
```

同时修改主配置文件，注释掉
`#UserDir public_html`
这句，再在用户test的主目录 /home/test 下面创建一个 index.html 文件，就可以浏览:

http://yourip/~test

### 自动支持中文的问题

网页的缺省字符集有参数 AddDefaultCharset ISO-8859-1 这时候在浏览器浏览中文网页的时候，会乱码，需要手动设置编码方式为 GBK 或 GB2312 才能显示中文去掉注释，修改为  `AddDefaultCharset GB2312` 就可以了。

### Apache 状态信息

在安装完 Apache 后，我们需要不断了解服务器的系统各方面的情况。Apache2 内建了server-status 及 server-info 二种查看服务器信息的方法。

* server-status 是指服务器状态信息，我们可以了解 Apache 目前运行的情形，包括占用的系统资源、目前联机数量等。
* server-info 主要是显示 Apache 的版本、加载的模块信息等。

为使用这两项功能，我们必须先修改 /etc/apache2/apache2.conf。
首先要自己手动添加一行 `ExtendedStatus On`，否则得到的信息会不够详细。

然后分别找到和这两段，把两段内前面的注释都去掉，并设置好访问权限。不重视安全的话，可以设置 `allow from all`

再:

```shell
cd /etc/apache2/mods_enabled
ln -s /etc/apache2/mods_available/info.load info.load
```

然后就可以在浏览器以 http://hostname/server-info 访问了。

### 其他配置参数

* ServerRoot: 指出服务器保存其配置、出错和日志文件等的根目录。
* Listen: 允许你绑定Apache服务到指定的IP地址和端口上，以取代默认值
* DocumentRoot: 你的文档的根目录。默认情况下，所有的请求从这个目录进行应答。
* HostnameLookups: 指定记录用户端的名字还是IP地址
