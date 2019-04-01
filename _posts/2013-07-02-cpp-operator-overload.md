---
layout: post
title: C++ operator overloading
type: post
categories:
- C++
tags:
- c++
---

<p>条款5：小心用户自定义的转换函数</p>
<p>c++允许编译器在两种数据类型之间进行隐式类型转换。(implicit conversion).首先，c++继承了c语言的类型转换的策略。</p>
<p>除了这个，c++还有两种隐式转换： 单个参数的构造函数，以及隐式的类型转换运算符。单个参数的构造函数是指只传递给它</p>
<p>一个参数就可以调用的构造函数，这种构造函数可能只定义一个参数，也可以定义多个参数，定义多个参数的时候要求第一个</p>

<!--more-->

参数后面的所有参数都有一个默认值。下面是两个例子:

```cpp
class name {
public:
Name(const string& s);
....
};

class Rational {
public:
Rational(int number = 0, int denominator);
....
};
```

隐式的类型转换符一般是这样定义的:

```cpp
class A {
    ...
operator B() {
        ...
        return B;
    }
};
```

这样就定义了A到B的转换操作符。

<p>条款6： 区分自增运算符和自减运算符的前缀和后缀形式。</p>
<p>i++和++i的区别大家都很熟悉了。我们知道c++可以重载运算符，同样的，我们也可以为类定义自增和自减运算符。为了区别前缀自增和后缀自增，c++规定后缀自增形式有一个int类型参数，这个参数相当于一个占位符，没有实际的意义。</p>
<p>例子如下：</p>

```cpp
class UPNINT{
public:
    UPNINT& operator++();         //前缀自增
    const UPNINT operator++(int); // 后缀自增
    UPNINT& operator--();         //前缀自减
    const UPNINT operator--(int); //后缀自减
    UPNINT& operator+=(const UPNINT& upi);
};</p>
```

条款7：不要重载 `&&`, `||` 和 `,`

与c一样，c++也使用了短路求值法对布尔表达式求值。这表达式一旦确定了布尔表达式为真或为假，即使还有部分表达式没有被测试，布尔表达式也停止运算。例如:

```cpp
char *p;
...
if ((p != 0) && (strlen(p) < 10))
```

这里不用担心当p为空时对它调用strlen是否会有问题。
因为如果p不等于0的测试失败。
strlen永远不会被调用。
c++ 允许对用户自定义的类型来定制 `&&` 和 `||` 运算符。
方法是通过重载 `operator&&` 函数和 `operator||` 函数。
这种重载可以是全局的也可以是针对某个类的。
然而如果你决定要采用这种方法，你必须知道它会对游戏规则带来根本性的改变。
因为你用函数调用的语义代替短路求值法。
也就是说，如果你重载了 `&&` 运算符。
下面这段代码

```cpp
if (expression1 && expression2)
    ...
```

对于编译器来说，就类似于:

```cpp
if (expression1.operator&&(expression2)) // when operator is a member function
if (expression1.operator&&(expression2)) // when operator is global function
```

这看上去没很大的不同。但是函数调用的语义和短路求值法在以下两个方面是绝对不同的。

* 首先，当函数调用时，需要对所有参数求值。所以当调用函数 `operator&&` 和 `operator||` 时，两个参数都需要计算。
换句话说，它没有采用短路求值法。
* 其次，c++ 语言规范没有定义函数参数的求值顺序，所以没有办法知道 expression1 和 expression2 哪一个先被求值。
而这与短路求值法是非常不用的。短路求值法总是以从左到右的顺序对参数进行求值。

因此，如果你重载 `&&` 和 `||`,就没有办法向程序员提供他们所期望的并且已经习惯了的行为特性。所以不要重载 `&&` 和 `||`.

同样的，逗号运算符也会有这种问题。一般情况下你需要也不会重载他们的，不是吗、？
