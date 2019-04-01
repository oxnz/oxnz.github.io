---
layout: post
title: Runtime of Objective-C
type: post
categories:
- cocoa
- objc
tags: []
---

<p>--  [1] 版本和平台<br />
--  [2] 与Runtime System交互<br />
--  [3] 方法的动态决议<br />
--  [4] 消息转发<br />
--  [5] 类型编码<br />
--  [6] 属性声明</p>
<p>[1] 版本和平台</p>
<p>Runtime System对于Objective-C来说就好比是它的操作系统，或者说是运行的支撑平台，它使得Objective-C代码能够按照既定的语言特性跑起来。相对于C/C++来说，Objective-C尽可能地把一些动作推迟到运行时来执行，即尽可能动态地做事情。因此，它不仅需要一个编译器，还需要一个运行时环境来执行编译后的代码。</p>
<p>Runtime System分为Legacy和Modern两个版本，一般来说，我们现在用的都是Modern版本。Modern版本的Runtime System有一个显著的特征就是“non-fragile”，即父类的成员变量的布局发生改变时，子类不需要重新编译。此外，还支持为声明的属性进行合成操作（即<em><strong>@property</strong></em>和<em><strong>@synthesis</strong></em>）。</p>
<p><!--more--></p>
<p>下面会讨论<span style="text-decoration: underline;">NSObject类</span>、<span style="text-decoration: underline;">Objective-C程序如何与Runtime System交互</span>、<span style="text-decoration: underline;">运行时动态地加载类</span>、<span style="text-decoration: underline;">发消息给其它对象</span>，以及<span style="text-decoration: underline;">运行时如何获取对象信息</span>。</p>
<p>&nbsp;</p>
<p>[2] 与Runtime System交互</p>
<p>Objective-C程序和Runtime System在三个不同层次进行交互：通过Objective-C源码；通过NSObject定义的函数；以及通过直接调用runtime functions。</p>
<p>&nbsp;</p>
<p>通常来讲，Runtime System都是在幕后工作，我们需要做的就是编写Objective-C代码，然后编译。编译器会为我们创建相应的数据结构和函数调用来实现语言的动态特性。这些数据结构保存着在类、Category定义和Protocol声明中所能找到的信息，包括成员变量模板、selectors，以及其它从源码中提取到的信息。</p>
<p>Runtime System是一个动态共享库，位于<em>/usr/include/objc</em>，拥有一套公共的接口，由一系列函数和数据结构组成。开发人员可以使用纯C调用一些函数来做编译器做的事情，或者扩展Runtime System，为开发环境制作一些工具等等。尽管一般情况下，编写Objective-C并不需要了解这些内容，但有时候会很有用。所有的函数都在<a href="http://www.google.com/url?sa=t&amp;rct=j&amp;q=&amp;esrc=s&amp;source=web&amp;cd=1&amp;ved=0CCkQFjAA&amp;url=http%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2FCocoa%2FReference%2FObjCRuntimeRef%2FReference%2Freference.html&amp;ei=pzBkT_2SM6KiiAf4usjFBQ&amp;usg=AFQjCNHUPc7kKFnX0NnbsY9PvlOg41SlZg&amp;sig2=nSIIAeXUm0CL5-YSjEZ82w">Objective-C Runtime Reference</a>有文档化信息。</p>
<p>&nbsp;</p>
<p>Cocoa中大部分对象都是NSObject的子类（NSProxy是一个例外），继承了NSObject的方法。因此在这个继承体系中，子类可以根据需求重新实现NSObject定义的一些函数，实现多态和动态性，比如<em>description</em>方法（返回描述自身的字符串，类似Python中开头的三引号）。</p>
<p>一些NSObject定义的方法只是简单地询问Runtime System获得信息，使得对象可以进行自省（introspection），比如用来确定类类型的isKindOfClass:，确定对象在继承体系中的位置的isMemberOfClass:，判断一个对象是否能接收某个特定消息的respondsToSelector:，判断一个对象是否遵循某个协议的conformsToProtocol:，以及提供方法实现地址的methodForSelector:。这些方法让一个对象可以进行自省（<strong><em>introspect about itself</em></strong>）。</p>
<p>&nbsp;</p>
<p>最主要的Runtime函数是用来发送消息的，它由源码中的消息表达式激发。发送消息是Objective-C程序中最经常出现的表达式，而该表达式最终会被转换成objc_msgSend函数调用。比如一个消息表达式[receiver message]会被转换成<em>objc_msgSend(receiver, selector)</em>，如果有参数则为<em>objc_msgSend(receiver, selector, arg1, arg2, …)</em>。</p>
<p>消息只有到运行时才会和函数实现绑定起来：首先<em>objc_msgSend</em>在receiver中查找selector对应的函数实现；然后调用函数过程，将receiving object（即this指针）和参数传递过去；最后，返回函数的返回值。</p>
<p>发送消息的关键是<strong><span style="text-decoration: underline;">编译器为类和对象创建的结构</span></strong>，包含两个主要元素，一个是指向superclass的指针，另一个是类的dispatch table，该dispatch table中的表项将<span style="text-decoration: underline;"><strong>selector和对应的函数入口地址关联</strong></span>起来。</p>
<p>当一个对象被创建时，内存布局中的第一个元素是指向类结构的指针，isa。通过isa指针，一个对象可以访问它的类结构，进而访问继承的类结构。示例图可参见<em><span style="text-decoration: underline;"><a href="https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtHowMessagingWorks.html#//apple_ref/doc/uid/TP40008048-CH104-SW1">此处</a></span></em>。</p>
<p>当向一个对象发送消息时，objc_msgSend先通过isa指针在类的dispatch table中查找对应selector的函数入口地址，如果没有找到，则沿着class hierarchy（类的继承体系）寻找，直到NSObject类。这就是在运行时选择函数实现，用OOP的行话来说，就是动态绑定。</p>
<p>为了加速发送消息的速度，Runtime System为每个类创建了一个<strong><em>cache</em></strong>，用来缓存selector和对应函数入口地址的映射。</p>
<p>&nbsp;</p>
<p>当objc_msgSend找到对应的函数实现时，它除了传递函数参数，还传递了两个隐藏参数：<em>receiving object</em>和<em>selector</em>。之所以称之为隐藏参数，是因为这两个参数在源代码中没有显示声明，但还是可以通过self和_cmd来访问。</p>
<p>当一个消息要被发送给某个对象很多次的时候，可以直接使用methodForSelector:来进行优化，比如下述代码：</p>
<p>&nbsp;</p>
<div>
<div>
<div>
<p><b>[cpp]</b> <a title="view plain" href="http://blog.csdn.net/jasonblog/article/details/7246822#">view plain</a><a title="copy" href="http://blog.csdn.net/jasonblog/article/details/7246822#">copy</a></p>
<div></div>
</div>
</div>
<ol start="1">
<li>//////////////////////////////////////////////////////////////</li>
<li>void (*setter)(id, SEL, BOOL);</li>
<li>int i;</li>
<li></li>
<li>setter = (void (*)(id, SEL, BOOL))[target</li>
<li>     methodForSelector:@selector(setFilled:)];</li>
<li>for ( i = 0; i &lt; 1000, i++ )</li>
<li>     setter(targetList[i], @selector(setFilled:), YES);</li>
<li>//////////////////////////////////////////////////////////////</li>
</ol>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>其中，methodForSelector:是由Cocoa Runtime System提供的，而不是Objective-C本身的语言特性。这里需要注意转换过程中函数类型的正确性，包括返回值和参数，而且这里的前两个参数需要显示声明为id和SEL。</p>
<p>&nbsp;</p>
<p>[3] 方法的动态决议</p>
<p>有时候我们想要为一个方法动态地提供实现，比如Objective-C的<em>@dynamic</em>指示符，它告诉编译器与属性对应的方法是动态提供的。我们可以利用resolveInstanceMethod:和resolveClassMethod:分别为对象方法和类方法提供动态实现。</p>
<p>一个Objective-C方法本质上是一个拥有至少两个参数（self和_cmd）的C函数，我们可以利用class_addMethod向一个类添加一个方法。比如对于下面的函数：</p>
<p>&nbsp;</p>
<div>
<div>
<div>
<p><b>[cpp]</b> <a title="view plain" href="http://blog.csdn.net/jasonblog/article/details/7246822#">view plain</a><a title="copy" href="http://blog.csdn.net/jasonblog/article/details/7246822#">copy</a></p>
<div></div>
</div>
</div>
<ol start="1">
<li>//////////////////////////////////////////////////////////////</li>
<li>void dynamicMethodIMP(id self, SEL _cmd) {</li>
<li>     // implementation ….</li>
<li>}</li>
<li>//////////////////////////////////////////////////////////////</li>
</ol>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>我们可以利用resolveInstanceMethod:将它添加成一个方法（比如叫<em>resolveThisMethodDynamically</em>）：</p>
<p>&nbsp;</p>
<div>
<div>
<div>
<p><b>[cpp]</b> <a title="view plain" href="http://blog.csdn.net/jasonblog/article/details/7246822#">view plain</a><a title="copy" href="http://blog.csdn.net/jasonblog/article/details/7246822#">copy</a></p>
<div></div>
</div>
</div>
<ol start="1">
<li>//////////////////////////////////////////////////////////////</li>
<li>@implementation MyClass</li>
<li>+ (BOOL)resolveInstanceMethod:(SEL)aSEL</li>
<li>{</li>
<li>     if (aSEL == @selector(resolveThisMethodDynamically)) {</li>
<li>          class_addMethod([self class], aSEL, (IMP) dynamicMethodIMP, "v@:");</li>
<li>          return YES;</li>
<li>     }</li>
<li>     return [super resolveInstanceMethod:aSEL];</li>
<li>}</li>
<li>@end</li>
<li>//////////////////////////////////////////////////////////////</li>
</ol>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>动态决议和发送消息并不冲突，在消息机制起作用之前，一个类是有机会动态决议一个方法的。当respondsToSelector:或者instancesRespondToSelector:被激活时，dynamic method resolver会优先有个机会为这个selector提供一份实现。如果实现了resolveInstanceMethod:，对于不想动态决议而想让其遵循消息转发机制的selectors，返回NO即可。</p>
<p>Objective-C程序可以在运行时链接新的类和category。动态加载可以用来做很多不同的事情，比如System Preferences里头各种模块就是动态加载的。尽管有运行时函数可以动态加载Objective-C模块（objc/objc-load.h中的objc_loadModules），但Cocoa的NSBundle类提供了更方便的动态加载接口。</p>
<p>&nbsp;</p>
<p>[4] 消息转发</p>
<p>向一个对象发送它不处理的消息是一个错误，不过在报错之前，Runtime System给了接收对象第二次的机会来处理消息。在这种情况下，Runtime System会向对象发一个消息，forwardInvocation:，这个消息只携带一个NSInvocation对象作为参数——这个NSInvocation对象包装了原始消息和相应参数。</p>
<p>通过实现forwardInvocation:方法（继承于NSObject），可以给不响应的消息一个默认处理方式。正如方法名一样，通常的处理方式就是转发该消息给另一个对象:</p>
<p>&nbsp;</p>
<div>
<div>
<div>
<p><b>[cpp]</b> <a title="view plain" href="http://blog.csdn.net/jasonblog/article/details/7246822#">view plain</a><a title="copy" href="http://blog.csdn.net/jasonblog/article/details/7246822#">copy</a></p>
<div></div>
</div>
</div>
<ol start="1">
<li>//////////////////////////////////////////////////////////////</li>
<li>- (void)forwardInvocation:(NSInvocation *)anInvocation</li>
<li>{</li>
<li>     if ([someOtherObject respondsToSelector:[anInvocation selector]])</li>
<li>          [anInvocation invokeWithTarget:someOtherObject];</li>
<li>     else</li>
<li>          [super forwardInvocation:anInvocation];</li>
<li>}</li>
<li>//////////////////////////////////////////////////////////////</li>
</ol>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>对于不识别的消息（在dispatch table中找不到），forwardInvocation:就像一个中转站，想继续投递或者停止不处理，都由开发人员决定。</p>
<p>&nbsp;</p>
<p>[5] 类型编码</p>
<p>为了支持Runtime System，编译器将返回值类型、参数类型进行编码，相应的编译器指示符是<em>@encode</em>。</p>
<p>比如，void编码为v，char编码为c，对象编码为@，类编码为#，选择符编码为:，而符合类型则由基本类型组成，比如</p>
<p>&nbsp;</p>
<div>
<div>
<div>
<p><b>[cpp]</b> <a title="view plain" href="http://blog.csdn.net/jasonblog/article/details/7246822#">view plain</a><a title="copy" href="http://blog.csdn.net/jasonblog/article/details/7246822#">copy</a></p>
<div></div>
</div>
</div>
<ol start="1">
<li>typedef struct example {</li>
<li>     id     anObject;</li>
<li>     char *aString;</li>
<li>     int anInt;</li>
<li>} Example;</li>
</ol>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>编码为{example=@*i}。</p>
<p>&nbsp;</p>
<p>[6] 属性声明</p>
<p>当编译器遇到属性声明时，它会生成一些可描述的元数据（metadata），将其与相应的类、category和协议关联起来。存在一些函数可以通过名称在类或者协议中查找这些metadata，通过这些函数，我们可以获得编码后的属性类型（字符串），复制属性的attribute列表（C字符串数组）。因此，每个类和协议的属性列表我们都可以获得。</p>
<p>&nbsp;</p>
<p>与类型编码类似，属性类型也有相应的编码方案，比如readonly编码为R，copy编码为C，retain编码为&amp;等。</p>
<p>通过property_getAttributes函数可以后去编码后的字符串，该字符串以T开头，紧接@encode type和逗号，接着以V和变量名结尾。比如：</p>
<p>&nbsp;</p>
<div>
<div>
<div>
<p><b>[cpp]</b> <a title="view plain" href="http://blog.csdn.net/jasonblog/article/details/7246822#">view plain</a><a title="copy" href="http://blog.csdn.net/jasonblog/article/details/7246822#">copy</a></p>
<div></div>
</div>
</div>
<ol start="1">
<li>@property char charDefault;</li>
</ol>
</div>
<p>&nbsp;</p>
<p>描述为：<strong><em>Tc,VcharDefault</em></strong></p>
<p>&nbsp;</p>
<div>
<div>
<div>
<p><b>[cpp]</b> <a title="view plain" href="http://blog.csdn.net/jasonblog/article/details/7246822#">view plain</a><a title="copy" href="http://blog.csdn.net/jasonblog/article/details/7246822#">copy</a></p>
<div></div>
</div>
</div>
<ol start="1">
<li>@property(retain)ididRetain;</li>
</ol>
</div>
<p>&nbsp;</p>
<p>描述为：<em><strong>T@,&amp;,VidRetain</strong></em></p>
<p>&nbsp;</p>
<p>Property结构体定义了一个指向属性描述符的不透明句柄：<strong><em>typedef struct objc_property *Property;</em></strong>。</p>
<p>通过class_copyPropertyList和protocol_copyPropertyList函数可以获取相应的属性数组：</p>
<p>&nbsp;</p>
<div>
<div>
<div>
<p><b>[cpp]</b> <a title="view plain" href="http://blog.csdn.net/jasonblog/article/details/7246822#">view plain</a><a title="copy" href="http://blog.csdn.net/jasonblog/article/details/7246822#">copy</a></p>
<div></div>
</div>
</div>
<ol start="1">
<li>objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount)</li>
<li>objc_property_t *protocol_copyPropertyList(Protocol *proto, unsigned int *outCount)</li>
</ol>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>通过property_getName函数可以获取属性名称。</p>
<p>通过class_getProperty和protocol_getProperty可以相应地根据给定名称获取到属性引用：</p>
<p>&nbsp;</p>
<div>
<div>
<div>
<p><b>[cpp]</b> <a title="view plain" href="http://blog.csdn.net/jasonblog/article/details/7246822#">view plain</a><a title="copy" href="http://blog.csdn.net/jasonblog/article/details/7246822#">copy</a></p>
<div></div>
</div>
</div>
<ol start="1">
<li>objc_property_t class_getProperty(Class cls, const char *name)</li>
<li>objc_property_t protocol_getProperty(Protocol *proto, const char *name, BOOL isRequiredProperty, BOOL isInstanceProperty)</li>
</ol>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>通过property_getAttributes函数可以获取属性的@encode type string：</p>
<p>const char *property_getAttributes(objc_property_t property)</p>
<p>&nbsp;</p>
<p>以上函数组合成一段示例代码：</p>
<p>&nbsp;</p>
<div>
<div>
<div>
<p><b>[cpp]</b> <a title="view plain" href="http://blog.csdn.net/jasonblog/article/details/7246822#">view plain</a><a title="copy" href="http://blog.csdn.net/jasonblog/article/details/7246822#">copy</a></p>
<div></div>
</div>
</div>
<ol start="1">
<li>@interface Lender : NSObject {</li>
<li>     float alone;</li>
<li>}</li>
<li>@property float alone;</li>
<li>@end</li>
<li></li>
<li>id LenderClass = objc_getClass("Lender");</li>
<li>unsigned int outCount, i;</li>
<li>objc_property_t *properties = class_copyPropertyList(LenderClass, &amp;outCount);</li>
<li>for (i = 0; i &lt; outCount; i++) {</li>
<li>     objc_property_t property = properties[i];</li>
<li>     fprintf(stdout, "%s %sn", property_getName(property), property_getAttributes(property));</li>
<li>}</li>
</ol>
</div>
<p>&nbsp;</p>
<p>[Last Updated] 2012-03-17</p>
<p>参考资料：<a href="http://www.google.com/url?sa=t&amp;rct=j&amp;q=&amp;esrc=s&amp;source=web&amp;cd=1&amp;ved=0CC8QFjAA&amp;url=http%3A%2F%2Fdeveloper.apple.com%2Fdocumentation%2FCocoa%2FConceptual%2FObjCRuntimeGuide%2FIntroduction%2FIntroduction.html&amp;ei=LjJkT8K1I62tiQek_YHKBQ&amp;usg=AFQjCNFCQkOn80S61Zld8s-owjTz9ywvDQ&amp;sig2=kbGgaMQr0GoklyLwigew-w">Objective-C Runtime Programming Guide</a></p>
<p>&nbsp;</p>
<p>Jason Lee @ 杭州</p>
<p>博客：<a href="http://blog.csdn.net/jasonblog">http://blog.csdn.net/jasonblog</a></p>
<p>微博：<a href="http://weibo.com/jasonmblog">http://weibo.com/jasonmblog</a></p>
<p>GitHub：<a href="https://github.com/siqin">https://github.com/siqin</a></p>
