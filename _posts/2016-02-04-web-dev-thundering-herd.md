---
title: Web Development - Thundering Herd
---

## Introduction

This article describles the thundering herd problem during web development.

<!--more-->

## Table of Contents

* TOC
{:toc}

## concurrent accept system call

* an issue with old kernel, new kernel has been fixed
* solution
	* multi-process
	* multi-thread
		* mutex

## concurrent select, poll, epoll

* used as monitors for file descriptors
* not an issue at all, notify all monitors are reasonable and necessary
* solution
	* using SysV IPC semaphores
		* SysV IPC resource are limited in the system
		* SysV IPC objects are persistent resources, need manually removing
		* leakage is an issue when `killall -9 apache2`
		* `ipcs`
		* not good for app server, cause
			* app server
				is managed by various users
				* not like apache, which is managed by conscious sysadmin as a service
				* app server is slower and heavier
				* running as non-root user
				* sleeping processes are generally low
				* so thundering herd is not a big problems
	* suboptimal option: independent process bound on different sockets and configure nginx to round robin between them
	* optimal option: having an inter-process locking (like Apache HTTP Server) seriallizing all of accepts in both thread and processes
	* use pthread_mutex to seriallizing epoll/kqueue/poll/select use in each thread

## References

* [Serializing accept(), AKA Thundering Herd, AKA the Zeeg Problem](http://uwsgi-docs.readthedocs.io/en/latest/articles/SerializingAccept.html)
* [serving-python-web-applications](http://cramer.io/2013/06/27/serving-python-web-applications)
