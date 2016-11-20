---
title: Algorithms
---

![algorithm](/assets/algorithm.jpg)

>
Algorithms + Data Structures = Programs
>
by Niklaus Wirth

There are three different stages in understanding an algorithms:

* K: known
* D: wrote code
* R: <...> times

<!--more-->

## Table of Contents

* TOC
{:toc}

## [Sorting Algorithms](/2014/04/17/sorting-algorithms/)

* insertion sort: online
* merge sort
* quick sort
* selection sort
	* standard
	* tree (NlgN) (tournament sort)
* heap sort
* bubble
* shell
* bucket
* radix
* count

## Data Structures

### Array

### List

### Hash Table

### Tree

#### BST

#### AVL

#### RBT

#### B Tree

#### B+ Tree

### Heap

### Union-Find Set

并查集是一种树型的数据结构，用于处理一些不相交集合 (Disjoint Sets) 的合并及查询问题。常常在使用中以森林来表示。

集就是让每个元素构成一个单元素的集合，也就是按一定顺序将属于同一组的元素所在的集合合并。

* <a href="http://zh.wikipedia.org/zh-cn/%E5%B9%B6%E6%9F%A5%E9%9B%86">http://zh.wikipedia.org/zh-cn/并查集 </a>
* <a title=" 并查集(Union-Find)算法介绍" href="http://blog.csdn.net/dm_vincent/article/details/7655764">http://blog.csdn.net/dm_vincent/article/details/7655764</a>
* <a title="数据结构——并查集的应用" href="http://blog.csdn.net/yujuan_mao/article/details/8301019">http://blog.csdn.net/yujuan_mao/article/details/8301019</a>
* <a title="并查集" href="http://www.cnblogs.com/cyjb/p/UnionFindSets.html" target="_blank">http://www.cnblogs.com/cyjb/p/UnionFindSets.html</a>

## String

### KMP

### BM

### Trie

not suitable for substring searching

### Radix Tree

substring matching, high performance full text search

### Suffix Tree

suitable for substring searching

## Dynamic Programming

### LCS

L[i, j] =

* 0, i = 0 or j = 0
* `L[i-1, j-1] + 1`, i > 0 and j > 0 and a[i] = b[j]
* `max(L[i, j-1], L[i-1, j])`, i > 0 and j > 0 and a[i] &ne; b[j]

Algorithm:

```python
for i in range(0, n):
    L[i, 0] = 0
for j in range(0, m):
    L[0, j] = 0

for i in range(1, n):
    for j in range(1, m):
        if a[i] == b[j]:
            L[i, j] = L[i-1, j-1] + 1
        else:
            L[i, j] = max(L[i, j-1], L[i-1, j])
return L[n, m]
```

Complexity:

* time: &theta;(nm)
* space: &theta;(n+m)

### LIS

O(nlgn)

### Knapsack

* Objects: U = {u1, u2, ..., un}
* Volumes: s1, s2, ..., sn
* Values: v1, v2, ..., vn
* Capacity: C

Algorithm:

```python
for i in range(0, n):
    V[i, 0] = 0
for j in range(0, C):
    V[0, j] = 0

for i in range(1, n):
    for j in range(1, C):
        V[i, j] = V[i-1, j]
        if s[i] <= j:
            V[i, j] = max(V[i, j], V[i-1, j-s[i]] + v[i])
return V[n, C]
```

Complexity:

* time: &theta;(nC)
* space: &theta;(C)

### Floyd

```python
for k in range(1, n):
    for i in range(1, n):
        for j in range(1, n):
            D[i, j] = min(D[i, j], D[i, k] + D[k, j])
```

Complexity:

* time: &theta;(n3)
* space: &theta;(n2)

### edit distance
