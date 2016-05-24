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

This article described some basic usage of mysql server and introduce intermediate MySQL internals.

<!--more-->

## Table Of Contents

* TOC
{:toc}

## Transaction

**ACID**

* atomicity
* consistency
* isolution
* durability

**Isolation Level**

* REPEATABLE READ (default)
* READ COMMITTED
* READ UNCOMMITTED
* SERIALIZABLE

## Type

* OLTP (Online Transaction Processing)

	Large number of short online transactions (INSERT, UPDATE, DELETE). Measured by transactions per second.

* OLAP (Online Analytical Processing)

	Low volume of transactions. Queries are often complex and involve aggregations. Response time is an effectiveness measurement.

