---
layout: post
title: The Bourne-Again Shell
date: 2014-05-05 23:31:12.000000000 +08:00
type: post
published: true
status: publish
categories:
- Architecture
tags:
- bash
- shell
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---
<p style="text-align: right;">英文作者：<a href="http://www.aosabook.org/en/intro1.html#ramey-chet">Chet Ramey</a></p>
<p style="text-align: right;">原文链接：<a href="http://www.aosabook.org/en/bash.html">The Bourne-Again Shell</a></p>
<h2>3.1. 介绍</h2>
<p>一个 Unix shell 提供了一个用户通过运行命令来和系统交互的接口。但是一个 shell 也是一门相当丰富的编程语言：具有流程控制、修改、循环、条件、基本的数学操作，命名函数、字符串变量和 shell 与它运行的命令之间的双向通信。</p>
<p>shells 可以交互使用，从终端或者终端模拟器例如xterm，也可以非交互使用，从文件中读取命令。大多数现代shells, 包括 bash, 提供命令行编辑 command-line editing, 使得命令行输入的时候可以使用类似 emacs 或者 vi 的命令进行编译，具有不同的命令历史记录。</p>
<p>bash 处理更像一个shell管道：在从终端或者脚本中读取之后，数据被传送经过一系列阶段，在每一个阶段中进行变换，直到shell最终执行一个命令并手机它的返回状态。<br />
<!--more--><br />
这一章将会从管道的视角介绍bash的主要组件：输入处理、解析、字展开和其他命令处理以及命令的执行。这些组件作为管道供数据从键盘或文件读入，并送到一个执行的命令。</p>
<p>[caption id="attachment_1351" align="aligncenter" width="569"]<a href="https://blog-oxnz.rhcloud.com/wp-content/uploads/2014/05/bash-article-diagram.png"><img class="size-full wp-image-1351" src="{{ site.baseurl }}/assets/bash-article-diagram.png" alt="图 3.1: Bash 组件架构" width="569" height="453" /></a> 图 3.1: Bash 组件架构[/caption]</p>
<h3>3.1.1. Bash</h3>
<p>bash 是 GNU 操作系统中出现的shell, 通常在Linux 内核之上实现。同时也出现在一些其他操作系统中供，例如 Mac OS X。它提供了相比历史版本sh功能提升，无论是在交互还是编程使用方面。</p>
<p>bash 的名字是 Bourne-Again SHell 的首字母缩写, 一个结合了 Stephen Bourne (目前 Unix shell /bin/sh 的直接祖先的作者, 曾经在 Bell Labs Seventh Edition Research version of Unix 供职过) 名字和通过重新实现而重生的概念的双关语。bash 的原作者是 Brian Fox, Free Software Foundation 的一名员工。 我是目前的开发者和维护者，一名在 Ohio 的 Case Western Reserve 大学的志愿者。</p>
<p>如同其他 GNU 软件一样，bash 具有很高的可移植性。它目前可以运行在几乎所有的Unix版本上，以及一些其他操作系统独立的移植在Windows 环境中，例如Cygwin和MinGW，移植到类Unix系统例如QNX和Minix。它只需要一个Posix环境来编译和运行，例如Microsoft提供的Services for Unix (SFU)。</p>
<h2>3.2. 语法单元和primitives</h2>
<h3>primitives</h3>
<p>对bash而言, 有三种类型的关键字: 保留字、字和操作符。保留字是那些对shell和它的编程语言有意义的字；通常这些字中包含流程控制，例如<code>if</code>和<code>while</code>。操作符由单个或多个字符组成：滋生对shell具有特殊含义的字符集，例如 <code>|</code> 和 <code>&gt;</code>。剩下的shell输入由普通单词或数字组成，单词中的一些具有特殊的意义赋值声明，例如－取决于它们出现在命令行的什么地方。</p>
<h3>3.2.2. 变量和参数</h3>
<p>如同其他编程语言, shells 提供变量: 使用名称存储数据并施加操作于其上。shell 提供了基本的用户可设置的变量和一些内建的变量引用作为参数。shell参数通常反映了shell内部状态的一些方面，并且自动设置或者作为其他操作的附带效果。</p>
<p>变量值是字符串。一些值根据上下文而不同对待；这将会在后面介绍。变量使用<code>name=value</code>的形式声明赋值。值是可选的；如果省略它将会把空串赋值给<code>name</code>。shell可以根据一个变量是否被赋值执行不同的操作，但是赋值是设置变量的唯一途径。没有被赋值的变量，即使被声明过并且给过属性，仍然被当作未设置。</p>
<p>以美元符号开头的单词引入了一个变量或者参数引用。单词，包含美元符号，被命名变量的值取代。shell提供了丰富的扩展操作符集合，从简单的值替换到改变或者移除一个变量值满足一个模式的部分。</p>
<p>变量有全局和局部之分。默认的，所有变量是全局的。任何简单命令 (the most familiar type of command—a command name and optional set of arguments and redirections) 可以通过在头部添加一个赋值声明集合来使得那些变量只为那条命令存在。shell实现了存储过程，或者shell函数，可以具有函数局部变量。</p>
<p>变量可以最简化输入：至于简单的字符串值变量，还有整数和数组。整数类型变量被当作数字：任何赋值给它们的字符串被展开为一个算术表达式，并且把结果赋值给变量值。数组可以是索引的或者关联的；索引数组使用数字作为下标，关联数组使用任意字符串。数组元素是字符串，如果有必要，可以看成是数字。数组元素不可以是其他数组。</p>
<p>Bash 使用hash表来存取shell变量，并使用这些hash表的链表来实现变量区间(variable scoping)。shell函数具有不同的变量区间，临时区间给前一个命令通过设置赋值。当一个命令之前的那些赋值声明内建进shell，例如，shell保持记录正确的顺序来解决变量引用，链接的区间允许bash来这样做。可以具有数量惊人的区间来追踪决定执行的嵌套层数。</p>
<h3>3.2.3. Shell 编程语言</h3>
<p>一条大多数读者最熟悉的shell命令，包含了命令名，例如<code>echo</code>或者<code>cd</code>，和一个包含0个或者多个参数和重定向的列表。重定向允许shell用户通过调用命令来控制输入和输出。正如上面提到的，用户可以定义局部于简单命令的变量。</p>
<p>保留字引入了复杂的shell命令。其中有类似于高级语言中的指令，例如 <code>if-then-else</code>, <code>while</code>, 遍历值列表的 <code>for</code> 循环和一个类似C算数的<code>for</code>循环。 这些复杂命令使得shell可以执行一个命令或者否则测试一个条件并基于结果执行不同的操作，或者多次执行一条命令。</p>
<p>Unix带到计算机世界中的礼物就是管道：一个命令组成的线性表，其中一条命令的输出作为后继命令的输入。任何shell指令可以在管道中使用，管道命令产生数据到一个循环并非罕见。</p>
<p>bash 实现了一种机制，这种机制可以允许一条命令执行时的标准输入，标准输出和标准错误流被重定向到另外一个文件或者进程。shell程序员也可以使用重定向在当前shell环境中打开和关闭文件。</p>
<p>bash允许shell程序存储起来多次使用。shell函数和shell脚本时两种把一组命令进行命名和执行的方法，就好像执行其他命令一样。shell函数使用一种特殊的语法进行声明，并在同一个上下文中存储和执行；shell脚本通过把命令放进文件并执行一个新的shell实例(instance)来解释执行。shell函数和调用它的shell共享大多数执行上下文，但是shell脚本，由于它们被一个新的shell进行解释，所以只共享通过环境传递的东西。</p>
<h3>3.2.4. 进一步注意(A Further Note)</h3>
<p>随着你读的更多，需要记在心里的时shell只通过很少的数据结构它的特：数组、树、单链表、双链表和hash表。几乎所有shell指令都是用这些primitives来实现的。</p>
<p>shell用来从一个阶段(stage)产地信息给下一个并在每一个处理阶段对数据单元进行操作的基本数据结构是 <code>WORD_DESC</code>:</p>
<pre class="lang:default decode:true">typedef struct word_desc {
  char *word;           /* Zero terminated string. */
  int flags;            /* Flags associated with this word. */
} WORD_DESC;</pre>
<p>使用单链表把单词组成了参数列表：</p>
<pre class="lang:default decode:true">typedef struct word_list {
  struct word_list *next;
  WORD_DESC *word;
} WORD_LIST;</pre>
<p>shell中<code>WORD_LIST</code>s 是非常普遍的。一条简单的命令就是一个单词链表(word list)，展开(expansion)的结果也是一个单词链表，每个内建命令都有一个参数构成的单词链表。</p>
<h2>3.3. 输入处理</h2>
<p>bash 处理管道的第一步就是输入处理：从终端或者文件取字符，然后把它们拆分成行，传递行给shell 解析器(parser)来转换成命令。如你所料，这些行是以新行结尾的字符序列。</p>
<h3>3.3.1. Readline and Command Line Editing</h3>
<p>bash 交互时候从终端读取输入，否则从脚本读取输入。当交互时，bash允许用户在输入时编辑命令行，使用类似Unix emacs和vi编辑器键序列。</p>
<p>bash使用readline库来实现命令行编辑。提供了一组允许用户编辑命令行的函数，保存命令行的函数和调用历史命令的函数，并能进行类似csh的历史命令展开。bash时readline的基本客户，并且他们共同开发，但是readline的代码中并没有专为bash的代码。许多其他项目也采用readline来提供基于终端行编辑的接口。</p>
<p>readline允许用户绑定不限长度的键序列到大量的readline命令。readline具有在命令行移动光标的命令、插入和删除文本，获取历史行和补全不完整的键入单词。在这之上，用户可以定义宏，就是对应一个键序列插入一串字符，键绑定也使用相同的语法。宏提供给用户一个简单的方式来做字符串替换和速记方法。</p>
<h4>readline 结构</h4>
<p>readline 时一个基于 read/dispatch/execute/redisplay 循环的结构。它使用<code>read</code>或者类似的从键盘读取字符，或者从宏获取输入。每个字符被用作一个keymap或者dispatch表的索引值。虽然只被一个8位字符索引，但是keymap中的每一个元素内容可以时多种东西。这些字符可以被解析成额外的keymaps，这就是多字符键序列的原理。也可以被解析成一个readline命令，例如<code>beginning-of-line</code>，导致命令被执行。一个绑定到自插入(<code>self-insert</code>)的字符被存储到编辑缓冲区中。可以在绑定一个键序列到一个命令的同时，绑定到其他命令(最近新添加的一个特性)；keymap中特殊的索引表示已经完成。绑定键序列到宏提供了极高的可伸缩性，从插入任意字符串到命令行到创建键盘快捷键给复杂的编辑序列。readline把每个绑定到<code>self-insert</code>的字符存入编辑缓冲区中，当显示的时候会显示一到多行在屏幕上。</p>
<p>readline只使用C <code>char</code>s组成的字符串和字符串缓冲区，并在必要的时候使用他们来构造多字节字符。由于速度和存储的原因，内部并没有使用<code>wchar_t</code>，还有一个原因时编辑代码在多字节字符支持广为传播之前就存在了。当在多字节字符的环境中，readline自动读入整个多字节字符并插入到编辑缓冲区中。使用多字节字符绑定编辑命令也是可以的，但是必须先把多字节字符绑定为一个键序列；这是可以的，但是困难，而且通常并不是想要的。例如存在的emacs和vi命令集就不使用多字节字符。</p>
<p>一旦一个键序列最终解析到一条编辑命令，readline就更新终端显示以反映编辑结果。而不管命令的结果是插入到缓冲区、编辑位置移动、或者行被部分或全部替换。一些可绑定的编辑命令，例如修改历史文件，并不引起任何编辑缓冲区内容的改变。</p>
<p>更新终端显示，看起来简单，实则是非常困难的。readline必须追踪三样东西：当前显示在屏幕上的字符缓冲区内容、更新了的显示缓冲区内容和实际显示的字符。在多字节字符环境中，显示的字符并不同于缓冲区，所以redisplay引擎必须注意这一点。当重新显示的时候，readline必须对比当前显示缓冲区内容和更新了的缓冲区，找出差异，然后决定如何最高效率的修改显示以反映更新了的缓冲区。这个问题常年来一直是 considerable research 的主题(the string-to-string correction problem)。readline的方法是找出两个缓冲区不同的开始和结尾，计算只更新那个区间的话费，包括光标的前后移动(比如，是先删除后插入还是直接覆盖当前屏幕的内容效率高？)，然后执行花费最低的更新，然后如果有必要，通过移除行为的残留字符做清理，把光标放在正确的位置。</p>
<p>redisplay引擎无疑是readline中修改最多的代码了。大多数的修改都是最具功能性的，在prompt中的不显示字符(例如改变颜色)和处理占空间多余一个字节的字符。</p>
<p>readline把编辑缓冲区的内容返回给调用程序，调用程序负责保存可能更改过的结果到历史列表中。</p>
<h4>Applications Extending Readline</h4>
<p>犹如readline提供给用户多种多样的方法来个性化和扩展readline的默认行为，它也提供了多种机制给应用程序来扩展它的默认特性集。首先，可绑定的readline函数接受一个标准参数集并返回一个特定的结果集，使得应用程序是用特定与应用的函数来扩展readline。例如bash，添加了超过30个可绑定命令，从特定于bash的单词补全到shell的内建命令。</p>
<p>第二种readline允许应用修改它的行为的方法是通过普遍使用的钩子函数指针。应用程序可以替换一些readline内部的一部分，插入功能到readline，并执行特定应用的转换。</p>
<h3>3.3.2. 非交互输入处理</h3>
<p>当shell不使用readline的时候，它使用<code>stdio</code>或者它自己的缓冲输入程序来获取输入。当非交互时，相比<code>stdio</code>，bash更倾向于使用自己的缓冲输入包，原因是由于posix强加给输入的假设：shell必须只取走解析命令必须的字符并把剩余的留给执行了的程序。当shell从标准输入读一个脚本的时候显得尤为重要。shell可以缓冲它想要的字符，只要它能够回滚文件偏移到刚好parser消耗的字符之后。由于实际的原因，这意味着shell在读例如管道的non-seekable设备的时候每次只能读一个字符，但是在读取文件的饿时候可以缓冲任意多字符。</p>
<p>把这些放在一边，非交互输入的shell的输入处理如同readline:一个由新行字符结尾的字符缓冲区。</p>
<h3>3.3.3. 多字节字符</h3>
<p>多字节字符处理加到shell是在最初实现的很久之后，并且设计要把对已存在代码的影响减到最小。当在一个支持多字节字符的环境中，shell还是把输入存储到一个字节(C <code>char</code>s)缓冲区中，但是把这些字节当作潜在的多字节字符。<br />
readline知道如何显示这些多字节字符(关键是知道一个多字节字符占多少屏幕位置，和当显示一个字符到屏幕的时候知道从缓冲区取多少字节)，如何向前或者向后移动一个字符等等。除了那些，多字节字符并没有对shell输入处理有多大影响。稍后介绍的shell的其他部分，需要注意处理多字节字符的输入。</p>
<h2>3.4. 解析(Parsing)</h2>
<p>解析引擎最初的工作是词法分析：把输入流中的字符分割成为单词并对其施加含义。单词是解析器工作的基本单元。单词是由元字符分割的字符序列，元字符包含简单的分隔符例如空格和tabs，或者对shell语言具有特殊含义的字符，例如分号和&amp;。</p>
<p>shell的一个历史遗留问题是，正如Tom Duff在他的关于<code>rc</code>的论文中所言，the Plan 9 shell，没有人知道Bourne shell的语法。Posix shell委员会最值得赞赏，因为其最终发表了一个Unix shell的定义性的语法，虽然有很高的上下文依赖性。那个语法并非没有问题－它不允许一些历史上Bourne shell解析器接受的指令－但那已经是我们所有的最好的了。</p>
<p>bash解析器是从posix 语法早起的一个版本中衍生出来的，并且据我所致，Bourne风格的解析器使用Yacc或者Bison实现。这也呈现出了它自己的问题集合－shell语法并不适合yacc风格的解析，并且需要一些复杂的此法分析和需要解析器和词法分析器之间的合作。</p>
<p>无论如何，词法分析器从readline或者其他源头获取行输入，用元字符把行分成tokens，标识符和tokens是基于上下文的，并把他们传递给解析器来组成声明(statements)和命令。这里有许多上下文关联的实例(instance)，单词可以作为保留字、标识符、赋值语句的一部分或者其他单词，而剩下的是一个有效的命令，下面的命令结果是显示<code>for</code>：</p>
<pre class="lang:default decode:true">for for in for; do for=for; done; echo $for</pre>
<p>这种情况下，需要稍微离题说一下别名(aliasing)。bash允许一个简单命令的第一个单词被使用别名的任意字符串替换。由于这完全是词法上的，别名甚至可以被使用(或者滥用)来改变shell的语法：写一个别名来实现一个bash不提供的复杂命令是完全可行的。bash解析器完全在词法阶段实现别名，尽管解析器需要通知analyzer什么时候允许展开(expansion)。</p>
<p>如同许多其他编程语言，shell允许字符转义来移除它们的特殊含义，所以元字符例如<code>&amp;</code>可以出现在命令中。一共有三种形式的引用，每一种都有轻微的差别并允许略有差异的对引用文本的解释：反斜杠转义之后的下个字符；单引号阻止对其中的内容做解释；双引号，阻止一部分解释但是允许特定的单词展开(expansions)(并且处理反斜杠也不同)。词法分析器翻译引用文本并且阻止它们被解析器识别为保留字或者元字符。这里有两种特殊情况：<code>$'…'</code> 和 <code>$"…"</code>，这两种情况下解释反斜杠转移字符与ANSI C 字符串相同，并且各自允许使用国际化函数翻译字符。前者被广泛使用；后者或许是缺少好的例子或用例，就不如前者广泛了。</p>
<p>解析器和词法分析器之间剩下的接口就比较直白了。解析器对一些状态进行编码并与分析器(analyzer)共享来允许一些语法要求的上下文关联分析。例如，词法分析器根据 token 类型对单词进行分类：保留字(在适当的上下文)、单词、赋值声明等等。为此，解析器必须告诉它处理命令的进度，是否在处理一个多行字符串(有时候称作 "here-document")，是否是一个 case 语句或者条件命令、或者是否在处理一个 shell 扩展模式或者集体赋值(compound assignment statement)。</p>
<p>在解析阶段识别命令替换结束的大部分工作都封装进了一个函数(<code>parse_comsub</code>)，它理解许多令人不快的 shell 语法和最佳的 token-reading 代码的重复。这个函数必须知道 here 文档，shell 注释，元字符和单词边界，引用和什么时候保留字是可以接受的(所以他知道什么时候是一个 <code>case</code> 语句)；它需要一小会儿来做这些工作。</p>
<p>当在展开一个命令替换做单词展开的时候，bash 使用解析器来找到指令的正确结束位置。这类似于把一个字符串变成一个命令给 <code>eval</code>，但是这种情况下命令并不以字符串的结尾而结束。为了使这正常工作，解析器必须识别有效命令结尾的右括号。这导致了语法产生的许多特殊情况并且需要词法分析器来标识一个正确的括号(在正确的上下文中)作为EOF 指示。解析器也同样需要在递归调用 <code>yyparse</code> 之前保存和重置解析器状态，由于一个命令替换可以作为扩展提示符字符串的一部分，在读取一个命令的过程中被解析和执行。既然输入函数实现了预读取，这个函数就必须处理回滚 bash 输入指针到正确的位置，而不管 bash 是在从字符串、文件、或者是使用 readline 从终端读取输入。这不仅对保证不丢失输入重要，也对命令替换展开函数构造正确的执行字符串同等重要。</p>
<p>可编程命令补全也有类似的问题，在解析命令的时候允许任意命令被执行，并且同样被在调用前后保存和恢复解析器状态而得以解决。</p>
<p>引用也是一个不兼容和争论的源头。第一个 Posix shell 标准公布20年之后，the standards working group的成员依然在争论obscure quoting的适当行为。如前所述，Bourne shell 除了作为一个观察行为的引用实现之外毫无帮助。</p>
<p>解析器返回一个 C 结构体来代表一条命令(在组合命令中国，类似循环，返回中也可以包含其他命令)并把它传递给下一个阶段的 shell 操作：单词展开(word expansion)。命令结构体由命令对象和单词列表组成。单词列表中的大多数都要经过变换，正如下一节所述，取决于它们的上下文。</p>
<h2>3.5. 单词展开(Word Expansions)</h2>
<p>解析之后，但在执行之前，由解析阶段生成的许多单词都要进过一个或者多个的单词展开，所以(例如)<code>$OSTYPE</code>被字符串<code>"linux-gnu"</code>替换。</p>
<h3>3.5.1. 参数和变量展开(Parameter and Variable Expansions)</h3>
<p>变量展开式用户最熟悉的一类了。shell 变量除了少数例外，都被当做字符串。扩展把这些字符串展开和变换为新的单词和单词列表。</p>
<p>还有些展开式面向变量值自身。程序员可以使用这些来产生一个变量值得子字符串，值的长度，从头或尾移除满足特定模式的的部分，使用新字符串替换满足特定模式的部分值，或者修改变量值的字母大小写。</p>
<p>另外，还有一些展开基于变量的状态：different expansions or assignments happen based on whether or not the variable is set. 例如，<code>${parameter:-word}</code> 如果 <code>parameter</code> 设置了的话将会被展开到 <code>parameter</code>, 否则到 <code>word</code> 或者空串。</p>
<h3>3.5.2. 更多</h3>
<p>bash 做很多类型的展开，每一种都有自己奇怪的规则。处理顺序中第一个是花括号展开，如下：</p>
<pre class="lang:default decode:true">pre{one,two,three}post</pre>
<p>到:</p>
<pre class="lang:default decode:true">preonepost pretwopost prethreepost</pre>
<p>还有命令替换，是一个 shell 的执行命令的能力和操纵变量的能力的漂亮合并。shell 执行一个命令，收集输出，并当做展开的值。</p>
<p>命令替换的问题之一是它立刻执行这个命令并且等到结束：没有容易的方式可以让 shell 发送输入给它。bash 使用了一个称作 process substitution 的特性, 一系列的命令替换组合和 shell 管道，来补偿这些缺点。例如命令替换，bash 执行一个命令，但是在后台运行而不是等它结束。关键是 bash 打开一个管道给命令来读取或者写入，并使用一个文件名来导出它，变成了展开的结果。</p>
<p>接下来是 tilde 展开。最初的目的是把 <code>~alan</code> 展开成 Alan 的 home 目录的引用，随着时间推移，它已经变成了一种引用大量其他目录的方式。</p>
<p>最后是算数展开。<code>$((expression))</code> 导致 <code>expression</code> 按照 C 语言表达式的计算。表达式的结果变成了展开的结果。</p>
<p>变量展开式单引号和双引号明显不同。单引号禁止所有展开-所有引号之内的字符保持不变-而双引号允许一些展开而禁止其他的。允许单词展开和命令、算数、和 process substitution 发生在双引号之内。双引号只影响结果如何处理-但是花括号和 tilde 展开并非如此。</p>
<h3>3.5.3. 单词分割(Word Splitting)</h3>
<p>单词展开的结果使用 shell变量 <code>IFS</code> 的值作为分隔符进行分割。这是如何告诉 shell 把一个单词转换成多个。每次 <code>$IFS1</code><sup><a href="#fn1">1</a></sup> 出现在结果中，bash 就把单词分割为两个。单双引号都禁止单词分割。</p>
<h3>3.5.4. Globbing</h3>
<p>在结果分割之后，shell 把前面展开的结果作为潜在的模式替换存在的文件名，包括任何前导的目录路径。</p>
<h3>3.5.5. Implementation</h3>
<p>如果 shell 的基本架构类似一个管道，那么单词展开吱声就是一个小型的管道。单词展开的每一个阶段，都取一个单词，然后经过可能的变换处理，最后传递给下一个展开阶段。在执行完所有的单词展开之后，命令就被执行了。</p>
<p>bash 的单词展开的实现建立在基本数据结构被描述的基础上。解析器输出的单词被独立展开，每一个输入单词输出一个或多个单词。<code>WORD_DESC</code> 数据结构被证明是足够通用来保存所有的封装单个单词扩展所必须的信息。flags 被用来编码信息给单词展开使用和从一个阶段到下一个阶段传递信息使用。例如，解析器使用一个 flag 来告诉展开和命令执行阶段一个特殊的单词是一个 shell 赋值声明，并且单词展开代码内部使用 flags 来禁止单词分割或者标记空引用串(<code>"$x"</code>, 其中 <code>$x</code> 未设置或值为空)。对每个要展开的单词使用一个字符串，并且使用某种字符编码来表示附加信息被证明是非常困难的。</p>
<p>说到解析器，单词展开代码处理需要多于一个字节来表示的字符。例如，变量长度展开 <code>(${#variable})</code> 计算字符长度，而不是字节长度，其代码可以正确标识展开的结尾或者多字节字符中特殊字符。</p>
<h2>3.6. 命令执行(Command Execution)</h2>
<p>bash 管道内部命令执行的阶段是真正做事情的时候。大多数时间，展开单词的结合分解成为一个命令名和参数集合，第一个作为要被读入和执行的文件名传递给操作系统，剩余的作为 <code>argv</code> 的元素来传递。</p>
<p>目前的描述重在 Posix 调用简单命令-那些具有一个命令名和一个参数集合的命令。这是最普通类型的命令，但是 bash 提供了更多类型。</p>
<p>命令执行阶段的输入是 parser 构造的命令结构体(command structure)和一个可能的展开的单词集合。这是真正 bash 编程语言展现的地方。编程语言使用之前讨论过的变量和展开，并且实现可能期待在高级语言中存在的：循环、条件、alternation、grouping、选择、基于模式匹配的条件执行、表达式求值(expression evaluation)和其他几个更高层次的 shell 特有的指令。</p>
<h3>3.6.1. 重定向(Redirection)</h3>
<p>shell 作为操作系统的接口的角色的一个影响就是它可以任意重定向它执行的命令的输入和输出。重定向语法是那些现实 shell 早期用户熟练程度的标志之一：直到最近，它需要用户记录他们使用得文件描述符，并显式的通过数字指定任何非标准输入、输出和错误。</p>
<p>最近一个对于重定向语法的增加允许用户指导 shell 来选择一个合适的文件描述符并将其分配给一个指定的变量，而不是让用户选择。这减轻了程序要记录文件描述符的负担，但是增加了额外的处理：shell 需要在合适的地方赋值文件描述符，并且确保它们被赋值给了指定的变量。这是另一个现实信息如何通过命令的执行从词法分析器传递给解析器的例子：analyzer 把单词归类为一个包含变量赋值的重定向；在合适的语法产生中，parser 使用一个 flag 标识需要赋值来创建重定向对象；最后重定向代码翻译 flag 来确保文件描述符被赋值给了正确的变量。</p>
<p>实现重定向最难的部分在于记住如何取消重定向。shell 故意模糊了从文件系统执行外部命令导致创建新进程和shell 执行的命令(内建命令)之间的区别，但是，无论命令是如何实现的，重定向不应该超出命令的执行结束<sup><a href="#fn2">2</a></sup>。因此 shell 需要记住如何取消每个重定向的影响，否则重定向 shell 内建命令将会改变 shell 的标准输出。bash 知道如何取消每种类型的重定向，要么是通过关闭一个它分配的文件描述符，或者通过保存一个文件描述符，并在稍后使用 <code>dup2</code> 恢复。这些由 parser 创建的重定向对象是相同的，并且使用相同的函数处理。</p>
<p>由于多重重定向是用简单对象列表实现的，所以用来取消重定向的重定向被保存在另外的表中。在命令结束的时候被处理，但是 shell 需要留神什么时候会这样，由于重定向附加到一个 shell 函数或者 "<code>.</code>" 内建命令必须有效知道函数或者内建命令完成。当不执行命令的时候，<code>exec</code> 内建命令导致 undo list 被简单丢弃，因为 <code>exec</code> 关联的重定向存在于 shell 的环境中。</p>
<p>另一个复杂性是 shell 自己带来的。Bourne shell 的历史版本只允许用户操作文件描述符0-9，保留10号及以上给 shell 内部使用。bash 取消了这个限制，用于用户操作任意描述符直到达到进程打开文件描述符分的限制。这意味着 bash 必须记录它自己内部的文件描述符，包括通过外部库打开的而不是直接通过 shell，并按照需求移动它们。这要求非常多的记账(bookkeeping)，一些启发性的联系到了close-on-exec标志，然而另外一个在这期间维护的重定向列表要么被处理，要么被丢弃。</p>
<h3>3.6.2. 内建命令(Builtin Commands)</h3>
<p>bash 使得很多命令变成了 shell 的一部分。这些命令是通过 shell 执行的，而不需要创建新进程。</p>
<p>把一条命令整合为内建的最常见的原因是维护或改变 shell 的内部状态。<code>cd</code> 就是一个很好的例子；介绍 Unix 的经典练习之一就是解释为什么 <code>cd</code> 不能作为一个外部命令来实现。</p>
<p>bash 内建命令使用相同的内部 primitives 作为 shell 的剩余部分。每一个内建命令都实现为一个接受一个单词列表作为参数的 C 语言函数。那些单词是单词展开阶段的输出；内建命令把它们看做命令名和参数。就大部分而言，内建命令使用与其他命令相同的标准展开规则，也有一些例外：接受赋值语句作为参数的bash 内建命令(例如 <code>declare</code> and <code>export</code>)与 shell 用来做变量赋值的那些使用相同的赋值参数展开规则。这也是 <code>WORD_DESC</code> 结构体成员 <code>flags</code> 被用来在一个阶段和 shell 的内部管道和另一个之间传递信息的地方。</p>
<h3>3.6.3. 简单命令执行(Simple Command Execution)</h3>
<p>简单命令就是那些经常遇到的一类。从文件系统中寻找和读取并执行命令，并收集它们的退出状态，涵盖了许多shell的保留特性。</p>
<p>shell 的变量赋值(i.e., words of the form <code>var=value</code>)本身就是一类简单命令。赋值语句(statemes)既可以在一个命令名之前，也可以自成一行。如果在一个命令之前，这个变量就会传递到这个命令执行的环境中 (如果他们在一个内建命令或者shell函数之前，只要这个内建命令或者函数在执行，它们就存在)。如果后边没有接着命令名，这个赋值就改变了 shell 的状态。</p>
<p>当输入的命令名不是 shell 函数或内建命令的时候，bash 就会搜索文件系统，寻找制定名称的可执行文件。值为使用分号分割的目录列表的变量 <code>PATH</code> 制定了搜索的目录。如果命令中包含了斜杠(或者其他目录分隔符)，则直接执行而不会查找。</p>
<p>当使用 <code>PATH</code> 找到一个命令的时候，bash 把命令名连同完整的路径名存入一张 hash 表中，它会首先查询这张表而不是直接使用 <code>PATH</code> 做后续查找。如果命令没有找到，bash 执行一个特殊名称的函数，如果定义了，使用命令名和参数作为函数的参数。一些 Linux 发行版使用这个机制来提供一种安装未找到命令的能力。</p>
<p>如果 bash 找到了一个文件来执行，它 fork 并创建一个新的执行环境，然后在新的环境中执行程序。执行环境是 shell 环境的完整副本，只有非常小的更改例如信号处理和通过打开或关闭文件的重定向。</p>
<h3>3.6.4. 作业控制(Job Control)</h3>
<p>shell 既可以前台执行命令，也就是等待命令结束并收集它的退出状态，也可以后台执行，shell 立即返回读取下一条命令。作业控制就是在前后台调度、休眠(suspend)、恢复(resume)进程(执行中的命令)执行的能力。为了实现作业控制，shell 引入了作业(job)的概念，它实质上就是由一个或多个进程正在执行的命令。例如管道，每个管道一个进程(A pipeline, for instance, uses one process for each of its elements)。 进程组是把不同的进程组合进一个作业的方式。终端有一个和它相关的进程组 ID，所以前台进程组就是进程组 ID 和终端的相同的那些进程。</p>
<p>shell 只是用了有限的几个数据结构来实现作业控制。有一个结构来表示一个子进程，包括了进程ID，状态，终止时的返回状态。管道只是这些进程结构的一个简单链表。一个作业也是非常类似的：有一个进程列表，一些作业状态(running, suspend, exited, etc.)，和作业的进程组 ID。进程列表通常有单个进程组成；只有管道才会关联多于一个的进程给一个作业。每一个作业有个唯一的进程组 ID，并且作业中得进程 ID 等于进程组 ID 的进程成为进程组组长(process group leader)。当前作业集合保存在一个数组中，概念上非常类似于呈现给用户的。作业的状态和退出状态是通过收集成员进程的状态和退出状态组装而成。</p>
<p>如同 shell 中的其他部分一样，作业控制的复杂部分在于bookkeeping。shell 必须小心分配进程到进程组，确保子进程的创建和进程组的赋值是同步的，并且终端的进程组是合适的，由于终端的进程组决定了前台作业(并且，如果不设置到 shell 得进程组，shell 自身是无法读取终端的输入的)。由于如此的面向进程，所以实现组合命令例如 <code>while</code> 和 <code>for</code> 循环就不那么直白了，因为要使得整个循环可以像一个单元那样开始和停止，并且一些少数 shell 实现了。</p>
<h3>3.6.5. 组合命令(Compound Commands)</h3>
<p>组合命令是由一个关键字 <code>if</code> 或者 <code>while</code> 引入的一个或者多个简单命令组成的列表。这就是shell的编程能力最明显和有效的体现。</p>
<p>实现是相当平淡的(The implementation is fairly unsurprising)。分析器构造相对应的各种组合命令的对象，并且通过遍历对象解释它们。每个组合命令是由一个相应的C函数实现的，这个函数负责执行相应的扩展，指定执行的命令和基于命令的返回状态改变执行流程。以实现 <code>for</code> 命令的函数作为例子。它首先必须扩展 <code>in</code> 保留字之后的单词列表。然后便利扩展的单词，赋值给合适的变量，接着执行 <code>for</code> 命令体中的命令列表。for 命令不需要更具命令的返回状态改变执行，但是必须注意 <code>break</code> 和 <code>continue</code> builtins。直到所有命令执行完，<code>for</code> 才返回。如上所述，大部分的实现都是契合描述的。</p>
<h2>3.7. 经验总结(Lessons Learned)</h2>
<h3>3.7.1. What I Have Found Is Important</h3>
<p>我花了二十多年在 bash 上，并且我想我发现了一些事情。最重要的是详细的更改日志，这个再怎么强调也不过分。当你看更改日志的时候能它能提醒你做出此改变的原因。如果能够把一个特定的 bug 报告联系到一次更改，完成一个可重入的测试用例或者建议。</p>
<p>如果合适，我会推荐项目一开始就做大量的回归测试。bash 具有上千个测试用例，覆盖了几乎它所有的非交互特性。我也考虑过为交互特性构建测试用例-Posix 在它的一致性测试套件中就有-但是并不想因为我觉得可能需要而发布。</p>
<p>标准是非常重要的。bash 从实现一个标准而受益。参与你实现的软件的标准化是意义非凡的。至于讨论到有关特性和它们的行为，有一个标准来参考，仲裁也不错。当然了，也可能不尽人意，取决于具体的标准了。</p>
<p>外部标准(external standards)固然重要，但是拥有内部标准(internal standards)也是很好的。我能有幸参与 GNU 项目的标准化，它带给了我非常多的好处、有关设计和实现的实践建议。</p>
<p>良好的文档是另一个不可或缺的因素。如果你希望一个程序被其他人使用，那么具有清晰易于理解的文档是值得拥有的。如果软件取得了成功，那么最终会有非常多的文档，开发者写的权威版本是非常重要的。</p>
<p>世界上有非常多的优秀软件。使用你可以用得：例如 gnulib 具有很多方便的库函数(一旦你可以从 gnulib framework 中取用)。BSDs 和 Mac OS X 也同样有。Picasso said "Great artists steal" for a reason.</p>
<p>参与的用户社区，但也要为偶尔的批评做准备，其中一些会令人挠头的。一个活跃的用户社区是意义非凡的。一个结果就是用户会变得非常热情。Don't take it personally.</p>
<h3>3.7.2. What I Would Have Done Differently</h3>
<p>bash 具有上百万的用户。我曾因向后兼容性而受教。一些情况下，向后兼容性意味着你永远不用说抱歉。而事实并非如此简单。我有时候会做出不兼容的更改，几乎所有用户都抱怨，即使我有正确的理由。修改一个坏的决策，修改设计失误或者修正shell 各部分之间的兼容性。I would have introduced something like formal bash compatibility levels earlier.</p>
<p>bash 的开发从来都未特别公开。我特别喜欢里程碑版本(e.g., bash-4.2)和独立发布的补丁的主意。下面是理由： I accommodate vendors with longer release timelines than the free software and open source worlds, and I've had trouble in the past with beta software becoming more widespread than I'd like. 如果我重新开始，我可能会考虑更频繁的版本释放，使用一种公开源等。</p>
<p>No such list would be complete without an implementation consideration. 有一件事情我反复考虑过，但是从来没实现，就是使用递归下降重写bash parser，而不是用 bison。I once thought I'd have to do this in order to make command substitution conform to Posix, but I was able to resolve that issue without changes that extensive. 如果我是从头实现 bash，我可能会顺手写个 parser。无疑会是事情变得更简单。</p>
<h2>3.8. 总结</h2>
<p>bash 是一款大型、复杂的自由软件的好例子。经过了超过20年的持续开发，成熟而且强大。几乎可以到处运行，每天被成千上万的人使用，而其中很多人都意识不到它的存在。</p>
<p>bash 被多个来源多影响，可以追溯到原始的 Stephen Bourne 所著的 Unix shell 的第七版。最显著的影响是 Posix 标准(the Posix standard)，规定了很多它的很多行为。向后兼容和服从标准带来了它的挑战。</p>
<p>bash 作为 GNU Project 的一部分而受益，<br />
Bash has profited by being part of the GNU Project, which has provided a movement and a framework in which bash exists. 如果没有 GNU, 也不会有 bash。bash 也得益于自己的活跃的用户社区。他们的反馈成就了 bash 的今天—自由软件的好处证明。</p>
<ol class="footnotes">
<li id="fn1">In most cases, a sequence of one of the characters.</li>
<li id="fn2">The exec builtin is an exception to this rule.</li>
</ol>
