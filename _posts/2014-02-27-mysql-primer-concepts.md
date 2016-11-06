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

#### Next-Key Locks

Information_schema:

* INNODB_TRX
* INNODB_LOCKS
* INNODB_LOCK_WAITS

#### Insert Intention Locks

#### AUTO-INC Locks

#### Predicate Locks for Spatial Indexes

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

When the index used in query has unique props, InnoDB Engine downgrade Next-Key Lock to Record Lock to improve performance.

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

* 1 NF
* 2 NF
* 3 NF

## References

* [Internal Locking Methods](http://dev.mysql.com/doc/refman/5.7/en/internal-locking.html)
* [Phantom Rows](http://dev.mysql.com/doc/refman/5.7/en/innodb-next-key-locking.html)
