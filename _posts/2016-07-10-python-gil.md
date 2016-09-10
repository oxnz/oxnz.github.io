---
title: Python GIL
---

## Introduction

GIL Global Interprete Lock

<!--more-->

## Table of Contents

* TOC
{:toc}

## GIL Overview

* GIL enables cooperative mmultitasking
* A running thread holds the GIL
* GIL released on I/O (read, write, readv, writev)
* `sys.setcheckinterval(n)
	* check for async events every n instructions
	* how long threads switches

## GIL Releases and Acquisitions

The currently running thread:

`python/ceval.c`

* Reset the tick counter
* Run signal handlers if in the main thread
* Releases the GIL
* Reacquires the GIL

## Multicore Event Handling

CPU-bound threads make GIL acquisition difficult for threads that want to handle events

## Behavior of I/O Handling

* I/O ops often do not block
* Due to buffering, the OS is able to fulfill I/O requests immediately and keep a thread running
* Results in GIL thrashing under heavy load
