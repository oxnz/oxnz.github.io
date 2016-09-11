---
layout: post
title: STL Iterator
type: post
categories:
- C++
tags: [stl]
---

## Table of Contents

* TOC
{:toc}

## 反向迭代器 (Reverse Iterator)

定义

反向迭代器 (Reverse Iterator) 是一种反向遍历容器的迭代器。也就是，从最后一个元素到第一个元素遍历容器。反向迭代器将自增（和自减）的含义反过来了：对于反向迭代器，++运算将访问前一个元素，而--运算则访问下一个元素。

作用

1. 反向迭代器需要使用自减操作符：标准容器上的迭代器 (reverse_iterator) 既支持自增运算，也支持自减运算。
但是，流迭代器由于不能反向遍历流，因此流迭代器不能创建反向迭代器。
2. 可以通过 `reverse_iterator::base()` 将反向迭代器转换为普通迭代器使用，从逆序得到普通次序。
这是因为: 有些容器的成员函数只接受 iterator 类型的参数，所以如果你想要在 ri 所指的位置插入一个新元素，你不能直接这么做，因为 vector 的 insert 函数不接受 reverse_iterator。如果你想要删除 ri 所指位置上的元素也会有同样的问题。erase 成员函数会拒绝 reverse_iterator，坚持要求 iterator。
为了完成删除和一些形式的插入操作，你必须先通过 base 函数将 reverse_iterator 转换成 iterator，然后用 iterator 来完成工作。

<!--more-->

例子

```cpp
void test_reverse() {
    int a[] = {-2, -1, 0, 1, 2, 3, 4};
    std::list<int> nums(a, a + sizeof(a)/sizeof(int));
    std::copy(nums.begin(), nums.end(), std::ostream_iterator<int>(std::cout, " "));
    std::cout << std::endl;

    std::list<int>::reverse_iterator rit = nums.rbegin();
    while(rit != nums.rend())
        std::cout << *rit++ << " ";
    std::cout << std::endl;

    // 使用base()实现insert或erase等操作。
    std::vector<int> vect(a, a + sizeof(a)/sizeof(int));
    // 反向迭代器指向2
    std::vector<int>::reverse_iterator vrit = std::find(vect.rbegin(), vect.rend(), 2);
    // 注意：正向迭代器是指向3
    std::vector<int>::iterator it(vrit.base());
    inserter(vect, it) = 10;
    std::copy(vect.begin(), vect.end(), std::ostream_iterator<int>(std::cout, " "));
    std::cout << std::endl;
}
```


## 插入型迭代器 (Insert Iterator) 或插入器 (inserter)

定义

插入型迭代器 (Insert Iterator)，又叫插入器 (Inserter)。

作用

插入迭代器的主要功能为把一个赋值操作转换为把相应的值插入容器的操作。

算法库对所有在容器上的操作有约束:
**决不修改容器的大小 (不插入、不删除)**
有了插入迭代器，既使得算法库可以通过迭代器对容器插入新的元素，又不违反这一约束，即保持了设计上的一致性。

类型

### 尾部插入器 (back_insert_iterator)

使用：通过调用容器的push_back()成员函数来插入元素<br />
功能：在容器的尾端插入元素<br />
限制：只有提供了push_back()成员函数的容器中<br />
适用：vector deque list<br />

```cpp
explicit back_insert_iterator(Container& _Cont);
template<class Container>
back_insert_iterator<Container> back_inserter(Container& _Cont);
```

### 头部插入器 (front_insert_iterator)

使用：通过调用容器的push_front()成员函数来插入元素<br />
功能：在容器的前端插入元素<br />
限制：只有提供了push_front()成员函数的容器中<br />
适用：deque list<br />

```cpp
explicit front_insert_iterator(Container& _Cont);
template<class Container>
front_insert_iterator<Container> front_inserter(Container& _Cont);
```

### 普通插入器 (insert_iterator)

使用：通过调用insert()成员函数来插入元素，并由用户指定插入位置<br />
功能：在容器的指定位置插入元素<br />
限制：所有STL容器都提供了insert()函数.<br />
适用：所有STL容器<br />

```cpp
insert_iterator(Container& _Cont, typename Container::iterator _It);
template<class Container>
insert_iterator<Container> inserter(Container& _Cont, typename Container::iterator _Where);
```

例子

```cpp
#include <iostream>
#include <vector>
#include <list>
#include <iterator>

using namespace std;

template<typename Container>
void PrintElements(Container c) {
    std::copy(c.begin(), c.end(), ostream_iterator(cout, " "));
    cout << endl;
}

int main() {
    vector<int> vecSrc;
    list<int> vecDest;

    for(vector<int>::size_type i = 0; i < 3; ++i)
        vecSrc.push_back(i);

    // 1. 类back_insert_iterator与函数back_inserter
    copy(vecSrc.begin(), vecSrc.end(), back_insert_iterator<list<int>>(vecDest));
    // copy(vecSrc.begin(), vecSrc.end(), back_inserter(vecDest));  // 效果一样
    PrintElements(vecDest);

    // 2. 类front_insert_iterator与函数front_inserter
    copy(vecSrc.begin(), vecSrc.end(), front_insert_iterator<list<int>>(vecDest));
    // copy(vecSrc.begin(), vecSrc.end(), front_inserter(vecDest));
    PrintElements(vecDest);

    // 3. 类insert_iterator与函数inserter
    copy(vecSrc.begin(), vecSrc.end(),
        insert_iterator<list<int>>(vecDest, ++vecDest.begin()));
    // copy(vecSrc.begin(), vecSrc.end(), inserter(vecDest, ++vecDest.begin()));
    PrintElements(vecDest);

    return 0;
}
```
