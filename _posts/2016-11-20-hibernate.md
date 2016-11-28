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
    this.session.createQuery(hql).setParamterList("ids", new Object[](xx,xx,xx,xx,......)); //数组或者集合参数设置传递
```

### 命名查询

```java
    this.session.getNamedQuery("queryById");
    query.setParameter("idMax",100); //参数传递
    query.setParameter("idMin",1);
    List list = query.list(); //查询返回
```

### find部分查询

```java
find(String str, Object value)  
    this.getHibernateTemplate().find(from Task where id=?", "valueId");
```
```java
find(String str , Object[] values) 
    hql = "from Task  where name=? and password=?";
    this.getHibernateTemplate().find(hql, new String[]{"nameValue", "passwordValue"});
```
```java
findByNamedParam(String str, String paramName, Object value)
    str="select count(*) from Task where name =:Name"; 
    paramName=name;
    value="xxx"
    this .getHibernateTemplate().findByNamedParam(queryString, paramName, value); 
```
```java
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
```
```java
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
```
```java
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
### hibernate 配置文件:

配置key前边的hibernate前缀 可有可无,如:hibernate.dialect或dialcet
按作用可以分为三大类:

  * 数据库信息: 方言,jdbcUr,驱动,用户名,密码...
```java
    <property name="hibernate.connection.driver_class">com.mysql.jdbc.Driver</property>
	<property name="connection.url">jdbc:mysql://.......
    <property  name="hibernate.dialect">org.hibernate.dialect.MySQLDialect</property>
```

  * 导入映射文件
  
```java
      <mapping resource="././*.hbm.xml">
```

  * 其他配置
  
```java
    <property ...>
          show_sql   //显示生成的sql语句
		  format_sql //格式化生成的sql语句
		  hbm2ddl.auto //自动生成表结构
		  hibernate.hbm2ddl.auto
    </property>
```
```java
    <property name=” hibernate.connection.isolation”>4</property>
```
   1代表:读未提交（Read Uncommitted）
   2代表:读已提交（Read Committed）
   4代表:可重复读（Repeatable Read）  数据库默认(快照 第一次读到的数据  数据库中途改变数据不会变化)
   8代表:可串行化（Serializable）(当前操作未完成不允许别的请求操作)

### 生成表结构的两种方式:

* hbm2ddl.auto

  是否自动创建数据库表 主要有一下几个值：  
  
   1.validate:当sessionFactory创建时，自动验证或者schema定义导入数据库。  
  
   2.create:每次启动都drop掉原来的schema，创建新的。  
  
   3.create-drop:当sessionFactory明确关闭时，drop掉schema。  
  
   4.update(常用):如果没有schema就创建，有就更新。 
   
```java
    <propertynamepropertyname="hbm2ddl.auto">create</property>  
```

 * 使用SchemaExport工具类



             
             
             
             
             
             
             
             
             


