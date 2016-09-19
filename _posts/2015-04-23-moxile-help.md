---
layout: post
title: "Moxile Help"
categories: [moxile]
tags: [moxile]
redirect_from:
  - /moxile/help/
---

**Moxile**, the missing Markdown editor designed for productivity. It comes with **Live Preview**.  It offers full support for regular 	Markdown Syntax as well as Github flavored markdown extension.

<!--more-->

## Table of Contents

* TOC
{:toc}

## Overview

>
**Markdown**
>
>Markdown is a way to style text on the web. You control the display of the document; formatting words as bold or italic, adding images, and creating lists are just a few of the things we can do with Markdown. Mostly, Markdown is just regular text with a few non-alphabetic characters thrown in, like # or *.

### Features

- editor and viewer could be swapped
- syntax highlight
- math support
- auto save
- powerful actions
- featured picture inserter
- light and dark theme built-in, support customize
- HTML and PDF export support
- UTF-8 support
- full retina support
- QuickLook support
- multiple screen support

### Editor

### Viewer

- inspector support
- syntax highlight
- live preview
- github and article theme built-in, support customize
- support external renderer like 'pandoc' and 'docutils'

### Keyboard Shortcuts

Option            | &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Shortcut&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
------------------|---------------------------------
New               | <kbd>⌘ N</kbd>
Open              | <kbd>⌘ O</kbd>
Save              | <kbd>⌘ S</kbd>
Save As           | <kbd>⌘ ⇧ S</kbd>
Close             | <kbd>⌘ W</kbd>
Print Preview     | <kbd>⌘ ⇧ P</kbd>
Print             | <kbd>⌘ P</kbd>
Find              | <kbd>⌘ F</kbd>
Replace           | <kbd>⌘ ⇧ F</kbd>
Strong            | <kbd>⌘ B</kbd>
Emphasis          | <kbd>⌘ I</kbd>
Strikethrough     | <kbd>⌘ U</kbd>
Uppercase         | <kbd>⌃ U</kbd>
Titlecase         | <kbd>⌃ ⌥ U</kbd>
Lowercase         | <kbd>⌃ ⇧ U</kbd>
Inline code       | <kbd>⌘ K</kbd>
Blockquote        | <kbd>⌃ Q</kbd>
Header 1..6       | <kbd>⌘ 1..6</kbd>
Increse font size | <kbd>⌘ ⌥ +</kbd>
Decrese font size | <kbd>⌘ ⌥ -</kbd>
Comment           | <kbd>⌘ /</kbd>
Task List         | <kbd>⌘ T</kbd>
Bulluted List     | <kbd>⌘ L</kbd>
Increse Indent    | <kbd>⌘ ]</kbd>
Decrese Indent    | <kbd>⌘ [</kbd>
Update preview    | <kbd>⌘ R</kbd>
Zoom in           | <kbd>⌘ +</kbd>
Zoom out          | <kbd>⌘ -</kbd>
Zoom reset        | <kbd>⌘ 0</kbd>
Minimize          | <kbd>⌘ M</kbd>
Fullscreen        | <kbd>⌘ ⇧ F</kbd>

See [Mac keyboard shortcuts](https://support.apple.com/en-us/HT201236) for more information.

## Syntax

### Basic Syntax

#### Strong and Emphasis

`**strong**` or `__strong__` ( <kbd>⌘ B</kbd> )

`*emphasize*` or `_emphasize_` ( <kbd>⌘ I</kbd> )

#### blockquote

```
> Right angle brackets > are used for block quotes.
```

#### Link and Email

Feed back goes <errpro@icloud.com>, visit our website [moxile] for more information.

A [reference style][moxile] link. Input id, then anywhere in the doc, define the link with corresponding id:

[moxile]: http://moxile.errpro.com "Markdown editor designed Mac OS X"

Titles ( or called tool tips ) in the links are optional.

#### Image

Inline image: `![Moxile icon](mox.png "Moxile Icon")`, title is optional.

Reference style image:

	![Moxile icon][mox-icon]
	[mox-icon]: mox.png "Moxile"

#### Inline code and Code block

Inline code are surround by `backtick` key. To create a block code, Indent each line by at least 1 tab, or 4 spaces:

```
	function greet() {
		console.log("Hello world");
	}
```

####  Ordered List

Ordered lists are created using "1." + Space:

```
1. first list item
2. second list item
3. third list item
```

#### Unordered List

Unordered list are created using "*" + Space:

```
* Unordered list item
* Unordered list item
* Unordered list item
```

Or using "-" + Space:

```
- Unordered list item
- Unordered list item
- Unordered list item
```

#### Hard Linebreak

End a line with two or more spaces will create a hard linebreak, called `<br />` in HTML. ( <kbd>⇧ + ↩</kbd> )


Above line ended with 2 spaces.

#### Horizontal Rule

Three or more asterisks or dashes:

***

---

- - - -

#### Header

**Setext-style**

```
This is H1
==========

This is H2
----------
```

**atx-style**

```
# This is H1
## This is H2
### This is H3
#### This is H4
##### This is H5
###### This is H6
```


### Extra Syntax

#### Footnote

Footnotes work mostly like reference-style links. A footnote is made of two things: a marker in the text that will become a superscript number; a footnote definition that will be placed in a list of footnotes at the end of the document. A footnote looks like this:

That's some text with a footnote.[^1]

[^1]: And that's the footnote.


#### Strikethrough

Wrap with 2 tilde characters ( <kbd>⌘ B</kbd> ):

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

#### Table

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

#### Task List

Task list is a GFM(github flavored markdown) extension

```
- [ ] uncomplete task item
- [x] completed task
- [x] another completed task
```

[moxile]: /moxile
