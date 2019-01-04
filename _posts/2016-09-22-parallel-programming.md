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

