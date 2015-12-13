---
layout: post
title: shell 重定向
date: 2012-12-04 16:48:05.000000000 +08:00
type: post
published: true
status: publish
categories:
- shell
- dev
tags:
- bash
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---

### Introduction

使用一个例子简要介绍了 shell 编程中得输入输出重定向问题。

<!--more-->

## Basics

`0`
: `stdin` 标准输入

`1`
: `stdout` 标准输出

`2`
: `stderr` 错误输出

## Input Redirection

### Syntax

```shell
# read from file
cmd < file
# read from single line here-doc
cmd <<< here-doc
# read from multi line here-doc
cmd << EOF
content
EOF
```

## Output Redirection

### Syntax

```shell
cmd > /dev/null 2>&1
```

#### Explain

符号 `>` 等价于 `1>` (系统默认为1,省略了); 所以 `> /dev/null` 等同于 `1> /dev/null`

`/dev/null` 代表空设备文件

`&` 可以理解为是"等同于"的意思，`2>&1`，即表示2的输出重定向等同于1

因此，`> /dev/null 2>&1 也可以写成 `1 > /dev/null 2>&1`

`1 > /dev/null`：首先表示标准输出重定向到空设备文件，也就是不输出任何信息到终端，说白了就是不显示任何信息。

`2>&1`：接着，将标准错误输出重定向到标准输出，因为之前标准输出已经重定向到了空设备文件，所以标准错误输出也重定向到空设备文件。
