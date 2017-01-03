---
layout: post
title: /usr/bin/install
type: post
categories: []
tags: 'install'
---

## Introduction

install命令的作用是安装或升级软件或备份数据，它的使用权限是所有用户。

## Syntax

```shell
install [OPTION]... [-T] SOURCE DEST
install [OPTION]... SOURCE... DIRECTORY
install [OPTION]... -t DIRECTORY SOURCE...
install [OPTION]... -d DIRECTORY...
```

在前两种格式中，会将复制至或将多个文件复制至已存在的，同时设定

权限模式及所有者/所属组。在第三种格式中，会创建所有指定的目录及它们的主目录。长选项必须用的参数在使用短选项时也是必须的。

<!--more-->

## Options

* --backup[=CONTROL]: 为每个已存在的目的地文件进行备份。
* -b: 类似 －－backup，但不接受任何参数。
* -c: (此选项不作处理)。
* -d, --directory: 所有参数都作为目录处理，而且会创建指定目录的所有主目录。
* -D：创建前的所有主目录，然后将复制至 ；在第一种使用格式中有用。
* -g，--group=组: 自行设定所属组，而不是进程目前的所属组。
* -m，--mode=模式: 自行设定权限模式 (像chmod)，而不是rwxr－xr－x。
* -o，--owner=所有者: 自行设定所有者 (只适用于超级用户)。
* -p，--preserve－timestamps: 以文件的访问/修改时间作为相应的目的地文件的时间属性。
* -s，--strip: 用strip命令删除symbol table，只适用于第一及第二种使用格式。
* -S，--suffix=后缀: 自行指定备份文件的。
* -v，--verbose: 处理每个文件/目录时印出名称。
* --help: 显示此帮助信息并离开。
* --version: 显示版本信息并离开。

## Examples

```shell
# 创建目录/root同时设定权限等
install -dv -m 0750 /root
install -dv -m 1777 /tmp /var/tmp
```
