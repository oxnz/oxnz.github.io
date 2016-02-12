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
<h2 id="intro">介绍</h2>
<p>最近在看 Linux/Unix 网络编程，谢了三篇关于 select、poll 和 epoll 的文章。<a title="Linux select" href="http://xinyi.sourceforge.net/linux-select/" target="_blank">第一篇</a>介绍select，本篇介绍poll，<a style="color: #0095da;" title="Linux epoll" href="http://xinyi.sourceforge.net/linux-epool/" target="_blank">第三篇</a>介绍 epoll。</p>
<ol>
<li><a href="#intro">介绍</a>
<ol>
<li><a href="#man-2-poll">man poll</a></li>
</ol>
</li>
<li><a href="#example-program">实例程序</a></li>
<li><a href="#summary">总结</a></li>
</ol>
<p><!--more--></p>
<h2>man 手册</h2>
<blockquote id="man-2-poll">
<h2>Name</h2>
<p>poll, ppoll - wait for some event on a file descriptor</p>
<h2>Synopsis</h2>
<pre class="lang:default decode:true">#include &lt;poll.h&gt;

int poll(struct pollfd *fds, nfds_t nfds, int timeout);

#define _GNU_SOURCE         /* See feature_test_macros(7) */
#include &lt;poll.h&gt;

int ppoll(struct pollfd *fds, nfds_t nfds,
        const struct timespec *timeout_ts, const sigset_t *sigmask);</pre>
<h2>Description</h2>
<p><b>poll</b>() 执行与 <b><a href="http://linux.die.net/man/2/select">select</a></b>(2) 类似的任务: 等待一系列文件描述符中任意一个为 I/O 读写准备就绪。</p>
<p>提到的文件描述符集合使用 <i>fds</i> 参数指定, 是一个下面结构体的数组：</p>
<pre class="code">struct pollfd {
    int   fd;         /* file descriptor */
    short events;     /* requested events */
    short revents;    /* returned events */
};</pre>
<p>调用者应该用 <i>nfds</i> 来指定<i>  fds</i> 数组的大小。</p>
<p>成员 <i>fd</i> 包含了一个打开的文件描述符。如果为负，则对应的 <i>events</i> 成员会被忽略，并且 <i>revents</i> 成员返回0。 (这就为在单次 <b>poll</b>() 调用中忽略一个文件描述符提供了一种简单方法：可以把 <i>fd</i> 成员设为负值。)</p>
<p><i>events</i> 成员是个输入参数，使用位掩码指定了应用对文件描述符<em>fd</em>感兴趣的事件。如果这个成员为0，则<i>fd</i>的所有事件被忽略而且 <i>revents </i>返回0<i>。</i></p>
<p><i>revents</i> 成员是个输出参数，是由内核按照实际发生的事件填充的。由 <i>revents</i> 返回的位中可以包含任何由 <i>events </i>指定的, 或者 <b>POLLERR</b>, <b>POLLHUP </b>和 <b>POLLNVAL</b> 三者之一。 (这三位在 <i>events</i> 成员中是无意义的, 当对应的情况为真的时候 <i>revents</i> 成员中对应的位会被设置。)</p>
<p>If none of the events requested (and no error) has occurred for any of the file descriptors, then <b>poll</b>() blocks until one of the events occurs.</p>
<p><i>timeout</i> 参数指定了 <b>poll</b>() 将会阻塞的最小毫秒值。 (这个区间大小会按照系统时钟粒度向上取整，另外内核调度延时意味着可能会超过阻塞间隔一点点。) 指定一个负值给 <i>timeout</i> 意味着不存在超时。给 <i>timeout</i> 取0值会使 <b>poll</b>() 即使没有文件描述符就绪也立即返回。</p>
<p>The bits that may be set/returned in <i>events</i> and <i>revents</i> are defined in <i>&lt;<a href="http://linux.die.net/include/poll.h" rel="nofollow">poll.h</a>&gt;</i>:</p>
<dl compact="compact">
<dd><b>POLLIN</b> 有数据要读。</p>
<dl compact="compact">
<dd><b>POLLPRI</b></dd>
</dl>
<p>有紧急数据等待读取(e.g., out-of-band data on TCP socket; pseudoterminal master in packet mode has seen state change in slave).</p>
<dl compact="compact">
<dd><b>POLLOUT</b></dd>
</dl>
<p>现在写则不会阻塞。</p>
<dl compact="compact">
<dd><b>POLLRDHUP</b> (since Linux 2.6.17)</dd>
</dl>
<p>Stream socket peer closed connection, or shut down writing half of connection. 必须定义 <b>_GNU_SOURCE</b> (在包含任何头文件之前) 特性宏来获得这个定义。</p>
<dl compact="compact">
<dd><b>POLLERR</b></dd>
</dl>
<p>Error condition (output only).</p>
<dl compact="compact">
<dd><b>POLLHUP</b></dd>
</dl>
<p>Hang up (output only).</p>
<dl compact="compact">
<dd><b>POLLNVAL</b></dd>
</dl>
<p>无效请求: <i>fd</i> 未打开 (output only).</p>
<dl compact="compact">
<dt>When compiling with <b>_XOPEN_SOURCE</b> defined, one also has the following, which convey no further information beyond the bits listed above:</dt>
<dd><b>POLLRDNORM</b></dd>
</dl>
<p>等同于 <b>POLLIN</b>.</p>
<dl compact="compact">
<dd><b>POLLRDBAND</b></dd>
</dl>
<p>Priority band data can be read (generally unused on Linux).</p>
<dl compact="compact">
<dd><b>POLLWRNORM</b></dd>
</dl>
<p>等同于 <b>POLLOUT</b>.</p>
<dl compact="compact">
<dd><b>POLLWRBAND</b></dd>
</dl>
<p>Priority data may be written.</p>
<dl compact="compact">
<dt>Linux 了解但不使用 <b>POLLMSG</b>.</dt>
</dl>
<p><b>ppoll()</b></p>
<dl compact="compact">
<dt><b>poll</b>() 和 <b>ppoll</b>() 的关系类似于 <b><a href="http://linux.die.net/man/2/select" rel="nofollow">select</a></b>(2) 和 <b><a href="http://linux.die.net/man/2/pselect">pselect</a></b>(2) 的关系: 如同 <b><a href="http://linux.die.net/man/2/pselect" rel="nofollow">pselect</a></b>(2), <b>ppoll</b>() 允许一个应用安全的等待直到任意一个文件描述符变为就绪状态或者捕捉到一个信号。而不是 <em>timeout</em> 参数的精度不同，下面的 <b>ppoll</b>() 调用:</dt>
</dl>
<pre class="code">ready = ppoll(&amp;fds, nfds, timeout_ts, &amp;sigmask);</pre>
<p>等同于原子执行下面的调用:</p>
<pre class="code"> sigset_t origmask;
 int timeout;

timeout = (timeout_ts == NULL) ? -1 :
           (timeout_ts.tv_sec * 1000 + timeout_ts.tv_nsec / 1000000);
 sigprocmask(SIG_SETMASK, &amp;sigmask, &amp;origmask);
 ready = poll(&amp;fds, nfds, timeout);
 sigprocmask(SIG_SETMASK, &amp;origmask, NULL);</pre>
<p><b>之所以 ppoll</b>() 是必须的的原因请参见 <b><a href="http://linux.die.net/man/2/pselect" rel="nofollow">pselect</a></b>(2) 的描述。如果 <i>sigmask</i> 参数指定为 NULL, 信号掩码操作就不会被执行 (这样的话 <b>ppoll</b>() 和 <b>poll</b>() 就只有 <i>timeout </i>参数的精度不同了).</p>
<p><i>timeout_ts</i> 参数指定了<b>ppoll</b>() 将会阻塞的时间上限。这个参数是一个指向下面结构的指针:</p>
<pre class="code">struct timespec {
    long    tv_sec;         /* seconds */
    long    tv_nsec;        /* nanoseconds */
};</pre>
<p>如果 <i>timeout_ts</i> 参数设为 NULL, <b>ppoll</b>() 将会一直(</p>
<dl>
<dt>indefinitely</dt>
<dd>adv. 不确定地，无限期地；模糊地，不明确地</dd>
</dl>
<p>)阻塞。</p>
<h2>返回值</h2>
<p>成功时返回正值，代表具有非0 <i>revents </i>成员的结构体的数目(换言之, 那些描述符有事件或者错误报告的)。 0表示超时，没有文件描述符就绪事件。错误的时候返回-1，且适当设置 errno。</p>
<h2>Errors</h2>
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
<h2>Versions</h2>
<p><b>poll</b>() 系统调用在 Linux 2.1.23 中引入。 在没有这个系统调用的旧内核中，glibc (and the old Linux libc) <b>poll</b>() wrapper function 提供了使用 <b><a href="http://linux.die.net/man/2/select" rel="nofollow">select</a></b>(2) 模拟的版本。</p>
<p><b>ppoll</b>() 系统调用 在 Linux kernel 2.6.16 中加入。库函数 <b>ppoll</b>() 在 glibc 2.4中加入。</p>
<h2>Conforming To</h2>
<p><b>poll</b>() conforms to POSIX.1-2001. <b>ppoll</b>() is Linux-specific.</p>
<h2>Notes</h2>
<p>有些实现中定义了非标准常亮 <b>INFTIM</b> 为-1，用作  <b>poll</b>() 的 <i>timeout </i>参数值。glibc 中没有提供这个常量。</p>
<p>关于如果在另一个线程中关闭了<b>poll</b>()监视的文件描述符的情况，请参考 <b><a style="color: #660000;" href="http://linux.die.net/man/2/select" rel="nofollow">select</a></b>(2).</p>
<p><b>Linux notes</b></p>
<dl compact="compact">
<dt>Linux <b>ppoll</b>() 系统调用会修改 <i>timeout_ts</i> 参数。但是, glibc wrapper function 通过使用一个timeout的局部变量传递给系统调用而隐藏了这一行为。因此，glibc <b>ppoll</b>() function 不修改 <i>timeout_ts</i> 参数。</dt>
</dl>
<h2>Bugs</h2>
<p>请参考 <b><a href="http://linux.die.net/man/2/select" rel="nofollow">select</a></b>(2) BUGS 一节中有关假就绪通知的讨论。</p>
<h2>See Also</h2>
<p><b><a href="http://linux.die.net/man/2/select" rel="nofollow">select</a></b>(2), <b><a href="http://linux.die.net/man/2/select_tut">select_tut</a></b>(2), <b><a href="http://linux.die.net/man/7/time">time</a></b>(7)</p>
<h2>Referenced By</h2>
<p><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/2/accept4" rel="nofollow">accept4</a></b><span style="color: #000000;">(2), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/2/connect" rel="nofollow">connect</a></b><span style="color: #000000;">(2), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/8/coroipc_overview" rel="nofollow">coroipc_overview</a></b><span style="color: #000000;">(8), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/cp_httpclient_ctl" rel="nofollow">cp_httpclient_ctl</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/cp_httpclient_fetch" rel="nofollow">cp_httpclient_fetch</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/4/epoll" rel="nofollow">epoll</a></b><span style="color: #000000;">(4), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/7/epoll" rel="nofollow">epoll</a></b><span style="color: #000000;">(7), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/2/epoll_ctl" rel="nofollow">epoll_ctl</a></b><span style="color: #000000;">(2), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/ev" rel="nofollow">ev</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/event" rel="nofollow">event</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/2/eventfd" rel="nofollow">eventfd</a></b><span style="color: #000000;">(2), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/1/explain" rel="nofollow">explain</a></b><span style="color: #000000;">(1),</span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/explain" rel="nofollow">explain</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/explain_poll" rel="nofollow">explain_poll</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/explain_poll_or_die" rel="nofollow">explain_poll_or_die</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/2/fcntl" rel="nofollow">fcntl</a></b><span style="color: #000000;">(2), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/ieee1284_get_irq_fd" rel="nofollow">ieee1284_get_irq_fd</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/7/inotify" rel="nofollow">inotify</a></b><span style="color: #000000;">(7), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/ivykis" rel="nofollow">ivykis</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/5/ldap.conf" rel="nofollow">ldap.conf</a></b><span style="color: #000000;">(5), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/ldap_set_option" rel="nofollow">ldap_set_option</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/libdlm" rel="nofollow">libdlm</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/libssh2_poll" rel="nofollow">libssh2_poll</a></b><span style="color: #000000;">(3),</span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/7/mq_overview" rel="nofollow">mq_overview</a></b><span style="color: #000000;">(7), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/7/nfsd" rel="nofollow">nfsd</a></b><span style="color: #000000;">(7), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/8/omping" rel="nofollow">omping</a></b><span style="color: #000000;">(8), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/pcap_get_selectable_fd" rel="nofollow">pcap_get_selectable_fd</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/2/perf_event_open" rel="nofollow">perf_event_open</a></b><span style="color: #000000;">(2), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/2/perfmonctl" rel="nofollow">perfmonctl</a></b><span style="color: #000000;">(2), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/7/pipe" rel="nofollow">pipe</a></b><span style="color: #000000;">(7), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/pmloop" rel="nofollow">pmloop</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/2/prctl" rel="nofollow">prctl</a></b><span style="color: #000000;">(2), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/5/proc" rel="nofollow">proc</a></b><span style="color: #000000;">(5), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/pth" rel="nofollow">pth</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/2/ptrace" rel="nofollow">ptrace</a></b><span style="color: #000000;">(2),</span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/4/random" rel="nofollow">random</a></b><span style="color: #000000;">(4), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/7/rds" rel="nofollow">rds</a></b><span style="color: #000000;">(7), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/2/recv" rel="nofollow">recv</a></b><span style="color: #000000;">(2), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/rpc_svc_calls" rel="nofollow">rpc_svc_calls</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/rtime" rel="nofollow">rtime</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/3/sctp_connectx" rel="nofollow">sctp_connectx</a></b><span style="color: #000000;">(3), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/2/sigaction" rel="nofollow">sigaction</a></b><span style="color: #000000;">(2), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/2/signalfd" rel="nofollow">signalfd</a></b><span style="color: #000000;">(2), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/5/slapd-ldap" rel="nofollow">slapd-ldap</a></b><span style="color: #000000;">(5), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/5/slapd-meta" rel="nofollow">slapd-meta</a></b><span style="color: #000000;">(5), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/7/socket" rel="nofollow">socket</a></b><span style="color: #000000;">(7), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/2/spufs" rel="nofollow">spufs</a></b><span style="color: #000000;">(2), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/7/spu</p>
<p>fs" rel="nofollow">spufs</a></b><span style="color: #000000;">(7), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/5/ssh-ldap.conf" rel="nofollow">ssh-ldap.conf</a></b><span style="color: #000000;">(5), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/5/sssd-ldap" rel="nofollow">sssd-ldap</a></b><span style="color: #000000;">(5), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/2/timerfd_create" rel="nofollow">timerfd_create</a></b><span style="color: #000000;">(2), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/7/udp" rel="nofollow">udp</a></b><span style="color: #000000;">(7), </span><b style="color: #000000;"><a style="color: #660000;" href="http://linux.die.net/man/1/zshmodules" rel="nofollow">zshmodules</a></b><span style="color: #000000;">(1)</span></p>
</dd>
</dl>
</blockquote>
<h2 id="example-program">实例程序</h2>
<p>使用poll做简单服务器模型</p>
<pre class="nums:true lang:default decode:true">#include &lt;stdio.h&gt;
#include &lt;stdlib.h&gt;
#include &lt;string.h&gt;

#include &lt;unistd.h&gt;

#include &lt;poll.h&gt;
#include &lt;sys/select.h&gt;
#include &lt;sys/time.h&gt;
#include &lt;sys/types.h&gt;
#include &lt;sys/socket.h&gt;
#include &lt;arpa/inet.h&gt;

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
	for (i = 1; i &lt; MAXCON; ++i) {
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
			for (i = 0; i &lt; MAXCON; ++i) {
				if (fds[i].fd &lt; 0) {
					fds[i].fd = sockfd;
					fds[i].events = POLLIN;
					printf("accept fds[%d] = %dn", i, sockfd);
					break;
				}
			}
			errpro(MAXCON == i, "too many connections");
			if (i+1 &gt; nfds) {
				nfds = i+1;
			}
		}

		// read data
		for (i = 1; i &lt; nfds; ++i) {
			if (fds[i].fd &lt; 0) {
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
}</pre>
<h2 id="summary">总结</h2>
