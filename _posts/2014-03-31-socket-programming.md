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

## 基本概念

### OSI参考模型,其七层模型从下到上分别为
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

<p>现在最流行的网络协议无疑就是TCP/IP(Transmission Control Protocol/Internet Protocol)协议.<br />
注:<br />
l IP （Internet Protocol），网际协议；IP是TCP/IP的最底层，高层协议都要转化为IP包，IP包含了源地址和目的地址，路由决策也发生在IP层；<br />
l ICMP （Internet Control Message Protocol），网际报文协议；它包括了数据包的错误、控制等相关信息。比如ping命令就是利用ICMP来测试一个网络的连接情况的工具；<br />
l TCP （Transmission Control Protocol），传输控制协议。TCP运行在IP之上，是基于数据流连接和面向的协议，应用程序把数据要经过TCP/IP的分割成若干包，这样数据就以字节流发送和接收，到达目的地后，TCP/IP再按顺序进行组装。TCP/IP要保证机器与机器之间的连接的可靠性，还要有纠错。TCP是否被选择，取决于应用程序或服务；<br />
l UDP （User Datagram Protocol） ，用户数据报协议 ，象TCP一样运行在IP之上，是基于数据报或分组的协议，UDP/IP可以直接发送和接收数据报文，而不必做验证，这一点与TCP/IP不同。TCP是否被选择，取决于应用程序或服务；</p>
<h1>基本接口</h1>
<p>以Unix/Linux平台为例,系统会建立许多网络服务程序</p>
<pre class="lang:default decode:true">$netstat -a
Proto Recv-Q Send-Q Local Address      Foreign Address          State
tcp        0      0         *:1975                  :                      LISTEN
udp        0      0         *:1978                  :
tcp        0      0 MYServer:34320   192.168.1.2:1521       ESTABLISHED</pre>
<p>以上可以看到有三个网络连接,一个是TCP接连在1975端口侦听,一个UDP连接在1978端口,另外一个TCP连接是连接到DB的<br />
我们可以看出,客户端程序需要通过”主机名:端口号”与服务器建立连接.主机名其实就是IP地址.<br />
上面的MYServer其实是192.168.1.3, 这样的主机名与IP的对应关系由本机的host文件或DNS服务器解析提供.</p>
<pre class="lang:default decode:true">$more /etc/hosts
# that require network functionality will fail.
127.0.0.1      localhost.localdomain   localhost
192.168.1.3   MYServer

$ more /etc/resolv.conf
nameserver 192.168.1.1</pre>
<p>当然,我们在编程时无需查询这些文件或服务器,系统提供了API:<br />
<code>gethostbyname/gethostbyaddr</code></p>
<pre class="lang:default decode:true">#include &lt;netdb.h&gt;
extern int h_errno;
struct hostent *gethostbyname(const char *name);

#include &lt;sys/socket.h&gt;        /* for AF_INET */
struct hostent *gethostbyaddr(const char *addr, int len, int type);</pre>
<p>它们会返回一个指针,指向如下结构的对象</p>
<pre class="lang:default decode:true">struct     hostent {
   char   h_name;        / official name */
   char   **h_aliases;    /* alias list */
   int    h_addrtype;     /* address type */
   int    h_length;       /* address length */
   char   **h_addr_list;  /* address list */
};
#define h_addr h_addr_list[0]
/* backward compatibility */</pre>
<p><code>h_addr_list</code>是一个与域名对应的IP地址的列表,勤快的程序员会依次尝试连接列表中返回的IP地址<br />
懒惰的程序员只会用<code>h_addr,h_addr_list</code>列表中的第一个IP地址<br />
不同的应用程序使用不同的端口和协议,比如常用的ftp就用21端口和tcp协议</p>
<pre class="lang:default decode:true">$more /etc/services
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
...</pre>
<p>同样,程序中是无需查询这个文件的,Unix提供了<code>getservbyname</code></p>
<pre class="lang:default decode:true">#include &lt;netdb.h&gt;
struct servent *getservbyname(const char *name, const char *proto);
返回
struct servent {
             char    s_name;        / official service name */
             char    **s_aliases;    /* alias list */
             int     s_port;         /* port number */
             char    s_proto;       / protocol to use */
         }</pre>
<p>知道主机名(IP)和端口号,我们就可以编写在这台主机的运行的或是连接到它的网络应用程序了<br />
Unix/Linux系统中是通过提供套接字(socket)来进行网络编程的.网络程序通过socket和其它几个函数的调用,会返回一个通讯的文件描述符,我们<br />
可以将这个描述符看成普通的文件的描述符来操作,可以通过向描述符读写操作实现网络之间的数据交流.</p>
<h3>2.1.打开一个socket</h3>
<p><code>int socket(int domain,int type,int protocol)</code><br />
domain:说明我们网络程序所在的主机采用的通讯协族(AF_UNIX和AF_INET等).AF_UNIX只能够用于单一的Unix系统进程间通信,而<code>AF_INET</code>是针对Internet的,因而可以允许在远程主机之间通信(当我们mansocket时发现domain可选项是PF_*而不是AF_*,因为glibc是posix的实现所以用PF代替了AF,不过我们都可以使用的).<br />
type:我们网络程序所采用的通讯协议<code>(SOCK_STREAM,SOCK_DGRAM</code>等)SOCK_STREAM表明我们用的是TCP协议,这样会提供按顺序的,可靠,双向,面向连接的比特流.SOCK_DGRAM表明我们用的是UDP协议,这样只会提供定长的,不可靠,无连接的通信.<br />
protocol:由于我们指定了type,所以这个地方我们一般只要用0来代替就可以了socket为网络通讯做基本的准备.成功时返回文件描述符,失败时返回-1,看<code>errno</code>可知道出错的详细情况.</p>
<h3>2.2. 将socket绑定定指定的端口—bind</h3>
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
<p>2.3.侦听socket—listen (服务器端)</p>
<p><code>int listen(int sockfd,int backlog)</code><br />
sockfd:是bind后的文件描述符.<br />
backlog:设置请求排队的最大长度.当有多个客户端程序和服务端相连时,使用这个表示可以介绍的排队长度.listen函数将bind的文件描述符变为监听套接字.返回的情况和bind一样.<br />
2.4.等待接收请求—accept (服务器端)</p>
<p><code>int accept(int sockfd, struct sockaddr*addr,int* addrlen)</code><br />
sockfd:是listen后的文件描述符.<br />
addr,addrlen是用来给客户端的程序填写的,服务器端只要传递指针就可以了.bind,listen和accept是服务器端用的函<br />
数,accept调用时,服务器端的程序会一直阻塞到有一个客户程序发出了连接.accept成功时返回最后的服务器端的文件描述符,这个时候服务器<br />
端可以向该描述符写信息了.失败时返回-1<br />
2.5.连接到socket—connect</p>
<p><code>int connect(int sockfd,struct sockaddr* serv_addr,int addrlen)</code><br />
sockfd:socket返回的文件描述符.<br />
serv_addr:储存了服务器端的连接信息.其中sin_add是服务端的地址<br />
addrlen:serv_addr的长度<br />
connect函数是客户端用来同服务端连接的.成功时返回0,sockfd是同服务端通讯的文件描述符失败时返回-1.</p>
<p>2.6. 利用socket传输数据</p>
<p>2.6.1. read和write</p>
<p><code>ssize_t read(int fd,void *buf,size_t nbyte)</code><br />
read函数是负责从fd中读取内容.当读成功时,read返回实际所读的字节数,<br />
如果返回的值是0表示已经读到文件的结束了,小于0表示出现了错误.<br />
如果错误为EINTR说明读是由中断引起的,<br />
如果是ECONNREST表示网络连接出了问题. 和上面一样,我们也写一个自己的读函数.<br />
<code>ssize_t write(int fd,const void *buf,size_t nbytes)</code><br />
write函数将buf中的nbytes字节内容写入文件描述符fd.<br />
成功时返回写的字节数.失败时返回-1. 并设置errno变量. 在网络程序中,当我们向套接字文件描述符写时有俩种可能.<br />
1)write的返回值大于0,表示写了部分或者是全部的数据.<br />
2)返回的值小于0,此时出现了错误.我们要根据错误类型来处理.<br />
如果错误为EINTR表示在写的时候出现了中断错误.<br />
如果为EPIPE表示网络连接出现了问题(对方已经关闭了连接).<br />
为了处理以上的情况,我们自己编写一个写函数来处理这几种情况.<br />
2.6.2. recv和send</p>
<p>和read和write差不多.不过它们提供 了第四个参数来控制读写操作.<br />
<code>int recv(int sockfd,void *buf,int len,int flags)<br />
int send(int sockfd,void *buf,int len,int flags)</code><br />
前面的三个参数和read,write一样,第四个参数可以是0或者是以下的组合<br />
<code>_______________________________________________________________<br />
| MSG_DONTROUTE | 不查找路由表 |<br />
| MSG_OOB | 接受或者发送带外数据 |<br />
| MSG_PEEK | 查看数据,并不从系统缓冲区移走数据 |<br />
| MSG_WAITALL | 等待所有数据 |<br />
|--------------------------------------------------------------|</code><br />
MSG_DONTROUTE:是send函数使用的标志.这个标志告诉IP协议.目的主机在本地网络上面,没有必要查找路由表.这个标志一般用网络诊断和路由程序里面.<br />
MSG_OOB:表示可以接收和发送带外的数据.关于带外数据我们以后会解释的.<br />
MSG_PEEK:是recv函数的使用标志,表示只是从系统缓冲区中读取内容,而不清楚系统缓冲区的内容.这样下次读的时候,仍然是一样的内容.一般在有多个进程读写数据时可以使用这个标志.<br />
MSG_WAITALL是recv函数的使用标志,表示等到所有的信息到达时才返回.使用这个标志的时候recv回一直阻塞,直到指定的条件满足,或者是发生了错误. 1)当读到了指定的字节时,函数正常返回.返回值等于len 2)当读到了文件的结尾时,函数正常返回.返回值小于len 3)当操作发生错误时,返回-1,且设置错误为相应的错误号(errno)<br />
如果flags为0,则和read,write一样的操作.还有其它的几个选项,不过我们实际上用的很少,可以查看Linux Programmer’s Manual得到详细解释.</p>
<p>2.6.3.recvfrom和sendto</p>
<p><code>int recvfrom(int sockfd,void *buf,int len,unsigned int flags,struct sockaddr * from int *fromlen)<br />
int sendto(int sockfd,const void *msg,int len,unsigned int flags,struct sockaddr *to int tolen)</code><br />
sockfd,buf,len的意义和read,write一样,分别表示套接字描述符,发送或接收的缓冲区及大小.recvfrom负责从sockfd接收数据,如果from不是NULL,那么在from里面存储了信息来源的情况,如果对信息的来源不感兴趣,可以将from和fromlen设置为NULL.sendto负责向to发送信息.此时在to里面存储了收信息方的详细资料.<br />
2.6.4.recvmsg和sendmsg</p>
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
<p>2.7.套接字的关闭close/shutdown</p>
<p>关闭套接字有两个函数close和shutdown.用close时和我们关闭文件一样.<br />
<code>int close(int sockfd);<br />
int shutdown(int sockfd,int howto);</code><br />
TCP连接是双向的(是可读写的),当我们使用close时,会把读写通道都关闭,有时侯我们希望只关闭一个方向,这个时候我们可以使用shutdown.针对不同的howto,系统回采取不同的关闭方式.<br />
howto=0这个时候系统会关闭读通道.但是可以继续往接字描述符写.<br />
howto=1关闭写通道,和上面相反,着时候就只可以读了.<br />
howto=2关闭读写通道,和close一样 在多进程程序里面,如果有几个子进程共享一个套接字时,如果我们使用shutdown, 那么所有的子进程都不能够操作了,这个时候我们只能够使用close来关闭子进程的套接字描述符.</p>
<p>3.最常用的服务器模型.<br />
3.1.循环服务器:<br />
循环服务器在同一个时刻只可以响应一个客户端的请求<br />
3.1.1.循环服务器之UDP服务器<br />
UDP循环服务器的实现非常简单:UDP服务器每次从套接字上读取一个客户端的请求,处理, 然后将结果返回给客户机.<br />
可以用下面的算法来实现:</p>
<pre class="lang:default decode:true">socket(...);
bind(...);
while(1) {
    recvfrom(...);
    process(...);
    sendto(...);
}</pre>
<p>因为UDP是非面向连接的,没有一个客户端可以老是占住服务端. 只要处理过程不是死循环, 服务器对于每一个客户机的请求总是能够满足.</p>
<p>3.1.2. 循环服务器之TCP服务器<br />
TCP循环服务器的实现也不难:TCP服务器接受一个客户端的连接,然后处理,完成了这个客户的所有请求后,断开连接.<br />
算法如下:</p>
<pre class="lang:default decode:true">socket(...);
bind(...);
listen(...);
while(1) {
    accept(...);
    while(1) {
        read(...);
        process(...);
        write(...);
    }
    close(...);
}</pre>
<p>TCP循环服务器一次只能处理一个客户端的请求.只有在这个客户的所有请求都满足后, 服务器才可以继续后面的请求.这样如果有一个客户端占住服务器不放时,其它的客户机都不能工作了.因此,TCP服务器一般很少用循环服务器模型的.</p>
<p>3.2.并发服务器<br />
并发服务器在同一个时刻可以响应多个客户端的请求</p>
<p>3.2.1.并发服务器之TCP服务器<br />
为了弥补循环TCP服务器的缺陷,人们又想出了并发服务器的模型. 并发服务器的思想是每一个客户机的请求并不由服务器直接处理,而是服务器创建一个 子进程来处理.<br />
框架如下:</p>
<pre class="lang:default decode:true">socket(...);
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
}</pre>
<p>TCP并发服务器可以解决TCP循环服务器客户机独占服务器的情况. 不过也同时带来了一个不小的问题.为了响应客户机的请求,服务器要创建子进程来处理. 而创建子进程是一种非常消耗资源的操作.</p>
<p>3.2.2.并发服务器之多路复用I/O<br />
为了解决创建子进程带来的系统资源消耗,人们又想出了多路复用I/O模型。</p>
<ul>
<li><a title="Linux select" href="http://xinyi.sourceforge.net/linux-select/" target="_blank">linux select</a></li>
<li><a title="Linux poll" href="http://xinyi.sourceforge.net/linux-poll/" target="_blank">linue poll</a></li>
<li><a title="Linux epoll" href="http://xinyi.sourceforge.net/linux-epoll/" target="_blank">linux epoll</a></li>
<li>unix kqueue</li>
<li>windows IOCP</li>
</ul>
<p>其中 select，poll，epoll 请参见我的其他三篇文章。</p>
<p>使用select后我们的服务器程序就变成了.</p>
<pre class="lang:default decode:true">// 初始化(socket,bind,listen);
while(1) {
    // 设置监听读写文件描述符(FD_*);
    // 调用select;
    if (/* listen_fd is ready */) { //如果是倾听套接字就绪,说明一个新的连接请求建立
        // 建立连接(accept);
        // 加入到监听文件描述符中去;
    } else { //否则说明是一个已经连接过的描述符
        // 进行操作(read或者write);
    }
}</pre>
<p>poll和 epoll 也类似上面的框架。多路复用I/O可以解决资源限制的问题.着模型实际上是将UDP循环模型用在了TCP上面. 这也就带来了一些问题.如由于服务器依次处理客户的请求,所以可能会导致有的客户 会等待很久.</p>
<p>3.2.3.并发服务器之UDP服务器<br />
人们把并发的概念用于UDP就得到了并发UDP服务器模型. 并发UDP服务器模型其实是简单的.和并发的TCP服务器模型一样是创建一个子进程来处理的 算法和并发的TCP模型一样.<br />
除非服务器在处理客户端的请求所用的时间比较长以外,人们实际上很少用这种模型</p>
<p>4.数据流程</p>
<table>
<tbody>
<tr>
<th>Server</th>
<th>Client</th>
</tr>
<tr>
<td>1. Establish a listening socket and wait for connections from clients.</td>
<td></td>
</tr>
<tr>
<td></td>
<td>2. Create a client socket and attempt to connect to server.</td>
</tr>
<tr>
<td>3. Accept the client's connection attempt.</td>
<td></td>
</tr>
<tr>
<td>4. Send and receive data.</td>
<td>4. Send and receive data.</td>
</tr>
<tr>
<td>5. Close the connection.</td>
<td>5. Close the connection.</td>
</tr>
</tbody>
</table>
<p>5.实例分析<br />
总的来说,利用socket进行网络编程并不难,却有点繁琐,稍不留心,就会出错,在Ｃ++网络编程卷一中就举过这样一个例子:</p>
<pre>Error example of socket
#include &lt;sys/types.h&gt;
#include &lt;sys/socket.h&gt;

const int PORT_NUM=2007;
const int BUFSIZE=256;

int echo_server()
{
      struct sockaddr_in addr;
      int addr_len; //error 1 :未初始化addr_len
      char buf[BUFSIZE];
      int n_handle;
       //error 2: s_handle在windows平台上的类型为SOCKET,移植性不好
      int s_handle=socket(PF_UNIX,SOCK_DGRAM,0);

      if(s_handle==-1)      return -1;
      // error 3: 整个addr 结构要先清零
       // error 4: PF_UNIX应对应 PF_INET
      addr.sin_family=AF_INET;
       // error 5: PORT_NUM应使用网络字节顺序
      addr.sin_port=PORT_NUM;
      addr.sin_addr.addr=INSDDR_ANY;

      if(bind(s_handle,(struct sockaddr*) &amp;addr,sizeof addr)==-1)
           return -1;
      // error 6: 未调用listen
       // error 7: 未加括号,导致运算符优先级问题
       // error ８: accept调用错误, 上面的socket调用应用SOCK_STREAM
      if(n_handle=accept(s_handle,(struct sockaddr*)&amp;addr, &amp;addr_len)!=-1)
      {
           int n;
            // error ９: read应该读取n_handle,而不是s_handle
           while((n=read(s_handle,buf,sizeof(buf))&gt;0)
                 write(n_handle,buf,n);
       // error ９: 没有检查write返回值,有可能造成数据丢失
           close(n_handle);
      }
      return 0;
}
</pre>
<p>所有凡是使用socket编程的程序中都想用一些相对简单的类来封装这些繁琐的接口调用<br />
我也曾经做过这样的尝试:</p>
<pre>/*
* Copyright  2005 JinWei Bird Studio All rights reserved
*
* Filename: wf_socket.h
* Description: Test program of socket lib
*
* Version:1.0
* Create date: 08/19/2005
* Author: Walter Fan, walter.fan@gmail.com
*/
#include "wf_base.h"

#ifndef BACKLOG
#define BACKLOG 50
#endif

#ifndef HOSTLEN
#define HOSTLEN 256
#endif

class Socket
{
protected:
    int m_nPort;
    int m_nSock;
    int m_nBacklog;
    char* m_szHost;

    bool m_bServer;
    fd_set m_fdSet;
    int m_fdNum;
public:
    Socket(int port);
    Socket(char* host,int port);
    virtual ~Socket();
    virtual int Wait()=0;//encapsulate select and accept
    virtual int Open()=0;//encapsulate socket,listen or connect
    int Close();//encapsulate close socket handle
    int GetSocketID();
    int CloseFD(int fd);//encapsulate close file handle
};

Socket::Socket(char* host,int port)
:m_szHost(host),m_nPort(port),m_bServer(false),m_fdNum(0)
{
    m_nSock=-1;
    m_nBacklog=BACKLOG;
    FD_ZERO(&amp;m_fdSet);
    msg_trace("Socket construct as Client...");
}

Socket::Socket(int port)
:m_szHost("127.0.0.1"),m_nPort(port),m_bServer(true),m_fdNum(0)
{
    m_nSock=-1;
    m_nBacklog=BACKLOG;
    FD_ZERO(&amp;m_fdSet);
    msg_trace("Socket construct as Server...");
}

Socket::~Socket()
{
    Close();
    msg_trace("Socket destruct...");
}


int Socket::Close()//encapsulate close socket handle
{
    if (m_bServer)
    {
          for (int fd = 0; fd &lt;= m_fdNum; fd++)
          {
                if (FD_ISSET(fd, &amp;m_fdSet))
                     close(fd);
          }
    }
    else
    {
          close(m_nSock);
    }
    return 0;

}
int Socket::GetSocketID()
{
    return m_nSock;
}

int Socket::CloseFD(int fd)//encapsulate close file handle
{
    int retval=0;
    retval=close(fd);
    if(retval&lt;0)
          return retval;
    FD_CLR(fd, &amp;m_fdSet);
    m_fdNum--;
    return retval;
}

//------------------------TCP --------------------//
class TCPSocket:public Socket
{

public:
    TCPSocket(int port):Socket(port){};
    TCPSocket(char* host,int port):Socket(host,port){};

    int Wait();
    int Open();
};


int TCPSocket::Open()
{
    int retval=0;
    //int     sock_id;           // the socket
    struct  sockaddr_in   saddr;   // build our address here
    struct  hostent        *hp;   // this is part of our

    m_nSock = socket(AF_INET, SOCK_STREAM, 0);  // get a socket
    if ( m_nSock == -1 )
        return -1;
    if (m_nSock &gt; m_fdNum)
          m_fdNum = m_nSock;
    //---set socket option---//
    int socket_option_value = 1;
    retval=setsockopt(m_nSock, SOL_SOCKET, SO_REUSEADDR,
                &amp;socket_option_value, sizeof(socket_option_value));
    if(retval&lt;0)
          return -1;
    //---build address and bind it to socket---//

    bzero((char *)&amp;saddr, sizeof(saddr));   // clear out struct
    gethostname(m_szHost, HOSTLEN);         // where am I ?
    hp = gethostbyname(m_szHost);           // get info about host
    if (hp == NULL)
        return -1;                                        // fill in host part
    bcopy((char *)hp-&gt;h_addr, (char *)&amp;saddr.sin_addr, hp-&gt;h_length);
    saddr.sin_port = htons(m_nPort);        // fill in socket port
    saddr.sin_family = AF_INET ;            // fill in addr family

    if(m_bServer)
    {
        retval=bind(m_nSock, (struct sockaddr *)&amp;saddr, sizeof(saddr));
        if (retval!= 0 )
            return -1;

        //---arrange for incoming calls---//
        retval=listen(m_nSock, m_nBacklog);
        if ( retval!= 0 )
            return -1;
        FD_SET(m_nSock,&amp;m_fdSet);
    }
    else
    {
           retval=connect(m_nSock,(struct sockaddr *)&amp;saddr, sizeof(saddr));
           //msg_trace("connect return "&lt;&lt;retval);
         if (retval!=0)
           return -1;
    }
    return m_nSock;
}

int TCPSocket::Wait()
{
    int retval=0;
    if(m_bServer)
    {
        fd_set fd_set_read;
        int fd,clientfd;
        struct sockaddr_un from;
        socklen_t from_len=sizeof(from);

        while(true)
        {
                //msg_trace("select begin...");
                retval=select(m_fdNum+1,&amp;m_fdSet,NULL,NULL,NULL);
                //msg_trace("select return "&lt;&lt;retval);
                if(retval&lt;0)
                     return -1;
                for(fd=0;fd&lt;=m_fdNum;fd++)
                {
                     if(FD_ISSET(fd,&amp;m_fdSet))
                     {
                           if(fd==m_nSock)
                           {
                                clientfd=accept(m_nSock,(struct sockaddr*)&amp;from,&amp;from_len);
                                //msg_trace("accept return "&lt;&lt;clientfd);
                                if(clientfd&lt;0)
                                      return -1;
                                FD_SET(clientfd,&amp;m_fdSet);
                                m_fdNum++;
                                continue;
                           }
                           else
                                return fd;
                     }
                }
        }

    }
    return retval;
}

int main(int argc, char *argv[])
{

    FILE* fp;
    time_t thetime;
    if(fork()==0)//client side
    {
    int sock, ret=0;
    char buf[100];
        TCPSocket oSock("127.0.0.1",1975);
        while((sock =oSock.Open())==-1);
        ret=write(sock,"hi,walter",10);
        if(ret&lt;0) err_quit("write error");
        ret=read(sock,buf,sizeof(buf));
        if(ret&lt;0) err_quit("read error");
        msg_trace("Client get "&lt;&lt;buf);
    }
    else//server side
    {
    int fd, ret=0;
    char buf[100];
        TCPSocket oSock(1975);
        oSock.Open();
        fd = oSock.Wait();
    if(fd&lt;0)    err_quit("wait failed");
        ret=read(fd,buf,sizeof(buf));
        if(ret&lt;0) err_quit("read failed");
        msg_trace("Server get "&lt;&lt;buf);
        ret=write(fd,"Good bye",10);
        if(ret&lt;0) err_quit("wait failed");
        oSock.CloseFD(fd);
     }
     return 0;
}
</pre>
<h2>参考链接及文章</h2>
<ol>
<li>http://www.unixprogram.com/socket/socket-faq.html</li>
<li>http://www.linuxsir.org/main/?q=node/2</li>
<li>http://tangentsoft.net/wskfaq/</li>
<li>http://www.uwo.ca/its/doc/courses/notes/socket/</li>
<li>http://fanqiang.chinaunix.net/a4/b7/20010508/112359.html</li>
<li><a title="man 2 socket" href="http://man7.org/linux/man-pages/man2/socket.2.html" target="_blank">man 2 socket</a></li>
</ol>
