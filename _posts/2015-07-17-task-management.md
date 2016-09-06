---
title: Task Management
categories: [sysadm]
tags: [cron, at]
---

## Introduction

Cron & at

<!--more-->


## Automating Tasks

### cron

* environment variables
	* SHELL
	* PATH
	* MAILTO
	* HOME

### anacron

* called by cron hourly
* mainly intended for use on laptops
* environment variables
	* SHELL
	* PATH
	* MAILTO
	* HOME
	* RANDOM_DELAY: prevent system overloading
	* START_HOURS_RANGE: the time range of hours during the day when anacron can run scheduled jobs

## One-Time Tasks

* at
* batch
	* `/etc/sysconfig/atd`
		* OPTS
