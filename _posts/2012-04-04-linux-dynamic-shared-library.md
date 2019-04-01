---
layout: post
title: Linux 动态共享库开发
type: post
categories: [Linux]
tags: [lib]
---

<style type="text/css">
.post-content h1,
.post-content h2,
.post-content h3,
.post-content h4,
.post-content h5,
.post-content h6 {
    color: #006600;
}
</style>

## Table of Contents

* TOC
{:toc}

## 1 简单的so实例

### 源文件

<!--more-->

```c
//add.c
int add(int a, int b) {
    return a + b;
}
//sub.c
int sub(int a, int b) {
    return a - b;
}
//calc.c
#include <stdio.h>
int add(int a, int b);
int sub(int a, int b);

int main() {
    int a = 1, b = 2;
    printf("result of add:= %dn", add(a, b));
    printf("result of sub:= %dn", sub(a, b));
}
```

### 打包成 so 文件

在代码的目录下运行如下命令:

```shell
gcc -Wall -fPIC -c *.c
gcc -shared -Wl,-soname,libcalc.so.1 -o libcalc.so.1.0 *.o
sudo mv libcalc.so.1.0 /usr/lib
sudo ln -sf /usr/lib/libcalc.so.1.0 /usr/lib/libcalc.so
sudo ln -sf /usr/lib/libcalc.so.1.0 /usr/lib/libcalc.so.1
```

参数详解:

* -Wall: 包含warning信息
* -fPIC: 编译动态库必须,输出不依赖位置的代码(原文 :Compiler directive to output position independent code)
* <tt>-shared</tt>: 编译动态库必需选项
* <tt>-W1</tt>: 向链接器(Linker)传递一些参数.在这里传递的参数有 "<tt>-soname libctest.so.1</tt>"
* -o: 动态库的名字. 在这个例子里最终生成动态库 libctest.so.1.0

两个符号链接的含义:

* 第一个:允许应用代码用 -lctest 的语法进行编译.
* 第二个:允许应用程序在运行时调用动态库.

## 2 so路径设置

为了使应用程序能够在运行时加载动态库,可以通过3种方式指定动态库的路径(以下例子均假定/opt/lib是动态库所在位置):

### 用 ldconfig 指定路径

运行

```
sudo ldconfig -n /opt/lib
```

/opt/lib 是动态库所在路径.

这种方式简单快捷,便于程序员开发.缺点是重启后即失效.

### 修改 /etc/ld.so.conf 文件

打开/etc/ld.so.confg 文件,并将/opt/lib 添加进去.

(<strong><span style="color: #000000;">注: 在Ubuntu系统中</span></strong>, 所有so.conf文件都在/etc/ld.so.conf.d目录. 你可以仿照该目录下的.conf文件写一个libcalc.conf并将/opt/lib填入)

### 用环境变量 LD_LIBRARY_PATH 指定路径

环境变量的名字一般是 LD_LIBRARY_PATH, 但是不同的系统可能有不同名字. 例如

* Linux/Solaris: <tt>LD_LIBRARY_PATH</tt>,
* SGI: <tt>LD_LIBRARYN32_PATH</tt>,
* AIX: <tt>LIBPATH</tt>,
* Mac OS X: <tt>DYLD_LIBRARY_PATH</tt>,
* HP-UX: <tt>SHLIB_PATH</tt>) (<em><span style="color: #009900;">注: 此说法未经验证</span></em>)

修改 ~/.bashrc, 增加以下脚本:

```shell
if [ -d /opt/lib ]; then
    LD_LIBRARY_PATH="/opt/lib:$LD_LIBRARY_PATH"
fi
export LD_LIBRARY_PATH
```

在第一章的简单例子中, /usr/lib 是Ubuntu默认的动态库目录,所以我们不须指定动态库目录也能运行应用程序.

## 3 简单的动态调用 so 例子

### C 调用例子

保留第一章的 add.c 和 sub.c 文件,并增加 calc.h 头文件如下:

```c
#ifndef CALC_H
#define CALC_H
#ifdef __cplusplus
extern "C" {
#endif
int add(int a, int b);
int sub(int a, int b);
#ifdef __cplusplus
}
#endif
#endif
```

我们继续使用第一章生成的 libcalc.so,仅需增加一个新的应用程序 prog.c:

```c
//prog.c
#include <stdio.h>
#include <dlfcn.h>
#include "calc.h"

int main(int argc, char *argv[]) {
    void *lib_handle;
    int (*fn)();
    char *error;
    lib_handle = dlopen("libcalc.so", RTLD_LAZY);
    if (! lib_handle) {
        fprintf(stderr, "%sn", dlerror());
        return 1;
    }
    fn = dlsym(lib_handle, "add");
    if ((error = dlerror()) != NULL) {
        fprintf(stderr, "%sn", error);
        return 1;
    }
    int sum = fn(1, 2);
    printf("sum = %d\n", sum);
    dlclose(lib_handle);
    return 0;
}
```

然后用如下命令运行(由于没有使用其他库,所以忽略 -L 等参数):

```shell
gcc -Wall prog.c -lcalc -o prog -ldl
./prog
```

### 方法简介

dlopen("libcalc.so", RTLD_LAZY): 加载动态库,如果加载失败返回 NULL. 第二个参数可以是:

* RTLD_LAZY: lazy模式. 直到源码运行到改行才尝试加载.
* RTLD_NOW: 马上加载.
* RTLD_GLOBAL: 不解(原文: Make symbol libraries visible.)

dlsym(lib_handle, "add"): 返回函数地址. 如果查找函数失败则返回 NULL.

和微软的动态加载 dll 技术对比如下:

* ::LoadLibrary() - dlopen()
* ::GetProcAddress() - dlsym()
* ::FreeLibrary() - dlclose()

### C++ 调用例子

增加一个prog.cpp

```cpp
#include <dlfcn.h>
#include <iostream>
#include "calc.h"

using namespace std;

int main() {
    void *lib_handle;
    //MyClass* (*create)();
    //ReturnType (* func_name)();
    int (* func_handle)();
    string nameOfLibToLoad("libcalc.so");
    lib_handle = dlopen(nameOfLibToLoad.c_str(), RTLD_LAZY);
    if (!lib_handle) {
        cerr << "Cannot load library: " << dlerror() << endl;
    }
    // reset errors
    dlerror();
    // load the symbols (handle to function "add")
    //create = (MyClass* (*)())dlsym(handle, "create_object");
    //destroy = (void (*)(MyClass*))dlsym(handle, "destroy_object");
    func_handle = (int(*)())dlsym(lib_handle, "add");
    const char* dlsym_error = dlerror();
    if (dlsym_error) {
        cerr << "Cannot load symbol add: " << dlsym_error << endl;
    }
    cout <<"result:= " << func_handle() << endl;
    dlclose(lib_handle);
    return 0;
}
```

然后用如下命令运行:

```shell
g++ -Wall prog.cpp -lcalc -o prog -ldl
./prog
```

### 编译命令简介

假设 C 文件是 prog.c, C++ 调用文件是 prog.cpp, 那么编译脚本分别是:

* C 语言
    * `gcc -Wall -I/path/to/include-files -L/path/to/libraries prog.c -lcalc -o prog`
* C++ 语言
    * `g++ -Wall -I/path/to/include-files -L/path/to/libraries prog2.cpp -lcalc -ldl -o prog`

参数详解:

* -I: 指定头文件目录.
* -L: 指定库目录.
* -lctest: 调用动态库libctest.so.1.0. 如果在打包so时没有创建第一个符号链接,那么这个参数会导致编译不成功.
* -ldl: C++编译必须

### 相关知识

命令 <em><strong>ldd appname</strong></em> 可以查看应用程序所依赖的动态库,运行如下命令:

```
ldd prog
# 在我的机器输出:
linux-gate.so.1 =>  (0xb80d4000)
libcalc.so.1 => /usr/lib/libcalc.so.1 (0xb80be000)
libc.so.6 => /lib/tls/i686/cmov/libc.so.6 (0xb7f5b000)
/lib/ld-linux.so.2 (0xb80d5000)
```

## 4 C++ 开发带 class 的 so

```cpp
//myclass.h
#ifndef __MYCLASS_H__
#define __MYCLASS_H__

class MyClass {
public:
    MyClass();/* use virtual otherwise linker will try to perform static linkage */
    virtual void DoSomething();
private:
    int x;
};

#endif

//myclass.cpp
#include "myclass.h"
#include <iostream>

using namespace std;

extern "C" MyClass* create_object() {
    return new MyClass;
}

extern "C" void destroy_object(MyClass* object ) {
    delete object;
}

MyClass::MyClass() {
    x = 20;
}

void MyClass::DoSomething() {
    cout << x << endl;
}

//class_user.cpp
#include <dlfcn.h>
#include <iostream>
#include "myclass.h"

using namespace std;

int main(int argc, char *argv[]) {
    /* on Linux, use "./myclass.so" */
    void *handle = dlopen("./myclass.so", RTLD_LAZY);
    MyClass* (*create)();
    void (*destroy)(MyClass*);
    create = (MyClass* (*)())dlsym(handle, "create_object");
    destroy = (void (*)(MyClass*))dlsym(handle, "destroy_object");
    MyClass* myClass = (MyClass*)create();
    myClass->DoSomething();
    destroy(myClass);
}
```

编译和运行:

```shell
g++ -fPIC -shared myclass.cpp -o myclass.so
g++ class_user.cpp -ldl -o class_user
./class_user
```


## 关于 Ubuntu 添加共享库路径

1. 将绝对路径写入 /etc/ld.so.conf
2. ldconfig
3. done

下面是解释

库文件在连接(静态库和共享库)和运行(仅限于使用共享库的程序)时被使用，其搜索路径是在系统中进行设置的。

一般 Linux 系统把 /lib 和 /usr/lib 两个目录作为默认的库搜索路径，所以使用这两个目录中的库时不需要进行设置搜索路径即可直接使用。

对于处于默认库搜索路径之外的库，需要将库的位置添加到库的搜索路径之中。

设置库文件的搜索路径有下列两种方式，可任选其一使用：

* 在环境变量 LD_LIBRARY_PATH 中指明库的搜索路径。
* 在 /etc/ld.so.conf 文件中添加库的搜索路径。

将自己可能存放库文件的路径都加入到 /etc/ld.so.conf 中是明智的选择

添加方法也极其简单，将库文件的绝对路径直接写进去就OK了，一行一个。例如：

```
/usr/X11R6/lib
/usr/local/lib
/opt/lib
```

需要注意的是：第二种搜索路径的设置方式对于程序连接时的库(包括共享库和静态库)的定位已经足够了，但是对于使用了共享库的程序的执行还是不够的。
这是因为为了加快程序执行时对共享库的定位速度，避免使用搜索路径查找共享库的低效率，所以是直接读取库列表文件 /etc/ld.so.cache 从中进行搜索的。
/etc/ld.so.cache 是一个非文本的数据文件，不能直接编辑，它是根据 /etc/ld.so.conf 中设置的搜索路径由 /sbin/ldconfig 命令将这些搜索路径下的共享库文件集中在一起而生成的(ldconfig 命令要以 root 权限执行)。

因此，为了保证程序执行时对库的定位，在 /etc/ld.so.conf 中进行了库搜索路径的设置之后，还必须要运行 /sbin/ldconfig 命令更新 /etc/ld.so.cache 文件之后才可以。

ldconfig ,简单的说，它的作用就是将 /etc/ld.so.conf 列出的路径下的库文件缓存到 /etc/ld.so.cache 以供使用。

因此当安装完一些库文件，(例如刚安装好glib)，或者修改 ld.so.conf 增加新的库路径后，需要运行一下 /sbin/ldconfig 使所有的库文件都被缓存到 ld.so.cache 中。

如果没做，即使库文件明明就在 /usr/lib 下的，也是不会被使用的，结果编译过程中报错，缺少 xxx 库。

在程序连接时，对于库文件(静态库和共享库)的搜索路径，除了上面的设置方式之外，还可以通过 -L 参数显式指定。因为用 -L 设置的路径将被优先搜索，所以在连接的时候通常都会以这种方式直接指定要连接的库的路径。

前面已经说明过了，库搜索路径的设置有两种方式：在环境变量 LD_LIBRARY_PATH 中设置以及在 /etc/ld.so.conf 文件中设置。

其中，第二种设置方式需要 root 权限，以改变 /etc/ld.so.conf 文件并执行 /sbin/ldconfig 命令。
而且，当系统重新启动后，所有的基于 GTK2 的程序在运行时都将使用新安装的 GTK 库。
不幸的是，由于 GTK 版本的改变，这有时会给应用程序带来兼容性的问题，造成某些程序运行不正常。
为了避免出现上面的这些情况，在 GTK 及其依赖库的安装过程中对于库的搜索路径的设置将采用第一种方式进行。这种设置方式不需要 root 权限，设置也简单：

```shell
export LD_LIBRARY_PATH="/opt/gtk/lib:$LD_LIBRARY_PATH"
```

可以用下面的命令查看 LD_LIBRAY_PATH 的设置内容:

```shell
echo $LD_LIBRARY_PATH
```

至此，库的两种设置就完成了。

## Linux 下的共享库版本控制

DLL hell
: 是指 Windows 系统上动态库的新版本覆盖旧版本，且新版本不能兼容旧版本的问题。

例如：装新软件，但原有的软件运行不起来了。Linux 系统下也同样面临着和 Windows 一样的动态库多版本的问题，其严重影响软件的升级和维护。

那么此问题该如何解决的呢？

Linux 系统为解决这个问题，引入了一套机制，如果遵守这个机制来做，就可以避免这个问题。

但是这只是一个约定，不是强制的。

但是建议遵守这个约定，否则同样也会出现 Linux 系统版的 DLL hell 问题。

下面来介绍一个这个机制。

这个机制是通过文件名，来控制共享库(Shared Library)的版本，它有三个名字，分别又有不同的目的。

1. 第一个是共享库的实际文件名(Real Name)，

    它是编译器产生共享库时或人为修改名字后的文件名，该实际文件名就是为了直观地控制共享库版本。

    其格式为：lib + math + .so + 主版本号 + 小版本号 + 制作号
    如：libmath.so.1.1.1234

    * lib 是 Linux 系统上的库的约定前缀名，
    * math 是库自已的名字，
    * so 是共享库的后缀名，
    * 1.1.1234 是共享库的版本号，

    格式：主版本号 + 小版本号 + 制作(build)号

    * 主版本号 - 代表当前共享库的版本，
    如果共享库提供的接口函数有变化的话，那么这个版本号就要加壹(1)；
    * 小版本号 - 如果引入了新的特性(Feature)的话，那么这个版本号就要加壹(1)；
    * 制作号　 - 一般仅表示修正了Bug。

2. 第二个是共享库的简短文件名(soname - Short for shared object name)

    它是可执行程序加载它时，要寻找的文件名。

    其格式为：lib + math + .so + 主版本号

    如：libmath.so.1

    注：在编译链接生成一个实际文件名的共享库时，同时也将简短文件名写进了共享库的文件头里面。

    可以用此命令来查看:

   ```shell
   readelf -d 共享库的实际文件名
   ```

3. 第三个是共享库的连接文件名(Link Name)

	* 是专门为可执行程序生成阶段链接共享库时用的名字，不带任何版本信息的。
	* 其格式为：lib + math + .so
		* 如：libmath.so。
	* 注：大多数 lib库名.so 只是一个链接，以 Ubuntu10.10 为例:

   ```
   $ ls -l /usr/lib/libm.so*
   lrwxrwxrwx 1 root root 14 2012-03-12 10:56 /usr/lib/libm.so -> /lib/libm.so.6
   $ ls -l /lib/libm.so.6
   lrwxrwxrwx 1 root root 14 2012-03-12 10:56 /lib/libm.so.6 -> libm-2.12.1.so
   $ ls -l /lib/libm-2.12.1.so
   -rw-r--r-- 1 root root 149392 2012-03-07 06:46 /lib/libm-2.12.1.so
   ```

	1. 在可执行程序链接共享库时
		1. 首先会用到共享库的连接文件名，通过连接文件名找到共享库；
		2. 然后会取出共享库的简短文件名，并写在共享库自己的文件头里面。
	2. 在可执行程序加载共享库时
		* 通过共享库的简短文件名在给定的路径下寻找共享库。

### 代码示例

下面通过代码来说明一下，并介绍系统的一些有用的工具

#### 编写代码

1. demo.h 文件内容

   ```c
   // 声明 - 共享库对外接口函数 */
   void display(void);
   ```

2. demo.c 文件内容：

   ```c
   #include <stdio.h>
   #include "demo.h"
   // 定义 - 共享库对外接口函数 */
   void display(void) {
    printf("display\n");
   }
   ```

3. main.c 文件内容

   ```c
   #include "demo.h"
   // 调用共享库的可执行程序的主函数 */
   int main(void) {
    display();
    return 0;
   }
   ```

#### 生成共享库

1. 编译源代文件

   ```shell
   gcc -g -Wall -fPIC -c demo.c -o demo.o
   ```

2. 关联 简短文件名(libdemo.so.0) 与 真实文件名(libdemo.so.0.0.0) 且 链接生成共享库

   ```shell
   gcc -shared -Wl,-soname,libdemo.so.0 -o libdemo.so.0.0.0 demo.o
   ```

3. 用系统提供的工具查看共享库

   ```shell
   readelf -d libdemo.so.0.0.0
   ```

    可在文件头中看到如下内容:

   ```
   ox00000000000e(SONAME) library soname: [libhello.so.0]
   ```

	例如:

   ```
   readelf -d /lib/x86_64-linux-gnu/libm.so.6

   Dynamic section at offset 0x104da8 contains 29 entries:
     Tag        Type                         Name/Value
    0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
    0x000000000000000e (SONAME)             Library soname: [libm.so.6]
    0x000000000000000c (INIT)               0x5400
    0x000000000000000d (FINI)               0x741b8
    0x0000000000000019 (INIT_ARRAY)         0x304d90
    0x000000000000001b (INIT_ARRAYSZ)       8 (bytes)
    0x000000000000001a (FINI_ARRAY)         0x304d98
    0x000000000000001c (FINI_ARRAYSZ)       8 (bytes)
    0x0000000000000004 (HASH)               0x1030a0
    0x000000006ffffef5 (GNU_HASH)           0x280
    0x0000000000000005 (STRTAB)             0x3f10
    0x0000000000000006 (SYMTAB)             0x1750
    0x000000000000000a (STRSZ)              3284 (bytes)
    0x000000000000000b (SYMENT)             24 (bytes)
    0x0000000000000003 (PLTGOT)             0x305000
    0x0000000000000002 (PLTRELSZ)           720 (bytes)
    0x000000000000000d (FINI)               0x741b8
    0x0000000000000019 (INIT_ARRAY)         0x304d90
    0x000000000000001b (INIT_ARRAYSZ)       8 (bytes)
    0x000000000000001a (FINI_ARRAY)         0x304d98
    0x000000000000001c (FINI_ARRAYSZ)       8 (bytes)
    0x0000000000000004 (HASH)               0x1030a0
    0x000000006ffffef5 (GNU_HASH)           0x280
    0x0000000000000005 (STRTAB)             0x3f10
    0x0000000000000006 (SYMTAB)             0x1750
    0x000000000000000a (STRSZ)              3284 (bytes)
    0x000000000000000b (SYMENT)             24 (bytes)
    0x0000000000000003 (PLTGOT)             0x305000
    0x0000000000000002 (PLTRELSZ)           720 (bytes)
    0x0000000000000014 (PLTREL)             RELA
    0x0000000000000017 (JMPREL)             0x5130
    0x0000000000000007 (RELA)               0x5010
    0x0000000000000008 (RELASZ)             288 (bytes)
    0x0000000000000009 (RELAENT)            24 (bytes)
    0x000000006ffffffc (VERDEF)             0x4f38
    0x000000006ffffffd (VERDEFNUM)          5
    0x000000000000001e (FLAGS)              STATIC_TLS
    0x000000006ffffffe (VERNEED)            0x4fe0
    0x000000006fffffff (VERNEEDNUM)         1
    0x000000006ffffff0 (VERSYM)             0x4be4
    0x000000006ffffff9 (RELACOUNT)          3
    0x0000000000000000 (NULL)               0x0
   ```

4. 先手动生成共享库的连接文件名，在下面可执行程序链接时要用：

   ```shell
   ln -s libdemo.so.0.0.0 libdemo.so
   ```

5. 可执行程序链接共享库：

   ```shell
   gcc -g -Wall -c main.c -o main.o -I.
   gcc -o main main.o -Wl,-rpath=./ -L. -ldemo
   ```

	注：-l 选项链接的库的时候，只会查找出现在它前面的文件中所需要链接的符号.

6. 用系统提供的工具查看编译出来的可执行程序:

   ```
   readelf -d main | grep libhello
   Tag Type Name/Value
   0x000000000001 (NEEDED) Shared library: [libdemo.so.0]
   ```

7. 运行该可执行程序时，需要将共享库拷贝到系统目录。

	注：Ubuntu 系统中 /etc/environment 文件里的 PATH 环境变量指定的目录。

	还有两种办法:

	* 第一种使用环境变量 LD_LIBRARY_PATH ;<br />
	* 第二种使用 gcc 的编译链接参数 -Wl,-rpath=./ -L. 来指定共享库与可执行程序在同一目录下；

8. 可执行程序运行时，通过共享库的简短文件名在给定的路径下寻找共享库，再手动生成共享库的简短文件名：

   ```shell
   ln -s libdemo.so.0.0.0 libdemo.so.0
   ```

#### 生成简短文件名

Linux 系统提供一个 ldconifg 命令专门为共享库生成简短文件名的，以便可执行程序在加载共享库时可以通过简短文件名找到共享库。
同时该命令也加速加载共享库，它把系统的共享库信息放到一个缓存文件中，这样可以提高查找速度。
可以用下面命令看一下系统已有的被缓存起来的共享库信息:

```shell
$ ldconfig -p
```

在 Ubuntu 下重新缓存共享库信息用如下命令:

```shell
sudo ldconfig
```

当升级后，小版本号变化时，共享库的简短文件名是不变的.
如：libdemo.so.0.0.0 变为 libdemo.so.0.1.0
所以需要重新把共享库的简短文件名的那个连接文件指向新版本的共享库就可以了。
这时候你的应用程序就自动升级了。

注：调用 ldconfig 命令，系统会帮你修改那个共享库的简短文件名的那个连接文件，并把它指向新的版本。

当升级后，主版本号变化时，共享库的简短文件名就要加壹(1)了！
如：libdemo.so.0.0.0 变为 libdemo.so.1.0.0
这时候再运行 ldconfig 命令，就会产生共享库的简短文件名的两个连接文件:

```
libhello.so.0 => libhello.so.0.0.0
libhello.so.1 => libhello.so.1.0.0
```

尽管共享库升级了，但是你的程序依旧用的是旧的共享库(libhello.so.0 => libhello.so.0.0.0)，
并且新旧两个共享库之间并不会相互影响。

问题是如果更新的共享库只是增加一些接口，并没有修改已有的接口，也就是说可以向前兼容，
但是这时候它的主版本号却增加壹(1)了，你的应用程序也想调用新的共享库，该如何办呢？

只能手工来做此事了，因为此时的 共享库的真实文件名 与 共享库的简短文件名 的主版本号不一致了！

```
ln -s libdemo.so.1.0.0 libdemo.so.0
```

如果编译共享库的时候没有指定共享库的简短文件名会怎么样呢？

在生成共享库的时候就没有将共享库的简短文件名放到库的文件头里面。

在可执行程序链接共享库的时候，就把共享库的链接文件名放到可执行程序的文件头里面。

这种方式会给程序员很大程度的便利性，但一不小心，就会掉进 DLL hell 里面。建议不要这样做!!!

1. 指定加载共享库的路径 LD_LIBRARY_PATH 优先与 PATH 环境变量；
2. ldd <wbr> <wbr> <wbr> <wbr> <wbr> 可以查看 可执行程序 或 共享库 所依赖的其它共享库信息；
3. nm <wbr> <wbr> <wbr> <wbr> <wbr> <wbr> 可以查看 可执行程序 或 静态/共享库 中暴露的接口；
4. ldconfig 可以自动生成共享库的简短文件名的连接文件，并提供缓存加速查找；
5. readelf 可以查看 elf 文件的信息，如：依赖的库、自身的简短文件名；
6. objdump <wbr> 与 readelf 相类似;

## References

在网上找到一篇很棒的文章: <a title="http://www.yolinux.com/TUTORIALS/LibraryArchives-StaticAndDynamic.html" href="http://www.yolinux.com/TUTORIALS/LibraryArchives-StaticAndDynamic.html" target="_blank">http://www.yolinux.com/TUTORIALS/LibraryArchives-StaticAndDynamic.html</a>

翻译并根据实际情况进行了小小修改,仅关注Linux下动态共享库(Dynamic shared library .so)的开发.
