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

### Docstring

```python
def process_request(request):
    '''process the user request and send back response in json format
    raise InvalidRequestException on parsing error
    '''
    ...
```

### exception

### pythonic

```python
a, b = b, a
```

```python
# b = a > 2 ? 2 : 1
b = 2 if a > 2 else 1
```

```python
arr = [1, 2, 3, 4, 5]
for idx, elem in enumerate(arr, 0):
    print idx, elem
```

```python
>>> zip((1, 2), ('a', 'b'))
[(1, 'a'), (2, 'b')]
>>> dict(zip((1, 2), ('a', 'b')))
{1: 'a', 2: 'b'}
```

```python
a = 2
b = 3
1 <= a < b <= 10 # True
```

```python
with open('input') as f:
    for line in f:
        do_sth_with(line)
```

### Naming Convertions

### Tips

* [Style Guide for Python Code](https://www.python.org/dev/peps/pep-0008/)
* don't commit commented out code
* don't repeat yourself
* don't return negative number to shell
* no magic numbers
* no hard coded constants

## Debug

### Disassemble

```python
import dis
dis.dis(func)
```

## Performance

### Benchmarking

```python
from timeit import Timer
Timer('tmp = x; x = y; y = tmp', 'x = 2; y = 3').timeit()
```

### Profile

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

## Idioms

### EAFP is preferable to LBYL

* "It's Easier to Ask for Forgiveness than Permission.”
* “Look Before You Leap”

```
try:            vs     if ...:
except:
```

## Scripting

### Shebang

```python
#!/usr/bin/env python
#!/usr/bin/python
#!/usr/bin/python2
#!/usr/bin/python3
#!/usr/local/bin/python3
#!/home/oxnz/python-3.4/bin/python3.4
```

### Encoding

BOM
: Byte Order Mark

```python
#-*- coding: utf-8 -*-
```

### importable and executable

```python
if __name__ == '__main__':
    do_sth()
```

## Code Snippets

### Condition Test

```python
if cluster is not None:
```

### Loops

#### product

```python
import itertools

suit = itertools.product(['A', 'B'], (1, 2, 3))
```

### Read Configure File

#### ini format

```python
config = ConfigParser.SafeConfigParser()
config.read("test.ini")
sections = config.sections()
options = config.options()
items = config.items()
```

#### json format

```python
import json

with open('config.json') as f:
	config = json.load(f)
```

### HTTP Reqeusts

[Requests HTTP library for Python](/2016/05/13/python-requests/)

### unittest

### Decorator

```python
@property
def code(self):
    return self._code

@staticmethod
def create_task(cls, args):
    return Task(args)
```

