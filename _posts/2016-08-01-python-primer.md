---
title: Python Primer
---

## Introduction

This article is a bunch of good python programming practices accumulated in working.

## Table of Contents

* TOC
{:toc}

<!--more-->

## Style

### The Zen of Python

```
python -c 'import this'
The Zen of Python, by Tim Peters

Beautiful is better than ugly.
Explicit is better than implicit.
Simple is better than complex.
Complex is better than complicated.
Flat is better than nested.
Sparse is better than dense.
Readability counts.
Special cases aren't special enough to break the rules.
Although practicality beats purity.
Errors should never pass silently.
Unless explicitly silenced.
In the face of ambiguity, refuse the temptation to guess.
There should be one-- and preferably only one --obvious way to do it.
Although that way may not be obvious at first unless you're Dutch.
Now is better than never.
Although never is often better than *right* now.
If the implementation is hard to explain, it's a bad idea.
If the implementation is easy to explain, it may be a good idea.
Namespaces are one honking great idea -- let's do more of those!
```

### Readability Counts

### WhiteSpace

* 4 spaces per indentation level.
* No hard tabs.
* **Never** mix tabs and spaces.
* One blank line between functions and classes.
* Add a space after "," in dicts, lists, tuples, & argument lists, and after ":" in dicts, but not before.
* Put spaces around assignments & comparisons (except in argument lists).
* No spaces just inside parentheses or just before argument lists.
* No spaces just inside docstrings.

### Naming

* joined_lower for functions, methods, attributes
* joined_lower or ALL_CAPS for constants
* PascalCase for classes
* camelCase only to conform to pre-existing conventions
* Attributes: `interface`, `_internal`, `__private`
	* But try to avoid the __private form.

      ```
      >>> class T(object):
      ...     def __init__(self):
      ...             self.__xprop = 1
      ...
      >>> t = T()
      >>> t
      <__main__.T object at 0x7ff7e00c1fd0>
      >>> t.__dict__
      {'_T__xprop': 1}
      ```
* `type_`, `class_` for name conflicts with keywords

### Long Lines & Continuations

* Keep lines below 80 chars in length.
	* Use implied line continuation inside parentheses/brackets/braces:

      ```python
      def __init__(self, task_id, user_id, version,
		  quality, quatity):
		  output = user_id + ':'
			+ 'task_id'
      ```

	* Use backslashes as a last resort:

      ```python
      self.files = \
          [os.path.join(vtk, fname) for fname in os.listdir('VTK')]
      ```

		Backslashes are fragile; they must end the line they're on. If you add a space after the backslash, it won't work any more.

### Long Strings

* Adjacent literal strings are concatenated by the parser:
* The string prefixed with an "r" is a "raw" string. Backslashes are not evaluated as escapes in raw strings. They're useful for regular expressions and Windows filesystem paths.
* The parentheses allow implicit line continuation.

  ```python
  text = ('Long strings can be made up '
      'of several shorter strings.')
  ```

### Compund Statements

Good:

```python
if r.method != 'GET':
    Logger.warn('unsupported request method')
parse(request)
process(request)
send(response)
```

Bad:

```python
if r.method != 'GET': Logger.warn('unsupported request method')
parse(request); process(request); send(response)
```

### Assert

Used to define user constraints, not input.

```python
assert x == 1, 'not equal'
# is equalivent to
if __debug__ and not x == 1:
	raise AssertionError('not equal')
```

`__debug__` is True by default.

### Function

A method should do one thing and only one thing
However many lines of code it takes to do that one thing is how many lines it should have.
If that "one thing" can be broken into smaller things, each of those should have a method.

10 LoC per function is a good practice.

### Exception Handling

>
Exceptions allow error handling to be organized cleanly in a central or high-level place within the program structure.

[Python Exceptions](http://docs.python.org/library/exceptions.html)

* Catch What You Can Handle
* Abstract exception when raise again
    * FatalError
    * LogicalError
    * Warnings
* Exception should contains useful information
    * exec context
    * error cause

As of Python 3, exceptions must subclass BaseException.

```python
try:
    query(stmt)
except: # catch *all* exceptions
    rollback()
    raise
else:
    commit()
```

```python
try:
    do_sth()
except:
    Logger.error('stack trace:\n{}'.format(traceback.format_exc()))
finally:
    # regardless of success or error
    post_process()
```

```
BaseException
 +-- SystemExit
 +-- KeyboardInterrupt
 +-- GeneratorExit
 +-- Exception
      +-- StopIteration
      +-- StandardError
      |    +-- BufferError
      |    +-- ArithmeticError
      |    |    +-- FloatingPointError
      |    |    +-- OverflowError
      |    |    +-- ZeroDivisionError
      |    +-- AssertionError
      |    +-- AttributeError
      |    +-- EnvironmentError
      |    |    +-- IOError
      |    |    +-- OSError
      |    |         +-- WindowsError (Windows)
      |    |         +-- VMSError (VMS)
      |    +-- EOFError
      |    +-- ImportError
      |    +-- LookupError
      |    |    +-- IndexError
      |    |    +-- KeyError
      |    +-- MemoryError
      |    +-- NameError
      |    |    +-- UnboundLocalError
      |    +-- ReferenceError
      |    +-- RuntimeError
      |    |    +-- NotImplementedError
      |    +-- SyntaxError
      |    |    +-- IndentationError
      |    |         +-- TabError
      |    +-- SystemError
      |    +-- TypeError
      |    +-- ValueError
      |         +-- UnicodeError
      |              +-- UnicodeDecodeError
      |              +-- UnicodeEncodeError
      |              +-- UnicodeTranslateError
      +-- Warning
           +-- DeprecationWarning
           +-- PendingDeprecationWarning
           +-- RuntimeWarning
           +-- SyntaxWarning
           +-- UserWarning
           +-- FutureWarning
           +-- ImportWarning
           +-- UnicodeWarning
           +-- BytesWarning
```

### Docstrings & Comments

Docstrings = **How to use** code

Comments = **Why** (rationale) & **how code works**

Docstrings explain **how** to use code, and are for the **users** of your code. Uses of docstrings:

* Explain the purpose of the function even if it seems obvious to you, because it might not be obvious to someone else later on.
* Describe the parameters expected, the return values, and any exceptions raised.
* If the method is tightly coupled with a single caller, make some mention of the caller (though be careful as the caller might change later).

Comments explain **why**, and are for the **maintainers** of your code. Examples include notes to yourself, like:

Docstrings are useful in interactive use (help()) and for auto-documentation systems.

False comments & docstrings are worse than none at all. So keep them up to date! When you make changes, make sure the comments & docstrings are consistent with the code, and don't contradict it.

[PEP 257: Docstring Convertions](http://www.python.org/dev/peps/pep-0257/)

```python
# !!! BUG: ...
# !!! FIX: This is a hack
# ??? Why is this here?

def process_request(request):
    '''process the user request and send back response in json format
    raise InvalidRequestException on parsing error
    '''
    ...
```

#### Sphinx-apidoc

```python
def create_task(task_id):
    '''create task with id = task_id

    :param task_id: task id
    :type task_id: int or long
    :rtype: Task object

    ::

        first line code
        second line code
```

### Importing

**Don't use wildcard import.**

```python
from module import *
```

1. standard library imports
2. related third party imports
3. local application/library specific imports

### Module

#### Module Structure

```python
"""module docstring"""

__all__ = ['classname', 'funcname']

# imports
# constants
# exception classes
# interface functions
# classes
# internal functions & classes

def main(...):
	...

if __name__ == '__main__':
	main(...)
```

### Scripting

#### Script Structure

```python
#!/usr/bin/env python
#-*- coding: utf-8 -*-

"""module docstring
description
"""

# the same as module afterwards
```

#### Shebang

```python
#!/usr/bin/env python
#!/usr/bin/python
#!/usr/bin/python2
#!/usr/bin/python3
#!/usr/local/bin/python3
#!/home/oxnz/python-3.4/bin/python3.4
```

#### Encoding

BOM
: Byte Order Mark

```python
#-*- coding: utf-8 -*-
```

### Packages

```
package/
    __init__.py
    module1.py
    subpackage/
        __init__.py
        module2.py
```

### Unit Testing

```shell
python -m unittest discover
```

```python
import unittest

def SimulatorTest(unittest.TestCase):
    def test_simulate(self):
        task_id = 124
        sim = Simulator(task_id)
        self.assertEqual(task_id, sim.task_id, 'inconsistent task_id')

def HelperTest(unittest.TestCase):
    def test_exec_cmd(self):
        with self.assertRaises(OSError):
            Helper.exec_cmd(['non_exists_cmd'])

if __name__ == '__main__':
    unittest.main()
```

* [Running unittest with typical test directory structure](http://stackoverflow.com/questions/1896918/running-unittest-with-typical-test-directory-structure)

### Practicality Beats Purity

There are always exceptions. From PEP 8:

But most importantly: know when to be inconsistent -- sometimes the style guide just doesn't apply. When in doubt, use your best judgment. Look at other examples and decide what looks best. And don't hesitate to ask!

Two good reasons to break a particular rule:

1. When applying the rule would make the code less readable, even for someone who is used to reading code that follows the rules.
2. To be consistent with surrounding code that also breaks it (maybe for historic reasons) -- although this is also an opportunity to clean up someone else's mess (in true XP style).

... but practicality shouldn't beat purity to a pulp!

## Idioms

### Swap Values

```python
a, b = b, a
```

### Ternary Operator

```python
# b = a > 2 ? 2 : 1
b = 2 if a > 2 else 1
```

### Building Strings from Substrings

```python
colors = ['red', 'orange', 'yellow', 'green', 'blue', 'indigo', 'violet']
rainbow = 'magic'.join(colors)
```

### Use copy for deepcopy

### Use Counter for counting

```python
from collections import Counter
Counter('success')
```

### Lazy evaluation

`yield`

### enum

```python
class Seasons:
    Spring = 0
    Summer = 1
    Autumn = 2
    Winter = 3

class Seasons:
    Sping, Summer, Autumn, Winter = range(4)

def enum(*posarg, **keysarg):
    return type('Enum', (object,), dict(zip(posarg, xrange(len(posarg))), **keysarg))

Seasons = enum('Spring', 'Summer', 'Autumn', 'Winter' = 1)

Seasons = namedtuple('Seasons', 'Spring Summer Autumn Winter')._make(range(4))
```

### Type checking

prefer isinstance than type

```python
if not isinstance(task_id, (int, long)):
    raise BadRequest('invalid task id, integer or long expected')
```

### eval is evil

### is and ==

* is: object identity
* ==: euqal

### Use `in` where possible

* in is generally faster
* This pattern also works for items in arbitrary containers (such as lists, tuples, and sets).
* in is also an operator

```python
for key in d:
    print key

if key in d:
    print 'in'
```

But, `.keys()` is **necessary** when mutating the dictionary:

```python
for key in d.keys():
    d[str(key)] = d[key]
```


### Dictionary `get` Method

`dict.get(key, default)` removes the need for the test

### Dictionary `setdefault` Method

### `defaultdict`

### Building & Splitting Dictionaries

```python
>>> zip((1, 2), ('a', 'b'))
[(1, 'a'), (2, 'b')]
>>> dict(zip((1, 2), ('a', 'b')))
{1: 'a', 2: 'b'}
```

### Testing for Truth Values

```python
a = 2
b = 3
1 <= a < b <= 10 # True
```

#### Condition Test

```python
if cluster is not None:
```

### Index & Item

#### enumerate

```python
arr = [1, 2, 3, 4, 5]
for idx, elem in enumerate(arr, 0):
    print idx, elem
```

### Default Parameter Values

### String Formatting

Prefer `format` than `%`

#### `%` String Formatting

#### `format`

### List Comprehensions

#### product

```python
import itertools

suit = itertools.product(['A', 'B'], (1, 2, 3))
```

### Generator Expressions

### Sorting

#### Soring with DSW

DSU = Decorate-Sort-Undecorate

#### Sorting With Keys

### Generators

### Reading Lines From Text/Data Files

```python
with open('input') as f:
    for line in f:
        do_sth_with(line)
```

### Decorator

```python
@property
def code(self):
    return self._code

@staticmethod
def create_task(args):
    return Task(args)
```

>
Though classmethod and staticmethod are quite similar, there's a slight difference in usage for both entities: classmethod must have a reference to a class object as the first parameter, whereas staticmethod can have no parameters at all.

#### Define new decorators

```python
def jsonify_api(func):
    '''decorator used to jsonify web api'''
    @functools.wraps(func)
    def decorator(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except NotFound as e:
            return jsonify({'code': 1, 'error': e.message}), 404
        except Exception as e:
            return jsonify({'code': 1, 'error': e.message}), 500
    return decorator

def synchronized(func):
    '''decorator used to synchronized on lock'''
    func.__lock__ = threading.Lock()
    @functools.wraps(func)
    def decorator(*args, **kwargs):
        with func.__lock__:
            return func(*args, **kwargs)
    return decorator

def synchronized(lock):
    def decorator(func):
        def sync_func(*args, **kwargs):
            with lock:
                return func(*args, **kwargs)
        return sync_func
    return decorator
```

### `with` statement

```python
class TransactionalSession(object):
    def __init__(self):
        self._transactional_session = scoped_session()

    @property
    def transactional_session(self):
        return self._transactional_session

    def __enter__(self):
        return self.transactional_session

    def __exit__(self, excpt_type, excpt_value, excpt_traceback):
        if excpt_type is None:
            self.session.commit()
            return True
        else:
            self.session.rollback()
            return False

# or use contextmanager
from contextlib import contextmanager
@contextmanager
def transactional_session():
    session = scoped_session()
    try:
        yield session
        session.commit()
    except:
        session.rollback()
        raise
# usage
with TransactionalSession() as session:
    session.add(task)
with transactional_session() as session:
    session.add(task)
```

### EAFP is preferable to LBYL

* "It's Easier to Ask for Forgiveness than Permission.”
* “Look Before You Leap”

```
try:            vs     if ...:
except:
```

### Simple is Better Than Complex

### Don't reinvent the wheel

### Tips

* [Style Guide for Python Code](https://www.python.org/dev/peps/pep-0008/)
* don't commit commented out code
* don't repeat yourself
* don't return negative number to shell
* no magic numbers
* no hard coded constants

PEP = Python Enhancement Proposal

## Debug

### Logging

#### logging

loggins is thread-safe only, not process-safe.

```python
import logging

logging.basicConfig(
    level = logging.DEBUG,
    filename = 'log.txt',
    filemode = 'w',
    format = '%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
)

# and log to console at the same time
console = logging.StreamHandler()
console.setLevel(logging.ERROR)
formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
console.setFormatter(formatter)
logging.getLogger(__name__).addHandler(console)
```

```python
logger = logging.getLogger(__file__)
console = logging.StreamHandler()
console.setLevel(logging.DEBUG)
logging.addHandler(console)
```

#### syslog

```python
import syslog

class Logger(object):
    '''log options:
    LOG_PID, LOG_CONS, LOG_NDELAY, LOG_NOWAIT and LOG_PERROR
    if defined in <syslog.h>.
    '''
    syslog.openlog(logoption = syslog.LOG_PID, facility = syslog.LOG_LOCAL0)

    @staticmethod
    def log(priority, message):
        '''priority levels:
        LOG_EMERG, LOG_ALERT, LOG_CRIT, LOG_ERR, LOG_WARNING,
        LOG_NOTICE, LOG_INFO, LOG_DEBUG.
        '''
        syslog.syslog(priority, message)

    @staticmethod
    def debug(msg):
        Logger.log(LOG_DEBUG, msg)

    @staticmethod
    def info(msg):
        Logger.log(LOG_INFO, msg)
```

### Disassemble

```python
import dis
dis.dis(func)
```

## Concurrency

### multiprocessing

```python
import contextlib
import multiprocessing as mp

nproc = 48
with contextlib.closing(mp.Pool(nproc)) as pool:
    rows = sum(pool.map(match, tables), ())
```

### thread

thread exception handling ?

### threading

```python
def worker():
    while True:
        item = Q.get()
        do_work(item)
        Q.task_done()

Q = Queue()
for i in range(nworker):
    t = Thread(target=worker)
    t.daemon = True
    t.start()

for item in source():
    Q.put(item)

Q.join()
```

#### Communication

* Lock
* RLock
* Condition
* Semaphore
* BoundedSemaphore
* Event
* **Queue**

```python
mutex = threading.Lock()

def serialized_method(self):
    with mutex:
        do_sth()
```

### thread vs threading

### signal

* A handler for a particular signal, once set, remains installed until it is explicitly reset (except SIGCHLD, which follows the underlying impl)
* There is no way to 'block' signals temporarily from critical sections
* Python signal handlers are called asynchronously, but they can only occur between the 'atomic' instructions of the Python interpreter. This means that signals arriving during long calculations implemented purely in C may be delayed for an arbitray amount of time
* Because the C signal handler always returns, it makes little sense to catch syncrhonous errors like SIGPIPE or SIGSEGV
* Python installs a small number of signal handlers by default:
	* `SIGPIPE` is ignored
	* `SIGINT` is translated into a `KeyboardInterrupt` exception
* Some care must be taken if both signals and threads are used in the same program. The fundamental thing to remmeber in using signals and threads simultaneously is:
	* always perform `signal()` operations in the main thread of execution.
	* Any thread can perform an `alarm()`, `getsignal()`, `pause()`, `settimer()` or `gettimer()`
	* only the main thread can set a new signal handler, and the main thread will be the only one to receive signals (this is enforced by the Python signal module, even if the underlying thread implementation supports sending signals to individual threads). This means that signals can\'t be used as a means of inter-thread communication. Use locks instead.

## Performance

### Benchmarking

```python
from timeit import Timer
Timer('tmp = x; x = y; y = tmp', 'x = 2; y = 3').timeit()
```

### Profile

#### time

```shell
time python script.py
real	0m0.027s
user	0m0.013s
sys	0m0.012s
```

#### cProfile

```shell
python -m cProfile -s cumtime script.py
```

```shell
python -m cProfile script.py
	 3 function calls in 0.000 seconds

Ordered by: standard name

ncalls  tottime  percall  cumtime  percall filename:lineno(function)
     1    0.000    0.000    0.000    0.000 api.py:27(<module>)
     1    0.000    0.000    0.000    0.000 api.py:27(test)
     1    0.000    0.000    0.000    0.000 {method 'disable' of '_lsprof.Profiler' objects}
```

## Design

### Object-oriented

```
Request <-----> Controller
                    ^
                    | Entity
                    v
                 Service
                    ^
                    | Entity
                    v
                   DAO <----> Database
```

* Entity
* Service
* Controller

### Package vs Module

### Design-Patterns

[design patterns impelemented in serveral programming languages](https://github.com/oxnz/design-patterns)

#### Singleton

```python
import Sun
Sun.rise()
Sun.set()
```

* all variables binds to module
* module inited once
* import is thread-safe

#### Mixin

>
Mix-in programming is a style of software development where **units of functionality are created in a class and then mixed in with other classes**.
This might sound like simple inheritance at first, but a mix-in differs from a traditional class in one or more of the following ways. Often a mix-in is not the "primary" superclass of any given class, does not care what class it is used with, is used with many classes scattered throughout the class hierarchy and is introduced dynamically at runtime.
>
There are several reasons to use mix-ins:
>
* they extend existing classes in new areas without having to edit, maintain or merge with their source code;
* they keep project components (such as domain frameworks and interface frameworks) separate;
* they ease the creation of new classes by providing a grab bag of functionalities that can be combined as needed;
* and they overcome a limitation of subclassing, whereby a new subclass has no effect if objects of the original class are still being created in other parts of the software.
>
Python provides an ideal language for mix-in development because it supports multiple inheritance, supports full-dynamic binding and allows dynamic changes to classes.
>
One thing to keep in mind is the order of searching with regard to multiple inheritance. The search order goes from left to right through the base classes, and for any given base class, goes deep into its ancestor classes.
>
When you create mix-ins, keep in mind the potential for method names to clash. By creating distinct mix-ins with well-named methods you can generally avoid any surprises. Lastly, Python supports dynamic changes to the class hierarchy.

```python
class Person(object):
    pass

class Writer:
    def write(self):
        print 'Hello world!'

Person.__bases__ += (Writer,)
Person().write()
```

```python
def mixIn(origClass, mixInClass):
    if mixInClass not in origClass.__bases__:
        origClass.__bases__ += mixInClass

def minxIn(origClass, mixInClass, append=True):
    if mixInClass not in origClass.__bases__:
        if append:
            origClass.__bases__ += (mixInClass,)
        else:
            origClass.__bases__ += (mixInClass,) + origClass.__bases__

import types
def mixIn(origClass, mixInClass, makeAncestor=False):
    '''An even more sophisticated version of this function could return
    (perhaps optionally) a list of methods that clash between the two,
    or raise an exception accompanied by such a list, if the overlap exists.
    '''
    if makeAncestor:
        if mixInClass not in origClass.__bases__:
            origClass.__bases__ = (mixInClass,) + origClass.__bases__
    else:
        # recursively traverse the mix-in ancestor classes in order to
        # support inheritance
        baseClasses = list(mixInClass.__bases__)
        baseClasses.reverse()
        for baseClass in baseClasses:
            mixIn(origClass, baseClass)
        # install the mix-in methods into the class
        for name in dir(mixInClass):
            if not name.startswith('__'): # skip private members
                member = getattr(mixInClass, name)
                if type(member) is types.MethodType:
                    member = member.im_func
                setattr(origClass, name, member)
```

>
One warning regarding dynamic mix-ins: they can change the behavior of existing objects (because they change the classes of those objects). This could lead to unpredictable results, as most classes are not designed with that type of change in mind. The safe way to use dynamic mix-ins is to install them when the application first starts, before any objects are created.
>
Mix-ins are great for improving modularity and enhancing existing classes without having to get intimate with their source code. This in turn supports other design paradigms, like separation of domain and interface, dynamic configuration and plug-ins. Python's inherent support for multiple inheritance, dynamic binding and dynamic changes to classes enables a very powerful technique. As you continue to write Python code, consider ways in which mix-ins can enhance your software.

#### pub/sub

python-message

#### state

python-state

## Modules

### builtin

#### `id`

CPython implementation detail: This is the address of the object in memory.

#### sorting

* `list.sort()`
* `sorted()`

```python
sorted('The quick fox jumped over the lazy dog'.split(), key=str.lower)
sorted(tasks, key=lambda task: task.priority)
sorted(tasks, key=itemgetter(1, 2))
sorted(tasks, key=attrgetter('vm_type', 'vm_image'), reverse=True)
sorted(iterable, key=functools.cmp_to_key(locale.strcoll)) # local-aware sort order
```

### functools

#### singledispatch

```python
@functools.singledispatch
def f(arg):
    print('f: {}'.format(arg))
@f.register(int)
def _(arg):
    print('int: {}'.format(arg))
@f.register(list)
def _(arg):
    print('list: {}'.format(arg))
```

#### partialmethod

```python
class Task(object):
    def __init__(self):
        self._state = 'active'
    @property
    def state(self):
        return self._active
    def set_state(self, state):
        self._state = state
    set_active = partialmethod(set_state, 'active')
    set_inactive = partialmethod(set_state, 'inactive')
```

## Frameworks

### Numerical

* scipy and numpy
* pandas
* SymPy
* matplotlib
* Traits
* Chaco
* TVTK
* VPython
* OpenCV

### Http

### HTTP Reqeusts

[Requests HTTP library for Python](/2016/05/13/python-requests/)

### MySQL

```python
import MySQLdb
import contextlib
import pandas as pd

fields = ('email', 'create_time', 'update_time')
with contextlib.closing(MySQLdb.connect(host='10.20.30.40', port=1234, user='root', pass='root', db='test')) as conn:
    with conn as cursor:
        cursor.execute('SELECT {} from test'.format(fields)
    rows = cursor.fetchall()
    df = pd.DataFrame(rows, columns=fields)
    pd.set_option('display.expand_frame_repr', False)
    print df[df.email != None]
```

### Kafka

#### Consumer

```python
from kafka import KafkaConsumer

topic = 'requests'
brokers = '10.20.30.40:9092,11.22.33.44:9092'
consumer = KafkaConsumer(topic, group_id='cg', bootstrap_servers=brokers, auto_offset_reset='earliest')
for msg_raw in consumer:
    print 'timestamp: {} partition: {} offset: {}'.format(time.strftime('%F %T', time.localtime(int(msg_raw.timestamp/1000.0))), msg_raw.partition, msg_raw.offset)
    msg = Message()
    if msg.ParseFromString(msg_raw.value): proc(msg)
# batch mode
batch = consumer.pool(10000, 10000)
count = sum(map(len, batch.values()))
if count != 0: proc(batch)
```

### Web

#### Flask

```python
app = Flask(__name__)
app.add_url_rule(rule = '/api/<ver>/task/<task_id>', methods = ['POST'],
    endpoint = 'add_task', view_func = self.add_task)
# or
@app.route('/api/v<int:ver>/task/<int:task_id>', methods = ['POST'])
@jsonify_api
def add_task(self, ver, task_id):
    pass

@app.before_request
def pre_process():
    setattr(request, 'timestamp', time.time())

@app.after_request
def post_process(response)
    elapsed = time.time() - request.timestamp
    log.info('elapsed: {}'.format(elapsed)
    return response

if __name__ == '__main__':
    app.run(host='0.0.0.0')
    app.run(host='0.0.0.0', threaded=True, processes=10)
```

[flask.Flask.run](http://flask.pocoo.org/docs/0.12/api/#flask.Flask.run) accepts additional keyword arguments (`**options`) that it forwards to [werkzeug.serving.run_simple](http://werkzeug.pocoo.org/docs/serving/#werkzeug.serving.run_simple) - two of those arguments are threaded (which can set to True to enable threading) and processes (which can set to a number greater than one to have werkzeug spawn more than one process to handle requests).

#### Django

[Django Basics](/2014/02/27/install-django-manually/)

#### bottle.py

### Database

#### SQLAlchemy

Cautions
: Pass Entity across sessions(threads)

* pass committed object id

IOC
: Inversion Of Control

session.flush() communicates a series of operations to the database (insert, update, delete). The database maintains them as pending operations in a transaction. The changes aren't persisted permanently to disk, or visible to other transactions until the database receives a COMMIT for the current transaction (which is what session.commit() does).

[SQLAlchemy: What's the difference between flush() and commit()?](http://stackoverflow.com/questions/4201455/sqlalchemy-whats-the-difference-between-flush-and-commit)

>
tl;dr;
>
1. As a general rule, keep the lifecycle of the session separate and external from functions and objects that access and/or manipulate database data. This will greatly help with achieving a predictable and consistent transactional scope.
2. Make sure you have a clear notion of where transactions begin and end, and keep transactions short, meaning, they end at the series of a sequence of operations, instead of being held open indefinitely.

* [Session Basics](http://docs.sqlalchemy.org/en/rel_1_1/orm/session_basics.html#session-faq-whentocreate)
* [Contextual/Thread-local Sessions](http://docs.sqlalchemy.org/en/rel_1_1/orm/contextual.html#sqlalchemy.orm.scoping.scoped_session.remove)

### Configuration

#### ConfigParser

#### INI

```python
config = ConfigParser.SafeConfigParser()
config.read("test.ini")
sections = config.sections()
options = config.options()
items = config.items()
```

#### JSON

```python
import json

with open('config.json') as f:
	config = json.load(f)
```

#### YAML

```python
import yaml

print yaml.load('''
name: Will
''')
```

## Internals

### MRO

MRO
: Method Resolution Order

* Classic Class
    * from left to right, depth-first
* Modern Class
    * more complicated (C3 MRO)

## Project Anatomy

```
moxile/                      # Project Hosting
    .svn/                    # Version Control
    moxile/                  # Quality Code
        moxile.py
    tests/                   # Unit Testing
        test_moxile.py
    doc/                     # Documentation
        index.rst
        html/
            index.html
    README.txt
    LICENSE.txt              # Licensing
    setup.py                 # Packaging
    MANIFEST.in
```

## Documentation

```shell
sudo pip install -U sphinx
cd moxile
sphinx-quickstart
sphinx-apidoc .. --force -o .
# modify conf.py
sys.path.insert(0, os.path.abspath('/path/to/source/code'))
make html
```

## Deployment

### setup.py

#### File Hierarchy

```
setup.py
src/
    mypkg/
        __init__.py
        module.py
        data/
            tables.dat
```

#### Script

```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

from distutils.core import setup

setup(name = 'platformz',
    version = '0.1.0',
    description = 'an operational platform',
    author = 'oxnz',
    author_email = 'yunxinyi@gmail.com',
    url = 'https://oxnz.github.io',
    packages = ['simulation', 'agent', 'utilities'],
    scripts = ['scripts/simulate', 'scripts/vm-agent'],
    data_files = [('/etc/init.d', ['init-script']),
        ('docs', ['man.1']),
    ]
)
```

python setup.py --help-commands

Standard commands:

* build             build everything needed to install
* build_py          "build" pure Python modules (copy to build directory)
* build_ext         build C/C++ extensions (compile/link to build directory)
* build_clib        build C/C++ libraries used by Python extensions
* build_scripts     "build" scripts (copy and fixup #! line)
* clean             clean up temporary files from 'build' command
* install           install everything from build directory
* install_lib       install all Python modules (extensions and pure Python)
* install_headers   install C/C++ header files
* install_scripts   install scripts (Python or otherwise)
* install_data      install data files
* sdist             create a source distribution (tarball, zip file, etc.)
* register          register the distribution with the Python package index
* bdist             create a built (binary) distribution
* bdist_dumb        create a "dumb" built distribution
* bdist_rpm         create an RPM distribution
* bdist_wininst     create an executable installer for MS Windows
* upload            upload binary package to PyPI
* check             perform some checks on the package

### PIP

```shell
python -m pip download --dest=/path/to/dest elasticsearch
```

## `pythonrc`

```python
#!/usr/bin/env python
#-*- coding: utf-8 -*-
#
# Copyright (c) 2013-2015 Z
# All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

try:
    import readline
    import rlcompleter
    import os
    import atexit
except ImportError as e:
    print(e)
else:
    class TabCompleter(rlcompleter.Completer):
        """Completer that support tab indenting"""
        def complete(self, text, state):
            if not text:
                return ('\t', None)[state]
            else:
                return rlcompleter.Completer.complete(self, text, state)
    readline.set_completer(TabCompleter().complete)
    if 'libedit' in readline.__doc__:
        """Complete filename (tab key)
        http://minix1.woodhull.com/manpages/man3/editline.3.html"""
        readline.parse_and_bind('bind ^I rl_complete')
    else:
        readline.parse_and_bind('tab: complete')
    histfile = os.path.expanduser('~/.pyhistory')
    def savehist(histfile=histfile):
        import readline
        readline.write_history_file(histfile)
    atexit.register(savehist)
    if os.path.exists(histfile):
        readline.read_history_file(histfile)
    del readline, os, atexit, histfile, savehist
```

## References

* [Code Like a Pythonista: Idiomatic Python](http://python.net/~goodger/projects/pycon/2007/idiomatic/handout.html)
* [How can you profile a Python script?](http://stackoverflow.com/questions/582336/how-can-you-profile-a-python-script)
* [Using Mix-ins with Python](http://www.linuxjournal.com/node/4540/print)
* [Python Project Howto](http://infinitemonkeycorps.net/docs/pph/)
* [Documenting Your Project Using Sphinx](http://pythonhosted.org/an_example_pypi_project/sphinx.html)
* [Writing the Setup Script](https://docs.python.org/2/distutils/setupscript.html)
* [reStructuredText Primer](http://www.sphinx-doc.org/en/stable/rest.html)
* [用Python做科学计算](http://old.sebug.net/paper/books/scipydoc/index.html)
