---
layout: post
title: MySQL Primer - Concepts
date: 2014-02-27 15:22:18.000000000 +08:00
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

## Exec Procedure

```
Client ---------------> Server
  ^                       |
  |                       | Parse
  |          Exec         v
Result <------------- Exec Plan
```

## Locking

MySQL has two kinds of locks: lock and latch.

type      |                lock |    latch
----------|---------------------|----------------
target    | transaction         | thread
protect   | database content    | memory data structure
duration  | whole transaction   | critical resource
type      | row-lock, table-lock, intention-lock | rwlock, mutex
dead-lock | deadlock detection through waits-for graph, timeout machanism | no deadlock detection, through lock leveling ensure no deadlock
exists    | Lock Manager's Hash Table | whole data structure

### lock

The taget of lock is transaction.

### latch

In MySQL and InnoDB, multiple threads of execution access shared data structures.
InnoDB synchronizes these accesses with its own implementation of **mutexes** and **read/write locks**.
Historically, InnoDB protected the internal state of a read/write lock with an InnoDB mutex, and the internal state of an InnoDB mutex was protected by a Pthreads mutex, as in IEEE Std 1003.1c (POSIX.1c).

On platforms that support Atomic operations, InnoDB now implements mutexes and read/write locks with the built-in functions provided by the GNU Compiler Collection (GCC) for atomic memory access instead of using the Pthreads approach.

* mutex
* rwlock

There is no deadlock detection mechanism. Its target is thread, to protect critical resource.

```sql
SHOW ENGINE innodb MUTEX;
```

### InnoDB Locking

#### Shared and Exclusive Locks (row-level locks)

* shared(S) locks
: permits the transaction that holds the lock to read a row
* exclusive(X) locks
: permits the transaction that holds the lock to update or delete a row

Lock compatible issue.

#### Intention Locks

InnoDB supports **multiple granularity locking** which permits coexistence of row-level locks and locks on entire tables.
To make locking at multiple granularity levels practical, additional types of locks called intention locks are used.
Intention locks are table-level locks in InnoDB that indicate which type of lock (shared or exclusive) a transaction will require later for a row in that table.

Intention Lock
: used to indication the lock type of next request.

* Intention shared (IS) Lock
    * `SELECT ... LOCK IN SHARE MODE`
* Intention exclusive(IX) Lock
    * `SELECT ... FOR UPDATE`

The intention locking protocol is as follows:

* Before a transaction can acquire an S lock on a row in table t, it must first acquire an IS or stronger lock on t.
* Before a transaction can acquire an X lock on a row, it must first acquire an IX lock on t.

Intention Lock will not block no request but full table scan (e.g. `LOCK TABLES ... WRITE`), because InnoDB support row-level lock.

#### Record Locks

#### Gap Locks

```SQL
SELECT c1 FROM t WHERE c1 BETWEEN 10 and 20 FOR UPDATE;
```

##### Insert Intention Locks

A type of gap lock called an insert intention gap lock is set by INSERT operations prior to row insertion.

An insert intention lock signals the intent to insert in such a way that multiple transactions inserting into the same index gap need not wait for each other if they are not inserting at the same position within the gap. Suppose that there are index records with values of 4 and 7. Separate transactions that attempt to insert values of 5 and 6, respectively, both lock the gap between 4 and 7 with insert intention locks prior to obtaining the exclusive lock on the inserted row, but do not block each other because the rows are nonconflicting.

#### Next-Key Locks

Information_schema:

* INNODB_TRX
* INNODB_LOCKS
* INNODB_LOCK_WAITS

#### AUTO-INC Locks

#### Predicate Locks for Spatial Indexes

>
To handle locking for operations involving SPATIAL indexes, next-key locking does not work well to support REPEATABLE READ or SERIALIZABLE transaction isolation levels. There is no absolute ordering concept in multidimensional data, so it is not clear which is the “next” key.
>
To enable support of isolation levels for tables with SPATIAL indexes, InnoDB uses predicate locks. A SPATIAL index contains minimum bounding rectangle (MBR) values, so InnoDB enforces consistent read on the index by setting a predicate lock on the MBR value used for a query. Other transactions cannot insert or modify a row that would match the query condition.

>
For MyISAM and (as of MySQL 5.7.5) InnoDB tables, MySQL can create spatial indexes using syntax similar to that for creating regular indexes, but using the SPATIAL keyword. Columns in spatial indexes must be declared NOT NULL.

```sql
CREATE TABLE geom (g GEOMETRY NOT NULL, SPATIAL INDEX(g)) ENGINE=MyISAM;
```

>
SPATIAL INDEX creates an R-tree index. For storage engines that support nonspatial indexing of spatial columns, the engine creates a B-tree index. A B-tree index on spatial values is useful for exact-value lookups, but not for range scans.

### Consistent Nonlocking Read

InnoDB Engine read data through multi versioning control method (by reading undo field), extrememly performance improvement.

### Internal Locking Methods

Generally, table locks are superior to row-level locks in the following cases:

* Most stmts for the table are reads
* Stmts for the table are a mix of reads and writes, where writes are updates or deletes for a single row that can be fetched with one key read
	* `UPDATE tbl_name SET column = value WHERE unique_key_col = key_value;`
	* `DELETE FROM tbl_name WHERE unique_key_col = key_value;`
* SELECT combined with concurrent INSERT stmts, and very few UPDATE or DELETE stmts
* Many scans or `GROUP BY` operations on the entire table without any writers

With higher-level locks, you can more easily tune applications by supporting locks of different types, because the lock overhead is less than for row-level locks.

Options other than row-level locking:

* Versioning
* Copy on demands
* Application-level locks

### Optimistic Locking v.s. Pessimistic Locking

#### Pessimistic Concurrency Control (PCC)

>
A user who reads a record, with the intention of updating it, places an exclusive lock on the record to prevent other users from manipulating it. This means no one else can manipulate that record until the user releases the lock. The downside is that users can be locked out for a very long time, thereby slowing the overall system response and causing frustration.
>
Where to use pessimistic locking: this is **mainly used in environments where data-contention (the degree of users request to the database system at any one time) is heavy**; where the cost of protecting data through locks is less than the cost of rolling back transactions, if concurrency conflicts occur. Pessimistic concurrency is best implemented when lock times will be short, as in programmatic processing of records. Pessimistic concurrency requires a persistent connection to the database and is not a scalable option when users are interacting with data, because records might be locked for relatively large periods of time. It is not appropriate for use in Web application development.

#### Optimistic Concurrency Control (OCC)

>
**OCC is generally used in environments with low data contention**.
When conflicts are rare, transactions can complete without the expense of managing locks and without having transactions wait for other transactions' locks to clear, leading to higher throughput than other concurrency control methods.
However, if contention for data resources is frequent, the cost of repeatedly restarting transactions hurts performance significantly; it is commonly thought that other concurrency control methods have better performance under these conditions.
However, locking-based ("pessimistic") methods also can deliver poor performance because locking can drastically limit effective concurrency even when deadlocks are avoided.

The point is that Optimistic Locking is not a database feature, not for MySQL nor for others: **optimistic locking is a practice that is applied using the DB with standard instructions**.

The NO-LOCKING way:

```sql
SELECT id, oval1, oval2 from table WHERE ID=@id;
// evaluate new values
UPDATE table SET var1=@nval1, var2=@nval2
WHERE ID=@id;
```

The OPTIMISTIC LOCKING way is:

```sql
SELECT id, oval1, oval2 from table WHERE ID=@id;
// evaluate new values
UPDATE table SET var1=@nval1, var2=@nval2 WHERE ID=@id
AND val1=@oval1, val2=@oval2;
if affected-rows == 1; then
    // go on
else
    // go bad
endif
```

Transactional way:

```sql
SELECT id, oval1, oval2 from table WHERE ID=@id;
// evaluate new values
BEGIN TRANSACTION;
UPDATE trans_table SET var1=@nval1, var2=@nval2 WHERE ID=@id;
UPDATE table SET var1=@nval1, var2=@nval2 WHERE ID=@id
AND val1=@oval1, val2=@oval2;
if affected-rows == 1; then
    COMMIT TRANSACTION;
    // go on
else
    ROLLBACK TRANSACTION;
    // go bad
endif
```

The VERSIONING OPTIMISTIC LOCKING option:

```sql
SELECT id, val1, val2, version FROM table WHERE id = @id;
// code that calculates new values
UPDATE table SET val1 = @nval1, val2 = @nval2, version = version + 1
WHERE id=@id AND version = @oversion;
if AffectedRows == 1; then
    // go on with your other code
else
    // decide what to do since it has gone bad... in your code
endif
```

## MVCC

```
-------------
| SQL Query |
-------------
     |
-----|-----
|    |----|------------
-----------           |
-----v-----    -------v---------    -------------------
| XLocked | -> | Snapshot Data | -> | Snapshot Data 2 |
-----------    -------|---------    -------------------
-----------           v
|    .----|------------
-----v-----
```

MVCC
: Multi Version Concurrency Control

There may be more than one snapshot of the data.

Under specific isolation levels (READ COMMITED, REPEATABLE READ), InnoDB use consistent nonlocking read.

Snapshot has different means under different isolation levels:

* READ COMMITED
: consistent nonlocking read always read the locked row's newest snapshot
* REPEATABLE READ
: always read row data after the transaction begins.

## Consistent Locking Read

InnoDB support two types of consistent locking read for SELECT:

* `SELECT ... FOR UPDATE (X LOCK)`
* `SELECT ... LOCK IN SHARE MODE (S LOCK)`

The abovet two stmts must be in a transaction, cause in that way, the lock is released after the transaction is commited.
Thus, using above stmts, transaction must prefixed with `BEGIN`, `START TRANSACTION` or `SET AUTOCOMMIT = 0`.

### AUTO-INC & Locking

An `AUTO-INC` lock is a special table-level lock taken by transactions inserting into tables with AUTO_INCREMENT columns.
AUTO-INC Locking is a special table lock mechanism, and is released after the insert SQL is finished. (prior to 5.1.22)

`innodb_autoinc_lock_mode`: use mutex to increment, but may lead to master-slave sync probs.

Auto incremental column must be index column or the first column of an index.

### Row Lock

There are 3 types of row locking algorithms in InnoDB Engine:

* Record Lock
* Gap Lock
* Next-Key Lock
: (Gap Lock + Record Lock) Lock a range (includes record itself)

Next-Key Locking is used to address the phantom problem.

By default, InnoDB operates in `REPEATABLE READ` transaction isolation level.
In this case, InnoDB uses next-key locks for searches and index scans, which prevents phantom rows.

When the index used in query has unique props, InnoDB Engine **downgrade** Next-Key Lock to Record Lock to improve performance.

## Transaction

**ACID**

* atomicity
* consistency
* isolution
* durability

**Isolation Level**

* READ UNCOMMITTED
: Low isolation, high concurrency
* READ COMMITTED
: Lock rows are current reading
* REPEATABLE READ (default)
: Lock all rows need reading
* SERIALIZABLE
: Lock Table

```sql
SET [SESSION | GLOBAL] TRANSACTION ISOLATION LEVEL [READ UNCOMMITTED | READ COMMITTED | REPEATABLE READ | SERIALIZABLE]
SELECT @@global.tx_isolation;
SELECT @@session.tx_isolation;
SELECT @@tx_isolation;
```

### Problems

* Dirty Read
* Unrepeatable Read
: Result record differs from previous read under the same condition
* Phantom Read
: The so-called phantom problem occurs within a transaction when the same query produces different sets of rows at different times.

Isolation Level | Dirty Read | Unrepeatable Read | Phantom Read
|---------------:------------|-------------------|---------------|
SERIALIZABLE    | NO         | NO                | NO
REPEATABLE READ | NO         | NO                | YES
READ COMMITTED  | NO         | YES               | YES
READ UNCOMMITTED| YES        | YES               | YES

## Type

* OLTP
: (Online Transaction Processing)

	Large number of short online transactions (INSERT, UPDATE, DELETE). Measured by transactions per second.

* OLAP
: (Online Analytical Processing)

	Low volume of transactions. Queries are often complex and involve aggregations. Response time is an effectiveness measurement.

## View

Views are stored queries that produce a result set when invoked. A view act as a virtual table.

MySQL support:

* views
* updatable views
* insertable views

Example

```sql
CREATE VIEW v as SELECT qty, price, qty*price AS value FROM t;
```

## Event Scheduler

```sql
GRANT EVENT ON myschema.* TO will@localhost;
CREATE EVENT e_store_ts ON SCHEDULE EVERY 10 SECOND
DO
INSERT INTO myschema.mytable VALUES(UNIX_TIMESTAMP());
```

## Trigger

A trigger is a named database object that is associated with a table, and that activates when a particular event occurs for that table.

```sql
CREATE TRIGGER ins_trx BEFORE INSERT ON account
FOR EACH ROW PRECEDES ins_sum
SET
@doposits = @doposits + IF(NEW.amount > 0, NEW.amount, 0),
@withdrawls = @withdrawls + IF(NEW.amount > 0, -NEW.amount, 0);
```

## Procedure

```sql
CREATE PROCEDURE dorepeat(p INT)
BEGIN
    set @x = 0;
    REPEAT
        set @x = @x + 1;
        UNTIL @x > p
    END REPEAT;
END;
call dorepeat(100);
```

## Normal Format

### First normal form

>
First normal form (1NF) is a property of a relation in a relational database. A relation is in first normal form if and only if the domain of each attribute contains only atomic (indivisible) values, and the value of each attribute contains only a single value from that domain.
>
First normal form enforces these criteria:
>
* Eliminate repeating groups in individual tables.
* Create a separate table for each set of related data.
* Identify each set of related data with a primary key

### Second normal form

>
a table is in 2NF if it is in 1NF and no non-prime attribute is dependent on any proper subset of any candidate key of the table. A non-prime attribute of a table is an attribute that is not a part of any candidate key of the table.
>
Put simply, a table is in 2NF if it is in 1NF and every non-prime attribute of the table is dependent on the whole of every candidate key.

### Third normal form

>
Third normal form is a normal form that is used in normalizing a database design to **reduce the duplication of data** and **ensure referential integrity** by ensuring that
>
1. the entity is in second normal form, and
2. all the attributes in a table are determined only by the candidate keys of that table and not by any non-prime attributes.

## Index

Storage Engine | Permissible Index Types
InnoDB | BTREE
MyISAM | BTREE
MEMORY/HEAP | HASH, BTREE
NDB | HASH, BTREE

Full-text index implementation is storage engine dependent. Spatial indexes are implemented as R-tree indexes.

### Clustered and Secondary Indexes

Every InnoDB table has a special index called the **clustered index** where the data for the rows is stored.
Typically, the clustered index is synonymous with the primary key.

* When you define a `PRIMARY KEY` on your table, InnoDB uses it as the clustered index. 
* If you do not define a `PRIMARY KEY` for your table, MySQL locates the first `UNIQUE` index where all the key columns are `NOT NULL` and InnoDB uses it as the clustered index.
* If the table has no `PRIMARY KEY` or suitable `UNIQUE` index, InnoDB internally generates a hidden clustered index on a synthetic column containing row ID values.
    * The rows are ordered by the ID that InnoDB assigns to the rows in such a table.
    * The row ID is a 6-byte field that **increases monotonically as new rows are inserted**.
    * Thus, the rows ordered by the row ID are **physically in insertion order**.

Accessing a row through the clustered index is fast because the index search leads directly to the page with all the row data.
MyISAM uses one file for data rows and another for index records.

All indexes other than the clustered index are known as secondary indexes.
In InnoDB, each record in a secondary index contains the primary key columns for the row, as well as the columns specified for the secondary index.
InnoDB uses this primary key value to search for the row in the clustered index.

If the primary key is long, the secondary indexes use more space, so it is advantageous to have a short primary key.

## References

* [Internal Locking Methods](http://dev.mysql.com/doc/refman/5.7/en/internal-locking.html)
* [Phantom Rows](http://dev.mysql.com/doc/refman/5.7/en/innodb-next-key-locking.html)
* [Lock (computer science)](https://en.wikipedia.org/wiki/Lock_(computer_science))
* [Third normal form](https://en.wikipedia.org/wiki/Third_normal_form)
* [CREATE INDEX Syntax](http://dev.mysql.com/doc/refman/5.7/en/create-index.html)
* [Clustered and Secondary Indexes](https://dev.mysql.com/doc/refman/5.7/en/innodb-index-types.html)
* [https://docs.oracle.com/cd/E17952_01/mysql-5.1-en/innodb-record-level-locks.html](https://docs.oracle.com/cd/E17952_01/mysql-5.1-en/innodb-record-level-locks.html)
