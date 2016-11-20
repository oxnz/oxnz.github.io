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

## `setsockopt`

```c
#include <sys/socket.h>
int
getsockopt(int socket, int level, int option_name,
    void *restrict option_value, socklen_t *restrict option_len);
int
setsockopt(int socket, int level, int option_name,
    const void *option_value, socklen_t option_len);
```

>
`getsockopt()` and `setsockopt()` manipulate the options associated with a
 socket.  Options may exist at multiple protocol levels; they are always
 present at the uppermost ``socket'' level.

<!--more-->

## Table of Contents

* TOC
{:toc}

## SOL_SOCKET

### `SO_DEBUG`        enables recording of debugging information

### `SO_REUSEADDR`    enables local address reuse

Indicates that the rules used in validating addresses supplied in a `bind(2)` call should **allow reuse of local addresses**. For `AF_INET` sockets this means that a socket may bind, except when there is an active listening socket bound to the address. When the listening socket is bound to `INADDR_ANY` with a specific port then **it is not possible to bind to this port for any local address**. Argument is an integer boolean flag.

### `SO_REUSEPORT`    enables duplicate address and port bindings

### `SO_KEEPALIVE`    enables keep connections alive

Enable sending of keep-alive messages on connection-oriented sockets. Expects an integer boolean flag.

### `SO_DONTROUTE`    enables routing bypass for outgoing messages

**Don't send via a gateway, only send to directly connected hosts**.
The same effect can be achieved by setting the `MSG_DONTROUTE` flag on a socket `send(2)` operation.
Expects an integer boolean flag.

### `SO_LINGER`       linger on close if data present

>
When enabled, a `close(2)` or `shutdown(2)` will not return until all queued messages for the socket have been successfully sent or the linger timeout has been reached. Otherwise, the call returns immediately and the closing is done in the background. When the socket is closed as part of `exit(2)`, it always lingers in the background.

The typical reason to set a `SO_LINGER` timeout of zero is to avoid large numbers of connections sitting in the `TIME_WAIT` state, tying up all the available resources on a server.

When a TCP connection is closed cleanly, the end that initiated the close ("active close") ends up with the connection sitting in `TIME_WAIT` for several minutes. So if your protocol is one where the server initiates the connection close, and involves very large numbers of short-lived connections, then it might be susceptible to this problem.

This isn't a good idea, though - `TIME_WAIT` exists for a reason (to ensure that stray packets from old connections don't interfere with new connections). It's a better idea to redesign your protocol to one where the client initiates the connection close, if possible.

Moreover, the purpose of `SO_LINGER` is very, very specific and only a 
tiny minority of socket applications actually need it. Unless you are 
extremely familiar with the intricacies of TCP and the BSD socket 
API, you could very easily end up using `SO_LINGER` in a way for which 
it was not designed. 

The effect of an `SO_LINGER` depends on what the values in the linger structure (the third parameter passed to `setsockopt()`)

```c
/* /usr/include/sys/socket.h -> /usr/include/bits/socket.h */
/* structure used to manipulate the SO_LINGER option */
struct linger {
    int l_onoff;      /* non-zero to linger on close */
    int l_linger;     /* time to linger */
}
```

which has 3 cases:

0. `linger->l_onoff == 0`

    `linger->l_linger` has no meaning.
    This is the default.

	On close(), the underlying stack attempts to gracefully shutdown the connection after ensuring all unsent data is sent. In the case of connection-oriented protocols such as TCP, the stack also ensures that sent data is acknowledged by the peer.  The stack will perform the above-mentioned graceful shutdown in the background (after the call to close() returns), regardless of whether the socket is blocking or non-blocking.

0. `linger->l_onoff != 0 && linger->l_linger == 0`

	A close() returns immediately. The underlying stack discards any unsent data, and, in the case of connection-oriented protocols such as TCP, sends a RST (reset) to the peer (this is termed a hard or abortive close). All subsequent attempts by the peer's application to read()/recv() data will result in an ECONNRESET.

0. `linger->l_onoff != 0 && linger->l_linger != 0`

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

### `SO_BROADCAST`    enables permission to transmit broadcast messages

Set or get the broadcast flag.
**When enabled, datagram sockets are allowed to send packets to a broadcast address**.
This option has no effect on stream-oriented sockets.

### `SO_OOBINLINE`    enables reception of out-of-band data in band

If this option is enabled, out-of-band data is directly placed into the receive data stream. Otherwise out-of-band data is only passed when the MSG_OOB flag is set during receiving.

### `SO_SNDBUF`       set buffer size for output

Sets or gets the maximum socket send buffer in bytes.
**The kernel doubles this value** (to allow space for bookkeeping overhead) when it is set using setsockopt(2), and this doubled value is returned by `getsockopt(2)`.
The default value is set by the `/proc/sys/net/core/wmem_default` file and the maximum allowed value is set by the `/proc/sys/net/core/wmem_max` file.
The minimum (doubled) value for this option is 2048.

**NOTES**

Linux assumes that half of the send/receive buffer is used for internal kernel structures; thus the sysctls are twice what can be  observed  on the wire.

### `SO_RCVBUF`       set buffer size for input

### `SO_SNDLOWAT`     set minimum count for output

Specify the minimum number of bytes in the buffer until the socket layer will pass the data to the protocol (`SO_SNDLOWAT`) or the user on receiving (`SO_RCVLOWAT`).
These two values are initialized to 1.
`SO_SNDLOWAT` is not changeable on Linux (`setsockopt(2)` fails with the error `ENOPROTOOPT`).
`SO_RCVLOWAT` is changeable only since Linux 2.4.
**The `select(2)` and `poll(2)` system calls currently do not respect the `SO_RCVLOWAT` setting on Linux, and mark a socket readable when even a single byte of data is available.**
A subsequent read from the socket will block until `SO_RCVLOWAT` bytes are available.

### `SO_RCVLOWAT`     set minimum count for input

### `SO_SNDTIMEO`     set timeout value for output

Specify the receiving or sending timeouts until reporting an error.
The argument is a `struct timeval`.

* If an input or output function blocks for this period of time, and data has been sent or received, the return value of that function will be the amount of data transferred;
* if no data has been transferred and the timeout has been reached then -1 is returned with errno set to `EAGAIN` or `EWOULDBLOCK`, or `EINPROGRESS` (for `connect(2)`) just as if the socket was specified to be nonblocking.
* If the timeout is set to zero (the default) then the operation will never timeout.

**Timeouts only have effect for system calls that perform socket I/O (e.g., `read(2)`, `recvmsg(2)`, `send(2)`, `sendmsg(2)`); timeouts have no effect for `select(2)`, `poll(2)`, `epoll_wait(2)`, and so on.**

### `SO_RCVTIMEO`     set timeout value for input

### `SO_TYPE`         get the type of the socket (get only)

### `SO_TIMESTAMP`    enable or disable the receiving of the `SO_TIMESTAMP` control message

The timestamp control message is sent with level `SOL_SOCKET` and the `cmsg_data` field is a `struct timeval` indicating the reception time of the last packet passed to the user in this call. See `cmsg(3)` for details on control messages.

### `SO_ERROR`        get and clear error on the socket (get only)

### `SO_NOSIGPIPE`    do not generate `SIGPIPE`, instead return `EPIPE`

### `SO_NREAD`        number of bytes to be read (get only)

### `SO_NWRITE` number of bytes written not yet sent by the protocol (get only)

### `SO_LINGER_SEC` linger on close if data present with timeout in seconds

### Options not in the manual

#### `SO_EXCLUSIVEADDRUSE`

#### `SO_USELOOPBACK`

#### `SO_BSDCOMPAT`

### `/proc/sys/net/core/` interfaces

* bpf_jit_enable
* busy_poll
* busy_read
* default_qdisc
* dev_weight
* message_burst
* message_cost
    * configure the token bucket filter used to load limit warning messages caused by external network events.
* netdev_budget
* netdev_max_backlog
    * Maximum number of packets in the global input queue.
* netdev_rss_key
* netdev_tstamp_prequeue
* optmem_max
    * Maximum length of ancillary data and user control data like the iovecs per socket.
* rmem_default
    * contains the default setting in bytes of the socket receive buffer.
* rmem_max
    * contains the maximum socket receive buffer size in bytes which a user may set by using the SO_RCVBUF socket option.
* rps_sock_flow_entries
* somaxconn
* warnings
* wmem_default
    * contains the default setting in bytes of the socket send buffer.
* wmem_max
    * contains the maximum socket send buffer size in bytes which a user may set by using the SO_SNDBUF socket option.
* xfrm_acq_expires
* xfrm_aevent_etime
* xfrm_aevent_rseqth
* xfrm_larval_drop

## IPPROTO_IP

### IP_HDRINCL

### IP_OPTIONS

### IP_RECVDSTADDR

### IP_RECVIF

### IP_TOS

* IPTOS_LOWDELAY
* IPTOS_THROUGHPUT
* IPTOS_RELIABILITY
* IPTOS_LOWCOST

### IP_TTL

### ICMP6_FILTER

## IPPROTO_IPV6

### IPV6_ADDRFORM

### IPV6_CHECKSUM

### IPV6_DSTOPTS

### IPV6_HOPLIMIT

### IPV6_HOPOPTS

### IPV6_NEXTHOP

### IPV6_PKTINFO

### IPV6_PKTOPTIONS

### IPV6_RTHDR

### IPV6_UNICAST_HOPS

## IPPROTO_TCP

### `TCP_MAXSEG`

### `TCP_NODELAY`

### `TCP_TW_REUSE`

Allow to **reuse TIME-WAIT sockets** for new connections when it is safe from protocol viewpoint. Default value is 0. It should not be changed without advice/request of technical experts.

It is generally a safer alternative to `TCP_TW_RECYCLE`

The `TCP_TW_REUSE` setting is particularly useful in environments where numerous short connections are open and left in TIME_WAIT state, such as web servers.
Reusing the sockets can be very effective in reducing server load.

### `TCP_TW_RECYCLE`

Enable **fast recycling TIME-WAIT sockets**. Default value is 0.

Known to cause some issues with hoststated (load balancing and fail over) if enabled, should be used with caution.

### `TCP_NODELAY`

First off, be sure you really want to use it in the first place.
It will **disable the Nagle algorithm**, which will cause network traffic to increase, with smaller than needed packets wasting bandwidth.
Also, from what I have been able to tell, the speed increase is very small, so you should probably do it without `TCP_NODELAY` first, and only turn it on if there is a problem.

```c
int optval = 1;
int result = setsockopt(sock,     /* socket affected */
                IPPROTO_TCP,      /* set option at TCP level */
                TCP_NODELAY,      /* name of option */
                (char *) &optval, /* the cast is historical cruft */
                sizeof(int));     /* length of option value */
if (result < 0)
   ... handle the error ...
```

`TCP_NODELAY` is for a specific purpose; to disable the Nagle buffering algorithm.
It should only be set for applications that send frequent small bursts of information without getting an immediate response, where timely delivery of data is required (the canonical example is mouse movements).

### `TCP_CORK`

### `TCP_DEFER_ACCEPT`

### `TCP_QUICKACK`

## TCP FLAGS

* SYN
* FIN
* ACK
* PSH
: Data is Not Empty
* RST
* URG
: Urgent pointer is valid

## Enable Non-Blocking Socket Option

```c
flags = fcntl(sock_descriptor, F_GETFL, 0)
fcntl(socket_descriptor, F_SETFL, flags | O_NONBLOCK)
```

or

```c
ioctl(sockfd, FIONBIO, (char *)&one);
```

## `EINTR`

This isn't really so much an error as an exit condition. It means that the call was interrupted by a signal. Any call that might block should be wrapped in a loop that checkes for EINTR

## `SIGPIPE`

with TCP you get SIGPIPE if your end of the connection has received an RST from the other end. What this also means is that if you were using select instead of write, the select would have indicated the socket as being readable, since the RST is there for you to read (read will return an error with errno set to ECONNRESET).

Basically an RST is TCP's response to some packet that it doesn't expect and has no other way of dealing with. A common case is when the peer closes the connection (sending you a FIN) but you ignore it because you're writing and not reading. (You should be using select.) So you write to a connection that has been closed by the other end and the other end's TCP responds with an RST.

## OOB Data

Out-of-band data is the data transferred through a stream that is independent from the main in-band data stream. An out-of-band data mechanism provides a conceptually independent channel, which allows any data sent via that mechanism to be kept separate from in-band data

* Out-of-band data (called "urgent data" in TCP) looks to the application like a separate stream of data from the main data stream.
* This can be useful for separating two different kinds of data.
* Note that just because it is called "urgent data" does not mean that it will be delivered any faster, or with higher priorety than data in the in-band data stream.
* Also beware that unlike the main data stream, the out-of-bound data may be lost if your application can't keep up with it.

## ACK

```
ACK
tcp_ack
tcp_clean_rtx_queue
tcp_ack_update_rtt
tcp_ack_saw_tstamp | tcp_ack_no_tstamp
tcp_valid_rtt_meas
tcp_rtt_estimator
tcp_set_rto
```

## Glossary

RTO
: Retransmission Timeout

MSL
: Maximum Segment Lifetime

RTT
: Round-Trip Time

MSS
: Maximum Segment Size

MTU
: Maximum Transmission Unit

## References

* [man 7 socket](https://linux.die.net/man/7/socket)
* [UNIX Socket FAQ](http://developerweb.net/viewforum.php)
* [Linux ip-sysctl](http://lxr.linux.no/linux+v3.2.8/Documentation/networking/ip-sysctl.txt)

*[RTT]: Round-Trip Time
*[RTO]: Retransmission TimeOut
*[MSL]: Maximum Segment Lifetime
*[MSS]: Maximum Segment Size
*[MTU]: Maximum Transmission Unit
