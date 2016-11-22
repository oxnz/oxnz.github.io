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

### find部分查询

```java
find(String str, Object value)  this.getHibernateTemplate().find(from Task where id=?", "valueId");
find(String str , Object[] values) 
hql = "from Task  where name=? and password=?";
this.getHibernateTemplate().find(hql, new String[]{"nameValue", "passwordValue"});
findByNamedParam(String str, String paramName, Object value)
str="select count(*) from Task where name =:Name"; 
paramName=name;
value="xxx"
this .getHibernateTemplate().findByNamedParam(queryString, paramName, value); 
findByNamedQuery(String hqlName) 
this.getHibernateTemplate().findByNamedQuery("queryAllTask");
 <hibernate-mapping>
                  <class>......</class>
                  <query name="queryAllTask"><!--此查询被调用的名字-->
                       <![CDATA[
                            from Task  <!--查询对象-->
                        ]]>
                  </query>
             </hibernate-mapping>
findByNamedQuery(String hqlNameObject value)  
this .getHibernateTemplate().findByNamedQuery("queryByName", "nameValue");
 <hibernate-mapping>
                  <class>......</class>
                  <query name="queryByName "><!--此查询被调用的名字-->
                       <![CDATA[
                            from Task where name = ?
                        ]]>
                  </query>
             </hibernate-mapping>
             
findByNamedQuery(String hqlName , Object[] value)  
String[] values= new String[]{"test", "123"};
this .getHibernateTemplate().findByNamedQuery("queryByNameAndPassword " , values);
   <hibernate-mapping>
                  <class>......</class>
                  <query name="queryByNameAndPassword "><!--此查询被调用的名字-->
                       <![CDATA[
                            from Task where name =? and password =?
                        ]]>
                  </query>
             </hibernate-mapping>
```
             


