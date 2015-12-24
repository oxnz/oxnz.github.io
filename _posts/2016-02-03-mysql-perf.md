---
layout: post
title: Mysql Performance Optimization
categories:
- sysadm
- DBA
- perf
tags:
- mysql
---

## Performance

* Mean Response Time

### Performance Concerns

* Security
* Manageability
* Compatibility
* Compliance
* Ease of use by Developers

<!--more-->

### Processes Queries

* Selects
* Inserts
* Deletes
* Updates

### Focus

Performance optimization focused on:

* Making queries run faster
* Using less resources
* Scaling better

## Related Issues

* Stability
* Scalability
	* Load
	* Data Size
	* Infrastructure
* Efficiency

## Optimization

General Steps:

0. Hardware
0. Server
	* OS
	* Network
	* File System
0. Mysql Server
	* Optimize the queries
	* Database schema

### OS Tuning

Generally speaking, the OS manufactories made their product good for common workloads by defaults. But in production, most server act as a specific character providing services, such as DB server, App Server, Proxy, etc. And so, the defaults may not the best.

### Mysql Configuration

#### Current Settings

`my.cnf`/`my.ini`

{% highlight sql %}
mysql> SHOW GLOBAL VARIABLES;
{% endhighlight %}

#### Current Status

{% highlight sql %}
mysql> SHOW GLOBAL STATUS;
{% endhighlight %}

#### Tuning

* RAM
* Workload
* Storage Engines

* Do not run with defaults
* Do not ever obsess with tuning

Variables:

* max_connections
* log_bin
* table_open_cache_size
* table_definitions_cache_size
* open_files_limit
* innodb_buffer_pool_size
* innodb_log_file_size
* innodb_flush_log_at_trx_commit
* innodb_flush_method = O_DIRECT

#### Transaction Optimization

* optimize slow queries the transaction runs

### Things to Consider

* Do not look at the average case only
* Look at trends over time(daily, weekly, monthly)
* Think about future performance

## Tools

### PT-Query-Digest from Percona Toolkit

### Mysql Utilities

### Mysql Performance Schemas

## Conclusion

* It is Application Performance what Matters
* Use Right tools for right job
* See what queries Mysql is Running
* Reduce Number of Queries
* Reduce Data They Return
* See how they can do less work
* Do that work more efficiently

## References
