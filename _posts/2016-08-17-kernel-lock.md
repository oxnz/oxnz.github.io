---
title: Locks In The Kernel
---

## Table of Contents

* TOC
{:toc}

<!--more-->

## 原子操作

```c
atomic_t v;
void atomic_set(atomic_t *v, int i);
atomic_t v = ATOMIC_INIT(0);
int atomic_read(atomic_t *v);
void atomic_add(int i, atomic_t *v);
void atomic_sub(int i, atomic_t *v);
void atomic_inc(atomic_t *v);
void atomic_dec(atomic_t *v);
void set_bit(int nr, void *addr);
void clear_bit(int nr, void *addr);
```

## 信号量 (semaphore)

* 睡眠锁
* 长时间等待
* 进程上下文使用

vs spinlock

* 信号量比自旋锁提供了更好的处理器利用率
* 自旋锁闭信号量拥有更好的系统开销

```c
void sema_init(struct semaphore *sem, int val);
DECLARE_MUTEX(name);
DECLARE_MUTEX_LOCKED(name);
void down(struct semaphore *sem);
int down_interruptible(struct semaphore *sem);
int down_trylock(struct semaphore *sem);
void up(struct semaphore *sem);
```

## 读写锁

一个任务通知另一个任务发生了某个特定的事件，同步两个任务。

```c
void init_rwsem(struct rw_semaphore *sem);
void down_read(struct rw_semaphore *sem);
int down_read_trylock(struct rw_semaphore *sem);
void up_read(struct rw_semaphore *sem);
void down_write(struct rw_semaphore *sem);
int down_write_trylock(struct rw_semaphore *sem);
void up_write(struct rw_semaphore *sem);
// 写改变完成后允许其他读者
void downgrade_write(struct rw_semaphore *sem);
```

## completion

是任务使用的一个轻量级机制；允许一个线程告诉另一个线程工作完成。

```
// static init
DECLARE_COMPLETION(comp);
// dynamic init
struct completion comp;
init_completion(&comp);
void wait_for_completion(struct completion *comp);
void complete(struct completion *comp);
void complete_all(struct completion *comp);
void complete_and_exit(struct completion *comp, long retval);
```

## spinlock

* 不可递归
* 忙等待
* 不可睡眠
* 中断上下文可用
* 短期持有

/usr/src/linux-headers-3.13.0-83/arch/alpha/include/asm/spinlock.h

```c
// static init
spinlock_t lock = SPIN_LOCK_UNLOCKED;
// dynamic init
void spin_lock_init(spinlock_t *lock);
void spin_lock(spinlock_t *lock);
void spin_unlock(spinlock_t *lock);
void spin_lock_irqsave(spinlock_t *lock, unsigned long flags);
void spin_unlock_irqsave(spinlock_t *lock, unsigned long flags);
void spin_lock_irq(spinlock_t *lock);
void spin_unlock_irq(spinlock_t *lock);
void spin_lock_bh(spinlock_t *lock);
void spin_unlock_bh(spinlock_t *lock);
void spin_trylock(spinlock_t *lock);
void spin_trylock_bh(spinlock_t *lock);
```

## rwlock

__raw_read_lock
__raw_write_lock

## seqlock

read/write seq lock

write_sequnlock
write_seqlock
read_seqbegin
read_seqretry

## RCU (read-copy-update)

RCU 是数据同步的一种方式，在当前的 Linux 内核中发挥着重要作用。

RCU 主要针对的数据对象是**链表**，目的是**提高遍历读取数据的效率**，为了达到目的使用 RCU 机制读取数据的时候不对链表进行耗时的加锁操作。
这样在同一时间可以有多个线程同时读取该链表，并且允许一个线程对链表进行修改（修改的时候需要加锁）。

**RCU 适用于需要频繁读取数据，而较少更改数据的情形。**

例如在文件系统中，经常需要查找定位目录，而对于目录的修改并不多，这就是 RCU 发挥作用的最佳场景。

/Documentation/RCU/

RCU 实现过程中主要解决以下问题：

1. 在读取过程中，另外一个线程删除了一个节点。
删除线程可以把这个节点从链表中移除，但是不能直接销毁这个节点，必须等到所有得读取线程读完之后，才能进行销毁操作。RCU 把这个过程称作宽限期（Grace period）。
2. 在读取过程中，另外一个线程插入了一个新节点，而读取线程读到了这个节点，那么需要保证读到的这个节点是完整的。这里涉及到发布订阅机制（publish-subscribe mechanism）。
3. 保证读取链表的完整性。新增或者删除一个节点，不至于导致遍历一个链表从中间断开。但是 RCU 并不保证一定能读到新节点或者不读到删除节点。

```c
struct foo {
    int a;
    int b;
    int c;
};

DEFINE_SPINLOCK(foo_mutex);

struct foo* glob_foo;

void foo_read(void) {
    rcu_read_lock();
    foo *fp = glob_foo;
    if (fp != NULL) do_sth(fp->a, fp->b, fp->c);
    rcu_read_unlock();
}

void foo_update(foo *new_fp) {
    spin_lock(&foo_mutex);
    foo *old_fp = glob_foo;
    rcu_assign_pointer(glob_foo, new_fp);
    spin_unlock(&foo_mutex);
    synchronize_rcu();
    kfee(old_fp);
}
```

linux/rcupdate.h

```c
#define __rcu_dereference_check(p, c, space) \
    ({ \
        typeof(*p) *_________p1 = (typeof(*p)*__force )ACCESS_ONCE(p); \
        rcu_lockdep_assert(c, "suspicious rcu_dereference_check()" \
                      " usage"); \
        rcu_dereference_sparse(p, space); \
        smp_read_barrier_depends(); \
        ((typeof(*p) __force __kernel *)(_________p1)); \
    })
// ...
#define __rcu_assign_pointer(p, v, space) \
    do { \
        smp_wmb(); \
        (p) = (typeof(*v) __force space *)(v); \
    } while (0)
```

## BKL (BigKernel Lock)

## Linux 软中断和工作队列

### 中断处理程序局限性

* 异步方式执行并且可能会打断其他重要代码，甚至是其他中断处理程序。
* 往往对硬件进行操作，需要很高的时限要求，需要效率高，时间短。
* 终端上下文不能阻塞。
* 一般只完成必要的数据拷贝。

### 下半部分机制

下半部的任务是执行与中断处理密切相关但中断处理程序本身并不执行的工作。在下半部工作时，可以响应所有的中断。

### 软中断，tasklet，工作队列

* 大多数时候选择 tasklet
* 需要睡眠选择工作队列
* 执行频率和连续性高时选择软中断

#### 软中断

* 产生后并不是马上可以执行，必须要等待内核调度才能执行。软中断不能被自己打断，只能被硬件中断打断（上班部）。
* 可以并发运行在多个 CPU 上（即使同一类型也可以）。所以软中断必须设计为可重入函数（允许多个 CPU 同时操作），因此也需要使用自旋锁来保护其数据结构。

#### tasklet

* 由于软中断必须使用可重入函数，从而导致设计复杂度变高。作为设备驱动开发者而言，增加了负担。
* 而如果某种应用并不需要在多个 CPU 上并行执行，那么软中断其实是没有必要的。

因此诞生了弥补以上两个弱点的 tasklet:

* 一种特定类型的 tasklet 只能运行在一个 CPU 上，不能并行，只能串行执行
* 多个不同类型的 tasklet 可以并行在多个 CPU 上
* 软中断是静态分配的，在内核编译好之后就不能改变。但 tasklet 就灵活很多，可以在运行时改变（比如添加模块时）。

#### workqueue

软中断和 tasklet 运行在中断上下文中，于是导致了一些问题：

* 不能睡眠
* 不能阻塞


由于中断上下文处于内核状态，没有进程切换，所以如果软中断一旦睡眠或者阻塞，将无法退出这种状态，导致整个内核僵死。所以可阻塞函数不能用在中断上下文中，必须要运行在进程上下文中。因此，可阻塞函数不能用软中断来实现。但它们又往往具有可延迟的特性。

因此在 2.6 版本的内核中出现了在内核态运行的工作队列（替代 2.4 中的任务队列）。它也具有一些可延迟函数的特点（需要被激活和延后执行），但是能够在不同的进程间切换，以完成不同的工作。

### 上半部和下半部

上半部是指中断处理程序，下半部指一些虽然与中断有相关性，但是可以延后执行的任务。

例如网卡收到数据包不一定马上需要处理，适合下半部实现；但用户敲键盘必须马上响应，应该用中断实现。

两者的主要区别在于：

* 中断不能被相同类型的中断打断，而下半部可以被中断
* 中断对于时间非常敏感，而下半部基本上都是一些可延迟的工作

由于两者的这种区别，对于一个工作放在上半部还是下半部有下面4条参考依据：

* 如果一个任务对时间非常敏感，放在中断处理程序中执行
* 如果一个任务和硬件相关，放在中断处理程序中执行
* 如果一个任务要保证不被其他中断（特别是相同的中断）打断，放在中断处理程序中执行
* 其他所有任务，考虑放在下半部执行

Linux 内核工作在进程上下文或者中断上下文。提供系统调用服务的内核代码代表发起系统调用的应用程序运行在进程上下文，代表进程运行；
另一方面，中断处理程序，异步运行在中断上下文，代表硬件运行，中断上下文和特定进程无关。
运行在中断上下文的代码就要受一些限制，不能做以下事情：

1. 睡眠或者放弃 CPU

	因为内核在进入中断之前就会关闭进程调度，一旦睡眠或者放弃 CPU，这时内核无法调度别的进程，系统死掉

2. 尝试获得信号量

	如果获得信号量失败，代码就会睡眠，同1

3. 执行耗时任务

	中断处理程序应该尽可能快，因为内核要响应大量服务和请求，中断上下文占用 CPU 时间太长会严重影响系统功能。

4. 访问用户空间虚拟地址

## References

* [Linux 内核的同步机制，第 1 部分](http://www.ibm.com/developerworks/cn/linux/l-synch/part1/)
* [Linux 锁机制](http://blog.csdn.net/lucien_cc/article/details/7440225)
