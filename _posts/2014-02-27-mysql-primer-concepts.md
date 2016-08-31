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

![Exec Procedure](/assets/mysql-exec-proc.png)

## Lock

MySQL has two kins of locks: lock and latch.

### lock

The taget of lock is transaction.

### latch

```sql
SHOW ENGINE innodb MUTEX;
```

* mutex
* rwlock

There is no deadlock detection mechanism. Its target is thread, to protect critical resource.

### InnoDB row-level lock

* S Lock
* X Lock

Lock compatible issue.

Intention Lock
: used to indication the lock type of next request.

* IS Lock
* IX Lock

Intention Lock will not block no request but full table scan, because InnoDB support row-level lock.

Information_schema:

* INNODB_TRX
* INNODB_LOCKS
* INNODB_LOCK_WAITS

### Consistent Nonlocking Read

InnoDB Engine read data through multi versioning control method (by reading undo field), extrememly performance improvement.

## MVCC

MVCC
: Multi Version Concurrency Control

There may be more than one snapshot of the data.

Under specific isolation levels (READ COMMITED, REPEATABLE READ), InnoDB use consistent nonlocking read.

Snapshot has different means under different isolation levels:

* READ COMMITED
: consistent nonlocking read always read the locked row's newest snapshot
* REPEATABLE READ
: always read row data after the transaction begins.

# Consistent Locking Read

InnoDB support two types of consistent locking read for SELECT:

* SELECT ... FOR UPDATE (X LOCK)
* SELECT ... LOCK IN SHARE MODE (S LOCK)

The abovet two stmts must be in a transaction, cause in that way, the lock is released after the transaction is commited. Thus, using above stmts, transaction must prefixed with BEGIN, START TRANSACTION or SET AUTOCOMMIT = 0.

### AUTO_INC & Locking

AUTO_INC Locking is a special table lock mechanism, and is released after the insert SQL is finished. (prior to 5.1.22)

innodb_autoinc_lock_mode: use mutex to increment, but may lead to master-slave sync probs.

Auto incremental column must be index column or the first column of an index.

### Row Lock

There are 3 types of row locking algorithms in InnoDB Engine:

* Record Lock
* Gap Lock
* Next_Key Lock
: (Gap Lock + Record Lock) Lock a range (includes record itself)

Next_Key Locking is used to address the phantom problem.

When the index used in query has unique props, InnoDB Engine downgrade Next_Key Lock to Record Lock to improve performance.

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

### Problems

* Dirty Read
* Unrepeatable Read
	* Result record differs from previous read under the same condition
* Phantom Read
	* Result record count differs from previous read under the same condition

Isolation Level | Dirty Read | Unrepeatable Read | Phantom Read
|---------------:------------|-------------------|---------------|
SERIALIZABLE    | NO         | NO                | NO
REPEATABLE READ | NO         | NO                | YES
READ COMMITTED  | NO         | YES               | YES
READ UNCOMMITTED| YES        | YES               | YES

## Type

* OLTP (Online Transaction Processing)

	Large number of short online transactions (INSERT, UPDATE, DELETE). Measured by transactions per second.

* OLAP (Online Analytical Processing)

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
FOR EACH ROW PRECeDES ins_sum
SET
@doposits = @doposits + IF(NEW.amount > 0, NEW.amount, 0),
@withdrawls = @withdrawls + IF(NEW.amount > 0, -NEW.amount, 0);
```

## Procedure

```sql
CREATE PROCeDURE dorepeat(p INT)
BEGIN
	set @x = 0;
	REPEAT
		set @x = @x + 1;
		UNTIL @x > p
	END REPEAT;
END;
call dorepeat(100);
```
