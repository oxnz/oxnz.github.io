---
layout: post
title: MySQL 性能调优分享
categories:
- sysadm
- DBA
- perf
tags:
- mysql
---

## 摘要

MySQL 凭借着开源社区和 Oracle 公司的支持，快速迭代变为很多公司关系型数据库的首选。

本文着眼于 MySQL 的性能优化, 系统的介绍了性能优化的各个方面，从系统的选择，安装使用到性能测量，优化，末尾介绍了文档平台数据库优化过程中几个有代表性的例子。

由于数据库优化设计内容众多，本文仅列出大纲，具体内容分布在对应的文章中。

<!--more-->

## 安排

2016-05-24T15:30:00 +0800 - 2016-05-24T18:20:00 +0800

* [安装&使用]({% post_url 2014-09-23-mysql-primer-up-and-running %}) 10min
* [MySQL 架构]({% post_url 2015-11-14-mysql-primer-infrastructure %}) 10min
* [MySQL 测量]({% post_url 2015-12-27-mysql-primer-measurements %}) 30min
* [性能调优]({% post_url 2016-03-21-mysql-primer-performance	%}) partial
* 案例分析

## 目录

* TOC
{:toc}

## 性能

* 不要只关注平均情况
* 结合变化趋势(daily, weekly, monthly)
* 为将来性能考虑

### 指标及测量

### 性能优化虑顾

* 稳定性
* 可扩展性
	* 负载
	* 数据集大小
	* 架构
* 效率(Efficiency)

### 重点

性能优化一般聚焦于:

* 使 Query 执行更快
* 使用更少的资源
* 更好的扩展性

## 分析

### 系统

#### 系统负载

### MySQL Server

#### 内部状态

### 工作负载

### Query

#### Explain

#### Slow Query

## 优化

### 步骤

0. 硬件
0. 服务器
	* 操作系统
	* 网络
	* 文件系统
0. MySQL 服务器
	* Query 优化
	* Database schema

### 操作系统优化

一般而言，操作系统厂商对于操作系统的优化使面向公共系统负载的。但是在生产环境中，基本上每个服务器的负载都是各有偏重的。例如数据库，应用和负载均衡代理等各自为一个系统，而每个对各种资源的需求都是各有特色的。

### 工具

* PT-Query-Digest from Percona Toolkit
* Mysql Utilities
* Mysql Performance Schemas

### 内存

### I/O

### 网络

#### 延迟

#### 压缩

#### 系统配置

#### MySQL 配置

```sql
SHOW GLOBAL VARIABLES;
SHOW GLOBAL STATUS;
```

## 存储引擎

## MySQL 优化

### 线程

### 内存

### 日志

### InnoDB 特定优化

## MySQL Replication

## 数据库优化

### 第三范式

### 表优化

#### 压缩

## 索引优化

### InnoDB 特定优化

## 事务优化

优化事物的慢查询

## Query 优化

### Query Cache

### Prepared Statements

### Query Rewrites

## 案例分析

1. protocol compression
1. table compression
1. add index
1. query rewrite
1. query cache


**Differences Between System and MySQL Versions**

```sql
select
@@version,
@@max_connections,
@@log_bin,
@@table_open_cache,
@@table_definition_cache,
@@open_files_limit,
@@innodb_buffer_pool_size,
@@innodb_log_file_size,
@@innodb_flush_log_at_trx_commit,
@@innodb_flush_method;
```

**Ubuntu 14.04 LTS**

```sql
+-------------------------+-------------------+-----------+--------------------+--------------------------+--------------------+---------------------------+------------------------+----------------------------------+-----------------------+
| @@version               | @@max_connections | @@log_bin | @@table_open_cache | @@table_definition_cache | @@open_files_limit | @@innodb_buffer_pool_size | @@innodb_log_file_size | @@innodb_flush_log_at_trx_commit | @@innodb_flush_method |
+-------------------------+-------------------+-----------+--------------------+--------------------------+--------------------+---------------------------+------------------------+----------------------------------+-----------------------+
| 5.5.47-0ubuntu0.14.04.1 |               151 |         0 |                400 |                      400 |               1024 |                 134217728 |                5242880 |                                1 | NULL                  |
+-------------------------+-------------------+-----------+--------------------+--------------------------+--------------------+---------------------------+------------------------+----------------------------------+-----------------------+
1 row in set (0.00 sec)
```

**Red Hat Enterprise Linux 7.2**

```sql
+----------------+-------------------+-----------+--------------------+--------------------------+--------------------+---------------------------+------------------------+----------------------------------+-----------------------+
| @@version      | @@max_connections | @@log_bin | @@table_open_cache | @@table_definition_cache | @@open_files_limit | @@innodb_buffer_pool_size | @@innodb_log_file_size | @@innodb_flush_log_at_trx_commit | @@innodb_flush_method |
+----------------+-------------------+-----------+--------------------+--------------------------+--------------------+---------------------------+------------------------+----------------------------------+-----------------------+
| 5.5.47-MariaDB |               151 |         0 |                400 |                      400 |               1024 |                 134217728 |                5242880 |                                1 | NULL                  |
+----------------+-------------------+-----------+--------------------+--------------------------+--------------------+---------------------------+------------------------+----------------------------------+-----------------------+
1 row in set (0.00 sec)
```

**CentOS 6.3**

```sql
+------------+-------------------+-----------+--------------------+--------------------------+--------------------+---------------------------+------------------------+----------------------------------+-----------------------+
| @@version  | @@max_connections | @@log_bin | @@table_open_cache | @@table_definition_cache | @@open_files_limit | @@innodb_buffer_pool_size | @@innodb_log_file_size | @@innodb_flush_log_at_trx_commit | @@innodb_flush_method |
+------------+-------------------+-----------+--------------------+--------------------------+--------------------+---------------------------+------------------------+----------------------------------+-----------------------+
| 5.5.35-log |              3000 |         1 |               1024 |                      400 |              65536 |               34359738368 |             1992294400 |                                2 | NULL                  |
+------------+-------------------+-----------+--------------------+--------------------------+--------------------+---------------------------+------------------------+----------------------------------+-----------------------+
1 row in set (0.00 sec)
```

0. Diagnose

   ```shell
   $ sudo apt-get install percona-toolkit
   $ pt-query-digest slow-pre.log > report-post.txt
   ```

1. Sort Optimization

   ```sql
   mysql>  show global variables like '%sort%';
   +---------------------------+-------------+
   | Variable_name             | Value       |
   +---------------------------+-------------+
   | max_length_for_sort_data  | 1024        |
   | max_sort_length           | 1024        |
   | myisam_max_sort_file_size | 10737418240 |
   | myisam_sort_buffer_size   | 67108864    |
   | sort_buffer_size          | 2097152     |
   +---------------------------+-------------+
   5 rows in set (0.00 sec)
   mysql> show global status like '%sort%';
   +-------------------+-----------+
   | Variable_name     | Value     |
   +-------------------+-----------+
   | Sort_merge_passes | 11759     |
   | Sort_range        | 86795644  |
   | Sort_rows         | 909752450 |
   | Sort_scan         | 97771     |
   +-------------------+-----------+
   4 rows in set (0.01 sec)
   ```

```sql
set global sort_buffer_size = 8M;
set global sort_buffer_size = 32M；
目前是2M
+-------------------+--------+
| Variable_name | Value |
+-------------------+--------+
| Sort_merge_passes | 24 |
| Sort_range | 1 |
| Sort_rows | 287159 |
| Sort_scan | 0 |
+-------------------+--------+

set global query_cache_min_res_unit = 4096*2
set global query_cache_min_res_unit = 1024;flush query cache;
set global query_cache_min_res_unit = 2048;
set global query_cache_limit = 2*1024*1024;
flush query cache;
```

## 结论

* 以应用性能为重心
* 真对不同的工作，选择合适的工具
* 查看负载的查询
* 减少查询次数
* 减少返回结果大小
* 看看如何可以减少工作(See how they can do less work)
* 提高工作效率(Do that work more efficiently)

**注意**

* 不要使用默认配置
* 不要沉迷于性能调优

## Q&A
