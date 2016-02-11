---
layout: post
title: Java Basics
date: 2012-12-29 20:39:42.000000000 +08:00
type: post
published: true
status: publish
categories:
- Linux
tags:
- Java
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---
## 介绍

记录一些零散的 java 入门知识，不定期更新。

<!--more-->

* TOC
{:toc}

## 集合类

<p>1、集合，无序和互异，如果add两个一样的值，只有一个。</p>
<pre class="lang:default decode:true">import java.util.*;
Set s=new HashSet();
s.add("One");</pre>
<p>2、列表：java为列表定义了一个接口List，常用的有ArrayList、Vector等。</p>
<pre class="lang:default decode:true">import java.util.*;
List s=new ArrayList(); //数组
s.add(“aaa”); // 添加元素
s.remove(2); &lt;wbr /&gt; //删除，索引号从0开始。</pre>
<p>3、Iterator接口：集合和列表都有个iterator()方法 ，可以列出各个元素。</p>
<pre class="lang:default decode:true">import java.util.*;

public class Test {
    public static void main(String[] args) {
        List&lt;String&gt; s = new ArrayList&lt;String&gt;();
        s.add("aaa");
        s.add("ccc");
        s.add("bbb");
        Iterator it = s.iterator(); //iterator()返回类型为Iterator。
        while (it.hasNext()) {
            System.out.println(it.next()); //用next()方法遍历元素。
        }
    }
}</pre>
<p>4、映射Map：Map也是一个接口，常用类是HashMap，通过put()方法将两个对象放进去。通过get()方法将映射关系取出。</p>
<pre class="lang:default decode:true">import java.util.*;

public class Test {
    public static void main(String[] args) {
        Map&lt;String, String&gt; m = new HashMap&lt;String, String&gt;();
        m.put("name", "xinyi");
        m.put("loc", "Wuhan");
        Object o = m.get("name"); //所有的类都是Object的子类。
        System.out.println("name: " + o
                + "nLocation: " + m.get("loc"));
    }
}
// 运行结果：
$ java Test
name: xinyi
Location: Wuhan</pre>
<p>5、排序：最简单的方法使用Arrays类的静态方法sort。可以对各种数组进行排序。</p>
<pre class="lang:default decode:true">int[] a = {2, 9, 2, 4, 5, 8};
Arrays.sort(a);</pre>

## 系统属性

<p>1、System类的静态方法getProperty(属性名称)可以获得用户计算机的各种属性。</p>
<p>如：<code>user.dir</code>代表当前程序运行的目录，<code>file.separator</code>代表文件分隔符，不同系统中文件分隔符不同。有的是<code>"/"</code>,有的是<code>""</code>。</p>
<pre class="lang:default decode:true">System.out.println(System.getProperty("user.dir") + System.getProperty("file.separator"));
// 输出(OS X 系统)：/Users/xinyi/Developer/tmp/</pre>
<p>2、若要获取当前系统中有哪些属性，可以使用System类的静态方法getProperties(),它将返回一个Properties类型的对象，其中包含的是属性名称与属性值的映射关系。</p>
<pre class="lang:default decode:true">import java.util.*;

public class Test {
    public static void main(String[] args) {
        Properties pps = System.getProperties();
        Enumeration e = pps.propertyNames();
        while (e.hasMoreElements()) {
            String pname = (String)e.nextElement();
            System.out.println(pname + ": " + System.getProperty(pname));
        }
    }
}
// 输出：
...
user.name: xinyi
java.class.path: .
java.vm.specification.version: 1.8
sun.arch.data.model: 64
java.home: /Library/Java/JavaVirtualMachines/jdk1.8.0.jdk/Contents/Home/jre
sun.java.command: Test
java.specification.vendor: Oracle Corporation
user.language: zh
awt.toolkit: sun.lwawt.macosx.LWCToolkit
java.vm.info: mixed mode
java.version: 1.8.0
...</pre>

## File 类

File类可以代表文件或目录，如：

<pre class="lang:default decode:true">File f= new File(“c:windows”);
// or File f = new File("c:windowscommand.com");</pre>
<p>1、获得当前路径，并在当前路径建立文件。</p>
<pre class="lang:default decode:true">String prefix = System.getProperty("user.dir") + System.getProperty("file.separator");

File f = new File(prefix + "test.txt");</pre>
<p>2、File类提供的方法:</p>
<ul>
<li><code>delete()</code>删除</li>
<li><code>mkdir()</code>创建File所代表的目录</li>
<li><code>rename(File newName)</code>更改名称</li>
<li><code>isFile()</code>判断是否为文件</li>
<li><code>isDirectory()</code>判断是否为目录</li>
<li><code>lastModified()</code>显示该文件上次修改时间，毫秒。</li>
<li><code>length()</code>返回文件长度</li>
<li><code>list()</code>返回字符串类型数组，数组元素是File对象所代表的目录下所有的目录和文件的名称。</li>
</ul>
<pre class="lang:default decode:true">import java.io.*;

File path = new File("/path/to/tmp");
path.mkdir();</pre>
<p>3、遍历输出指定目录的文件。</p>
<pre class="lang:default decode:true">import java.util.*;
import java.io.*;

public class Test {
    public static void main(String[] args) {
        tree(".");
    }

    public static void tree(String fpath) {
        tree(fpath, "");
    }

    public static void tree(String fpath, String prefix) {
        File f = new File(fpath);
        System.out.println(prefix + fpath);
        if (f.isDirectory()) {
            if (prefix.equals("")) {
               prefix = "|_______";
            } else { // if (prefix.equals("|_______")) {
                prefix = "        " + prefix;
            }
            for (String fp : f.list()) {
                tree(fp, prefix);
            }
        }
    }
}
// 运行效果类似 Linux 的 tree 命令：
% java Test
.
|_______.DS_Store
|_______a
        |_______b
|_______Makefile
|_______test
|_______Test.class
|_______test.cpp
|_______Test.java</pre>

## 比较操作
<ol>
<li>简单类型<br />
java中的比较操作有两种：使用<code>==</code>运算符和使用<code>equals()</code>方法。简单类型不是对象，因而只能用<code>==</code>而不能用<code>equals()</code>进行比较。</li>
<li>参考类型</li>
<li>特殊类型</li>
</ol>

## 输入输出流

<p><b>1</b><b>、键盘输入和屏幕输出</b></p>
<p><code>read()</code>,<code>write()</code>方法的使用参见API文档，一般常用<code>read(char[] cbuf, int offset, int length)</code>,表示读取<code>length</code>长度的字符存入<code>cbuf</code>的第<code>offset</code>个单元中。<code>write</code>对应相反。</p>
<pre class="lang:default decode:true">byte buffer[] = new byte[255];
System.in.read(buffer,0,255);
String s = new String(buffer);
System.out.println(s);</pre>
<p><code>read()</code>方法按字符读取，结束时将返回-1，因此如果要多次从输入流中读取数据，可以将其作为循环条件。</p>
<p><b>2</b><b>、处理流：处理输入流</b></p>
<p><code>System.in</code>中的<code>read()</code>不带参数时只能一次读取一个字符，或者像1、当中使用，如果想要一次读入一行，则可以将其作为参数传递给其他输入流，这些流称为处理流或过滤流，可以提供其他方式来处理输入输出流。</p>
<p>如：类B<code>ufferedReader</code>提供了<code>readLine()</code>方法可以一次从流中读取一行，其构造参数为<code>Reader</code>类型。而类<code>InputStreamReader</code>是<code>Reader</code>的子类，构造器参数为输入流<code>System.in</code>。因此可以如下构造处理流：</p>
<pre class="lang:default decode:true">InputStreamReader ir = new InputStreamReader(System.in);
BufferedReader in = new BufferedReader(ir);
while(in.readLine()!=null){
// ...
}</pre>
<p>以上可简写为：</p>
<p><code>in=new BufferedReader(new InputStreamReader(System.in));</code></p>
<p><b>3</b><b>、基本文件输入输出</b></p>
<p>java中提供了<code>FileInputStream</code>和<code>FileOutputStream</code>来处理文件输入/输出操作，参数可以是字符串代表的文件，也可以是<code>File</code>类型的对象。这两个类分别提供了<code>read()</code>和<code>write()</code>方法来读写文件。结束返回-1 。</p>
<pre class="lang:default decode:true">FileInputStream fileIn=new FileInputStream(“c:test.txt”);
int b;
while((b=fileIn.read())!=-1) {
    System.out.print((char)b);
}</pre>
<p>也可以用处理流一次读取一行，如下：</p>
<pre class="lang:default decode:true">BufferedReader in = new BufferedReader (new InputStreamReader (new FileInputStream ("c:test.txt")))；
while(in.readLine()!=null) {
}</pre>
<p><code>read()</code>和<code>write()</code>:</p>
<pre class="lang:default decode:true">byte buffer[]=new byte[80];
int bytes=System.in.read(buffer); //返回值为实际读入的字符数
FileOutputStream fileOut=new FileOutputStream(“line.txt”);
fileOut.write(buffer,0,bytes); //将buffer内容输出到文件。</pre>
<p>同样，写也可以制造处理流一次写入一行：</p>
<p><code>BufferedWriter out=new BufferedWriter(new InputStreamWriter(new FileOutputStream("line.txt")));</code></p>
<p><b>4</b><b>、字节流和字符流</b></p>
<p>字节流按照字节（8位）传输；字符流按照字符（16位）传输。由于字符使用Unicode字符集，支持多国文字，因此若流要跨越多种平台，应使用字符流。</p>
<p>1）常用的字节型的节点流有：（8位）</p>
<p>文件：<code>FileInputStream</code>, <code>FileOutputStream</code><br />
内存（数组）：<code>ByteArrayInputStream</code>, <code>ByteArrayOutputStream</code><br />
管道：<code>PipedInputStream</code>, <code>PipedOutputStream</code></p>
<p>2）常用的字符型的节点流有：（16位）</p>
<p>文件：<code>FileReader</code>, <code>FileWriter</code><br />
内存（数组）：<code>CharArrayReader</code>，<code>CharArrayWriter</code><br />
管道：<code>PipedReader</code>, <code>PipedWriter</code></p>
<p>同样，处理流也有面向字符和面向字节之分，成用的有：</p>
<p>1)面向字节的处理流 （8位）</p>
<p><code>BufferedInputStream</code>, <code>BufferedOutputStream</code>,<code>DataInputStream</code>, <code>DataOutputStream</code></p>
<p>2）面向字符的处理流 （16位）</p>
<p><code>BufferedWriter</code>, <code>BufferedReader</code>,<code>InputStreamReader</code>, <code>InputStreamWriter</code></p>
<p>可见，字节类型的叫<code>Stream</code>，字符类型的叫<code>Reader/Writer</code>。<code>InputStreamReader/Writer</code>用于将字节流按照指定的字符集转换成字符流。</p>
<p>对于文件有两种操作，<code>FileInputStream</code>和<code>FileReader/Writer</code>，前者为8位，后者16位。<code>BufferedReader/Writer</code>的参数为<code>Reader</code>类，即为16位的。对于文件处理流可以如下：</p>
<p><code>BufferedReader in=new BufferedReader(new FileReader("test.txt"));</code></p>
<p><b>5</b><b>、文件随机读写</b></p>
<p>使用<code>RandomAccessFile</code>类可以实现文件的随机读写，即从文件的任意一个位置开始读写。一般的流中，文件指针只能顺序移动，而<code>RandomAccessFile</code>可以任意移动指针。</p>
<p><code>RandomAccessFile raf = new RandomAccessFile</code>（文件名，模式）；文件名和模式都是字符串类型，模式<code>"r"</code>代表以只读方式访问文件，<code>"rw"</code>代表既可以读文件又可以写文件。</p>
<p><code>seek(long pos)</code>方法将文件指针移动到文件开头pos个字节处。<br />
<code>getFilePointer()</code>返回当前的文件指针的位置。<br />
<code>length()</code>返回文件长度。</p>
<p>例：向文件的末尾添加一个字符串“hi”</p>
<pre class="lang:default decode:true">import java.io.*;

public class Test {
    public static void main(String[] args) {
        RandomAccessFile f;
        try {
            f = new RandomAccessFile("test.txt", "rw");
            f.seek(f.length());
            f.writeUTF("hin");
        } catch (Exception e) {
            System.out.println("error");
        }
    }
}</pre>
<p><code>RandomAccessFile</code>提供了一系列的方法对文件进行各种类型的读写。如<code>writeChar(),writeInt(),readChar(),readInt()</code>等。</p>
<p><b>6</b><b>、自己编写处理流</b></p>
<p>定义处理流只要定义<code>FilterInputStream</code>类的子类，在处理流的构造器中传入需要处理的流，然后定义一些方法利用传入的流进行所需的处理即可。</p>
<p>列：构造处理流，对于输入的字符，只输出数字和回车符，其他字符按空格输出。</p>
<pre class="lang:default decode:true">class NZInputStream extends FilterInputStream {
    public NZInputStream(InputStream in) {
        super(in);
    }
    public int read() throws IOException {
        int c = in.read();
        if (-1 == c) { //结束则返回-1
            return c;
        } else if (Character.isDigit((char)c) || (char)c == 'n') {
            return c; //数字或回车也返回
        } else {
            return ' '; //其他字符返回空格。
        }
    }
}</pre>
<p><b>7</b><b>、对象流</b><br />
<b>8</b><b>、通过URL</b><b>对象访问网页</b></p>
<pre class="lang:default decode:true">import java.util.*;
import java.net.*;
import java.io.*;

public class Test {
    public static void main(String[] args) {
        URL url;
        try {
            url = new URL("http://www.xinyi.sf.net");
            InputStream in = url.openStream();
            BufferedReader reader = new BufferedReader(new InputStreamReader(in));
            String s = reader.readLine();
            while (null != s) {
                System.out.println(s);
                s = reader.readLine();
            }
        } catch (Exception e) {
            System.out.println("error");
        }
    }
}
// 输出：
&lt;!DOCTYPE html&gt;
&lt;!--[if IE 7]&gt;
&lt;html class="ie ie7" lang="en-US"&gt;
&lt;![endif]--&gt;
&lt;!--[if IE 8]&gt;
&lt;html class="ie ie8" lang="en-US"&gt;
&lt;![endif]--&gt;
&lt;!--[if !(IE 7) | !(IE 8) ]&gt;&lt;!--&gt;
&lt;html lang="en-US"&gt;
&lt;!--&lt;![endif]--&gt;
&lt;head&gt;
	&lt;meta charset="UTF-8"&gt;
...</pre>
<p><b>输入输出流小结：</b></p>
<p><code>read()</code>方法：按字符读取，-1表示结束。<br />
<code>read(buffer)</code>：读入数据存入<code>buffer</code>。<br />
<code>read(buffer, offset, length)</code>: 读入数据存入<code>buffer</code>的<code>offset</code>位置</p>
<p>若要读取行，则必须应用处理流。</p>

## 图形界面应用程序

java中各种图形组件如按钮对话框都是<code>Component</code>类的子类，放在容器（<code>Container</code>）中。java中的容器有两类：窗口<code>Window</code>和面板<code>Panel</code>。窗口是可以独立存在的容器，<code>Panel</code>必须放在其他容器中，如窗口或浏览器窗口中。

窗口有两类，一类是具有标题栏、最大化、最小化、按钮的<code>Frame</code>，另一类是对话框<code>Dialog</code>。

使用<code>Frame</code>的主要步骤是：

<pre class="lang:default decode:true">import java.awt.*;

public class Test {
    public static void main(String[] args) {
        Frame f = new Frame("NZ");
        f.setSize(400, 600);
        f.pack(); //自动调整窗口大小
        f.setVisible(true);
        f.setBackground(Color.blue); //设置背景颜色
    }
}</pre>

### 常用图形组件

<p><b>按钮 <code>Button</code></b></p>
<pre class="lang:default decode:true">Panel p = new Panel();
Button b = new Button("NZTest");
p.add(b);
f.add(p);</pre>
<p><b>复选框 Checkbox</b></p>
<p><code>Checkbox c = new Checkbox("test",true);</code> // 第二个参数表示默认选中，否则为 <code>false</code></p>
<p><b>单选项 Radio</b></p>
<pre class="lang:default decode:true">CheckboxGroup g = new CheckboxGroup();
Checkbox c = new Checkbox("Test", g, true); //添加了一个组分类g</pre>
<p><b>下拉列表框</b></p>
<pre class="lang:default decode:true">Choice c = new Choice();
c.addItem("choice 1");</pre>
<p><b>列表框</b></p>
<p>跟下拉列表框类似，只是可以一次显示多行，自动生成滚动条。</p>
<pre class="lang:default decode:true">List l = new List(4,true); // 4表示行数，true表示支持多选。
l.add("listx"); //添加超过四个时，自动生成滚动条。</pre>
<p><b>对话框</b></p>
<p>对话框和Frame都是窗口类型，对话框和Frame相关联，但不是放在Frame中。</p>
<pre class="lang:default decode:true">Frame f = new Frame("NZFrame");
Dialog d = new Dialog(f, "Test" ,true);</pre>
<p>第一个参数为与之相关联的<code>Frame</code>，第三个参数表示对话框处理完毕才可以和<code>Frame</code>交互。就像Word软件，选择“文件/打开”之后出现的对话框。</p>
<p><b>文件对话框</b></p>
<p>文件对话框显示一个对话框让用户选择文件，该对话框用于点击打开文件时调用。语法结构为：</p>
<p><code>FileDialog d = new FileDialog(f, "Selectable");</code></p>
<p>用户选择了哪个文件可由对话框方法<code>getDirectory()</code>和<code>getFile()</code>获得。返回为字符串。</p>
<p>如：<code>String s = d.getDirectory() + d.getFile();</code></p>
<p><b>标签</b></p>
<p><code>Label l = new Label("Label");</code></p>
<p><b>滚动面板</b></p>
<p>对于较大的图形界面，可以放在滚动面板中，然后将滚动面板放在<code>Frame</code>中。</p>
<pre class="lang:default decode:true">Frame f = new Frame("NZFrame");
ScrollPane sp = new ScrollPane();
Panel p = new Panel();
f.add(sp);
sp.add(p);</pre>
<p><b>单行文本框</b></p>
<pre class="lang:default decode:true">TextField tf = new TextField(String s,int length);</pre>
<p><b>多行文本输入框</b></p>
<pre class="lang:default decode:true">TextArea ta = new TextArea(String s,int row,int width);</pre>
<p><b>菜单</b></p>
<p>在Frame中设置菜单栏-》菜单栏中添加菜单-》菜单中添加菜单项。</p>
<pre class="lang:default decode:true">Frame f = new Frame("NZFrame");
MenuBar mb = new MenuBar();
Menu m1 = new Menu("File");
MenuItem m11 = new MenuItem("Open");
MenuItem m12 = new MenuItem("Save");
m1.add(m11);
m1.add(m12);
mb.add(m1);
f.setMenuBar(mb);</pre>
<p>分隔符：<code>m1.addSeparator();</code></p>
<p>菜单选中：如自动换行。使用<code>CheckBoxMenuItem</code>.</p>
<p><b>快捷菜单（常用于右键单击）</b></p>
<p>对于不需要放在固定位置的快捷菜单，可以使用<code>PopupMenu</code>来实现，和普通菜单<code>Menu</code>的使用方法一样，可以添加各种菜单项、选择项、分隔符等。使用<code>show()</code>方法可以指定快捷菜单的显示位置。通常读取鼠标右击的位置来确定快捷菜单在何处显示。</p>
<pre class="lang:default decode:true">Frame f=new Frame("MENU");
PopupMenu m1=new PopupMenu("File");
MenuItem m11=new MenuItem("Open");
MenuItem m12=new MenuItem("Save");
m1.add(m11);
m1.add(m12);
f.add(m1);
m1.show(f,20,50); // 第一个参数是各种组件，后面两个参数是快捷菜单相对于第一个组件的相对显示位置。</pre>

### 布局

<p><b>流布局</b></p>
<p>流布局从左到右，自上而下的顺序放置组件。其使用方式是：<br />
其语法结构为：</p>
<p><code>FlowLayout layout = new FlowLayout();</code></p>
<p>或<code>FlowLayout layout = new FlowLayout(FlowLayout.RIGHT);</code></p>
<p>或<code>FlowLayout layout = new FlowLayout(FlowLayout.LEFT,10,20);</code></p>
<p>后边两个参数表示组件左右、上下间隔多少像素。</p>
<p>使用：<code>f.setLayout(t);</code> 或者<code>f.setLayout(new FlowLayout());</code></p>
<p><b>边界布局</b><br />
<b>网格布局</b><br />
<b>卡片布局</b><br />
<b>网格包布局</b></p>

### 绘图操作
<p>Java中使用<code>Graphics</code>对象可以进行各种绘图操作。定义<code>Panel</code>的子类，重写<code>paint()</code>方法。在该方法的参数中只有一个<code>Graphics</code>对象。窗口刷新时自动执行<code>paint()</code>方法。</p>
<pre class="lang:default decode:true">import java.awt.*;

public class Test extends Panel {
    public static void main(String[] args) {
        Frame f = new Frame("NZ");
        Test t = new Test();
        f.add("Center", t);
        f.setSize(400, 600);
        f.setVisible(true);
    }
    public void paint(Graphics g) {
        System.out.println("repaint");
        Font f = new Font("TimesRoman", Font.BOLD, 18);
        g.setFont(f); //设置字体
        g.drawString("Hello world!", 10, 60);
        g.drawOval(50, 50, 30, 30); //画椭圆
        g.fillRect(200, 200, 40, 80);
    }
}</pre>

### 事件处理

用户单击按钮，自动产生的对象为<code>ActionEvent</code>，自动执行<code>ActionPerformed()</code>方法；按动键盘，自动产生的对象为<code>KeyEvent</code>，自动执行<code>KeyPressed()</code>，<code>KeyReleased()</code>，<code>KeyTyped()</code>方法。
<p><b>按钮事件处理</b></p>
<p>对于鼠标单击按钮的事件，编写事件处理器时需要实现的接口为：<code>ActionListener</code>，该接口中只有一个方法需要实现：<code>ActionPerformed(ActionEvent e)</code>。程序可以如下：</p>
<pre class="lang:default decode:true">import java.awt.event.*;

class Test implements ActionListener{
public void actionPerformed(ActionEvent e) {
    System.out.println(e.getActionCommand()); //可以获得用户单击的按钮所对应的字符串。
    }
}</pre>
<p>按钮添加监听：<code>button.addActionListener(事件处理器);</code></p>
<p><b>键盘处理事件</b></p>
<pre class="lang:default decode:true">import java.awt.*;
import java.awt.event.*;

public class Test implements KeyListener{ //接口
    public void keyTyped(KeyEvent ev) { //接口方法
        char c=ev.getKeyChar();
        System.out.println(“keyTyped”+c);
    }
    public void keyPressed(KeyEvent ev) {
    ...
    }
    public void keyRealeased(KeyEvent ev){
    ...
    }
}</pre>
<p><b>鼠标事件的处理</b></p>
<p>实现的接口有两类：一类是<code>MouseListener</code>，它处理鼠标单击以及鼠标进出操作；另一类是<code>MouseMotionListener</code>，它处理鼠标拖动和移动操作。使用时可以实现其中的一个接口，也可以两个都实现。</p>
<p>对于<code>MouseMotionListener</code>，拖动鼠标将执行<code>mouseDragged()</code>，移动鼠标将执行<code>mouseMoved()</code>。</p>
<p>对于<code>MouseListener</code>，鼠标按钮按下将执行<code>mousePressed()</code>，鼠标按钮释放将执行<code>mouseReleased()</code>，鼠标按钮单击将执行<code>mouseClicked()</code>，鼠标进入组件所在区域将执行<code>mouseEntered()</code>，鼠标离开组件将执行<code>mouseExited()</code>。</p>
<p>方法的参数为<code>MouseEvent</code>，通过其<code>getX()</code>和<code>getY()</code>方法可以获得鼠标的位置，<code>getClickCount()</code>方法可获得单击次数，通过<code>paramString()</code>方法可以获得各种参数，包括单击的模式，由此可判断鼠标操作使用的是左按钮还是右按钮或中间按钮。</p>
<pre class="lang:default decode:true">import java.awt.*;
import java.awt.event.*;

public class Test implemets MouseListener,MouseMotionListener{
    // 对某一组件添加监听。
    public void mouseMoved(MouseEvent ev){
        int x=ev.getX();
        int y=ev.getY();
        System.out.println(“mouseMoved”+x+y);
    }
    ...其它方法类似
}</pre>
<p><b>窗口事件处理</b></p>
<p>接口：<code>WindowListener</code>。</p>
<p>方法：打开执行<code>windowOpened()</code>,单击窗口右上角关闭按钮执行<code>windowClosing()</code>，单击最小化按钮执行<code>windowIconified()</code>和<code>windowDeactivated()</code>，鼠标单击其他窗口也会执行<code>windowDeactivated()</code>，由最小化恢复会执行<code>windowDeiconified()</code>和<code>windowActivated()</code>，当前窗口为其他窗口时单击该窗口，也会执行<code>windowActivated()</code>，窗口被关闭，则执行<code>windowClosed()</code>.</p>
<p>方法参数：<code>WindowEvent e</code></p>
<p><b>选项事件的处理</b></p>
<p>单选按钮、复选框、下拉列表、列表框、菜单中每个选项或菜单项都可以使用选项事件进行处理。</p>
<p>接口：<code>ItemListener</code>，每当选择某个选项，便会自动执行<code>itemStateChanged()</code>方法，该方法的参数为<code>ItemEvent</code>。其<code>getItem()</code>方法可以获得选项对应的字符串，<code>getStateChange()</code>方法可以获得选项是选中（值为<code>ItemEvent.SELECTED</code>）还是未选中（值为<code>ItemEvent.DESELECTED</code>）。</p>
<p>添加监听：<code>.addItemListener(this)</code>；</p>
<p><b>动作事件的处理（文本框）</b></p>
<p><code>ActionListener</code>除了用于鼠标单击按钮外，单行文本框中的回车、列表框中双击选择某个选项也可以用其处理。</p>
<pre class="lang:default decode:true">import java.awt.*;
import java.awt.event.*;

class NZAC implements ActionListener{
    TextField t = new TextField(“you can enter here”,35);
    t.addActionListener(this); //即单行文本框可以自动监听。
    ...
    public void actionPerformed(ActionPerformed e){
        String s = t.getText();
        System.out.println(s);
    }
}</pre>
<p>注意：对于多行文本框<code>TextArea</code>，不能自动监听，可以添加按钮来实现检查和提交功能。</p>
<p><b>多个事件处理器</b></p>
<p>如果对一个组件添加多个事件处理器，则需要对每一个处理器创建一个类。</p>

{% highlight java %}
import java.awt.*;
import java.awt.event.*;

public class TwoListener{
    Button b = new Button("ok");
    b.addActionListener(new xx());
    b.addActionListener(new yy());
}

public class xx implements ActionListener{
    public void actionPerformed(ActionEvent t){
        System.out.println("First"+t.getActionCommand);
    }
}

public class yy implements ActionListener{
    public void actionPerformed(ActionEvent t){
        System.out.println("Second"+t.getActionCommand);
    }
}
{% endhighlight %}

<p><b><code>Adapter</code>类</b></p>
<p>事件处理器实现的接口中往往有多个方法要实现，而某个具体程序用到的可能只是其中的一个，但实现接口时根据接口的语法规则必须把所有方法都实现，因此程序中不使用的方法要写空语句。</p>
<p>为了简化程序，java中预定义了一些特殊的类，这些类应经实现了相应的接口，方法中已经写上空语句，使用时只要将事件处理器作为子类（使用<code>extends</code>，而不是<code>implements</code>）即可。命名规则：只要将接口中的<code>Listener</code>改为<code>Adapter</code>即可。对于只有一个方法需要实现的接口，没有<code>Adapter</code>。</p>

{% highlight java %}
public class NZListener extends WindowAdapter implements WindowListener{
}
{% endhighlight %}

## 通过鼠标双击直接运行java程序
<p>DOS下可以用<code>javac *.java</code>来编译java文件，使用java 类名 来执行程序。</p>
<p><b>制作jar</b><b>文件</b></p>
<p>双击直接运行java程序。</p>
<p>比如有NZFrame.java一文件。</p>
<p><code>javac NZFrame.java</code>编译生成MyFrame.class</p>
<p>然后做一个配置文件，随意起一个文件名如conf.txt，该文件中输入一行内容：</p>
<p><code>Main-Class: NZFrame</code></p>
<p>注意：文件开头顶格，不可有空行空格，<code>Main-Class:</code>后有一空格。该配置文件给出了双击jar文件时运行其中的哪个类。</p>
<p>然后输入如下命令制作jar文件：</p>
<p><code>jar cmf conf.txt NZFrame.jar *.class</code></p>
<p>这样将创建MyFrame.jar，以后只要双击即可执行。</p>
<p><b>使用批处理制作</b></p>
<p>运行jar文件</p>
<p><code>java –jar NZFrame.jar</code></p>
