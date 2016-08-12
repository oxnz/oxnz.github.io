---
title: fwrite perf issue
---

## Introduction

This article addresses one I/O performance issue in glibc caused by buffer.

<!--more-->

## Table of Contents

* TOC
{:toc}

## Source Code

from stackoverflow: [http://stackoverflow.com/posts/38913312](http://stackoverflow.com/posts/38913312)

```c
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>

int main() {
  size_t bufsz=65536;
  char buf[bufsz];
  FILE *f;
  int r;

  f=fmemopen(buf,bufsz,"w");
  assert(f!=NULL);

  // setbuf(f,NULL);   // UNCOMMENT TO GET THE UNBUFFERED VERSION

  for(int j=0; j<1024; ++j) {
    for(uint32_t i=0; i<bufsz/sizeof(i); ++i) {
      r=fwrite(&i,sizeof(i),1,f);
      assert(r==1);
    }
    rewind(f);
  }

  r=fclose(f);
  assert(r==0);
}
```

## Performance Record

the time cost of the unbuffered version was about twice of the buffered one.
Here's the performance analysis.

fwrite with buffer:

```
Samples: 19K of event 'cycles', Event count (approx.): 14986217099
Overhead  Command  Shared Object      Symbol
  48.56%  fwrite   libc-2.17.so       [.] _IO_fwrite
  27.79%  fwrite   libc-2.17.so       [.] _IO_file_xsputn@@GLIBC_2.2.5
  11.80%  fwrite   fwrite             [.] main
   9.10%  fwrite   libc-2.17.so       [.] __GI___mempcpy
   1.56%  fwrite   libc-2.17.so       [.] __memcpy_sse2
   0.19%  fwrite   fwrite             [.] fwrite@plt
   0.19%  fwrite   [kernel.kallsyms]  [k] native_write_msr_safe
   0.10%  fwrite   [kernel.kallsyms]  [k] apic_timer_interrupt
   0.06%  fwrite   libc-2.17.so       [.] fmemopen_write
   0.04%  fwrite   libc-2.17.so       [.] _IO_cookie_write
   0.04%  fwrite   libc-2.17.so       [.] _IO_file_overflow@@GLIBC_2.2.5
   0.03%  fwrite   libc-2.17.so       [.] _IO_do_write@@GLIBC_2.2.5
   0.03%  fwrite   [kernel.kallsyms]  [k] rb_next
   0.03%  fwrite   libc-2.17.so       [.] _IO_default_xsputn
   0.03%  fwrite   [kernel.kallsyms]  [k] rcu_check_callbacks
```

without buffer:

```
Samples: 35K of event 'cycles', Event count (approx.): 26769401637
Overhead  Command  Shared Object      Symbol
  33.36%  fwrite   libc-2.17.so       [.] _IO_file_xsputn@@GLIBC_2.2.5
  25.58%  fwrite   libc-2.17.so       [.] _IO_fwrite
  12.23%  fwrite   libc-2.17.so       [.] fmemopen_write
   6.09%  fwrite   libc-2.17.so       [.] __memcpy_sse2
   5.94%  fwrite   libc-2.17.so       [.] _IO_file_overflow@@GLIBC_2.2.5
   5.39%  fwrite   libc-2.17.so       [.] _IO_cookie_write
   5.08%  fwrite   fwrite             [.] main
   4.69%  fwrite   libc-2.17.so       [.] _IO_do_write@@GLIBC_2.2.5
   0.59%  fwrite   fwrite             [.] fwrite@plt
   0.33%  fwrite   [kernel.kallsyms]  [k] native_write_msr_safe
   0.18%  fwrite   [kernel.kallsyms]  [k] apic_timer_interrupt
   0.04%  fwrite   [kernel.kallsyms]  [k] timerqueue_add
   0.03%  fwrite   [kernel.kallsyms]  [k] rcu_check_callbacks
   0.03%  fwrite   [kernel.kallsyms]  [k] ktime_get_update_offsets_now
   0.03%  fwrite   [kernel.kallsyms]  [k] trigger_load_balance
```

perf diff:

```
# Event 'cycles'
#
# Baseline    Delta  Shared Object      Symbol                            
# ........  .......  .................  ..................................
#
    48.56%  -22.98%  libc-2.17.so       [.] _IO_fwrite                    
    27.79%   +5.57%  libc-2.17.so       [.] _IO_file_xsputn@@GLIBC_2.2.5  
    11.80%   -6.72%  fwrite             [.] main                          
     9.10%           libc-2.17.so       [.] __GI___mempcpy                
     1.56%   +4.54%  libc-2.17.so       [.] __memcpy_sse2                 
     0.19%   +0.40%  fwrite             [.] fwrite@plt                    
     0.19%   +0.14%  [kernel.kallsyms]  [k] native_write_msr_safe         
     0.10%   +0.08%  [kernel.kallsyms]  [k] apic_timer_interrupt          
     0.06%  +12.16%  libc-2.17.so       [.] fmemopen_write                
     0.04%   +5.35%  libc-2.17.so       [.] _IO_cookie_write              
     0.04%   +5.91%  libc-2.17.so       [.] _IO_file_overflow@@GLIBC_2.2.5
     0.03%   +4.65%  libc-2.17.so       [.] _IO_do_write@@GLIBC_2.2.5     
     0.03%   -0.01%  [kernel.kallsyms]  [k] rb_next                       
     0.03%           libc-2.17.so       [.] _IO_default_xsputn            
     0.03%   +0.00%  [kernel.kallsyms]  [k] rcu_check_callbacks           
     0.02%   -0.01%  [kernel.kallsyms]  [k] run_timer_softirq             
     0.02%   -0.01%  [kernel.kallsyms]  [k] cpuacct_account_field         
     0.02%   -0.00%  [kernel.kallsyms]  [k] __hrtimer_run_queues          
     0.02%   +0.01%  [kernel.kallsyms]  [k] ktime_get_update_offsets_now  
```

## Analysis

After digging into the source code, I found the `fwrite`, which is `_IO_fwrite` in iofwrite.c, is just a wrapper function of the actual write function `_IO_sputn`.
And also found:

    libioP.h:#define _IO_XSPUTN(FP, DATA, N) JUMP2 (__xsputn, FP, DATA, N)
    libioP.h:#define _IO_sputn(__fp, __s, __n) _IO_XSPUTN (__fp, __s, __n)

As the `__xsputn` function is actual the `_IO_file_xsputn`, which can be found as follows:

    fileops.c:  JUMP_INIT(xsputn, _IO_file_xsputn),
    fileops.c:# define _IO_new_file_xsputn _IO_file_xsputn
    fileops.c:versioned_symbol (libc, _IO_new_file_xsputn, _IO_file_xsputn, GLIBC_2_1);

At last, down into the `_IO_new_file_xsputn` function in fileops.c, the related part of code is as follows:

```c
/* Try to maintain alignment: write a whole number of blocks.  */
      block_size = f->_IO_buf_end - f->_IO_buf_base;
      do_write = to_do - (block_size >= 128 ? to_do % block_size : 0);

      if (do_write)
    {
      count = new_do_write (f, s, do_write);
      to_do -= count;
      if (count < do_write)
        return n - to_do;
    }

      /* Now write out the remainder.  Normally, this will fit in the
     buffer, but it's somewhat messier for line-buffered files,
     so we let _IO_default_xsputn handle the general case. */
      if (to_do)
    to_do -= _IO_default_xsputn (f, s+do_write, to_do);
```

On a RHEL 7.2, the `block_size` equals 8192 if buffer was enabled, otherwise equals 1.

So there are to cases:

* case 1: with the buffer enabled

```c
do_write = to_do - (to_do % block_size) = to_do - (to_do % 8192)
```

In our case,
`to_do = sizeof(uint32)`
so the `do_write = 0`, and will call the `_IO_default_xsputn` function.

* case 2: without buffer

`new_do_write` function, after that, `to_do` is zero.
And `new_do_write` is just a wrapper call to `_IO_SYSWRITE`

```
libioP.h:#define _IO_SYSWRITE(FP, DATA, LEN) JUMP2 (__write, FP, DATA, LEN)
```

As we can see, the `_IO_SYSWRITE` is actual the `fmemopen_write` call.
So, the performance difference is caused by the `fmemopen_write` call.
And that was proved by the performance record showed before.

## Non-gnu implementations

### FreeBSD

https://github.com/freebsd/freebsd/blob/master/lib/libc/stdio/fmemopen.c

the snippet below is come from fmemopen in FreeBSD:

```c
/*
	 * Turn off buffering, so a write past the end of the buffer
	 * correctly returns a short object count.
	 */
	setvbuf(f, NULL, _IONBF, 0);
```

So this issue does not exists in FreeBSD

### macOS

macOS uses BSD as the base system implementation, but `fmemopen` was removed. So there's no `fmemopen` function in macOS.
