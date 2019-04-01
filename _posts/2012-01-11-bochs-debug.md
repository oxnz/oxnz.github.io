---
layout: post
title: 用Bochs调试操作系统
type: post
categories: []
tags: []
---
如果单是需要一个虚拟机的话，你有许许多多的选择，本书下文也会对其他虚拟机有所介绍，之所以Bochs称为我们的首选，最重要的还在于它的调试功能。

<!--more-->

假设你正在运行一个有调试功能的Bochs，那么启动后，你会看到控制台出现若干选项，默认选项为“6. Begin simulation”，所以直接按回车键，Bochs就启动了，不过既然是可调试的，Bochs并没有急于让虚拟机进入运转状态，而是继续出现一个提示 符，等待你的输入，这时，你就可以尽情操纵你的虚拟机了。

还是以我们那个最轻巧的引导扇区为例，假如你想让它一步步地执行，可以先在07c00h处设一个断点──引导扇区就是从这里开始执行的，所以这里就是我们 的入口地址──然后单步执行，就好像所有其他调试工具一样。在任何时刻，你都可以查看CPU寄存器，或者查看某个内存地址处的内容。下面我就来模拟一下这 个过程：

```
……<br />
Next at t=0<br />
(0) [0xfffffff0] f000:fff0 (unk. ctxt): jmp far f000:e05b         ; ea5be000f0<br />
b 0x7c00 ?<br />
c ?<br />
(0) Breakpoint 1, 0x00007c00 in ?? ()<br />
Next at t=886152<br />
(0) [0x00007c00] 0000:7c00 (unk. ctxt): mov ax, cs                ; 8cc8<br />
dump_cpu ?<br />
eax:0x0fffaa55, ebx:0x00000000, ecx:0x00120001, edx:0x00000000<br />
ebp:0x00000000, esp:0x0000fffe, esi:0x000088d2, edi:0x0000ffde<br />
eip:0x00007c00, eflags:0x00000282, inhibit_mask:0<br />
cs:s=0x0000, dl=0x0000ffff, dh=0x00009b00, valid=1<br />
ss:s=0x0000, dl=0x0000ffff, dh=0x00009300, valid=7<br />
ds:s=0x0000, dl=0x0000ffff, dh=0x00009300, valid=1<br />
es:s=0x0000, dl=0x0000ffff, dh=0x00009300, valid=1<br />
fs:s=0x0000, dl=0x0000ffff, dh=0x00009300, valid=1<br />
gs:s=0x0000, dl=0x0000ffff, dh=0x00009300, valid=1<br />
ldtr:s=0x0000, dl=0x0000ffff, dh=0x00008200, valid=1<br />
tr:s=0x0000, dl=0x0000ffff, dh=0x00008300, valid=1<br />
gdtr:base=0x00000000, limit=0xffff<br />
idtr:base=0x00000000, limit=0xffff<br />
dr0:0x00000000, dr1:0x00000000, dr2:0x00000000<br />
dr3:0x00000000, dr6:0xffff0ff0, dr7:0x00000400<br />
cr0:0x00000010, cr1:0x00000000, cr2:0x00000000<br />
cr3:0x00000000, cr4:0x00000000<br />
done<br />
x /64xb 0x7c00 ?<br />
[bochs]:<br />
0x00007c00 : 0x8c 0xc8 0x8e 0xd8 0x8e 0xc0 0xe8 0x02<br />
0x00007c08 : 0x00 0xeb 0xfe 0xb8 0x1e 0x7c 0x89 0xc5<br />
0x00007c10 : 0xb9 0x10 0x00 0xb8 0x01 0x13 0xbb 0x0c<br />
0x00007c18 : 0x00 0xb2 0x00 0xcd 0x10 0xc3 0x48 0x65<br />
0x00007c20 : 0x6c 0x6c 0x6f 0x2c 0x20 0x4f 0x53 0x20<br />
0x00007c28 : 0x77 0x6f 0x72 0x6c 0x64 0x21 0x00 0x00<br />
0x00007c30 : 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00<br />
0x00007c38 : 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00<br />
n ?<br />
Next at t=886153<br />
(0) [0x00007c02] 0000:7c02 (unk. ctxt): mov ds, ax                ; 8ed8<br />
trace-reg on ?<br />
Register-Tracing enabled for CPU 0<br />
n ?<br />
Next at t=886154<br />
eax: 0x0fff0000 268369920<br />
ecx: 0x00120001 1179649<br />
edx: 0x00000000 0<br />
ebx: 0x00000000 0<br />
esp: 0x0000fffe 65534<br />
ebp: 0x00000000 0<br />
esi: 0x000088d2 35026<br />
edi: 0x0000ffde 65502<br />
eip: 0x00007c04<br />
eflags 0x00000282<br />
IOPL=0 id vip vif ac vm rf nt of df IF tf SF zf af pf cf<br />
(0) [0x00007c04] 0000:7c04 (unk. ctxt): mov es, ax                ; 8ec0<br />
c ?<br />
……<br />
```

以上带有?符号并以加粗字体显示的是输入，其他均为Bochs的输出。如果你用过GDB，你会觉得这个过程很亲切。没错，它跟用GDB调试程序的感觉是很 相似的，最大的区别可能就在于在Bochs的调试模式下我们需要跟CPU、内存、机器指令等内容打更多交道。</p>
<p>在上面的演示过程中，最开始的“b 0x7c00”在0x7c00处设置了断点，随后的命令“c”让代码继续执行，一直到我们设置的断点处停止，然后演示的是用“dump_cpu”指令查看 CPU寄存器以及用“x”指令查看内存。随后用一个“n”指令让代码向下走了一步，“trace-reg on”的功能是让Bochs每走一步都显示主要寄存器的值。之所以选择演示这些命令，因为它们基本是调试过程中最常用到的。</p>
<p>如果你在调试过程中忘记了指令的用法，或者根本就忘记了该使用什么指令，可以随时使用help命令，所有命令的列表就呈现在眼前了。你将会发现Bochs的调试命令并不多，不需要多久就可以悉数掌握。Table 1列出了常用的指令以及其典型用法。</p>
<p>Table 1. 部分Bochs调试指令<br />
行为                                                  指令                         举例<br />
在某物理地址设置断点                   b addr                    b 0x30400<br />
显示当前所有断点信息                   info break                info break<br />
继续执行，直到遇上断点                c                              c<br />
单步执行                                         s                              s<br />
单步执行（遇到函数则跳过）      n                              n</p>
<p>查看寄存器信息                             info cpu                     info cpu</p>
<p>r                               r</p>
<p>fp                             fp</p>
<p>sreg                           sreg</p>
<p>creg                            creg</p>
<p>查看堆栈                                        print-stack                      print-stack</p>
<p>查看内存物理地址内容                   xp /nuf addr xp /40bx             0x9013e</p>
<p>查看线性地址内容                         x /nuf addr x /40bx            0x13e<br />
反汇编一段内存                             u start end u 0x30400           0x3040D<br />
反汇编执行的每一条指令              trace-on                         trace-on<br />
每执行一条指令就打印CPU信息     trace-reg                            trace-reg on        其中“xp /40bx 0x9013e”这样的格式可能显得有点复杂，读者可以用“help x”这一指令在Bochs中亲自看一下它代表的意义。</p>
<p>好了，虽然你可能还无法熟练运用Bochs进行调试，但至少你应该知道，即便你的操作系统出现了问题也并不可怕，有强大的工具可以帮助你进行调试。由于 Bochs是开放源代码的，如果你愿意，你甚至可以通过读Bochs的源代码来间接了解计算机的运行过程──因为Bochs就是一台计算机。</p>
