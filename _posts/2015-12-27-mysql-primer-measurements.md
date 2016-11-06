---
layout: post
title: MySQL Primer - Benchmarking and Profiling
date: 2015-12-27 15:22:18.000000000 +08:00
type: post
published: true
status: publish
categories:
- database
- MySQL
tags:
- MySQL
---

## Introduction

This article described some basic usage of mysql server and introduce intermediate MySQL internals.

<!--more-->

## Table Of Contents

* TOC
{:toc}

## Overview

### MySQL Workbench

`mysql-workbench-community-6.3.6-src//plugins/wb.admin/frontend/wb_admin_monitor.py`

#### Server Status

`mforms.newServerStatusWidget()`

#### Load

```python
if self.server_profile.target_is_windows:
    self.cpu_usage.set_description("CPU")
else:
    self.cpu_usage.set_description("Load")
```

* CPU
	* queued tasks
* MEM
	* used and free
* IO
* NETWORK

Max & Mean

* Response Time
* Concurrent Connection
* TPS (Transaction per second)
* QPS (Query per second)

### Connection

max_connections = 151 (+1)

The extra is used for privileged users.

### Cache

`table_open_cache` 400

```sql
max_tmp_tables 32
tmp_table_size 16M
```

`read_rnd_buffer_size` 256K

`sort_buffer_size`

read_buffer_size

query_cache_size

```sql
SELECT SQL_NO_CACHE id, name FROM customer;
```

innodb_log_buffer_size

innodb_additional_mem_pool_size

innodb_buffer_pool_size

key_buffer_size

## Information Schema

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

## Performance Schema

### Tables

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

### InnoDB Status

* read reqs: Innodb_buffer_pool_read_requests /second
* write reqs: Innodb_buffer_pool_write_requests / second
* InnoDB Buffer Pool Utilization:

$$
\frac{Innodb\_buffer\_pool\_pages\_data + misc}{total}
$$

* disk reads: Innodb_buffer_pool_reads / second

* Redo Log:
	* data written: Innodb.os_log_written / second
	* writes: Innodb_log_writes / second

* Double write buffer:
	* writes: Innodb_dbuffer_writes / second

* InnoDB Disk Writes: Innodb_data_written / second
* InnoDB Disk Reads: Innodb_data_reads / second
* Innodb_read_ahead_threshold:
	* inspect (`show engine innodb status`)

**`show engine innodb status`**

* status
* log
* background thread
* buffer pool and memory
* semaphers
* row operations
* latest foreign key error
* latest detected deadlock
* transactions
* file I/O
* insert buffer and adaptive hash index

### InnoDB File Format and Row Format

* Barracuda
	* DYNAMIC
	* COMPRESSED
		* efficiency
	* COMPACT
	* REDUNDANT
* Antelope
	* COMPACT
	* REDUNDANT

### Locks

`innodb_lock_wait_timeout` only applies to innodb row locks.

### InnoDB I/O

Selects per second: Com_select / second

InnoDB writes per second: Innodb_data_writes/second

Innodb reads per second: Innodb_data_reads / second

Innodb buffer usage:

$$
\frac{Innodb\_buffer\_pool\_pages\_total - free}{total} \times 100\%
$$

Key efficiency:

$$
(1 - \frac{Key\_reads}{Key\_read\_requests}) \times 100\%
$$

### Network Status

Connections: Threads_connected

Incoming Network Traffic: Bytes_received /second

Outgoing Network Traffic: Bytes_sent / second

Client Connections: Thread_connected / max_connections

### Table Open Cache Efficiency

$$
\frac{Table\_open\_cache\_hits}{Table\_open\_cache\_hits + Table\_open\_cache\_misses}
$$

### SQL Statments Executed

```sql
Com_select Com_insert Com_update Com_delete Com_create_db
Com_creawte_event Com_create_function Com_create_index
Com_create_procedure Com_create_server Com_create_table
Com_create_trigger Com_create_udf Com_create_user
Com_create_view Com_alter_db Com_alter_db_upgrade
Com_alter_event Com_alter_function Com_alter_procedure
Com_alter_server Com_alter_table Com_alter_tablepsace
Com_alter_user Com_drop_db Com_drop_event Comp_drop_fucntion
Com_drop_index Com_drop_procedure Com_drop_server
Com_drop_tabel Com_drop_trigger Com_drop_user COm_drop_view
```

## MySQL Replication

### Replication Delay

MySQL replication works with two threads:

* IO_THREAD

	connects to the master and read binary log events from the master as they come in and copies them over to a local log file called relay log.

	depends on the network connectivity, network latency, ...

* SQL_THREAD

	read events from a relay log stored locally on the replication slave (the file was written by IO thread) and then applies them as fast as possible.

```sql
show master|slave status;
```

## MySQL Performance

* sort buffer size
* create index on orders ()
* query_cache
	* query_cache_limit
	* query_cache_size
* table compression
	* zlib
	* LZ77
* optimize table

### Table Compressions

#### Pre Conditions

```sql
SET GLOBAL innodb_file_per_table=1;
SET GLOBAL innodb_file_format=Barracuda;
```

#### Compress

```sql
CREATE TABLE t1
 (c1 INT PRIMARY KEY)
 ROW_FORMAT=COMPRESSED
 KEY_BLOCK_SIZE=8;
```

**KEY_BLOCK_SIZE**

measure size of .idb file to see how well each performs with a realistic workload

These values compresses well:

* BLOB
* VARCHAR
* TEXT

overflow pages (off-page columns)

read for more often than written

information_schema.innodb_cmp (compress_ops_ok/compress_ops)

Compression and InnoDB Buffer Pool

Adaptive LRU:

* compressed pages
* uncompressed pages (evict)

is used to keep balance between:

* I/O bound
* CPU bound

## Diagnose

0. ERROR 1040 (HY000): Too many connections

if `show processlist` contains too many sleeping connections; then:

`wait_timeout` default 28800, set to a relative short period of time may help.

else you may consider increase `max_connections` based on your workload.

### Inspect

* processlist
* status
	* `Questions`
	* `Slave_running`
	* `Threads_connected`
	* `Threads_running`
	* `Aborted_clients`
	* `Handler_%`;
	* `Opened_tables`
	* `Select_full_join`
	* `Select_scan`
	* `Slow_queries`
	* `Threads_created`
* show status
* show plugins
* show engine innodb status
* show table status
* profile

  ```sql
  SET PROFILING = 1;
  SHOW profiles;
  ```

Use `FLUSH STATUS` to reset status variables.

SUM(Com_xxx) + QCache_hits == Questions + statements executed within stored programs == Queries

### Query Cache

Use `flush query_cache` to flush query cache between measurements.

* Memory Utilization

<script src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>

$$
\frac{query\_cache\_size - Qcache\_free\_memory}{query\_cache\_size} \times 100\%
$$

* Hit Rate

$$
\frac{Qcache\_hits}{Qcache\_hits + Qcache\_inserts + Qcache\_not\_cached} \times 100\%
$$

Qcache_lowmem_prunes (LRU) -> query_cache_size

**Query Cache Memory Fragmentation**

* Qcache_total_blocks
* Qcache_free_blocks

Qcache entry consists of two parts:

* Query String (one block)
* Result Set (+1 block(s))

`query_cache_wlock_invalidate = ON/OFF`

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

#### Disadvantages

* No control on invalidation
* It is not that fast (compared to dedicated cache system like memcached)
* Cannot retrieve multiple objs at the same time
* Is not distributed

## MySQL Plugins

### Query Rewrites

Query rewrites can be used to force index on some search.

Query rewrites can in placed in two points:

* pre-parse
* post-parse (more efficient)


## Appendix

### Inspect Examples

```sql
status;
--------------
mysql  Ver 15.1 Distrib 5.5.47-MariaDB, for Linux (x86_64) using readline 5.1

Connection id:		11
Current database:	information_schema
Current user:		root@localhost
SSL:			Not in use
Current pager:		stdout
Using outfile:		''
Using delimiter:	;
Server:			MariaDB
Server version:		5.5.47-MariaDB MariaDB Server
Protocol version:	10
Connection:		Localhost via UNIX socket
Server characterset:	latin1
Db     characterset:	utf8
Client characterset:	utf8
Conn.  characterset:	utf8
UNIX socket:		/var/lib/mysql/mysql.sock
Uptime:			1 day 17 hours 13 min 18 sec

Threads: 1  Questions: 181  Slow queries: 0  Opens: 0  Flush tables: 2  Open tables: 26  Queries per second avg: 0.001
--------------
```

```sql
show status;
+------------------------------------------+-------------+
| Variable_name                            | Value       |
+------------------------------------------+-------------+
| Aborted_clients                          | 0           |
| Aborted_connects                         | 4           |
| Access_denied_errors                     | 0           |
| Aria_pagecache_blocks_not_flushed        | 0           |
| Aria_pagecache_blocks_unused             | 15737       |
| Aria_pagecache_blocks_used               | 0           |
| Aria_pagecache_read_requests             | 0           |
| Aria_pagecache_reads                     | 0           |
| Aria_pagecache_write_requests            | 0           |
| Aria_pagecache_writes                    | 0           |
| Aria_transaction_log_syncs               | 0           |
| Binlog_commits                           | 0           |
| Binlog_group_commits                     | 0           |
| Binlog_snapshot_file                     |             |
| Binlog_snapshot_position                 | 0           |
| Binlog_bytes_written                     | 0           |
| Binlog_cache_disk_use                    | 0           |
| Binlog_cache_use                         | 0           |
| Binlog_stmt_cache_disk_use               | 0           |
| Binlog_stmt_cache_use                    | 0           |
| Busy_time                                | 0.000000    |
| Bytes_received                           | 4232        |
| Bytes_sent                               | 136174      |
...
```

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

```sql
show engine innodb status \G;
*************************** 1. row ***************************
  Type: InnoDB
  Name: 
Status: 
=====================================
160519 11:54:52 INNODB MONITOR OUTPUT
=====================================
Per second averages calculated from the last 5 seconds
-----------------
BACKGROUND THREAD
-----------------
srv_master_thread loops: 1 1_second, 1 sleeps, 0 10_second, 1 background, 1 flush
srv_master_thread log flush and writes: 1
----------
SEMAPHORES
----------
OS WAIT ARRAY INFO: reservation count 2, signal count 2
Mutex spin waits 2, rounds 37, OS waits 0
RW-shared spins 2, rounds 60, OS waits 2
RW-excl spins 0, rounds 0, OS waits 0
Spin rounds per wait: 18.50 mutex, 30.00 RW-shared, 0.00 RW-excl
--------
FILE I/O
--------
I/O thread 0 state: waiting for completed aio requests (insert buffer thread)
I/O thread 1 state: waiting for completed aio requests (log thread)
I/O thread 2 state: waiting for completed aio requests (read thread)
I/O thread 3 state: waiting for completed aio requests (read thread)
I/O thread 4 state: waiting for completed aio requests (read thread)
I/O thread 5 state: waiting for completed aio requests (read thread)
I/O thread 6 state: waiting for completed aio requests (write thread)
I/O thread 7 state: waiting for completed aio requests (write thread)
I/O thread 8 state: waiting for completed aio requests (write thread)
I/O thread 9 state: waiting for completed aio requests (write thread)
Pending normal aio reads: 0 [0, 0, 0, 0] , aio writes: 0 [0, 0, 0, 0] ,
 ibuf aio reads: 0, log i/o's: 0, sync i/o's: 0
Pending flushes (fsync) log: 0; buffer pool: 0
154 OS file reads, 3 OS file writes, 3 OS fsyncs
0.00 reads/s, 0 avg bytes/read, 0.00 writes/s, 0.00 fsyncs/s
-------------------------------------
INSERT BUFFER AND ADAPTIVE HASH INDEX
-------------------------------------
Ibuf: size 1, free list len 0, seg size 2, 0 merges
merged operations:
 insert 0, delete mark 0, delete 0
discarded operations:
 insert 0, delete mark 0, delete 0
Hash table size 276671, node heap has 0 buffer(s)
0.00 hash searches/s, 0.00 non-hash searches/s
---
LOG
---
Log sequence number 1597945
Log flushed up to   1597945
Last checkpoint at  1597945
Max checkpoint age    7782360
Checkpoint age target 7539162
Modified age          0
Checkpoint age        0
0 pending log writes, 0 pending chkp writes
8 log i/o's done, 0.00 log i/o's/second
----------------------
BUFFER POOL AND MEMORY
----------------------
Total memory allocated 137756672; in additional pool allocated 0
Total memory allocated by read views 88
Internal hash tables (constant factor + variable factor)
    Adaptive hash index 2217584 	(2213368 + 4216)
    Page hash           139112 (buffer pool 0 only)
    Dictionary cache    593780 	(554768 + 39012)
    File system         83536 	(82672 + 864)
    Lock system         333248 	(332872 + 376)
    Recovery system     0 	(0 + 0)
Dictionary memory allocated 39012
Buffer pool size        8191
Buffer pool size, bytes 134201344
Free buffers            8048
Database pages          143
Old database pages      0
Modified db pages       0
Pending reads 0
Pending writes: LRU 0, flush list 0, single page 0
Pages made young 0, not young 0
0.00 youngs/s, 0.00 non-youngs/s
Pages read 143, created 0, written 0
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
No buffer pool page gets since the last printout
Pages read ahead 0.00/s, evicted without access 0.00/s, Random read ahead 0.00/s
LRU len: 143, unzip_LRU len: 0
I/O sum[0]:cur[0], unzip sum[0]:cur[0]
--------------
------------
TRANSACTIONS
------------
```


```sql
show profile for query 24;
+----------------------+----------+
| Status               | Duration |
+----------------------+----------+
| starting             | 0.000045 |
| checking permissions | 0.000005 |
| Opening tables       | 0.000035 |
| After opening tables | 0.000002 |
| System lock          | 0.000001 |
| Table lock           | 0.000001 |
| After table lock     | 0.000003 |
| init                 | 0.000008 |
| optimizing           | 0.005735 |
| statistics           | 0.000023 |
| preparing            | 0.000007 |
| executing            | 0.000002 |
| Filling schema table | 0.000122 |
| checking permissions | 0.000165 |
| checking permissions | 0.000163 |
| checking permissions | 0.000044 |
| checking permissions | 0.000007 |
| executing            | 0.000007 |
| Sending data         | 0.000105 |
| end                  | 0.000005 |
| query end            | 0.000003 |
| closing tables       | 0.000001 |
| removing tmp table   | 0.000005 |
| closing tables       | 0.000002 |
| freeing items        | 0.000004 |
| updating status      | 0.000163 |
| cleaning up          | 0.000004 |
+----------------------+----------+
27 rows in set (0.00 sec)
```

## Benchmarking

## References

* [MathJax Quick Reference](http://meta.math.stackexchange.com/questions/5020/mathjax-basic-tutorial-and-quick-reference)
* [How to identify and cure MySQL replication slave lag](https://www.percona.com/blog/2014/05/02/how-to-identify-and-cure-mysql-replication-slave-lag/)
