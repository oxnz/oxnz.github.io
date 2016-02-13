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
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---
<p>Standard Template Library: Algorithms<br />
The header defines a collection of functions especially designed to be used on ranges of elements.</p>
<p>A range is any sequence of objects that can be accessed through iterators or pointers, such as an array or an instance of some of the STL containers. Notice though, that algorithms operate through iterators directly on the values, not affecting in any way the structure of any possible container (it never affects the size or storage allocation of the container).</p>
<p><a href="http://www.cplusplus.com/reference/algorithm/">http://www.cplusplus.com/reference/algorithm/</a></p>
<p><!--more--></p>
<p>swap:</p>
<p>相信大家看到swap这个词都一定不会感到陌生，甚至会有这样想法：这不就是简单的元素交换嘛。的确，swap交换函数是仅次于Hello word这样老得不能老的词，然而，泛型算法东风，这个小小的玩意儿却在C++ STL中散发着无穷的魅力。本文不仅详细地阐述STL泛型算法swap，并借助泛型算法这股东风，展现STL容器中swap成员函数的神奇魅力。注意哦，泛型算法swap和容器中的swap成员函数，这是两个不同角度和概念哦！</p>
<p>一、泛型算法swap</p>
<p>老规矩，我们先来看看swap的函数原型：</p>
<pre class="lang:default decode:true ">template &lt;class T&gt; void swap ( T&amp; a, T&amp; b )
{
  T c(a); a=b; b=c;
}  </pre>
<p>二、容器中的成员函数swap</p>
<p>        在容器vector中，其内存占用的空间是只增不减的，比如说首先分配了10,000个字节，然后erase掉后面9,999个，则虽然有效元素只有一个，但是内存占用仍为10,000个。所有内存空间在vector析构时回收。</p>
<p>     一般，我们都会通过vector中成员函数clear进行一些清除操作，但它清除的是所有的元素，使vector的大小减少至0，却不能减小vector占用的内存。要避免vector持有它不再需要的内存，这就需要一种方法来使得它从曾经的容量减少至它现在需要的容量，这样减少容量的方法被称为“收缩到合适（shrink to fit）”。（节选自《Effective STL》）如果做到“收缩到合适”呢，嘿嘿，这就要全仰仗“Swap大侠”啦，即通过如下代码进行释放过剩的容量(C++11: shrink_to_fit)：</p>
<pre class="lang:default decode:true ">vector&lt; T &gt;().swap(X)  </pre>
<pre class="lang:default decode:true ">int main ()
{
    int x = 10;
    vector&lt;int&gt; myvector(10000, x);

    //这里打印仅仅是元素的个数不是内存大小
    cout &lt;&lt; "myvector size:"
         &lt;&lt; myvector.size()
         &lt;&lt; endl;

    //swap交换函数释放内存：vector&lt;T&gt;().swap(X);
    //T:int ; myvertor代表X
    vector&lt;int&gt;().swap(myvector);

    //两个输出仅用来表示swap前后的变化
    cout &lt;&lt; "after swap :"
         &lt;&lt; myvector.size()
         &lt;&lt; endl;

    return 0;
}</pre>
<p>swap交换技巧实现内存释放思想：vector()使用vector的默认构造函数建立临时vector对象，再在该临时对象上调用swap成员，swap调用之后对象myvector占用的空间就等于一个默认构造的对象的大小，临时对象就具有原来对象v的大小，而该临时对象随即就会被析构，从而其占用的空间也被释放。</p>
<pre class="lang:default decode:true ">std::vector&lt;T&gt;().swap(X)</pre>
<p>作用相当于：</p>
<pre class="lang:default decode:true ">{
    std::vector&lt;T&gt;  temp(X);
    temp.swap(X);
}
</pre>
<p>    注意：并不是所有的STL容器的clear成员函数的行为都和vector一样。事实上，其他容器的clear成员函数都会释放其内存。比如另一个和vector类似的顺序容器deque。</p>
<p>上一篇《C++的营养——RAII》中介绍了RAII，以及如何在C#中实现。这次介绍另一个重要的基础技术——swap手法。<br />
swap手法<br />
    swap手法不应当是C++独有的技术，很多语言都可以实现，并且从中得到好处。只是C++存在的一些缺陷迫使大牛们发掘，并开始重视这种有用的手法。这个原本被用来解决C++的资源安全和异常保证问题的技术在使用中逐步体现出越来越多的应用，有助于我们编写更加简洁、优雅和高效的代码。<br />
    接下来，我们先来和swap打个招呼。然后看看在C#里如何玩出swap。最后展示swap手法的几种应用，从中我们将看到它是如何的可爱。<br />
    假设，我要做一个类，实现统计并保存一个字符串中字母的出现次数，以及总的字母和数字的个数。</p>
<pre>class CountStr
        ...{
        public:
            explicit CountStr(std::string const& val)
                :m_str(val), m_nLetter(0), m_nNumber(0) ...{
                do_count(val);
            }
            CountStr(CountStr const& cs)
                :m_str(cs.m_str), m_counts(cs.m_counts)
                , m_nLetter(cs.m_nLetter), m_nNumber(cs.m_nNumber)
            ...{}
               void swap(CountStr& cs) ...{
                   std::swap(m_str, cs.m_str);
                   m_counts.swap(m_str);
                   std::swap(m_nLetter, cs.m_nLetter);
                   std::swap(m_nNumber, cs.m_nNumber);
               }
        private:
            std::string m_str;
            std::map<char, int> m_counts;
            int m_nLetter;
            int m_nNumber;
        }</pre>
<p>    在类CountStr中，定义了swap成员函数。swap接受一个CountStr&类型的参数。在函数中，我们可以看到一组函数调用，每一个对应一个数据成员，其任务是将相对应的数据成员的内容相互交换。此处，我使用了两种调用，一种是使用std::swap()标准函数，另一种是通过 swap成员函数执行这个交换。一般情况下，std::swap()通过一个临时变量实现对象的内容交换。但对于string、map等非平凡的对象，这种交换会引发至少三次深拷贝，其复杂度将是O(3n)的，性能极差。因此，标准库为这些类定义了swap成员函数，通过成员函数可以实现O(1)的交换操作。同时将std::swap()针对这些拥有swap()成员函数的标准容器特化，使其可以直接使用swap()成员函数，而避免性能损失。但是，对于那些拥有swap()成员，但没有被特化的用户定义，或第三方的类，则不应使用std::swap()，而改用swap()成员函数。所以，一般情况下，为了避免混淆，对于拥有swap()成员函数的类，调用swap()，否则调用标准std::swap()函数。<br />
    顺便提一下，在未来的C++0x中，由于引入了concept机制，可以允许一个函数模板自动识别出所有“具有swap()成员”的类型，并使用相应的特化版本。这样便只需使用std::swap()，而不必考虑是什么样的类型了。<br />
    言归正传。这里，swap()成员函数有两个要求，其一是复杂度为O(1)，其二是具备无抛掷的异常保证。前者对于性能而言至关重要，否则swap操作将会由于性能问题而无法在实际项目中使用。对于后者，是确保强异常保证（commit or rollback语义）的基石。要达到这两个要求，有几个关键要点：首先，对于类型为内置类型或小型POD（8～16字节以内）的成员数据，可以直接使用 std::swap()；其次，对于非平凡的类型（拥有资源引用，复制构造和赋值操作会引发深拷贝），并且拥有符合上述要求的swap()成员函数的，直接使用swap()成员函数；最后，其余的类型，则保有其指针，或智能指针，以确保满足上述两个要求。<br />
    听上去有些复杂，但在实际开发中做到并不难。首先，尽量使用标准库容器，因为标准库容器都拥有满足两个条件的swap()成员。其次，在编写的每一个类中实现满足两个条件的swap()成员。最后，对于那些不具备swap()成员函数的第三方类型，则使用指针，最好是智能指针。（也就是Sutter所谓的 PImpl手法）。只要坚持这些方针，必能收到很好的效果。<br />
    下面，就来看一下这个swap()的第一个妙用。假设，这个类需要复制。通常可以通过operator=操作符，或者copy（或其他有明确的复制含义的）成员函数实现，这两者实际上是等价的，只是形式不同而已。这里选择operator=，因为它比较C++:)。<br />
    最直白的实现方式是这样：</p>
<pre>class CountStr
        ...{
        public:
            ...
            CountStr& operator=(CountStr& val) ...{
                m_str=val.m_str;
                m_counts=val.m_counts;
                m_nLetter=val.m_nLetter;
                m_nNumber=val.m_nNumber;
            }
            ...
        }</pre>
<p>    很简单，但是不安全，或者说没有满足异常保证。<br />
    先解释一下异常保证。异常保证有三个级别：基本保证、强异常保证和无抛掷保证。基本保证是指异常抛出时，程序的各个部分应当处于有效状态，不能有资源泄漏。这个级别可以轻而易举地利用RAII确保，这在前一篇已经展示过了。强异常保证则更加严格，要求异常抛出后，程序非但要满足基本保证，其各个部分的数据应保持原状。也就是要满足“Commit or Rollback”语义，熟悉数据库的人，可以联想一下Transaction的行为。而无抛掷保证要求函数在任何情况下都不会抛出异常。无抛掷保证不是说用一个catch(...)或throw()把异常统统吞掉。而是说在无抛掷保证的函数中的任何操作，都不会抛出异常。能满足无抛掷保证的操作还是很多的，比如内置POD类型（int、指针等等）的复制，swap手法便以此为基础。（多说一句，用catch(...)吞掉异常来确保无抛掷并非绝对不行，在特定情况下，还是可以偶尔一用。不过这等烂事也只能在西构函数中进行，而且也只有在迫不得已的情况下用那么一下）。<br />
    如果这四个赋值操作中，任意一个抛出异常，便会退出这个函数（操作符）。此时，至少有一个成员数据没有正确修改，而其他的则全部或部分地发生改变。于是，一部分成员数据是新的，另一部分是旧的，甚至还有一些是不完全的。这在软件中往往会引发很多令人苦恼的bug。无论如何，此时应当运用强异常保证，使得数据要么是新的值，要么没有改变。那么如何获得强异常保证？在swap()的帮助下，惊人的简单：</p>
<pre>class CountStr
        ...{
        public:
            ...
            CountStr& operator=(CountStr& val) ...{
                swap(CountStr(val)); // 或者CountStr(val).swap(*this);
                raturn *this;
            }
            ...
        }</pre>
<p>    我想世上没有比这等代码更加漂亮的了吧！不仅仅具有简洁动人的外表，而且充满了丰富的内涵。这就叫优雅。不过，优雅之下还需要一些解释。在这两个版本中，都是先用复制构造创建一个临时对象，这个临时对象同传入的参数对象拥有相同的值。然后用swap()成员函数将this对象的内容与临时对象交换。于是， this对象拥有了临时对象的值，也就是与传入的实参对象具有相同的值（复制）。当退出函数的时候，临时对象销毁，自然而然地释放了this对象原先的资源（前提是CountStr类实现了RAII）。<br />
    那么抛出异常的情况又是怎样的呢？<br />
    先来看看operator=里执行了哪些步骤，并考察这些步骤的异常抛掷的情况。如果将代码改写成另一个等价的形式，就很容易理解了：</p>
<pre>CountStr& operator=(CountStr& val) ...{
                CountStr t_(val);    //此处可能抛出异常，但只有t_的值发生变化
                t_.swap(*this);       //由于swap拥有无抛掷保证，所以不会抛出异常
                return *this；
            }</pre>
<p>    在构造临时对象的时候，可能会抛出异常，因为此时执行了数据的复制和构造。请注意，这时候this对象的内容没有改变。如果此时抛出异常，数据发生改变的只有t_，this对象并未受到影响。而随着栈清理，t_也将被析构，在RAII的作用下，t_所占用的资源也会依次释放。而下一步，swap()成员的调用，则是无抛掷保证的，不会抛出异常，this的内容可以得到充分地、原子地交换，不会发生数据值修改一半的情况。<br />
    在C#中，实现swap非常容易，甚至比C++更容易。因为在C#中，大部分对象都在堆上，代码中定义的所谓对象实际上是引用。对于引用的赋值操作是无抛掷的，因此在C#中可以采用同C++几乎一样的代码实现swap：</p>
<pre>class CountStr
        ...{
            public CountStr(string val) ...{
                m_str=val;
                m_nLetter=0;
                m_nNumber=0;
                do_count(val);
            }
            public CountStr(CountStr cs) ...{
                m_str=new string(cs.m_str);
                m_counts=new Dictionary<char, int>(cs.m_counts);
                m_nLetter=cs.m_nLetter;
                m_nNumber=cs.m_nNumber
            }

              public void swap(CountStr& cs) ...{
                   utility.swap(ref m_str, ref cs.m_str);
                   utility.swap(ref m_counts, ref cs.m_counts);
                   utility.swap(ref m_nLetter, ref cs.m_nLetter);
                   utility.swap(ref m_nNumber, ref cs.m_nNumber);
              }
            public void copy(CountStr& cs) ...{
                this.swap(new CountStr(cs));
            }

            private string m_str;
            private Dictionary<char, int> m_counts;
            private int m_nLetter;
            private int m_nNumber;
        }</pre>
<p>这里utility.swap()是一个泛型函数，作用是交换两个参数：</p>
<pre>class utility
        ...{
            public static void swap<t>(ref T lhs, ref T rhs) ...{
                T t_=lhs;
                lhs=rhs;
                rhs=t_;
            }
        }</t></pre>
<p>    如果类有关键性的资源需要释放，那么可以实现IDisposable接口，然后在copy()中使用using：</p>
<pre>public void copy(CountStr& cs) ...{
                using(CountStr t_=new CountStr(cs))
                    ...{
                        t_.swap(this);
                    }
            }</pre>
<p>    如此，对象原有的数据和资源被交换到临时对象t_中之后，在退出using作用域的时候，会立即得到释放。这是RAII的一个应用，详细内容参见本系列的前一篇《C++的营养——RAII》。<br />
    swap的基本作用是维持强异常保证语义。但是，作为一种基础性的技术，它还可以拥有更多的用途。下面介绍几种主要的应用，为了节省篇幅，案例直接使用C#，不再给出C++的代码。<br />
    在我们的开发过程中，有时需要是一些对象复位，即回复对象的初始状态。一般情况下，我们会在类中增加一个reset()之类的成员，在这个函数中释放资源，恢复各成员数据的初值。但是，在拥有swap的情况下，这种操作变得非常容易：</p>
<pre>class X
        ...{
            public X() ...{
                ... //初始化对象
            }
            public X(int v) ...{
                ... //以v初始化对象
            }
            public void swap(X val) ...{...}
            public void reset() ...{
                this.swap(new X());
            }
            ...
        }</pre>
<p>    reset()用X的默认构造函数创建了一个临时对象，将其内容与this交换，this的内容便成为了初始值。重要的是，这个成员函数也是强异常保证的。如果需要通过一些参数复位，那么同样可以做到：</p>
<pre>class X
        ...{
            ...
            public void reset(int v) ...{
                this.swap(new X(v));
            }
            ...
        }</pre>
<p>    有时甚至可以不需要reset这个成员，而直接在代码中使用swap复位一个对象：</p>
<pre>X x=new X();
        ... //对x的操作，改变了内容
        x.swap(new X()); //复位了</pre>
<p>    如果X有资源需要释放，那么只需实现IDispose，然后使用using：</p>
<pre>class X : IDisposable
        ...{
            ...
            public void reset() ...{
                using(X t=new X())
                ...{
                    this.swap(t);
                }
            }
            public void Dispose() ...{...}
            ...
        }</pre>
<p>    上面这些应用都有一个共同点，即重新初始化一个对象，使其恢复到一个初始状态。下面的应用，则反其道而行之，将一个对象切换到另一个状态。<br />
    有时，我们会做一些类，在构造函数中执行一些复杂的操作，比如解析一个文本文件，然后向外公布解析后的结果。之后，我们需要在这个对象上load另一个文件，那么通常都写一个load成员函数，先释放掉原先占用的资源，然后再加载新的文件。如果有了swap，那么这个load函数同样极其简单：</p>
<pre>class Y : IDisposable
        ...{
            public Y(string filename) ...{
                ... //打开文件，执行解析
            }
            public void swap(Y val) ...{...}
            public load(string filename) ...{
                using(Y t=new Y(filename))
                ...{
                    this.swap(t);
                }
            }
            public void Dispose() ...{
                ... //关闭文件，释放资源
            }
        }</pre>
<p>    还有一种情况，有一些类，通过一些数据创建，创建之后在绝大多数的情况下都是只读的，但偶尔会需要改变其内部数据。为了代码的可靠性，我们可以把类写成只读的。但是如何修改其内部的数据呢？也可以通过swap：</p>
<pre>class Z
        ...{
            public Z(int a, float b) ...{
                m_a=a;
                m_b=b;
            }
            public void swap(Z val) ...{...}
            public int a ...{ get...{return m_a;}}
            public float b ...{ get...{return m_b;}}
            private int m_a;
            private float m_b;
        }

        Z z=new Z(3, 4.5);
        z.swap(new Z(5, 5.4)); //z的值已修改</pre>
<p>    这样便可避免对Z的实例的随意修改。但是，这种修改方式会造成性能损失，特别是数据成员存在非O(1)复制的情况下（如有字符串、数组等），只有在修改偶尔发生的情况下才能使用。<br />
    有些类，构造函数需要一些数据初始化对象，并且会创建的过程中会验证其有效性，和执行一些计算。也就是构造函数存在一定的数据逻辑。如果需要修改对象的某些值，会牵涉到相应的复杂数据逻辑。通常都是把这些逻辑独立在private成员函数中，由构造函数和数据修改操作共享。这样的做法往往不能带来强异常保证，在构造函数里的数据验证往往会抛出异常。因此，如果使用swap，便可以消除这类问题，并且使代码简化：</p>
<pre>class A
        ...{
            public A(int a, string b, Rectangle c) ...{
                ... //数据逻辑、计算等
            }
            public int a ...{
                set...{ this.swap(new A(value, m_b, m_c));}
            }
            public string b ...{
                set...{ this.swap(new A(m_a, value, m_c));}
            }
            public Rectangle c ...{
                set...{ this.swap(new A(m_a, m_b, value));}
            }
            ...
       }</pre>
<p>    当然，也可以在类外直接进行这样的数据设置：</p>
<pre>A a=new A(2, "zzz", Rectangle(1,1, 10,10));
        a.swap(new A(3, "zzz", Rectangle(1,1, 10,10)));</pre>
<p>    这种用法可以用于某些只保存对构造函数参数的计算结果，而不需要保存这些参数的类（m_a，m_b，m_c都不需要了），只是使用上过于琐碎。<br />
    所有这些与对象状态设置有关的swap用法，都集中表现了一个特性，即使得我们可以将对象的初始化代码集中在构造函数中，数据和资源清理的代码集中在 Dispose()中。这种做法可以大大提高代码的可维护性。如果一个软件项目中，每个类都实现swap和复制构造函数（除非该类不允许复制），并尽可能集中数据逻辑代码，那么会使得代码质量有答复的提高。<br />
    在上一篇《C++的营养——RAII》中，我提到守卫一个结构复杂的类：在代码中修改一个对象，然后再回复原来的状态。如果单纯手工地保存对象数据，通常很困难（有时甚至是不可能的），而且也难以维持异常安全性（强异常保证）。但是如果使用了swap，那么将会易如反掌：</p>
<pre>void ScopeObject(MyCls obj) ...{
            using(MyCls t_=new MyCls(obj))
            ...{
                ... //操作obj，改变其状态或数据
                obj.swap(t_); //恢复原来的状态
            }
        }</pre>
<p>    当然，也可以直接使用t_执行操作，这就不需要执行swap。在一般情况下两者是等价的。但是，在某些特殊情况下，比如类持有特殊资源，或者obj是并发中的共享对象的时候，两种方法有可能不等价。swap方案使用上更全面些。总的来说相差不多，放在这里仅供参考。<br />
    作为更进一步的发展，可以构造一个ISwapable泛型接口：</p>
<pre>interface ISwapable<t>
        ...{
            void swap(T v);
        }</t></pre>
<p>    对于需要实现swap手法的类，实现这个接口：</p>
<pre>class B : ISwapable&lt;B>
        ...{
            public B() ...{...}
            public void swap(B v) ...{...}
            ...
        }</pre>
<p>    这将会带来一个好处，通过泛型算法实现某些特定的操作：</p>
<pre>class utility
        ...{
            public static void reset<t>(T obj)
                where T : ISwapable
                where T : new()
            ...{
                obj.swap(new T());
            }
        }</t></pre>
<p>    这样便无须为每一个类编写reset成员函数，只需这一个泛型算法即可：</p>
<pre> X x;
        Y y;
        utility.reset(x);
        utility.reset(y);
        ...</pre>
<p>    swap手法可能在存在其他诸多应用，在编码的时候可以不断地发掘。只需要抓住一个原则：swap可以无抛掷，简洁地修改一个对象的值。swap所带来的一个问题主要是性能方面。swap通常伴随着临时对象的构造，多数情况下，这种构造不会引发更多的性能损失，但在某些数据修改的应用中，会比直接的数据修改损失更多的性能。如何取舍，需要根据具体情况分析和权衡。总的来说，swap手法所带来的好处是显而易见的，特别是强异常保证，往往是至关重要的。而诸如简化代码等的作用，则无需多言，一用便知。<br />
    或许swap手法非常基础，非常细小，而且很多人不用swap也过来了。但是，聚沙成塔，每一处细小的优化，积累起来则是巨大的进步。还是刘皇叔说得好：“勿以善小而不为，勿以恶小而为之”。</p>
<p>iter_swap:</p>
<p>      上文中阐述了元素交换算法swap以及容器中swap成员函数的使用，尤其是通过vector成员函数的交换技巧实现容器内存的收缩，今天，我们要看到的是另一个变易算法，迭代器的交换算法iter_swap，顾名思义，该算法是通过迭代器来完成元素的交换。首先我们来看看函数的原型：</p>
<p>函数原型：</p>
<pre class="lang:default decode:true ">template&lt;class ForwardIterator1, class ForwardIterator2&gt;
   void iter_swap(
      ForwardIterator1 _Left,
      ForwardIterator2 _Right
   );</pre>
<p>参数说明：<br />
        _Left，_Right指向要交换的两个迭代器</p>
<p>程序示例：</p>
<p>        在泛型编程里面，iterator被称为“泛型指针”，因此我们可以通过iterator作为指针来交换两个数组的元素，为了展示swap和iter_swap的区别，在下面这个示例中，我们分别通过这两个算法来实现数组元素的简单交换。</p>
<pre class="lang:default decode:true ">int main()
{
    //初始化数组
    int b[ 9 ] = { 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    ostream_iterator&lt; int &gt; otpt( cout, " " );

    //通过copy+ostream_iterator的方式输出原始数组
    cout &lt;&lt; "Array a contains:n ";
    copy( b, b + 9, otpt );

    //调用iter_swap交换b[0]和b[1]
    iter_swap( &amp;b[0], &amp;b[1] );

    //调用swap交换b[2]和b[3]，展示两者的区别
    swap( b[2], b[3] );

    //通过copy+ostream_iterator的方式输出交换后的数组
    cout &lt;&lt; "n Array a after swapping :n ";
    copy( b, b + 9, otpt );
    cout &lt;&lt; endl;

    return 0;
}  </pre>
<p>上例中，迭代器是作为泛型指针的形式来实现数组元素的交换，现在我们通过iter_swap算法来实现同一种容器之间元素的交换以及不同容器之间的元算交换。</p>
<pre class="lang:default decode:true ">int main( )
{
   deque&lt;int&gt; deq1;
   deque&lt;int&gt;::iterator d1_Iter;
   ostream_iterator&lt; int &gt; otpt( cout, " " );

   deq1.push_back ( 2 );
   deq1.push_back ( 4 );
   deq1.push_back ( 9 );

   //通过copy输出队列初始序列
   cout &lt;&lt; "The deque is:n";
   copy(deq1.begin(), deq1.end(), otpt);

   //通过iter_swap算法交换队列中第一个和最后一个元素
   iter_swap(deq1.begin() , --deq1.end());

   //输出通过iter_swap交换后的队列
   cout &lt;&lt; "nnThe deque of CInts with first &amp; last elements swapped is:n ";
   copy(deq1.begin(), deq1.end(), otpt);

   //通过swap交换算法还原队列中的元素
   swap (*deq1.begin(), *(deq1.end()-1));

   cout &lt;&lt; "nnThe deque of CInts with first &amp; last elements swapped back is:n ";
   copy(deq1.begin(), deq1.end(), otpt);
   cout &lt;&lt; endl;

   cout &lt;&lt; "*********************************" &lt;&lt; endl;


   // 通过iter_swap交换vector和deque两个不同容器中的元素
   vector &lt;int&gt; v1;
   deque &lt;int&gt; deq2;

   //初始化容器v1
   for ( size_t i = 0 ; i &lt;= 3 ; ++i )
   {
      v1.push_back( i );
   }

   //初始化队列deq2
   for ( size_t ii = 4 ; ii &lt;= 5 ; ++ii )
   {
      deq2.push_back( ii );
   }

   cout &lt;&lt; "nVector v1 is : " ;
   copy(v1.begin(), v1.end(), otpt);

   cout &lt;&lt; "nDeque deq2 is : " ;
   copy(deq2.begin(), deq2.end(), otpt);
   cout &lt;&lt; endl;

   //交换容器v1和队列deq2的第一个元素
   iter_swap( v1.begin(), deq2.begin() );

   cout &lt;&lt; "nnAfter exchanging first elements,n vector v1 is:  " ;
   copy(v1.begin(), v1.end(), otpt);

   cout &lt;&lt; " n deque deq2 is: ";
   copy(deq2.begin(), deq2.end(), otpt);

   cout &lt;&lt; endl;

   return 0;
}  </pre>
<p>swap_ranges:</p>
<p>   前面我们已经熟悉了swap和iter_swap，接下来我们来看看区间元素交换算法：swap_ranges，该算法用于进行两个迭代器区间元素的交换。它的使用原形如下，将迭代器区间[first1，last1)的元素，与迭代器区间[first2，first2+(last1-first1))迭代器区间元素交换其中*first1和*first2交换、*（first+1）和*（first2+1）交换、...*（last1-1）和*（first2+ last1-fitst1）-1）交换。</p>
<p>   函数原型：</p>
<pre class="lang:default decode:true ">template&lt;class ForwardIterator1, class ForwardIterator2&gt;
  ForwardIterator2 swap_ranges ( ForwardIterator1 first1, ForwardIterator1 last1,
                                 ForwardIterator2 first2 )
{
  while (first1!=last1) swap(*first1++, *first2++);
  return first2;
}  </pre>
<p>  参数说明：</p>
<p>first1, last1<br />
指出要进行交换的第一个迭代器区间 [first1,last1)。<br />
first2<br />
指出要进行交换的第二个迭代器区间的首个元素的迭代器位置，该区间的元素个数和第一个区间相等。</p>
<p>    程序示例：</p>
<pre class="lang:default decode:true ">int main () {
  vector&lt;int&gt; first (5,10);        //  first: 10 10 10 10 10
  vector&lt;int&gt; second (5,33);       // second: 33 33 33 33 33
  vector&lt;int&gt;::iterator it;

  swap_ranges(first.begin()+1, first.end()-1, second.begin());

  // print out results of swap:
  cout &lt;&lt; " first contains:";
  for (it=first.begin(); it!=first.end(); ++it)
    cout &lt;&lt; " " &lt;&lt; *it;

  cout &lt;&lt; "nsecond contains:";
  for (it=second.begin(); it!=second.end(); ++it)
    cout &lt;&lt; " " &lt;&lt; *it;

  cout &lt;&lt; endl;

  return 0;
}  </pre>
<p>transform:</p>
<p>前篇我们已经了解了一种区间元素交换swap_ranges函数，现在我们再来学习另外一种区间元素交换transform。该算法用于实行容器元素的变换操作。有如下两个使用原型，一个将迭代器区间[first，last)中元素，执行一元函数对象op操作，交换后的结果放在[result，result+（last-first)）区间中。另一个将迭代器区间[first1，last1)的元素*i，依次与[first2，first2+（last-first）)的元素*j，执行二元函数操作binary_op(*i,*j)，交换结果放在[result，result+（last1-first1)）。</p>
<p>     函数原型：</p>
<pre class="lang:default decode:true ">template &lt; class InputIterator, class OutputIterator, class UnaryOperator &gt;
  OutputIterator transform ( InputIterator first1, InputIterator last1,
                             OutputIterator result, UnaryOperator op );

template &lt; class InputIterator1, class InputIterator2,
           class OutputIterator, class BinaryOperator &gt;
  OutputIterator transform ( InputIterator1 first1, InputIterator1 last1,
                             InputIterator2 first2, OutputIterator result,
                             BinaryOperator binary_op );  </pre>
<p>  参数说明：</p>
<p>first1, last1<br />
指出要进行元素变换的第一个迭代器区间 [first1,last1)。<br />
first2<br />
指出要进行元素变换的第二个迭代器区间的首个元素的迭代器位置，该区间的元素个数和第一个区间相等。</p>
<p>result<br />
指出变换后的结果存放的迭代器区间的首个元素的迭代器位置<br />
op<br />
用一元函数对象op作为参数，执行其后返回一个结果值。它可以是一个函数或对象内的类重载operator()。<br />
binary_op<br />
用二元函数对象binary_op作为参数，执行其后返回一个结果值。它可以是一个函数或对象内的类重载operator()。</p>
<p>      程序示例：</p>
<pre class="lang:default decode:true ">int op_increase (int i) { return ++i; }
int op_sum (int i, int j) { return i+j; }

int main () {
  vector&lt;int&gt; first;
  vector&lt;int&gt; second;
  vector&lt;int&gt;::iterator it;

  // set some values:
  for (int i=1; i&lt;6; i++) first.push_back (i*10); //  first: 10 20 30 40 50

  second.resize(first.size());     // allocate space
  transform (first.begin(), first.end(), second.begin(), op_increase);
                                                  // second: 11 21 31 41 51

  transform (first.begin(), first.end(), second.begin(), first.begin(), op_sum);
                                                  //  first: 21 41 61 81 101

  cout &lt;&lt; "first contains:";
  for (it=first.begin(); it!=first.end(); ++it)
    cout &lt;&lt; " " &lt;&lt; *it;

  cout &lt;&lt; endl;
  return 0;
}  </pre>
<p>replace:</p>
<p>    替换算法将指定元素值替换为新值，使用原型如下，将迭代器[first，last)中值为old_value的元素全部替换为new_value值。</p>
<p>    函数原型：</p>
<pre class="lang:default decode:true ">template &lt; class ForwardIterator, class T &gt;
  void replace ( ForwardIterator first, ForwardIterator last,
                 const T&amp; old_value, const T&amp; new_value );  </pre>
<p>    参数说明：</p>
<p>first, last<br />
指出要替换的迭代器区间[first,last)<br />
old_value<br />
将要被替换的元素值<br />
new_value<br />
将要替换旧值的新值<br />
     程序示例：</p>
<pre class="lang:default decode:true ">int main () {
  int myints[] = { 10, 20, 30, 30, 20, 10, 10, 20 };
  vector&lt;int&gt; myvector (myints, myints+8);            // 10 20 30 30 20 10 10 20

  replace (myvector.begin(), myvector.end(), 20, 99); // 10 99 30 30 99 10 10 99

  cout &lt;&lt; "myvector contains:";
  for (vector&lt;int&gt;::iterator it=myvector.begin(); it!=myvector.end(); ++it)
    cout &lt;&lt; " " &lt;&lt; *it;

  cout &lt;&lt; endl;

  return 0;
}</pre>
<p>copy:</p>
<p>前面十二个算法所展现的都属于非变易算法（Non-mutating algorithms）系列，现在我们来看看变易算法。所谓变易算法(Mutating algorithms)就是一组能够修改容器元素数据的模板函数，可进行序列数据的复制，变换等。</p>
<p>       我们现在来看看第一个变易算法：元素复制算法copy。该算法主要用于容器之间元素的拷贝，即将迭代器区间[first，last)的元素复制到由复制目标result给定的区间[result，result+(last-first))中。下面我们来看看它的函数原型：</p>
<p>函数原形:</p>
<pre class="lang:default decode:true ">template&lt;class InputIterator, class OutputIterator&gt;
   OutputIterator copy(
      InputIterator _First,
      InputIterator _Last,
      OutputIterator _DestBeg
   );  </pre>
<p>参数<br />
_First, _Last<br />
指出被复制的元素的区间范围[ _First，_Last).<br />
_DestBeg<br />
指出复制到的目标区间起始位置<br />
返回值<br />
返回一个迭代器，指出已被复制元素区间的最后一个位置</p>
<p>程序示例：</p>
<p>首先我们来一个简单的示例，定义一个简单的整形数组myints，将其所有元素复制到容器myvector中，并将数组向左移动一位。</p>
<pre class="lang:default decode:true ">int main ()
{
    int myints[] = {10, 20, 30, 40, 50, 60, 70};
    vector&lt;int&gt; myvector;
    vector&lt;int&gt;::iterator it;

    myvector.resize(7);   // 为容器myvector分配空间

    //copy用法一：
    //将数组myints中的七个元素复制到myvector容器中
    copy ( myints, myints+7, myvector.begin() );

    cout &lt;&lt; "myvector contains: ";
    for ( it = myvector.begin();  it != myvector.end();  ++it )
    {
        cout &lt;&lt; " " &lt;&lt; *it;
    }
    cout &lt;&lt; endl;

    //copy用法二:
    //将数组myints中的元素向左移动一位
    copy(myints + 1, myints + 7, myints);

    cout &lt;&lt; "myints contains: ";
    for ( size_t i = 0; i &lt; 7; ++i )
    {
        cout &lt;&lt; " " &lt;&lt; myints[i];
    }
    cout &lt;&lt; endl;

    return 0;
}</pre>
<p>从上例中我们看出copy算法可以很简单地将一个容器里面的元素复制至另一个目标容器中，上例中代码特别要注意一点就是myvector.resize(7);这行代码，在这里一定要先为vector分配空间，否则程序会崩，这是初学者经常犯的一个错误。其实copy函数最大的威力是结合标准输入输出迭代器的时候，我们通过下面这个示例就可以看出它的威力了。</p>
<pre class="lang:default decode:true ">int main ()
{
     typedef vector&lt;int&gt; IntVector;
     typedef istream_iterator&lt;int&gt; IstreamItr;
     typedef ostream_iterator&lt;int&gt; OstreamItr;
     typedef back_insert_iterator&lt; IntVector &gt; BackInsItr;

     IntVector myvector;

     // 从标准输入设备读入整数
     // 直到输入的是非整型数据为止 请输入整数序列，按任意非数字键并回车结束输入
     cout &lt;&lt; "Please input element：" &lt;&lt; endl;
     copy(IstreamItr(cin), IstreamItr(), BackInsItr(myvector));

     //输出容器里的所有元素，元素之间用空格隔开
     cout &lt;&lt; "Output : " &lt;&lt; endl;
     copy(myvector.begin(), myvector.end(), OstreamItr(cout, " "));
     cout &lt;&lt; endl;

    return 0;
}</pre>
<p>copy_backward:</p>
<p>前文中展示了copy的魅力，现在我们来看一下它的孪生兄弟copy_backward，copy_backward算法与copy在行为方面相似，只不过它的复制过程与copy背道而驰，其复制过程是从最后的元素开始复制，直到首元素复制出来。也就是说，复制操作是从last-1开始，直到first结束。这些元素也被从后向前复制到目标容器中，从result-1开始，一直复制last-first个元素。举个简单的例子：已知vector {0, 1, 2, 3, 4, 5}，现我们需要把最后三个元素（3, 4, 5）复制到前面三个（0, 1, 2）位置中，那我们可以这样设置：将first设置值3的位置，将last设置为5的下一个位置，而result设置为3的位置，这样，就会先将值5复制到2的位置，然后4复制到1的位置，最后3复制到0的位置，得到我们所要的序列{3, 4, 5, 3, 4, 5}。下面我们来看一下copy_backward的函数原型：</p>
<p>函数原型：</p>
<pre class="lang:default decode:true ">template&lt;class BidirectionalIterator1, class BidirectionalIterator2&gt;
 BidirectionalIterator2 copy_backward ( BidirectionalIterator1 first,
                                        BidirectionalIterator1 last,
                                        BidirectionalIterator2 result)；</pre>
<p> 参数:</p>
<p>       first, last<br />
       指出被复制的元素的区间范围[first，last).<br />
       result<br />
       指出复制到目标区间的具体位置[result-(last-first),result)</p>
<p> 返回值：</p>
<p>        返回一个迭代器，指出已被复制元素区间的起始位置</p>
<p> 程序示例：</p>
<p>      先通过一个简单的示例来阐述copy_backward的使用方法，程序比较简单，代码中做了详细的说明，在此不再累赘。</p>
<pre>
int main()
{
    vector<int> myvector;
    vector<int>::iterator iter;

    //为容器myvector赋初始值:10 20 30 40 50
    for ( int i = 1; i <= 5; ++i )
    {
        myvector.push_back( i*10 );
    }

    //将myvector容器的大小增加3个单元
    myvector.resize( myvector.size()+3 );

    //将容器元素20、10拷贝到第八、第七个单元中：10 20 30 40 50 0 10 20
    //注意copy_backward是反向复制，先将20拷贝到第八个单元，再将10拷贝到第七个单元
    copy_backward( myvector.begin(), myvector.begin()+2, myvector.end() );

    for ( iter = myvector.begin(); iter != myvector.end(); ++iter )
    {
        cout << " " << *iter;
    }

    cout << endl;


    //清除myvector容器
    myvector.clear();

    //还原容器myvector的初始值:10 20 30 40 50
    for ( i = 1; i <= 5; ++i )
    {
        myvector.push_back( i*10 );
    }

    //将容器元素40、50覆盖10、20, 即：40 50 30 40 50：
    copy_backward( myvector.end()-2, myvector.end(), myvector.end()-3 );

    for ( iter = myvector.begin(); iter != myvector.end(); ++iter )
    {
        cout << " " << *iter;
    }

    cout << endl;
    return 0;
}
</int></int></pre>
<p>通过上例的简单介绍相信大家对copy_backward 的基本使用不再陌生了吧，^_^，下面我们结合前面所讲的for_search算法来巩固一下copy_backward的使用。</p>
<pre class="lang:default decode:true ">class output_element
{
public:
    //重载运算符()
    void operator() (string element)
    {
        cout &lt;&lt; element
             &lt;&lt; ( _line_cnt++ % 7 ? " " : "nt"); //格式化输出,即每7个换行和制表位
    }

    static void reset_line_cnt()
    {
        _line_cnt = 1;
    }

private:
    static int _line_cnt;

};

int output_element::_line_cnt = 1; //定义并初始静态数据成员

int main()
{
    string sa[] = {
        "The", "light", "untonusred", "hair",
        "grained", "and", "hued", "like", "pale", "oak"
    };

    vector&lt;string&gt; svec(sa, sa+10);

    //还记得for_each吧，呵呵，这里用它来作为输出
    //for_each具体用法参考 http://blog.csdn.net/jerryjbiao/article/details/6827508
    cout &lt;&lt; "Original list of strings:nt";
    for_each( svec.begin(), svec.end(), output_element() );
    cout &lt;&lt; "n" &lt;&lt; endl;

    //将"The", "light", "untonusred", "hair","grained",
    //"and", "hued"后移三个单元覆盖了"like", "pale", "oak"
    copy_backward(svec.begin(), svec.end()-3, svec.end());

    output_element::reset_line_cnt();

    cout &lt;&lt; "sequence after "
         &lt;&lt; "copy_backward(svec.begin(), svec.end()-3, svec.end()): nt";
    for_each( svec.begin(), svec.end(), output_element() );
    cout &lt;&lt; "n" &lt;&lt; endl;

    return 0;
}</pre>
<p>find_end:</p>
<p>C++STL的非变易算法（Non-mutating algorithms）是一组不破坏操作数据的模板函数，用来对序列数据进行逐个处理、元素查找、子序列搜索、统计和匹配。<br />
       find_end算法在一个序列中搜索出最后一个与另一序列匹配的子序列。有如下两个函数原型，在迭代器区间[first1, last1)中搜索出与迭代器区间[first2, last2)元素匹配的子序列，返回首元素的迭代器或last1。</p>
<p>       函数原型：</p>
<pre class="lang:default decode:true ">template&lt;class ForwardIterator1, class ForwardIterator2&gt;
   ForwardIterator1 find_end(
      ForwardIterator1 _First1,
      ForwardIterator1 _Last1,
      ForwardIterator2 _First2,
      ForwardIterator2 _Last2
   );
template&lt;class ForwardIterator1, class ForwardIterator2, class Pr&gt;
   ForwardIterator1 find_end(
      ForwardIterator1 _First1,
      ForwardIterator1 _Last1,
      ForwardIterator2 _First2,
      ForwardIterator2 _Last2,
      BinaryPredicate _Comp
   );  </pre>
<p>示例程序：</p>
<pre class="lang:default decode:true ">int main()
{
    vector&lt;int&gt; v1;
    v1.push_back(5);
    v1.push_back(-2);
    v1.push_back(4);
    v1.push_back(3);
    v1.push_back(-2);
    v1.push_back(4);
    v1.push_back(8);
    v1.push_back(-2);
    v1.push_back(4);
    v1.push_back(9);

    vector&lt;int&gt;::const_iterator iter;
    cout &lt;&lt; "v1: " ;
    for (iter = v1.begin(); iter != v1.end(); ++iter)
    {
        cout &lt;&lt; *iter &lt;&lt; "  ";
    }
    cout &lt;&lt; endl;

    vector&lt;int&gt; v2;
    v2.push_back(-2);
    v2.push_back(4);

    cout &lt;&lt; "v2: " ;
    for (iter = v2.begin(); iter != v2.end(); ++iter)
    {
        cout &lt;&lt; *iter &lt;&lt; "  ";
    }
    cout &lt;&lt; endl;

    vector&lt;int&gt;::iterator iLoaction;
    iLoaction = find_end(v1.begin(), v1.end(), v2.begin(), v2.end());

    if (iLoaction != v1.end())
    {
        cout &lt;&lt; "v1中找到最后一个匹配V2的子序列，起始位置在："
             &lt;&lt; "v1[" &lt;&lt; iLoaction - v1.begin() &lt;&lt; "]" &lt;&lt; endl;
    }

    return 0;
}</pre>
<p>search_n:</p>
<p> C++STL的非变易算法（Non-mutating algorithms）是一组不破坏操作数据的模板函数，用来对序列数据进行逐个处理、元素查找、子序列搜索、统计和匹配。</p>
<p>      重复元素子序列搜索search_n算法：搜索序列中是否有一系列元素值均为某个给定值的子序列，它有如下两个函数原型，分别在迭代器区间[first, last)上搜索是否有count个连续元素，其值均等于value（或者满足谓词判断binary_pred的条件），返回子序列首元素的迭代器，或last以表示没有重复元素的子序列。</p>
<p>     函数原型：</p>
<pre class="lang:default decode:true ">template&lt;class ForwardIterator1, class Diff2, class Type&gt;
   ForwardIterator1 search_n(
      ForwardIterator1 _First1,
      ForwardIterator1 _Last1,
      Size2 _Count,
      const Type&amp; _Val
   );
template&lt;class ForwardIterator1, class Size2, class Type, class BinaryPredicate&gt;
   ForwardIterator1 search_n(
      ForwardIterator1 _First1,
      ForwardIterator1 _Last1,
      Size2 _Count,
      const Type&amp; _Val,
      BinaryPredicate _Comp
   );</pre>
<p> 示例程序：</p>
<p>     搜索向量容器ivect = {1,8,8,8,4,,4,3}中有三个连续元素为8，没有四个连续元素8，以及有三个连续元素的两倍为16.</p>
<pre class="lang:default decode:true ">bool twice(const int para1, const int para2)
{
    return 2 * para1 == para2;
}

using namespace std;

int main()
{
    vector&lt;int&gt; ivect;
    ivect.push_back(1);
    ivect.push_back(8);
    ivect.push_back(8);
    ivect.push_back(8);
    ivect.push_back(4);
    ivect.push_back(4);
    ivect.push_back(3);

    vector&lt;int&gt;::iterator iLocation;
    iLocation = search_n(ivect.begin(), ivect.end(), 3, 8);
    if (iLocation != ivect.end())
    {
        cout &lt;&lt; "在ivect中找到3个连续的元素8" &lt;&lt; endl;
    }
    else
    {
        cout &lt;&lt; "在ivect中没有3个连续的元素8" &lt;&lt; endl;
    }

    iLocation = search_n(ivect.begin(), ivect.end(), 4, 8);
    if (iLocation != ivect.end())
    {
        cout &lt;&lt; "在ivect中找到4个连续的元素8" &lt;&lt; endl;
    }
    else
    {
        cout &lt;&lt; "在ivect中没有4个连续的元素8" &lt;&lt; endl;
    }

    iLocation = search_n(ivect.begin(), ivect.end(), 2, 4);
    if (iLocation != ivect.end())
    {
        cout &lt;&lt; "在ivect中找到2个连续的元素4" &lt;&lt; endl;
    }
    else
    {
        cout &lt;&lt; "在ivect中没有2个连续的元素4" &lt;&lt; endl;
    }

    iLocation = search_n(ivect.begin(), ivect.end(), 3, 16, twice);
    if (iLocation != ivect.end())
    {
        cout &lt;&lt; "在ivect中找到3个连续元素的两倍为16" &lt;&lt; endl;
    }
    else
    {
        cout &lt;&lt; "在ivect中没有3个连续元素的两倍为16" &lt;&lt; endl;
    }
    return 0;
}</pre>
<p>search:</p>
<p>  C++STL的非变易算法（Non-mutating algorithms）是一组不破坏操作数据的模板函数，用来对序列数据进行逐个处理、元素查找、子序列搜索、统计和匹配。</p>
<p>      search算法函数在一个序列中搜索与另一序列匹配的子序列。它有如下两个原型，在迭代器区间[first1, last1)上找迭代器区间[first2, last2)完全匹配（或者满足二元谓词binary_pred）子序列，返回子序列的首个元素在[first1, last1)区间的迭代器值，或返回last1表示没有匹配的子序列。</p>
<p>     函数原型：</p>
<pre class="lang:default decode:true ">template&lt;class ForwardIterator1, class ForwardIterator2&gt;
   ForwardIterator1 search(
      ForwardIterator1 _First1,
      ForwardIterator1 _Last1,
      ForwardIterator2 _First2,
      ForwardIterator2 _Last2
   );
template&lt;class ForwardIterator1, class ForwardIterator2, class Pr&gt;
   ForwardIterator1 search(
      ForwardIterator1 _First1,
      ForwardIterator1 _Last1,
      ForwardIterator2 _First2,
      ForwardIterator2 _Last2
      BinaryPredicate _Comp
   ); </pre>
<p>  示例程序：</p>
<p>     在vector向量容器v1 = {5， 8， 1 ， 4}中搜索是否包含子序列容器向量V2 = {8， 1}，打印搜索结果“v2的元素包含在v1中，起始元素为：v1[1] ”</p>
<pre class="lang:default decode:true ">int main()
{
    vector&lt;int&gt; v1;
    v1.push_back(5);
    v1.push_back(8);
    v1.push_back(1);
    v1.push_back(4);

    vector&lt;int&gt; v2;
    v2.push_back(8);
    v2.push_back(1);

    vector&lt;int&gt;::iterator iterLocation;
    iterLocation = search(v1.begin(), v1.end(), v2.begin(), v2.end());

    if (iterLocation != v1.end())
    {
        cout &lt;&lt; "v2的元素包含在v1容器中，起始元素为"
             &lt;&lt; "v1[" &lt;&lt; iterLocation - v1.begin() &lt;&lt; "]" &lt;&lt;endl;
    }
    else
    {
        cout &lt;&lt; "v2的元素不包含在v1容器" &lt;&lt; endl;
    }
    return 0;
}</pre>
<p>equal:</p>
<p>   C++STL的非变易算法（Non-mutating algorithms）是一组不破坏操作数据的模板函数，用来对序列数据进行逐个处理、元素查找、子序列搜索、统计和匹配。</p>
<p>    equal算法类似于mismatch，equal算法也是逐一比较两个序列的元素是否相等，只是equal函数的返回值为bool值true/false，不是返回迭代器值。它有如下两个原型，如果迭代器区间[first1，last1)和迭代器区间[first2， first2+(last1 - first1))上的元素相等（或者满足二元谓词判断条件binary_pred） ，返回true，否则返回false。</p>
<p>      函数原型：</p>
<pre>
template<class InputIterator1, class InputIterator2>
   bool equal(
      InputIterator1 _First1,
      InputIterator1 _Last1,
      InputIterator2 _First2
      );
template<class InputIterator1, class InputIterator2, class BinaryPredicate>
   bool equal(
      InputIterator1 _First1,
      InputIterator1 _Last1,
      InputIterator2 _First2,
      BinaryPredicate _Comp
      );
</pre>
<p>  示例程序：</p>
<p>     利用二元谓词判断条件absEqual，判断出两个vector向量容器的元素均绝对值相等。</p>
<pre>
bool absEqual(int a, int b)
{
    return (a == abs(b) || b == abs(a)) ? true : false;
}

int main()
{
    vector<int> ivect1(5);
    vector<int> ivect2(5);

    for (vector<int>::size_type i = 0; i < ivect1.size(); ++i)
    {
        ivect1[i] = i;
        ivect2[i] = (-1) * i;
    }
    if ( equal( ivect1.begin(), ivect1.end(), ivect2.begin(), absEqual ) )
    {
        cout << "ivect1 和 ivect2 元素的绝对值完全相等" << endl;
    }
    else
    {
        cout << "ivect1 和 ivect2 元素的绝对值不完全相等" << endl;
    }
    return 0;
}</int></int></int></pre>
<p>mismatch:</p>
<p>C++STL的非变易算法（Non-mutating algorithms）是一组不破坏操作数据的模板函数，用来对序列数据进行逐个处理、元素查找、子序列搜索、统计和匹配。<br />
     mismatch算法是比较两个序列，找出首个不匹配元素的位置。它有如下两个函数原型，找出迭代器区间[first1, last1) 上第一个元素 *i ， 它和迭代器区间[first2, first2 + (last1 - first1))上的元素* (first2 + (i - first1))不相等（或者不满足二元谓词binary_pred条件）。通过匹配对象pair返回这两个元素的迭代器，指示不匹配元素位置。</p>
<p>     函数原型：</p>
<pre>
template<class InputIterator1, class InputIterator2>
   pair<inputIterator1, InputIterator2> mismatch(
      InputIterator1 _First1,
      InputIterator1 _Last1,
      InputIterator2 _First2
    );
template<class InputIterator1, class InputIterator2, class BinaryPredicate>
   pair<inputIterator1, InputIterator2> mismatch(
      InputIterator1 _First1,
      InputIterator1 _Last1,
      InputIterator2 _First2
      BinaryPredicate _Comp
   );
</pre>
<p>示例代码：</p>
<pre>
bool strEqual(const char* s1, const char* s2)
{
    return strcmp(s1, s2) == 0 ? true : false;
}

typedef vector<int>::iterator ivecIter;

int main()
{
    vector<int> ivec1, ivec2;
    ivec1.push_back(2);
    ivec1.push_back(0);
    ivec1.push_back(1);
    ivec1.push_back(4);

    ivec2.push_back(2);
    ivec2.push_back(0);
    ivec2.push_back(1);
    ivec2.push_back(7);

    pair<ivecIter, ivecIter> retCode;
    retCode = mismatch(ivec1.begin(), ivec1.end(), ivec2.begin());
    if (retCode.first == ivec1.end() && retCode.second == ivec2.end() /* ivec2.begin() */)
    {
        cout << "ivec1 和 ivec2完全相同" << endl;
    }
    else
    {
        cout << "ivec1 和 ivec2 不相同，不匹配的元素为：n"
             << *retCode.first << endl
             << *retCode.second << endl;
    }


    char* str1[] = {"appple", "pear", "watermelon", "banana", "grape"};
    char* str2[] = {"appple", "pears", "watermelons", "banana", "grape"};

    pair<char**, char**> retCode2 = mismatch(str1, str1+5, str2, strEqual);
    if (retCode2.first == str1+5 && retCode2.second == str2+5)
    {
        cout << "str1 和 str2 完全相同" << endl;
    }
    else
    {
        cout << "str1 和 str2  不相同，不匹配的字符串为：" << endl
             << str1[retCode2.first - str1] << endl
             << str2[retCode2.second - str2] << endl;
    }


    return 0;
}</int></int></pre>
<p>count_if:</p>
<p>C++STL的非变易算法（Non-mutating algorithms）是一组不破坏操作数据的模板函数，用来对序列数据进行逐个处理、元素查找、子序列搜索、统计和匹配。</p>
<p>     count_if算法是使用谓词判断pred统计迭代器区间[first , last) 上满足条件的元素个数n，按计数n是否引用返回，有如下两种函数原型：</p>
<p>函数原型：</p>
<pre>
template<class InputIterator, class Predicate>
   typename iterator_traits<inputiterator>::difference_type count_if(
      InputIterator _First,
      InputIterator _Last,
      Predicate _Pred
   );
template<class InputIterator, class T> inline
   size_t count(
      InputIterator First,
      InputIterator Last,
      const T& Value
   ) </inputiterator></pre>
<pre>
//学生记录结构体
struct stuRecord{

    struct stuInfo{
        char* name;
        int year;
        char* addr;
    };

    int id;     //学号
    stuInfo m_stuInfo;  //学生信息
    stuRecord(int m_id, char* m_name, int m_year, char* m_addr)
    {
        id = m_id;
        m_stuInfo.name = m_name;
        m_stuInfo.year = m_year;
        m_stuInfo.addr = m_addr;
    }
};

typedef stuRecord::stuInfo stuRI;

bool setRange( pair<int, stuRI> s )
{
    if (s.second.year > 20 && s.second.year < 30)
    {
        return true;
    }
    return false;
}

int main()
{
    //学生数据
    stuRecord stu1 = stuRecord(1, "张三", 21, "北京");
    stuRecord stu2 = stuRecord(2, "李四", 29, "上海");
    stuRecord stu3 = stuRecord(3, "王五", 12, "深圳");
    stuRecord stu4 = stuRecord(4, "赵六", 25, "长沙");
    stuRecord stu5 = stuRecord(5, "孙七", 30, "广东");

    //插入学生记录
    map<int, stuRI> m;
    m.insert(make_pair(stu1.id, stu1.m_stuInfo));
    m.insert(make_pair(stu2.id, stu2.m_stuInfo));
    m.insert(make_pair(stu3.id, stu3.m_stuInfo));
    m.insert(make_pair(stu4.id, stu4.m_stuInfo));
    m.insert(make_pair(stu5.id, stu5.m_stuInfo));

    //条件统计
    int num = count_if(m.begin(), m.end(), setRange);

    cout << "学生中年龄介于20至30之间的学生人数为:"
         << num << endl;

    return 0;
}
</pre>
<p>  C++STL的非变易算法（Non-mutating algorithms）是一组不破坏操作数据的模板函数，用来对序列数据进行逐个处理、元素查找、子序列搜索、统计和匹配。</p>
<p>    count算法用于计算容器中的某个给定值的出现次数。它有两个使用原型，均计算迭代器区间[first, last)上等于value值的元素个数n，区别在于计数n是直接返回还是引用返回。</p>
<p>    函数原型：</p>
<pre>
template<class InputIterator, class Type>
   typename iterator_traits<inputiterator>::difference_type count(
      InputIterator _First,
      InputIterator _Last,
      const Type& _Val
   );
template<class InputIterator, class T> inline
   size_t count(
      InputIterator First,
      InputIterator Last,
      const T& Value
   )</inputiterator></pre>
<p>示例代码：</p>
<pre>
int main()
{
    list<int> ilist;
    for (list<int>::size_type index = 0; index < 100; ++index)
    {
        ilist.push_back( index % 20 );
    }

    list<int>::difference_type num = 0;
    int value = 9;
    num = count(ilist.begin(), ilist.end(), value);

    cout << "链表中元素等于value的元素的个数："
             << num << endl;

    vector<string> vecString;
    vecString.push_back("this");
    vecString.push_back("is");
    vecString.push_back("a");
    vecString.push_back("test");
    vecString.push_back("program");
    vecString.push_back("is");

    string valString("is");

    ptrdiff_t result = count(vecString.begin(), vecString.end(), valString);

    cout << "容器中元素为is的元素个数："
         << result << endl;

    return 0;
}</string></int></int></int></pre>
<p>find_first_of:</p>
<p> C++STL的非变易算法（Non-mutating algorithms）是一组不破坏操作数据的模板函数，用来对序列数据进行逐个处理、元素查找、子序列搜索、统计和匹配。</p>
<p>        find_first_of算法用于查找位于某个范围之内的元素。它有两个使用原型，均在迭代器区间[first1, last1)上查找元素*i，使得迭代器区间[first2, last2)有某个元素*j，满足*i ==*j或满足二元谓词函数comp(*i, *j)==true的条件。元素找到则返回迭代器i，否则返回last1。</p>
<p>函数原型：</p>
<pre>
template<class ForwardIterator1, class ForwardIterator2>
   ForwardIterator1 find_first_of(
      ForwardIterator1 _First1,
      ForwardIterator1 _Last1,
      ForwardIterator2 _First2,
      ForwardIterator2 _Last2
   );
template<class ForwardIterator1, class ForwardIterator2, class BinaryPredicate>
   ForwardIterator1 find_first_of(
      ForwardIterator1 _First1,
      ForwardIterator1 _Last1,
      ForwardIterator2 _First2,
      ForwardIterator2 _Last2,
      BinaryPredicate _Comp
   );</pre>
<p>示例代码：</p>
<pre>
int main()
{
    const char* strOne = "abcdef1212daxs";
    const char* strTwo = "2ef";

    const char* result = find_first_of(strOne, strOne + strlen(strOne),
                                 strTwo, strTwo + strlen(strTwo));

    cout << "字符串strOne中第一个出现在strTwo的字符为："
         << *result << endl;

    return 0;
}</pre>
<p>adjacent_find:</p>
<p> C++STL的非变易算法（Non-mutating algorithms）是一组不破坏操作数据的模板函数，用来对序列数据进行逐个处理、元素查找、子序列搜索、统计和匹配。</p>
<p>      adjacent_find算法用于查找相等或满足条件的邻近元素对。其有两种函数原型：一种在迭代器区间[first , last)上查找两个连续的元素相等时，返回元素对中第一个元素的迭代器位置。另一种是使用二元谓词判断binary_pred，查找迭代器区间[first , last)上满足binary_pred条件的邻近元素对，未找到则返回last。</p>
<p>      函数原型：</p>
<pre>template<class forwarditerator>
   ForwardIterator adjacent_find(
      ForwardIterator _First,
      ForwardIterator _Last
      );
template<class ForwardIterator , class BinaryPredicate>
   ForwardIterator adjacent_find(
      ForwardIterator _First,
      ForwardIterator _Last,
            BinaryPredicate _Comp
   ); </class></pre>
<p> 示例代码：</p>
<pre>
//判断X和y是否奇偶同性
bool parity_equal(int x, int y)
{
    return (x - y) % 2 == 0 ? 1 : 0;
}

int main()
{
    //初始化链表
    list<int> iList;
    iList.push_back(3);
    iList.push_back(6);
    iList.push_back(9);
    iList.push_back(11);
    iList.push_back(11);
    iList.push_back(18);
    iList.push_back(20);
    iList.push_back(20);

    //输出链表
    list<int>::iterator iter;
    for(iter = iList.begin(); iter != iList.end(); ++iter)
    {
        cout << *iter << "  ";
    }
    cout << endl;

    //查找邻接相等的元素
    list<int>::iterator iResult = adjacent_find(iList.begin(), iList.end());
    if (iResult != iList.end())
    {
        cout << "链表中第一对相等的邻近元素为：" << endl;
        cout << *iResult++ << endl;
        cout << *iResult << endl;
    }

    //查找奇偶性相同的邻近元素
    iResult = adjacent_find(iList.begin(), iList.end(), parity_equal);
    if (iResult != iList.end())
    {
        cout << "链表中第一对奇偶相同的元素为：" << endl;
        cout << *iResult++ << endl;
        cout << *iResult << endl;
    }
    return 0;
}</int></int></int></pre>
<p>find_if:</p>
<p> C++STL的非变易算法（Non-mutating algorithms）是一组不破坏操作数据的模板函数，用来对序列数据进行逐个处理、元素查找、子序列搜索、统计和匹配。</p>
<p>     find_if算法 是find的一个谓词判断版本，它利用返回布尔值的谓词判断pred，检查迭代器区间[first, last)上的每一个元素，如果迭代器iter满足pred(*iter) == true，表示找到元素并返回迭代器值iter；未找到元素，则返回last。</p>
<p>    函数原型：</p>
<pre>
template<class InputIterator, class Predicate>
   InputIterator find_if(
      InputIterator _First,
      InputIterator _Last,
      Predicate _Pred
   );  </pre>
<p> 示例代码：</p>
<pre>
//谓词判断函数 divbyfive : 判断x是否能5整除
bool divbyfive(int x)
{
    return x % 5 ? 0 : 1;
}

int main()
{
    //初始vector
    vector<int> iVect(20);
    for(size_t i = 0; i < iVect.size(); ++i)
    {
        iVect[i] = (i+1) * (i+3);
    }

    vector<int>::iterator iLocation;
    iLocation = find_if(iVect.begin(), iVect.end(), divbyfive);

    if (iLocation != iVect.end())
    {
        cout << "第一个能被5整除的元素为："
             << *iLocation << endl                  //打印元素：15
             << "元素的索引位置为："
             << iLocation - iVect.begin() << endl;  //打印索引位置：2
    }

    return 0;
}</int></int></pre>
<p>C++STL的非变易算法（Non-mutating algorithms）是一组不破坏操作数据的模板函数，用来对序列数据进行逐个处理、元素查找、子序列搜索、统计和匹配。</p>
<p>     find算法用于查找等于某值的元素。它在迭代器区间[first , last)上查找等于value值的元素，如果迭代器iter所指的元素满足 *iter == value ，则返回迭代器iter，未找则返回last。</p>
<p>函数原型：</p>
<pre>
template<class InputIterator, class Type>
   InputIterator find(
      InputIterator _First,
      InputIterator _Last,
      const Type& _Val
   );  </pre>
<p>示例代码：</p>
<pre>
int main()
{
    list<int> ilist;
    for (size_t i = 0; i < 10; ++i)
    {
        ilist.push_back(i+1);
    }

    ilist.push_back(10);

    list<int>::iterator iLocation = find(ilist.begin(), ilist.end(), 10);

    if (iLocation != ilist.end())
    {
        cout << "找到元素 10" << endl;
    }

    cout << "前一个元素为：" << *(--iLocation) << endl;

    return 0;
}</int></int></pre>
<p> C++STL的非变易算法（Non-mutating algorithms）是一组不破坏操作数据的模板函数，用来对序列数据进行逐个处理、元素查找、子序列搜索、统计和匹配。</p>
<p>     for_each用于逐个遍历容器元素，它对迭代器区间[first，last)所指的每一个元素，执行由单参数函数对象f所定义的操作。</p>
<p>     原型：</p>
<pre>
template<class InputIterator, class Function>
   Function for_each(
      InputIterator _First,
      InputIterator _Last,
      Function _Func
      );</pre>
<p>   说明：<br />
        for_each 算法范围 [first, last) 中的每个元素调用函数 F，并返回输入的参数 f。此函数不会修改序列中的任何元素。</p>
<p>    示例代码：</p>
<pre>
//print为仿函数
struct print{
    int count;
    print(){count = 0;}
    void operator()(int x)
    {
        cout << x << endl;
        ++count;
    }
};

int main(void)
{
    list<int> ilist;
    //初始化
    for ( size_t i = 1; i < 10; ++i)
    {
        ilist.push_back(i);
    }
    //遍历ilist元素并打印
    print p = for_each(ilist.begin(), ilist.end(), print());
    //打印ilist元素个数
    cout << p.count << endl;

    return 0;
}</int></pre>
<p>示例说明：</p>
<p>    仿函数，又或叫做函数对象，是STL（标准模板库）六大组件（容器、配置器、迭代器、算法、配接器、仿函数）之一；仿函数虽然小，但却极大的拓展了算法的功能，几乎所有的算法都有仿函数版本。例如，查找算法find_if就是对find算法的扩展，标准的查找是两个元素向等就找到了，但是什么是相等在不同情况下却需要不同的定义，如地址相等，地址和邮编都相等，虽然这些相等的定义在变，但算法本身却不需要改变，这都多亏了仿函数。 仿函数之所以叫做函数对象，是因为仿函数都是定义了()函数运算操作符的类。</p>
<p>仿函数相关参考文章：</p>
<p>1、仿函数使用要领</p>
<p>2、何为仿函数</p>
<p>3、C++ 仿函数(functor)</p>
