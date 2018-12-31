---
layout: post
title: ! 'Standard Template Library: Algorithms'
date: 2014-04-26 00:52:24.000000000 +08:00
type: post
published: true
status: publish
categories:
- C++
tags:
- algorithm
- c++
- stl
hreflangs:
- en
- zh
---

The header defines a collection of functions especially designed to be used on ranges of elements.

A range is any sequence of objects that can be accessed through iterators or pointers, such as an array or an instance of some of the STL containers. Notice though, that algorithms operate through iterators directly on the values, not affecting in any way the structure of any possible container (it never affects the size or storage allocation of the container).

<!--more-->

## Table of Contents

* TOC
{:toc}

## Non-modifying sequence operations

C++ STL Non-mutating algorithms 是一组不破坏操作数据的模板函数，用来对序列数据进行逐个处理、元素查找、子序列搜索、统计和匹配。

### all_of

```cpp
template<class InputIterator, class UnaryPredicate>
bool all_of(InputIterator first, InputIterator last, UnaryPredicate pred) {
	for (; first != last; ++first) if (!pred(*first)) return false;
	return true;
}
```

### any_of

```cpp
template<class InputIterator, class UnaryPredicate>
bool any_of (InputIterator first, InputIterator last, UnaryPredicate pred) {
	for (; first != last; ++first) if (pred(*first)) return true;
	return false;
}
```

### none_of

```cpp
template<class InputIterator, class UnaryPredicate>
  bool none_of (InputIterator first, InputIterator last, UnaryPredicate pred) {
	for (; first != last; ++first) if (pred(*first)) return false;
	return true;
}
```

### for_each

```cpp
template<class InputIterator, class Function>
Function for_each(InputIterator first, InputIterator last, Function fn) {
	for (; first != last; ++first) fn(*first);
	return fn; // return std::move(fn); for C++11
}
```

Example:

```cpp
template<typename T>
struct printer {
    size_t count;

    printer() : count(0) {}
    void operator()(T x) {
        std::cout << x << std::endl;
        ++count;
    }
};

int main(int argc, char *argv[]) {
    std::list<int> nums;
    copy(std::istream_iterator<int>(std::cin), std::istream_iterator<int>(),
            back_inserter(nums));
    printer<int> p = for_each(nums.begin(), nums.end(), printer<int>());
    std::cout << "count(nums) = " << p.count << std::endl;

    return 0;
}
```

#### functor

仿函数,又或叫做函数对象，是STL（标准模板库）六大组件（

* 容器、
* 配置器、
* 迭代器、
* 算法、
* 配接器、
* 仿函数）之一；

仿函数虽然小，但却极大的拓展了算法的功能，几乎所有的算法都有仿函数版本。
例如，查找算法`find_if`就是对`find`算法的扩展，标准的查找是两个元素相等就找到了，但是什么是相等在不同情况下却需要不同的定义，如地址相等，地址和邮编都相等，虽然这些相等的定义在变，但算法本身却不需要改变，这都多亏了仿函数。 仿函数之所以叫做函数对象，是因为仿函数都是定义了()函数运算操作符的类。

另外 functor 比普通函数效率要高，因为默认內联。同样內联的还有lambda。`inline` 需要编译器支持才行。

### find


find算法用于查找等于某值的元素。它在迭代器区间[first , last)上查找等于value值的元素，如果迭代器iter所指的元素满足 `*iter == value` ，则返回迭代器iter，未找则返回last。

```cpp
template<class InputIterator, class T>
InputIterator find(InputIterator first, InputIterator last, const T& val) {
	for (; first != last; ++first) if (*first == val) return first;
	return last;
}
```

### find_if

find_if算法 是find的一个谓词判断版本，它利用返回布尔值的谓词判断pred，检查迭代器区间[first, last)上的每一个元素，如果迭代器iter满足`pred(*iter) == true`，表示找到元素并返回迭代器值iter；未找到元素，则返回last。

```cpp
template<class InputIterator, class UnaryPredicate>
InputIterator find_if(InputIterator first, InputIterator last, UnaryPredicate pred) {
	for (; first != last; ++first) if (pred(*first)) return first;
	return last;
}
```

### find_if_not

```cpp
template<class InputIterator, class UnaryPredicate>
InputIterator find_if_not(InputIterator first, InputIterator last, UnaryPredicate pred) {
	for (; first != last; ++first) if (!pred(*first)) return first;
	return last;
}
```

### find_end

find_end算法在一个序列中搜索出最后一个与另一序列匹配的子序列。有如下两个函数原型，在迭代器区间[first1, last1)中搜索出与迭代器区间[first2, last2)元素匹配的子序列，返回首元素的迭代器或last1。

```cpp
template<class ForwardIterator1, class ForwardIterator2>
InputIterator1 find_end(InputIterator1 first1, ForwardIterator1 last1,
	InputIterator2 first2, InputIterator2 last2) {
	if (first2 == last2) return last1;

	ForwardIterator1 ret = last1;

	while (first1 != last1) {
		ForwardIterator1 it1 = first1;
		ForwardIterator2 it2 = first2;
		while (*it1 == *it2) {
			++it1; ++it2;
			if (it2 == last2) { ret = first1; break; }
			if (it1 == last1) return ret;
		}
		++first1;
	}
	return ret;
}
```

### find_first_of

find_first_of算法用于查找位于某个范围之内的元素。它有两个使用原型，均在迭代器区间[first1, last1)上查找元素*i，使得迭代器区间[first2, last2)有某个元素*j，满足`*i ==*j`或满足二元谓词函数`comp(*i, *j)==true`的条件。元素找到则返回迭代器i，否则返回last1。

```cpp
template<class InputIterator, class ForwardIterator>
InputIterator find_first_of (InputIterator first1, InputIterator last1,
	ForwardIterator first2, ForwardIterator last2) {
	for (; first1 != last1; ++first1)
		for (ForwardIterator it = first2; it != last2; ++it)
			if (*it == *first1) return first1;
	return last1;
}
```

### adjacent_find

adjacent_find算法用于查找相等或满足条件的邻近元素对。其有两种函数原型：一种在迭代器区间[first , last)上查找两个连续的元素相等时，返回元素对中第一个元素的迭代器位置。另一种是使用二元谓词判断binary_pred，查找迭代器区间[first , last)上满足binary_pred条件的邻近元素对，未找到则返回last。

```cpp
template<class ForwardIterator>
ForwardIterator adjacent_find(ForwardIterator first, ForwardIterator last) {
	if (first != last) {
		ForwardIterator next = first;
		++next;
		while (next != last) {
			if (*first == *next) return first;
			++first;
			++next;
		}
	}
	return last;
}
```

### count

```cpp
template<class InputIterator, class T>
typename iterator_traits<InputIterator>::difference_type
	count(InputIterator first, InputIterator last, const T& val) {
	typename iterator_traits<InputIterator>::difference_type cnt = 0;
	for (; first != last; ++first) if (*first == val) ++cnt;
	return cnt;
}
```

### count_if

### mismatch

>
`first2`: Input iterator to the initial position of the second sequence. Up to as many elements as in the range [first1,last1) can be accessed by the function.

```cpp
template<class InputIterator1, class InputIterator2>
pair<InputIterator1, InputIterator2>
	mismatch(InputIterator1 first1, InputIterator1 last1, InputIterator2 first2) {
	while ((first1 != last1) && (*first1 == *first2)) { ++first1; ++first2; }
	return std::make_pair(first1, first2);
}
```

### equal

equal算法类似于mismatch，equal算法也是逐一比较两个序列的元素是否相等，只是equal函数的返回值为bool值true/false，不是返回迭代器值。它有如下两个原型，如果迭代器区间[first1，last1)和迭代器区间[first2， first2+(last1 - first1))上的元素相等（或者满足二元谓词判断条件binary_pred） ，返回true，否则返回false.

```cpp
template<class InputIterator1, class InputIterator2>
bool equal(InputIterator1 first1, InputIterator1 last1, InputIterator2 first2) {
	while (first1 != last1) {
		if (!(*first1 == *first2)) return false;
		++first1; ++first2;
	}
	return true;
}
```

### is_permutation

```cpp
template<class InputIterator1, class InputIterator2>
bool is_permutation(InputIterator1 first1, InputIterator1 last1, InputIterator2 first2) {
	std::tie(first1, first2) = std::mismatch(first1, last1, first2);
	if (first1 == last1) return true;
	InputIterator2 last2 = first2;
	std::advance(last2, std::distance(first1, last1));
	for (InputIterator1 it1 = first1; it1 != last1; ++it1) {
		if (std::find(first1, it1, *it1) == it1) {
			auto n = std::count(first2, last2, *it1);
			if (n == 0 || std::count(it1, last1, *it1) != n) return false;
		}
	}
	return true;
}
```

### search

search算法函数在一个序列中搜索与另一序列匹配的子序列。它有如下两个原型，在迭代器区间[first1, last1)上找迭代器区间[first2, last2)完全匹配（或者满足二元谓词binary_pred）子序列，返回子序列的首个元素在[first1, last1)区间的迭代器值，或返回last1表示没有匹配的子序列。

### search_n

重复元素子序列搜索search_n算法：搜索序列中是否有一系列元素值均为某个给定值的子序列，它有如下两个函数原型，分别在迭代器区间[first, last)上搜索是否有count个连续元素，其值均等于value（或者满足谓词判断binary_pred的条件），返回子序列首元素的迭代器，或last以表示没有重复元素的子序列。

## Modifying sequence operations

Mutating algorithms 就是一组能够修改容器元素数据的模板函数，可进行序列数据的复制，变换等。

### copy

>
The ranges shall not overlap in such a way that result points to an element in the range [first,last). For such cases, see `copy_backward`.

```cpp
template<class InputIterator, class OutputIterator>
OutputIterator copy(InputIterator first, InputIterator last, OutputIterator dest) {
	while (first != last) *dest++ = *first++;
	return oit;
}
```

Example

```cpp
int arr[] = {10, 20, 30, 40, 50, 60, 70};
vector<int> v;
vector<int>::iterator it;

v.resize(7);   // important!, otherwise the operation would fail

// usage 1
copy(arr, arr+7, v.begin());

// usage 2: shift left one element
copy(arr + 1, arr + 7, arr);

// usage 3: read array
copy(istream_iterator<int>(cin), istream_iterator<int>(), back_inserter(v));
// usage 4: output elements, sep by space
copy(v.begin(), v.end(), ostream_iterator<int>(cout, " "));
```

### copy_n

```cpp
template<class InputIterator first, class Size, class OutputIterator>
OutputIterator copy_n (InputIterator first, Size n, OutputIterator dest) {
	while (n-- > 0) *dest++ = *first++;
	return dest;
}
```

### copy_if

```cpp
template<class InputIterator, class OutputIterator, class UnaryPredicate>
OutputIterator copy_if (InputIterator first, InputIterator last,
	OutputIterator dest, UnaryPredicate pred) {
	for (; first != last; ++first) if (pred(*first)) *dest++ = *first;
	return dest;
}
```

### copy_backward

```cpp
template<class BidirectionalIterator1, class BidirectionalIterator2>
BidirectionalIterator2 copy_backward(BidirectionalIterator1 first,
	BidirectionalIterator1 last, BidirectionalIterator2 dest) {
	while (last != first) *(--dest) = *(--last);
	return dest;
}
```

Example

```cpp
// shift right one element
vector<int> v;
v.resize(v.size() + 1);
copy_backward(v.begin(), v.end() - 1, v.end());
```

### swap

Note: 泛型算法swap和容器中的swap成员函数是两个不同角度和概念

```cpp
template <class T>
void swap(T& a, T& b) {
	T c(a); a=b; b=c; // C++98
	T c(std::move(a)); a = std::move(b); b = std::move(c); // C++11
}
template <class T, size_t N>
void swap(T (&a)[N], T (&b)[N]) {
	for (size_t i = 0; i < N; ++i) swap(a[i], b[i]);
}
```

### swap_ranges

```cpp
template<class ForwardIterator1, class ForwardIterator2>
  ForwardIterator2 swap_ranges (ForwardIterator1 first1, ForwardIterator1 last1,
	ForwardIterator2 first2) {
  while (first1 != last1) swap(*first1++, *first2++);
  return first2;
}
```

### iter_swap

```cpp
template<class ForwardIterator1, class ForwardIterator2>
  void iter_swap (ForwardIterator1 a, ForwardIterator2 b) {
	swap(*a, *b);
}
```

## transform

```cpp
template <class InputIterator, class OutputIterator, class UnaryOperator>
OutputIterator transform ( InputIterator first1, InputIterator last1,
                             OutputIterator result, UnaryOperator op ) {
	while (first1 != last1) *result++ = op(*first1++);
	return result;
}

template <class InputIterator1, class InputIterator2,
           class OutputIterator, class BinaryOperator>
OutputIterator transform ( InputIterator1 first1, InputIterator1 last1,
                             InputIterator2 first2, OutputIterator result,
                             BinaryOperator binary_op ) {
	while (!first1 != last1) *result++ = binary_op(*first1++, *first2++);
	return result;
}
```

Applies an operation sequentially to the elements of one (1) or two (2) ranges and stores the result in the range that begins at result.

```cpp
std::string s("hello world");
std::transform(s.begin(), s.end(), [](unsigned char c) { return std::toupper(c); });
std::cout << s << std::endl;
std::vector<int> ips({132113135, 20111113, 91111117, 411122226});
transform(ips.begin(), ips.end(), ostream_iterator<string>(cout, "\n"), [](uint32_t ip) {
    return to_string((ip & 0xFF000000)>>24) + '.' + to_string((ip & 0x00FF0000)>>16) + '.'
        + to_string((ip & 0x0000FF00)>>8) + '.'	+ to_string((ip & 0x000000FF)>>0);
});
```

### replace

[http://www.cplusplus.com/reference/algorithm/replace/](http://www.cplusplus.com/reference/algorithm/replace/)

```cpp
template<class ForwardIterator, class T>
void replace(ForwardIterator first, ForwardIterator last,
    const T& old_value, const T& new_value) {
	for (; first != last; ++first) if (*first == old_value) *first = new_value;
}
```

### replace_copy

Copies the elements in the range [first,last) to the range beginning at result, replacing the appearances of old_value by new_value.

```cpp
template<class InputIterator, class OutputIterator, class T>
replace_copy(InputIterator first, InputIterator last, OutputIterator result,
	const T& old_value, const T& new_value) {
	for (; first != last; ++first)
		*result++ = (*first == old_value) ? new_value : *first;
	return result;
}
```

### replace_copy_if

### fill

```cpp
template<class ForwardIterator, class T>
void fill(ForwardIterator first, ForwardIterator last, const T& val) {
	while (first != last) *first++ = val;
}
```

### fill_n

Assigns val to the first n elements of the sequence pointed by first.

```cpp
template<class ForwardIterator, class Size, class T>
void fill_n(ForwardIterator first, Size n, const T& val) { while (n-- > 0) *first++ = val; }
```

### generate

```cpp
template <class ForwardIterator, class Generator>
void generate (ForwardIterator first, ForwardIterator last, Generator gen) {
	while (first != last) *first++ = gen();
}
```

Example

```cpp
class RandomScoreGenerator {
	std::mt19937 generator; // non-const(internal state changes)
				// DO NOT use across threads
	std::uniform_int_distribution<int> distribution;
public:
	RandomScoreGenerator() : distribution(0, 100) { }
	int operator()() { return distribution(generator); }
};
void fill_with_random_score(std::vector<int>& scores, size_t n) {
	scores.resize(n);
	std::generate(scores.begin(), scores.end(), RandomScoreGenerator());
}
```

### generate_n

```cpp
template <class ForwardIterator, class Size, class Generator>
void generate_n(ForwardIterator first, Size n, Generator gen) {
	while (n-- > 0) *first++ = gen();
}
```

### remove

Transforms the range [first,last) into a range with all the elements that compare equal to val removed, and returns an iterator to the new end of that range.

```cpp
template <class ForwardIterator, class T>
ForwardIterator remove(ForwardIterator first, ForwardIterator last, const T& val) {
	ForwardIterator result = first;
	for (; first != last; ++first) if (!(*first == val)) *result++ = move(*first);
	return result;
}
```

### remove_copy

Copies the elements in the range [first,last) to the range beginning at result, except those elements that compare equal to val.

```cpp
template<class InputIterator, class OutputIterator, class T>
OutputIterator remove_copy(InputIterator first, InputIterator last,
	OutputIterator dest, const T& val) {
	for (; first != last; ++first) if (!(*first == val)) *dest++ = *first;
	return dest;
}
```

### remove_copy_if

Copies the elements in the range [first,last) to the range beginning at result, except those elements for which pred returns true.

```cpp
template<class InputIterator, class OutputIterator, class UnaryPredicate>
OutputIterator remove_copy_if(InputIterator first, InputIterator last,
	OutputIterator dest, UnaryPredicate pred) {
	for (; first != last; ++first)
		if (!pred(*first)) *dest++ = *first;
	return dest;
}
```

### unique

Removes all but the first element from every consecutive group of equivalent elements in the range [first,last).

```cpp
template <class ForwardIterator>
ForwardIterator unique(ForwardIterator first, ForwardIterator last) {
	ForwardIterator result = first;
	while (++first != last)
		if (!(*result == *first))
			*(++result) = *first;
	return ++result;
}
```

### unique_copy

```cpp
template<class InputIterator, class OutputIterator>
OutputIterator unique_copy(InputIterator first, InputIterator last,
	OutputIterator result) {
	if (first == last) return result;
	*result = *first;
	while (++first != last) {
		typename iterator_traits<InputIterator>::value_type val = *first;
		if (!(*result == val))
			*(++result) = val;
	return ++result;
}
```

### reverse

```cpp
template<class BidirectionalIterator>
void reverse(BidirectionalIterator first, BidirectionalIterator last) {
	while ((first != last) && (first != --last))
		std::iter_swap(first++, last);
}
```

### rotate

Rotates the order of the elements in the range [first,last), in such a way that the element pointed by middle becomes the new first element.

```cpp
template<class ForwardIterator>
void rotate(ForwardIterator first, ForwardIterator middle, ForwardIterator last) {
	ForwardIterator next = middle;
	while (first != next) {
		swap(*first++, *next++);
		if (next == last) next = middle;
		else if (first == middle) middle = next;
	}
}
```

### random_shuffle

**considered harmful**

```cpp
template <class RandomAccessIterator, class RandomNumberGenerator>
void random_shuffle(RandomAccessIterator first, RandomAccessIterator last,
	RandomNumberGenerator& gen) {
	iterator_traits<RandomNumberGenerator>::difference_type i, n;
	n = last - first;
	for (i = n-1; i > 0; --i)
		swap(first[i], first[gen(i+1)]);
}
```

### shuffle

Rearranges the elements in the range [first,last) randomly, using g as uniform random number generator.

```cpp
template <class RandomAccessIterator, class URNG>
void shuffle(RandomAccessIterator first, RandomAccessIterator last, URNG& g) {
	for (auto i = last - first - 1; i > 0; --i) {
		std::uniform_int_distribution<decltype(i)> d(0, i);
		swap(first[i], first[d(g)]);
	}
}
```

>
The gist is, std::shuffle is an improvement over std::random_shuffle, and C++ programmers should prefer using the former.

## Partitions

### is_partitioned

Returns true if all the elements in the range [first,last) for which pred returns true precede those for which it returns false.

```cpp
template<class InputIterator, class UnaryPredicate>
bool is_partitioned(InputIterator first, InputIterator last, UnaryPredicate pred) {
	while (first != last && pred(*first))
		++first;
	for (; first != last; ++first)
		if (pred(*first)) return false;
	return true;
}
```

### partition

```cpp
template<class BidirectionalIterator, class UnaryPredicate>
BidirectionalIterator partition(BidirectionalIterator first,
	BidirectionalIterator last, UnaryPredicate pred) {
	for (; first != last; ++first) {
		while (pred(*first))
			if (++first == last) return first;
		do {
			--last;
			if (first == last) return first;
		} while (!pred(*last));
		std::iter_swap(first, last);
	}
	return first;
}
```

Example

```cpp
std::array<int, 7> arr {1, 2, 3, 4, 5, 6, 7};
auto it = std::partition(arr.begin(), arr.end(), [](int v) { return (v%2) == 1; });
std::cout << "odd elements: ";
std::copy(arr.begin(), it, std::ostream_iterator<int>(std::cout, " "));
std::cout << std::endl;
std::cout << "even elements: ";
std::copy(it, arr.end(), std::ostream_iterator<int>(std::cout, " "));
std::cout << std::endl;
// output
// odd elements: 1 7 3 5
// even elements: 4 6 2
```

## Sorting

### sort

Complexity

>
On average, linearithmic in the distance between first and last: Performs approximately N*log2(N) (where N is this distance) comparisons of elements, and up to that many element swaps (or moves).

### stable_sort

Complexity

>
* If enough extra memory is available, linearithmic in the distance between first and last: Performs up to N*log2(N) element comparisons (where N is this distance), and up to that many element moves.
* Otherwise, polyloglinear in that distance: Performs up to N*log22(N) element comparisons, and up to that many element swaps.

### partial_sort

Rearranges the elements in the range [first,last), in such a way that the elements before middle are the smallest elements in the entire range and are sorted in ascending order, while the remaining elements are left without any specific order.

```cpp
template <class RandomAccessIterator>
  void partial_sort (RandomAccessIterator first, RandomAccessIterator middle,
                     RandomAccessIterator last);
template <class RandomAccessIterator, class Compare>
  void partial_sort (RandomAccessIterator first, RandomAccessIterator middle,
                     RandomAccessIterator last, Compare comp);
```

Complexity

>
On average, less than linearithmic in the distance between first and last: Performs approximately N*log(M) comparisons of elements (where N is this distance, and M is the distance between first and middle). It also performs up to that many element swaps (or moves).

### is_sorted

```cpp
template<class ForwardIterator>
bool is_sorted(ForwardIterator first, ForwardIterator last) {
	if (first == last) return true;
	ForwardIterator next = first;
	for (; ++next != last; ++first)
		if (*next < *first) return false;
	return true;
}
```

### is_sorted_until

Returns an iterator to the first element in the range [first,last) which does not follow an ascending order.

```cpp
template<class ForwardIterator>
ForwardIterator is_sorted_until(ForwardIterator first, ForwardIterator last) {
	if (first == last) return first;
	ForwardIterator next = first;
	for (; ++next != last; ++first)
		if (*next < *first) return next;
	return last;
}
```

## Binary search

### lower_bound

```cpp
template<class ForwardIterator, class T>
ForwardIterator lower_bound(ForwardIterator first, ForwardIterator last, const T& val) {
	ForwardIterator it;
	iterator_traits<ForwardIterator>::difference_type count, step;
	count = distance(first, last);
	while (count > 0) {
		it = first;
		step = count/2;
		advance(it, step);
		if (*it < val) {
			first = ++it;
			count -= step + 1;
		} else count = step;
	}
	return first;
}
```

### upper_bound

Returns an iterator pointing to the first element in the range [first,last) which compares greater than val.

```cpp
template<class ForwardIterator, class T>
ForwardIterator upper_bound(ForwardIterator first, ForwardIterator last, const T& val) {
	ForwardIterator it;
	iterator_traits<ForwardIterator>::difference_type count, step;
	count = std::distance(first, last);
	while (count > 0) {
		it = first;
		step = count/2;
		std::advance(it, step);
		if (!(val < *it)) { first = ++it; count -= step + 1; }
		else count = step;
	}
	return first;
}
```

### upper_bound

```cpp
template <class ForwardIterator, class T>
ForwardIterator upper_bound(ForwardIterator first, ForwardIterator last, const T& val) {
	ForwardIterator it;
	iterator_traits<ForwardIterator>::difference_type count, step;
	count = std::distance(first, last);
	while (count > 0) {
		it = first;
		step = count >> 1;
		std::advance(it, step);
		if (!(val < *it)) {
			first = ++it;
			count -= step + 1;
		} else count = step;
	}
	return first;
}
```

### binary_search

```cpp
template <class ForwardIterator, class T>
bool binary_search(ForwardIterator first, ForwardIterator last, const T& val) {
	first = std::lower_bound(first, last, val);
	return (first != last && !(val < *first));
}
```

## Merge

### merge

```cpp
template<class InputIterator1, class InputIterator2, class OutputIterator>
OutputIterator merge(InputIterator1 first1, InputIterator1 last1,
	InputIterator2 first2, InputIterator2 last2, OutputIterator result) {
	if (first1 == last1) return std::copy(first2, last2, result);
	if (first2 == last2) return std::copy(first1, last1, result);
	*result ++ = (*first2 < *first1) ? *first2++ : *first1++;
}
```

## Heap

```cpp
template <class RandomAccessIterator, class Distance>
Distance __is_heap_until(RandomAccessIterator first, Distance n) {
    Distance parent = 0;
    for (Distance child = 1; child < n; ++child) {
        if (first[parent] < first[child]) return child;
        if ((child & 1) == 0) ++parent;
    return n;
}
```

### push_heap

Given a heap in the range [first,last-1), this function extends the range considered a heap to [first,last) by placing the value in (last-1) into its corresponding location within it.

A range can be organized into a heap by calling make_heap. After that, its heap properties are preserved if elements are added and removed from it using push_heap and pop_heap, respectively.

### pop_heap

Rearranges the elements in the heap range [first,last) in such a way that the part considered a heap is shortened by one: The element with the highest value is moved to (last-1).

While the element with the highest value is moved from first to (last-1) (which now is out of the heap), the other elements are reorganized in such a way that the range [first,last-1) preserves the properties of a heap.

### make_heap

Rearranges the elements in the range [first,last) in such a way that they form a heap.

A heap is a way to organize the elements of a range that allows for fast retrieval of the element with the highest value at any moment (with pop_heap), even repeatedly, while allowing for fast insertion of new elements (with push_heap).

### sort_heap

Sorts the elements in the heap range [first,last) into ascending order.

The elements are compared using `operator<` for the first version, and `comp` for the second, which shall be the same as used to construct the heap.

The range loses its properties as a heap.

### is_heap

Returns true if the range [first,last) forms a heap, as if constructed with make_heap.

```cpp
template <class RandomAccessIterator>
inline bool is_heap(RandomAccessIterator first, RandomAccessIterator last) {
	return is_heap_until(first, last) == last;
}
```

### is_heap_until

```cpp
template <class RandomAccessIterator>
RandomAccessIterator is_heap_until(RandomAccessIterator first, RandomAccessIterator last) {
	return first + __is_heap_until(first, std::distance(first, last));
}
```

## Min/Max

### min

```cpp
template<class T>
const T& min(const T& a, const T& b) { return !(b < a) ? a : b; }
```

### max

```cpp
template<class T, class Compare>
const T& max(const T& a, const T& b, Compare comp) { return comp(a, b) ? b : a; }
```

### minmax

```cpp
template<class T>
pair<const T&, const T&> minmax(const T& a, const T& b) {
	return (b < a) ? std::make_pair(b, a) : std::make_pair(a, b);
}
```

### min_element

```cpp
template<class ForwardIterator>
  ForwardIterator min_element(ForwardIterator first, ForwardIterator last) {
	if (first == last) return last;
	ForwardIterator smallest = first;
	while (++first != last)
		if (*first < *smallest) smallest = first;
	return smallest;
}
```

### max_element

### minmax_element

## Other

### lexicographical_compare

Returns true if the range [first1,last1) compares lexicographically less than the range [first2,last2).

```cpp
template<class InputIterator1, class InputIterator2>
bool lexicographical_compare(InputIterator1 first1, InputIterator1 last1,
	InputIterator2 first2, InputIterator2 last2) {
    for (; (first1 != last1) && (first2 != last2); ++first1, ++first2) {
        if (*first1 < *first2) return true;
        if (*first2 < *first1) return false;
    }
    return (first1 == last1) && (first2 != last2);
}
```

### next_permutation

* [std::next_permutation implementation explanation](http://stackoverflow.com/questions/11483060/stdnext-permutation-implementation-explanation)
* [Next permutation: When C++ gets it right](http://wordaligned.org/articles/next-permutation)

### prev_permutation

```cpp
template <class BidirectionalIterator>
bool prev_permutation(BidirectionalIterator first, BidirectionalIterator last) {
    if (first == last) return false;
    BidirectionalIterator i = last;
    if (first == --i) return false;

    BidirectionalIterator i1, i2;
    while (true) {
        i1 = i;
        if (*i1 < *--i) {
            i2 = last;
            while (!(*--i2 < *i))
                ;
            std::iter_swap(i, i2);
            std::reverse(i1, last);
            return true;
        }
        if (i == first) {
            std::reverse(first, last);
            return false;
        }
    }
}
```

## References

* [http://www.cplusplus.com/reference/algorithm/](http://www.cplusplus.com/reference/algorithm/)
* [https://channel9.msdn.com/Events/GoingNative/2013/rand-Considered-Harmful](https://channel9.msdn.com/Events/GoingNative/2013/rand-Considered-Harmful)
