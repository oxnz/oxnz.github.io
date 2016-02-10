---
title: "Moxile 帮助手册"
---

**Moxile**, the missing Markdown editor designed for productivity. It comes with **Live Preview**.  It offers full support for regular 	Markdown Syntax as well as Github flavored markdown extension.

<!--more-->

## 目录

* Markdown 介绍
* 编辑器
	* 快捷键
* 预览器
* 语法
	* 基本语法
	* 扩展语法

### 概览

- [x] 编辑器可以和预览器互换位置

> ###Markdown
>
>Markdown is a way to style text on the web. You control the display of the document; formatting words as bold or italic, adding images, and creating lists are just a few of the things we can do with Markdown. Mostly, Markdown is just regular text with a few non-alphabetic characters thrown in, like # or *.


### 编辑器

#### 快捷键

操作    | 快捷键
-------|:----------
新建    | <kbd>Command + N</kbd>
打开    | <kbd>Command + O</kbd>
保存    |	<kbd>Command + S</kbd>
另存为  | <kbd>Command + Shift + S</kbd>
关闭    | <kbd>Command + W</kbd>
打印预览	| <kbd> Command + Shift + P</kbd>
打印	    | <kbd> Command + P</kbd>
查找   	| <kbd> Command + F</kbd>
替换	   | <kbd> Command + Shift + F</kbd>
粗体	   | <kbd> Command + B</kbd>
斜体	   | <kbd> Command + I</kbd>
删除线  | <kbd> Command + U</kbd>
大写    | <kbd> Ctrl + U</kbd>
首字母大写	| <kbd> Ctrl + Option + U</kbd>
小写	    | <kbd> Ctrl + Shift + U</kbd>
內联代码	| <kbd> Command + K</kbd>
块引用	| <kbd> Ctrl + Q</kbd>
标题	    | <kbd> Command + 1..6</kbd>
增大字体	| <kbd> Command + Option + +</kbd>
减小字体	| <kbd> Command + Option + -</kbd>
注释	    | <kbd> Command + /</kbd>
任务列表	| <kbd> Command + T</kbd>
无序列表	| <kbd> Command + L</kbd>
增加缩进	| <kbd> Command + ]</kbd>
减小缩进	| <kbd> Command + [</kbd>
更新预览	| <kbd> Command + R</kbd>
放大	    | <kbd> Command + +</kbd>
缩小	    | <kbd> Command + -</kbd>
重置缩放	| <kbd> Command + 0</kbd>
最小化	| <kbd> Command + M</kbd>
全屏     | <kbd> Command + Shift + F</kbd>

- [x] 语法高亮
- [x] 数学公式支持
- [x] 自动保存
- [x] powerful actions
- [x] featured picture inserter
- [x] 内建多种主题，并支持主题定制
- [x] HTML 和 PDF 导出支持
- [x] UTF-8 支持
- [x] 视网膜屏幕支持
- [x] QuickLook 支持
- [x] 多屏幕支持

### 预览器

- [x] 开发者工具支持
- [x] 代码语法高亮
- [x] 实时预览
- [x] 多种主题支持，并支持主题定制
- [x] 支持外部渲染器，例如 'pandoc' 和 'docutils'

## 语法

### 基本语法

#### 粗体和斜体

**strong** or __strong__ ( ⌘ + B )

*emphasize* or _emphasize_ ( ⌘ + I )

#### 块引用

> 大于号 ==&gt;== 用作块引用标记

#### 超链接和邮件地址

Feed back goes <errpro@icloud.com>, for more information visit our website [Moxile](http://moxile.errpro.com).

A [reference style][moxile] link. Input id, then anywhere in the doc, define the link with corresponding id:

[moxile]: http://moxile.errpro.com "Markdown editor designed Mac OS X"

Titles ( or called tool tips ) in the links are optional.

#### 图片

Inline image: `![Moxile icon](mox.png "Moxile Icon")`, title is optional.

Reference style image:

	![Moxile icon][mox-icon]
	[mox-icon]: mox.png "Moxile"

#### 内联代码和代码块

Inline code are surround by `backtick` key. To create a block code, Indent each line by at least 1 tab, or 4 spaces:

	function greet() {
		console.log("Hello world");
	}

####  有序列表

Ordered lists are created using "1." + Space:

1. first list item
2. second list item
3. third list item

#### 无序列表

Unordered list are created using "*" + Space:

* Unordered list item
* Unordered list item
* Unordered list item

Or using "-" + Space:

- Unordered list item
- Unordered list item
- Unordered list item

#### 硬换行

End a line with two or more spaces will create a hard linebreak, called `<br />` in HTML. (⇧ + ↩)


Above line ended with 2 spaces.

#### 水平分隔符

Three or more asterisks or dashes:

***

---

- - - -

#### 标题

Setext-style:

This is H1
==========

This is H2
----------

atx-style:

# This is H1
## This is H2
### This is H3
#### This is H4
##### This is H5
###### This is H6


### 扩展语法

#### 脚注

Footnotes work mostly like reference-style links. A footnote is made of two things: a marker in the text that will become a superscript number; a footnote definition that will be placed in a list of footnotes at the end of the document. A footnote looks like this:

That's some text with a footnote.[^1]

[^1]: And that's the footnote.


#### Strikethrough

Wrap with 2 tilde characters (⌘ + B):

`~~Strikethrough~~`

#### Fenced Code Blocks

Start with a line containing 3 or more backticks, and ends with the first line with the same number of backticks:

{% highlight javascript %}
/*
Fenced code blocks are like Stardard Markdown’s regular code
blocks, except that they’re not indented and instead rely on
a start and end fence lines to delimit the code block. After
the begin backtick, you could supply language information to
let Moxile highlight the code.
*/
function hello() {
	console.write("Hello world");
}
{% endhighlight %}

#### 表格

A simple table looks like this:

First Header | Second Header | Third Header
------------ | ------------- | ------------
Content Cell | Content Cell  | Content Cell
Content Cell | Content Cell  | Content Cell

If you wish, you can add a leading and tailing pipe to each line of the table:

| First Header | Second Header | Third Header |
| ------------ | ------------- | ------------ |
| Content Cell | Content Cell  | Content Cell |
| Content Cell | Content Cell  | Content Cell |

Specify alignment for each column by adding colons to separator lines:

First Header | Second Header | Third Header
:----------- | :-----------: | -----------:
Left         | Center        | Right
Left         | Center        | Right

#### 任务列表

Task list is a GFM(github flavored markdown) extension

- [ ] uncomplete task item
- [x] completed task
- [X] another completed task

