---
layout: post
title: Linux poll
date: 2014-05-03 22:21:09.000000000 +08:00
type: post
published: true
status: publish
categories:
- Linux
- UNIX
tags:
- network
- poll
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---

## 介绍

最近在看 Linux/Unix 网络编程，写了三篇关于 select、poll 和 epoll 的文章。<a title="Linux select" href="http://xinyi.sourceforge.net/linux-select/" target="_blank">第一篇</a>介绍select，本篇介绍poll，<a style="color: #0095da;" title="Linux epoll" href="http://xinyi.sourceforge.net/linux-epool/" target="_blank">第三篇</a>介绍 epoll。

<!--more-->

* TOC
{:toc}

## man 手册

Name
: poll, ppoll - wait for some event on a file descriptor

## Synopsis

{% highlight c %}
#include <poll.h>

int poll(struct pollfd *fds, nfds_t nfds, int timeout);

#define _GNU_SOURCE         /* See feature_test_macros(7) */
#include <poll.h>

int ppoll(struct pollfd *fds, nfds_t nfds,
        const struct timespec *timeout_ts, const sigset_t *sigmask);
{% endhighlight %}

## Description

`poll()` 执行与 <b><a href="http://linux.die.net/man/2/select">select</a></b>(2) 类似的任务: 等待一系列文件描述符中任意一个为 I/O 读写准备就绪。

提到的文件描述符集合使用 <i>fds</i> 参数指定, 是一个下面结构体的数组：

{% highlight c %}
struct pollfd {
    int   fd;         /* file descriptor */
    short events;     /* requested events */
    short revents;    /* returned events */
};
{% endhighlight %}

调用者应该用 <i>nfds</i> 来指定<i>  fds</i> 数组的大小。

成员 <i>fd</i> 包含了一个打开的文件描述符。如果为负，则对应的 <i>events</i> 成员会被忽略，并且 <i>revents</i> 成员返回0。 (这就为在单次 <b>poll</b>() 调用中忽略一个文件描述符提供了一种简单方法：可以把 <i>fd</i> 成员设为负值。)

<i>events</i> 成员是个输入参数，使用位掩码指定了应用对文件描述符<em>fd</em>感兴趣的事件。如果这个成员为0，则<i>fd</i>的所有事件被忽略而且 <i>revents </i>返回0<i>。</i>

<i>revents</i> 成员是个输出参数，是由内核按照实际发生的事件填充的。由 <i>revents</i> 返回的位中可以包含任何由 <i>events </i>指定的, 或者 <b>POLLERR</b>, <b>POLLHUP </b>和 <b>POLLNVAL</b> 三者之一。 (这三位在 <i>events</i> 成员中是无意义的, 当对应的情况为真的时候 <i>revents</i> 成员中对应的位会被设置。)

If none of the events requested (and no error) has occurred for any of the file descriptors, then <b>poll</b>() blocks until one of the events occurs.

<i>timeout</i> 参数指定了 <b>poll</b>() 将会阻塞的最小毫秒值。 (这个区间大小会按照系统时钟粒度向上取整，另外内核调度延时意味着可能会超过阻塞间隔一点点。) 指定一个负值给 <i>timeout</i> 意味着不存在超时。给 <i>timeout</i> 取0值会使 <b>poll</b>() 即使没有文件描述符就绪也立即返回。

The bits that may be set/returned in <i>events</i> and <i>revents</i> are defined in <i><<a href="http://linux.die.net/include/poll.h" rel="nofollow">poll.h</a>></i>:

POLLIN
: 有数据要读

POLLPRI
: 有紧急数据等待读取(e.g., out-of-band data on TCP socket; pseudoterminal master in packet mode has seen state change in slave).

POLLOUT
: 现在写则不会阻塞

POLLRDHUP (since Linux 2.6.17)
: Stream socket peer closed connection, or shut down writing half of connection. 必须定义 `_GNU_SOURCE` (在包含任何头文件之前) 特性宏来获得这个定义

POLLERR
: Error condition (output only)

POLLHUP
: Hang up (output only)

POLLNVAL
: 无效请求: <i>fd</i> 未打开 (output only)

When compiling with `_XOPEN_SOURCE` defined, one also has the following, which convey no further information beyond the bits listed above:

POLLRDNORM

等同于 POLLIN

POLLRDBAND
: Priority band data can be read (generally unused on Linux)

POLLWRNORM

等同于 POLLOUT

POLLWRBAND
: Priority data may be written

Linux 了解但不使用 POLLMSG

<p><b>ppoll()</b></p>
<dl compact="compact">
<dt><b>poll</b>() 和 <b>ppoll</b>() 的关系类似于 <b><a href="http://linux.die.net/man/2/select" rel="nofollow">select</a></b>(2) 和 <b><a href="http://linux.die.net/man/2/pselect">pselect</a></b>(2) 的关系: 如同 <b><a href="http://linux.die.net/man/2/pselect" rel="nofollow">pselect</a></b>(2), <b>ppoll</b>() 允许一个应用安全的等待直到任意一个文件描述符变为就绪状态或者捕捉到一个信号。而不是 <em>timeout</em> 参数的精度不同，下面的 <b>ppoll</b>() 调用:</dt>
</dl>
<pre class="code">ready = ppoll(&amp;fds, nfds, timeout_ts, &amp;sigmask);</pre>
<p>等同于原子执行下面的调用:</p>

{% highlight c %}
sigset_t origmask;
int timeout;

timeout = (timeout_ts == NULL) ? -1 :
           (timeout_ts.tv_sec * 1000 + timeout_ts.tv_nsec / 1000000);
 sigprocmask(SIG_SETMASK, &amp;sigmask, &amp;origmask);
 ready = poll(&amp;fds, nfds, timeout);
 sigprocmask(SIG_SETMASK, &amp;origmask, NULL);
{% endhighlight %}

<b>之所以 ppoll</b>() 是必须的的原因请参见 <b><a href="http://linux.die.net/man/2/pselect" rel="nofollow">pselect</a></b>(2) 的描述。如果 <i>sigmask</i> 参数指定为 NULL, 信号掩码操作就不会被执行 (这样的话 <b>ppoll</b>() 和 <b>poll</b>() 就只有 <i>timeout </i>参数的精度不同了).

<i>timeout_ts</i> 参数指定了<b>ppoll</b>() 将会阻塞的时间上限。这个参数是一个指向下面结构的指针:

{% highlight c %}
struct timespec {
    long    tv_sec;         /* seconds */
    long    tv_nsec;        /* nanoseconds */
};
{% endhighlight %}

如果 <i>timeout_ts</i> 参数设为 NULL, <b>ppoll</b>() 将会一直(
<dl>
<dt>indefinitely</dt>
<dd>adv. 不确定地，无限期地；模糊地，不明确地</dd>
</dl>
)阻塞。
<h2>返回值</h2>
<p>成功时返回正值，代表具有非0 <i>revents </i>成员的结构体的数目(换言之, 那些描述符有事件或者错误报告的)。 0表示超时，没有文件描述符就绪事件。错误的时候返回-1，且适当设置 errno。</p>

## Errors

<dl compact="compact">
<dt><b>EFAULT</b></dt>
<dd>作为参数的数组不在调用程序的地址空间中。</dd>
<dt><b>EINTR</b></dt>
<dd>在请求的事件发生之前有信号发生。参见 <b><a href="http://linux.die.net/man/7/signal">signal</a></b>(7).</dd>
<dt><b>EINVAL</b></dt>
<dd><i>nfds</i> 值超过了 <b>RLIMIT_NOFILE</b> 值。</dd>
<dt><b>ENOMEM</b></dt>
<dd>没有足够的内存分配给文件描述符表。</dd>
</dl>

## Versions

<b>poll</b>() 系统调用在 Linux 2.1.23 中引入。 在没有这个系统调用的旧内核中，glibc (and the old Linux libc) <b>poll</b>() wrapper function 提供了使用 <b><a href="http://linux.die.net/man/2/select" rel="nofollow">select</a></b>(2) 模拟的版本。

<b>ppoll</b>() 系统调用 在 Linux kernel 2.6.16 中加入。库函数 <b>ppoll</b>() 在 glibc 2.4中加入。

## Conforming To
`poll()` conforms to POSIX.1-2001. `ppoll()` is Linux-specific.

## Notes

有些实现中定义了非标准常亮 `INFTIM` 为-1，用作  `poll()` 的 `timeout` 参数值。glibc 中没有提供这个常量。

关于如果在另一个线程中关闭了 `poll()` 监视的文件描述符的情况，请参考 [`select`(2)](http://linux.die.net/man/2/select)

### Linux notes

Linux `ppoll()` 系统调用会修改 `timeout_ts` 参数。但是, glibc wrapper function 通过使用一个timeout的局部变量传递给系统调用而隐藏了这一行为。因此，glibc `ppoll()` function 不修改 `timeout_ts` 参数。

## Bugs

请参考 [`select`(2)](http://linux.die.net/man/2/select) BUGS 一节中有关假就绪通知的讨论。

## 实例程序

使用poll做简单服务器模型

{% highlight c %}
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <unistd.h>

#include <poll.h>
#include <sys/select.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>

void errpro(int condition, const char *errmsg) {
	if (condition) {
		perror(errmsg);
		exit(EXIT_FAILURE);
	}
}

#define PORT	8888U
#define BACKLOG	16U
#define BUFLEN	64U
#define MAXCON	128U

int main() {
	char buf[BUFLEN+1];
	struct sockaddr_in server_addr, client_addr;
	int listen_fd = socket(AF_INET, SOCK_STREAM, 0);
	errpro(-1 == listen_fd, "socket");
	memset(&amp;server_addr, 0, sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons(PORT);
	server_addr.sin_addr.s_addr = htonl(INADDR_ANY);
	errpro(-1 == bind(listen_fd, (struct sockaddr *)&amp;server_addr,
				sizeof(server_addr)), "bind");
	errpro(-1 == listen(listen_fd, BACKLOG), "listen");
	struct pollfd fds[MAXCON];
	fds[0].fd = listen_fd;
	fds[0].events = POLLIN;
	int nfds = 1;
	int i;
	for (i = 1; i < MAXCON; ++i) {
		fds[i].fd = -1;
	}
	int concnt = 0; // current connections count
	static int loop = 0;
	for (;;) {
		printf("loop %dn", ++loop);
		int ret = poll(fds, nfds, 10000);
		errpro(-1 == ret, "poll");
		if (0 == ret) {
			printf("timeoutn");
			break;
		}
		if (fds[0].revents &amp; POLLIN) {
			int sockfd = accept(listen_fd, NULL, NULL);
			errpro(-1 == sockfd, "accept");
			++concnt;
			for (i = 0; i < MAXCON; ++i) {
				if (fds[i].fd < 0) {
					fds[i].fd = sockfd;
					fds[i].events = POLLIN;
					printf("accept fds[%d] = %dn", i, sockfd);
					break;
				}
			}
			errpro(MAXCON == i, "too many connections");
			if (i+1 > nfds) {
				nfds = i+1;
			}
		}

		// read data
		for (i = 1; i < nfds; ++i) {
			if (fds[i].fd < 0) {
				printf("skippedn");
			} else if (fds[i].revents &amp; POLLIN) {
				int ret = recv(fds[i].fd, buf, BUFLEN, 0);
				errpro(-1 == ret, "recv");
				if (0 == ret) {
					printf("close fds[%d]n", i);
					close(fds[i].fd);
					fds[i].fd = -1;
				}
				buf[ret] = ' ';
				printf("message from %d:n%s", i, buf);
				while (BUFLEN == ret) {
					ret = recv(fds[i].fd, buf, BUFLEN, 0);
					errpro(-1 == ret, "recv");
				}
			} else if (fds[i].revents &amp; POLLERR) {
				printf("fds[%d] errorn", i);
				errpro(EXIT_FAILURE, "POLLERR");
			}
		} // end of read data
	}

	return 0;
}
{% endhighlight %}

## References

* [`poll(2)`](http://linux.die.net/man/2/poll)
