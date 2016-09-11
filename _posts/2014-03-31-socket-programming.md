---
layout: post
title: Linux/Unix socket 网络编程
date: 2014-03-31 15:35:31.000000000 +08:00
type: post
published: true
status: publish
categories:
- Linux
- Network
- UNIX
tags: []
---

## Table of Contents

* TOC
{:toc}

## 基本概念

### OSI参考模型

#### 七层模型

其七层模型从下到上分别为:

<ol>
<li>物理层(Physical Layer,PH)</li>
<li>数据链路层(Data Link Layer,DL)</li>
<li>网络层(Network Layer,N)</li>
<li>运输层(Transport Layer,T)</li>
<li>会话层(Session Layer,S)</li>
<li>表示层(Presentation Layer,P)</li>
<li>应用层(Application Layer,A)</li>
</ol>

<!--more-->

### 网络协议

现在最流行的网络协议无疑就是TCP/IP (Transmission Control Protocol/Internet Protocol) 协议.

* IP (Internet Protocol)，网际协议；IP是TCP/IP的最底层，高层协议都要转化为IP包，IP包含了源地址和目的地址，路由决策也发生在IP层
* ICMP (Internet Control Message Protocol)，网际报文协议；它包括了数据包的错误、控制等相关信息。比如ping命令就是利用ICMP来测试一个网络的连接情况的工具
* TCP (Transmission Control Protocol)，传输控制协议。
TCP运行在IP之上，是基于数据流和面向链接的协议， 给用户进程提供可靠的全双工的字节流，TCP套接口是字节流套接口(STream socket)的一种。
应用程序把数据要经过TCP/IP的分割成若干包，这样数据就以字节流发送和接收，到达目的地后，TCP/IP再按顺序进行组装。
TCP/IP要保证机器与机器之间的连接的可靠性，还要有纠错。
TCP是否被选择，取决于应用程序或服务
* UDP (User Datagram Protocol) ，用户数据报协议 ，象TCP一样运行在IP之上，是基于数据报或分组的协议，UDP/IP可以直接发送和接收数据报文，而不必做验证，这一点与TCP/IP不同。TCP是否被选择，取决于应用程序或服务
UDP是一种无连接协议。UDP套接口是数据报套接口(datagram Socket)的一种。
* TCP（传输控制协议）和UDP（用户数据报协议是网络体系结构TCP/IP模型中传输层一层中的两个不同的通信协议。



## 基本接口

以Unix/Linux平台为例,系统会建立许多网络服务程序

```shell
$ netstat -a
Proto Recv-Q Send-Q Local Address      Foreign Address          State
tcp        0      0         *:1975                  :                      LISTEN
udp        0      0         *:1978                  :
tcp        0      0 MYServer:34320   192.168.1.2:1521       ESTABLISHED
```

<p>以上可以看到有三个网络连接,一个是TCP接连在1975端口侦听,一个UDP连接在1978端口,另外一个TCP连接是连接到DB的<br />
我们可以看出,客户端程序需要通过”主机名:端口号”与服务器建立连接.主机名其实就是IP地址.<br />
上面的MYServer其实是192.168.1.3, 这样的主机名与IP的对应关系由本机的host文件或DNS服务器解析提供.</p>

```shell
$ more /etc/hosts
# that require network functionality will fail.
127.0.0.1      localhost.localdomain   localhost
192.168.1.3   MYServer
$ more /etc/resolv.conf
nameserver 192.168.1.1
```

当然,我们在编程时无需查询这些文件或服务器,系统提供了API gethostbyname/gethostbyaddr:

```c
#include <netdb.h>
extern int h_errno;
struct hostent *gethostbyname(const char *name);

#include <sys/socket.h>        /* for AF_INET */
struct hostent *gethostbyaddr(const char *addr, int len, int type);
```

它们会返回一个指针,指向如下结构的对象

```c
struct  hostent {
    char    *h_name;        /* official name of host */
    char    **h_aliases;    /* alias list */
    int     h_addrtype;     /* host address type */
    int     h_length;       /* length of address */
    char    **h_addr_list;  /* list of addresses from name server */
};
#define h_addr  h_addr_list[0]  /* address, for backward compatibility */
```

<p><code>h_addr_list</code>是一个与域名对应的IP地址的列表,勤快的程序员会依次尝试连接列表中返回的IP地址<br />
懒惰的程序员只会用<code>h_addr,h_addr_list</code>列表中的第一个IP地址<br />
不同的应用程序使用不同的端口和协议,比如常用的ftp就用21端口和tcp协议</p>

```
$ more /etc/services
# service-name  port/protocol  [aliases ...]   [# comment]
ftp             21/tcp
ftp             21/udp          fsp fspd
ssh             22/tcp                          # SSH Remote Login Protocol
ssh             22/udp                          # SSH Remote Login Protocol
telnet          23/tcp
telnet          23/udp
# 24 - private mail system
smtp            25/tcp          mail
smtp            25/udp          mail
...
```

<p>同样,程序中是无需查询这个文件的,Unix提供了<code>getservbyname</code></p>

```
#include <netdb.h>
struct servent *getservbyname(const char *name, const char *proto);
struct servent {
    char    s_name;        / official service name */
    char    **s_aliases;    /* alias list */
    int     s_port;         /* port number */
    char    s_proto;       / protocol to use */
}
```

<p>知道主机名(IP)和端口号,我们就可以编写在这台主机的运行的或是连接到它的网络应用程序了<br />
Unix/Linux系统中是通过提供套接字(socket)来进行网络编程的.网络程序通过socket和其它几个函数的调用,会返回一个通讯的文件描述符,我们<br />
可以将这个描述符看成普通的文件的描述符来操作,可以通过向描述符读写操作实现网络之间的数据交流.</p>

### 打开一个socket


```c
int socket(int domain,int type,int protocol)
```

domain:说明我们网络程序所在的主机采用的通讯协族(AF_UNIX和AF_INET等).AF_UNIX只能够用于单一的Unix系统进程间通信,而<code>AF_INET</code>是针对Internet的,因而可以允许在远程主机之间通信(当我们mansocket时发现domain可选项是PF_*而不是AF_*,因为glibc是posix的实现所以用PF代替了AF,不过我们都可以使用的).<br />
type:我们网络程序所采用的通讯协议<code>(SOCK_STREAM,SOCK_DGRAM</code>等)SOCK_STREAM表明我们用的是TCP协议,这样会提供按顺序的,可靠,双向,面向连接的比特流.SOCK_DGRAM表明我们用的是UDP协议,这样只会提供定长的,不可靠,无连接的通信.<br />
protocol:由于我们指定了type,所以这个地方我们一般只要用0来代替就可以了socket为网络通讯做基本的准备.成功时返回文件描述符,失败时返回-1,看<code>errno</code>可知道出错的详细情况.</p>

### 将socket绑定定指定的端口 bind

<pre class="lang:default decode:true crayon-selected">int bind(int sockfd,struct sockaddr* my_addr,int addrlen)
sockfd:是由socket调用返回的文件描述符.
addrlen:是sockaddr结构的长度.
my_addr:是一个指向sockaddr的指针.在中有sockaddr的定义
structsockaddr{
unisgnedshortas_family;
charsa_data[14];
};</pre>
<p>不过由于系统的兼容性,我们一般不用这个头文件,而使用另外一个结构<code>(structsockaddr_in)</code>来代替.在中有<code>sockaddr_in</code>的定义</p>
<pre>structsockaddr_in{
unsignedshortsin_family;
unsignedshortintsin_port;
structin_addrsin_addr;
unsignedcharsin_zero[8];
}</pre>
<p>我们主要使用Internet所以sin_family一般为AF_INET,sin_addr设置为INADDR_ANY表示可以和任何的主<br />
机通信,sin_port是我们要监听的端口号.sin_zero[8]是用来填充的.bind将本地的端口同socket返回的文件描述符捆绑在一<br />
起.成功是返回0,失败的情况和socket一样</p>

### 侦听 socket - listen (服务器端)


```c
int listen(int sockfd,int backlog)
```

sockfd:是bind后的文件描述符.
backlog:设置请求排队的最大长度.当有多个客户端程序和服务端相连时,使用这个表示可以介绍的排队长度.listen函数将bind的文件描述符变为监听套接字.返回的情况和bind一样.

### 等待接收请求—accept (服务器端)

```c
int accept(int sockfd, struct sockaddr*addr,int* addrlen)
```

* sockfd:是listen后的文件描述符.
* addr,addrlen是用来给客户端的程序填写的,服务器端只要传递指针就可以了.

bind,listen和accept是服务器端用的函数,accept调用时,服务器端的程序会一直阻塞到有一个客户程序发出了连接.accept成功时返回最后的服务器端的文件描述符,这个时候服务器端可以向该描述符写信息了.失败时返回-1

### 连接到socket—connect

<p><code>int connect(int sockfd,struct sockaddr* serv_addr,int addrlen)</code><br />
sockfd:socket返回的文件描述符.<br />
serv_addr:储存了服务器端的连接信息.其中sin_add是服务端的地址<br />
addrlen:serv_addr的长度<br />
connect函数是客户端用来同服务端连接的.成功时返回0,sockfd是同服务端通讯的文件描述符失败时返回-1.</p>

### 利用socket传输数据

#### read 和 write

```c
ssize_t read(int fd,void *buf,size_t nbyte)
```

* read函数是负责从fd中读取内容.当读成功时,read返回实际所读的字节数
* 如果返回的值是0表示已经读到文件的结束了,小于0表示出现了错误
* 如果错误为EINTR说明读是由中断引起的
* 如果是ECONNREST表示网络连接出了问题

```c
ssize_t write(int fd,const void *buf,size_t nbytes)
```

* write函数将buf中的nbytes字节内容写入文件描述符fd
* 成功时返回写的字节数
* 失败时返回-1, 并设置errno变量

在网络程序中,当我们向套接字文件描述符写时有俩种可能:

1. write的返回值大于0,表示写了部分或者是全部的数据
2. 返回的值小于0,此时出现了错误.我们要根据错误类型来处理
	* 如果错误为 EINTR 表示在写的时候出现了中断错误
	* 如果为 EPIPE 表示网络连接出现了问题(对方已经关闭了连接)

#### recv 和 send

和read和write差不多.不过它们提供 了第四个参数来控制读写操作.

```c
int recv(int sockfd,void *buf,int len,int flags);
int send(int sockfd,void *buf,int len,int flags);
```

前面的三个参数和read,write一样,第四个参数可以是0或者是以下的组合:

Option          | Meaning                           | Extra
----------------|-----------------------------------|------
MSG_DONTROUTE	| 不查找路由表						| 是send函数使用的标志.这个标志告诉IP协议.目的主机在本地网络上面,没有必要查找路由表.这个标志一般用网络诊断和路由程序里面
MSG_OOB			| 接受或者发送带外数据				| 表示可以接收和发送带外的数据.关于带外数据我们以后会解释的
MSG_PEEK		| 查看数据,并不从系统缓冲区移走数据	| 是recv函数的使用标志,表示只是从系统缓冲区中读取内容,而不清楚系统缓冲区的内容.这样下次读的时候,仍然是一样的内容.一般在有多个进程读写数据时可以使用这个标志
MSG_WAITALL		| 等待所有数据						| 是recv函数的使用标志,表示等到所有的信息到达时才返回.使用这个标志的时候recv回一直阻塞,直到指定的条件满足,或者是发生了错误. 1)当读到了指定的字节时,函数正常返回.返回值等于len 2)当读到了文件的结尾时,函数正常返回.返回值小于len 3)当操作发生错误时,返回-1,且设置错误为相应的错误号(errno)

如果flags为0,则和read,write一样的操作.还有其它的几个选项,不过我们实际上用的很少,可以查看Linux Programmer’s Manual得到详细解释.

#### recvfrom 和 sendto

```c
ssize_t
 recvfrom(int socket, void *restrict buffer, size_t length, int flags,
	 struct sockaddr *restrict address,
	 socklen_t *restrict address_len);
ssize_t
 sendto(int socket, const void *buffer, size_t length, int flags,
	 const struct sockaddr *dest_addr, socklen_t dest_len);
```

sockfd,buf,len的意义和read,write一样,分别表示套接字描述符,发送或接收的缓冲区及大小.

recvfrom负责从sockfd接收数据,如果from不是NULL,那么在from里面存储了信息来源的情况,如果对信息的来源不感兴趣,可以将from和fromlen设置为NULL.

sendto负责向to发送信息.此时在to里面存储了收信息方的详细资料.

#### recvmsg 和 sendmsg

<p>recvmsg和sendmsg可以实现前面所有的读写函数的功能.</p>
<pre class="lang:default decode:true">int recvmsg(int sockfd,struct msghdr *msg,int flags)
int sendmsg(int sockfd,struct msghdr *msg,int flags)
struct msghdr
{
void *msg_name;
int msg_namelen;
struct iovec *msg_iov;
int msg_iovlen;
void *msg_control;
int msg_controllen;
int msg_flags;
 }
struct iovec
 {
void iov_base; / 缓冲区开始的地址 */
size_t iov_len; /* 缓冲区的长度 */
 }</pre>
<p>msg_name和msg_namelen当套接字是非面向连接时(UDP),它们存储接收和发送方的地址信息.msg_name实际上是一个指向struct sockaddr的指针,msg_name是结构的长度.当套接字是面向连接时,这两个值应设为NULL. msg_iov和msg_iovlen指出接受和发送的缓冲区内容.msg_iov是一个结构指针,msg_iovlen指出这个结构数组的大小. msg_control和msg_controllen这两个变量是用来接收和发送控制数据时的msg_flags指定接受和发送的操作选项.和recv,send的选项一样</p>

### 套接字的关闭 close/shutdown

关闭套接字有两个函数close和shutdown.用close时和我们关闭文件一样.

```c
int close(int sockfd);
int shutdown(int sockfd,int howto);
```

TCP连接是双向的(是可读写的),当我们使用close时,会把读写通道都关闭,有时侯我们希望只关闭一个方向,这个时候我们可以使用shutdown.
针对不同的howto,系统回采取不同的关闭方式:

* howto=0这个时候系统会关闭读通道.但是可以继续往接字描述符写
* howto=1关闭写通道,和上面相反,着时候就只可以读了
* howto=2关闭读写通道,和close一样 在多进程程序里面,如果有几个子进程共享一个套接字时,如果我们使用shutdown, 那么所有的子进程都不能够操作了,这个时候我们只能够使用close来关闭子进程的套接字描述符

## 最常用的服务器模型

### 循环服务器

循环服务器在同一个时刻只可以响应一个客户端的请求

#### 循环服务器之UDP服务器

UDP循环服务器的实现非常简单:UDP服务器每次从套接字上读取一个客户端的请求,处理, 然后将结果返回给客户机.

python udp server

```python
#!/usr/bin/env python
#-*- coding: utf-8 -*-

import socket
def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind(('localhost', 8000))
    while True:
        data, (addr, port) = sock.recvfrom(1024)
        print 'server recv: ', data

if __name__ == '__main__':
    main()
```

udp client

```python
#!/usr/bin/env python
#-*- coding: utf-8 -*-

import socket

def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        sock.sendto('hello, server!', ('localhost', 8000))
        buf = sock.recvfrom(1024)
        print 'client recv: ', buf
    except:
        print 'exception in client'
    sock.close()

if __name__ == '__main__':
    main()
```

因为UDP是非面向连接的,没有一个客户端可以老是占住服务端. 只要处理过程不是死循环, 服务器对于每一个客户机的请求总是能够满足.

#### 循环服务器之TCP服务器

TCP循环服务器的实现也不难:TCP服务器接受一个客户端的连接,然后处理,完成了这个客户的所有请求后,断开连接.

python tcp server

```python
#!/usr/bin/env python
#-*- coding: utf-8 -*-

import socket
def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.bind(('localhost', 8000))
    sock.listen(5)
    while True:
        conn, addr = sock.accept()
        try:
            conn.settimeout(4)
            buf = conn.recv(1024)
            conn.send('welcome')
            print 'server recv: ', buf
        except socket.timeout:
            print 'time out'
        conn.close()

if __name__ == '__main__':
    main()
```

tcp client

```python
#!/usr/bin/env python
#-*- coding: utf-8 -*-

import socket

def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(('localhost', 8000))
    try:
        sock.send('hello, server!')
        buf = sock.recv(1024)
        print 'client recv: ', buf
    except:
        print 'exception in client'
    sock.close()

if __name__ == '__main__':
    main()
```

<p>TCP循环服务器一次只能处理一个客户端的请求.只有在这个客户的所有请求都满足后, 服务器才可以继续后面的请求.这样如果有一个客户端占住服务器不放时,其它的客户机都不能工作了.因此,TCP服务器一般很少用循环服务器模型的.</p>

### 并发服务器

并发服务器在同一个时刻可以响应多个客户端的请求</p>

#### 并发服务器之TCP服务器

为了弥补循环TCP服务器的缺陷,人们又想出了并发服务器的模型. 并发服务器的思想是每一个客户机的请求并不由服务器直接处理,而是服务器创建一个 子进程来处理.<br />
框架如下:</p>

```c
socket(...);
bind(...);
listen(...);
while(1) {
    accept(...);
    if(fork(..)==0) {
        while(1) {
            read(...);
            process(...);
            write(...);
        }
        close(...);
        exit(...);
    }
    close(...);
}
```

TCP并发服务器可以解决TCP循环服务器客户机独占服务器的情况. 不过也同时带来了一个不小的问题.为了响应客户机的请求,服务器要创建子进程来处理. 而创建子进程是一种非常消耗资源的操作.

#### 并发服务器之多路复用 I/O

为了解决创建子进程带来的系统资源消耗,人们又想出了多路复用I/O模型

* Linux
    * [select](/2014/04/30/linux-select/)
    * [poll](/2014/05/03/linux-poll/)
    * [epoll](/2014/04/26/linux-epool/)
* Unix
    * kqueue
* Windows

其中 select, poll, epoll 已经做过介绍。

使用select后我们的服务器程序就变成了.

```c
// 初始化(socket,bind,listen);
while(1) {
    // 设置监听读写文件描述符(FD_*);
    // 调用select;
    if (/* listen_fd is ready */) { //如果是倾听套接字就绪,说明一个新的连接请求建立
        // 建立连接(accept);
        // 加入到监听文件描述符中去;
    } else { //否则说明是一个已经连接过的描述符
        // 进行操作(read或者write);
    }
}
```

poll和 epoll 也类似上面的框架。多路复用I/O可以解决资源限制的问题.着模型实际上是将UDP循环模型用在了TCP上面. 这也就带来了一些问题.如由于服务器依次处理客户的请求,所以可能会导致有的客户 会等待很久.

#### 并发服务器之UDP服务器

人们把并发的概念用于UDP就得到了并发UDP服务器模型. 并发UDP服务器模型其实是简单的.和并发的TCP服务器模型一样是创建一个子进程来处理的 算法和并发的TCP模型一样.

除非服务器在处理客户端的请求所用的时间比较长以外,人们实际上很少用这种模型

## 数据流程

Server                             |                       Client
-----------------------------------|---------------------------------------------
1. Establish a listening socket and wait for connections from clients |
                     | 2. Create a client socket and attempt to connect to server
3. Accept the client's connection attempt |
4. Send and receive data           | 4. Send and receive data
5. Close the connection            | 5. Close the connection.</td>

## 参考链接及文章

* http://www.unixprogram.com/socket/socket-faq.html
* http://www.linuxsir.org/main/?q=node/2
* http://tangentsoft.net/wskfaq/
* http://www.uwo.ca/its/doc/courses/notes/socket/
* http://fanqiang.chinaunix.net/a4/b7/20010508/112359.html
* [man 2 socket](http://man7.org/linux/man-pages/man2/socket.2.html)
