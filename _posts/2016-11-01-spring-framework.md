---
title: Spring Framework
---

## Overview

Benefits of the Spring platform:

* Make a Java method execute in a database transaction without having to deal with transaction APIs.
* Make a local Java method a remote procedure without having to deal with remote APIs.
* Make a local Java method a management operation without having to deal with JMX APIs.
* Make a local Java method a message handler without having to deal with JMS APIs.

## Table of Contents

* TOC
{:toc}

<!--more-->

## Modules

### Spring Framework Runtime

![Spring Framework Runtime](/assets/spring-overview.png)

### Core Container

* spring-core
* spring-beans
* spring-context
    * `ApplicationContext`
* spring-context-support
    * caching
        * EhCache
        * Guava
    * mailing
        * JavaMail
    * scheduling
        * CommonJ
        * Quartz
    * template engines
        * FreeMaker
        * JasperReports
        * Velocity
* spring-expression (SpEL)

>
The spring-core and spring-beans modules provide the fundamental parts of the framework, including the IoC and Dependency Injection features.

### Typical full-fiedged Spring web application

![Typical full-fiedged Spring web application](/assets/spring-overview-full.png)

## AOP

## IOC

## Java Message Service (JMS)

## JMX

## secret

## Data Access

### Transaction management

### DAO support

### Data access with JDBC

### Object Relational Mapping (ORM) Data Access

The Spring Framework supports integration with Hibernate, Java Persistence API (JPA) and Java Data Objects (JDO) for resource management, data access object (DAO) implementations, and transaction strategies.

Benefits of using the Spring Framework to create your ORM DAOs include:

* Easier testing
* Common data access exceptions
* General resource management
* Integrated transaction management

The major goal of Spring’s ORM integration is clear application layering, with any data access and transaction technology, and for loose coupling of application objects.

#### Exception translation

Spring enables exception translation to be applied transparently through the @Repository annotation:

```java
@Repository
public class ProductDaoImpl implements ProductDao {
    // class body here...
}
```

In summary: you can implement DAOs based on the plain persistence technology’s API and annotations, while still benefiting from Spring-managed transactions, dependency injection, and transparent exception conversion (if desired) to Spring’s custom exception hierarchies.

#### Hibernate

```xml
<beans>
    <bean id="myDataSource" class="org.apache.commons.dbcp.BasicDataSource" destroy-method="close">
        <property name="driverClassName" value="org.hsqldb.jdbcDriver"/>
        <property name="url" value="jdbc:hsqldb:hsql://localhost:9001"/>
        <property name="username" value="sa"/>
        <property name="password" value=""/>
    </bean>

    <bean id="mySessionFactory" class="org.springframework.orm.hibernate5.LocalSessionFactoryBean">
        <property name="dataSource" ref="myDataSource"/>
        <property name="mappingResources">
            <list>
                <value>product.hbm.xml</value>
            </list>
        </property>
        <property name="hibernateProperties">
            <value>
                hibernate.dialect=org.hibernate.dialect.HSQLDialect
            </value>
        </property>
    </bean>
</beans>
```

## References

* [Spring Framework Reference Documentation](http://docs.spring.io/spring/docs/4.3.x/spring-framework-reference/html/index.html)
* [Build RESTful web services using Spring 3](http://www.ibm.com/developerworks/library/wa-spring3webserv/index.html)
