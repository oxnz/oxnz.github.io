---
title: Performance Tuning - Stress Testing
---

## Introduction

Stress (Load) testing.

<!--more-->

## Table of Contents

* TOC
{:toc}

## Apache HTTP server benchmarking tool

>
ab is a tool for benchmarking your Apache Hypertext Transfer Protocol (HTTP) server. It is designed to give you an impression of how your current Apache installation performs. This especially shows you how many requests per second your Apache installation is capable of serving.

### Aspects

* multiple time test
* content type
	* static
	* dynamic
* KeepAlive (on/off)
	* allow multiple requests to be sent over the same TCP connection

### Examples

```shell
ab -c 512 -n 102400 -g out-01.tsv 'http://172.24.74.193/icons/poweredby.png'
```

### Options

* -c concurrency
* -n requests
	* number of requests
* -k
	* enable the HTTP KeepAlive feature
* -g gnuplot-file
	* Write all measured values out as a 'gnuplot' or TSV (Tab separate  values)  file
* -r
	* Don't exit on socket receive errors

### Diagnose

* socket: Too many open files (24)
	* nofile too small, try `ulimit -n 1024`
* apr_socket_recv: Connection reset by peer (54)
	* use '-r' option

## References

http://www.bradlanders.com/2013/04/15/apache-bench-and-gnuplot-youre-probably-doing-it-wrong/

* [tcpcopy](https://github.com/wangbin579/tcpcopy)
* [jmeter](http://jmeter.apache.org/)
* [httperf](https://github.com/httperf/httperf)
