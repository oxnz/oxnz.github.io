---
layout: post
title: Linux 网络模型
type: post
categories:
- Linux
- network
- UNIX
tags:
- network
- server
- socket
- tcp
- udp
---

全文针对linux环境。tcp/udp两种server种，tcp相对较复杂也相对比较常用。本文就从tcp server开始讲起。先从基本说起，看一个单线程的网络模型，处理流程如下:

```
socket-->bind-->listen-->[accept-->read-->write-->close]-->close
```

[]中代码循环运行，[]外的是对监听socket的处理，[]内的是对accept返回的客户socket的处理。这些系统调用的参数以及需要的头文件等，只需要在linux下man就好。

<!--more-->

## Table of Contents

* TOC
{:toc}

## 注意事项

（1）返回值检测。这些系统调用返回-1表示失败。检测系统调用的返回值是个好习惯，应该说必须检测。每次检查的话，代码写起来又很是罗唆，并且容易遗漏检测。使用错误处理代码包裹系统调用或者使用包裹函数是不错的方案。下面给出几个预定义包裹函数：</p>

```c
void errpro(int condition, const char *errmsg) {
    if (condition) {
        perror(errmsg);
        exit(EXIT_FAILURE);
    }
}
```

<p>(2)不能返回失败的错误。大多数阻塞式系统调用要处理EINTR错误，另accept还要处理ECONNABORTED。与（1）同样道理，预定义宏如下：</p>
<p>(3)涉及到系统调用分两类：从用户态到内核态，该类系统调用使用值参数，有：bind/setsockopt/connect；从内核态到用户态,该类系统调用使用值－结果参数，有：accept/getsockopt。<br />
看下两者函数原型，从用户态到内核态：</p>
<pre class="lang:default decode:true">int setsockopt(int s, int level, int optname, const void *optval, socklen_t optlen);
int connect(int sockfd, const struct sockaddr *serv_addr, socklen_t addrlen);
int bind(int sockfd,struct sockaddr *Addr,socklen_t addrlen);</pre>
<p>从内核态到用户态：</p>
<pre class="lang:default decode:true">int getsockopt(int s, int level, int optname, void *optval, socklen_t *optlen);
int accept(int sockfd,struct sockaddr *Addr,socklen_t *addrlen);</pre>
<p>看最后一个参数，从用户态到内核态只要告诉内核参数长度的值就可以了，因此是值方式。从内核态到用户态，要事先准备好变量保存内核态返回的结果长度值，因此是指针方式，称之为值－结果参数。</p>

## 系统调用

（1）socket</p>
<pre class="lang:default decode:true">errpro(-1 == (fd=socket(AF_INET,SOCKET_STREAM,0)), "socket");</pre>
<p>创建一个ipv4的tcp socket</p>
<p>（2）bind<br />
把socket绑定到一个地址，首先要指明地址，如下：</p>
<pre class="lang:default decode:true">struct sockaddr_in addr;
addr.sin_family=AF_INET;//协议类型
addr.sin_port=htons(5000);//端口地址
addr.sin_addr.s_addr=htonl(INADDR_ANY);//此处表示任意ip（主机有多个网卡，则将环路地址127.0.0.1以及各网卡ip都指定）。
errpro(-1 == bind(fd,(struct sockaddr *)addr,sizeof(struct sockaddr_in)), "bind");</pre>
<p>创建ipv4协议的地址，使用5000端口，接收任何地址的connect，把该地址和fd绑定。<br />
注意：<br />
1、地址声明的时候使用struct sockaddr_in，使用的时候总是强制转化为struct sockaddr。<br />
2、struct sockaddr_in结构中端口和ip都必须是网络序。htons把主机序的short int转化为网络序，htonl把主机序的long int转化为网络序。<br />
3、除任意ip地址为常量外，一般习惯用点分字符串表示ip地址，而addr.sin_addr.s_addr要使用网络序整型。<br />
因此有两个函数可以在字符串和网络序ip地址之间做转换：</p>
<pre class="lang:default decode:true">const char *inet_ntop(int af, const void *src,char *dst, socklen_t cnt);
int inet_pton(int af, const char *src, void *dst);</pre>
<p>这里是需要网络序，因此使用ton（to net）那个函数，比如：</p>
<pre class="lang:default decode:true">inet_pton(AF_INET,"172.168.0.45", &amp;addr.sin_addr.s_addr);
</pre>
<p>（3）setsockopt</p>
<pre class="lang:default decode:true">long val;
socklen_t len=sizeof(val);
errpro(-1 == setsockopt(fd,SOL_SOCKET,SO_REUSEADDR,&amp;(val=1),len), "setsockopt");</pre>
<p>给socket设置选项，常用的不多，SO_REUSEADDR是一个，服务器一般使用，其它还有SO_RCVBUF，SO_SNDBUF。accept返回的对端socket继承监听socket的发送缓存、接收缓存选项。一般也不需要设置SO_RCVBUF，SO_SNDBUF，默认的足够了，带宽很大的情况下，需要设置，以免其称为瓶颈，貌似默认的是8092字节。哦，还有要在listen前设置。<br />
（4）listen</p>
<pre class="lang:default decode:true">errpro(-1 == listen(fd,SOMAXCONN), "listen");</pre>
<p>把fd从主动端口变为被动端口，等待client connect。第二个参数是表示三次握手中队列以及完成了三次握手等待accept系统函数来取的队列的相加值，有的系统不是简单相加，还有一个系数，也就是如果设置5，系数是2，那么两个队列的和就是10。如果队列满，而accept没来取（很忙的情况下，来不及调用accept），再有连接来就会被拒绝掉，要想系统能处理超大爆发的连接，就加大这个参数值，加快accept的处理。SOMAXCONN表示取系统允许的最大值。<br />
（5）accept<br />
前面已经举例了，这里就不再列例子了。<br />
阻塞式调用，需要处理EINTR（被信号终止），ECONNABORTED（返回前client异常终止），处理的方式就是重新accept。<br />
（6）read</p>
<pre class="lang:default decode:true">errpro(-1 == read(int fd,char *buf,size_t len), "read");</pre>
<p>这是针对文件描述符的一个系统调用，socket也属于文件描述符。tcp协议中传输的数据都是流字节，没有什么结束符的标志，只能由协议提供结束方式，比如http协议使用"rnrn"或者"nn"标识一条信令结束，这样的话，我们只能一个字节一个字节的读取，然后结合已经读取的字节，判断是否应该结束读。而网络模型中要提高性能，一个重要方面就是要减少系统调用的次数。因此tcp中都要使用缓存区一次读取尽可能多的数据，然后再从该缓存区一个字节一个字节的读取，缓存区数据被读完而没有到结束位置的时候，再次调用系统调用read。<br />
返回值为0表示对端正常关闭，大于0表示读取到的字节数。示例见最后例子。<br />
（7）write</p>
<pre class="lang:default decode:true">int write(int fd,char *buf,size_t len);</pre>
<p>两个需要注意的地方：<br />
1、对EINTR处理。防止被信号中断，没有正确写入需求的字符数。<br />
2、signal(SIGPIPE, SIG_IGN);这句代码的意思是忽略SIGPIPE信号。<br />
write写被重置（对端意外关闭）的套接口，产生SIGPIPE信号，不处理的话程序被终止。忽略的话，继续写会产生EPIPE错误，检查write系统调用的返回结果就好了。示例见最后例子。<br />
signal的使用，man下就看到了，回调函数的原型等都有，SIG_IGN也会出现，呵呵。<br />
（8）close就不说了<br />
（9）fcntl<br />
要对socket设置为非阻塞方式，setsockopt没有提供相应的选项，只能用fcntl函数设置。</p>
<pre class="lang:default decode:true">int flags;
errpro(-1 == (flags=fcntl(client_sockfd,F_GETFL,0)), "fcntl");
errpro(-1 == fcntl(client_sockfd,F_SETFL,flags|O_NONBLOCK), "fcntl");</pre>
<p>多路分离I/O(select/poll/epoll)通常设置为非阻塞方式。<br />
设置为阻塞方式（默认方式）代码：</p>
<pre class="lang:default decode:true">int flags;
errpro(-1 == (flags=fcntl(client_sockfd,F_GETFL,0)), "fcntl");
errpro(-1 == fcntl(client_sockfd,F_SETFL,flags&amp;~O_NONBLOCK));</pre>
<p>对于阻塞方式的套接口，如果要避免read write永远阻塞，设置等待时间的方式有3种：信号方式，不推荐，不说了；select方式，每次调用read前调用select监视该套接口是否在指定时间内可写，超时select返回0，这样每次执行read都要调用两个系统调用，不推荐；最后就是设置套接口选项SO_RECVTIMEO和SO_SNDTIMEO,其实这个也不推荐，总之不推荐阻塞式的方式，呵呵。实用的网络模型都是多路分离的。<br />
非阻塞方式下的connect函数要说下，当然是就客户端而言，connect后如果没有立即返回连接成功的话，把这个socket加入select的 fd_set(poll的pollfd，epoll的EPOLL_CTL_ADD操作),要监视是否可写事件，可写的时候用getsockopt获取SO_ERROR选项，如果非负（其实就是0值）就标示connect成功，否则就是失败。EPOLL中测试结果是connect失败的返回事件是EPOLLERR|EPOLLHUP,并不是加入时的EPOLLOUT，成功的时候是EPOLLOUT。</p>

## 示例

最后给个单线程的服务器，虽说没什么实用意义，不过就象“hello world!”，入门第一课。<br />
这个例子，读取数据，回写response，关闭clientfd。不管read write是否出错，都执行close，因此代码很简单。<br />
先来main函数：省略</p>

## 其它基础性知识的说明

（1）read write外 还有recv send recvfrom sendto recvmsg sendmsg不说了<br />
（2）信号处理不说了<br />
（3）多路分离后面讲各种模型的时候详细写<br />
（4）信号方式的多路分离不细说了，在tcp中只能accept除使用信号SIGIO，但是该信号为非可靠信号，当大量client连接到来的时候，经常丢失信号，10并发都支持不了，实在没什么实际意义。</p>
<hr />
<p>本章主要列举服务器程序的各种网络模型，示例程序以及性能对比后面再写。<br />
一、分类依据。服务器的网络模型分类主要依据以下几点<br />
（1）是否阻塞方式处理请求，是否多路复用，使用哪种多路复用函数<br />
（2）是否多线程，多线程间如何组织<br />
（3）是否多进程，多进程的切入点一般都是accept函数前<br />
二、分类。首先根据是否多路复用分为三大类：<br />
（1）阻塞式模型<br />
（2）多路复用模型<br />
（3）实时信号模型<br />
三、详细分类。<br />
1、阻塞式模型根据是否多线程分四类：<br />
（1）单线程处理。实现可以参考上文的示例代码。<br />
（2）一个请求一个线程。<br />
主线程阻塞在accept处，新连接到来，实时生成线程处理新连接。受限于进程的线程数，以及实时创建线程的开销，过多线程后上下文切换的开销，该模型也就是有学习上价值。<br />
（3）预派生一定数量线程，并且所有线程阻塞在accept处。<br />
该模型与下面的（4）类似与线程的领导者/追随者模型。<br />
传统的看法认为多进程（linux上线程仍然是进程方式）同时阻塞在accept处，当新连接到来时会有“惊群”现象发生，即所有都被激活，之后有一个获取连接描述符返回，其它再次转为睡眠。linux从2.2.9版本开始就不再存在这个问题，只会有一个被激活，其它平台依旧可能有这个问题，甚至是不支持所有进程直接在accept阻塞。<br />
（4）预派生一定数量线程，并且所有线程阻塞在accept前的线程锁处。<br />
一次只有一个线程能阻塞在accept处。避免不支持所有线程直接阻塞在accept，并且避免惊群问题。特别是当前linux2.6的线程库下，模型（3）没有存在的价值了。另有文件锁方式，不具有通用性，并且效率也不高，不再单独列举。<br />
（5）主线程处理accept，预派生多个线程（线程池）处理连接。<br />
类似与线程的半同步/半异步模型。<br />
主线程的accept返回后，将clientfd放入预派生线程的线程消息队列，线程池读取线程消息队列处理clientfd。主线程只处理accept，可以快速返回继续调用accept，可以避免连接爆发情况的拒绝连接问题，另加大线程消息队列的长度，可以有效减少线程消息队列处的系统调用次数。<br />
（6）预派生多线程阻塞在accept处，每个线程又有预派生线程专门处理连接。<br />
（3）和（4）/（5）的复合体。<br />
经测试，（5）中的accept线程处理能力非常强，远远大于业务线程，并发10000的连接数也毫无影响，因此该模型没有实际意义。<br />
总结：就前五模型而言，性能最好的是模型（5）。模型（3）/(4)可以一定程度上改善模型（1）的处理性能，处理爆发繁忙的连接，仍然不理想。。阻塞式模型因为读的阻塞性，容易受到攻击，一个死连接（建立连接但是不发送数据的连接）就可以导致业务线程死掉。因此内部服务器的交互可以采用这类模型，对外的服务不适合。优先（5），然后是（4），然后是（1），其它不考虑。<br />
2、多路复用模型根据多路复用点、是否多线程分类：<br />
以下各个模型依据选用select/poll/epoll又都细分为3类。下面个别术语采用select中的，仅为说明。<br />
（1）accept函数在多路复用函数之前，主线程在accept处阻塞，多个从线程在多路复用函数处阻塞。主线程和从线程通过管道通讯，主线程通过管道依次将连接的clientfd写入对应从线程管道，从线程把管道的读端pipefd作为fd_set的第一个描述符，如pipefd可读，则读数据，根据预定义格式分解出clientfd放入fd_set，如果clientfd可读，则read之后处理业务。<br />
此方法可以避免select的fd_set上限限制，具体机器上select可以支持多少个描述符，可以通过打印sizeof(fd_set)查看，我机器上是512字节，则支持512×8＝4096个。为了支持多余4096的连接数，此模型下就可以创建多个从线程分别多路复用，主线程accept后平均放入（顺序循环）各个线程的管道中。创建5个从线程以其对应管道，就可以支持2w的连接，足够了。另一方面相对与单线程的select，单一连接可读的时候，还可以减少循环扫描fd_set的次数。单线程下要扫描所有fd_set（如果再最后），该模型下，只需要扫描所在线程的fd_set就可。<br />
（2）accept函数在多路复用函数之前，与（1）的差别在于，主线程不直接与从线程通过管道通讯，而是将获取的fd放入另一缓存线程的线程消息队列，缓存线程读消息队列，然后通过管道与从线程通讯。<br />
目的在主线程中减少系统调用，加快accept的处理，避免连接爆发情况下的拒绝连接。<br />
（3）多路复用函数在accept之前。多路复用函数返回，如果可读的是serverfd，则accept，其它则read，后处理业务，这是多路复用通用的模型，也是经典的reactor模型。<br />
（4）连接在单独线程中处理。<br />
以上（1）（2）（3）都可以在检测到cliendfd可读的时候，把描述符写入另一线程（也可以是线程池）的线程消息队列，另一线程（或线程池）负责read，后处理业务。<br />
（5）业务线程独立，下面的网络层读取结束后通知业务线程。<br />
以上（1）（2）（3）（4）中都可以将业务线程（可以是线程池）独立，事先告之（1）、（2）、（3）、（4）中read所在线程（上面1、2、4都可以是线程池），需要读取的字符串结束标志或者需要读取的字符串个数，读取结束，则将clientfd/buffer指针放入业务线程的线程消息队列，业务线程读取消息队列处理业务。这也就是经典的proactor模拟。<br />
总结：模型（1）是拓展select处理能力不错选择；模型（2）是模型（1）在爆发连接下的调整版本；模型（3）是经典的reactor，epoll在该模型下性能就已经很好，而select/poll仍然存在爆发连接的拒绝连接情况；模型（4）（5）则是方便业务处理，对模型（3）进行多线程调整的版本。带有复杂业务处理的情况下推荐模型（5）。根据测试显示，使用epoll的时候，模型（1）（2）相对（3）没有明显的性能优势，（1）由于主线程两次的系统调用，反而性能下降。<br />
3、实时信号模型：<br />
使用fcntl的F_SETSIG操作，把描述符可读的信号由不可靠的SIGIO(SYSTEM V)或者SIGPOLL(BSD)换成可靠信号。即可成为替代多路复用的方式。优于select/poll，特别是在大量死连接存在的情况下，但不及epoll。<br />
四、多进程的参与的方式<br />
（1）fork模型。fork后所有进程直接在accept阻塞。以上主线程在accept阻塞的都可以在accept前fork为多进程。同样面临惊群问题。<br />
（2）fork模型。fork后所有进程阻塞在accept前的线程锁处。同线程中一样避免不支持所有进程直接阻塞在accept或者惊群问题，所有进程阻塞在共享内存上实现的线程互斥锁。<br />
（3）业务和网络层分离为不同进程模型。这个模型可能是受unix简单哲学的影响，一个进程完成一件事情，复杂的事情通过多个进程结合管道完成。我见过进程方式的商业协议栈实现。自己暂时还没有写该模型的示例程序测试对比性能。<br />
（4）均衡负载模型。起多个进程绑定到不同的服务端口，前端部署lvs等均衡负载系统，暴露一个网络地址，后端映射到不同的进程，实现可扩展的多进程方案。<br />
总结：个人认为（1）（2）没什么意义。（3）暂不评价。（4）则是均衡负载方案，和以上所有方案不冲突。<br />
以上模型的代码示例以及性能对比后面给出。
