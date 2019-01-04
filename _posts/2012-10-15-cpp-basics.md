---
layout: post
title: C/C++ Basics
type: post
categories:
- C++
---

## Table of Contents

* TOC
{:toc}

## 面向对象

### 面向对象的三个基本特征

1. 封装：将客观事物抽象成类，每个类对自身的数据和方法实行protection(private, protected,public)
2. 继承：广义的继承有三种实现形式：实现继承（指使用基类的属性和方法而无需额外编码的能力）、可视继承（子窗体使用父窗体的外观和实现代码）、接口继承（仅使用属性和方法，实现滞后到子类实现）。前两种（类继承）和后一种（对象组合=>接口继承以及纯虚函数）构成了功能复用的两种方式。
3. 多态：是将父对象设置成为和一个或更多的他的子对象相等的技术，赋值之后，父对象就可以根据当前赋值给它的子对象的特性以不同的方式运作。简单的说，就是一句话：允许将子类类型的指针赋值给父类类型的指针。

### 多态

多态指同一个实体同时具有多种形式。它是面向对象程序设计（OOP）的一个重要特征。
如果一个语言只支持类而不支持多态，只能说明它是基于对象的，而不是面向对象的。

C++ 中的多态性具体体现在运行和编译两个方面:

* 运行时多态是动态多态，其具体引用的对象在运行时才能确定。
* 编译时多态是静态多态，在编译时就可以确定对象使用的形式。

多态：同一操作作用于不同的对象，可以有不同的解释，产生不同的执行结果。
在运行时，可以通过指向基类的指针，来调用实现派生类中的方法。

### 多态的作用

主要是两个：

1. 隐藏实现细节，使得代码能够模块化；扩展代码模块，实现代码重用；
2. **接口重用**：为了类在继承和派生的时候，保证使用家族中任一类的实例的某一属性时的正确调用。

## 虚函数表

对 C++ 了解的人都应该知道虚函数（Virtual Function）是通过一张虚函数表（Virtual Table）来实现的。
简称为 V-Table。
在这个表中，主是要一个类的虚函数的地址表，这张表解决了继承、覆盖的问题，保证其容真实反应实际的函数。
这样，在有虚函数的类的实例中这个表被分配在了这个实例的内存中，所以，当我们用父类的指针来操作一个子类的时候，这张虚函数表就显得由为重要了，它就像一个地图一样，指明了实际所应该调用的函数。

<!--more-->

这里我们着重看一下这张虚函数表。C++ 的编译器应该是保证虚函数表的指针存在于对象实例中最前面的位置（这是为了保证取到虚函数表的有最高的性能——如果有多层继承或是多重继承的情况下）。
这意味着我们通过对象实例的地址得到这张虚函数表，然后就可以遍历其中函数指针，并调用相应的函数。

```cpp
class Test {
private:
    int value;
public:
    Test(int v) : value(v) {}
    virtual void foo() { printf("foo\n"); }
    virtual void bar() { printf("bar\n"); }
    ~Test() {}
};

typedef void (*F)(void);

void test() {
    Test t(1);
    F f = (void(*)(void))*((long*)*(long*)(&t));
    f();
    f = (void(*)(void))*((long*)*(long*)(&t)+1);
    f();
}
```

```
$./test
foo
bar
```
* 虚函数按照其声明顺序放于表中。
* 父类的虚函数在子类的虚函数前面。
* 覆盖的f()函数被放到了虚表中原来父类虚函数的位置。
* 没有被覆盖的函数依旧。

### 安全性

#### 一、通过父类型的指针访问子类自己的虚函数

我们知道，子类没有重载父类的虚函数是一件毫无意义的事情。
因为多态也是要基于函数重载的。
虽然在上面的图中我们可以看到Base1的虚表中有Derive的虚函数，但我们根本不可能使用下面的语句来调用子类的自有虚函数：

```cpp
Base1 *b1 = new Derive();
b1->f1();  //编译出错
```

任何妄图使用父类指针想调用子类中的未覆盖父类的成员函数的行为都会被编译器视为非法。
所以，这样的程序根本无法编译通过。但在运行时，我们可以通过指针的方式访问虚函数表来达到违反 C++ 语义的行为。（关于这方面的尝试，通过阅读后面附录的代码，相信你可以做到这一点）

#### 二、访问 non-public 的虚函数

另外，如果父类的虚函数是 private 或是 protected 的，但这些非 public 的虚函数同样会存在于虚函数表中，所以，我们同样可以使用访问虚函数表的方式来访问这些 non-public 的虚函数，这是很容易做到的。

如：

```cpp
class Base {
private:
    virtual void f() { cout << "Base::f" << endl; }
};

class Derive : public Base {};

typedef void(*Fun)(void);

void main() {
    Derive d;
    Fun pFun = (Fun)*((int*)*(int*)(&d)+0);
    pFun();
}
```

多态：是**对于不同对象接收相同消息时产生不同的动作**。
C++ 的多态性具体体现在运行和编译两个方面：

* 在程序运行时的多态性通过继承和虚函数来体现
* 在程序编译时多态性体现在函数和运算符的重载上

虚函数：在基类中冠以关键字 virtual 的成员函数。
它提供了一种接口界面。
允许在派生类中对基类的虚函数重新定义。

纯虚函数的作用：在基类中为其派生类保留一个函数的名字，以便派生类根据需要对它进行定义。
作为接口而存在 纯虚函数不具备函数的功能，一般不能直接被调用。

从基类继承来的纯虚函数，在派生类中仍是虚函数。
如果一个类中至少有一个纯虚函数，那么这个类被称为抽象类（**abstract class**）。

抽象类中不仅包括纯虚函数，也可包括虚函数。
抽象类必须用作派生其他类的基类，而不能用于直接创建对象实例。
但仍可使用指向抽象类的指针支持运行时多态性。

**引用是除指针外另一个可以产生多态效果的手段**。
这意味着，一个基类的引用可以指向它的派生类实例。

## 重载 (overload) 和重写 (overried，"覆盖")

* 从定义上来说
    * 重载：是指允许存在多个同名函数，而这些函数的参数表不同（或许参数个数不同，或许参数类型不同，或许两者都不同）。
    * 重写：是指子类重新定义父类虚函数的方法。
* 从实现原理上来说
    * 重载：编译器根据函数不同的参数表，对同名函数的名称做修饰，然后这些同名函数就成了不同的函数（至少对于编译器来说是这样的）。如，有两个同名函数：function func(p:integer):integer;和function func(p:string):integer;。那么编译器做过修饰后的函数名称可能是这样的：int_func、str_func。对于这两个函数的调用，在编译器间就已经确定了，是静态的。也就是说，它们的地址在编译期就绑定了（早绑定），因此，重载和多态无关！
    * 重写：和多态真正相关。当子类重新定义了父类的虚函数后，父类指针根据赋给它的不同的子类指针，动态的调用属于子类的该函数，这样的函数调用在编译期间是无法确定的（调用的子类的虚函数的地址无法给出）。因此，这样的函数地址是在运行期绑定的（晚绑定）。

## 有哪几种情况只能用intialization list 而不能用assignment?

答案：当类中含有const、reference 成员变量；基类的构造函数都需要初始化表。</p>

## C++ 不是类型安全的

两个不同类型的指针之间可以强制转换（用reinterpret cast)。C#是类型安全的。

## main 函数执行以前，还会执行什么代码？

答案：全局对象的构造函数会在main 函数之前执行

## 内存分配方式

1. 从**静态存储区域**分配。内存在程序编译的时候就已经分配好，这块内存在程序的整个运行期间都存在。例如全局变量，static 变量。
2. 在栈上创建。在执行函数时，函数内局部变量的存储单元都可以在栈上创建，函数执行结束时这些存储单元自动被释放。栈内存分配运算内置于处理器的指令集。
3. 从堆上分配，亦称动态内存分配。程序在运行的时候用 malloc 或 new 申请任意多少的内存，程序员自己负责在何时用 free 或 delete 释放内存。动态内存的生存期由程序员决定，使用非常灵活，但问题也最多。

当一个类A 中没有任何成员变量与成员函数,这时sizeof(A)的值是多少？
答案：如果不是零，请解释一下编译器为什么没有让它为零。（Autodesk）肯定不是零。举个反例，如果是零的话，声明一个class A[10]对象数组，而每一个对象占用的空间是零，这时就没办法区分A[0],A[1]…了。

## C++ 中的 4 种类型转换方式

重点是 static_cast, dynamic_cast 和 reinterpret_cast 的区别和应用。

dynamic_cast 在帮助你浏览继承层次上是有限制的。
它不能被用于缺乏虚函数的类型上，它被用于安全地沿着类的继承关系向下进行类型转换。
如你想在没有继承关系的类型中进行转换，你可能想到 static_cast。

## const vs define

const 三个作用：

* 定义常量
* 修饰函数参数
* 修饰函数返回值

被 const 修饰的东西都受到强制保护，可以预防意外的变动，能提高程序的健壮性。

### 与 define 区别

1. const 常量有数据类型，而宏常量没有数据类型。编译器可以对前者进行类型安全检查。而对后者只进行字符替换，没有类型安全检查，并且在字符替换可能会产生意料不到的错误。
2. 有些集成化的调试工具可以对 const 常量进行调试，但是不能对宏常量进行调试。

## 数组与指针

数组要么在静态存储区被创建（如全局数组），要么在栈上被创建。指针可以随时指向任意类型的内存块。

1. 修改内容上的差别

   ```cpp
   char a[] = "hello";
   a[0] = 'X';
   char *p = "world"; // 注意p 指向常量字符串
   p[0] = 'X'; // 编译器不能发现该错误，运行时错误
   ```

2. 用运算符 sizeof 可以计算出数组的容量（字节数）。
sizeof(p),p 为指针得到的是一个指针变量的字节数，而不是 p 所指的内存容量。
C++/C 语言没有办法知道指针所指的内存容量，除非在申请内存时记住它。
注意当数组作为函数的参数进行传递时，该数组自动退化为同类型的指针。

   ```cpp
   char a[] = "hello world";
   char *p = a;
   cout<< sizeof(a) << endl; // 12 字节
   cout<< sizeof(p) << endl; // 4 字节
   // 计算数组和指针的内存容量
   void Func(char a[100]) {
       cout<< sizeof(a) << endl; // 4 字节而不是100 字节
   }
   ```

## 类成员函数的重载、覆盖和隐藏

1. 成员函数被重载的特征：
    1. 相同的范围（在同一个类中）；
    2. 函数名字相同；
    3. 参数不同；
    4. virtual 关键字可有可无。
2. 覆盖是指派生类函数覆盖基类函数，特征是：
    1. 不同的范围（分别位于派生类与基类）；
    2. 函数名字相同；
    3. 参数相同；
    4. 基类函数必须有 virtual 关键字。
3. "隐藏"是指派生类的函数屏蔽了与其同名的基类函数，规则如下：
    1. 如果派生类的函数与基类的函数同名，但是参数不同。此时，不论有无 virtual 关键字，基类的函数将被隐藏（注意别与重载混淆）。
    2. 如果派生类的函数与基类的函数同名，并且参数也相同，但是基类函数没有 virtual 关键字。此时，基类的函数被隐藏（注意别与覆盖混淆）

## 宏指令

```cpp
#define min(X,Y)
    ({
        typeof(X) __x=(X), __y=(Y);
        (__x<__y)?__x:__y;
    })
```

cautious:

({})宏指令要么没有返回值，要么有返回值，而且要保证最后返回的类型具有 public 的拷贝构造函数。

下例中的 cout 具有 private 的拷贝构造函数，所以会导致编译错误：

```cpp
#define malformed_macro(param) ({cout << param << endl;})
#define normal_macro(param) do {cout << param << endl;} while (false)

int main(void) {
	normal_macro("hello");
	malformed_macro("hello");
	return 0;
}
```

```shell
$ clang++     test.cpp   -o test
Call to deleted constructor of 'std::__1::basic_ostream<char>'
      base class 'std::__1::ios_base' has private copy constructor
```

## 用变量 a 给出下面的定义

a) 一个整型数（An integer）<br />
b) 一个指向整型数的指针（A pointer to an integer）<br />
c) 一个指向指针的的指针，它指向的指针是指向一个整型数（A pointer to a pointer to an integer）<br />
d) 一个有10个整型数的数组（An array of 10 integers）<br />
e) 一个有10个指针的数组，该指针是指向一个整型数的（An array of 10 pointers to integers）<br />
f) 一个指向有10个整型数数组的指针（A pointer to an array of 10 integers）<br />
g) 一个指向函数的指针，该函数有一个整型参数并返回一个整型数（A pointer to a function that takes an integer as an argument and returns an integer）<br />
h) 一个有10个指针的数组，该指针指向一个函数，该函数有一个整型参数并返回一个整型数（ An array of ten pointers to functions that take an integer<br />
argument and return an integer ）</p>

答案是：

```cpp
a) int a; // An integer
b) int *a; // A pointer to an integer
c) int **a; // A pointer to a pointer to an integer
d) int a[10]; // An array of 10 integers
e) int *a[10]; // An array of 10 pointers to integers
f) int (*a)[10]; // A pointer to an array of 10 integers
g) int (*a)(int); // A pointer to a function a that takes an integer argument and returns an integer
h) int (*a[10])(int); // An array of 10 pointers to functions that take an integer argument and return an integer
```

## 关键字

### static

这个简单的问题很少有人能回答完全。
在 C 语言中，关键字 static 有三个明显的作用：

1. 在函数体，一个被声明为静态的变量在这一函数被调用过程中维持其值不变。
2. 在模块内（但在函数体外），一个被声明为静态的变量可以被模块内所用函数访问，但不能被模块外其它函数访问。
它是一个本地的全局变量。
3. 在模块内，一个被声明为静态的函数只可被这一模块内的其它函数调用。那就是，这个函数被限制在声明它的模块的本地范围内使用。

大多数应试者能正确回答第一部分，一部分能正确回答第二部分，同是很少的人能懂得第三部分。
这是一个应试者的严重的缺点，因为他显然不懂得本地化数据和代码范围的好处和重要性。

### const

const 意味着"只读"
尽管这个答案不是完全的答案，但我接受它作为一个正确的答案。（如果你想知道更详细的答案，仔细读一下 Saks 的文章吧。）
如果应试者能正确回答这个问题，我将问他一个附加的问题：下面的声明都是什么意思？

```cpp
const int a;
int const a;
const int *a;
int * const a;
int const * a const;
```

前两个的作用是一样，a 是一个常整型数。第三个意味着 a 是一个指向常整型数的指针（也就是，整型数是不可修改的，但指针可以）。
第四个意思 a 是一个指向整型数的常指针（也就是说，指针指向的整型数是可以修改的，但指针是不可修改的）。
最后一个意味着 a 是一个指向常整型数的常指针（也就是说，指针指向的整型数是不可修改的，同时指针也是不可修改的）。

如果应试者能正确回答这些问题，那么他就给我留下了一个好印象。

顺带提一句，也许你可能会问，即使不用关键字 const，也还是能很容易写出功能正确的程序，那么我为什么还要如此看重关键字 const 呢？我也如下的几下理由：

1. 关键字 const 的作用是为给读你代码的人传达非常有用的信息，实际上，声明一个参数为常量是为了告诉了用户这个参数的应用目的。
如果你曾花很多时间清理其它人留下的垃圾，你就会很快学会感谢这点多余的信息。（当然，懂得用 const 的程序员很少会留下的垃圾让别人来清理的。）
2. 通过给优化器一些附加的信息，使用关键字 const 也许能产生更紧凑的代码。
3. 合理地使用关键字 const 可以使编译器很自然地保护那些不希望被改变的参数，防止其被无意的代码修改。简而言之，这样可以减少 bug 的出现。

### volatile

The volatile keyword informs the compiler that a variable may change without the compiler knowing it. Variables that are declared as volatile will not be cached by the compiler, and will thus always be read from memory.

The mutable keyword can be used for class member variables. Mutable variables are allowed to change from within const member functions of the class.

一个定义为 volatile 的变量是说这变量可能会被意想不到地改变，这样，编译器就不会去假设这个变量的值了。
精确地说就是，优化器在用到这个变量时必须每次都小心地重新读取这个变量的值，而不是使用保存在寄存器里的备份。
下面是 volatile 变量的几个例子：

1. 并行设备的硬件寄存器（如：状态寄存器）
2. 一个中断服务子程序中会访问到的非自动变量(Non-automatic variables)
3. 多线程应用中被几个任务共享的变量

回答不出这个问题的人是不会被雇佣的。
我认为这是区分 C 程序员和嵌入式系统程序员的最基本的问题。
嵌入式系统程序员经常同硬件、中断、RTOS 等等打交道，所用这些都要求 volatile 变量。
不懂得 volatile 内容将会带来灾难。

假设被面试者正确地回答了这是问题（嗯，怀疑这否会是这样），我将稍微深究一下，看一下这家伙是不是直正懂得 volatile 完全的重要性。

1. 一个参数既可以是 const 还可以是 volatile 吗？解释为什么。
2. 一个指针可以是 volatile 吗？解释为什么。
3. 下面的函数有什么错误：

```cpp
int square(volatile int *ptr) {
    return *ptr * *ptr;
}
```

下面是答案：

1. 是的。一个例子是只读的状态寄存器。它是 volatile 因为它可能被意想不到地改变。它是 const 因为程序不应该试图去修改它。
2. 是的。尽管这并不很常见。一个例子是当一个中服务子程序修该一个指向一个 buffer 的指针时。
3. 这段代码的有个恶作剧。这段代码的目的是用来返指针 `*ptr` 指向值的平方，但是，由于 `*ptr` 指向一个 volatile 型参数，编译器将产生类似下面的代码：

```cpp
int square(volatile int *ptr) {
    int a,b;
    a = *ptr;
    b = *ptr;
    return a * b;
}
```

由于 `*ptr` 的值可能被意想不到地该变，因此 a 和 b 可能是不同的。
结果，这段代码可能返不是你所期望的平方值！正确的代码如下：

```cpp
long square(volatile int *ptr) {
    int a;
    a = *ptr;
    return a * a;
}
```

### sizeof

sizeof不被编译，如int a = 8; sizeof(a = 6)   输出是4，但是a=8

空类所占空间为1， 单一继承的空类空间也为1，多重继承的空类空间为1，虚继承涉及虚指针，大小为4.

空类没有数据成员，只有方法，占空间为1；

但是一旦有虚拟方法，就占4，因为有虚指针。

## 进程和线程的区别

什么是进程（Process）：普通的解释就是，进程是程序的一次执行，而什么是线程（Thread），线程可以理解为进程中的执行的一段程序片段。在一个多任务环境中下面的概念可以帮助我们理解两者间的差别：

进程间是独立的，这表现在内存空间，上下文环境；
线程运行在进程空间内。
一般来讲（不使用特殊技术）进程是无法突破进程边界存取其他进程内的存储空间；
而线程由于处于进程空间内，所以同一进程所产生的线程共享同一内存空间。
同一进程中的两段代码不能够同时执行，除非引入线程。线程是属于进程的，当进程退出时该进程所产生的线程都会被强制退出并清除。
线程占用的资源要少于进程所占用的资源。
进程和线程都可以有优先级。
在线程系统中进程也是一个线程。
可以将进程理解为一个程序的第一个线程。

线程是指进程内的一个执行单元,也是进程内的可调度实体.与进程的区别:

* 地址空间:进程内的一个执行单元;进程至少有一个线程;它们共享进程的地址空间;而进程有自己独立的地址空间;
* 进程是资源分配和拥有的单位,同一个进程内的线程共享进程的资源
* 线程是处理器调度的基本单位,但进程不是.
* 二者均可并发执行.

## C++ 中的 class 和 struct 的区别

从语法上，在 C++ 中（只讨论 C++ 中）, class 和 struct 做类型定义时只有两点区别：

* 默认继承权限。如果不明确指定，来自 class 的继承按照 private 继承处理，来自 struct 的继承按照 public 继承处理；
* 成员的默认访问权限。class 的成员默认是 private 权限，struct 默认是 public 权限。

除了这两点，class 和 struct 基本就是一个东西。语法上没有任何其它区别。

### 关于使用大括号初始化

* class 和 struct 如果定义了构造函数的话，都不能用大括号进行初始化
* 如果没有定义构造函数，struct 可以用大括号初始化。
* 如果没有定义构造函数，且所有成员变量全是 public 的话，可以用大括号初始化。

### 关于默认访问权限

class 中默认的成员访问权限是 private 的，而 struct 中则是 public 的。

### 关于继承方式

* class 继承默认是 private 继承，而 struct 继承默认是 public 继承。
* class 中有个默认的 this 指针，struct 没有

## 成员函数被重载的特征

* 相同的范围（在同一个类中）；
* 函数名字相同；
* 参数不同；
* virtual关键字可有可无。
* 成员函数中 有无const (函数后面) 也可判断是否重载

## C++ 中为什么用模板类

* 可用来创建动态增长和减小的数据结构
* 它是类型无关的，因此具有很高的可复用性。
* 它在编译时而不是运行时检查数据类型，保证了类型安全
* 它是平台无关的，可移植性
* 可用于基本数据类型

重载函数则在编译时表现出多态性,而虚函数在运行时表现出多态功能，这是C++的精髓；

http://blog.csdn.net/chenhu_doc/article/details/856468

## 解释下列输出结果

```cpp
char str1[] = "abc";
char str2[] = "abc";
const char str3[] = "abc";
const char str4[] = "abc";
const char *str5 = "abc";
const char *str6 = "abc";
char *str7 = "abc";
char *str8 = "abc";
cout << ( str1 == str2 ) << endl;
cout << ( str3 == str4 ) << endl;
cout << ( str5 == str6 ) << endl;
cout << ( str7 == str8 ) << endl;
// 结果是：0 0 1 1
```

解答：str1,str2,str3,str4是数组变量，它们有各自的内存空间；
而str5,str6,str7,str8是指针，它们指向相同的常量区域。

注意:数组名作为函数参数时,退化为指针.
数组名作为sizeof()参数时,数组名不退化,因为sizeof不是函数.

## 指出下面代码的输出，并解释为什么。

(不错,对地址掌握的深入挖潜)

```cpp
main() {
    int a[5]={1,2,3,4,5};
    int *ptr=(int *)(&a+1);
    printf("%d,%d",*(a+1),*(ptr-1));
}
// 输出：2,5
```

*(a+1）就是a[1]，*(ptr-1)就是a[4],执行结果是2，5

&a+1不是首地址+1，系统会认为加一个a数组的偏移，是偏移了一个数组的大小（本例是5个int）<br />
int *ptr=(int *)(&a+1);<br />
则ptr实际是&(a[5]),也就是a+5<br />
原因如下：<br />
&a是数组指针，其类型为 int (*)[5];<br />
而指针加1要根据指针类型加上一定的值，<br />
不同类型的指针+1之后增加的大小不同<br />
a是长度为5的int数组指针，所以要加 5*sizeof(int)<br />
所以ptr实际是a[5]<br />
但是prt与(&a+1)类型是不一样的(这点很重要)<br />
所以prt-1只会减去sizeof(int*)<br />
a,&a的地址是一样的，但意思不一样，a是数组首地址，也就是a[0]的地址，&a是对象（数组）首地址，a+1是数组下一元素的地址，即a[1],&a+1是下一个对象的地址，即a[5].</p>

## C 指针

```c
int *p[n];  // 指针数组，每个元素均为指向整型数据的指针。
int (*p)[n];// p为指向一维数组的指针，这个一维数组有n个整型数据。
int *p();   // 函数带回指针，指针指向返回的值。
int (*p)(); // p 为指向函数的指针。
```

## bit manipulation

```cpp
struct bit {
	int a:3;
	int b:2;
	int c:3;
};

int test() {
	bit b;
	char *c = (char *)&b;
	*c = 0x9A;
	printf("%d %d %dn", b.a, b.b, b.c);
	return 0;
}
#-->compile and run
% ./test
2 -1 -4
```

```cpp
struct s1 {
    int i: 8;
    int j: 4;
    int a: 3;
    double b;
};

struct s2 {
    int i: 8;
    int j: 4;
    double b;
    int a:3;
};

printf("sizeof(s1)= %dn", sizeof(s1));
printf("sizeof(s2)= %dn", sizeof(s2));
// result: 16, 24
// 第一个struct s1 {
    int i: 8;
    int j: 4;
    int a: 3;
    double b;
};
```

<p>理论上是这样的，首先是i在相对0的位置，占8位一个字节，然后，j就在相对一个字节的位置，由于一个位置的字节数是4位的倍数，因此不用对齐，就放在那里了，然后是a，要在3位的倍数关系的位置上，因此要移一位，在15位的位置上放下，目前总共是18位，折算过来是2字节2位的样子，由于double是8字节的，因此要在相对0要是8个字节的位置上放下，因此从18位开始到8个字节之间的位置被忽略，直接放在8字节的位置了，因此，总共是16字节。<br />
第二个最后会对照是不是结构体内最大数据的倍数，不是的话，会补成是最大数据的倍数</p>

## 字符串面试题

http://blog.csdn.net/hkh5730/article/details/14674183</p>

### 反转句子

```cpp
void reverse_sentence(char str[]) {
    char *p1 = str;
    char *p2 = str;
    char *p3;
    char *p4 = str;
    while (*++p4)
        ;
    --p4;
    p3 = p4;
    while (p1 &lt; p4) {
        p2 = p1;
        while (*++p2 &amp;&amp; *p2 != '_')
            ;
        --p2;
        p3 = p2 + 2;
        while (p1 &lt; p2) {
            char c = *p1;
            *p1++ = *p2;
            *p2-- = c;
        }
        p1 = p3;
    }
    p1 = str;
    while (p1 &lt; p4) {
        char c = *p1;
        *p1++ = *p4;
        *p4-- = c;
    }
}
char str[] = "wu_han_da_xue";
reverse_sentence(str);
printf("str = [%s]n", str);

$./test
str = [xue_da_han_wu]
```

```c
void i2a(const int i, char *a) {
    int ii = i &lt; 0 ? -i : i;
    char *p = a;
    while (ii > 0) {
        *p++ = ii % 10 + '0';
        ii /= 10;
    }
    if (i < 0) {
        ii = -i;
        *p++ = '-';
    }
    *p = '';
    --p;
    while (a < p) {
        char c = *p;
        *p-- = *a;
        *a++ = c;
    }
}

int a2i(const char *a) {
    int i(0);
    int flag(1);
    if (*a == '-') {
        ++a;
        flag = -1;
    }
    while (*a) {
        i = i*10 + *a-'0';
        ++a;
    }
    return i*flag;
}
```

## 树

### 根据前序和中序写出后序

前序：1 2 4 7 3 5 8 9 6 中序：4 7 2 1 8 5 9 3 6 求出后序：7 4 2 8 9 5 6 3 1</p>

```c
int a[] = {1, 2, 4, 7, 3, 5, 8, 9, 6};
int b[] = {4, 7, 2, 1, 8, 5, 9, 3, 6};

void loop(int ai, int bi, int l) {
    int r = a[ai++];
    if (l == 1) {
        printf("%d ", r);
        return;
    } else if (l == 0)
        return;
    int i, l1, l2;
    for (i = bi; i < bi + l; ++i)
        if (r == b[i])
            break;
    l1 = i-bi;
    l2 = l - l1 - 1;
    loop(ai, bi, l1);
    loop(ai+l1, bi+l1+1, l2);
    printf("%d ", r);
}
loop(0, 0, sizeof(a)/sizeof(a[0]);
```

## initialization

<p>常量必须在构造函数的初始化列表里面初始化，</p>
<p>http://www.igigo.net/</p>

## References

* http://www.msra.cn/Articles/ArticleItem.aspx?Guid=8ae08db5-e059-44bf-9181-83d40a67dadb<br />
* http://blog.sina.com.cn/s/blog_4caedc7a010094at.html
* http://msbop.openjudge.cn/bop2013/
http://zhedahht.blog.163.com/blog/static/2541117420072114478828/</p>
* C++ singleton: http://patmusing.blog.163.com/blog/static/135834960201002322226231/?fromdm&fr
* http://zhedahht.blog.163.com/blog/static/2541117420105146828433/
* http://zhangzhibiao02005.blog.163.com/blog/static/37367820201181134256898/
* 换类成员方法指针到普通函数指针
* http://www.cnblogs.com/xianyunhe/archive/2011/11/26/2264709.html
* http://zhangzhibiao02005.blog.163.com/blog/static/373678202011612104210592/
* http://zhangzhibiao02005.blog.163.com/blog/static/3736782020101010104317578/
* http://zhangzhibiao02005.blog.163.com/blog/static/373678202009326039191/
* http://en.wikipedia.org/wiki/Resource_Acquisition_Is_Initialization
* http://qt-project.org/wiki/API-Design-Principles
* http://www.opensource.apple.com/source/Libc/Libc-997.1.1/string/FreeBSD/strlen.c
