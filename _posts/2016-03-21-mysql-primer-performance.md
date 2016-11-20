---
layout: post
title: MySQL Primer - Performance
date: 2016-03-21 15:22:18.000000000 +08:00
type: post
published: true
status: publish
categories:
- database
- MySQL
tags:
- MySQL
---

![MySQL Performance Balance](/assets/mysql-perf-balance.png)

## Introduction

This article will discus MySQL server performance tuning tips and tricks.

This article is intend for

* Application Designer/Developer
* Database/System Administrator

<!--more-->

## Table Of Contents

* TOC
{:toc}

## Performance

### Measurements

Know the baseline.

See [measurements] for details about performance measurements.

### Concerns

* Stability
* Security
* Manageability
* Compatibility
* Compliance
* Ease of use by Developers
* Efficiency
* Scalability
	* Load
	* Data Size
	* Infrastructure

### Focus

* Making queries run faster
* Using less resources
* Scaling better

## Analyzing

* Understand hardware platform limits
	* helps deploying in an optimal way
* Understand MySQL Server internals
	* helps configuring database settings in the most optimal way
	* some limitations are here 'by design'
* Understand of your Workload
	* helps you to tune the whole solution in the most optimal way
	* 20% of known issues covering 80% of the most common problems
	* so, adapt some best practices from the beginning
* There is NO 'Silver Bullet'

* RAM
* Workload
* Storage Engines

### Notes

* Do not look at the average case only
* Look at trends over time (daily, weekly, monthly)
* Think about future performance

### OS

Generally speaking, the OS manufactories made their product good for common workloads by defaults. But in production, most server act as a specific character providing services, such as DB server, App Server, Proxy, etc. And so, the defaults may not the best.

#### System Loads

* CPU Usage
* Run Queue
* RAM/SWAP
* (Top) processes
* I/O op/sec & MB/sec
* Network traffic
* etc

### MySQL Server

Overview

* Multi-Threaded
	* fast context switch
	* all threads see all data
	* so, data lock is needed
	* design is very important
	* MT malloc
	* user threads
	* 'background' threads:
		* Master thread
		* Cleaner thread(s)
		* Purge thread(s)
		* IO threads
	* mutexes and RW-locks
	* most famous in the past:
		* MySQL: LOCK_open
		* InnoDB: kernel_mutex

#### Internal Status

* MySQL Information Schema
* MySQL Performance Schema

```sql
select EVENT_NAME, max(SUM_TIMER_WAIT)/1000000000000 as WaitTM from events_waits_summary_global_by_event_name group by 1 order by 2 desc limit 5;
select EVENT_NAME, max(SUM_TIMER_WAIT)/1000000000000 as WaitTM from events_waits_summary_by_instance group by 1 order by 2 desc limit 5;
```

### Workloads

* Read-Only (RO)
* Read-Write (RW)

### Query

#### Explain

Explain send the query all the way to the optimizer instead of the storage engine, and returns the query execution plan.

The plan would tell:

* in which order the tables are read
* what types of read operations that are made
* which indexes can be used
* which indexes are used
* how tables refer to each other
* how many rows the optimizer estimates to retrieve from each table


Type

```
system              The table has only one row 
const               At the most one matching row, treated as a constant 
eq_ref              One row per row from previous tables 
ref                 Several rows with matching index value 
ref_or_null         Like ref, plus NULL values 
index_merge         Several index searches are merged 
unique_subquery     Same as ref for some subqueries 
index_subquery      As above for non-unique indexes 
range               A range index scan 
index               The whole index is scanned 
ALL                 A full table scan
```

Extra

```
STRAIGHT_JOIN       Forces the optimizer to join the tables in the given order 
SQL_BIG_RESULTS     Together with GROUP BY or DISTINCT tells the server to use disk-based temp tables 
SQL_BUFFER_RESULTS  Tells the server to use a temp table, thus releasing locks early (for table-locks) 
USE INDEX           Hints to the optimizer to use the given index 
FORCE INDEX         Forces the optimizer to use the index (if possible) 
IGNORE INDEX        Forces the optimizer not the use the index 
```

Optimizer Hints

```
STRAIGHT_JOIN       Forces the optimizer to join the tables in the given order 
SQL_BIG_RESULTS     Together with GROUP BY or DISTINCT tells the server to use disk-based temp tables 
SQL_BUFFER_RESULTS  Tells the server to use a temp table, thus releasing locks early (for table-locks) 
USE INDEX           Hints to the optimizer to use the given index 
FORCE INDEX         Forces the optimizer to use the index (if possible) 
IGNORE INDEX        Forces the optimizer not the use the index 
```

#### Slow Query

* log_queries_not_using_indexes
* log_slow_admin_statements

* mysqldumpslow
* pt-query-digest

## Optimization

Some basic rules:

* avoid tweak on production systems
* focus on the test which are most significant
* focus on test which are potentially depending on settings you are tweaking
* any test case is important
* most of the problems is in your app(95%)
* monitoring is the must, do not do anything without monitoring
* keep thinking about what you are doing

### Optimization Chances

* Deploy

	Deploy optimal would eliminate many potential performance issues.

* When there are performance issues
* tack performance into consideration when developing
* keep optimizing while business grows

### General Steps

0. Hardware
0. Server
	* OS
	* Network
	* File System
0. MySQL Server
	* Engine
	* Database schema
	* Optimize the queries

Generally speaking, the OS manufactories made their product good for common workloads by defaults. But in production, most server act as a specific character providing services, such as DB server, App Server, Proxy, etc. And so, the defaults may not the best.

See [Performance Tuning] for more details about system optimization.

### Tools

* DTrace (mysql-5.7.11/support-files/dtrace)
* Sysbench
	* OLTP
	* RO/RW
	* N-tables
	* lots load options
	* deadlocks
* Percona Toolkit
	* pt-query-digest
* MySQL Utilities
* MySQL Workbench
* MySQL Monitor Tools
	* MySQL Enterprise Monitor
	* Cacti
	* Zabbix
	* Nagios
	* dim_STAT
* System Monitoring (See system tunning for details)
* MySQL Proxy
	* Query Rewrite
	* Load Balance
	* Read/Write Splitting

![MySQL Proxy](/assets/mysql-proxy.jpg)

### Memory

* **OS Usage**: Kernel, running processes, filesystem cache, etc.
* **MySQL fixed usage**: query cache, InnoDB buffer pool size, mysqld rss, etc.
* **MySQL workload based usage**: connections, per-query buffers (join buffer, sort buffer, etc.)
* **MySQL replication usage**:  binary log cache, replication connections, Galera gcache and cert index, etc.
* **Any other services on the same server**: Web server, caching server, cronjobs, etc.

### Disk I/O

Using raw disk partition for the system tablespace

newraw -> raw

### Network

#### Latency

* TCP_NODELAY ON means send the data (partial frames) the moment you get, regardless if you have enough frames for a full network packet.
* TCP_NODELAY OFF means Nagles Algoritm which means send the data when it is bigger than the MSS or waiting for the receiving acknowledgement before sending data which is smaller.
* TCP_CORK ON means don't send any data (partial frames) smaller than the MSS until the application says so or until 200ms later.
* TCP_CORK OFF means send all the data (partial frames) now.

See [Difference between TCP_CORK and TCP_NODELAY] for more details.

#### Compression

Performance benefits are going to be largely dependent on:

* the size of the result sets that you are sending
* the network bandwidth and latency between the database server and its clients

The larger the result sets, the larger the latency, or the less bandwidth, the more likely you will see the benefit of compression.

Your maximum level of service is limited to the smallest bottleneck. So, you need to analyze where you're currently at regarding network and CPU resources.

Turn compression on if:

* there is a lot of headroom before CPU becomes the bottleneck
* the result sets are a significant size
* the network is a factor

If you pay for bandwidth, trading CPU usage for bandwidth is easily justified, and even if you're not anywhere near reaching the bandwidth bottleneck, that faster speed, and higher level of service, is worth something.

Don't forget that the client must also expend CPU cycles to decompress the data. Not a major issue, but still a factor. In general, today's CPUs are faster than today's networks.

See [Compression] for MySQL Internals about compression.

See [Connector J Configure] for more details about how to apply these settings.

### System Configuration

See [MySQL Primer - Up and Running] for more details

### MySQL Configuration

`my-{huge,large,medium,small}.cnf`

## Storage Engines

* MyISAM (table locking)
* InnoDB (row locking)

## MySQL Optimization

* back_log < (system back_log)
* max_connections
	* very important for tuning thread specific memory areas
	* max_connections = 151 (+1)
	* the extra is used for privileged users.
* max_allowed_packet
* thread_cache
	* number of threads to keep for reuse
	* increse if threads_created is high
	* not useful if the client uses connection pooling
	* each connection uses at least `thread_stack` of memory
* log_bin
* open_files_limit
* table_definitions_cache_size
* table_open_cache
	* cache used for opened table handlers
	* increse this if Opened_tables is high
* sort_buffer_size
* read_rnd_buffer_size 256K
* read_buffer_size
* query_cache_limit
* query_cache_size
	* disable cache: `SELECT SQL_NO_CACHE id, name FROM customer`
* max_tmp_tables 32
* tmp_table_size 16M
	* The maximum size of internal in-memory temporary tables
* max_heap_table_size
	* sets the maximum size to which user-created MEMORY tables are permitted to grow

### InnoDB-Specific

* innodb_flush_method = O_DIRECT
	* the innodb cache is more efficient compared to OS cache
		* no copying
		* adaptive hash indexes (AHI) lets InnoDB perform more like an in-memory database
		* ability to buffer writes
		* other factors
	* disable OS cache while innodb is caching already
* innodb_additional_mem_pool_size
* innodb_buffer_pool_size (128M by default)
	* innodb_buffer_pool_size = n * innodb_buffer_pool_chunk_size * innodb_buffer_pool_instances
	* cache both data and indexes
	* reduce disk I/O
	* up to 80% on a dedicated system
	* InnoDB reserves additional memory for buffers and control structures, so the total allocated space is approximately 10% greater than the specified buffer pool size
	* the time to initialize the buffer pool is roughly proportional to its size
	* careful with swap
* innodb_buffer_pool_instances
	* increse this value to improve scalability if the innodb_buffer_pool_size > 1GB
	* separate instances can improve concurrency, by reducing contention as different threads read and write to cached pages
	* each buffer pool manages its own free lists, flush lists, LRUs, and all other data structures connected to a buffer pool, and is protected by its own buffer pool mutex
	* each buffer pool instance is at least 1GB
* innodb_flush_log_at_trx_commit
	* 0 writes and sync's once per second (not ACID)
	* 1 forces sync to disk after every commit
	* 2 write to disk every commit but only sync's about once per second
* innodb_log_buffer_size
	* allow transactions to be logged in memory
* innodb_log_file_size
	* size of each InnoDB redo log file
	* can be up to `buffer_pool_size`

## MySQL Replication

## Database Privileges Optimization

Simplifying the privileges established by GRANT statements enables MySQL to reduce permission-checking overhead when clients execute statements.

## Database Optimization

### Optimizing Data Size

### Optimizing MySQL Data Types

### Optimizing for Many Tables

### Internal Temporary Table Use in MySQL

### Normalization

Transactional databases should be in the 3rd normal form.

## Table Optimization

* Use small data types
	* INT instead of BIGINT
	* VARCHAR(10) instead of VARCHAR(255)
* Be careful with joins
* NOT NULL if applicable
* PROCEDURE ANALYSE()
* summary tables (OLAP)

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

## Index Optimization

* Indexes are used to find rows with specific column values quickly
* All MySQL data types can be indexed
* Most MySQL indexes(PRIMARY KEY, UNIQUE, FULLTEXT) are stored in B-Trees
* Indexes on spatial data types use R-trees
* MEMORY tables also support hash indexes
* InnoDB uses inverted lists for FULLTEXT indexes
* Unnecessary indexes waste space and waste time for MySQL to determine which indexes to use
* Indexes also add to the cost of inserts, updates, and deletes because each index must be updated
* You must find the right balance to achieve fast queries using the optimal set of indexes.

MySQL uses indexes for these operations:

* To find the rows matching a WHERE clause quickly
* To eliminate rows from consideration
	* use the most selective index among multi indexes
* Any leftmost prefix of a multi-column index can be used by the optimizer
* To retrieve rows from other tables when performing joins.
* To find the MIN() OR MAX() value for a specific indexed column
* To sort or group a table if the sorting or grouping is done on a leftmost prefix of a usable index
* In some cases, a query can be optimized to retrieve values without consulting the data rows

```sql
create index idx_name on table_name (col1, col2, ...);
```

There are several types of index in MySQL:

* Tree Index
	* B-Trees
    * FULLTEXT index (based on words instead of whole columns)
        * FULLTEXT index implementation is storage engine dependent.
	* B+ Trees (InnoDB)
	* T-Trees (NDB)
	* Red-black trees (MEMORY)
	* R-Trees (MyISAM, spatial index)
        * R-trees are tree data structures used for spatial access methods, i.e., for indexing multi-dimensional information such as geographical coordinates, rectangles or polygons.
        * the "R" in R-tree is for rectangle.
        * `GEOMETRY`, range search
        * Spatial indexes are implemented as R-tree indexes.
        * Two standard spatial data formats are used to represent geometry objects in queries:
            * Well-Known Text (WKT) format
            * Well-Known Binary (WKB) format
        * Internally, MySQL stores geometry values in a format that is not identical to either WKT or WKB format.
* Hash index (MEMORY and NDB)

For MyISAM and (as of MySQL 5.7.5) InnoDB tables, search operations in columns containing spatial data can be optimized using SPATIAL indexes. The most typical operations are:

* Point queries that search for all objects that contain a given point
* Region queries that search for all objects that overlap a given region

MySQL uses **R-Trees with quadratic splitting** for SPATIAL indexes on spatial columns. A SPATIAL index is built using the minimum bounding rectangle (MBR) of a geometry. For most geometries, the MBR is a minimum rectangle that surrounds the geometries. For a horizontal or a vertical linestring, the MBR is a rectangle degenerated into the linestring. For a point, the MBR is a rectangle degenerated into the point.

```sql
CREATE TABLE geom (g GEOMETRY NOT NULL, SPATIAL INDEX(g)) ENGINE=MyISAM;
-- or
ALTER TABLE geom ADD SPATIAL INDEX(g);
-- or
REATE SPATIAL INDEX sp_index ON geom (g);
SET @poly =
    -> 'Polygon((30000 15000,
                 31000 15000,
                 31000 16000,
                 30000 16000,
                 30000 15000))';
SELECT fid,ST_AsText(g) FROM geom WHERE
    MBRContains(ST_GeomFromText(@poly),g);
```

cardinality
: a property which affects the ability to cluster, sort and search data. It is therefore an important measurement for the query planners in DBs, it is a heuristic which they can use to choose the best plans.

* Max cardinality: All values are unique
* Min cardinality: All values are the same

Index can help speeding up most queries, but can lead slower writing with each added index.

* an index on the whole column is not always necessary
	* index just a prefix of a column
	* prefix indexes take less space and the operation are faster as a result
* compsite indexes can be used for searches on the first column(s) in the index
* minimize the size of PRIMARY KEY(s) that are used as references in other tables
	* using an auto_increment column can be more optimal
* A FULLTEXT index is used for
	* word searches in text
	* searches on serveral columns

#### Index Condition Pushdown Optimization

* ICP is used for the range, ref, eq_ref and ref_or_null
* ICP is used only for secondary indexes for InnoDB tables
* The goal of ICP is to reduce the number of full-record reads and thereby reduce IO operations
* For InnoDB clusted indexes, the complete record is already read into the InnoDB buffer, Using ICP in this case does not reduce IO
* The ICP optimization is not supported with secondary indexes created on generated virtual columns

### InnoDB-Specific Optimization

InnoDB uses clustered index, so the length of PRIMARY KEY is extremely important.

The rows are always dynamic, using VARCHAR instead of CHAR is almost always better.

Maintenance operations needed after many UPDATE/DELETE operations, cause the pages can become underfilled.

InnoDB automatically extends each secondary index by appending the primary key columns to it.

* Use BTREE (Red-black binary tree) index when
	* key duplication is high
	* need range searches
* set a size limit for your memory tables
	* with --max_heap_table_size
* remove unused memory
	* TRUNCATE TABLE to completely remove the contents of the table
	* A null ALTER TABLE to free up deleted rows

## Transaction Optimization

optimize slow queries the transaction runs

## Query Optimization

### Query Cache

### Prepared Statements

>
* Less overhead for parsing the statement each time it is executed. Typically, database applications process large volumes of almost-identical statements, with only changes to literal or variable values in clauses such as WHERE for queries and deletes, SET for updates, and VALUES for inserts.
* Protection against SQL injection attacks. The parameter values can contain unescaped SQL quote and delimiter characters.

### Query Rewrites

Query rewrites can be used to force index on some search.

Query rewrites can in placed in two points:

* pre-parse
* post-parse (more efficient)

Source Code

* mysql-5.7.11/plugin/rewriter
* mysql-5.7.11/plugin/rewrite_example

## Conclusion

* It is Application Performance what Matters
* Use Right tools for right job
* See what queries MySQL is Running
* Reduce Number of Queries
* Reduce Data They Return
* See how they can do less work
* Do that work more efficiently

### Notes

* Do not run with defaults
* Do not ever obsess with tuning

## References

* [MySQL Tips](http://www.artfulsoftware.com/infotree/mysqltips.php)
* [dimitrik's blog](http://dimitrik.free.fr/blog/)
* [BASIC MYSQL PERFORMANCE TUNING](https://mediatemple.net/community/products/dv/204404044/making-it-better:-basic-mysql-performance-tuning-)
* [tunning primer](https://launchpadlibrarian.net/78745738/tuning-primer.sh)
* [SQL Syntax for Prepared Statements](http://dev.mysql.com/doc/refman/5.7/en/sql-syntax-prepared-statements.html)
* [Tuning InnoDB Concurrency Tickets](https://www.percona.com/blog/2010/05/24/tuning-innodb-concurrency-tickets/)
* [Optimizing Spatial Analysis](http://dev.mysql.com/doc/refman/5.7/en/optimizing-spatial-analysis.html)
* [https://en.wikipedia.org/wiki/R-tree](https://en.wikipedia.org/wiki/R-tree)

[Compression]: https://dev.mysql.com/doc/internals/en/compression.html
[Difference between TCP_CORK and TCP_NODELAY]: http://stackoverflow.com/questions/22124098/is-there-any-significant-difference-between-tcp-cork-and-tcp-nodelay-in-this-use
[Connector J Configure]: https://dev.mysql.com/doc/connector-j/5.1/en/connector-j-reference-configuration-properties.html
[Performance Tuning]: {% post_url 2016-05-03-performance-tuning %}
[MySQL Primer - Up and Running]: {% post_url 2014-09-23-mysql-primer-up-and-running %}
