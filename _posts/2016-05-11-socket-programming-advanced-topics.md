---
layout: post
title: Socket Programming - Advanced Topics
date: 2016-05-11 12:35:31.000000000 +08:00
type: post
published: true
status: publish
categories:
- Linux
- Network
- UNIX
tags: [socket]
---

## Introduction

This article covers some advanced topics about socket programming.

<!--more-->

## Table of Contents

* TOC
{:toc}

## Options

### SO_SNDBUF/SO_RCVBUF

### TTL

### KeepAlive

### TCP_TW_REUSE

Allow to reuse TIME-WAIT sockets for new connections when it is safe from protocol viewpoint. Default value is 0. It should not be changed without advice/request of technical experts.

It is generally a safer alternative to tcp_tw_recycle

The tcp_tw_reuse setting is particularly useful in environments where numerous short connections are open and left in TIME_WAIT state, such as web servers. Reusing the sockets can be very effective in reducing server load.

### TCP_TW_RECYCLE

Enable fast recycling TIME-WAIT sockets. Default value is 0.

Known to cause some issues with hoststated (load balancing and fail over) if enabled, should be used with caution.

### TCP_NODELAY

First off, be sure you really want to use it in the first place. It will disable the Nagle algorithm, which will cause network traffic to increase, with smaller than needed packets wasting bandwidth. Also, from what I have been able to tell, the speed increase is very small, so you should probably do it without TCP_NODELAY first, and only turn it on if there is a problem.

```c
int flag = 1;
int result = setsockopt(sock,            /* socket affected */
					    IPPROTO_TCP,     /* set option at TCP level */
                        TCP_NODELAY,     /* name of option */
                        (char *) &flag,  /* the cast is historical 
                                                cruft */
                        sizeof(int));    /* length of option value */
if (result < 0)
   ... handle the error ...
```

TCP_NODELAY is for a specific purpose; to disable the Nagle buffering algorithm. It should only be set for applications that send frequent small bursts of information without getting an immediate response, where timely delivery of data is required (the canonical example is mouse movements).

### SO_LINGER

The typical reason to set a `SO_LINGER` timeout of zero is to avoid large numbers of connections sitting in the `TIME_WAIT` state, tying up all the available resources on a server.

When a TCP connection is closed cleanly, the end that initiated the close ("active close") ends up with the connection sitting in TIME_WAIT for several minutes. So if your protocol is one where the server initiates the connection close, and involves very large numbers of short-lived connections, then it might be susceptible to this problem.

This isn't a good idea, though - TIME_WAIT exists for a reason (to ensure that stray packets from old connections don't interfere with new connections). It's a better idea to redesign your protocol to one where the client initiates the connection close, if possible.

Moreover, the purpose of SO_LINGER is very, very specific and only a 
tiny minority of socket applications actually need it. Unless you are 
extremely familiar with the intricacies of TCP and the BSD socket 
API, you could very easily end up using SO_LINGER in a way for which 
it was not designed. 

The effect of an setsockopt(..., SO_LINGER,...) depends on what the values in the linger structure (the third parameter passed to setsockopt()) are:

0. Case 1: linger->l_onoff is zero (linger->l_linger has no meaning): This is the default.

	On close(), the underlying stack attempts to gracefully shutdown the connection after ensuring all unsent data is sent. In the case of connection-oriented protocols such as TCP, the stack also ensures that sent data is acknowledged by the peer.  The stack will perform the above-mentioned graceful shutdown in the background (after the call to close() returns), regardless of whether the socket is blocking or non-blocking.

0. Case 2: linger->l_onoff is non-zero and linger->l_linger is zero:

	A close() returns immediately. The underlying stack discards any unsent data, and, in the case of connection-oriented protocols such as TCP, sends a RST (reset) to the peer (this is termed a hard or abortive close). All subsequent attempts by the peer's application to read()/recv() data will result in an ECONNRESET.

0. Case 3: linger->l_onoff is non-zero and linger->l_linger is non-zero:

	A close() will either block (if a blocking socket) or fail with EWOULDBLOCK (if non-blocking) until a graceful shutdown completes or the time specified in linger->l_linger elapses (time-out). Upon time-out the stack behaves as in case 2 above.

#### Portability Note

* Some implementations of the BSD socket API do not implement SO_LINGER at all.

	On such systems, applying SO_LINGER either fails with EINVAL or is (silently) ignored. Having SO_LINGER defined in the headers is no guarantee that SO_LINGER is actually implemented.

* Since the BSD documentation on SO_LINGER is sparse and inadequate, it is not surprising to find the various implementations interpreting the effect of SO_LINGER differently.

	For instance, the effect of SO_LINGER on non-blocking sockets is not mentioned at all in BSD documentation, and is consequently treated differently on different platforms. Taking case 3 for example: Some implementations behave as described above. With others, a non-blocking socket close() succeed immediately leaving the rest to a background process. Others ignore non-blocking'ness and behave as if the socket were blocking. Yet others behave as if SO_LINGER wasn't in effect [as if the case 1, the default, was in effect], or ignore linger->l_linger [case 3 is treated as case 2]. Given the lack of 
adequate documentation, such differences are not (by themselves) indicative of an "incomplete" or "broken" implementation. They are simply different, not incorrect.

* Some implementations of the BSD socket API do not implement SO_LINGER completely.

	On such systems, the value of linger->l_linger is ignored (always treated as if it were zero).
Technical/Developer note: SO_LINGER does (should) not affect a stack's implementation of TIME_WAIT. In any event, SO_LINGER is not the way to get around TIME_WAIT.  If an application expects to open and close many TCP sockets in quick succession, it should be written to use only a fixed number and/or range of ports, and apply SO_REUSEPORT to sockets that use those ports.

#### Related Note

SO_DONTLINGER
: This socket option has the exact opposite meaning of SO_LINGER, and the two are treated (after inverting the value of linger->l_onoff) as equivalent. In other words, SO_LINGER with a zero `linger->l_onoff` is the same as SO_DONTLINGER with a non-zero `linger->l_onoff`, and vice versa.

**using SO_LINGER with timeout 0 should really be a last resort**

## Enable Non-Blocking Socket Option

```c
flags = fcntl(sock_descriptor, F_GETFL, 0)
fcntl(socket_descriptor, F_SETFL, flags | O_NONBLOCK)
```

or

```c
ioctl(sockfd, FIONBIO, (char *)&one);
```

## EINTR

This isn't really so much an error as an exit condition. It means that the call was interrupted by a signal. Any call that might block should be wrapped in a loop that checkes for EINTR

## SIGPIPE

with TCP you get SIGPIPE if your end of the connection has received an RST from the other end. What this also means is that if you were using select instead of write, the select would have indicated the socket as being readable, since the RST is there for you to read (read will return an error with errno set to ECONNRESET).

Basically an RST is TCP's response to some packet that it doesn't expect and has no other way of dealing with. A common case is when the peer closes the connection (sending you a FIN) but you ignore it because you're writing and not reading. (You should be using select.) So you write to a connection that has been closed by the other end and the other end's TCP responds with an RST.

## OOB Data

Out-of-band data is the data transferred through a stream that is independent from the main in-band data stream. An out-of-band data mechanism provides a conceptually independent channel, which allows any data sent via that mechanism to be kept separate from in-band data

* Out-of-band data (called "urgent data" in TCP) looks to the application like a separate stream of data from the main data stream.
* This can be useful for separating two different kinds of data.
* Note that just because it is called "urgent data" does not mean that it will be delivered any faster, or with higher priorety than data in the in-band data stream.
* Also beware that unlike the main data stream, the out-of-bound data may be lost if your application can't keep up with it.

## References

* [UNIX Socket FAQ](http://developerweb.net/viewforum.php)
* [Linux ip-sysctl](http://lxr.linux.no/linux+v3.2.8/Documentation/networking/ip-sysctl.txt)
