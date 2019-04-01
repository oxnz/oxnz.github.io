---
layout: post
title: C++ Template
type: post
categories:
- C++
tags: []
---

## Template specialization

```cpp
template<size_t n>
struct fibonacci {
	enum { value = fibonacci<n-1>::value + fibonacci<n-2>::value };
};

template<> // specialization
struct fibonacci<0> {
	enum { value = 1 };
};

template<>
struct fibonacci<1> {
	enum { value = 1 };
};

TEST(fibonacci, fibonacci) {
	EXPECT_EQ(1, fibonacci<0>::value);
	EXPECT_EQ(1, fibonacci<1>::value);
	EXPECT_EQ(2, fibonacci<2>::value);
	EXPECT_EQ(3, fibonacci<3>::value);
	EXPECT_EQ(5, fibonacci<4>::value);
}
```

```cpp
template <typename T>
struct is_pointer_type : std::false_type {};

template <typename T>
struct is_pointer_type<T*> : std::true_type {};

template <typename T>
constexpr bool is_pointer_type_v = is_pointer_type<T>::value;
```

<!--more-->

## `constexpr` function

### Recursive

```cpp
constexpr size_t fibonacci(size_t n) {
    return n < 2 ? 1 : fibonacci(n-1) + fibonacci(n-2);
}
```

### Iterative


```cpp
constexpr size_t fibonacci(size_t n) { // iterative
	if (n < 2) return 1;
	auto prev(1), curr(1);
	for (; n > 1; --n) {
		std::swap(prev, curr);
		curr += prev;
	}
	return curr;
}
```

## Templated

```cpp
template <typename T>
struct make_ptr {
	using type = T *;
};

template <typename T>
struct make_ptr<T *> {
	using type = T *;
};
```

## function

```cpp
template <typename T>
struct pointer {
    using type = T;
};

template <typename T>
auto make_ptr(pointer<T>) {
	if constexpr (std::is_pointer_v<T>) {
		return pointer<T>{};
	} else {
		return pointer<T *>{};
	}
}
```

## SFINAE

```cpp
template <bool, typename T=void>
struct enable_type_if{};

template <typename T>
struct enable_type_if<true, T> { typedef T type; };

template <bool cond, typename T>
using enable_type_if_t = typename enable_type_if<cond, T>::type;
```

## Usage

```cpp
template <typename T, std::size_t N>
std::enable_if_t<std::is_integral_v<T> and N < 128>
insertion_sort(std::array<T, N>& arr) {
	for (size_t i = 0; i < N; ++i)
		for (size_t j = i; j > 0 and arr[j] < arr[j-1]; --j)
			std::swap(arr[j], arr[j-1]);
}
```

## Variadic

A template parameter pack is a template parameter that accepts **zero or more template arguments (non-types, types, or templates)**.
A function parameter pack is a function parameter that accepts zero or more function arguments.

A template with at least one parameter pack is called a variadic template.

* [https://florianjw.de/en/variadic_templates.html](https://florianjw.de/en/variadic_templates.html)

<p>2.类模板与模板类的概念</p>

<p>（1） 什么是类模板<br />
一个类模板（也称为类属类或类生成类）允许用户为类定义一种模式，使得类中的某些数据成员、默写成员函数的参数、某些成员函数的返回值，能够取任意类型（包括系统预定义的和用户自定义的）。<br />
  如果一个类中数据成员的数据类型不能确定，或者是某个成员函数的参数或返回值的类型不能确定，就必须将此类声明为模板，它的存在不是代表一个具体的、实际的类，而是代表着一类类。<br />
（2）类模板定义<br />
定义一个类模板，一般有两方面的内容：<br />
A.首先要定义类，其格式为：</p>
<pre class="lang:c++">
template <class t>
class foo
{
   ……
}
</class></pre>
<p>foo 为类名，在类定义体中，如采用通用数据类型的成员，函数参数的前面需加上T，其中通用类型T可以作为普通成员变量的类型，还可以作为const和static成员变量以及成员函数的参数和返回类型之用。例如：</p>
<pre class="cpp">
template<class t>
class Test{
private:
    T n;
    const T i;
    static T cnt;
public:
    Test():i(0){}
    Test(T k);
    ~Test(){}
    void print();
    T operator+(T x);
};</class></pre>
<p>B. 在类定义体外定义成员函数时，若此成员函数中有模板参数存在，则除了需要和一般类的体外定义成员函数一样的定义外，还需在函数体外进行模板声明<br />
例如</p>
<pre class="lang:cpp">
template<class t>
void Test<t>::print(){
    std::cout<<"n="<<n<<std::endl;
    std::cout<<"i="<<i<<std::endl;
    std::cout<<"cnt="<<cnt<<std::endl;

}</t></class></pre>
<p>如果函数是以通用类型为返回类型，则要在函数名前的类名后缀上“<t>”。例如：</p>
<pre class="lang:cpp">
template<class t>
Test<t>::Test(T k):i(k){n=k;cnt++;}
template<class t>
T Test<t>::operator+(T x){
               return n + x;
}</t></class></t></class></pre>
<p>C. 在类定义体外初始化const成员和static成员变量的做法和普通类体外初始化const成员和static成员变量的做法基本上是一样的，唯一的区别是需再对模板进行声明，例如</p>
<pre class="lang:cpp">
template<class t>
int Test<t>::cnt=0;
template<class t>
Test<t>::Test(T k):i(k){n=k;cnt++;}
</t></class></t></class></pre>
<p>（3） 类模板的使用 类模板的使用实际上是将类模板实例化成一个具体的类，它的格式为：类名<实际的类型>。<br />
  模板类是类模板实例化后的一个产物。说个形象点的例子吧。我把类模板比作一个做饼干同的模子，而模板类就是用这个模子做出来的饼干，至于这个饼干是什么味道的就要看你自己在实例化时用的是什么材料了，你可以做巧克力饼干，也可以做豆沙饼干，这些饼干的除了材料不一样外，其他的东西都是一样的了。<br />

## 函数模板和模板函数

（1）函数模板<br />
函数模板可以用来创建一个通用的函数，以支持多种不同的形参，避免重载函数的函数体重复设计。它的最大特点是把函数使用的数据类型作为参数。<br />
函数模板的声明形式为:

```cpp
template<typename（或class) T>
<返回类型><函数名>(参数表)
{
    函数体
}
```

<p>其中，template是定义模板函数的关键字；template后面的尖括号不能省略；typename（或class)是声明数据类型参数标识符的关键字，用以说明它后面的标识符是数据类型标识符。这样，在以后定义的这个函数中，凡希望根据实参数据类型来确定数据类型的变量，都可以用数据类型参数标识符来说明，从而使这个变量可以适应不同的数据类型。例如：
<pre class="lang:cpp">
template<typename（或class) T>
T fuc(T x, T y)
{
    T x;
    //……
}</pre>
<p>函数模板只是声明了一个函数的描述即模板，不是一个可以直接执行的函数，只有根据实际情况用实参的数据类型代替类型参数标识符之后，才能产生真正的函数。<br />
（2）模板函数：<br />
 模板函数的生成就是将函数模板的类型形参实例化的过程。<br />
例如:

```cpp
double d;
int a;
func(d,a);
```

则系统将用实参d的数据类型double去代替函数模板中的T生成函数:

```cpp
double func(double x,int y) {
    double x;
    //……
}
```
