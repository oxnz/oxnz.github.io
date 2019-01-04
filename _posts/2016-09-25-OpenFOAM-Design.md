---
title: OpenFOAM Service Design
---

## Table of Contents

* TOC
{:toc}

## 流程

1. 参数
2. 网格化
3. 仿真求解
4. 出结果视频

## 任务调度

任务编排，提高资源利用率，提高执行效率

任务执行时间预估非常重要。对用户决策有很大意义。

### 计算资源分配

何时分配，何时回收，成本控制

<!--more-->

#### 分配策略

1. 一开始分配并发数目的虚拟机
	* \- 可能网格化等过程耗时较长，造成计算资源浪费
	* \+ 开发简单
2. 一开始分配一台虚拟机进行参数校验，网格化，场设置等任务，之后分配并行数目虚拟机进行并行计算，来加快计算速度
	* \- 但是增加了系统之间交互，开发复杂。
	* \+ 无计算资源浪费

#### 回收策略

1. 结果合并之后回收
	* \- 计算资源浪费, 传输结果可能耗时较长，不需要多台计算资源
	* \+ 开发简单
2. 及时回收可以回收资源
	* \- 系统交互多，开发复杂
	* \+ 计算资源利用率高

## 任务提交

涉及到前后端交互，需要定义接口和交互流程。

用户提交任务，应当不涉及虚拟机分配和任务调度。仅记录用户任务。保存任务状态及相关文件以提供完善的容错机制，例如失败重试。

参数校验和转换也应当属于任务提交的一部分。这样以来可以及时反馈错误，简化任务执行。

### 参数校验

参数校验需要 OpenFOAM 参与，因此也涉及到计算资源分配问题。

方案1. 提供专门的 OpenFOAM 实例做参数校验和转换，当作一种服务。

* 资源利用率高
* 可以使用 pool 的概念，弹性的资源分配
* 并发处理较好

**方案2**. 分配任务相关虚拟机

* 资源利用率低
* 无开发负担

**方案3**. 分阶段分别使用方案1和2

* 前期阶段，并发量低，使用方案2来简化开发
* 后期阶段，并发量高，使用方案1来提高资源利用率

### 参数提交

1. 文件与参数同时上传
2. 先设置相关参数，然后上传文件

这样一来，可以判断参数是否合格。另外可以对上传文件有一定约束作用，好做进一步校验。因为文件可能较大，尽量加强验证条件，保证成功率。
在文件上传的时候可以进行文件格式，大小等各个约束条件的验证。

这个方案是在输入文件不包含部分参数的前提下有效。

问题：单机文件上传之后，运行失败导致需要重新上传
方案：上传文件到单独的存储服务器，然后只要用户上传成功，可以多次尝试运行，避免了单点失败问题。
可以挂在磁盘到运行 OpenFOAM 的虚拟机多次运行.另外读写不同磁盘，速度较快。

### 参数转换

参数转换需要在后台进行：

1. 用户可能不了解 OpenFOAM
2. 参数转换可能设计到计算问题

这个过程存在失败可能性，需要定义前后端交互过程。

转换为 OpenFOAM 参数 (成败与否, 警告）

文件:

```
0
constant
system
```

## 任务执行

### 网格化

网格化过程属于 CPU 密集型任务。

网格化后期可以基于大数据建议网格数量。

blockMesh

网格化结果是否展现给用户，需要定义交互模式。

### 场设置

setFields

### 并行化运行

涉及到何时分配并行计算资源及结果合并之后资源何时回收。

1. 任务分割 decomposePar
2. 并行求解
3. 结果合并 reconstructPar

其中结果合并时间不可预知，所以无法准确得知任务进度。

### 仿真求解

#### 求解器选择

#### 进度跟踪

#### 视频合成

用户更改一部分参数，在此提交任务，是否回收？

## 输出

输出结果格式，大小。

### 结果存储

方案1. 存储结果在本机和存储服务器

* \- 同时存储在本机和之前的存储服务器上，传输给用户，网络占用较高，可能影响结果传输速度。
* \+ 便于结果分析和保存。

方案2. 直接传输给用户，不存储结果

* \- 结果丢失
* \- 如果传输失败，需要重试，虚拟机资源得不到及时回收
* \- 需要控制传输流量，增加系统复杂性
* \+ 传输效率较高，没有额外负载

**方案3**. 先传输给用户，然后保存到存储服务器

* \- 如果传输失败，需要重试，虚拟机资源得不到及时回收
* \- 需要控制传输流量，增加系统复杂性
* \+ 用户可以第一时间得到运行结果

**方案4**. 先传输到存储服务器保存，然后从服务器返回结果给用户

* \- 返回结果延迟
* \+ 流量控制容易
* \+ 结果存储控制
* \+ 可以尽快回收计算资源

相对而言，从虚拟机传输结果到存储服务器速度较快，成本较低。
也可以直接写结果到公共的网络磁盘，但是可能存在并行来避免单点失败，需要成功之后，将结果标记为任务结果，回收其他并行资源。

### 传输成功

返回成功给调度系统, 然后调度系统更新任务状态为成功并回收相关资源。

任务执行时间可能较长，考虑通知机制。

## 详细需求

待定

## API

目前由于部分需求不明确，导致 API 设计不完善，需要尽快定下来。

### 交互方式

待定

* HTTP
* RPC

### 任务提交

错误类型

* 参数缺失
* 参数互斥
* 范围不合理
* 转换失败

### 任务执行

错误类型

* 计算资源分配失败
* 任务执行失败
* 结果存储失败
* 客户中止

### 结果传输

* 网络异常
* 客户中止

## TODO

1. OpenFOAM 本身参数校验分散在多个阶段，需要对此进行整理，可能需要重新写验证代码
3. OpenFOAM 本身一次求解过程设计多个阶段，每个阶段需要调用不同的程序执行。需要使用代码整合成为一个服务，和任务调度解耦，以便后续升级和灰度发布。
2. paraFoam 使用的是 Qt 库，需要 GUI 支持，如果在服务器端运行，可能需要更改相关代码。
4. paraFoam 生成的视频格式有限，可能需要使用 FFMPEG 等开源框架进行转换。
4. 安全问题
	* 数据安全(云化的顾虑)
4. 兼容性问题
	* chrome, firefox(浏览器)
	* websocket
	* webgl
	* flash

## Design

### Overview

实例化一个 OpenFOAMProxy 对象，然后执行，收集各种异常。

具体交互方式待定

错误处理:

1. 异常
2. 日志
4. 返回值
3. core 文件

### 输入/输出

* 存储到 NFS 上，平台负责自动挂载 NFS 到 OpenFOAM 指定文件夹。
* 需要约定好输出文件夹，并由平台负责清空。

**Note**

有些求解器会改变输入文件，需要考虑进去。

输入包含两份文档:

* 网格文件
* 输入参数文件
	* 文件格式待定
	* 需要拆分为 OpenFOAM 的输入文件树
		* 拆分失败返回错误
			* IOError
				* No such file or directory
					* mesh
					* parameter
				* Permission Denied
					* write error
			* OFParseInputError
		* 成功
			1. 有场设置，则进行场设置
				* 设置成功，转2
				* 失败，返回错误
					* OFSetFieldError
			2. 无场设置或者已经设置，则进入求解阶段

其中参数校验在前端完成。这里不做参数校验。

>
关于存储，每个任务输入输出我们现在都会通过 NFS 写到 NAS 存储服务器上。提供下载和删除接口给用户。
以后如果用公有云资源的话，存储的备份/快照都不需要自己再去维护了。

### 求解

根据输入进行求解。

用户负责网格化，直接上传网格文件作为输入。

网格设置场、求解。过程中涉及到的错误处理如下:

1. 进程启动
	* 正常，转2
	* 异常，返回错误
		* 包含了输入不存在的错误，所以没有输入检测
		* InvalidSolver
			* NotExists
			* Unsupported
		* PermissionDenied
		* SIGSEGV
		* SIGPIPE
2. 进程结束
	1. 异常，返回错误
		* crash core，平台部负责收集
		* 有日志
	2. 正常，转3
	3. 返回值
		1. 非0，返回错误
			* SolveError
		2. 0，返回成功，进入后处理阶段
3. 并行
	* ParallelError
		* 任务拆分失败
		* 主机解析错误
		* 并行处理网络错误等

>
关于上传之后到仿真之前的一些处理操作，看复杂度吧。现在可以就在我们的 Control sevice 进程里面做，不需要弄的很复杂。可以算算能够支持的任务并行数，以后可以交给别的计算资源去做。

>
错误处理，现在内部是有重试机制的。不过有些情况是需要用户驱动的，稍后会列出各种错误情况，确定错误处理方式。

### 后处理

* 目前返回视频文件
	* 格式未定
		* 默认格式为 ogv
		* UnsupportedFormat
	* 分辨率未定
		* UnsupportedResolution
* 存储到输出文件夹下指定文件中
	* 写错误，返回错误
		* IOError
	* 写成功，返回成功
		* 转码
			* TransformatError

#### API

* HTTP POST host:port/task/{task_id}/update
* format: json

message struct

```
code: int (0: success, other: error)
status: ['ready', 'preproc', 'solve', 'postproc', 'finished']
desc: string description (success: ok, error: exception)
progress: int (solve progress, 1234 = 12.34%)
```

note:

* progress 只在 status 为 solve, code 为 0 时候才有意义。
	* progress 一期暂不启用，实现可以 mockup
* status 为 finished 时候可以回收资源

#### Impl

```python
class OpenFOAMProxy(object):
	@attr
	def state(self):
		['preproc', 'process', 'postproc']
	@attr
	def status(self):
		0/-1
	def preProcess(self):
		setFields()
	def setFields(self):
	def solve(self):
	def postProcess(self):
	def __call__(self):
		preProcess()
		solve()
		postProcess()
```

## ParaViewWeb

### Graphics Setup

```shell
export DISPLAY=:0.0
pvpython /opt/paraviewopenfoam50/lib/paraview-5.0/site-packages/paraview/web/pv_web_visualizer.py --content /opt/paraviewopenfoam50/ --data-dir $FOAM_RUN  --port 8080
```

### The Mesa 3D Graphics Library

#### Build (Offscreen OSMesa)

Installing OSMesa Gallium llvmpipe state-tracker

```shell
yum install libxcb-devel libXext-devel libXt-devel
make -j4 distclean

autoreconf -fi

./configure \
    CXXFLAGS="-O2 -g -DDEFAULT_SOFTWARE_DEPTH_BITS=31" \
    CFLAGS="-O2 -g -DDEFAULT_SOFTWARE_DEPTH_BITS=31" \
    --disable-xvmc \
    --enable-glx \
    --disable-dri \
    --with-dri-drivers="" \
    --with-gallium-drivers="swrast" \
    --enable-texture-float \
    --enable-shared-glapi \
    --disable-egl \
    --with-egl-platforms="" \
    --enable-gallium-osmesa \
    --enable-gallium-llvm=yes \
    --with-llvm-shared-libs

make -j2
make -j4 install
```

## Animation

### Solutions

1. ParaView + X11 + Dedicated Server
	* \+ 单独的机器，有 GPU 资源，渲染形成视屏较快
	* \- 难以计算资源占用
2. ParaView + Mesa (Preferred)
	* \- 开发成本
3. ParaViewWeb + Mesa (Inspecting)

### Downloads

```
347  wget https://github.com/Kitware/ParaView/archive/v5.1.0.tar.gz
591  wget https://mesa.freedesktop.org/archive/12.0.3/mesa-12.0.3.tar.gz
677  wget https://cmake.org/files/v3.6/cmake-3.6.2-Linux-i386.sh
```

### ParaView

```cmake
PARAVIEW_ENABLE_PYTHON      ON
PARAVIEW_BUILD_QT_GUI       OFF
CMAKE_INSTALL_PREFIX        /.../ParaView/install
VTK_USE_X                   OFF
OPENGL_INCLUDE_DIR          /opt/mesa/9.2.2/llvmpipe/include
OPENGL_gl_LIBRARY
OPENGL_glu_LIBRARY          /opt/mesa/9.2.2/llvmpipe/lib/libGLU.[so|a]
VTK_OPENGL_HAS_OSMESA       ON
OSMESA_INCLUDE_DIR          /opt/mesa/9.2.2/llvmpipe/include
OSMESA_LIBRARY              /opt/mesa/9.2.2/llvmpipe/lib/libOSMesa.[so|a]
VTK_USE_MEPG2_ENCODER       ON
FFMPEG ON
```

```shell
git clone git://paraview.org/stage/ParaView.git src
cd src
git submodule update --init
git tag # view release versions
git checkout -b animation v5.1.2
mkdir ../build
cd ../build
ccmake ../src
make
make install
```

#### Configure with CMake

1. In a terminal cd to your build_dir
2. Run ccmake path/to/source_dir that opens a curses dialog
3. Press 'c' to configure.
	* Configuration needs to occur until issues are resolved and CMake presents the option to generate 'g'

#### FFMPEG

libvpx -> webm

```
./configure --enable-shared --enable-libvpx
```

## Schedule

* OpenFOAMProxy 设计与实现
	* 设计 2D
* preproc
	* 具体输入格式未定
	* 涉及到各个参数和文件树对应关系，需要 CAE 专家支持
	* 2D
* proc
	* 2D
* postproc
	* 视屏生成比较复杂，涉及到软件模拟 GPU 方式，要修代码实现
	* 另外可能需要调整颜色等一系列参数
	* 视频生成可以 mockup，不影响其他模块进度
	* 调研 3D
	* 设计与实现 5D
* 镜像制作
	* 系统优化
	* 2D

#### ParaView Python Source Code

```
/usr/local/lib/paraview-5.1/site-packages/paraview/simple.py
def WriteAnimation(filename, **params):
```

#### ParaView Modes

* Stand-alone mode
	* computations and user interface are run on same machine
* Client/Server mode
	* computations are run on a server
* Parallel mode
	* server launches an mpi job on a cluster

#### Visualization Pipeline

```
Reader -> Filter ->  Filter  -> Mapper -> Renderer
                 |           |
                 |-> Filter -|
                 modify and/or
                manipulate data
```

* Reader
	* imports data from a source (e.g. data file)
* Filter
	* modify and/or manipulate data
* Mapper
	* Transform data to geometry (e.g. points, lines, polygons, colours)
* Renderer
	* Converts geometry into an image (e.g. pixels, vector graphics, polygons, volume rendering)

## References

1. [https://github.com/ENGYS/HELYX-OS](https://github.com/ENGYS/HELYX-OS)
2. [https://github.com/Kitware/ParaView](https://github.com/Kitware/ParaView)
3. [Mesa 3D Graphics Library - Off-screen Rendering](http://mesa3d.org/osmesa.html)
4. [ParaView/ParaView And Mesa 3D](http://www.paraview.org/Wiki/ParaView/ParaView_And_Mesa_3D)
5. [ParaViewWeb Source Configure and Build](http://paraviewweb.kitware.com/index.html#!/guide/configure_and_build)
6. [paraview workshop aug 2015](http://www.hpc.mcgill.ca/downloads/paraview_workshop_aug2015/Paraview_Workshop-McGillHPC.pdf)
7. [www.hpc.mcgill.ca](http://www.hpc.mcgill.ca/downloads/)
8. [HOW TO: Install latest geospatial & scientific software on Linux](http://scigeo.org/articles/howto-install-latest-geospatial-software-on-linux.html)
9. [CGAL 4.9 - Manual - install](http://doc.cgal.org/latest/Manual/installation.html)
10. [CGAL releases](https://github.com/CGAL/cgal/releases)
11. [Compiling OpenFOAM](https://proteusmaster.urcf.drexel.edu/urcfwiki/index.php/Compiling_OpenFOAM#CGAL)
12. [Installation/Linux/OpenFOAM-4.0/CentOS SL RHEL](https://openfoamwiki.net/index.php/Installation/Linux/OpenFOAM-4.0/CentOS_SL_RHEL)
13. [ParaView:Build And Install](http://www.paraview.org/Wiki/ParaView:Build_And_Install)
14. [Using VTK to Visualize Scientific Data \(online tutorial\)](http://www.bu.edu/tech/support/research/training-consulting/online-tutorials/vtk/)
15. [ParaView/Python Scripting](https://cmake.org/Wiki/ParaView/Python_Scripting)
16. [FFMPEG compile guide](https://trac.ffmpeg.org/wiki/CompilationGuide)

1. 换热温度
2. 网格敏感
3. 网格转换 非通用 手工转换，看看质量 gmesh -> OpenFOAM mesh
