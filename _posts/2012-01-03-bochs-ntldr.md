---
layout: post
title: Bochs
type: post
categories: []
tags: [bochs]
---

>
A virtual machine is an indirection engine which redirects code and data inside of the 'guest' sandbox

## Three ways of VM implementation

1. Virtualization, direct execution (VMware, Virtual PC, Xen)
2. Dynamic (just-in-time) translation (QEMU)
3. Emulation (Bochs, Gemulator)

<p>对一台安装了Windows NT 系列操作系统的PC来说，按下电源开关之后，CPU中首<br />
先开始运行的是Bios，然后是MBR，接着是引导扇，然后就是NTLDR。<!--more-->ntoskrnl.exe和<br />
hal.dll 都是由NTLDR来加载的。也就是说，运行NTLDR的时候，系统中还没有任何应<br />
用程序或者驱动，当然也就没有任何基于软件的调试器可用。当然，无所不能的硬件<br />
调试器肯定是可以的，可惜我们没有硬件调试器。</p>
<p>幸好有了Bochs。Bochs是一个基于LGPL的开源x86 虚拟机软件。Bochs的CPU指令<br />
是完全自己模拟出来的，这种方式的缺点是速度比较慢；优点是具有无以伦比的可移<br />
植性：有Gcc的地方就可以有Bochs。甚至已经有了跑在PocketPC上的Bochs。</p>
<p>现在的Bochs 已经实现了一定程度的调试功能，虽然在易用性和功能上还无法和<br />
WinDbg、SoftICE相比，但优势也是很明显的：对跑在Bochs里面的代码来说，这就是<br />
“硬件调试器”。</p>
<p>对Windows 版本的Bochs来说，安装目录下的bochsdbg.exe就是Bochs的调试版本。<br />
用它来运行Bochs虚拟机就可以进行“硬件调试”。</p>
<p>Bochs的调试命令风格是按照GDB习惯来设计的，这对于用惯了WinDbg的人来说无<br />
疑是痛苦的，好在这是个开源软件，看着不顺眼可以考虑自己改改。</p>
<p>目前版本的Bochs(Version 2.1.1)支持的调试命令如下：</p>
<p>[注意]</p>
<p>1、Bochs的文档和帮助信息中的使用说明与真实情况之间存在很大的差错和缺失，<br />
下面的命令说明根据源码作了很多补充和修正。</p>
<p>2、其中涉及到的seg（段）、off（偏移）、addr（地址）、val（值）等数字，<br />
可以使用十六进制、十进制或者八进制，但必须按照如下形式书写：</p>
<p>十六进制   0xCDEF0123<br />
八进制     01234567<br />
十进制     123456789<br />
尤其要注意，Bochs不能自动识别16进制的数字，也不接受12345678h这种写法。</p>
<p>[执行控制]</p>

<p>c|cont                   向下执行，相当于WinDBG的“g”。</p>
<p>s|step|stepi [count]     单步执行，相当于WinDBG的“t”，count 默认为 1。</p>
<p>p|n|next                 单步执行，类似于WinDBG的“p”。</p>
<p>q|quit|exit             退出调试，同时关闭虚拟机。</p>
<p>Ctrl-C                   结束执行状态，返回调试器提示符。</p>
<p>Ctrl-D                   if at empty line on command line, exit<br />
（至少在Windows版本中我没有发现Ctrl-D有什么功能）</p>
<p>[执行断点]</p>
<p>vb|vbreak [seg:off]         在虚拟地址上下断点。</p>
<p>lb|lbreak [addr]             在线性地址上下断点，相当于WinDBG的“bp”。</p>
<p>pb|pbreak|b|break [addr]     在物理地址上下断点。（为了兼容GDB的语法，地址前<br />
可以加上一个“*”）。</p>
<p>blist                       显示断点状态，相当于WinDBG的“bl”。</p>
<p>bpd|bpe [num]               禁用/启用断点，WinDBG的“be”和“bd”。num是断<br />
点号，可以用blist命令查询。</p>
<p>d|del|delete [num]           删除断点，相当于WinDBG的“bc”。mum是断点号，可<br />
以用blist命令查询。</p>
<p>[读写断点]</p>
<p>watch read [addr]       设置读断点。<br />
watch write [addr]       设置写断点。<br />
unwatch read [addr]     清除读断点。<br />
unwatch write [addr]     清除写断点。<br />
watch                   显示当前所有读写断点。<br />
unwatch                 清除当前所有读写断点。<br />
watch stop|continue     开关选项，设置遇到读写断点时中断下来还是显示出来但<br />
是继续运行。</p>
<p>[内存操作]</p>
<p>x   /nuf [addr]   显示线性地址的内容<br />
xp /nuf [addr]   显示物理地址的内容<br />
n           显示的单元数<br />
u           每个显示单元的大小，u可以是下列之一：<br />
b BYTE<br />
h WORD<br />
w DWORD<br />
g DWORD64<br />
注意: 这种命名法是按照GDB习惯的，而并不是按照inter的规范。</p>
<p>f           显示格式，f可以是下列之一：<br />
x 按照十六进制显示<br />
d 十进制显示<br />
u 按照无符号十进制显示<br />
o 按照八进制显示<br />
t 按照二进制显示<br />
c 按照字符显示<br />
n、f、u是可选参数，如果不指定，则u默认是w，f默认是x。如果前面使用过x或<br />
者xp命令，会按照上一次的x或者xp命令所使用的值。n默认为1。addr 也是一个<br />
可选参数，如果不指定，addr是0，如过前面使用过x或者xp命令，指定了n=i，<br />
则再次执行时n默认为i+1。</p>
<p>setpmem [addr] [size] [val]     设置物理内存某地址的内容。</p>
<p>需要注意的是，每次最多只能设置一个DWORD：<br />
这样是可以的：<br />
&lt;bochs:1&gt;   setpmem 0x00000000 0x4 0x11223344<br />
&lt;bochs:2&gt; x /4 0x00000000<br />
[bochs]:<br />
0x00000000 &lt;bogus+       0&gt;:     0x11223344 0x00000000 0x00000000 0x00000000<br />
这样也可以：<br />
&lt;bochs:1&gt;   setpmem 0x00000000 0x2 0x11223344<br />
&lt;bochs:2&gt; x /4 0x00000000<br />
[bochs]:<br />
0x00000000 &lt;bogus+       0&gt;:     0x00003344 0x00000000 0x00000000 0x00000000<br />
或者：<br />
&lt;bochs:1&gt;   setpmem 0x00000000 0x1 0x20<br />
&lt;bochs:2&gt; x /4 0x00000000<br />
[bochs]:<br />
0x00000000 &lt;bogus+       0&gt;:     0x00000020 0x00000000 0x00000000 0x00000000<br />
下面的做法都会导致出错：<br />
&lt;bochs:1&gt;   setpmem 0x00000000 0x3 0x112233<br />
Error: setpmem: bad length value = 3<br />
&lt;bochs:2&gt;   setpmem 0x00000000 0x8 0x11223344<br />
Error: setpmem: bad length value = 8</p>
<p>crc [start] [end]     显示物理地址start到end之间数据的CRC。</p>
<p>[寄存器操作]</p>
<p>set $reg = val               设置寄存器的值。现在版本可以设置的寄存器包括：<br />
eax ecx edx ebx esp ebp esi edi<br />
暂时不能设置：<br />
eflags   cs   ss   ds   es   fs   gs</p>
<p>r|reg|registers reg = val   同上。</p>
<p>dump_cpu                     显示完整的CPU信息。</p>
<p>set_cpu                     设置CPU状态，这里可以设置dump_cpu所能显示出来的<br />
所有CPU状态。</p>
<p>[反汇编命令]</p>
<p>u|disas|disassemble [/num] [start] [end]<br />
反汇编物理地址start到end 之间的代码，如<br />
果不指定参数则反汇编当前EIP指向的代码。<br />
num是可选参数，指定处理的代码量。<br />
set $disassemble_size = 0|16|32     $disassemble_size变量指定反汇编使用的段<br />
大小。</p>
<p>set $auto_disassemble = 0|1         $auto_disassemble决定每次执行中断下来的<br />
时候（例如遇到断点、Ctrl-C等）是否反汇<br />
编当前指令。</p>
<p>[其他命令]<br />
trace-on|trace-off       Tracing开关打开后，每执行一条指令都会将反汇编的结果<br />
显示出来。</p>
<p>ptime                   显示Bochs自本次运行以来执行的指令条数。</p>
<p>sb [val]                 再执行val条指令就中断。val是64-bit整数，以L结尾，形<br />
如“1000L”</p>
<p>sba [val]               执行到Bochs自本次运行以来的第val条指令就中断。val是<br />
64-bit整数，以L结尾，形如“1000L”</p>
<p>modebp                   设置切换到v86模式时中断。</p>
<p>record ["filename"]     将输入的调试指令记录到文件中。文件名必须包含引号。</p>
<p>playback ["filename"]   回放record的记录文件。文件名必须包含引号。</p>
<p>print-stack [num]       显示堆栈，num默认为16，表示打印的条数。</p>
<p>?|calc                   和WinDBG的“?”命令类似，计算表达式的值。</p>
<p>load-symbols [global] filename [offset]<br />
载入符号文件。如果设定了“global”关键字，则符号针<br />
对所有上下文都有效。offset会默认加到所有的symbol地<br />
址上。symbol文件的格式为："%x %s"。</p>
<p>[info命令]</p>
<p>info program             显示程序执行的情况。<br />
info registers|reg|r     显示寄存器的信息。<br />
info pb|pbreak|b|break   相当于blist<br />
info dirty               显示脏页的页地址。<br />
info cpu                 显示所有CPU寄存器的值。<br />
info fpu                 显示所有FPU寄存器的值。<br />
info idt                 显示IDT。<br />
info gdt [num]           显示GDT。<br />
info ldt                 显示LDT。<br />
info tss                 显示TSS。<br />
info pic                 显示PIC。<br />
info ivt [num] [num]     显示IVT。<br />
info flags               显示状态寄存器。<br />
info cr                 显示CR系列寄存器。<br />
info symbols             显示symbol信息。<br />
info ne2k|ne2000         显示虚拟的ne2k网卡信息。</p>
<p>弄明白了调试命令，接下来就可以着手进行NTLDR的调试工作了。下面所进行的工<br />
作都是在Windows版Bochs 2.1.1上实现的。我们假设读者了解Bochs的基本使用方法和<br />
术语。</p>
<p>首先要安装一个Windows NT 4的Bochs虚拟机。</p>
<p>1、创建虚拟硬盘。<br />
运行bximage.exe，创建一个500M、flat模式的虚拟硬盘文件“C.img”。</p>
<p>2、创建一个Windows NT安装光盘的ISO文件“nt.iso”<br />
如果你打算直接用光盘安装，也可以省去这一步。</p>
<p>3、创建bochsrc.txt<br />
内容可参考下面：<br />
###############################################################<br />
megs: 32</p>
<p>romimage: file=$BXSHAREBIOS-bochs-latest, address=0xf0000<br />
vgaromimage: $BXSHAREVGABIOS-lgpl-latest</p>
<p>ata0: enabled=1, ioaddr1=0x1f0, ioaddr2=0x3f0, irq=14<br />
ata0-master: type=disk, path="C.img", mode=flat, cylinders=1015, heads=16, spt=63<br />
ata0-slave: type=cdrom, path="nt.iso", status=inserted<br />
newharddrivesupport: enabled=1</p>
<p>boot: cdrom</p>
<p>log: nul</p>
<p>mouse: enabled=1</p>
<p>clock: sync=realtime, time0=local<br />
###############################################################</p>
<p>4、创建start.bat<br />
内容如下：<br />
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::<br />
::假设你的Bochs安装在D:ProgramBochs<br />
set BXSHARE=D:ProgramBochs<br />
%BXSHARE%bochs.exe -q -f bochsrc.txt<br />
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::</p>
<p>把C.img、nt.iso、bochsrc.txt、start.bat放到同一个目录下，运行start.bat，<br />
进行Windows NT的安装。</p>
<p>事实上，如果只是为了调试MBR、引导扇和NTLDR 的话，并没有必要安装完整的操<br />
作系统，只要根目录下有ntldr等那几个文件就可以了。这里之所以安装Windows NT而<br />
不是Windows 2000或者更高版本，一方面是考虑速度问题，另一方面，Windows NT 是<br />
可以在Bochs上确保顺利完成安装的。如果要调试Windows 2000/XP/2003 的NTLDR，只<br />
需用这些操作系统的ntldr文件替换Windows NT的即可。</p>
<p>安装完Windows NT之后，可以进行NTLDR的调试了。把start.bat中的“bochs.exe”<br />
换成“bochsdbg.exe”。然后运行start.bat。</p>
<p>下面是操作的屏幕拷贝：</p>

```
========================================================================
Bochs x86 Emulator 2.1.1<br />
February 08, 2004<br />
========================================================================
00000000000i[     ] reading configuration from bochsrc.txt
00000000000i[     ] installing win32 module as the Bochs GUI
00000000000i[     ] Warning: no rc file specified.
00000000000i[     ] using log file nul
Next at t=0       //启动bochsdbg.exe，会自动停在Bios的第一条指令上。
(0) context not implemented because BX_HAVE_HASH_MAP=0
[0x000ffff0] f000:fff0 (unk. ctxt): jmp f000:e05b             ; ea5be000f0
<bochs:1> b 0x00007c00     //MBR和引导扇都会加载在0000:7c00。
<bochs:2> c
(0) Breakpoint 1, 0x7c00 in ?? () //第一次会在MBR上中断下来。
Next at t=772567
(0) [0x00007c00] 0000:7c00 (unk. ctxt): cli                   ; fa
<bochs:3> c
(0) Breakpoint 1, 0x7c00 in ?? () //第二次会在引导扇上中断。
Next at t=773872
(0) [0x00007c00] 0000:7c00 (unk. ctxt): jmp 0x7c5d             ; eb5b
<bochs:4>b 0x00020000   //ntldr会加载在2000:0000，事实上无论是CDFS、NTFS还是FAT，
//Windows加载启动文件都是这个地址。
<bochs:5> c
(0) Breakpoint 2, 0x20000 in ?? () //在NTLDR的第一条指令上断下来了，可以开始进行调试。
Next at t=861712
(0) [0x00020000] 2000:0000 (unk. ctxt): jmp 0x1f6             ; e9f301
```

<p>现在，我们可以像上帝俯看芸芸众生一样，看着操作系统一步一步启动起来，一<br />
切尽在眼底，甚至可以看到系统启动过程中实模式切换到保护模式的情景：</p>

```
(0).[28734582] [0x00020247] 2000:0247 (unk. ctxt): opsize or eax, 0x1         ; 6683c801
(0).[28734583] [0x0002024b] 2000:024b (unk. ctxt): mov cr0, eax               ; 0f22c0
(0).[28734584] [0x0002024e] 2000:0000024e (unk. ctxt): xchg bx, bx           ; 87db
(0).[28734585] [0x00020250] 2000:00000250 (unk. ctxt): jmp 0x253             ; eb01
(0).[28734586] [0x00020253] 2000:00000253 (unk. ctxt): push 0x58             ; 6a58
(0).[28734587] [0x00020255] 2000:00000255 (unk. ctxt): push 0x259             ; 685902
(0).[28734588] [0x00020258] 2000:00000258 (unk. ctxt): retf                   ; cb
```

## References

* [http://bochs.sourceforge.net/](http://bochs.sourceforge.net/)
* [http://bochs.sourceforge.net/Virtualization_Without_Hardware_Final.pdf](http://bochs.sourceforge.net/Virtualization_Without_Hardware_Final.pdf)
