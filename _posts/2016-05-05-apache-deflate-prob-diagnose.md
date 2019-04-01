---
layout: post
title: Apache deflate prob diagnose
date: 2016-05-05 03:40:13.000000000 +08:00
type: post
published: true
status: publish
categories:
- Linux
- Server
tags:
- apache
- deflate
- httpd
meta:
  _edit_last: '1'
author:
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---

## Configuration

Apache 启用压缩，配置文件里一般是:

{% highlight apache %}
AddOutputFilterByType DEFLATE application/javascript text/html text/javascript
{% endhighlight %}

## GZIP header format

	+---+---+---+---+---+---+---+---+---+---+
	|ID1|ID2|CM |FLG| MTIME |XFL|OS |(more-->)
	+---+---+---+---+---+---+---+---+---+---+

* D1 (IDentification 1)
* ID2 (IDentification 2)

这两个字节具有固定值 ID1 = 31 (0x1f, \037), ID2 = 139 (0x8b, \213), 标识文件为gzip压缩包.

* CM (Compression Method)

文件使用的压缩方法. CM = 8 denotes the "deflate" 压缩方法</p>

<!--more-->

* OS (Operating System)

标识压缩文件源自的文件系统类型

	0 - FAT filesystem (MS-DOS, OS/2, NT/Win32)
	1 - Amiga
	2 - VMS (or OpenVMS)
	3 - Unix
	4 - VM/CMS
	5 - Atari TOS
	6 - HPFS filesystem (OS/2, NT)
	7 - Macintosh
	8 - Z-System
	9 - CP/M
	10 - TOPS-20
	11 - NTFS filesystem (NT)
	12 - QDOS
	13 - Acorn RISCOS
	255 - unknown

详情见引用1.

## Diagnose

因为错误的启用压缩导致的结果一般而言是结果文件大小比预期文件大小小，具体小多少取决于压缩强度和文件类型。（wiki就是这种情况），可以通过文件头部检查是否包含GZIP头部标志，wiki的两个文件具有相同的gzip头部：`0x1f 0x8b 0x08 0x00 0x00 0x00 0x00 0x00 0x03`.

但是也可能比预期长，（icafe的情况），之所以出现这种情况是应为服务器返回的是二进制流，而接收方却绑定了一个UTF8解码器到流上，触发了unicode的replacement character，导致文件中的非UTF8编码内的被替换为 `0xEF,0xBF,0xBD`，显示为�（黑色菱形上边白色问号）。详情见引用2.

## References

* [GZIP file format specification](http://www.zlib.org/rfc-gzip.html)
* [Replacement character](https://en.wikipedia.org/wiki/Specials_(Unicode_block))
