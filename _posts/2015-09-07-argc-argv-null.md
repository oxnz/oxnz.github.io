---
layout: post
title: "argv[argc] == null"
categories: [dev, c, c++]
tags: [argv]
---

Is `argv[argc] == null` always true?

<!--more-->

## The standard

>		5.1.2.2.1 Program startup
	  ...
	  -- argv[argc] shall be a null pointer.

## Predates the standard

>The man page for exec from 1979 (plan9.bell-labs.com/7thEdMan/v7vol1.pdf) shows that this predates the standard by quite a bit, and contains a possible hint as to why it's this way: "Argv is directly usable in another execv because argv[argc] is 0.

## Emails

>argv null terminated in main()?
From: Aleksandar Milivojevic
Date: Thu Sep 16 2004 - 16:27:37 EST


>I was looking for info on this question on web and in documentation, but couldn't find it documented anywhere.
>
>The question is, after call to execve() system call, and after new image is loaded, is argv (as passed to main() function of new program) NULL terminated or not in Linux?
>
>So far I found article from Ritchie saying that argv[argc] was -1 up to Unix Sixth Edition (1975), and than it was changed to NULL starting from Seventh Edition (in 1979) and than later same behaviour was carried over to 32V and BSD. Looking at the man page for exec(2) on Solaris, which is System V derivate, the documentation still states the same (argv[argc] is guaranteed to be NULL).
>
>But how about Linux kernel? What (if anything) is copied or filled into argv[argc] by execve()?
>
>Documentation for execve() on Linux doesn't state it explicitly, but one could find himself lured into beleiving that argv[argc] should be NULL. It says "The argument vector and environment can be accessed by the called program's main function, when it is defined as int main(int argc, char *argv[], char *envp[])". Because original vector as passed to execve was NULL terminated.
>
>I've looked in the kernel source code (just a glance), and by looking at copy_strings function in exec.c, it seems as argv[argc] might be undefined (it seems that loop copies only first argc - 1 elements of argv). But I might be wrong.

## Source code

[argv.c](http://www.opensource.apple.com/source/gcc/gcc-5666.3/libiberty/argv.c)
