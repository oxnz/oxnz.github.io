---
title: Python Primer
---

## Introduction

This article is a bunch of good python programming practices accumulated in working.

<!--more-->

## Encoding

BOM
: Byte Order Mark

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

## Read Configure File

```python
config = ConfigParser.SafeConfigParser()
config.read("test.ini")
sections = config.sections()
options = config.options()
items = config.items()
```
