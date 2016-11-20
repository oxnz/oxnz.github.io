---
layout: post
title: C\C++ faux pas
type: post
categories:
- C++
tags:
- c++
- faux pas
---

```cpp
class Widget {...};	// 假设Widget有默认构造函数
Widget w();		// 函数声明，而非变量定义
```

这并没有声明一个叫做 w 的Widget，它声明了一个叫作 w 的没有参数且返回Widget的函数。学会识别这个*失言 (faux pas)* 是成为C++程序员的一个真正的通过仪式。

<!--more-->

假设现有一个int的文件，想要把那些int拷贝到一个list中。这看起来是一个合理的方式:

```cpp
ifstream dataFile("ints.dat");
list<int> data(istream_iterator<int>(dataFile), istream_iterator<int>());
```

<p>这里的想法是传一对istream_iterator给list的区间构造函数，因此把int从文件拷贝到list中。</p>
<p>这段代码可以编译，但在运行时，它什么都没做。它不会从文件中读出任何数据。它甚至不会建立一个list。那是因为第二句并不声明list，而且它也不调用构造函数。它做得很奇怪。</p>
<p>我们从最基本的开始。这行声明了一个函数f带有一个double而且返回一个int：<br />
int f(double d);<br />
第二行作了同样的事情。名为d的参数左右的括号是多余的，被忽略：<br />
int f(double (d)); // 同上；d左右的括号被忽略<br />
下面这行声明了同样的函数。它只是省略了参数名：<br />
int f(double); // 同上；参数名被省略</p>
<p>再接着看。下面第一个声明了一个函数g，它带有一个参数，那个参数是指向一个没有参数、返回double的函数的指针：</p>

```cpp
int g(double (*pf)()); // g带有一个指向函数的指针作为参数
```

这是完成同一件事的另一种方式。唯一的不同是pf使用非指针语法来声明(一个在C和C++中都有效的语法):

```cpp
int g(double pf()); // 同上；pf其实是一个指针
```

照常，参数名可以省略，所以这是g的第三种声明，去掉了pf这个名字:

```cpp
int g(double ()); // 同上；参数名省略
```

注意参数名左右的括号（就像f的第二种声明中的d）和单独的括号（正如本例）之间的区别。参数名左右的括号被忽略，但单独的括号指出存在一个参数列表：它们声明了存在指向函数的指针的参数。

用这些f和g的声明做了热身，我们准备检查开头的代码:

```cpp
list<int> data(istream_iterator<int>(dataFile), istream_iterator<int>());
```

这声明了一个函数data，它的返回类型是list<int>。这个函数data带有两个参数:

* 第一个参数叫做dataFile。它的类型是istream_iterator<int>。dataFile左右的括号是多余的而且被忽略。
* 第二个参数没有名字。它的类型是指向一个没有参数而且返回istream_iterator<int>的函数的指针。

奇怪吗？但这符合C++里的一条通用规则——几乎任何东西都可能被分析成函数声明。如果用C++编程有一段时间，应该会遇到另一个这条规则的表象。有多少次会看见这个错误？

```cpp
class Widget {...}; // 假设Widget有默认构造函数<br />
Widget w();
```

这并没有声明一个叫做w的Widget，它声明了一个叫作w的没有参数且返回Widget的函数。学会识别这个失言（faux pas）是成为C++程序员的一个真正的通过仪式。

所有这些都很有趣（以它自己的扭曲方式），但它没有帮我们说出我们想要说的，警惕C++最令人恼怒的解析内容来初始化一个list<int>对象。现在我们知道了我们必须战胜的解析，那就很容易表示了。用括号包围一个实参的声明是不合法的，但用括号包围一个函数调用的观点是合法的，所以通过增加一对括号，我们强迫编译器以我们的方式看事情:

```cpp
// 注意在list构造函数的第一个实参左右的新括号
list<int> data((istream_iterator<int>(dataFile)), istream_iterator<int>());
```

这是可能的声明数据方法，给予istream_iterators的实用性和区间构造函数，值得知道它是怎样完成的。不幸的是，目前并非所有编译器都知道它。在测试的几种中，几乎一半拒绝接受数据的声明，除非它错误地接受没有附加括号形式的声明！

一个更好的解决办法是在数据声明中从时髦地使用匿名istream_iterator对象后退一步，仅仅给那些迭代器名字。以下代码到哪里都能工作:

```cpp
ifstream dataFile("ints.dat");
istream_iterator<int> dataBegin(dataFile);
istream_iterator<int> dataEnd;
list<int> data(dataBegin, dataEnd);
```

命名迭代器对象的使用和普通的STL编程风格相反，但是得判断这种方法对编译器和必须使用编译器的人都模棱两可的代码是一个值得付出的代价。

## References

* [Effective STL - 警惕c++让人懊恼的解析](http://blog.csdn.net/bichenggui/article/details/4571357)
