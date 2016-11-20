---
title: Hibernate
author: wangzai
---

## Hibernate

### 单个参数设置方式

```java
hql = "from task where id = ?";
this.session.createQuery(hql).setParamter(0,1); //单个或则多个参数设置传递
```

<!--more-->

### 集合参数设置方式

```java
hql = "from task where id  in (:ids)" ;
this.session.createQuery(hql).setParamterList(
    "ids", new Object[](xx,xx,xx,xx,......)); //数组或者集合参数设置传递
```

### 命名查询

```java
Query query = this.session.getNamedQuery("queryById");
query.setParameter("idMax",100); //参数传递
query.setParameter("idMin",1);
List list = query.list(); //查询返回
```
