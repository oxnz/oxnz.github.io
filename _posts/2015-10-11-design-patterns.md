---
layout: post
title: Design Patterns
date: 2015-10-11 20:31:38.000000000 +08:00
type: post
published: true
status: publish
categories:
- dev
tags:
- design pattern
---

## Table of Contents

* TOC
{:toc}

<!--more-->

## 设计模式六大原则

* 单一职责
* 里氏替换
	* 子类透明代替父类
* 依赖倒置
	* 高层不应该依赖底层模块，应该依赖其抽象
	* 抽象不应该依赖细节，细节应该依赖抽象
* 接口隔离原则
	* 客户端不应该依赖非必需接口
	* 一个类对另一个类的依赖应建立在最小接口上
* Dimit 法则
	* 一个对象应该对其他对象保持最少了解
* Open-Close
	* 对扩展开放
	* 对修改关闭

## Creational Patterns

### Simple Factory

```
      FileSysWatcher  <------------- Factory
         /      \                createFSWatcher()
MacFSWatcher LinuxFSWatcher          /       \
                      MacFSWatcherFactory LinuxFSWatcherFactory
```

### Factory Method

### Abstract Factory

```
        FileSystemWatcher
               |
       -----------------
      |                |
  WatcherBuilder      Watcher
      |                |
  |---------|    |-------------|
LinuxVer OSXVer LinuxWatcher OSXWatcher
```

```
            Renderer                      Viewer
            /      \                       /   \
MarkdownRenderer reTextRenderer MarkdownViewer reTextViewer

                           ControllerFactory
                             - newRenderer()
                             - newViewer()
                             /          \
        MarkdownControllerFactory     reTextControllerFactory
```

### Builder

将一个复杂对象的构建与它的表示分离，使得同样的构建过程可以创建不同的表示。

```cpp
class Builder {
	void build_part1();
	void build_part2();
	void build_part3();
};
```

### Prototype

通过复制 (克隆 (clone)，拷贝) 一个指定类型的对象来创建更多同类型的对象。这个指定的对象可被称为“原型”对象。

### Singleton/Multiton

## Structual Patterns

### Adapter

为对象提供了一种完全不同的接口。可以使用 Adapter 来实现一个不通的类的常见接口，同时为了避免因为升级和拆解客户代码引起的纠纷。

```
Client ---------------> Target       |--->    Adaptee
                       request()     |    specificRequest()
                          |          |
                          v          |
                        Adapter ------ (adaptee/impl)
                       request()
```

### Bridge

将抽象部分与实现部分分离，使它们都可以独立的变化。又称为柄体 (Handle and body) 模式或者接口 (Interface) 模式。

```
Client    | Abstraction |<--------(imp)-------| Implementator  |
          | operation() | imp->operationImp() | operationImp() |
          `-----^-------`                     `---^--------^---`
                |                                 |        |
        RefinedAbstraction               ConcreteImplA    ConcreteImplB
                                         operationImp()   operationImp()
```

### Composite

### Decorator

动态的给一个对象添加一些额外的职责或行为。通过一个包装对象，也就是装饰来包裹真实的对象。

### Facade

为子系统的一组接口提供一个一致的界面。Facade 模式定义了一个高层接口，这个接口使得这一子系统更加容易使用。

引入外观模式之后，用户只需要直接与外观角色交互，用户与子系统之间的复杂关系由外观角色来实现，从而降低了系统的耦合度。

```
Client -----------> Facade
                      |
             ^--------^-------^
          subsysA  subsysB subsysC
```

### Flyweight

对象结构模式运用共享技术有效地支持大量细粒度的对象。

### Proxy

Provide surrogate or placeholder for another object to **control access** to it.

Lazy initialization

## Behavior Patterns

### Chain of Responsibility

### Command

Encapsulate a request as an object, thereby letting you parameterize clients with different requests, queueor log requests, and support undoable operations.

### Interpreter

### Iterator(Cursor)

用迭代器模式来提供对聚合对象的统一存取，即提供一个外部的迭代器来聚合对象进行访问和遍历，而又不暴露对象的内部结构。

### Mediator

Define an object that encapsulates how a set of objects interact.

Mediator promotes loose coupling by keeping objects from referring to each other explicitly, and it lets you vary thier interaction independently.

### Observer

### State

### Strategy(Policy)

Define a family of algorithms, encapsulate each one, and make them interchangeable.

Strategy lets the algorithm vary independently from clients that using it.

### Template Method

Define the skeleton of an algorithm in an operation, deferring some steps to subclasses.

Template method lets subclasses redefine certain steps of an algorithm without changing the algorithm's structure.

### Visitor

## References

* [Proxy Pattern](https://sourcemaking.com/design_patterns/proxy)
