---
title: Build Systems
---

## Autotools

configure.ac

```configure
AC_INIT[hello], [1.0], [bug@xxx.org])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])
AM_PROG_AR
AC_PROG_RANLIB
AC_PROG_CC
AC_PROG_CXX
AC_CONFIG_FILES([
	Makefile
	echo/Makefile
	])
AC_OUTPUT
```

Makefile.am

```Makefile
bin_PROGRAMS = hello
SUBDIRS=echo
hello_SOURCES = hello.cpp
hello_LDADD = ./echo/echo.a
hello_LDFLAGS = -lstdc++ -lpthread
AM_CPPFLAGS = -Iinclude
AM_CXXFLAGS = -std=c++11
```

```sh
autoreconf --install
./configure
make
```

## CMake

CMakeLists.txt

```cmake
add_executable(test, test.cc)
```

```sh
cmake .
make
```
