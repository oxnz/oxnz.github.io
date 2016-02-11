---
layout: post
title: shell 重定向
date: 2012-12-04 16:48:05.000000000 +08:00
type: post
published: true
status: publish
categories:
- shell
tags:
- shell
- bash
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---
<h2>摘要</h2>
<p>使用一个例子简要介绍了 shell 编程中得输入输出重定向问题。</p>

<!--more-->

<h2>例子</h2>
<p><code>&gt;/dev/null 2&gt;&amp;1</code></p>
<ol>
<li>首先 <code>0&gt;</code> 表示<code>stdin</code>标准输入; <code>1&gt;</code> 表示<code>stdout</code>标准输出; <code>2&gt;</code> 表示<code>stderr</code>错误输出;</li>
<li>符号 <code>&gt;</code> 等价于 <code>1&gt;</code> (系统默认为1,省略了); 所以<code>"&gt;/dev/null"</code>等同于 <code>"1&gt;/dev/null"</code></li>
<li><code>/dev/null</code> 代表空设备文件</li>
<li><code>&amp;</code> 可以理解为是"等同于"的意思，<code>2&gt;&amp;1</code>，即表示2的输出重定向等同于1</li>
</ol>
<p>因此，<code>&gt;/dev/null 2&gt;&amp;1</code> 也可以写成"<code>1&gt; /dev/null 2&gt; &amp;1"</code></p>
<p>那么本文开始的语句执行过程为：<br />
<code>1&gt;/dev/null</code>：首先表示标准输出重定向到空设备文件，也就是不输出任何信息到终端，说白了就是不显示任何信息。<br />
<code>2&gt;&amp;1</code>：接着，将标准错误输出重定向到标准输出，因为之前标准输出已经重定向到了空设备文件，所以标准错误输出也重定向到空设备文件。</p>
