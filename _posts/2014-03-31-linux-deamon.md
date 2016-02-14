---
layout: post
title: Linux deamon
date: 2014-03-31 15:02:28.000000000 +08:00
type: post
published: true
status: publish
categories:
- Service
tags:
- deamon
meta:
  _edit_last: '1'
  _wp_old_slug: deamon-%e5%ae%9e%e7%8e%b0
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---
<p>守护进程（Daemon）是运行在后台的一种特殊进程。它独立于控制终端并且周期性地执行某种任务或等待处理某些发生的事件。守护进程是一种很有用的进 程。Linux的大多数服务器就是用守护进程实现的。比如，Internet服务器inetd，Web服务器httpd等。同时，守护进程完成许多系统任务。 比如，作业规划进程crond，打印进程lpd等。<br />
<!--more--><br />
守护进程的编程本身并不复杂，复杂的是各种版本的Unix的实现机制不尽相同，造成不同 Unix环境下守护进程的编程规则并不一致。需要注意，照搬某些书上的规则（特别是BSD4.3和低版本的System V）到Linux会出现错误的。下面将给出Linux下守护进程的编程要点和详细实例。</p>
<p>一． 守护进程及其特性</p>
<p>守护进程最重要的特性是后台运行。在这一点上DOS下的常驻内存程序TSR与之相似。其次，守护进程必须与其运行前的环境隔离开来。这些环 境包括未关闭的文件描述符，控制终端，会话和进程组，工作目录以及文件创建掩模等。这些环境通常是守护进程从执行它的父进程（特别是shell）中继承下 来的。最后，守护进程的启动方式有其特殊之处。它可以在Linux系统启动时从启动脚本/etc/rc.d中启动，可以由作业规划进程crond启动，还可以由用户终端（通常是 shell）执行。</p>
<p>总之，除开这些特殊性以外，守护进程与普通进程基本上没有什么区别。因此，编写守护进程实际上是把一个普通进程按照上述的守护进程的特性改造成为守护进程。如果对进程有比较深入的认识就更容易理解和编程了。</p>
<p>二． 守护进程的编程要点</p>
<p>不同Unix环境下守护进程的编程规则并不一致。所幸的是守护进程的编程原则其实都一样，区别在于具体的实现细节不同。这个原则 就是要满足守护进程的特性。同时，Linux是基于Syetem V的SVR4并遵循Posix标准，实现起来与BSD4相比更方便。编程要点如下；</p>
<p>1. 在后台运行。</p>
<p>为避免挂起控制终端将Daemon放入后台执行。方法是在进程中调用fork使父进程终止，让Daemon在子进程中后台执行。</p>
<pre class="lang:c">
if(pid=fork())
exit(0); //是父进程，结束父进程，子进程继续
</pre>
<p>2. 脱离控制终端，登录会话和进程组</p>
<p>有必要先介绍一下Linux中的进程与控制终端，登录会话和进程组之间的关系：进程属于一个进程组，进程组号（GID）就是进程组长的进程号（PID）。登录会话可以包含多个进程组。这些进程组共享一个控制终端。这个控制终端通常是创建进程的登录终端。 控制终端，登录会话和进程组通常是从父进程继承下来的。我们的目的就是要摆脱它们，使之不受它们的影响。方法是在第1点的基础上，调用setsid()使进程成为会话组长：</p>
<pre class="lang:c">
setsid(); //设置为会话组长
</pre>
<p>说明：当进程是会话组长时setsid()调用失败。但第一点（fork()）已经保证进程不是会话组长。setsid()调用成功后，进程成为新的会话组长和新的进程组长，并与原来的登录会话和进程组脱离。由于会话过程对控制终端的独占性，进程同时与控制终端脱离。</p>
<p>3. 禁止进程重新打开控制终端</p>
<p>现在，进程已经成为无终端的会话组长。但它可以重新申请打开一个控制终端。可以通过使进程不再成为会话组长来禁止进程重新打开控制终端（再fork一次）：</p>
<pre class="lang:c">
if(pid=fork())
exit(0); //结束第一子进程，第二子进程继续（第二子进程不再是会话组长）
</pre>
<p>4. 关闭打开的文件描述符</p>
<p>进程从创建它的父进程那里继承了打开的文件描述符。如不关闭，将会浪费系统资源，可能会造成进程所占用的文件系统无法卸下以及引起无法预料的错误。按如下方法关闭它们：</p>
<pre class="lang:c">
for(i=0;i &lt; 3; ++i)
close(i); //0， 1， 2 分别表示标准输入、标准输出和标准错误
</pre>
<p>当然，此处关闭哪个文件描述符与实际需要相关，也可以关闭以后再重新打开。</p>
<p>5. 改变当前工作目录</p>
<p>进程活动时，如果该目录是一个挂载的目录，将导致其文件系统不能卸载。一般需要将工作目录改变到根目录（chdir("/")）。对于需要转储核心，写运行日志的进程将工作目录改变到特定目录如 /tmp</p>
<p>6. 重设文件创建掩模</p>
<p>进程从创建它的父进程那里继承了文件创建掩模。由继承得来的文件方式创建屏蔽字可能会拒绝设置某些许可权。例如，若daemon进程要创建一个组可读、写的文件，而继承的文件方式创建屏蔽字，屏蔽了这两种许可权，则要求的组可读、写就不能起作用。为防止这一点，将文件创建掩模清除：</p>
<pre class="lang:c">
umask(0);
</pre>
<p>7. 处理SIGCHLD信号</p>
<p>处理SIGCHLD信号并不是必须的。但对于某些进程，特别是服务器进程往往在请求到来时生成子进程处理请求。如果父进程不等待子进程结 束，子进程将成为僵尸进程（zombie）。如果父进程等待子进程结束，将增加父进程的负担，影响服务器进程的并发性能。在Linux下 可以简单地将 SIGCHLD信号的操作设为SIG_IGN。</p>
<pre class="lang:c">
signal(SIGCHLD,SIG_IGN);
</pre>
<p>这样，内核在子进程结束时不会产生僵尸进程。这一点与BSD4不同，BSD4下必须显式等待子进程结束才能释放僵尸进程。</p>
<p>三． 守护进程实例</p>
<p>fork()两次，将孙子进程“过继”给1号进程init，如果孙子进程成功，其父进程将会是系统1号进程init，如果失败，将由init负责收拾残局。</p>
<pre class="lang:c">
void deamonize() {
	if (fork())
		exit(0);	// exit parent process
	setsid();	// become session leader, discard controlling terminal
	signal(SIGINT, SIG_IGN);
	signal(SIGCHLD, SIG_IGN);
	signal(SIGHUP, SIG_IGN);
	signal(SIGQUIT, SIG_IGN);
	signal(SIGPIPE, SIG_IGN);
	if (fork())
		exit(0);	// no more session leader, cannot reopen a contorl terminal
	for (int i = 0; i < 3; ++i)
		close(i);	// close file dscriptor
	chdir("/");
	umask(0);
}
</pre>
<p>四. wait和waitpid</p>
<p>两者相同点都是用于在创建子进程之后，阻塞自己，然后检查自己的子进程中是否有僵尸进程存在，如果存在，该父进程就释放僵尸进程占用的资源，并返回，如果没有这样的僵尸进程，就一直阻塞。</p>
<p>不同点是后者还有两个pid和option参数。</p>
<p>pid：当pid &gt; 0时，只等待进程号为pid的进程退出；pid == -1时，等待任意子进程，作用等同于wait；pid == 0时，等待同一进程组中任意子进程；pid &lt; -1 时，等待某个进程组的任意进程，该进程组的组号为pid的绝对值。</p>
<p>option：有两个值，WNOHANG和WUNTRACED，前者使得waitpid立即返回而不管有没有子进程退出；后者是指其子进程集合中，如果有子进程是STOPED状态，就立即返回，如果该进程是被traced的，那么即使不提供WUNTRACED参数，也立即返回。</p>
<p>于是可以看出，wait是等待第一个退出的子进程，而waitpid是等待指定子进程退出。因此对于多进程服务器，使用waitpid可以避免因为第一个子进程退出调用了wait，而造成剩余子进程没有wait来处理，引起的僵尸进程的问题。</p>
<p>五. 僵尸进程的处理</p>
<p>僵尸进程是无法使用kill或者killall来杀死的，虽然僵尸进程并不占用很多系统资源（只是占用进程表process table中的一个项），但是过多的僵尸进程还是会对系统性能造成影响（达到系统进程数上限），因此应尽可能避免：</p>
<ol>
<li>改写父进程：如上所述，fork两次，将init作为其父进程，由系统负责清理</li>
<li>kill掉僵尸进程的父进程，交由系统处理。</li>
</ol>
<p>使用</p>
<pre class="lang:c">
ps auwx可以查看系统中僵尸进程，僵尸进程的状态会被标注为“Z”。或者
ps axf   以树形展示进程表
ps axm    列出线程，linux下进程线程一致
ps aux   列出进程的详细信息
</pre>
<p>参考：</p>
<p><a href="http://blog.csdn.net/zi_jin/article/details/3861497" rel="nofollow">http://blog.csdn.net/zi_jin/article/details/3861497</a><br />
<a href="http://blog.csdn.net/ixidof/article/details/6715792" rel="nofollow">http://blog.csdn.net/ixidof/article/details/6715792</a><br />
<a href="http://hi.baidu.com/qiaoyongfeng/blog/item/3d6fc100bcf93e17738b6576.html" rel="nofollow">http://hi.baidu.com/qiaoyongfeng/blog/item/3d6fc100bcf93e17738b6576.html</a></p>
