---
layout: post
title: C++ 对象的自杀
date: 2014-04-23 18:13:10.000000000 +08:00
type: post
published: true
status: publish
categories:
- C++
tags: []
---
<p>前两天看到一个问题，<strong>一个类的成员函数是否可以delete this </strong>？<br />
据出题者的意思来看，是认为这样的问题一般比较少人会遇到，而这样就可以了解一下对方对未知问题的分析和解决思路。</p>
<p>出于这点，我也想看看自己的思路，所以就先自己思考了一下。<br />
1. 要使用delete，那么对象需要使用new来实例化（处于堆中），而不能使用类似DemoCls d;这样的语句将对象放在栈中；<br />
2. 成员函数delete this，这样给了我一种感觉：这个成员函数是不是超出了自己的权限呢？然而进一步想，我认为delete this纯粹代表释放this指针指向的特定大小的内存空间，告诉内存管理单元这块内存区域又“自由”了；<br />
基于以上两点，我认为由new运算符分配空间得到的对象的成员函数可以调用delete this;语句。</p>
<p><!--more--></p>
<p>后面在C++ FAQ看到该问题的阐述，原文如下：<br />
<em>[16.15] Is it legal (and moral) for a member function to say delete this?</p>
<p>As long as you're careful, it's OK for an object to commit suicide (delete this).</p>
<p>Here's how I define "careful":</p>
<p><strong>1. </strong>You must be absolutely 100% positive sure that this object was allocated via new (not by new[], nor by placement new, nor a local object on the stack, nor a global, nor a member of another object; but by plain ordinary new).<br />
<strong>2. </strong>You must be absolutely 100% positive sure that your member function will be the last member function invoked on this object.<br />
<strong>3. </strong>You must be absolutely 100% positive sure that the rest of your member function (after the delete this line) doesn't touch any piece of this object (including calling any other member functions or touching any data members).<br />
<strong>4. </strong>You must be absolutely 100% positive sure that no one even touches the this pointer itself after the delete this line. In other words, you must not examine it, compare it with another pointer, compare it with NULL, print it, cast it, do anything with it.</p>
<p>Naturally the usual caveats apply in cases where your this pointer is a pointer to a base class when you don't have a virtual destructor. </em></p>
<p>上面提到了“自杀”时需要注意4点：<br />
<strong>1.</strong> 对象是通过最简单的new运算符分配到空间的，而非new[]，也不是内存定位的new（比如new(P) Q），更不是栈上面的、全局的，最后该对象不能是另外一个对象的成员；<br />
<strong>2.</strong> 负责自杀的成员函数应该是该对象最后调用的成员函数；<br />
<strong>3.</strong> 负责自杀的成员函数在delete this;这一条语句后面不能再去访问对象的其它成员；<br />
<strong>4.</strong> 对象自杀后，不能再去访问this指针；<br />
最后说明了一句，如果this指针指向一个不具有虚析构函数的基类对象，往往会出现警告。</p>
<p>对于上面要注意的4点，有的即使不遵守也不会出现警告或者错误，但是会有安全隐患。因为delete this;语句得到调用后，指向该对象的指针就是野指针了，这时候内存中的内容可能保持完整并且可以被访问，使得数据仍然有效，但是安全的编码风格应该保证内存释放后不能再对它进行访问，避免潜在风险。</p>
<pre>
#include <iostream>

using namespace std;

class Creature {
    public:
        Creature() {
            cout << "life +1" << endl;
        }
        virtual ~Creature() {
            cout << "life -1" << endl;
        }
};

class Person: public Creature {
    public:
        Person(const string& name_) : name(name_) {
            cout << "A man was born and named " << name << endl;
        }
        ~Person() {
            cout << "A man named " << name << " was dead" << endl;
        }
        void suicide() {
            cout << name << " commited suicide" << endl;
            delete this;
        }
    private:
        string name;
};

int main() {
    Person *p = new Person("John");
    p->suicide();

    return 0;
}
</iostream></pre>
<p>output:</p>
<pre class="lang:shell">
$./test
life +1
A man was born and named John
John commited suicide
A man named John was dead
life -1
</pre>
