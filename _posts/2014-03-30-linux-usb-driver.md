---
layout: post
title: Linux USB 驱动
date: 2014-03-30 01:31:32.000000000 +08:00
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

记得大一的时候试着为自己的双飞燕鼠标写驱动来着，结果写了一半，最后发现只实现了指针上下移动，左右移动有问题，然后就没下文了，这次想起来，已经过去了两年了，期间也陆续写过一些简单的内核模块的代码，现在突然旧鼠标坏了，就想着再试一次，顺便也练练手。

## References

* http://www.ibm.com/developerworks/cn/linux/l-usb/index2.html
* http://www.cnblogs.com/hoys/archive/2011/04/01/2002406.html
* http://blog.sina.com.cn/s/blog_53689eaf01011f7u.html
* http://www.cnblogs.com/image-eye/archive/2011/08/24/2152580.html
