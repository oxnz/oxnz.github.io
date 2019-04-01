---
title: Parallel Programming
---

## Table of Contents

* TOC
{:toc}

## OpenMP

* 线程级别
* 共享存储
* 隐式（数据分配方式）
* 可扩展性差

<!--more-->

### Data-Sharing Rules

**OpenMP does not put any restriction to prevent data races between shared variables. This is a responsibility of a programmer.**

* shared
: there exists one instance of this variable which is shared among all threads
* private
: each thread in a team of threads has its own local copy of the private variable

* Implicit Rules
	* The data-sharing attribute of variables, which are declared outside the parallel region, is usually shared
	* The loop iteration variables, however, are private by default
	* The variables which are declared locally within the parallel region are private
* Explicit rules
	* Shared
		* The `shared(list)` clause declares that all the variables in `list` are shared
		* Shared variables introduce an overhead, because one instance of a variable is shared between multiple threads. Therefore, it is often best to minimize the number of shared variables when a good performance is desired.
	* Private
		* The `private(list)` clause declares that all the variables in `list` are private
		* When a variable is declared private, OpenMP replicates this variable and assigns its local copy to each thread
		* The behavior of private variables is sometimes unintuitive. Let us assume that a private variable has a value before a parallel region. However, the value of the variable at the beginning of the parallel region is undefined. Additionally, the value of the variable is undefined also after the parallel region.
	* Default
		* `default(shared)`
		* `default(none)`
			* forces a programmer to explicitly specify the data-sharing attributes of all variables
* Rule NO.1
	* always write parallel regions with the `default(none)` clause
	* declare private variables inside parallel regions whenever possible

http://jakascorner.com/blog/2016/06/omp-data-sharing-attributes.html

```c
size_t count_mp(const vector<int>& v) {
	size_t n = v.size(), cnt = 0;
#pragma omp parallel for shared(n) reduction(+:cnt)
	for (int i = 1; i < n; ++i) /* i is private by default */
		cnt += count(v[i]);
	return cnt;
}
```

## MPI (multi-process)

* 进程级别
* 分布式存储
* 显式（数据分配方式）
* 可扩展性好

## Conclusion


OpenMP 采用共享存储，意味着只适应于 SMP，DSM 机器，不适合集群。

* MPI 虽然适合于各种机器，但是编程模型复杂
	* 需要分析及划分应用程序问题，并将问题映射到分布式进程集合；
	* 需要解决**通信延迟和负载不均衡**两个主要问题。
    * 调试 MPI 程序麻烦
* MPI 程序可靠性差，一个进程出问题，整个程序将错误

一个并行算法的好坏，主要看是否很好的解决了通信延迟和负载不均衡问题。

与 OpenMP，MPI 相比，MapReduce 优势在于：

* 自动并行
* 容错
* 学习门槛低

SMP: Symmetric multi-processing: 共享总线与内存，单一操作系统映象。在软件上可扩展，而硬件上不能。

DSM: Distributed shared memory: SMP 的扩展。物理上分布存储；单一地址空间；非一致内存访问；单一操作系统映象。

