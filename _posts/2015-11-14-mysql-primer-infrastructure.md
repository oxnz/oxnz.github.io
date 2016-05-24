---
layout: post
title: MySQL Primer - Infrastructure
date: 2015-11-14 15:22:18.000000000 +08:00
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

This article describes the infrastructure of MySQL.

<!--more-->

## Table Of Contents

* TOC
{:toc}

## Files

### Executables

#### MySQL Client

* mysql — The MySQL Command-Line Tool
* mysqladmin — Client for Administering a MySQL Server
* mysqlcheck — A Table Maintenance Program
* mysqldump — A Database Backup Program
* mysqlimport — A Data Import Program
* mysqlpump — A Database Backup Program
* mysqlshow — Display Database, Table, and Column Information
* mysqlslap — Load Emulation Client

#### MySQL Admin

* innochecksum — Offline InnoDB File Checksum Utility
* myisam_ftdump — Display Full-Text Index information
* myisamchk — MyISAM Table-Maintenance Utility
* myisamlog — Display MyISAM Log File Contents
* myisampack — Generate Compressed, Read-Only MyISAM Tables
* mysql_config_editor — MySQL Configuration Utility
* mysqlbinlog — Utility for Processing Binary Log Files
* mysqldumpslow — Summarize Slow Query Log Files

### Configure File

my.cnf

### Data Files

The system tablespace (+1 ibdata files)

Zero or more single-table tabpespaces (`file_per_table` files, named *.ibd files)

### Log Files

InnoDB log files (usually two: ib_logfile0, ib_logfile1, used for crash recovery and in backups)

#### Slow Log

Contains the slow queries.

#### General Log

General log is generally send to a file or table.

It contains debug info and can be tweaked with `--log-raw`

#### Error Log

Error log is intend for DBA or sysadm use.

Error log is stored in plain text file, cannot stored in table. But can use native system log utilities:

* Event Log (Windows platform)
* syslog (Unix like platform)

It contains information of serval aspects:

* exhaustion of resources
* system error
* backtrace of error crashes
* damaged databases and indices
* errors on startup
* failed or refused connections

## Builtin Databases

### Information Schema

* INNODB_CMP
* INNODB_CMP_RESET

* INNODB_CMPMEM
* INNODB_CMPMEM_RESET

* INNODB_TRXX
* INNODB_LOCKS
* INNODB_LOCK_WAITS

* INNODB_BUFFER_PAGE_LRU <----> BLOCK_ID
* INNODB_BUFFER_PAGE <-----> LRU_POSITION
* INNODB_BUFFER_POOL_STATS

INNODB_BUFFER_PAGE_LRU and INNODB_BUFFER_PAGE is performance issue related.

INNODB_BUFFER_POOL_STATS and

```sql
show status like 'Innodb_buffer%';
show engine innodb status;
```

can be used to get similar information

### Performance Schema

#### Tables

* mutex_instances
* rwlock_instances
* cond_instances
* file_instances

## Storage Engines

* MyISAM
* InnoDB

## InnoDB

### InnoDB monitor

There are 4 InnoDB monitors:

Name                      | Table
--------------------------|----------------------------
Standard InnoDB Monitor   | `innodb_monitor`
InnoDB Lock Monitor       | `innodb_lock_monitor`
InnoDB Tablespace Monitor | `innodb_tablespace_monitor`
InnoDB Table Monitor      | `innodb_table_monitor`

innodb_status_file = 1

innodb_status.pid

Standard Monitor:

```sql
# create innodb monitor
CREATE TABLE innodb_monitor (a int) ENGINE = INNODB;
# drop innodb monitor
DROP innodb_monitor
```

Lock Monitor:

```sql
CREATE TABLE innodb_lock_monitor (a INT) ENGINE = INNODB;
DROP innodb_lock_monitor
```

### InnoDB File Format and Row Format

* Barracuda
	* DYNAMIC
	* COMPRESSED
	* COMPACT
	* REDUNDANT
* Antelope
	* COMPACT
	* REDUNDANT

### Locks

`innodb_lock_wait_timeout` only applies to innodb row locks.

## Plugins

### Query Rewrites

Query rewrites can be used to force index on some search.

Query rewrites can in placed in two points:

* pre-parse
* post-parse (more efficient)

#### Installed Plugins

```sql
show plugins;
+--------------------------------+----------+--------------------+---------+---------+
| Name                           | Status   | Type               | Library | License |
+--------------------------------+----------+--------------------+---------+---------+
| binlog                         | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
| mysql_native_password          | ACTIVE   | AUTHENTICATION     | NULL    | GPL     |
| mysql_old_password             | ACTIVE   | AUTHENTICATION     | NULL    | GPL     |
| MEMORY                         | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
| MyISAM                         | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
| CSV                            | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
| MRG_MYISAM                     | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
| ARCHIVE                        | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
| PERFORMANCE_SCHEMA             | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
| InnoDB                         | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
| INNODB_RSEG                    | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_UNDO_LOGS               | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_TRX                     | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_LOCKS                   | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_LOCK_WAITS              | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_CMP                     | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_CMP_RESET               | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_CMPMEM                  | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_CMPMEM_RESET            | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_SYS_TABLES              | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_SYS_TABLESTATS          | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_SYS_INDEXES             | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_SYS_COLUMNS             | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_SYS_FIELDS              | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_SYS_FOREIGN             | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_SYS_FOREIGN_COLS        | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_SYS_STATS               | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_TABLE_STATS             | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_INDEX_STATS             | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_BUFFER_POOL_PAGES       | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_BUFFER_POOL_PAGES_INDEX | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_BUFFER_POOL_PAGES_BLOB  | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| XTRADB_ADMIN_COMMAND           | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_CHANGED_PAGES           | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_BUFFER_PAGE             | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_BUFFER_PAGE_LRU         | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| INNODB_BUFFER_POOL_STATS       | ACTIVE   | INFORMATION SCHEMA | NULL    | GPL     |
| FEDERATED                      | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
| BLACKHOLE                      | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
| Aria                           | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
| FEEDBACK                       | DISABLED | INFORMATION SCHEMA | NULL    | GPL     |
| partition                      | ACTIVE   | STORAGE ENGINE     | NULL    | GPL     |
+--------------------------------+----------+--------------------+---------+---------+
42 rows in set (0.00 sec)
```

## Memory

### Query Cache

#### Query Cache Features

* Caching full queryies only
* Works on packet level
* Works before parsing
* Exactly the same matching strategy
* Only select queries are cached
* Query must be deterministic
* Table level graunlarity in invalidation
* Fragmentation over time
* Limited amount of usable memory
* Demand operating mode
* Counting query cache efficiency

#### Query Types

* select
* insert
* update
* delete

#### Disadvantages

* No control on invalidation
* It is not that fast (compared to dedicated cache system like memcached)
* Cannot retrieve multiple objs at the same time
* Is not distributed

## References

* [MySQL Administrative and Utility Programs](https://dev.mysql.com/doc/refman/5.7/en/programs-admin-utils.html)
* [MySQL Client Programs](https://dev.mysql.com/doc/refman/5.7/en/programs-client.html)
