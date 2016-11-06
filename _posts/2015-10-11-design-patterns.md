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

## Level Arch

* presentation
	* UI, reponsible for visual effect and interaction
* bussiness
	* bussiness logic
* persistence
	* data provider, SQL stmts
* database
	* data

```
     Request
        |
--------v-----------------------------------------------
Presentation Layer | Componenet | Component | Component
--------v----------|------------|-----------|-----------
Business Layer     | Componenet | Component | Component
--------v----------|------------|-----------|-----------
Persistence Layer  | Componenet | Component | Component
--------v----------|------------|-----------|-----------
Database Layer     | Componenet | Component | Component
--------------------------------------------------------
```

### Pro

* 结构简单，容易理解和开发
* 不同技能的程序员可以分工，负责不同的层，天然适合大多数软件公司的组织架构
* 每一层都可以独立测试，其他层的接口通过模拟解决

### Cons

* 一旦环境变化，需要代码调整或增加功能时，通常比较麻烦和费时
* 部署比较麻烦，即使只修改一个小地方，往往需要整个软件重新部署，不容易做持续发布
* 软件升级时，可能需要整个服务暂停
* 扩展性差。用户请求大量增加时，必须依次扩展每一层，由于每一层内部是耦合的，扩展会很困难

## Event-Driven Architecture

```
                            Event
                              |
                              v
                       ---->--->--->--
                       | Event Queue |
                       ---------------
                              |
                      --------v---------
                      | Event Mediator |
                      --------|---------
        .---------------------o--------------------.
        |                     |                    |
 -------v---------    --------v--------    --------v--------
 | Event Channel |    | Event Channel |    | Event Channel |
 --------.--------    --------.--------    --------.--------
         |                    |                    |
---------v---------  ---------v---------  ---------v--------.
| Event Processor |  | Event Processor |  | Event Processor |
|-----------------|  |-----------------|  |-----------------|
|  Module Module  |  |  Module Module  |  |  Module Module  |
|  Module Module  |  |  Module Module  |  |  Module Module  |
-------------------  -------------------  -------------------
```

* 事件队列（event queue）：接收事件的入口
* 分发器（event mediator）：将不同的事件分发到不同的业务逻辑单元
* 事件通道（event channel）：分发器与处理器之间的联系渠道
* 事件处理器（event processor）：实现业务逻辑，处理完成后会发出事件，触发下一步操作

对于简单的项目，事件队列、分发器和事件通道，可以合为一体，整个软件就分成事件代理和事件处理器两部分。

### Pros

* 分布式的异步架构，事件处理器之间高度解耦，软件的扩展性好
* 适用性广，各种类型的项目都可以用
* 性能较好，因为事件的异步本质，软件不易产生堵塞
* 事件处理器可以独立地加载和卸载，容易部署

### Cons

* 涉及异步编程（要考虑远程通信、失去响应等情况），开发相对复杂
* 难以支持原子性操作，因为事件通过会涉及多个处理器，很难回滚
* 分布式和异步特性导致这个架构较难测试

## Microkernel Arch

微核架构（microkernel architecture）又称为"插件架构"（plug-in architecture），指的是软件的内核相对较小，主要功能和业务逻辑都通过插件实现。

内核（core）通常只包含系统运行的最小功能。插件则是互相独立的，插件之间的通信，应该减少到最低，避免出现互相依赖的问题。

```
-------------   ----------   -------------
|  Plug-in  |---|        |---|  Plug-in  |
| Component |   |        |   | Component |
-------------   |  Core  |   -------------
                | System |
-------------   |        |   -------------
|  Plug-in  |---|        |---|  Plug-in  |
| Component |   |        |   | Component |
-------------   ----------   -------------
```

### Pros

* 良好的功能延伸性（extensibility），需要什么功能，开发一个插件即可
* 功能之间是隔离的，插件可以独立的加载和卸载，使得它比较容易部署，
* 可定制性高，适应不同的开发需要
* 可以渐进式地开发，逐步增加功能

### Cons

* 扩展性（scalability）差，内核通常是一个独立单元，不容易做成分布式
* 开发难度相对较高，因为涉及到插件与内核的通信，以及内部的插件登记机制

## Microservices Arch

微服务架构（microservices architecture）是服务导向架构（service-oriented architecture，缩写 SOA）的升级。

每一个服务就是一个独立的部署单元（separately deployed unit）。这些单元都是分布式的，互相解耦，通过远程通信协议（比如REST、SOAP）联系。

```
  ------------------- ------------------- -------------------
  | Client Requests | | Client Requests | | Client Requests |
  ------------------- ------------------- -------------------
           |
  -----------------------------------------------------------
  |                   User Interface Layer                  |
  --------^---------------------^---------------------^------
          |                     |                     |
----------v---------- ----------v---------- ----------v----------
| Service Component | | Service Component | | Service Component |
|  Module   Module  | |  Module   Module  | |  Module   Module  |
--------------------- --------------------- ---------------------
```

* RESTful API 模式：服务通过 API 提供，云服务就属于这一类
* RESTful 应用模式：服务通过传统的网络协议或者应用协议提供，背后通常是一个多功能的应用程序，常见于企业内部
* 集中消息模式：采用消息代理（message broker），可以实现消息队列、负载均衡、统一日志和异常处理，缺点是会出现单点失败，消息代理可能要做成集群

### Pros

* 扩展性好，各个服务之间低耦合
* 容易部署，软件从单一可部署单元，被拆成了多个服务，每个服务都是可部署单元
* 容易开发，每个组件都可以进行持续集成式的开发，可以做到实时部署，不间断地升级
* 易于测试，可以单独测试每一个服务

### Cons

* 由于强调互相独立和低耦合，服务可能会拆分得很细。这导致系统依赖大量的微服务，变得很凌乱和笨重，性能也会不佳。
* 一旦服务之间需要通信（即一个服务要用到另一个服务），整个架构就会变得复杂。典型的例子就是一些通用的 Utility 类，一种解决方案是把它们拷贝到每一个服务中去，用冗余换取架构的简单性。
* 分布式的本质使得这种架构很难实现原子性操作，交易回滚会比较困难。

## Cloud Arch

云结构（cloud architecture）主要解决扩展性和并发的问题，是最容易扩展的架构。

它的高扩展性，主要原因是没使用中央数据库，而是把数据都复制到内存中，变成可复制的内存数据单元。然后，业务处理能力封装成一个个处理单元（prcessing unit）。访问量增加，就新建处理单元；访问量减少，就关闭处理单元。由于没有中央数据库，所以扩展性的最大瓶颈消失了。由于每个处理单元的数据都在内存里，最好要进行数据持久化。

```
           ------------------ ------------------- -------------------
           |Processing Unit | | Processing Unit | | Processing Unit |
           --------^--------- ---------^--------- ---------^---------
                   |                   |                   |
-------------------v-------------------v-------------------v--------------------
| ------------------  ------------- ------------------- ---------------------- |
| | Messaging Grid |  | Data Grid | | Processing Grid | | Deployment Manager | |
| ------------------  ------------- ------------------- ---------------------- |
--------------------------------------------------------------------------------
```

* 消息中间件（Messaging Grid）：管理用户请求和session，当一个请求进来以后，决定分配给哪一个处理单元。
* 数据中间件（Data Grid）：将数据复制到每一个处理单元，即数据同步。保证某个处理单元都得到同样的数据。
* 处理中间件（Processing Grid）：可选，如果一个请求涉及不同类型的处理单元，该中间件负责协调处理单元
* 部署中间件（Deployment Manager）：负责处理单元的启动和关闭，监控负载和响应时间，当负载增加，就新启动处理单元，负载减少，就关闭处理单元。

### Pros

* 高负载，高扩展性
* 动态部署

### Cons

* 实现复杂，成本较高
* 主要适合网站类应用，不合适大量数据吞吐的大型数据库应用
* 较难测试

## References

* [Proxy Pattern](https://sourcemaking.com/design_patterns/proxy)
* [Software Architecture Patterns](http://www.oreilly.com/programming/free/software-architecture-patterns.csp)
