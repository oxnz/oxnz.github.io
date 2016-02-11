---
layout: post
title: Mysql Basics
date: 2014-02-27 15:22:18.000000000 +08:00
type: post
published: true
status: publish
categories:
- Database
- Mysql
tags:
- Mysql
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---
<h2>管理</h2>
<h3>账户管理</h3>
<p>改密码:<code>mysqladmin -u 用户名 -p 旧密码 password 新密码</code><br />
1、给<code>root</code>加个密码<code>abc</code>。首先进入目录 <code>mysql/bin</code>，然后键入以下命令<br />
<code>mysqladmin -u root -password abc</code><br />
注：因为开始时<code>root</code>没有密码，所以<code>-p 旧密码</code>一项就可以省略了。<br />
mysql&gt; UPDATE mysql.user SET password=PASSWORD(’新密码’) WHERE User=’root’;<br />
mysql&gt; FLUSH PRIVILEGES;</p>
<p>4、显示当前的user：<br />
mysql&gt; SELECT USER();<br />
<!--more--></p>
<h3>授权管理</h3>
<p>下面为您介绍的语句都是用于授予MySQL用户权限，这些语句可以授予数据库开发人员，创建表、索引、视图、存储过程、函数。。。等MySQL用户权限。</p>
<p>grant 创建、修改、删除 MySQL 数据表结构权限。</p>
<p>grant create on testdb.* to developer@'192.168.0.%';<br />
grant alter on testdb.* to developer@'192.168.0.%';<br />
grant drop on testdb.* to developer@'192.168.0.%';</p>
<p>grant 操作 MySQL 外键权限。</p>
<p>grant references on testdb.* to developer@'192.168.0.%';</p>
<p>grant 操作 MySQL 临时表权限。</p>
<p>grant create temporary tables on testdb.* to developer@'192.168.0.%';</p>
<p>grant 操作 MySQL 索引权限。</p>
<p>grant index on testdb.* to developer@'192.168.0.%';</p>
<p>grant 操作 MySQL 视图、查看视图源代码权限。</p>
<p>grant create view on testdb.* to developer@'192.168.0.%';<br />
grant show view on testdb.* to developer@'192.168.0.%';</p>
<p>grant 操作 MySQL 存储过程、函数权限。</p>
<p>grant create routine on testdb.* to developer@'192.168.0.%'; -- now, can show procedure status<br />
grant alter routine on testdb.* to developer@'192.168.0.%'; -- now, you can drop a procedure<br />
grant execute on testdb.* to developer@'192.168.0.%';</p>
<p>以上就是MySQL用户权限的语句介绍</p>
