---
layout: post
title: MySQL Primer - Up and Running
date: 2014-09-23 15:22:18.000000000 +08:00
type: post
published: true
status: publish
categories:
- database
- MySQL
tags:
- MySQL
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---

## Introduction

This article described the installation and service control of MySQL.

<!--more-->

## Table Of Contents

* TOC
{:toc}

## Before Install

### Choose Operating System

* stable
* reliable
* easy to manage
* plenty of resources available online
* allow runing MySQL without too much hassle

Recommendations

* SUSE Linux Enterprise Server
	* Live Patching
* Red Hat Enterprise Linux

### Choose Package

**OS specific packages**

* packages have been rigorously tested with other componenets of the given OS

	Ubuntu has MySQL packaging team

* simplicity of maintenance
	* auto resolv dependencies.
	* often not up to date
	* 3rd party specialized repositories provide updated versions
	* but these repos may not included by default

**Pre-bulit Binaries**

* careful with incompatible core dependencies like glibc and libaio

	which may silent corrupt your data

* flexibility of install and update

	manually installed pre-built binaries is less likely to be replaced/overwritten during an update by simply keeping package folders on unique directories

**Custom Built Binaries**

* need to alter the default behavior of MySQL

	* disabling and totally disallowing use of query cache
	* increasing maximum total number of indexes per table from 64
	* take adavntages of new hardware, kernel or core libs

* require engineering effort for continuous integration (may be a lot)

	* Google, Facebook, Twitter

## Install

### MySQL Server

* package manager
* pre-built binary
* source code

#### Plugins

```shell
$ mysql_plugin -P
mysql_plugin would have been started with the following arguments:
--datadir=/var/lib/mysql
```

### MySQL Client

### Configure

back_log < (system back_log)

`my-{huge,large,medium,small}.cnf`

#### Default Configure

```shell
[will@rhel7.2.vmg]$ my_print_defaults mysqld
--datadir=/var/lib/mysql
--socket=/var/lib/mysql/mysql.sock
--symbolic-links=0
```

```shell
[will@ubuntu-14.04.4.vmg]$ my_print_defaults mysqld
--user=mysql
--pid-file=/var/run/mysqld/mysqld.pid
--socket=/var/run/mysqld/mysqld.sock
--port=3306
--basedir=/usr
--datadir=/var/lib/mysql
--tmpdir=/tmp
--lc-messages-dir=/usr/share/mysql
--skip-external-locking
--lower_case_table_names=1
--bind-address=127.0.0.1
--key_buffer=16M
--max_allowed_packet=16M
--thread_stack=192K
--thread_cache_size=8
--myisam-recover=BACKUP
--query_cache_limit=1M
--query_cache_size=16M
--log_error=/var/log/mysql/error.log
--expire_logs_days=10
--max_binlog_size=100M
```

#### Example Configure

```conf
!include /path/to/other.conf

[client]
port=3306
socket=/tmp/mysql.sock
# store password is not recommended, at lease make this file not readable by other users
password='passphrase'

[mysql]
# used for invoke of command: 'mysql'

[mysql-5.7]
# specific version
sql_mode=TRADITIONAL

[mysqld]
port=3306
socket=/tmp/mysql.sock
key_buffer_size=16M
max_allowed_packet=8M

performance_schema
performance_schema_events_waits_history_size=20
performance_schema_events_waits_history_long_size=15000

[mysqldump]
quick

[mysqladmin]
force
```

### Environment Variables

```shell
MYSQL_TCP_PORT=3306
EXPORT MYSQL_TCP_PORT
```

## Post Install

`mysql_install_db`

### First Run

Invoke `mysql_secure_installation` to:

0. set root password
0. remove test databases
0. restrict access

### Setup Users

```sql
# show current user
SELECT USER();
# set root password
mysqladmin -u root -password passphrase`
# update password
UPDATE mysql.user SET password = PASSWORD('passphrase') WHERE user = 'root';
FLUSH PRIVILEGES;
```

### Grant Accesses

Grant **Minimal Access** Only

`help grant`

**Syntax** `grant on <access> testdb.* to developer@'192.168.0.%';`

access:

* create
* alter
* drop
* references
* execute
* create temporary tables
* index
* create view
* show view
* create routine (can show procedure status)
* alter routine (can drop a procedure)

``` sql
with_option:
    GRANT OPTION
  | MAX_QUERIES_PER_HOUR count
  | MAX_UPDATES_PER_HOUR count
  | MAX_CONNECTIONS_PER_HOUR count
  | MAX_USER_CONNECTIONS count
```

## Running

* mysqld — The MySQL Server
* mysqld_safe — MySQL Server Startup Script
* mysql.server — MySQL Server Startup Script
* mysqld_multi — Manage Multiple MySQL Servers

## Backup and Recovery

### InnoDB Backup and Recovery

#### Backup

Type            | Tool
----------------|-----
hot backup      | MySQL Enterprise Backup
cold backup     | copying files when sql server is down
physical backup | fast operation (esp. restore)
logical backup  | mysqldump

**Notes**

`mysqldump` utility is usually used under two circumstances:

* smaller data volumes
* record schema obj structure

##### Cold Backup

0. slow shutdown
0. copy ibdata files and .ibd files
0. copy .frm files
0. copy ib_logfile files
0. copy my.cnf configuration files

#### InnoDB Recovery Process

0. apply redo log
0. rolling back incomplete transactions
0. chagne buffer merge
0. perge

## MySQL Replication

### Setup Slaves

Either

MySQL Enterprise Backup (without taking down server)

or

Cold Backup.

MySQL Replication is based on binlog.

Transactions that fails on the master do not affect replication at all.

**Note**

Replication and CASCADE foreign key cautious

## Upgrade

`mysql_upgrade`

## Downgrade

## References

* [OLTP vs OLAP](http://datawarehouse4u.info/OLTP-vs-OLAP.html)
* [option files](https://dev.mysql.com/doc/refman/5.7/en/option-files.html)
* [Overview of MySQL Programs](https://dev.mysql.com/doc/refman/5.7/en/programs-overview.html)
* [MySQL Server and Server-Startup Programs](https://dev.mysql.com/doc/refman/5.7/en/programs-server.html)
