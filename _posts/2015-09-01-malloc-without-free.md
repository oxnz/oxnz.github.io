---
title: "Resource reclaim when exit() called"
---

What REALLY happens when you don't free after malloc?
<!--more-->

{% highlight man %}
EXIT(3)                FreeBSD Library Functions Manual                EXIT(3)

NAME
     exit, _Exit -- perform normal program termination

LIBRARY
     Standard C Library (libc, -lc)

SYNOPSIS
     #include <stdlib.h>

     void
     exit(int status);

     void
     _Exit(int status);

DESCRIPTION
     The exit() and _Exit() functions terminate a process.

     Before termination, exit() performs the following functions in the order
     listed:

           1.   Call the functions registered with the atexit(3) function, in
                the reverse order of their registration.

           2.   Flush all open output streams.

           3.   Close all open streams.

           4.   Unlink all files created with the tmpfile(3) function.

     The _Exit() function terminates without calling the functions registered
     with the atexit(3) function, and may or may not perform the other actions
     listed.  Both functions make the low-order eight bits of the status argu-
     ment available to a parent process which has called a wait(2)-family
     function.
{% endhighlight %}

## What REALLY happens when you don't free after malloc?

>Just about every modern operating system will recover all the allocated memory space after a program exits. The only exception I can think of might be something like Palm OS where the program's static storage and runtime memory are pretty much the same thing, so not freeing might cause the program to take up more storage. (I'm only speculating here.)
>
>So generally, there's no harm in it, except the runtime cost of having more storage than you need. Certainly in the example you give, you want to keep the memory for a variable that might be used until it's cleared.
>
>However, it's considered good style to free memory as soon as you don't need it any more, and to free anything you still have around on program exit. It's more of an exercise in knowing what memory you're using, and thinking about whether you still need it. If you don't keep track, you might have memory leaks.
>
>On the other hand, the similar admonition to close your files on exit has a much more concrete result - if you don't, the data you wrote to them might not get flushed, or if they're a temp file, they might not get deleted when you're done. Also, database handles should have their transactions committed and then closed when you're done with them. Similarly, if you're using an object oriented language like C++ or Objective C, not freeing an object when you're done with it will mean the destructor will never get called, and any resources the class is responsible might not get cleaned up.
>
> -- [stackoverflow](http://stackoverflow.com/questions/654754/what-really-happens-when-you-dont-free-after-malloc)

## What happens to the malloc'ed memory when exit(1) is encountered?

> @Als: I disagree. Calling free recursively on structures that might not have been touched for days or weeks right before you exit is extremely harmful. It thrashes swap, evicts tons of actually-useful data/cache from physical ram, and accomplishes nothing except making valgrind happy. Why do you think Firefox takes 20+ seconds to go away after you click the close button? 
> 
> -- [stackoverflow](http://stackoverflow.com/questions/10588014/what-happens-to-the-malloced-memory-when-exit1-is-encountered)
 

## What happens if you exit a program without doing fclose()?

>It depends on how you exit. Under controlled circumstances (via exit() or a return from main()), the data in the (output) buffers will be flushed and the files closed in an orderly manner. Other resources that the process had will also be released.

If your program crashes out of control, or if it calls one of the alternative _exit() or _Exit() functions, then the system will still clean up (close) open file descriptors and release other resources, but the buffers won't be flushed, etc.

