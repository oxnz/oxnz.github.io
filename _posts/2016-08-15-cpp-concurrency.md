---
title: C++ Concurrency
tags: [c++]
---

## Introduction

C++ concurrency

<!--more-->

## Table of Contents

* TOC
{:toc}

## Hello World

```cpp
#include <iostream>
#include <thread>

int main() {
	auto taskp = make_shared<packaged_task<string()>>([] { return "hello"; });
	auto s = taskp->get_future();
	thread t([&taskp] { (*taskp)(); });
	// or : thread t([&taskp] { taskp->operator()(); });
	t.join();
	cout << s.get() << "\n";
	return 0;
}
```

## Thread Management

### Lanuching

### Waiting

* detach()
* join()
* joinable()

#### Waiting in exceptional circumstances

RAII

```cpp
class thread_guard {
	std::thread& t;
public:
	explicit thread_guard(std::thread &t_) t(t_) {}
	~thread_guard() { if (t.joinable()) t.join(); }
	thread_guard(thread_guard const&) = delete;
	thread_guard& operator=(thread_guard const&) = delete;
};
```

### Background Running

`detach()`ed threads truly run in the background.

ownership and control are passed over to the C++ Runtime Library, which ensures that the resources associated with the thread are correctly reclaimed when the thread exists.

### Passing Arguments

explicit convert argument to target type before passing

```cpp
# explicit convert
std::thread t(func, std::string(buffer));
# explicit pass by reference
std::thread t(func, std::ref(data));
# pass member func
class Test {
public: void foo();
};
Test test;
std::thread t(&Test::foo, &test);
# pass by move
std::unique_ptr<Test> p(new Test);
std::thread t(func, std::move(p));
```

### Transferring ownership of a thread

Many resource-owning types in the C++ Standard Library such as `std::ifstream` and `std::unique_ptr` are movable but not copyable. and `std::thread` is one of them.

This means that the ownership of a particular thread of execution can be moved between std::thread instances.

```cpp
std::thread t1(foo);
std::thread t2 = std::move(t1);
t1 = std::thread(bar);
std::thread t3 = std::move(t2);
t1 = std::move(t3);
```

```cpp
void work(int id);

void proc(int ntask) {
	std::vector<std::thread> tasks;
	for (int i = 0; i < ntask; ++i)
		tasks.push_back(std::thread(work, i));
	std::for_each(tasks.begin(), tasks.end(), std::mem_fn(&std::thread::join));
}
```

### Concurrency Limits

`std::thread::hardware_concurrency()`

### Identifier

`std::thread::id tid = std::this_thread::get_id()`

## Sharing Data

* race condition
* lock-free programming
* software transactional memory (STM)
* mutually exclusive (mutex)
* lock
	* deadlock

### mutexes

lock() and unlock()
std::lock_guard (RAII)

```cpp
mutable std::mutex mutex;

size_type size() const { return m_tasks.size(); }
void modify() {
	std::lock_guard<std::mutex> guard(mutex);
	do_modify();
}
```

Don't pass pointers and references to protected data ourside the scope of the lock, whether by returning them from a function, storing them in externally visible memory, or passing them as arguemtns to user-supplied functions.

* sometimes you need more than one mutex locked in order to protect all the data in an operation.
* sometimes the right thing to do is increase the granularity of the data covered by the mutexes, so that only one mutex needs to be locked
* however, sometimes that's undesirable
	* deadlock potential

### Deadlock

solution
: lock the two mutexes in the same order

`std::lock` provides **all-or-nothing semantics** with regard to locking the supplied mutexes.

```cpp
class T {
private:
	void *m_data;
	std::mutex m_mutax;
public:
	friend void swap(T& lhs, T& rhs) {
		if (&lhs == &rhs) return;
		std::lock(lhs.m_mutex, rhs.m_mutex);
		std::lock_guard<std::mutex> lock_lhs(lhs.m_mutex, std::adopt_lock);
		std::lock_guard<std::mutex> lock_rhs(rhs.m_mutex, std::adopt_lock);
		swap(lhs.m_data, rhs.m_data);
	}
};
```

### Avoiding Deadlock

deadlock doesn't just occur with locks
: two threads by having each thread call `join()` on the `std::thread` object for the other.

* Avoid nested locks
	* Don't acquire a lock if you already hold one
	* If you need to acquire multiple locks, do it as a single action with std::lock in order to acquire them without deadlock
* Avoid calling user-supplied code while holding a lock
	* Cause the user-supplied code may acquire a lock, thus would violate the previous guideline
* Acquire locks in a fixed order
* Use a lock hierarchy
	* this is really a particular case of defining lock ordering, a lock hierarchy can provides a means of checking that the convertion is adhered to at runtime
	* can check this at runtime by assigning layer numbers to each mutex and keeping a record of which mutexex are locked by each thread

### Flexible locking with std::unique_lock

* case1: deferred locking
* case2: where the ownership of the lock needs to be transfered from one scope to another

the flexibility of `std::unique_lock` also allows instances to relinquish thier locks before they're destroyed

### Transferring mutex ownership between scopes

`std::unique_lock` instances don't have to own their associated mutexes, the ownership of a mutex can be transferred between instances by moving the instances around.

* some case such transfer is automatic
	* returning an instance from a function
* other cases you have to do it explicity by calling `std::move()`

### Locking at an appropriate granularity

Not only is it important to choose a sufficiently coarse lock granularity to ensure the required data is protected, but it's also important to ensure that a lock is held only for the operations that actually reuqire it.

In general, a lock should be held for only the minimum possible time needed to perform the required operations.

### Alternative facilities for protecting shared data

* protecting shared data during initialization
	* lazy initialization
		* the infamous double-checked locking pattern
	* use `std::once_flag` and `std::call_once` to handle this situation
		* typically have a lower overhead than using a mutex explicitly
		* `std::once_flag` instances can't be copied or moved

```cpp
std::share_ptr<some_resource> resource_ptr;
std::once_flag resource_flag;

void init_resource() { resource_ptr.reset(new some_resource); }
void foo() {
	std::call_once(resource_flag, init_resource);
	resource_ptr->do_something();
}
```

```cpp
class some_resource;
// only safe in C++11
some_resource& get_some_resource_instance() {
	static some_resource instance;
	return instance;
}
```

#### Protecting rarely updated data structures

reader-writer mutex

The new C++ Standard Library doesn't provide such a mutex out of the box.
but provided by the Boost Library

```cpp
class dns_entry;

class dns_cache {
	std::map<std::string, dns_entry> entries;
	mutable boost::shared_mutex entry_mutex;
public:
	dns_entry find_entry(std::string const& domain) const {
		boost::shared_lock<boost::shared_mutex> lk(entry_mutex);
		std::map<std::string, dns_entry>::const_iterator const it =
			entries.find(domain);
		return (it == entries.end()) ? dns_entry() : it->second;
	}
	void update_or_add_entry(std::string const& domain, dns_entry const& dns_details) {
		std::lock_guard<boost::shared_mutex> lk(entry_mutex);
		entries[domain] = dns_details;
	}
};
```

#### Recursive locking

`std::resursive_mutex` works just like `std::mutex` except that you can acquire multiple locks on a single instance from the same thread. must release all locks before the mutex can be locked by another thread.

* Most of the time, if you think you want a recursive mutex, you probably need to change your design instead
* A common use of recursive mutexes is where a class is designed to be accessible from multiple threads concurrently, so it has a mutex protecting the member data

## Synchronizing concurrent operations

### Waiting for an event

* waiting for an event or other condition

```cpp
bool flag;
std::mutex m;

void wait_for_flag() {
	std::unique_lock<std::mutex> lk(m);
	while (! flag) {
		lk.unlock();
		std::this_thread::sleep_for(std::chrono::milliseconds(100));
		lk.lock();
	}
}
```

Conceptually, a condition varialbe is associated with some vent or other condition, and one or more threads can wait for that condition to be satisfied.

* waiting for a condition with condition variables

`std::condition_variable`
`std::condition_variable_any`

* these 2 cond_var need to work with a mutex in order to provide appropriate synchronization
* the former is limited to working with std::mutex,
* whereas the latter can work with anything that meets some minimal criteria for being mutex-like, hence the _any suffix.
* because `std::condition_variable_any` is more general, there's the potential for additional costs in terms of size, performance, or operating system resources, so std::condition_variable should be preferred unless the additional flexibility is required.

```cpp
std::mutex m;
std::queue<data> q;
std::condition_variable cond_var;

void produce_thread_fn() {
	while (true) {
		data const d = prepare_data();
		std::lock_guard<std::mutex> lk(m);
		q.push(d);
		cond_var.notify_one();
	}
}

void consume_thread_fn() {
	while (true) {
		std::unique_lock<std::mutex> lk(m);
		cond_var.wait(lk, []{ return ! q.empty(); });
		data d = q.front();
		q.pop();
		lk.unlock();
		process(d);
	}
}
```

### Waiting for one-off events with futures

If the condition being waited for is the availability of a particular piece of data, a *future* might be more appropriate

The C++ Standard Library models this sort of one-off event with something called a *future*. If a thread needs to wait for a specific one-off event, it somehow obtains a future representing this event.

* A future may have data associated with it, or it may not
* Once an event has happended (and the future has become ready), the future can't be reset

There are two sorts of futures in the C++ Standard Library:

* unique futures (`std::future<>`)
* shared futures (`std::shared_future<>`)

These are modeled after `std::unique_ptr` and `std::shared_ptr`.

An instance of `std::future` is the one and only instance that refers to its associated event, whereas multiple instances of `std::shared_future` may refer to the same event. In the latter case, all the instances will become ready at the same time.

`std::future<void>`
`std::shared_future<void>` template specializations should be used where there's no associated data.

#### Returning values from background tasks

use `std::async` to start an *asynchronous task*, just as with `std::thread`, if the arguments are rvalues, the copies are created by `moving` the originals. This allows the use of move-only types as both the function object and the arguments.

* `std::launch::defered`: func call defered until either `wait()` or `get()` called on the future
* `std::launch::async`: must run on its own thread
* `std::launch::defered | std::launch::async`: (default) implmenetation may choose

```cpp
void proc() {
	std::future<int> ans = std::async(find_the_answer_to_universe(std::ref(arg1)));
	do_other_stuff();
	std::cout << "answer = " << ans.get() << std::endl;
}
```

Associating a task with a future

* `std::packaged_task<>` ties a future to a function or a callable object

```cpp
std::mutex m;
std::deque<std::packaged_task<void()>> tasks;

void gui_thread_fn() {
	while (! quit_msg_rcvd()) {
		get_and_proc_gui_msg();
		std::packaged_task<void()> task;
		{
			std::lock_guard<std::mutex> lk(m);
			if (tasks.empty()) continue;
			task = std::move(tasks.front());
			tasks.pop_front();
		}
		task();
	}
}

template<typename func>
std::future<void> post_task_for_gui_thread(func f) {
	std::packaged_task<void()> task(f);
	std::future<void> res = task.get_future();
	std:lock_guard<std::mutex> lk(m);
	tasks.push_back(std::move(task));
	return res;
}
```

* making promises

`std::promise<T>` provides a means of setting a value (of type T), which can later be read through an associated `std::future<T>` object.

A `std::promise`/`std::future` pair would provide one possible mechanism for this facility; the waiting thread could block on the future, while the thread providing the data could use the promise half of the pairing to set the associated value and make the future ready.

```cpp
#include <future>

void process_connections(connection_set& connections) {
	for (auto &conn : connections) {
		if (conn.readable()) {
			packet data = conn.read();
			std::promise<payload_type>& p = conn.get_promise(data.id);
			p.set_value(data.payload);
		}
		if (conn.writable()) {
			packet data = conn.top_of_outgoing_queue();
			conn.send(data.payload);
			data.promise.set_value(true);
		}
	}
}
```

exception handling

```cpp
try {
	some_promise.set_value(calc_val());
} catch (...) {
	some_promise.set_exception(std::current_exception());
}
```

only one thread can wait for the `std::future`, if you need to wait for the same event from more than one thread, you need to use `std::shared_future` instead.

>
If the function call invoked as part of `std::async` throws an exception, that exception is stored in the future in place of a stored value, the future becomes ready, and a call to `get()` rethrows that stored exception.
>
(Note: the standard leaves it unspecified whether it is the original exception object that’s rethrown or a copy; different compilers and libraries make different choices on this mat- ter.) The same happens if you wrap the function in a std::packaged_task—when the task is invoked, if the wrapped function throws an exception, that exception is stored in the future in place of the result, ready to be thrown on a call to get().

### Waiting with a time limit

#### Clocks

* now: `std::chrono::system_clock::now()`

the tick period of the clock is specified as a fractional number of seconds

`std::ratio<1, 25>` = ticks 25 times per second

If a clock ticks at a uniform rate (whether or not that rate matches period) and can't be adjusted, the clock is said to be a steady clock.

Typically, `std::chrono::system_clock` will not e steady, because the clock can be adjusted.

#### Duration

`std::chrono::duration<>` class template

`std::chrono::duration_cast<>`, the result is truncated rather than rounded.

duration support arithmetic

```cpp
std::future<int> f = std::async(some_task);
if (f.wait_for(std::chrono::milliseconds(35)) == std::future_status::ready)
	do_sth_with(f.get());
```

#### Time points

```cpp
auto start = std::chrono::high_resolution_clock::now();
do_sth();
auto stop = std::chrono::high_resolution_clock::now();
std::cout << "do_sth() took "
	<< std::chrono::duration<double, std::chrono::seconds>(stop - start).count()
	<< " second(s)" << std::endl;
```

### Using synchronization of operations to simplify code

#### Functional programming with futures

The term *functional programming* (FP) refers to a style of programming where the result of a function call depends solely on the parameters to that function and doesn't depend on any external state.

```cpp
template<typename T>
std::list<T> sequential_quick_sort(std::list<T> input) {
	if (input.empty()) return input;
	std::list<T> result;
	result.splice(result.begin(), input, input.begin());
	T const& pivot = * result.begin();

	auto divide_point = std::partition(input.begin(), input.end(),
		[&](T const& t) { return t < pivot; });
	std::list<T> lower_part;
	lower_part.splice(lower_part.end(), input, input.begin(), divide_point);
	auto new_lower(sequential_quick_sort(std::move(lower_part)));
	auto new_higher(sequential_quick_sort(std::move(input)));
	result.splice(result.end(), new_higher);
	result.splice(result.begin(), new_lower);
	return result;
}
```

#### Synchronizing operations with message passing

CSP (Communicating Sequential Processes): where threads are conceptually entirely separate, with no shared data but with communication channels that allow messages to be passed between them. purely on the basis of how it behaves in response to the messages that it received. Each thread is therefore effectively a state machine: when it receives a message, it updates its state in some manner and maybe sends one or more messages to other threads, with the processing performed depending on the initial state.

## The C++ memory model and operations on atomic types

There are two aspects to the memory model:

* the basic *structual* aspects, which relate to how things are laid out in memory
* the *concurrency* aspects

### Memory model basics

#### Objects and memory locations

The C++ Standard defines an object as "a region of storage".

* One way to ensure there's a defined ordering is to use mutexes
* The other way is to use the synchronization properties of *atomic* operations either on the same or other memory locations to enforce an ordering between the accesses in the two threads
* If more than two threads access the same memory location, each pair of accesses must have a defined ordering
* If there's no enforced ordering between two accesses to a single memory location from separate threads, one or both of these accesses is not atomic, and one or both is a write, then this is a data race and causes undefined behavior

#### Modification orders

Every object in a C++ program has a defined *modification order* composed of all the writes to that object from all threads in the program, starting with the object's initialization.

### Atomic operations and types in C++

An atomic operation is an indivisible operation.

#### The standard atomic types

`x.is_lock_free()`

Operations on `std::atomic_flag` are required to be lock-free

* `std::atomic_flag`
	* `test_and_set()`
	* `clear()`

The standard atomic types are not copyable or assignable in the conventional sense, in that they have no copy constructors or copy assignment operators.

* load
* store
* exchange
* compare_exchange_weak
* compare_exchange_strong
* fetch_add
* fetch_or

The `std::atomic<>` class template

* store operations
	* memory_order_relaxed
	* memory_order_release
	* memory_order_seq_cst
* load operations
	* memory_order_relaxed
	* memory_order_consume
	* memory_order_acquire
	* memory_order_seq_cst
* read-modify-write
	* memory_order_relaxed
	* memory_order_consume
	* memory_order_acquire
	* memory_order_release
	* memory_order_acq_rel
	* memory_order_seq_cst


The default ordering for all operations is `memory_order_seq_cst`.

#### Operations on `std::atomic_flag`

`std::atomic_flag` is the simplest standard atomic type. Must be initialized with `ATOMIC_FLAG_INIT`.

```cpp
std::atomic_flag flag = ATOMIC_FLAG_INIT;
...
flag.clear(std::memory_order_release);
bool x = flag.test_and_set()
```

All operations on an atomic type are defined as atomic, and assignment and copy-construction involve two objects. A single operation on two distinct objects can't be atomic.

The limited feature set makes `std::atomic_flag` ideally suited to use as a spinlock mutex.

```cpp
class spinlock_mutex {
	std::atomic_flag m_flag;
public:
	spinlock_mutex() : m_flag(ATOMIC_FLAG_INIT) {}
	void lock() { while (m_flag.test_and_set(std::memory_order_acquire)); }
	void unlock() { m_flag.clear(std::memory_order_release); }
};
```

#### Operations on `std::atomic<bool>`

The compare/exchange operation is the cornerstone of programming with atomic types.

For `compare_exchange_weak()`, the store might not be successful even if the original value was equal to the expected value, in which case the value of the variable is unchanged and the return value of `compare_exchange_weak()` is `false`. This is most likely to happen on machines that lack a single compare-and-exchange instruction. This is called a *spurious failure*, cause the reason for the failure is a function of timing rather tha the value of the variables.

```cpp
bool expected = false;
extern atomic<bool> b; // set somewhere else
while (! b.compare_exchange_weak(expected, true) && ! expected);
```

#### Operations on `std::atomic<T*>`: pointer arithmetic

* It's neither copy-constructable nor copy-assignable
* It can be constructed and assigned from the suitable pointer values

operations:

* load
* store
* exchange
* compare_exchange_weak
* compare_exchange_strong

The new operations provided by `std::atomic<T*>` are the pointer arithmetic operations.
The basic operations are provided by the `fetch_add` and `fetch_sub` member functions, which do atomic addtion and subtraction on the stored address, and the operators `+=` and `-=`, and both pre- and post-increment and decrement with `++` and `--`, which provide convenient wrappers.

Because both `fetch_add` and `fetch_sub` are read-modify-write operations, they can have any of the memory_ordering tags and can participate in a release sequence.

The operator forms always have `memory_order_seq_cst` semantics.

#### Operations on standard atomic integral types

Only division, multiplication and shift operations are missing.
Since atomic integral values are typically used either as counters or as bitmasks, this isn't a particularly noticeable loss.
Additional operations can easily be done using `compare_exchange_weak` in a loop, if required.

#### The `std::atomic<>` primary class template

In order to use a std::atomic for some user-defined types, this type must have a *trivil* copy-assignment operator.
This means that the type must not have any virtual functions or virtual base classes, and must use the compiler-generated copy-assignment operator.
Not only that, but every base class and non-static data member of a user-defined type must also have a trivil copy-assignment operator.
This essentially permits the compiler to use `memcpy` or an quivalent operation for assignment operations, because there's no user-written code to run.

Finally, the type must be *bitwise equality comparable*.
This goes alongside the assignment requirement:
not only must you be able to copy and object using `memcpy`, but also be able to compare instances using `memcmp`.

This guarantee is required in order for compare/exchange operations to work.

### Synchronizing operations and enforcing ordering

#### The synchronizes-with relationship

The synchronizes-with relationship is something that you can get only between operations on atomic types. It comes only from operations on atomic types.

#### The happens-before relationship

#### Memory ordering for atomic operations:

memory_order_:

* relaxed
* consume
* acquire
* release
* acq_rel
* seq_cst
	* default
	* most stringent

The six options represent three models:

* sequential consistent ordering
	* seq_cst
* acquire_release ordering
	* consume
	* acquire
	* release
	* acq_rel
* relaxed ordering
	* relaxed

These distinct memory-ordering models have varing costs on different CPU arhitectures.

**SEQUENTIALLY CONSISTENT ORDERING**

The default ordering is named *sequentially consistent* because it implies that the behavior of the program is consistent with a simple sequential view of the world.
All threads must see the same order of operations.

**NON-SEQUENTIALLY CONSISTENT MEMORY ORDERING**

There's no longer a single global order of events.
This means that different threads can see different views of the same operations, and any mental model you have of operations from different threads neatly interleaved one after the other must be thrown away.
Threads don't have to agree on the order of events.

In the absense of other ordering constraints, the only requirement is that all threads agree on the modification order of each individual variable.

**RELAXED ORDERING**

Operations on atomic types performed with relaxed ordering don't participate in synchronizes-with relationships.
Operations on the same variable within a single thread still obey happens-before relationships, but there's almost no requirement on ordering relative to other threads.
The only requirement is that accesses to a single atomic variable from the same thread cannot be reordered.

Without any additional synchronization, the modification order of each variable is the only thing shared between therads that are using `memory_order_relaxed`.

>
`std::memory_order` specifies how regular, non-atomic memory accesses are to be ordered around an atomic operation.

## Designing lock-based concurrent data structures

## Designing lock-free concurrent data structures

`cmpxchg`
: compare/exchange

Algorithms that use compare/exchange operations on the data structure often have loops inside. Cause another thread might have modified the data in the meantime, in which case the code will need to redo part of its operation before trying the compare/exchange again.

A wait-free data structure is a lock-free data structure with the additional property that every thread accessing the data structure can complete its operation within a bounded number of steps, regardless of the behavior of other threads. Algorithms that can involve an unbounded number of retries because of clashes with other threads are thus not wait-free.

* why lock-free
	* primary reason: to enable maximum concurrency
	* second reason: robustness
		* If a thread dies while holding a lock, that data structure is broken forever. But if a thread dies partway through an operation on a lock-free data structure, nothing is lost except that thread’s data; other threads can proceed normally.

As already mentioned, lock-free data structures rely on the use of atomic opera- tions and the associated memory-ordering guarantees in order to ensure that data becomes visible to other threads in the correct order.

## Designing concurrent code

### Deviding work between threads

* dividing before processing begins
* dividing data recursively (qsort)
* dividing by task type

### Factors affecting performance

* processor numbers
* data contention
	* high/low contention
* cache ping-pong
	* var/mutex passed back and forth between the caches many times
	* effects of contention with mutexes are usually different from the effects of contention with atomic operations
	* use of a mutex natually serializes threads at the operating system level rather than at the processor level
* false sharing
* data proximity
* oversubscription and excessive task switching
* scalability and Amdahl's law

## Advanced thread management

### Thread Pool

```cpp
namespace mp {
class thread_pool {
	using size_type = std::vector<std::thread>::size_type;
	using lock_type = std::unique_lock<std::mutex>;
public:
	thread_pool(size_type nworker = std::thread::hardware_concurrency())
	: m_workers(), m_tasks(), m_mutex(), m_cmd(command::run), m_cond_v() {
		if (0 == nworker) nworker = std::thread::hardware_concurrency();
		m_workers.reserve(nworker);
		try {
			for (size_type i = 0; i < nworker; ++i)
				m_workers.emplace_back(&thread_pool::_exec, this);
		} catch (...) { join(); throw; }
	}
	thread_pool(const thread_pool&) = delete;
	thread_pool(thread_pool&&) = delete;
	thread_pool& operator=(const thread_pool&) = delete;
	thread_pool& operator=(thread_pool&&) = delete;
	~thread_pool() { join(); }
	
	size_type size() const { return m_workers.size(); }
	size_type capacity() const { return m_workers.capacity(); }

	void pause() {
		{ lock_type lock(m_mutex); m_cmd = command::pause; }
		m_cond_v.notify_all();
	}
	void resume() {
		{ lock_type lock(m_mutex); m_cmd = command::run; }
		m_cond_v.notify_all();
	}
	void stop() {
		{ lock_type lock(m_mutex); m_cmd = command::stop; }
		m_cond_v.notify_all();
	}
	void abort() {
		{ lock_type lock(m_mutex); m_cmd = command::abort; }
		m_cond_v.notify_all();
	}
	void join() {
		stop();
		std::for_each(m_workers.begin(), m_workers.end(),
					  std::mem_fn(&std::thread::join));
		{
			lock_type lock(m_mutex);
			m_workers.clear();
		}
	}
	
	template <typename Fn, typename ...Args>
	auto emplace(Fn&& f, Args&& ...args) -> std::future<std::result_of_t<Fn(Args...)>> {
		using result_type = std::result_of_t<Fn(Args...)>;
		auto taskp = std::make_shared<std::packaged_task<result_type()>>
		(std::bind(std::forward<Fn>(f), std::forward<Args>(args)...));
		std::future<result_type> future = taskp->get_future();
		{
			lock_type lock(m_mutex);
			if (m_cmd != command::run) {
				throw std::runtime_error("submit on a not running thread pool");
			}
			m_tasks.emplace([taskp] { (*taskp)(); });
		}
		m_cond_v.notify_one();
		return future;
	}

private:
	void _exec() {
		for (;;) {
			std::function<void()> task;
			{
				std::unique_lock<std::mutex> lock(m_mutex);
				m_cond_v.wait(lock, [this]() -> bool {
					return m_cmd != command::run || !m_tasks.empty();
				});
				switch (m_cmd) {
					case command::pause: continue;
					case command::stop:
						if (m_tasks.empty()) return;
						break;
					case command::abort: return;
					default:
						break;
				}
				if (m_cmd != command::run && m_tasks.empty()) return;
				task = std::move(m_tasks.front());
				m_tasks.pop();
			}
			task();
		}
	}
private:
	std::queue<std::function<void()>> m_tasks;
	std::mutex m_mutex;
	std::condition_variable m_cond_v;
	std::vector<std::thread> m_workers;
	enum class command { run, pause, stop, abort } m_cmd;
};
}
```

## References

[http://en.cppreference.com/w/cpp/atomic/memory_order](http://en.cppreference.com/w/cpp/atomic/memory_order)
