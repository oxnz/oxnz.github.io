---
layout: post
title: size_type, size_t, different_type and ptrdiff_t
type: post
categories:
- C++
tags:
- c++
---

## size_type

在标准库 string 类型中，最容易令人产生误解就是 `size()` 成员函数的返回值了。
事实上，size 操作返回的是 string::size_type 类型的值。
那怎样理解 size_type 这一类型呢，我引用《C++ Primer》一段原文简单解释一下:

>
string 类类型和许多其他库类型都定义了一些配套类型 (companion type)。
通过这些配套类型，库类型的使用就能和机器无关 (machine-independent)。
size_type 就是这些配套类型中的一种。
它定义为与 unsigned 型 (unsigned int 或 unsigned long) 具有相同的含义，而且可以保证足够大能够存储任意 string 对象的长度。
为了使用由 string 类型定义的 size_type 类型，程序员必须加上作用域操作符来说明所使用的 size_type 类型是由 string 类定义的。

这里特别注意的是: 任何存储 string 的 size 操作结果的变量必须为 string::size_type 类型，
同时，使用 size_type 类型时，必须指出该类型是在哪里定义的。
切记不要把 size 的返回值赋给一个 int 变量。

<!--more-->

不仅 string 类型定义了 size_type，其他标准库类型如 vector::size_type, list::size_type, deque::size_type, map::size_type, multimap::size_type, basic_string::size_type 等更多请查看 MSDN 详细介绍。

## size_t

size_t 类型定义在 cstddef 头文件中，该文件是 C 标准库中的头文件 stddef.h 的 C++ 版本。
它是一个与机器相关的 unsigned 类型，其大小足以存储内存中对象的大小。

与前面Demo中vector和string中的size操作类似，在标准库类型bitset中的size操作和count操作的返回值类型为size_t 。

## different_type

一种由 vector 类型定义的 signed 整型，用于存储任意两个迭代器间的距离。

## ptrdiff_t

与 size_t 一样，定义在 cstddef 头文件中定义的与机器相关的有符号整型，该类型具有足够的大小存储两个指针的差值，这两个指针指向同一个可能的最大数组。
