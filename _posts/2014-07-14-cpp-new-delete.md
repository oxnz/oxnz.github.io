---
layout: post
title: C++ memory management
type: post
categories:
- C++
tags: []
---

因为你所编写的循环语句根本不能正确运行，所以当编译成可执行代码后，也不可能正常运行。<span style="color: #ff0000;">语言规范中说通过一个基类指针来删除一个含有派生类对象的数组，结果将是不确定的。</span>这实际意味着执行这样的代码肯定不会有什么好结果。多态和指针算法不能混合在一起来用，所以数组与多态也不能用在一起。

C++中虚析构函数的作用－－这样做是为了当用一个基类的指针删除一个派生类的对象时，派生类的析构函数会被调用。

<!--more-->

```cpp
void* operator new(size_t sz) throw(bad_alloc) {
    printf("operator new: %lu bytesn", sz);
    void *m = malloc(sz);
    if (!m)
        throw bad_alloc();
    return m;
}

void* operator new[](size_t sz) throw(bad_alloc) {
    printf("operator new[]: %lu bytesn", sz);
    void *m = malloc(sz);
    if (!m)
        throw bad_alloc();
    return m;
}

void operator delete(void* m) throw() {
    puts("operator delete");
    free(m);
}

void operator delete[](void *m) throw() {
    puts("operator delete[]");
    free(m);
}
```
