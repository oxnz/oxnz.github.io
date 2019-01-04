---
layout: post
title: MySQL Primer - Develop Rules
date: 2016-06-13 18:42:00.000000000 +08:00
type: post
published: true
status: publish
categories:
- database
- MySQL
- sysadm
- dev
tags:
- MySQL
---

## Introduction

This article described some basic rules in developing involed with MySQL Server. This is intend to help the developers and sysadms.

<!--more-->

## Table Of Contents

* TOC
{:toc}

## Basic Rules

* Use InnoDB engine
* Use UTF8 encoding
* Comments are needed for all tables
* Do not exceed 5000w records per table
* Do not store large data such as pic, file, etc
* Do not benchmark an online server
* Do not connect online server from prod/test env

## Naming Rules

### Database/Table Naming Rules

* Unifined database/table name (no more than 32 chars)
* Meaningful names
* Do not use reserved MySQL keywords
* Temporary database/table name begin with `tmp_`, end with date
* Backup database/table begin with `bkp_`, end with date

### Index Naming Rules

* non-unique index with format: `idx_field1_field2`
* unique index with format: `uniq_field1_field2`
* lowercase

## Database/Table/Field Design Rules

### Database/Table Rules

* DO NOT use partition table
	* RANGE
	* LIST
	* HASH
	* KEY
* Separate data by frequency (hot/cold data)
* Use appropriate table slice strategy

### Field Rules

Type      | Bytes | Min/Max/Unsigned Max
|---------|-------:--------------------|
tinyint   | 1     | -128/127/255
smallint  | 2     | -32768/32767/65535
mediumint | 3     | -8388608/-8388607/16777215
int       | 4     | -2147483648/2147483647/4294967295
bigint    | 8     | -9223372036854775808/9223372036854775807/18446744073709551615

* The simpler, the better
	* Use TINYINT instead of ENUM
	* Use number instead of string
	* Use INT UNSIGNED for IPV4 addr
	* Use UNSIGNED to store non-negtive num
	* Use VARBINARY for case-sensitive varaible length string
	* Use DECIMAL instead of FLOAT/DOUBLE for precision float
* Do not use TEXT/BLOB if possible, split table if TEXT/BLOB is needed
* Use TIMESTAMP to store time
* DO NOT store plain password
* Use NOT NULL if possible, because NULL field is
	* hard to optimize
	* need more space for index
	* invalidate compsite index
* Store file path other than the file itsself

## Index Rules

* Limit number of indexes
	* no more than 5 indexes per table
	* no more than 5 fields per index
	* prefix length within 8 chars
* consider prefix index first
* consider add persedo column and index it
* Primary key
	* DO NOT use column which are updated frequently
	* DO NOT use string if possible
	* DO NOT use UUID/MD5/HASH as primary key (too sparse)
	* Use NOT NULL UNIQUE as primary key by default
	* It is recommend to use auto_increment
* Key SQL must be indexed
	* Where conditions of UPDATE/DELETE
	* Fields of ORDER BY/GROUP By/DISTINCT
* Join
	* Put Field which has max cardinality first
	* Consider cover index for key SQL
	* Avoid redudency and repeated index
	* Index considerations
		* Data density
		* Query/Update percentage
* DO NOT
	* create index on column with low cardinality, like gender
	* use function or math eval on index column
* DO NOT use reference key if possible
	* Reference key is used to protect integrety, which can be achieved at the business end
* NOT NULL by default for index columns
* Use unique index if possible
* Devloper use explain regularlly, and learn to use hint

## SQL Rules

* As simple as possible
* Split complex SQL to small ones
	* to full utlize QUERY CACHE and multi-core
* Transaction need to stay simple, do not use too much time
* Avoid trigger/func/procedure
* Lower coupling, leave room for scale out/sharding
* Do not do math in MySQL, which MySQL is not good at
* DO NOT use select *, specify fields needed
* OR -> IN
* IN -> EXIST
* no more than 1000 elems in IN()
* LIMIT
	* select id from t limit 10000, 10; => select id from t where id > 10000 limit 10;
* use union all instead of union
* Avoid join large tables
* Use group by, auto order
* Use prepared statements
	* only params needed
	* once compiled, multiple use
	* lower possibility of SQL injection
* DO NOT use order by rand()
* DO NOT update multiple tables within one statements
* DO NOT run large query
* DO NOT use NOT IN/LIKE query
* Pagination query
* DO NOT use implicity conversion, like select id from t where id = '1';
* uppercase keywords in SQL, space separated
* Use perf tools
	* explain
	* show profile
	* mysqlslap
* reduce interaction times with MySQL
* DO NOT use preceding '%' in LIKE condition

## Procedure Rules

* Database/Table creation/modification need usage info (related SQLs)
* All indexes are determined before online
* Data import/export need DBA watching
* No super privileges for app account
* Do not do batch update/query under heavy load time
* Promotion Activites need DBA assessment
* Do not run admin/statistics query from backend

## Usage

### INSERT

>
With ON DUPLICATE KEY UPDATE, the affected-rows value per row is 1 if the row is inserted as a new row, 2 if an existing row is updated, and 0 if an existing row is set to its current values. If you specify the CLIENT_FOUND_ROWS flag to mysql_real_connect() when connecting to mysqld, the affected-rows value is 1 (not 0) if an existing row is set to its current values.

```sql
INSERT INTO table (a,b,c) VALUES (1,2,3) ON DUPLICATE KEY UPDATE c=c+1;
```

## References
