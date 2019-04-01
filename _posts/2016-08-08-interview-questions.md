---
title: Technical Interview Questions
---

This article describes serveral good interview questions.

<!--more-->

## Design and Algorithms

### Scheduler

* Priority Queue
	* Heap
* DAG
* typological sort
* cycle
	* detection
	* removing
* online algorithm

### Garbage collector

### multiplication

```cpp
void F(int* A, int* B, int N) {
    // Set prod to the neutral multiplication element
    int prod = 1;
    
    for (int i = 0; i < N; ++i) {
        // For element "i" set B[i] to A[0] * ... * A[i - 1]
        B[i] = prod;
        // Multiply with A[i] to set prod to A[0] * ... * A[i]
        prod *= A[i];
    }
    
    // Reset prod and use it for the right elements
    prod = 1;
    
    for (int i = N - 1; i >= 0; --i) {
        // For element "i" multiply B[i] with A[i + 1] * ... * A[N - 1]
        B[i] *= prod;
        // Multiply with A[i] to set prod to A[i] * ... * A[N - 1]
        prod *= A[i];
    }
}
```

1. 最大回文子串
2. 在线中位数统计（最大堆+最小队）
3. A.length=N, 包含数字为1..N，判断是否有重复

## Test

* How to test a random number generator
* A/B Test
	* Confidential Interval

## Concurrent Programming

stack interface

* top()
* pop()

v = stack.pop() implementation candidates:

1. pass in a reference
2. require a no-throw copy constructor or move constructor
	* std::is_nothrow_copy_constructible
	* std::is_nothrow_move_constructible
3. return a pointer to the popped item
	* hard memory management
	* more overhead for primitive types
4. provide both option 1 and either option 2 or 3

<!--more-->

## Coding

### Implementation

1. `uint32_t inet_aton(const char *ip); const char* inet_ntoa(uint32_t ip)`
2. `char* trim(char* s)`
3. strcpy

## Q&A

0. endian

   ```cpp
   uint32_t endian = 0x12345678;
   uint32_t i = 1;
   EXPECT_EQ(0x5678, *reinterpret_cast<uint16_t*>(&endian));
   EXPECT_TRUE(*reinterpret_cast<uint8_t*>(&i)&i);
   ```

1. `stable_sort()` complexity
	* O(N·log(N)2), where N = std::distance(first, last) applications of cmp. If additional memory is available, then the complexity is O(N·log(N)).
2. socket编程，如果client断电了，服务器如何快速知道？
	1. 使用定时器（适合有数据流动的情况）； 
	2. 使用socket选项SO_KEEPALIVE（适合没有数据流动的情况)
3. fork()一子进程程后 父进程癿全局发量子迍程能不能使用？
	* fork后子进程将会拥有父进程的几乎一切资源，父子进程的都各自有自己的全局变量。不能通用，不同于线程。对于线程，各个线程共享全局变量。
4. 4G的long型整数中找到一个最大的，如何做？
	* O(n)
	* 此题还有个变种，就是寻找K个最大或者最小的数。partition O(n) median-of-median
5. 有千万个string在内存 怎举高速查找，插入和删除？
	* hash O(1) 关键是如何做hash，对string做hash，要减少碰撞频率
	* BKDR Hash unsigned int BKDRHash(char *str) { unsigned int seed = 131; // 31 131 1313 13131 131313 etc.. unsigned int hash = 0;   while (*str) { hash = hash * seed + (*str++); }   return (hash & 0x7FFFFFFF); }
	* Order statistics : trie
6. tcp三次握手的过程，accept发生在三次握手哪个阶段？
7. Tcp流， udp的数据报，之间有什么区别，为什么TCP要叫做数据流？
	* TCP本身是面向连接的协议，S和C之间要使用TCP，必须先建立连接，数据就在该连接上流动，可以是双向的，没有边界。所以叫数据流 ，占系统资源多
	* UDP不是面向连接的，不存在建立连接，释放连接，每个数据包都是独立的包，有边界，一般不会合并。
	* TCP保证数据正确性，UDP可能丢包，TCP保证数据顺序，UDP不保证
8. const的含义及实现机制，比如：const int i,是怎么做到i只可读的？
	* const指示对象为常量，只读。
	* 实现机制：这些在编译期间完成，对于内置类型，如int， 编译器可能使用常数直接替换掉对此变量的引用。而对于结构体不一定。

      ```cpp
      const int i=100;
      int *p=const_cast<int*>(&i);
      *p=200;
      cout << i << ":" << *p << endl; // 100:200
      ```

	* 编译器在优化代码时把`cout<<i`直接优化成`cout<<100`了，所以虽然p和`&i`的值一样，但`cout<<i`不再通过访问i的地址输出。（反汇编时也有看到直接把数字压栈push 100 ）
这是因为，const型在压栈时，是使用的直接的数，就有点像C的#define a 100
对于非系统缺省类型，系统不知道怎么去直接替换，因此必须占据内存。

9. volatile的含义
	* 变量可能在编译器的控制或监控之外改变，告诉编译器不要优化该变量，如被系统时钟更新的变量。
10. `OFFSETOF(s, m)`的宏定义，s是结构类型，m是s的成员，求m在s中的偏移量。
	* `#define OFFSETOF（s, m） size_t（&((s*)0)->m）`
12. 设计一个洗牌的算法，并说出算法的时间复杂度
	* wrong： for i:=1 to n do swap(a[i], a[random(1,n)]);  // 不是真随机
	* `for i:=1 to n do swap(a[i], a[random(i,n)]);`
13. socket在什么情况下可读?

	>
	A socket is ready for reading if any of the following four conditions is true:
	>
	1. The number of bytes of data in the socket receive buffer is greater than or
	     equal to the current size of the low-water mark for the socket receive buffer.
	     A read operation on the socket will not block and will return a value greater than 0
	2.  The read half of the connections is closed (i.e., A TCP connection that has received a FIN).
	     A read operation on the socket will not block and will return 0 (i.e., EOF)
	3. The socket is a listening socket and the number of completed connection is nonzero.
	    An accept on the listening socket will normally not block, although we will describe a
	4. A socket error is pending. A read operation on the socket will not block and will return
	    an error (-1) with errno set to the specific error condition

14. 流量控制与拥塞控制的区别，节点计算机怎样感知网络拥塞了？
	* 拥塞控制是把整体看成一个处理对象的，流量控制是对单个的节点。
	* 感知的手段应该不少，比如在TCP协议里，TCP报文的重传本身就可以作为拥塞的依据。依据这样的原理， 应该可以设计出很多手段。
15. C++虚函数是如何实现的？
	* 使用虚函数表。 C++对象使用虚表， 如果是基类的实例，对应位置存放的是基类的函数指针；如果是继承类，对应位置存放的是继承类的函数指针（如果在继承类有实现）。所以 ，当使用基类指针调用对象方法时，也会根据具体的实例，调用到继承类的方法。
	* VTABLE bzero -> defer nullptr -> core dump
16. C++的虚函数有什么作用？
	* 虚函数作用是实现多态
	* 更重要的，虚函数其实是实现封装，使得使用者不需要关心实现的细节
	* 在很多设计模式中都是这样用法，例如Factory、Bridge、Strategy模式。
17. 非阻塞`connect()`如何实现
	* 将socket设置成non-blocking，操作方法同非阻塞read()、write();
18. 考标准IO缓冲，标准出错是不带缓缓冲的
	* 如若是涉及终端设备的其他流，则他们是行缓冲的；否则是全缓冲的。
	* printf是标准IO的一个，格式化打印到标准输出，在这里是行缓冲，那么没有遇到换行符也就是‘n’或者没有强制flush, 则不会输出。
20. 给出float与“零值”比较的 if 语句（假设变量名为var）
	* 浮点数在运算过成功运算通常伴随着因为无法精确表示而进行的近似或舍入。但是这种设计的好处是可以在固定的长度上存储更大范围的数。<br />

