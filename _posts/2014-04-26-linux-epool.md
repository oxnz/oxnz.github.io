---
layout: post
title: Linux epoll
date: 2014-04-26 17:13:42.000000000 +08:00
type: post
published: true
status: publish
categories:
- Linux
tags:
- epoll
- socket
---

## Introduction

本篇为 Linux I/O 事件通知机制系列第三篇，介绍 epool。 其他两篇为:

* [第一篇介绍Linux Select](/2014/04/30/linux-select/)
* [第二篇介绍 poll](2014/05/03/linux-poll/)

<!--more-->

## Table of Contents

* TOC
{:toc}

## epoll - I/O event notification facility

### Description

<b>epoll</b> API 执行与 <b><a style="color: #660000;" href="http://linux.die.net/man/2/poll">poll</a></b>(2) 类似的任务: 监测多个文件描述符是否可以进行 I/O。<b>epoll</b> API 既可以被用作边缘触发(edge-triggered)也可以被用作水平触发(level-triggered)接口，并且能很好的扩展以适应监测大量的文件描述符(and scales well to large numbers of watched file descriptors)。下面的系统调用用来创建和管理一个 <b>epoll </b>实例。

<b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_create">epoll_create</a></b>(2) 创建一个 <b>epoll</b> 实例并且返回引用这个实例的一个文件描述符。(较新的 <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_create1">epoll_create1</a></b>(2) 扩展了 <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_create" rel="nofollow">epoll_create</a></b>(2) 的功能。)

然后把感兴趣的特定文件描述符通过 <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_ctl">epoll_ctl</a></b>(2) 进行注册。有时候把目前注册到一个 <b>epoll</b> 实例的文件描述符集合称作一个 <i>epoll</i>set.

<b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_wait">epoll_wait</a></b>(2) 等待 I/O 事件, 如果当前没有可用事件则阻塞调用线程。

### Level-triggered and edge-triggered

The <b>epoll</b> event distribution interface is able to behave both as edge-triggered (ET) and as level-triggered (LT). 两种机制之间的区别可做如下描述。假定有如下情况发生:
<ol>
<li>代表管道读取一端的文件描述符(<i>rfd</i>)已经注册到了 <b>epoll </b>实例。</li>
<li>从管道写端写入了2 kB 的数据。</li>
<li>对 <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_wait" rel="nofollow">epoll_wait</a></b>(2) 的调用已完成并且将会返回 <i>rfd</i> 作为一个已就绪的文件描述符。</li>
<li>读取者从 <i>rfd </i>取走了1 kB 数据。</li>
<li>调用 <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_wait" rel="nofollow">epoll_wait</a></b>(2) 已经返回。</li>
</ol>

如果文件描述符 <i>rfd</i> 被添加到 <b>epoll</b> 接口的时候使用了 <b>EPOLLET</b> (edge-triggered) 标志, 在第5步中对 <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_wait" rel="nofollow">epoll_wait</a></b>(2) 的调用很可能就会挂起，尽管文件输入缓冲区中还有数据可用；meanwhile the remote peer might be expecting a response based on the data it already sent. 其原因在于 edge-triggered mode 只在在监测的文件描述符上发生改变的时候才传送事件。所以，在第5步中虽然输入缓冲区中有数据，但还是要等数据到来。在上述例子中，an event on由于第2步的写操作会对 <i>rfd</i> 产生一个事件，这个事件在第3步中被消费。由于第4步的读操作并没有消费缓冲区的全部数据，所以第5步对 <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_wait" rel="nofollow">epoll_wait</a></b>(2) 的调用就可能无限期阻塞。<span style="color: #ff0000;">使用标志的应用应当使用非阻塞的文件描述符来避免读写阻塞，因为读写阻塞会使处理多个文件描述符的任务出现饥饿(An application that employs the <b>EPOLLET</b> flag should use nonblocking file descriptors to avoid having a blocking read or write starve a task that is handling multiple file descriptors)。</span>

* 推荐的使用 <b>epoll</b> 作为一个 edge-triggered (<b>EPOLLET</b>) interface 的方法如下:
	1. 使用非阻塞的文件描述符；并且
	2. 只有在 <b><a style="color: #660000;" href="http://linux.die.net/man/2/read">read</a></b>(2) or <b><a style="color: #660000;" href="http://linux.die.net/man/2/write">write</a></b>(2) 返回 <b>EAGAIN 的</b>情况下才进入等待下一个事件

* 相反的, 当用作 level-triggered interface (这是默认的, 当没有指定 <b>EPOLLET</b> 的时候) 的时候, <b>epoll </b>只是一个更快的 <b><a style="color: #660000;" href="http://linux.die.net/man/2/poll" rel="nofollow">poll</a></b>(2), 而且由于它们具有相同的语义(semantics)，所以可以用在任何使用后者的地方。

由于使用 edge-triggered <b>epoll </b>的时候, 在收到多个数据块的时候会产生多个事件，调用者可以指定 <b>EPOLLONESHOT </b>标志来告诉 <b>epoll</b> 在 从<b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_wait" rel="nofollow">epoll_wait</a></b>(2)收到一个事件之后禁用相关的文件描述符。当制定 <b>EPOLLONESHOT</b> 标识的时候， 调用者就要负责使用 <b>EPOLL_CTL_MOD </b>操作 <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_ctl" rel="nofollow">epoll_ctl</a></b>(2) 重新添加这个文件描述符。

### /proc interfaces

下面的接口可以用来限制 epoll 消耗的内核存储大小
`/proc/sys/fs/epoll/max_user_watches` (since Linux 2.6.28)

这个值指定了一个用户可以通过系统上所有 epoll 实例注册的文件描述符数量上限。这个限制是针对每个真实用户 ID (real user ID)的。每一个注册的文件描述符在32位内核上大概占用90字节，64位内核上占用160字节。Currently, the default value for <i>max_user_watches</i> is 1/25 (4%) of the available low memory, divided by the registration cost in bytes.

### Example for suggested usage

把 <b>epoll</b> 当做一个 level-triggered interface 来用的时候和 <b><a style="color: #660000;" href="http://linux.die.net/man/2/poll" rel="nofollow">poll</a></b>(2) 具有相同的语义(semantics), 边沿触发edge-triggered的使用需要进一步澄清，以避免在应用程序事件循环中暂停(stalls)。
在下面的例子中，listener 是一个对其调用了<b><a style="color: #660000;" href="http://linux.die.net/man/2/listen">listen</a></b>(2) 的非阻塞 socket。
函数 `do_use_fd()` 使用就绪的文件描述符直到<b><a style="color: #660000;" href="http://linux.die.net/man/2/read" rel="nofollow">read</a></b>(2) 或 <b><a style="color: #660000;" href="http://linux.die.net/man/2/write" rel="nofollow">write</a></b>(2) 返回 <b>EAGAIN。</b>
一个事件驱动的状态机应用，在收到 EAGAIN 之后，应当记录当前状态，以便在下次调用 <i>do_use_fd()</i> 的时候可以接着上次 <b><a style="color: #660000;" href="http://linux.die.net/man/2/read" rel="nofollow">read</a></b>(2) 或 <b><a style="color: #660000;" href="http://linux.die.net/man/2/write" rel="nofollow">write</a></b>(2) 停止的地方工作。

```c
#define MAX_EVENTS 10
struct epoll_event ev, events[MAX_EVENTS];
int listen_sock, conn_sock, nfds, epollfd;

/* Set up listening socket, 'listen_sock' (socket(),
   bind(), listen()) */

epollfd = epoll_create(10);
if (epollfd == -1) {
    perror("epoll_create");
    exit(EXIT_FAILURE);
}

ev.events = EPOLLIN;
ev.data.fd = listen_sock;
if (epoll_ctl(epollfd, EPOLL_CTL_ADD, listen_sock, &amp;ev) == -1) {
    perror("epoll_ctl: listen_sock");
    exit(EXIT_FAILURE);
}

for (;;) {
    nfds = epoll_wait(epollfd, events, MAX_EVENTS, -1);
    if (nfds == -1) {
        perror("epoll_pwait");
        exit(EXIT_FAILURE);
    }

   for (n = 0; n < nfds; ++n) {
        if (events[n].data.fd == listen_sock) {
            conn_sock = accept(listen_sock, (struct sockaddr *)&local, &addrlen);
            if (conn_sock == -1) {
                perror("accept");
                exit(EXIT_FAILURE);
            }
            setnonblocking(conn_sock);
            ev.events = EPOLLIN | EPOLLET;
            ev.data.fd = conn_sock;
            if (epoll_ctl(epollfd, EPOLL_CTL_ADD, conn_sock, &ev) == -1) {
                perror("epoll_ctl: conn_sock");
                exit(EXIT_FAILURE);
            }
        } else {
            do_use_fd(events[n].data.fd);
        }
    }
}
```

当用作 edge-triggered interface 的时候, 出于**效率**考虑，一般通过指定 (`EPOLLIN|EPOLLOUT`)来一次把文件描述符添加到 <b>epoll</b> interface (<b>EPOLL_CTL_ADD</b>) 中。
这样就可以避免后续的通过使用 <b>EPOLL_CTL_MOD 调用 <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_ctl" rel="nofollow">epoll_ctl</a></b>(2)</b> 在<b> </b><b>EPOLLIN</b> 和 <b>EPOLLOUT</b> 之间切换。

### Questions and answers

<p><b>Q0</b></p>
<p>What is the key used to distinguish the file descriptors registered in an <b>epoll</b> set?</p>
<p><b>A0</b></p>
<p>The key is the combination of the file descriptor number and the open file description (also known as an "open file handle", the kernel's internal representation of an open file).</p>
<p><b>Q1</b></p>
<p>What happens if you register the same file descriptor on an <b>epoll</b> instance twice?</p>
<p><b>A1</b></p>
<p>You will probably get <b>EEXIST</b>. However, it is possible to add a duplicate (<b><a style="color: #660000;" href="http://linux.die.net/man/2/dup">dup</a></b>(2), <b><a style="color: #660000;" href="http://linux.die.net/man/2/dup2">dup2</a></b>(2), <b><a style="color: #660000;" href="http://linux.die.net/man/2/fcntl">fcntl</a></b>(2) <b>F_DUPFD</b>) descriptor to the same <b>epoll</b> instance. <span style="color: #ff0000;">This can be a useful technique for filtering events, if the duplicate file descriptors are registered with different <i>events</i> masks.</span></p>
<p><b>Q2</b></p>
<p>Can two <b>epoll</b> instances wait for the same file descriptor? If so, are events reported to both <b>epoll</b> file descriptors?</p>
<p><b>A2</b></p>
<p>Yes, and events would be reported to both. However, careful programming may be needed to do this correctly.</p>
<p><b>Q3</b></p>
<p>Is the <b>epoll</b> file descriptor itself poll/epoll/selectable?</p>
<p><b>A3</b></p>
<p>Yes. If an <b>epoll</b> file descriptor has events waiting then it will indicate as being readable.</p>
<p><b>Q4</b></p>
<p>What happens if one attempts to put an <b>epoll</b> file descriptor into its own file descriptor set?</p>
<p><b>A4</b></p>
<p>The <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_ctl" rel="nofollow">epoll_ctl</a></b>(2) call will fail (<b>EINVAL</b>). However, you can add an <b>epoll</b> file descriptor inside another <b>epoll</b> file descriptor set.</p>
<p><b>Q5</b></p>
<p>Can I send an <b>epoll</b> file descriptor over a UNIX domain socket to another process?</p>
<p><b>A5</b></p>
<p>Yes, but it does not make sense to do this, since the receiving process would not have copies of the file descriptors in the <b>epoll</b> set.</p>
<p><b>Q6</b></p>
<p>关闭一个文件描述符会使得它自动从所有 <b>epoll</b> sets 中移除吗？</p>
<p><b>A6</b></p>
<p>Yes, but be aware of the following point. A file descriptor is a reference to an open file description (see <b><a style="color: #660000;" href="http://linux.die.net/man/2/open">open</a></b>(2)). Whenever a descriptor is duplicated via <b><a style="color: #660000;" href="http://linux.die.net/man/2/dup" rel="nofollow">dup</a></b>(2), <b><a style="color: #660000;" href="http://linux.die.net/man/2/dup2" rel="nofollow">dup2</a></b>(2),<b><a style="color: #660000;" href="http://linux.die.net/man/2/fcntl" rel="nofollow">fcntl</a></b>(2) <b>F_DUPFD</b>, or <b><a style="color: #660000;" href="http://linux.die.net/man/2/fork">fork</a></b>(2), a new file descriptor referring to the same open file description is created. An open file description continues to exist until all file descriptors referring to it have been closed. A file descriptor is removed from an <b>epoll</b> set only after all the file descriptors referring to the underlying open file description have been closed (or before if the descriptor is explicitly removed using <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_ctl" rel="nofollow">epoll_ctl</a></b>(2) <b>EPOLL_CTL_DEL</b>). <span style="color: #ff0000;">This means that even after a file descriptor that is part of an <b>epoll</b> set has been closed, events may be reported for that file descriptor if other file descriptors referring to the same underlying file description remain open.</span></p>
<p><b>Q7</b></p>
<p>If more than one event occurs between <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_wait" rel="nofollow">epoll_wait</a></b>(2) calls, are they combined or reported separately?</p>
<p><b>A7</b></p>
<p>They will be combined.</p>
<p><b>Q8</b></p>
<p>Does an operation on a file descriptor affect the already collected but not yet reported events?</p>
<p><b>A8</b></p>
<p>You can do two operations on an existing file descriptor. Remove would be meaningless for this case.<span style="color: #ff0000;"> Modify will reread available I/O.</span></p>
<p><b>Q9</b></p>
<p>Do I need to continuously read/write a file descriptor until <b>EAGAIN</b> when using the <b>EPOLLET</b> flag (edge-triggered behavior) ?</p>
<p><b>A9</b></p>
<p>Receiving an event from <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_wait" rel="nofollow">epoll_wait</a></b>(2) should suggest to you that such file descriptor is ready for the requested I/O operation. You must consider it ready until the next (nonblocking) read/write yields <b>EAGAIN</b>. When and how you will use the file descriptor is entirely up to you.</p>
<p>For packet/token-oriented files (e.g., datagram socket, terminal in canonical mode), the only way to detect the end of the read/write I/O space is to continue to read/write until <b>EAGAIN</b>.For stream-oriented files (e.g., pipe, FIFO, stream socket), the condition that the read/write I/O space is exhausted can also be detected by checking the amount of data read from / written to the target file descriptor. For example, if you call <b><a style="color: #660000;" href="http://linux.die.net/man/2/read" rel="nofollow">read</a></b>(2) by asking to read a certain amount of data and <b><a style="color: #660000;" href="http://linux.die.net/man/2/read" rel="nofollow">read</a></b>(2) returns a lower number of bytes, you can be sure of having exhausted the read I/O space for the file descriptor. The same is true when writing using <b><a style="color: #660000;" href="http://linux.die.net/man/2/write" rel="nofollow">write</a></b>(2). (<span style="color: #ff0000;">Avoid this latter technique if you cannot guarantee that the monitored file descriptor always refers to a stream-oriented file.</span>)<b>Possible pitfalls and ways to avoid them</b></p>
<dl compact="compact">
<dt><b>o Starvation (edge-triggered)</b></dt>
<dt>If there is a large amount of I/O space, it is possible that by trying to drain it the other files will not get processed causing starvation. (This problem is not specific to <b>epoll</b>.) <span style="color: #ff0000;">The solution is to maintain a ready list and mark the file descriptor as ready in its associated data structure, thereby allowing the application to remember which files need to be processed but still round robin amongst all the ready files. This also supports ignoring subsequent events you receive for file descriptors that are already ready.</span></dt>
<dt><b>o If using an event cache...</b></dt>
<dt>If you use an event cache or store all the file descriptors returned from <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_wait" rel="nofollow">epoll_wait</a></b>(2), then <span style="color: #ff0000;">make sure to provide a way to mark its closure dynamically</span> (i.e., caused by a previous event's processing). Suppose you receive 100 events from <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_wait" rel="nofollow">epoll_wait</a></b>(2), and in event #47 a condition causes event #13 to be closed. If you remove the structure and <b><a style="color: #660000;" href="http://linux.die.net/man/2/close">close</a></b>(2) the file descriptor for event #13, then your event cache might still say there are events waiting for that file descriptor causing confusion.One solution for this is to call, during the processing of event 47, <b>epoll_ctl</b>(<b>EPOLL_CTL_DEL</b>) to delete file descriptor 13 and <b><a style="color: #660000;" href="http://linux.die.net/man/2/close" rel="nofollow">close</a></b>(2), then mark its associated data structure as removed and link it to a cleanup list. If you find another event for file descriptor 13 in your batch processing, you will discover the file descriptor had been previously removed and there will be no confusion.</dt>
</dl>

## 使用 epoll

### epoll_create, epoll_create1 - open an epoll file descriptor

```c
int epoll_create(int size);
int epoll_create1(int flags);</pre>
```

<b>epoll_create</b>() creates an <i><b><a style="color: #660000;" href="http://linux.die.net/man/7/epoll">epoll</a></b>(7)</i> instance. Since Linux 2.6.8, the <i>size</i> argument is ignored, but must be greater than zero; see NOTES below.

<b>epoll_create</b>() returns a file descriptor referring to the new epoll instance. This file descriptor is used for all the subsequent calls to the <b>epoll</b> interface. When no longer required, the file descriptor returned by <b>epoll_create</b>() should be closed by using <i><b><a style="color: #660000;" href="http://linux.die.net/man/2/close">close</a></b>(2)</i>. When all file descriptors referring to an epoll instance have been closed, the kernel destroys the instance and releases the associated resources for reuse.

#### epoll_create1()

If <i>flags</i> is 0, then, other than the fact that the obsolete <i>size</i> argument is dropped, <b>epoll_create1</b>() is the same as <b>epoll_create</b>(). The following value can be included in<i>flags</i> to obtain different behavior:

<dl compact="compact">
<dt><b>EPOLL_CLOEXEC</b></dt>
<dd>Set the close-on-exec (<b>FD_CLOEXEC</b>) flag on the new file descriptor. See the description of the <b>O_CLOEXEC</b> flag in <i><b><a style="color: #660000;" href="http://linux.die.net/man/2/open">open</a></b>(2)</i> for reasons why this may be useful.</dd>
</dl>

#### Return Value

On success, these system calls return a nonnegative file descriptor. On error, -1 is returned, and <i>errno</i> is set to indicate the error.

#### Errors

<dl compact="compact">
<dt><b>EINVAL</b></dt>
<dd><i>size</i> is not positive.</dd>
<dt><b>EINVAL</b></dt>
<dd>(<b>epoll_create1</b>()) Invalid value specified in <i>flags</i>.</dd>
<dt><b>EMFILE</b></dt>
<dd>The per-user limit on the number of epoll instances imposed by <i>/proc/sys/fs/epoll/max_user_instances</i> was encountered. See <i><b><a style="color: #660000;" href="http://linux.die.net/man/7/epoll" rel="nofollow">epoll</a></b>(7)</i> for further details.</dd>
<dt><b>ENFILE</b></dt>
<dd>The system limit on the total number of open files has been reached.</dd>
<dt><b>ENOMEM</b></dt>
<dd>There was insufficient memory to create the kernel object.</dd>
</dl>

#### Notes

In the initial <b>epoll_create</b>() implementation, the <i>size</i> argument informed the kernel of the number of file descriptors that the caller expected to add to the <b>epoll</b> instance. The kernel used this information as a hint for the amount of space to initially allocate in internal data structures describing events. (If necessary, the kernel would allocate more space if the caller's usage exceeded the hint given in <i>size</i>.) Nowadays, this hint is no longer required (the kernel dynamically sizes the required data structures without needing the hint), but <i>size</i> must still be greater than zero, in order to ensure backward compatibility when new <b>epoll</b> applications are run on older kernels.

### epoll_ctl - control interface for an epoll descriptor

```c
#include <sys/epoll.h>

int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);
```

This system call performs control operations on the <b><a style="color: #660000;" href="http://linux.die.net/man/7/epoll">epoll</a></b>(7) instance referred to by the file descriptor <i>epfd</i>. It requests that the operation <i>op</i> be performed for the target file descriptor, <i>fd</i>.
<p>Valid values for the <i>op</i> argument are :</p>
<dl compact="compact">
<dt><b>EPOLL_CTL_ADD</b></dt>
<dd>Register the target file descriptor <i>fd</i> on the <b>epoll</b> instance referred to by the file descriptor <i>epfd</i> and associate the event <i>event</i> with the internal file linked to <i>fd</i>.</dd>
<dt><b>EPOLL_CTL_MOD</b></dt>
<dd>Change the event <i>event</i> associated with the target file descriptor <i>fd</i>.</dd>
<dt><b>EPOLL_CTL_DEL</b></dt>
<dd>Remove (deregister) the target file descriptor <i>fd</i> from the <b>epoll</b> instance referred to by <i>epfd</i>. The <i>event</i> is ignored and can be NULL (but see BUGS below).</dd>
<dt>The <i>event</i> argument describes the object linked to the file descriptor <i>fd</i>. The <i>struct epoll_event</i> is defined as :</dt>
</dl>

```c
typedef union epoll_data {
    void        *ptr;
    int          fd;
    uint32_t     u32;
    uint64_t     u64;
} epoll_data_t;

struct epoll_event {
    uint32_t     events;      /* Epoll events */
    epoll_data_t data;        /* User data variable */
};
```

<dl>
<dt>The <i>events</i> member is a bit set composed using the following available event types:</dt>
<dt><b>EPOLLIN</b></dt>
<dd>The associated file is available for <b><a style="color: #660000;" href="http://linux.die.net/man/2/read">read</a></b>(2) operations.</dd>
<dt><b>EPOLLOUT</b></dt>
<dd>The associated file is available for <b><a style="color: #660000;" href="http://linux.die.net/man/2/write">write</a></b>(2) operations.</dd>
<dt><b>EPOLLRDHUP</b> (since Linux 2.6.17)</dt>
<dd>Stream socket peer closed connection, or shut down writing half of connection. (This flag is especially useful for writing simple code to detect peer shutdown when using Edge Triggered monitoring.)</dd>
<dt><b>EPOLLPRI</b></dt>
<dd>There is urgent data available for <b><a style="color: #660000;" href="http://linux.die.net/man/2/read" rel="nofollow">read</a></b>(2) operations.</dd>
<dt><b>EPOLLERR</b></dt>
<dd>Error condition happened on the associated file descriptor. <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_wait">epoll_wait</a></b>(2) will always wait for this event; it is not necessary to set it in <i>events</i>.</dd>
<dt><b>EPOLLHUP</b></dt>
<dd>Hang up happened on the associated file descriptor. <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_wait" rel="nofollow">epoll_wait</a></b>(2) will always wait for this event; it is not necessary to set it in <i>events</i>.</dd>
<dt><b>EPOLLET</b></dt>
<dd>Sets the Edge Triggered behavior for the associated file descriptor. The default behavior for <b>epoll</b> is Level Triggered. See <b><a style="color: #660000;" href="http://linux.die.net/man/7/epoll" rel="nofollow">epoll</a></b>(7) for more detailed information about Edge and Level Triggered event distribution architectures.</dd>
<dt><b>EPOLLONESHOT</b> (since Linux 2.6.2)</dt>
<dd>Sets the one-shot behavior for the associated file descriptor. This means that after an event is pulled out with <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_wait" rel="nofollow">epoll_wait</a></b>(2) the associated file descriptor is internally disabled and no other events will be reported by the <b>epoll</b> interface. The user must call <b>epoll_ctl</b>() with <b>EPOLL_CTL_MOD</b> to rearm the file descriptor with a new event mask.</dd>
</dl>

#### Return Value

<p>When successful, <b>epoll_ctl</b>() returns zero. When an error occurs, <b>epoll_ctl</b>() returns -1 and <i>errno</i> is set appropriately.</p>

#### Errors

<dl compact="compact">
<dt><b>EBADF</b><i>epfd</i> or <i>fd</i> is not a valid file descriptor.<b>EEXIST</b><i>op</i> was <b>EPOLL_CTL_ADD</b>, and the supplied file descriptor <i>fd</i> is already registered with this epoll instance.<b>EINVAL</b><i>epfd</i> is not an <b>epoll</b> file descriptor, or <i>fd</i> is the same as <i>epfd</i>, or the requested operation <i>op</i> is not supported by this interface.<b>ENOENT</b><i>op</i> was <b>EPOLL_CTL_MOD</b> or <b>EPOLL_CTL_DEL</b>, and <i>fd</i> is not registered with this epoll instance.<b>ENOMEM</b>There was insufficient memory to handle the requested <i>op</i> control operation.</dt>
<dt><b>ENOSPC</b>The limit imposed by <i>/proc/sys/fs/epoll/max_user_watches</i> was encountered while trying to register (<b>EPOLL_CTL_ADD</b>) a new file descriptor on an epoll instance. See<b><a style="color: #660000;" href="http://linux.die.net/man/7/epoll" rel="nofollow">epoll</a></b>(7) for further details.<b>EPERM</b>The target file <i>fd</i> does not support <b>epoll</b>.</dt>
</dl>

#### Notes
<p>The <b>epoll</b> interface supports all file descriptors that support <b><a style="color: #660000;" href="http://linux.die.net/man/2/poll">poll</a></b>(2).</p>

#### Bugs

<p>In kernel versions before 2.6.9, the <b>EPOLL_CTL_DEL</b> operation required a non-NULL pointer in <i>event</i>, even though this argument is ignored. Since Linux 2.6.9, <i>event</i> can be specified as NULL when using <b>EPOLL_CTL_DEL</b>. Applications that need to be portable to kernels before 2.6.9 should specify a non-NULL pointer in <i>event</i>.</p>


### epoll_wait, epoll_pwait - wait for an I/O event on an epoll file descriptor

```c
#include <sys/epoll.h>

int epoll_wait(int epfd, struct epoll_event *events,
			  int maxevents, int timeout);
int epoll_pwait(int epfd, struct epoll_event *events,
			  int maxevents, int timeout,
			  const sigset_t *sigmask);
```

The <b>epoll_wait</b>() system call waits for events on the <b><a style="color: #660000;" href="http://linux.die.net/man/7/epoll">epoll</a></b>(7) instance referred to by the file descriptor <i>epfd</i>. The memory area pointed to by <i>events</i> will contain the events that will be available for the caller. Up to <i>maxevents</i> are returned by <b>epoll_wait</b>(). The <i>maxevents</i> argument must be greater than zero.

The <i>timeout</i> argument specifies the minimum number of milliseconds that <b>epoll_wait</b>() will block. (This interval will be rounded up to the system clock granularity, and kernel scheduling delays mean that the blocking interval may overrun by a small amount.) Specifying a <i>timeout</i> of -1 causes <b>epoll_wait</b>() to block indefinitely, while specifying a <i>timeout</i> equal to zero cause <b>epoll_wait</b>() to return immediately, even if no events are available.

The <i>data</i> of each returned structure will contain the same data the user set with an <b><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_ctl">epoll_ctl</a></b>(2) (<b>EPOLL_CTL_ADD</b>,<b>EPOLL_CTL_MOD</b>) while the <i>events</i> member will contain the returned event bit field.

#### epoll_pwait()

<dl compact="compact">
<dt>The relationship between <b>epoll_wait</b>() and <b>epoll_pwait</b>() is analogous to the relationship between <b><a style="color: #660000;" href="http://linux.die.net/man/2/select">select</a></b>(2) and <b><a style="color: #660000;" href="http://linux.die.net/man/2/pselect">pselect</a></b>(2): like <b><a style="color: #660000;" href="http://linux.die.net/man/2/pselect" rel="nofollow">pselect</a></b>(2), <b>epoll_pwait</b>() allows an application to safely wait until either a file descriptor becomes ready or until a signal is caught.The following <b>epoll_pwait</b>() call:
</dt>
</dl>

```c
ready = epoll_pwait(epfd, &events, maxevents, timeout, &sigmask);
```

<p>is equivalent to <i>atomically</i> executing the following calls:</p>

```c
sigset_t origmask;

sigprocmask(SIG_SETMASK, &sigmask, &origmask);
ready = epoll_wait(epfd, &events, maxevents, timeout);
sigprocmask(SIG_SETMASK, &origmask, NULL);
```

<p>The <i>sigmask</i> argument may be specified as NULL, in which case <b>epoll_pwait</b>() is equivalent to <b>epoll_wait</b>().</p>

#### Return Value

<p>When successful, <b>epoll_wait</b>() returns the number of file descriptors ready for the requested I/O, or zero if no file descriptor became ready during the requested <i>timeout</i>milliseconds. When an error occurs, <b>epoll_wait</b>() returns -1 and <i>errno</i> is set appropriately.</p>

#### Errors

<dl compact="compact">
<dt><b>EBADF</b><i>epfd</i> is not a valid file descriptor.<b>EFAULT</b>The memory area pointed to by <i>events</i> is not accessible with write permissions.<b>EINTR</b>The call was interrupted by a signal handler before either any of the requested events occurred or the <i>timeout</i> expired; see <b><a style="color: #660000;" href="http://linux.die.net/man/7/signal">signal</a></b>(7).<b>EINVAL</b><i>epfd</i> is not an <b>epoll</b> file descriptor, or <i>maxevents</i> is less than or equal to zero.</dt>
</dl>

#### Notes

<p>While one thread is blocked in a call to <b>epoll_pwait</b>(), it is possible for another thread to add a file descriptor to the waited-upon <b>epoll</b> instance. If the new file descriptor becomes ready, it will cause the <b>epoll_wait</b>() call to unblock.</p>
<p>For a discussion of what may happen if a file descriptor in an <b>epoll</b> instance being monitored by <b>epoll_wait</b>() is closed in another thread, see <b><a style="color: #660000;" href="http://linux.die.net/man/2/select" rel="nofollow">select</a></b>(2).</p>

#### Bugs

<p>In kernels before 2.6.37, a <i>timeout</i> value larger than approximately <i>LONG_MAX / HZ</i> milliseconds is treated as -1 (i.e., infinity). Thus, for example, on a system where the<i>sizeof(long)</i> is 4 and the kernel <i>HZ</i> value is 1000, this means that timeouts greater than 35.79 minutes are treated as infinity.</p>

### 使用流程

<p>首先通过<code>epoll_create(int size)</code>来创建一个epoll的句柄。这个函数会返回一个新的epoll句柄，之后的所有操作将通过这个句柄来进行操作。在用完之后，记得用close()来关闭这个创建出来的epoll句柄。</p>
<p>之后在你的网络主循环里面，每一帧的调用<code>epoll_wait(int epfd, epoll_event events, int max events, int timeout)</code>来查询所有的网络接口，看哪一个可以读，哪一个可以写了。基本的语法为：<br />
<code>nfds = epoll_wait(epfd, events, maxevents, -1);</code></p>
<p>其中<code>epfd</code>为用<code>epoll_create</code>创建之后的句柄，<code>events</code>是一个<code>epoll_event *</code>的指针，当<code>epoll_wait</code>这个函数操作成功之后，<code>epoll_events</code>里面将储存所有的读写事件。max_events是当前需要监听的所有socket句柄数。最后一个<code>timeout</code>是<code>epoll_wait</code>的超时，为0的时候表示马上返回，为-1的时候表示一直等下去，直到有事件返回，为任意正整数的时候表示等这么长的时间，如果一直没有事件，则返回。一般如果网络主循环是单独的线程的话，可以用-1来等，这样可以保证一些效率，如果是和主逻辑在同一个线程的话，则可以用0来保证主循环的效率。</p>
<p><code>epoll_wait</code>返回之后应该是一个循环，遍历所有的事件。man中给出了epoll的用法的example程序，其中使用的是ET模式，即，边沿触发，类似于电平触发，epoll中的边沿触发的意思是只对新到的数据进行通知，而内核缓冲区中如果是旧数据则不进行通知，所以在<code>do_use_fd</code>函数中应该使用循环读尽内核缓冲区中的数据。</p>

```c
for(;;) {
    len = recv(sockfd, buffer, buflen, 0);
    if (len == -1) {
        if(errno == EAGAIN)
            break;
        perror("recv");
        break;
    }
    //do something with the recved data......
}
```

<p>例子中没有说明对于listen socket fd该如何处理，有的时候会使用两个线程，一个用来监听accept另一个用来监听epoll_wait，如果是这样使用的话，则listen socket fd使用默认的阻塞方式就行了，而如果epoll_wait和accept处于一个线程中，即，全部由epoll_wait进行监听，则需将listen socket fd也设置成非阻塞的，这样一来，对accept也应该使用循环包起来以做多次accept（类似于上面的recv），<span style="color: #ff0000;">因为epoll_wait返回时只是说有连接到来了，并没有说有几个连接，而且在ET模式下epoll_wait不会再因为上一次的连接还没读完而返回，这种情况确实存在，也是容易出错的地方之一。</span>这里需要说明的是，每调用一次accept将从内核中的已连接队列中的队头读取一个连接，因为在并发访问的环境下，有可能有多个连接“同时”到达，而epoll_wait只返回了一次。</p>

### 各模式要点

<p>epoll模式分为ET边缘模式和LT水平模式；IO 模式有阻塞和非阻塞之分。</p>
<ol>
<li>ET边缘模式（listen socket fd）+非阻塞（listen socket fd)<br />
可以使用同一线程的epoll，但是应注意如果是 listen socket fd可读，应使用 while 重复 accept 多个连接</li>
<li>ET边缘模式（listen socket fd）+阻塞（listen socket fd）<br />
由于 listen socket fd 是阻塞的，accept 和 epoll 最好放在两个线程；否则因为listen socket fd 是 ET边缘模式，有一到多个连接过来，如果此时让该单线程while阻塞在 listen socket fd 的 accept上，程序将一直没有响应，如果不用while，而仅仅accept 一次，则会使得该次epoll事件中的后续连接无法 accept到。</li>
<li>LT水平模式（listen socket fd）+非阻塞（listen socket fd）<br />
可以使用同一线程epoll，不需要while重复accept多个连接</li>
<li>LT水平模式（listen socket fd）+阻塞（listen socket fd）<br />
此模式非常类似经典select、poll，相当于一个快速的poll</li>
</ol>

### epoll vs IOCP

<p>epoll 和 IOCP 都是为高性能网络服务器而设计的高效 I/O 模型；都是基于事件驱动的。事件驱动有个著名的好莱坞原则（“不要打电话给我们，我们会打电话给你”）。不同之处在于：</p>

* epoll 用于 Linux 系统；而 IOCP 则是用于 Windows
* epoll 是当事件资源满足时发出可处理通知消息；而 IOCP 则是当事件完成时发出完成通知消息。
* 从应用程序的角度来看， epoll 本质上来讲是同步非阻塞的，而 IOCP 本质上来讲则是异步操作；这是才二者最大的不同。

<p>就第 3 点来讲，还需要简单说说系统的 IO 模型。</p>

系统 IO 可以分成三种模型：阻塞 (blocking) ，同步非阻塞 (non-blocking synchronous) 和异步非阻塞 (non-blocking asynchronous):

* 阻塞模型调用者必须阻塞等待操作的完成，如果资源不可用，只能阻塞等待。是一种相当低效的模型。
* 同步非阻塞本质上依然是同步的，但是当资源不可用时，调用将会立即返回，并得到通知指示资源部可用；否则可以立即完成。

## Example Usage - epoll 服务器

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

#include <sys/epoll.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>

void evecho(const char *prefix, const struct epoll_event *events, int idx,
		const char *suffix) {
	if (NULL != prefix) {
		printf("%s:", prefix);
	}
	printf("events[%d].data.fd(%d)", idx, events[idx].data.fd);
	if (NULL != suffix) {
		printf(": %s", suffix);
	}
	if (NULL == suffix || 'n' != suffix[strlen(suffix)-1]) {
		putchar('n');
	}
}

void errpro(int condition, const char *errmsg) {
	if (condition) {
		perror(errmsg);
		exit(EXIT_FAILURE);
	}
}

int reuseaddr(int fd) {
	int opval = 1;
	errpro(-1 == setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (char *)&amp;opval,
				sizeof(opval)),
			"setsockopt");
	return 0;
}

int disblock(int fd) {
	int flags = fcntl(fd, F_GETFL);
	errpro(-1 == flags, "fcntl");
	errpro(-1 == fcntl(fd, F_SETFL, flags | O_NONBLOCK), "fcntl");
	return 0;
}

#define PORT	8888U
#define BACKLOG	16U
#define BUFLEN	64U
#define MAXCON	128U

int main() {
	struct sockaddr_in cli_addr, ser_addr;
	socklen_t addrlen = sizeof(sockaddr_in);
	int listenfd = socket(AF_INET, SOCK_STREAM, 0);
	errpro(-1 == listenfd, "socket");
	reuseaddr(listenfd);
	disblock(listenfd);    // enable non-blocking mode
	struct epoll_event ev, events[MAXCON];
	ev.data.fd = listenfd;
	ev.events = EPOLLIN|EPOLLET;
	int epfd = epoll_create(true);
	errpro(-1 == epfd, "epoll_create");
	errpro(-1 == epoll_ctl(epfd, EPOLL_CTL_ADD, listenfd, &amp;ev), "epoll_ctl");
	memset(&amp;ser_addr, 0, sizeof(sockaddr_in));
	ser_addr.sin_family = AF_INET;
	ser_addr.sin_addr.s_addr = htonl(INADDR_ANY);
	ser_addr.sin_port = htons(PORT);
	errpro(-1 == bind(listenfd, (struct sockaddr *)&amp;ser_addr,
				addrlen), "bind");
	errpro(-1 == listen(listenfd, BACKLOG), "listen");
	static int loop = 0;
	for (;;) {
		printf("loop %dn", ++loop);
		int timeout = 10000; // 10 seconds
		int nfds = epoll_wait(epfd, events, MAXCON, timeout);
		errpro(-1 == nfds, "epoll_wait");
		if (0 == nfds) {
			printf("timeoutn");
			continue;
		}
		for (int i = 0; i &lt; nfds; ++i) {
			if (events[i].data.fd == listenfd) { // new connection(s)
				evecho(NULL, events, i, "ready for connection");
				while (true) {
					int fd = accept(listenfd, (sockaddr *)&amp;cli_addr, &amp;addrlen);
					errpro(-1 == fd &amp;&amp; EWOULDBLOCK != errno, "accept");
					if (EWOULDBLOCK == errno) {
						errno = 0; // already accept all the incoming conn(s)
						break;
					}
					printf("accepted: %s, fd: %dn", inet_ntoa(cli_addr.sin_addr), fd);
					disblock(fd);
					ev.data.fd = fd;
					ev.events = EPOLLIN|EPOLLET;
					errpro(-1 == epoll_ctl(epfd, EPOLL_CTL_ADD, fd, &amp;ev),
							"epoll_ctl");
				}
			} // data ready from established connections
			else if (EPOLLIN &amp; events[i].events) {
				evecho(NULL, events, i, "ready for read");
				if (-1 == events[i].data.fd) {
					evecho("closed fd", events, i, NULL);
					continue;
				}
				char buf[BUFLEN];
				int n = read(events[i].data.fd, buf, BUFLEN-1);
				if ((-1 == n &amp;&amp; ECONNRESET == errno) || 0 == n) {
					evecho("close", events, i,
							-1 == n ? "cause ECONNRESET":"cause read 0 byte");
					close(events[i].data.fd);
					events[i].data.fd = -1;
				}
				errpro(-1 == n, "read");
				buf[n] = ' ';
				evecho("message from", events, i, buf);
				ev.data.fd = events[i].data.fd;
				ev.events = EPOLLOUT|EPOLLET;
				errpro(-1 == epoll_ctl(epfd, EPOLL_CTL_MOD, events[i].data.fd,
							&amp;ev), "epoll_ctl");
			} // fd ready for write
			else if (EPOLLOUT &amp; events[i].events) {
				evecho(NULL, events, i, "ready for write");
				char msg[] = "-&gt;reply from servern";
				errpro(-1 == write(events[i].data.fd, msg, strlen(msg)),
						"write");
				ev.data.fd = events[i].data.fd;
				ev.events = EPOLLIN|EPOLLET;
				errpro(-1 == epoll_ctl(epfd, EPOLL_CTL_MOD, events[i].data.fd,
							&amp;ev), "epoll_ctl");
			} else { // non-sense
				errpro(EXIT_FAILURE, "unknow error");
			}
		}
	}
	close(epfd);

	return 0;
}
```

## 进阶

此段文字为引用，留待实践证明。

<blockquote>
<ol>
<li>首先需要一个内存池，目的在于：减少频繁的分配和释放，提高性能的同时，还能避免内存碎片的问题；<br />
能够存储变长的数据，不要很傻瓜地只能预分配一个最大长度；<br />
基于SLAB算法实现内存池是一个好的思路：分配不同大小的多个块，请求时返回大于请求长度的最小块即可，对于容器而言，处理固定块的分配和回收，相当容易实现。当然，还要记得需要设计成线程安全的，自旋锁比较好，使用读写自旋锁就更好了。<br />
分配内容的增长管理是一个问题，比如第一次需要1KB空间，随着数据源源不断的写入，第二次就需要4KB空间了。扩充空间容易实现，可是扩充的时候必然 涉及数据拷贝。甚至，扩充的需求很大，上百兆的数据，这样就不好办了。暂时没更好的想法，可以像STL一样，指数级增长的分配策略，拷贝数据虽不可避免， 但是起码重分配的几率越来越小了。<br />
上面提到的，如果是上百兆的数据扩展需要，采用内存映射文件来管理是一个好的办法：映射文件后，虽然占了很大的虚拟内存，但是物理内存仅在写入的时候才会被分配，加上madvice()来加上顺序写的优化建议后，物理内存的消耗也会变小。<br />
用string或者vector去管理内存并不明智，虽然很简单，但服务器软件开发中不适合使用STL，特别是对稳定性和性能要求很高的情况下。</li>
<li>第二个需要考虑的是对象池，与内存池类似：减少对象的分配和释放。其实C++对象也就是struct，把构造和析构脱离出来手动初始化和清理，保持对同一个缓冲区的循环利用，也就不难了。<br />
可以设计为一个对象池只能存放一种对象，则对象池的实现实际就是固定内存块的池化管理，非常简单。毕竟，对象的数量非常有限。</li>
<li>第三个需要的是队列：如果可以预料到极限的处理能力，采用固定大小的环形队列来作为缓冲区是比较不错的。一个生产者一个消费者是常见的应用场景，环形队列有其经典的“锁无关”算法，在一个线程读一个线程写的场景下，实现简单，性能还高，还不涉及资源的分配和释放。好啊，实在是好！<br />
涉及多个生产者消费者的时候，<code>tbb::concurent_queue</code>是不错的选择，线程安全，并发性也好，就是不知道资源的分配释放是否也管理得足够好。</li>
<li>第四个需要的是映射表，或者说hash表：因为epoll是事件触发的，而一系列的流程可能是分散在多个事件中的，因此，必须保留下中间状态，使得下一个事件触发的时候，能够接着上次处理的位置继续处理。要简单的话，STL的hash_map还行，不过得自己处理锁的问题，多线程环境下使用起来很麻烦。<br />
多线程环境下的hash表，最好的还是<code>tbb::concurent_hash_map</code>。</li>
<li>核心的线程是事件线程：<br />
事件线程是调用epoll_wait()等待事件的线程。例子代码里面，一个线程干了所有的事情，而需要开发一个高性能的服务器的时候，事件线程应该专注于事件本身的处理，将触发事件的socket句柄放到对应的处理队列中去，由具体的处理线程负责具体的工作。</li>
<li>accept()单独一个线程：<br />
服务端的socket句柄（就是调用bind()和listen()的这个）最好在单独的一个线程里面做accept()，阻塞还是非阻塞都无所谓，相比整个服务器的通讯，用户接入的动作只是很小一部分。而且，accept()不放在事件线程的循环里面，减少了判断。</li>
<li>接收线程单独一个：<br />
接收线程从发生EPOLLIN事件的队列中取出socket句柄，然后在这个句柄上调用recv接收数据，直到缓冲区没有数据为止。接收到的数据写入以socket为键的hash表中，hash表中有一个自增长的缓冲区，保存了客户端发过来的数据。这样的处理方式适合于客户端发来的数据很小的应用，比如HTTP服务器之类；假设是文件上传的服务器，则接受线程会一直处理某个连接的海量数据，其他客户端的数据处理产生了饥饿。所以，如果是文件上传服务器一类的场景，就不能这样设计。</li>
<li>发送线程单独一个：<br />
发送线程从发送队列获取需要发送数据的SOCKET句柄，在这些句柄上调用send()将数据发到客户端。队列中指保存了SOCKET句柄，具体的信息 还需要通过socket句柄在hash表中查找，定位到具体的对象。如同上面所讲，客户端信息的对象不但有一个变长的接收数据缓冲区，还有一个变长的发送 数据缓冲区。具体的工作线程发送数据的时候并不直接调用send()函数，而是将数据写到发送数据缓冲区，然后把SOCKET句柄放到发送线程队列。SOCKET句柄放到发送线程队列的另一种情况是：事件线程中发生了EPOLLOUT事件，说明TCP的发送缓冲区又有了可用的空间，这个时候可以把SOCKET句柄放到发送线程队列，一边触发send()的调用；需要注意的是：发送线程发送大量数据的时候，当频繁调用send()直到TCP的发送缓冲区满后，便无法再发送了。这个时候如果循环等待，则其他用户的 发送工作受到影响；如果不继续发送，则EPOLL的ET模式可能不会再产生事件。解决这个问题的办法是在发送线程内再建立队列，或者在用户信息对象上设置 标志，等到线程空闲的时候，再去继续发送这些未发送完成的数据。</li>
<li>需要一个定时器线程：<br />
一位将epoll使用的高手说道：“单纯靠epoll来管理描述符不泄露几乎是不可能的。完全解决方案很简单，就是对每个fd设置超时时间，如果超过timeout的时间，这个fd没有活跃过，就close掉”。所以，定时器线程定期轮训整个hash表，检查socket是否在规定的时间内未活动。未活动的SOCKET认为是超时，然后服务器主动关闭句柄，回收资源。</li>
<li>多个工作线程：<br />
工作线程由接收线程去触发：每次接收线程收到数据后，将有数据的SOCKET句柄放入一个工作队列中；工作线程再从工作队列获取SOCKET句柄，查询hash表，定位到用户信息对象，处理业务逻辑。工作线程如果需要发送数据，先把数据写入用户信息对象的发送缓冲区，然后把SOCKET句柄放到发送线程队列中去。对于任务队列，接收线程是生产者，多个工作线程是消费者；对于发送线程队列，多个工作线程是生产者，发送线程是消费者。在这里需要注意锁的问题，如果采用tbb::concurrent_queue，会轻松很多。</li>
<li>仅仅只用scoket句柄作为hash表的键，并不够：<br />
假设这样一种情况：事件线程刚把某SOCKET因发生EPOLLIN事件放入了接收队列，可是随即客户端异常断开了，事件线程又因为EPOLLERR事 件删除了hash表中的这一项。假设接收队列很长，发生异常的SOCKET还在队列中，等到接收线程处理到这个SOCKET的时候，并不能通过 SOCKET句柄索引到hash表中的对象。索引不到的情况也好处理，难点就在于，这个SOCKET句柄立即被另一个客户端使用了，接入线程为这个SCOKET建立了hash表中的某个对象。此时，句柄相同的两个SOCKET，其实已经是不同的两个客户端了。极端情况下，这种情况是可能发生的。解决的办法是，使用socket fd + sequence为hash表的键，sequence由接入线程在每次accept()后将一个整型值累加而得到。这样，就算SOCKET句柄被重用，也不会发生问题了。</li>
<li>监控，需要考虑：<br />
框架中最容易出问题的是工作线程：工作线程的处理速度太慢，就会使得各个队列暴涨，最终导致服务器崩溃。因此必须要限制每个队列允许的最大大小，且需要监视每个工作线程的处理时间，超过这个时间就应该采用某个办法结束掉工作线程。</li>
</ol>
</blockquote>

## References

<ol id="refs" class="refs">
<li><a href="http://m.blog.csdn.net/blog/lingfengtengfei/12398299">http://m.blog.csdn.net/blog/lingfengtengfei/12398299</a></li>
<li><a href="http://www.ibm.com/developerworks/cn/aix/library/au-libev/">http://www.ibm.com/developerworks/cn/aix/library/au-libev/</a></li>
<li><a title="EPOLL_CTL_DISABLE and multithreaded applications" href="https://lwn.net/Articles/520012/" target="_blank">EPOLL_CTL_DISABLE and multithreaded applications</a></li>
<li><a title="EPOLL_CTL_DISABLE and multithreaded applications" href="https://lwn.net/Articles/520198/" target="_blank">EPOLL_CTL_DISABLE, epoll, and API design</a></li>
<li><a title="Event Queues and Threads" href="https://raw.githubusercontent.com/dankamongmen/libtorque/master/doc/mteventqueues" target="_blank">Event Queues and Threads</a></li>
</ol>
