---
layout: post
title: MySQL Primer - Query Optimization
date: 2016-05-24 23:12:18.000000000 +08:00
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

This article describes query optimization.

This article is intend for

* Application Designer/Developer
* Database/System Administrator

<!--more-->

## Table Of Contents

* TOC
{:toc}

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

### SELECT

* SQL_SMALL_RESULT
* SQL_BIG_RESULT
* SQL_BUFFER_RESULT
* SQL_CACHE
* SQL_NO_CACHE

#### Overview

* Add index appropriatly
* Optimize sub-query
* Minimize the number of full table scans
* Keep table statistics up to date by using `ANALYZE TABLE` stmt **periodically**
* Optimizing InnoDB Queries
	* specify an efficient primary key
	* do not specify too many or too long columns in the primary key
	* do not create a separate secondary index for each column
		* try to create a small number of concatenated indexes instead
		* with a covering index the query might be able to avoid reading the table data at all
	* declare column `NOT NULL` if appropriate
	* Optimizing InnoDB Read-Only Transactions
		* The transaction is started with the START TRANSACTION READ ONLY statement
		* The autocommit setting is turned on, so that the transaction is guaranteed to be a single statement, and the single statement making up the transaction is a “non-locking” SELECT statement
			* NO `SELECT FOR UPDATE`
			* NO `LOCK IN SHARED MODE`
	* Use Query Cache
* Avoid transforming the query in ways that make it hard to understand, especially if the optimizer does some of the same transformations automatically
* Adjust the size and properties of the memory areas that MySQL uses for caching
* Even for a query that runs fast using the cache memory areas, you might still optimize further so that they require less cache memory, making your application more scalable
* Deal with locking issues, where the speed of your query might be affected by other sessions accessing the tables at the same time

>
MySQL Cluster supports a join pushdown optimization whereby a qualifying join is sent in its entirety to MySQL Cluster data nodes, where it can be distributed among them and executed in parallel. For more information about this optimization, see [Conditions for NDB pushdown joins](https://dev.mysql.com/doc/refman/5.6/en/mysql-cluster-options-variables.html#ndb_join_pushdown-conditions)

#### WHERE

* Removal of unnecessary parentheses
* Constant folding
* Constant condition removal (needed because of constant folding)
* Constant expressions used by indexes are evaluated only once
* `COUNT(*)` on a single table without a `WHERE` is retrieved directly from the table information for MyISAM and MEMORY tables. This is also done for any `NOT NULL` expression when used with only one table
* Early detection of invalid constant expressions.
* `HAVING` is merged with `WHERE` if you do not use `GROUP BY` or aggregate functions (`COUNT()`, `MIN()`, and so on)
* For each table in a join, a simpler `WHERE` is constructed to get a fast `WHERE` evaluation for the table and also to skip rows as soon as possible
* All constant tables are read first before any other tables in the query. A constant table is any of the following:
	* An empty table or a table with one row
	* A table that is used with a `WHERE` clause on a `PRIMARY KEY` or a `UNIQUE` index, where all index parts are compared to constant expressions and are defined as NOT NULL
* The best join combination for joining the tables is found by trying all possibilities
	*  If all columns in ORDER BY and GROUP BY clauses come from the same table, that table is preferred first when joining
* If there is an ORDER BY clause and a different GROUP BY clause, or if the ORDER BY or GROUP BY contains columns from tables other than the first table in the join queue, a temporary table is created
* If you use the SQL_SMALL_RESULT option, MySQL uses an in-memory temporary table
* Each table index is queried, and the best index is used unless the optimizer believes that it is more efficient to use a table scan
* In some cases, MySQL can read rows from the index without even consulting the data file
* Before each row is output, those that do not match the HAVING clause are skipped

#### Range Optimization

#### ORDER BY

Eliminate unneeded sorting overhead by specifying `ORDER BY NULL`

In some cases, MySQL can use an index to satisfy an ORDER BY clause without doing extra sorting.

quicksort -> merge

two version of filesort algorithms

sort buffer consists of pairs of values:

* (sort key value : row ID) read row twice
* (sort key value : columns referenced by the query) read row only once

@@max_length_for_sort_data := 1024

>
The tuples used by the modified filesort algorithm are longer than the pairs used by the original algorithm, and fewer of them fit in the sort buffer. As a result, it is possible for the extra I/O to make the modified approach slower, not faster. To avoid a slowdown, the optimizer uses the modified algorithm only if the total size of the extra columns in the sort tuple does not exceed the value of the max_length_for_sort_data system variable. (A symptom of setting the value of this variable too high is a combination of high disk activity and low CPU activity.)

@@max_sort_length := 1024

>
The server uses only the first max_sort_length bytes of each value and ignores the rest. Consequently, values that differ only after the first max_sort_length bytes compare as equal for GROUP BY, ORDER BY, and DISTINCT operations.

* sort_buffer_size
* read_rnd_buffer_size

```sql
show global status like '%sort%';
```

Change the tmpdir system variable to point to a dedicated file system with large amounts of free space

### GROUP BY

* Use indexes
	* all GROUP BY columns reference attributes from the same index
	* and that the index stores its keys in order (for example, this is a BTREE index and not a HASH index)

There are two ways to execute a GROUP BY query through index access:

* Loose Index Scan

	This access method considers only a fraction of the keys in an index

* Tight Index Scan

### JOIN

* INNER JOIN
* LEFT JOIN
* RIGHT JOIN

### Where

## DML (Data Manipulation Language) Optimization

### INSERT

Costs:

* rows
* indexes

Optimizations:

* merge or separate insert operations
	* bulk_insert_buffer_size
* LOAD DATA INFILE
	* 20 times faster
* emit default values to eliminate needed parse operations

### UPDATE

An update statement is optimized like a SELECT query with the additional overhead of a write

* do multi updates if there is locking
* OPTIMIZE TABLE

### DELETE

TRUNCATE TABLE is faster, but not transaction-safe

## References

