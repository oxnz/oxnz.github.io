---
layout: post
title: Sorting Algorithm
date: 2014-04-17 15:22:27.000000000 +08:00
type: post
published: true
status: publish
categories:
- Algorithm
tags:
- sort
---

This article describe some sorting algorithms.

<!--more-->

## Table of Contents

* TOC
{:toc}

## Complexity

<table border="1">
<tbody>
<tr>
<th rowspan="2">Name</th>
<th colspan="3">Time Complexity</th>
<th rowspan="2">Space Complexity</th>
<th rowspan="2">stability</th>
<th rowspan="2">Implementation Complexity</th>
</tr>
<tr>
<th>Average-Case</th>
<th>Worst-Case</th>
<th>Best-Case</th>
</tr>
<tr>
<th>Insertion Sort</th>
<td>O(n^2)</td>
<td>O(n^2)</td>
<td>O(n)</td>
<td>O(1)</td>
<td><span style="color: #008000;">stable</span></td>
<td>Simple</td>
</tr>
<tr>
<th>Bubble Sort</th>
<td>O(n^2)</td>
<td>O(n^2)</td>
<td>O(n)</td>
<td>O(1)</td>
<td><span style="color: #008000;">stable</span></td>
<td>Simple</td>
</tr>
<tr>
<th>Selection Sort</th>
<td>O(n^2)</td>
<td>O(n^2)</td>
<td>O(n^2)</td>
<td>O(1)</td>
<td><span style="color: #ff0000;">unstable</span></td>
<td>Simple</td>
</tr>
<tr>
<th>Shell Sort</th>
<td>O(n^1.3)</td>
<td></td>
<td></td>
<td>O(1)</td>
<td><span style="color: #ff0000;">unstable</span></td>
<td>Complex</td>
</tr>
<tr>
<th>Quick Sort</th>
<td>O(nlog2n)</td>
<td>O(n^2)</td>
<td>O(nlog2n)</td>
<td>O(log2n)</td>
<td><span style="color: #ff0000;">unstable</span></td>
<td>Complex</td>
</tr>
<tr>
<th>Heap Sort</th>
<td>O(nlog2n)</td>
<td>O(nlog2n)</td>
<td>O(nlog2n)</td>
<td>O(1)</td>
<td><span style="color: #ff0000;">unstable</span></td>
<td>Complex</td>
</tr>
<tr>
<th>Merge Sort</th>
<td>O(nlog2n)</td>
<td>O(nlog2n)</td>
<td>O(nlog2n)</td>
<td>O(n)</td>
<td><span style="color: #008000;">stable</span></td>
<td>Complex</td>
</tr>
<tr>
<th>Radix Sort</th>
<td>O(d(n+1))</td>
<td>O(d(n+r))</td>
<td>O(d(n+r))</td>
<td>O(r)</td>
<td><span style="color: #008000;">stable</span></td>
<td>Complex</td>
</tr>
</tbody>
</table>

## 实现

### 冒泡排序 (bubble sort)

```c
void bubble_sort(int a[], int n) {
    for (int i = 0; i < n; ++i) {         for (int j = n-1; j > i; --j) {
            if (a[j-1] > a[j])
                swap(a[j-1], a[j]);
        }
    }
}
```

### 插入排序 (insertion sort)

insertion sort is an online algorithm

>
The average case is also quadratic, which makes insertion sort impractical for sorting large arrays.
However, **insertion sort is one of the fastest algorithms for sorting very small arrays**, even faster than quicksort; indeed, **good quicksort implementations use insertion sort for arrays smaller than a certain threshold, also when arising as subproblems**; the exact threshold must be determined experimentally and depends on the machine, but is commonly around ten.
<br/>[-from Wikipedia](https://en.wikipedia.org/wiki/Insertion_sort)

>
Insertion sort's advantage is that it only scans as many elements as needed to determine the correct location of the k+1st element, while selection sort must scan all remaining elements to find the absolute smallest element.
<br/>-from Wikipedia

Implementation

```c
void insert_sort(int a[], int n) {
    for (int i = 1; i < n; ++i)
        for (int j = i; j > 0 && a[j] < a[j-1]; --j)
            swap(a[j-1], a[j]);
}
```

### 选择排序 (selection sort)

* standard selection sort
* tree (NlgN) (tournament sort)

```c
void selection_sort(int *a, int len) {
    register int i, j, min, t;
    for(i = 0; i < len - 1; i ++) {
        min = i;
        //查找最小值
        for(j = i + 1; j < len; j ++)
            if(a[min] > a[j]) min = j;
        //交换
        if(min != i) {
            t = a[min];
            a[min] = a[i];
            a[i] = t;
        }
    }
}
```

### 希儿排序 (shell sort)

<p>希尔排序，也称递减增量排序算法，是插入排序的一种更高效的改进版本。希尔排序是非stable排序算法。</p>
<p>希尔排序是基于插入排序的以下两点性质而提出改进方法的：</p>
<p>插入排序在对几乎已经排好序的数据操作时， 效率高， 即可以达到线性排序的效率<br />
但插入排序一般来说是低效的， 因为插入排序每次只能将数据移动一位</p>

```cpp
void shell_sort(int* a, int n) {
    for (int gap = n; gap > 0; gap >>= 1) {
        for (int i = gap; i < n; ++i) {             int tmp = a[i];             int j;             for (j = i - gap; j >= 0 &amp;&amp; a[j] > tmp; j -= gap) {
                a[j+gap] = a[j];
            }
            a[j+gap] = tmp;
        }
    }
}
```

### 快速排序 (quicksort)

快速排序是由东尼·霍尔所发展的一种排序算法。在平均状况下，排序 n 个项目要Ο(n log n)次比较。在最坏状况下则需要Ο(n2)次比较，但这种状况并不常见。事实上，快速排序通常明显比其他Ο(n log n) 算法更快，因为它的内部循环（inner loop）可以在大部分的架构上很有效率地被实现出来。

```cpp
template
void quicksort(T array[], Index left, Index right) {
    if (left < right) {
        Index l = left;
        Index r = right;
        T m = array[l];
        while (l < r) {
            while (l < r &amp;&amp; array[r] >= m)
                --r;
            if (l < r)
                array[l++] = array[r];
            while (l < r &amp;&amp; array[l] < m)
                ++l;
            if (l < r)
                array[r--] = array[l];
        }
        array[l] = m;
        quicksort(array, left, l-1);
        quicksort(array, l+1, right);
    }
}
```

### 堆排序 (heapsort)

```c
//#筛选算法#%
void sift(int d[], int ind, int len) {
	//#置i为要筛选的节点#%
	int i = ind;

	//#c中保存i节点的左孩子#%
	int c = i * 2 + 1; //#+1的目的就是为了解决节点从0开始而他的左孩子一直为0的问题#%

	while(c < len)//#未筛选到叶子节点#%
	{
		//#如果要筛选的节点既有左孩子又有右孩子并且左孩子值小于右孩子#%
		//#从二者中选出较大的并记录#%
		if(c + 1 < len &amp;&amp; d[c] < d[c + 1])
			c++;
		//#如果要筛选的节点中的值大于左右孩子的较大者则退出#%
		if(d[i] > d[c]) break;
		else {
			//#交换#%
			swap(d[c], d[i]);
 			//#重置要筛选的节点和要筛选的左孩子#%
			i = c;
			c = 2 * i + 1;
		}
	}

	return;
}

void heap_sort(int d[], int n) {
	//#初始化建堆, i从最后一个非叶子节点开始#%
	for(int i = (n - 2) / 2; i >= 0; i--)
		sift(d, i, n);

	for(int j = 0; j < n; j++) {
                //#交换#%
		swap(d[0], d[n-j-1];

		//#筛选编号为0 #%
		sift(d, 0, n - j - 1);
	}
}
```

### 归并排序 (mergesort)

```c
/**
 * @brief 归并排序
 *
 * @param *list 要排序的数组
 * @param n 数组中的元素数量
 */
void merge_sort(int *list, int list_size) {
    if (list_size > 1)
    {
        // 把数组平均分成两个部分
        int *list1 = list;
        int list1_size = list_size / 2;
        int *list2 = list + list_size / 2;
        int list2_size = list_size - list1_size;
        // 分别归并排序
        merge_sort(list1, list1_size);
        merge_sort(list2, list2_size);

        // 归并
        merge_array(list1, list1_size, list2, list2_size);
    }
}

/**
 * @brief 归并两个有序数组
 *
 * @param list1
 * @param list1_size
 * @param list2
 * @param list2_size
 */
void merge_array(int *list1, int list1_size, int *list2, int list2_size) {
    int i, j, k;
    i = j = k = 0;

    // 声明临时数组用于存储归并结果
    int list[list1_size + list2_size];

    // note: 只要有一个数组到达了尾部就要跳出
    // 也就是说只有两个都没有到达尾部的时候才执行这个循环
    while (i < list1_size &amp;&amp; j < list2_size)
    {
        // 把较小的那个数据放到结果数组里， 同时移动指针
        list[k++] = list1[i] < list2[j] ? list1[i++] : list2[j++];
    }

    // 如果 list1 还有元素，把剩下的数据直接放到结果数组
    while (i < list1_size)
    {
        list[k++] = list1[i++];
    }

    // 如果 list2 还有元素，把剩下的数据直接放到结果数组
    while (j < list2_size)
    {
        list[k++] = list2[j++];
    }

    // 把结果数组 copy 到 list1 里
    for (int ii = 0; ii < (list1_size + list2_size); ++ii)
    {
        list1[ii] = list[ii];
    }

}
```

### count sort

### 基数排序 (radix sort)

基数排序（英语：Radix sort）是一种非比较型整数排序算法，其原理是将整数按位数切割成不同的数字，然后按每个位数分别比较。由于整数也可以表达字符串（比如名字或日期）和特定格式的浮点数，所以基数排序也不是只能使用于整数。基数排序的发明可以追溯到1887年赫尔曼·何乐礼在打孔卡片制表机（Tabulation Machine）上的贡献[1]。

它是这样实现的：将所有待比较数值（正整数）统一为同样的数位长度，数位较短的数前面补零。然后，从最低位开始，依次进行一次排序。这样从最低位排序一直到最高位排序完成以后, 数列就变成一个有序序列。

基数排序的方式可以采用LSD（Least significant digital）或MSD（Most significant digital），LSD的排序方式由键值的最右边开始，而MSD则相反，由键值的最左边开始。

### bucket sort
