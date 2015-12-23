---
layout: post
title: Effective C++
date: 2014-05-02 22:11:42.000000000 +08:00
type: post
published: true
status: publish
categories:
- C++
- dev
tags:
- Effective C++
meta:
  _edit_last: '1'
  _wp_old_slug: effective-c
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---
<h2>介绍</h2>
<p>从网络上整理的Effective C++ 读书笔记，鉴于其中有些部分内容太老，因为参考1的文章成语2006年，而最近有新出 C++11，其中有些内容需要更新，以反映语言的新变化。另外其中有些内容基于我自己的理解做了适当的更改，包括但不限于删除，添加和修改。</p>
<ol>
<li>介绍</li>
<li>改变旧有的C习惯：(shifting from C to C++)</li>
<li>内存管理：(memory management)</li>
<li>构造函数，析构函数和Assignment运算符：(Constructors, Destructors, and Assignment Operators)</li>
<li>类与函数的设计和声明：(Classes and Funcations: Design and Declaration)</li>
<li>类与函数实现：(Classes and Functions: Implementation)</li>
<li>继承关系和面向对象设计(Inheritance and object-Oriented Design)</li>
<li>杂项讨论：(Miscellany)</li>
<li>参考</li>
</ol>
<p><!--more--></p>
<h2>改变旧有的C习惯：(shifting from C to C++)</h2>
<div class="panel panel-primary">
<div class="panel-heading">1. 尽量以const和inline取代#define(prefer const and inline to define)</div>
<div class="panel-body">宏虽然有很多问题，但还是有优点的：<br />
使用灵活，可以随时改变定义：</p>
<pre class="lang:default decode:true">#define eval(a, b) ((a) + (b))
    cout &lt;&lt; eval(3, 2) &lt;&lt; endl;
#undef eval
#define eval(a, b) ((a) - (b))
    cout &lt;&lt; eval(3, 2) &lt;&lt; endl;</pre>
<p>还可以使用 define 与 undef 来更细粒度的制定宏的存在区间。</p>
<p>宏不能访问对象的私有成员<br />
宏的定义很容易产生二意性</p>
<p>内联函数和宏的区别在于，宏是由预处理器对宏进行替代，而内联函数是通过编译器控制来实现的。而且内联函数是真正的函数，只是在需要用到的时候，内联函数像宏一样的展开，所以取消了函数的参数压栈，减少了调用的开销。你可以象调用函数一样来调用内联函数，而不必担心会产生于处理宏的一些问题。</p>
<p>我们可以用Inline来定义内联函数，不过，任何在类的说明部分定义的函数都会被自动的认为是内联函数。内联函数必须是和函数体申明在一起，才有效。当然，内联函数也有一定的局限性。就是函数中的执行代码不能太多了，如果，内联函数的函数体过大，一般的编译器会放弃内联方式，而采用普通的方式调用函数。这样，内联函数就和普通函数执行效率一样了。</p>
</div>
</div>
<h3>2. 尽量以取代(prefer iostream to stdio.h)</h3>
<div class="panel panel-primary">
<div class="panel-heading">3. 尽量以new和delete取代malloc和free(prefer new and delete to malloc and free)</div>
<div class="panel-body">
<pre class="lang:default decode:true">string* stringArray1 = static_cast&lt;string*&gt;(malloc(10*sizeof(string)));
string* stringArray2 = new string[10];</pre>
<p>stringArray1 points to enough memory for 10 string objects,but no objects have been constructed in that memory,and you have no way to initialize the objects in the array;<br />
stringArray2 points to an array of fully constructed string objects,each of whick can safely be used in any operation taking a string;</p>
<pre class="lang:default decode:true">free(stringArray1);
delete [] stringArray2;</pre>
<p>the call to free will release the memory pointed to by stringArray1,but no destructor will be called on the strong objects in that memory,if the string objects themselves allocated memory,as string objects are wont to all the memory they allocated will be lost<br />
delete is called on stringArray2,a destructor is called for each object in array before any memory is released.<br />
Mixing new and delete with malloc and free is usually a bad idea;<br />
new 相当于下面的调用：</p>
<pre class="lang:default decode:true">A* pa = (A*)malloc(sizeof(A)); // alloc memory
pa-&gt;A::A(3); // call the constructor
return pa;   // return pointer</pre>
<p>虽然从效果上看，这三句话也得到了一个有效的指向堆上的A对象的指针pa，但区别在于，<span style="color: #ff0000;">当malloc失败时，它不会调用分配内存失败处理程序new_handler，而使用new的话会的。</span></p>
</div>
</div>
<div class="panel panel-primary">
<div class="panel-heading">4. 尽量使用C++风格的注释(prefer C++ style commnents)</div>
<div class="panel-body">c++的单行注释<code>"//"</code>主要是为了解决传统c中<code>"/*"</code>和<code>"*/"</code>错误匹配的问题。</div>
</div>
<h2>内存管理：(memory management)</h2>
<h3>5. 使用相同形式的new和delete(Use the same form in corresponding uses of new and delete)</h3>
<div class="panel panel-primary">
<div class="panel-heading">6. 记得在destructor中以delete对付pointer member(Use delete on pointer member in destructors)</div>
<div class="panel-body">
<blockquote>
<p style="text-align: right;">引用自 <a style="color: #19599b;" href="http://blog.chinaunix.net/uid-20405949-id-1686333.html">Gama的Effective C++ 学习笔记 -- E06</a><span style="color: #565656;"> </span></p>
<p>在为一个class添加point member的时候，要配合做三件事情：</p>
<ol>
<li>在class的constructor中initializate该指针，或者将该指针初始化为0（成为null指针）</li>
<li>在其他memeber function中使用该指针；或者，在assignment运算符中将原有内容删除，并重新分配一块内存（参考E17）。</li>
<li>在destructor中delete这个指针。</li>
</ol>
<p>delete一个null指针是安全的，因为什么都没有做。所以如果能在constructor,assignment,以及其他的member function中，都保证使用的point member要么是指向有效内存，要么是null，那么，你就可以在destructor中放心的delete该pointer member，而不需要在以是否对该指针使用过new。</p>
<p>不需要delete一个没有被new初始化过的指针，而且也不要delete一个传递而来的指针（除非smart pointer objects，参M28），也就是说，在destructor中只需要delete那些使用new的指针成员。</p></blockquote>
</div>
</div>
<p>7. 对内存不足的状况预做准备(Be prepared for out-of-memory conditions)</p>
<p>8. 撰写operator new和operator delete是应遵循公约(Adhere to convention when writing operator new and delete)</p>
<p>9. 避免遮掩了new的正规形式(Avoid hiding the new)</p>
<p>10. 如果写了一个operator new对应的也要写一个operator delete(Write operator delete if you write operator new)</p>
<p>构造函数，析构函数和Assignment运算符：(Constructors, Destructors, and Assignment Operators)</p>
<p>11. 如果class内动态配置有内存，请为此class声明一个copy constructor和一个assignment运算符(Declare a copy constructor and an assignment operator for class with dynamically allocated memory)</p>
<div class="well">如果你的class拥有指针member，你有两个选择：实现 copy和assignment constructor；或者将copy和assignment constructor声明为private/delete(C++11 specific)。</div>
<h3>12. 在constructor中尽量以initialization动作取代assignment动作(Prefer initialization to assignment in constructors)</h3>
<div class="well">
<p>o. Why prefer member initialization list?</p>
<ul>
<li>*. const members以及reference members只能通过member initialization list来初始化，而不能够使用assignment。</li>
<li>*. better performance。member initialization list可以获得更好的性能，通过这种方式初始化只有一次函数调用，而constructor assignment要有两次函数调用。比如对于string name这个成员，使用member ininitialization list只是执行一次string的copy constructor；而使用constructor assignment要分别执行：一次string的默认构造函数，和一次string的operator=函数（对于内建类型，两种方法效率一样，都只 有一次付值）。</li>
<li>*. member initialization list可以简化类的维护工作。详见M32。</li>
</ul>
</div>
<p>13. initialization list中的members初始化次序应该和其在class内的声明次序相同(List members in an initialization list in the order in which they are declared)</p>
<div class="well">
<ul>
<li>o. class members以他们在class内的声明次序进行初始化，于在member initialization list中出现的次序无关。</li>
<li>o. static data member只需要初始化一次。参考E47</li>
<li>o. base class data member在derived class data member之前初始化，故应该在initialization list的开始先初始化base class中的data members。</li>
<li>o. 结论：在初始化对象时：
<ul>
<li>*. member initialization list中应该以class内data member的声明次序来初始化；</li>
<li>*. static data members不要在initialization list或者constructor中初始化；</li>
<li>*. base class的成员要先于derived class成员，在initialization list中初始化。</li>
</ul>
</li>
</ul>
</div>
<p>14. 总是让base class拥有virtual destructors(Make sure base class have virtual destructors)<br />
15. 令operator=传回“*this的reference”(Have operator= return a reference to *this)<br />
assignment运算符总是必须传回一个reference，并且指向其左侧参数，也就是*this；如果不这么做，就会妨碍assignment串联，或者妨碍隐式类型转换。<br />
16. 在operator=中为所有的data members设定（赋值）内容(Assign to all data members in operator=)</p>
<ul>
<li>如果你打算为你的类构造自己的operator=（关于何时需要构建自己的operator=，参考E11），那么你就需要为class中每一个data member都在operator=中进行赋值。</li>
<li>在继承机制引入的时候，需要多加一个考量：derived class的operator=也有义务处理其base class members的assignment动作。这是你应该做的就是：在derived class的operator=函数内，显式的调用base class的constructor或者其他public的用于初始化其成员的方法，对base class的data member进行付值。</li>
<li>实现derived class的copy constructor会遇到和前面实现derived class的operator=类似的问题：当derived object以copy方式被构造出来时，并没有连带copy属于base class的成分，base class的成分是由其default constructor完成的。为了避免这个问题，derived class的copy constructor必须确保调用base class的copy constructor而不是default constructora。</li>
</ul>
<p>17. 在operator=中检查是否“自己赋值给自己”(Check for assignment to self in operator=)</p>
<p>aliasing问题不只出现在operator=函数内，只要出现reference和pointer，任何代表兼容类型的对象名称，都可能实际上指向 同一个对象。</p>
<h2>类与函数的设计和声明：(Classes and Funcations: Design and Declaration)</h2>
<p>18. 努力让接口完满且最小化(Strive for class interfaces that are complete and minimal)</p>
<ul>
<li>o. client interface: 一个开放给class的用户并为他们所使用的接口。一般而言，接口中只有函数，如果其中也有数据，会导致很多问题。见E20。</li>
<li>o. 设计类的接口的一个准则是：完满且最小化，complete and minimal。完满是指，让class的用户可以通过接口完成任何合理的工作；最小化是指，尽量使接口函数最少，不至于有两个函数功能重叠。</li>
<li>o. friend函数虽然不属于class member functions，但是也应该纳入接口完满性和最小化的考虑。参考E19。</li>
</ul>
<p>19. 区分member functions，non-member functions和friend functions(Differentiate among member of functions, non-member functions, and friend functions)</p>
<ul>
<li>*. virtual function必须是class member。</li>
<li>*. 不要让operator&gt;&gt;和operator&lt;&lt;成为member。如果operator&lt;&lt;还需要访问class的private/protected成员，那么最多也就是让它成为friend。</li>
<li>*. 只有non-member function才能在其left hand side参数身上实施隐式类型转换。因此如果需要在左参身上实施隐式类型转换，就要将函数声明为non-member functions。进一步，如果该function还要访问类中的非公有成员，就要在类中声明该 函数为friend。</li>
<li>*. 除了上面提到operator&lt;&lt;，operator&gt;&gt;，左参隐式转换等问题，如果一个function与一个类在意义上相关，就应该把这个函数声明为这个类的member function。</li>
</ul>
<p>20. 避免将data members放在公开接口中(Avoid data members in the public interface)</p>
<div class="panel panel-primary">
<div class="panel-heading">21. 尽可能使用const(Use const whenever possible)</div>
<div class="panel-body">
<p>const修饰它右边最近的代码。对于指针，你可以通过const指定指针本身为const，或者指针所指的内容为const，或者两者都是：</p>
<pre class="lang:default decode:true">char* p             = "hello";//non-const pointer, non-const data
const char* p       = "hello";//non-const pointer, const data
char* const p       = "hello";//const pointer, non-const data
const char* const p = "hello";//const pointer, const data</pre>
<ul>
<li>可以这样看：以星号为界线，如果const出现在*的左边，那么const就使指针所指内容为常量；如果const出现在*的右边，那么const就使指 针本身为常量。两边都出现，两者皆为常量。</li>
<li>也可以这样看：const修饰它右边最近的代码。例如"char* const p"，这里const修饰p，就是说指针本身为常量；又如"const char* p"，这里const修饰char*（主要是修饰*，说明修饰的指针的内容），就是说指针所指内容为常量。</li>
</ul>
<p>const可以放在类型名称之前，或者类型之后，两者都是合法的，要适应这两种写法：</p>
<pre class="lang:default decode:true">void f1(const String* p);
void f2(String const *p);</pre>
<p>const最具威力的用途还是在函数的声明上：<br />
*. const可以修饰函数的返回值；-- const char&amp; func()；<br />
*. const可以修饰函数的参数；-- char func(const char*);<br />
*. const可以修饰member function整个函数。-- void func() const;<br />
下面将分别就这三个方面分别分析。</p>
<ul>
<li>当const用于修饰一个函数的返回值，就说明了函数要传回一个常量值，这个返回值是不容许修改的。这样做的结果可以降低client的错误，又不至于放 弃安全性或者效率，关于这一点，见E29。</li>
<li>将const应用于函数参数身上，其行为与local const objects一样，没有什么特别之处，就是表明这个参数在函数体中是不可以被修改的。</li>
<li>const用于member function。const member function的目的是指明了该成员函数可以由const对象调用。<br />
可以通过const实现函数重载。比如：</li>
</ul>
<pre class="lang:default decode:true">struct NZString { // another string impl
    ...
    char&amp; operator[](int idx) {
        return str[idx];
    }
    const char&amp; operator[](int idx) const {
        return str[idx];
    }
    ...
};</pre>
<p>还要注意一点，任何函数的返回值如果是内建类型，那么其传回值是不容许被修改的。如果上面的non-const <code>operator[]</code>的返回值设定为<code>char</code>而不是<code>char&amp;</code>，那么任何试图付值的动作都是非法的。如：<br />
<code>str[0] = 'x'; //非法操作。</code><br />
这就引出一条规律，如果返回值是基本类型，那么对返回值的const修饰也就不那么必要了。</p>
</div>
</div>
<div class="panel panel-primary">
<div class="panel-heading">22. 尽量使用pass-by-reference（传址）(Prefer pass-by-reference to pass-by-value)</div>
<div class="panel-body">C++把pass-by-value作为缺省行为，这是为了沿袭C的传统。函数参数都是以实参的副本（就是以传入参数为本，调用copy constructor返回的结果为函数的参数）作为初值，而调用端所获得的也是函数返回值的一个副本（就是以返回值为本，调用copy-constructor返回一个临时对象，）。<br />
prefer pass-by-ref的原因之一：为了效率。</p>
<pre class="lang:default decode:true">class Natural {
public:
    Natural(unsigned long v) : val(v) { cout &lt;&lt; "construct" &lt;&lt; endl; }
    Natural(const Natural&amp; rhs) {
        val = rhs.val;
        cout &lt;&lt; "copy constructor : val = " &lt;&lt; val &lt;&lt; endl;
    }
    Natural&amp; operator=(const Natural&amp; rhs) {
        val = rhs.val;
        cout &lt;&lt; "assignment constructor : val = " &lt;&lt; val &lt;&lt; endl;
        return *this;
    }
    void inc(void) { val &gt; 100 ? val : ++val; }
    ~Natural() { cout &lt;&lt; "destructor" &lt;&lt; endl; val = 0; }
private:
    unsigned long val;
};

Natural inc1(Natural n) {
    n.inc();
    return n;
}

Natural&amp; inc2(Natural&amp; n) {
    n.inc();
    return n;
}

int main(int , char **) {
    Natural n1(0);
    cout &lt;&lt; "inc1-----&gt;" &lt;&lt; endl;
    Natural n2 = inc1(n1);
    cout &lt;&lt; "inc2-----&gt;" &lt;&lt; endl;
    Natural&amp; n3 = inc2(n2);
    cout &lt;&lt; "&lt;---------" &lt;&lt; endl;
    return 0;
}
// 输出：
% ./test
construct
inc1-----&gt;
copy constructor : val = 0
copy constructor : val = 1
destructor
inc2-----&gt;
&lt;---------
destructor
destructor</pre>
<p>prefer pass-by-ref的原因之二：避免slicing。<br />
pass-by-reference的问题:</p>
<ol>
<li>aliasing问题，参考E17。</li>
<li>有些情况下，当你必须返回object时，不要尝试传回reference，参考E23</li>
<li>pass-by-ref底层是指针来完成的，所以pass-by-ref通常意味着在传递指针。对于小对象，那么pass-by-value可能比 pass-by-reference更有效率。一般对于内建类型，int,char,double等，用pass-by-value更合理，而对于各种用 户自定义类型，class,struct等，如果pass-by-ref可行（E23展示给你一些不能的情况），应尽量采用。</li>
</ol>
</div>
</div>
<p>23. 当你必须传回object时，不要尝试传回reference(Don't try to return a reference when you must return an object)<br />
考虑的重点是对象的生命scope,有可能会造成返回一 个指向并不存在的对象的引用，因为这个想要返回的对象只在被调用函数的内部scope内可见，出了scope，这个对象早就被销毁了。</p>
<div class="panel panel-primary">
<div class="panel-body">24. 在函数重载和参数缺省化之间，谨慎抉择(Choose carefully between function overloading and parameter defaulting)</div>
<div class="panel-body">
<ol>
<li>function overloading和parameter defaulting之间引起的混淆，是因为他们都允许以不同的形式调用同一个函数名称。</li>
<li>判断使用哪一种方式：
<pre class="lang:default decode:true ">             是否有适当的默认值
               |        |
               |yes     |no
               |        |---&gt;function overloading
            算法个数
            |     |
            |one  |more than one
            |     |
            |     |---&gt;function overloading
            |
            |---&gt;parameter defaulting</pre>
</li>
<li>一个常用的重载策略：使用重载函数，让它们调用共同的后端函数完成工作，从而避免在重载函数中包含重复的代码。例如 c++11 中的委托构造函数(Delegating constructors):<br />
在一个构造函数中调用另外一个构造函数，这就是委托的意味，不同的构造函数自己负责处理自己的不同情况，把最基本的构造工作委托给某个基础构造函数完成，实现分工协作。</li>
<li>有几点要注意：
<ol>
<li>default constructor可以无中生有的构造出一个对象来；<br />
copy constructor可以以已有对象为本构造出另一个对象来</li>
<li>default constructor和copy constructor是重载的关系。</li>
<li>让重载函数调用共同的后端函数完成工作，可以避免在重载函数中包含重复的代码，这是一个常见的策略。</li>
<li>只要是符合构造函数的声明形式，对象就会被构造，即便这样的对象没有什么意义。</li>
</ol>
</li>
</ol>
</div>
</div>
<p>25. 避免对指针型别和数值型别进行重载(Avoid overloading on a pointer and a numerical type)</p>
<div class="panel panel-primary">
<div class="panel-heading">26. 防卫潜伏的（模棱两可）状态(Guard against potential ambiguity)</div>
<div class="panel-body">
<p>对编译器来说，如果提供了两个方法都能完成同一件事情，编译器会拒绝在这两个方法中选择一个：</p>
<pre class="lang:default decode:true">class B;
class A {
    public:
        A(const B&amp;); // construct B from A
};

class B {
    operator A() const; // transform B to A
};

void f(const A&amp;) {}
B b;
f(b); // ambiguity</pre>
<p>编译器输出：</p>
<pre class="lang:default decode:true">test.cpp:36:4: error: reference initialization of type 'const A &amp;' with
      initializer of type 'B' is ambiguous
        f(b);
          ^
test.cpp:25:3: note: candidate constructor
                A(const B&amp;);
                ^
test.cpp:29:2: note: candidate function
        operator A() const;
        ^
test.cpp:32:16: note: passing argument to parameter here
void f(const A&amp;) {}
               ^
1 error generated.</pre>
<p>编译器看到f函数，它知道要获得一个A类型的参数，当传入一个B对象的时候，它发现有两个方法都能够完成从一个B对象到一个A对象的变化：方法之一是调用 A的constructor，以b为参数构造一共A，const A a(b)；或者调用b的转换函数，将b转换为一个A对象，b.A()。编译器不会在这两个方法之中作出选择。<br />
<strong>解决</strong>：参考M5。<br />
类型转换中的ambiguity：</p>
<pre class="lang:default decode:true">void f(int x) {}
void f(char) {}

int main(int , char **) {
    double d = 12.34;
    f(d); // ambiguity
    return 0;
}
// 编译器输出：
test.cpp:27:2: error: call to 'f' is ambiguous
        f(d); // ambiguity
        ^
test.cpp:22:6: note: candidate function
void f(int x) {}
     ^
test.cpp:23:6: note: candidate function
void f(char) {}
     ^
1 error generated.</pre>
<p>解决：explicit cast。<br />
多重继承中的ambiguity：</p>
<pre class="lang:default decode:true">class A { void f(); }; // private f
struct B { void f(); }; // public
struct D : public B, public A {};

int main(int , char **) {
    D d;
    d.f(); // still ambiguity
    return 0;
}
// 编译器输出：
test.cpp:28:4: error: member 'f' found in multiple base classes of different
      types
        d.f(); // still ambiguity
          ^
test.cpp:23:17: note: member found by ambiguous name lookup
struct B { void f(); }; // public
                ^
test.cpp:22:16: note: member found by ambiguous name lookup
class A { void f(); }; // private f
               ^
1 error generated.</pre>
<p><strong>注意</strong>：即便A中的do()函数声明为private，也不能解决ambiguity问题。这就是c++的一个最不直观的规则：<span style="color: #ff0000;">存取限制不能解除因为多重继承而得的member的ambiguity。原因是：改变某个class member的存取限制，绝不应该改变程序的意义。</span></p>
</div>
</div>
<p>27. 如果不想使用编译器暗自产生的member functions，就应该明白拒绝它(Explicitly disallow use of implicitly generated member functions you don't want)<br />
对于任何一个编译器自动产生的函数，constructor,copy-constructor,assignment operator=,desctructor,address-of operator&amp;，如果你不希望他们被执行，你就要明确的拒绝他们。<br />
拒绝编译器自动产生的函数的方法：</p>
<ol>
<li>step1 给出要拒绝的函数的声明，这样编译器就不会自动生成它们；</li>
<li>step2 将要拒绝的函数声明为<code>private</code>/<code>delete</code>(C++11 specific)，这样client就无法调用它们；</li>
<li>step3 不要提供要拒绝的函数的定义，这样member function和friend function就不能调用它们。</li>
</ol>
<p>28. 尝试切割global namespace（全局命名空间）(Partition the global namespace)</p>
<h2>类与函数实现：(Classes and Functions: Implementation)</h2>
<p>29. 避免传回内部数据的handles(Avoid returning)<br />
handle to internal data是指指向类内部数据成员的指针或者引用，要避免返回一个指向内部数据的handle，是因为，该handle所代表的内容是不应该被函数调用者所 见的。当调用者得到了指向类内部数据的指针或者引用时，那么private也就对他失去了限制意义，他可以随心所欲的通过该handle修改类中 private member的内容。更为严重的是，handle所对应的对象终了时，handle也跟着终了，这可能比调用者预期的要快，最常见的是当某对象为临时对象 时，调用者得到临时对象中某个成员的handle，但是由于临时对象及该handle的销毁，调用者得到的handle已经不知所踪了。</p>
<p>对于const member function，返回指向内部数据的指针或者引用是不好的行为，因为看似const的内容实际上可以被client所修改；对于non-const member function，返回指向内部数据的指针或者引用，也是不妥的，特别是涉及到临时对象时，这个handle可能成为空悬的(dangling)。应该尽可能的避免传回指向内部数据的指针或者引用，即所谓handles to interal data。</p>
<p>30. 避免写出member functions，传回一个non-const pointer或reference并以之指向较低存取层级的members(Avoid member functions that return non-const pointer or references to members less accessible than themselves)</p>
<ol>
<li>本条规则其实在E29种已经有所体现，意思是说，避免让member function返回一个private/protected member data的non-const的指针或者引用。有的时候，出于效率的考虑，有的成员函数的返回值以by-reference而非by value的方式返回，但是，如果返回值是类的member data，且存取级别比较低（private/protected）就会造成返回值可能被客户程序修改，从而违反了private/protected的存取限制。</li>
<li>不单是成员数据，成员函数的存取限制，也会被传回member function的指针而违背。</li>
<li>当你面对效率的要求而必须写一个返回指向private/protect member的成员函数时，你可以返回一个指向const object的指针或者引用，这既可以保证效率，又可以保证存取限制规则。</li>
</ol>
<p>31. 千万不要传回“函数内local对象的reference”(Never return a reference to a local object or to a dereferenced pointer initialized by new with in the function)<br />
32. 尽可能延缓变量定义式的出现(Postpone varible definitions as long as possible)<br />
33. 明智的运用inlining(Use inlining judiciously)<br />
34. 将文件之间的编译依赖关系降至最低(Minimize compilation dependencies between files)</p>
<h2>继承关系和面向对象设计(Inheritance and object-Oriented Design)</h2>
<p>35. 确定你的public inheritance模塑出“is-a”关系(Make sure public inheritance models)<br />
36. 区分接口函数和实现继承(Differentiate between inheritance of interface and inheritance of implementaion)<br />
37. 绝对不要重新定义继承而来的非虚拟函数(Never redefine an inherited nonvitual function)<br />
38. 绝对不要定义继承而来的缺省参数值(Never redefine an inherited default parameter value)<br />
39. 避免在继承体系中作向下的转型动作(Avoid casts down the inheritance hierarchy)<br />
40. 通过layering技术来模塑has-a或is-implemented-in-terms-of的关系(Model)<br />
41. 区分inheritance和templates(Differentiate between inheritance and templates)<br />
42. 明智的运用私有继承(Use private inheritance judiciously)<br />
43. 明智的运用多继承(Use muliple inhertance judiciously)<br />
44. 说出你的意思并了解你所说的每一句话(Say what you mean; understand what you're saying)</p>
<h2>杂项讨论：(Miscellany)</h2>
<div class="panel panel-primary">
<div class="panel-heading">45. 清楚知道C++编译器为我们完成和调用那些函数(Know what function C++ silently writes and calls)</div>
<div class="panel-body">一个空的类被编译之后，会被编译器插入几个函数：<br />
一个类声明为<code>"class Empty{};"</code>，那么相当于作了如下的声明：</p>
<pre class="lang:default decode:true">class Empty{
public:
  //default constructor，用于凭空构造一个对象
  Empty();
  //copy constructor，用于从一个对象构造另一个对象
  Empty(const Empty&amp; rhs);
  //destructor，用于销毁这个对象
  ~Empty();
  //assignment operator=，用于用一个对象给另一个
  //已存在的对象赋值，执行memberwise assign
  Empty&amp; operator=(const Empty &amp;rhs);
  //non-const adderess-of operator，用于取地址
  Empty* operator&amp;();
  //const address of operator&amp;，用于取地址，且不可改变
  const Empty* operator&amp;() const;
};
// 只有当这些函数被需要时，编译器才会定义它们
// 下面的代码就在要求编译器定义并且执行某些自动生成的函数：
{
  const Empty e1;         // default constructor
  Empty e2(e1);           // copy constructor
  Empty e3=e1;            // copy constructor
  e2 = e1;                // assignment constructor
  Empty *pe2 =&amp;e2;        // non-const address-of operator
  const Empty *pe1 = &amp;e1; // const address-of operator
}                         // destructors</pre>
<p>关于<code>default constructor</code>和<code>destructor</code>：</p>
<ul>
<li><code>default constructor</code>和<code>destructor</code>不做任何事情，它们只是让你得以产生和销毁对象（编译器实现者有时会在它们里面放入一些 幕后的动作，见E33，M24）。它们看起来定义成这样：
<pre class="lang:default decode:true ">inline Empty::Empty(){}
inline Empty::~Empty(){}</pre>
</li>
<li>这个自动生成的destructor不是虚拟的。一个destructor要想成为virtual，要么声明为virtual，要么其父类有一个virtual destructor。关于virtual destructor，参考E14。</li>
</ul>
<p>关于<code>address-of operator&amp;</code>：<br />
缺省的<code>address-of operator</code>运算符只负责传回对象地址。看起来像这样：</p>
<pre class="lang:default decode:true">inline Empty* Empty::operator&amp;(){ return this; }
inline const Empty* Empty::operator&amp;() const { return this; }</pre>
<p>这里的<code>this</code>就是当前对象的地址。<br />
关于copy constructor和assignment <code>operator=</code>：</p>
<p>缺省的copy constructor和assignment operator，对该class的non-static data members（就是对象数据成员，不包含类数据成员）执行memberwise copy construction或者memberwise assignment动作。也就是说，设m是class C中的一个类型为T的non-static成员数据，当试图利用一个C的对象构造或赋值另一个对象（copy或assign）时：</p>
<ul>
<li>step1. 尝试调用c的copy constructor（或者assignment operator）来进行构造；如果C的copy constructor（或者assignment operator）不存在，则；</li>
<li>step2. 尝试调用C的成员m所属类型T的copy constructor（或 者assignment operator）来进行复制；如果T的copy constructor（或者assignment operator）没有定义，则；（对m之外的其他数据成员，类似调用其所属类型的copy constructor或者assignment operator）</li>
<li>step3. 上述规则递归实施于m的每一个data member身上。直到找到一个copy constructor（或者assignment operator），或者遇到内建类型为止；</li>
<li>step4. 如果遇到定义的copy constructor（或者assignment operator），就调用执行之；如果遇到内建类型，缺省按照bitwise copy的方式一位一位的进行construction（或者assignment）</li>
<li>step5. 对于继承体系的中的classes，这个规则将实施于体系中的每一层，所以用户自定义的copy constructor和assignment operator会在它们被声明的那层被调用。</li>
</ul>
<p>reference可以改变其值么？C++认为答案为否（参考M1）。那么对一个内含有reference member的class，缺省的assignment operator就不能够完成它的任务，因为它不懂得如何将一个reference的值赋给另外一个reference。因此，对于一个内含有 reference member的class，你有两个选择：提供一个干活的assignment operator；或者明确定拒绝assignment动作。</p>
<p>所以，对于data member中含有reference member或者const member的类，你需要提供一个可以干活的assignment operator，或者你可以明确地拒绝client进行assignment动作。要想拒绝很简单，<code>private</code>(C++11:<code>delete</code>)它，不要定义它，见E27。</p>
<p>E11，E15，E16，E17有更加详细的关于copy constructor和assignment operator的说明。</p>
</div>
</div>
<p>46. 宁愿编译和连接时出错也不要执行时出错(Prefer compile-time and line-time errors to runtime errors)<br />
47. 使用non-local static objects之前先确定它已有初值(Ensure that non-local static objects are initialized before they're used)<br />
48. 不要对编译器的警告视为不见(Pay attention to compiler warnings)</p>
<div class="panel panel-primary">
<div class="panel-heading">49. 尽量让自己熟悉C++标准库(Familiarize yourself with the standard library)</div>
<div class="panel-body">
<p>标准程序库中的每一样东西都是template。用户不要尝试手动声明标准程序库内的任何部分，你只要包含进适当的头文件就好了。C++标准库中的主要组件：</p>
<ul>
<li>C标准程序库。你仍然可以使用它们，例如。</li>
<li>iostream。新的特点：被模版化；支持<code>expection</code>；支持<code>string</code>；支持多国<code>locale</code>。仍然支持的原特性：<code>stream buffer</code>,<code>formatter</code>,<code>manipulator</code>,<code>file</code>,<code>cin</code>,<code>cout</code>,<code>cerr</code>,<code>clog</code>等。</li>
<li><code>string</code>。更方便，更有效率的替代<code>char*</code>指针。</li>
<li><code>container</code>。包含：<code>vector</code>,<code>list</code>,<code>queue</code>,<code>stack</code>,<code>deque</code>,<code>map</code>,<code>set</code>,<code>bitset</code>的高效率实现。可惜没有提供 <code>hash table</code>，不过<code>string</code>也是<code>Container</code>可以稍微弥补一下这个问题。所以，不需要自己再去实现<code>Container</code>了，使用标准库，你可以不被 new,delete带来的memory leak问题所困扰，使用也更加方便。</li>
<li><code>algorithms</code>。用于<code>container</code>对象、内建数组和一些其他类型身上，方便使用者操作对象。提供了：<code>for_each</code>,<code>find</code>, <code>count_if</code>,<code>equal</code>,<code>serach</code>,<code>copy</code>,<code>unique</code>,<code>rotate</code>,<code>sort</code>等等约70个算法，用于操作<code>container</code>对象。</li>
<li><code>internationalization</code>。用于协助完成国际化的工作，主要包括两个组件<code>facet</code>和<code>locale</code>。<code>facet</code>描述一个国家的特殊字符集 的处理方式，包括校对，日期时间，数值，货币，信息代码，自然语言映射关系等等。<code>locale</code>是一组<code>facet</code>，一个<code>locale</code>代表一个国家的全部特征 集合，而每一个<code>facet</code>描述一个该国的特征。C++允许多个<code>locales</code>同时在程序中起作用，所以同一个程序的不同部分可能会采取不同的规则。</li>
<li>数值处理。C++提供了复数，以及一些特殊的数组类型用来帮助处理数值。有一些<code>algorithm</code>专门处理这些数值。</li>
<li>诊断功能。标准库提供了三种错误处理方法：使用C的<code>assertion</code>（见E7）；使用错误代码；使用<code>exception</code>。<code>exception</code>有一套继承 体系，<code>exception</code>非为两个子类：<code>logic_error</code>和<code>runtime_error</code>。你可以选择使用<code>exception</code>提供的<code>class</code>也可以 不使用，并非强制的。</li>
</ul>
<p><code>container + algorithm + iterator = STL(Standard Template Library)</code>。STL并不是一个真正的软件，而是一个公约，每个人可以按照公约撰写自己的<code>container</code>，<code>algorithm</code>和 <code>iterator</code>，也可以与标准的STL互操作。</p>
</div>
</div>
<p>50. 加强自己对C++的了解(Improve your understanding of C++)</p>
<h2>参考</h2>
<ol>
<li><a style="background-color: #f3f3f3;" title="Gama的EffectiveC++笔记" href="http://blog.chinaunix.net/uid/20405949/sid-44089-list-1.html">Gama的EffectiveC++笔记</a><span style="color: #565656;">（25）</span></li>
</ol>
