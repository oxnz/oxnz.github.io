---
title: Resume
layout: page
status: publish
published: true
lang: zh_CN
categories: []
tags: []
redirect_from:
  - /cv/zh_CN/
---

<link href="/assets/css/resume.css" rel="stylesheet" />
<style type="text/css">
.post-content {
	font-family: 'PingFang SC', 'Hiragino Sans GB',
		'Microsoft YaHei',
		'WenQuanYi Micro Hei',
		'Helvetica Neue', Helvetica, Arial, sans-serif;
}

.post-content h4 {
	font-size: 16px;
	margin-bottom: 5px;
}

ul.proj-list {
	margin: 0;
	list-style: none;
}

ul.proj-list > li > ul {
	margin-left: 30px;
	list-style: initial;
}
</style>

[<i class="fa fa-language"></i>](/resume/ '英文简历')
[<i class="fa fa-print"></i>](# '打印简历'){:onclick='window.print()'}
<!--
[<i class="fa fa-download"></i>](/assets/resume.pdf '下载简历')
-->
{:class="ops"}

# 张盼
{:class="name"}

<i class="fa fa-fw fa-phone"></i> (+86) 185-7670-8672
<i class="fa fa-fw fa-envelope-o"></i> [will_d_thomas@icloud.com](mailto:will_d_thomas@icloud.com)
<br/>
<i class="fa fa-fw fa-globe"></i> Blog: [https://oxnz.github.io](https://oxnz.github.io '博客')
Github: [https://github.com/oxnz](https://github.com/oxnz 'Github')
{:class="contact"}

<!--
<br/>
<i class="fa fa-fw fa-map-marker"></i> 北京市海淀区西北旺东路10号院百度科技园3号楼100000
-->

## 后台开发工程师

* 3.5 年大型企业搜索服务系统开发经验, 熟悉大型项目和服务的开发与部署;
* 具有多种语言编程经验, 熟悉 **Linux** 环境开发;
* 善于分析和解决问题;

## 工作经历

### 搜索开发工程师@[腾讯](https://www.tencent.com/){:target='_blank'} &middot; 2016/11 - 至今

* #### [腾讯视频](https://v.qq.com/)搜索项目

	为腾讯视频提供基于 Elasticisearch 的实时索引和在线检索服务。
	主要负责引擎相关研发工作。

	* 集群设计，压力测试，性能优化 (jmeter,Python,Shell)
	**分享性能优化经验**
	* Elasticsearch 中文分词插件开发(基于已有中文分词算法，添加项目相关策略)
	(C++/Java)
	* 第三方接入规范化，平台化改造，**为微信视频/企鹅直播等平台提供索引搜索服务**
	* 查询模版编写，排序模型，查询路由中间件开发 **新接入系统配置即可，不需要发布**
	* ELK 监控系统，logstash 插件开发
	* 数据同步，索引流程自动化 (C++/Python)

### 后台开发工程师@[百度](https://www.baidu.com){:target='_blank'} &middot; 2014/07 - 2016/10

* #### 百度 Hi 消息搜索项目

	为百度 Hi 提供基于 Solr 的消息在线实时索引检索服务。
	主要负责集群的负载均衡和状态监控模块。

	* 改 Solr 集群请求分发过程, 重写请求分发策略，使得对集群的索引和查询请求可以直接定位到相关的特定节点，**从数量级上减少了不必要的请求转发**
	* 设计并实现**逻辑独立**的监控系统, 使得业务逻辑变更时只需要更改配置，而无需改动后台代码, 并且配置可以**继承和重载**，减少重复劳动而不失灵活性, 得到其他平台**重用**
	* 使用 JNI 接口封装自然语言处理库和加解密库 (C/C++, Java)
	* 编写集群自动化部署脚本 (Python, shell)

* #### 百度文档平台项目

	文档平台为百度员工提供文件版本管理和协同编辑。
	主要负责文档平台维护和协同编辑功能开发。

	* 搭建数据库代理, 并编写脚本过滤有问题的查询
	* 优化系统和数据库, 并添加**数据库监控**, **分享数据库调优经验**
	* 搭建 ELK 日志分析系统，接入多个平台日志, 并进行优化以满足大数据量和实时性的需求

* #### 百度 Wiki 项目

	百度 Wiki 是公司的知识管理平台。
	主要负责迁移过程中的数据处理，错误修复以及新系统的开发。

	* 编写各种脚本来自动化旧平台页面错误检测和修复过程，**提高迁移效率40%**
	* **分享脚本开发经验**，获得**百度 Good Coder 认证** (shell)
	* 百度 Hi 公众帐号开发

* #### 其他项目

	* 腾讯视频摘要系统新功能开发与维护 (C++)
	* 百度广告平台日志信息统计系统的设计与实现 (Python, C)
	* 高并发 web 应用服务器设计与实现 (C, Linux)
	* 参与多个**开源项目**（包括 bash-completion, homebrew, Elasticsearch-mustache 等);
	* 工作中工具编写 （文件传输，系统部署，迁移等）
	* 著有 [Moxile](https://oxnz.github.io/moxile/) 编辑器, 被国内外多个软件分发网站编辑推荐
	* Stackoverflow profile: [stackoverflow.com/users/2273296/oxnz](https://stackoverflow.com/users/2273296/oxnz)

{:class="proj-list"}

## 专业技能

语言: C\C++, Python, Shell, Java
<br/>
软件:
MySQL,
Elastic Search, Logstash, Kibana;
Git, Subversion
Solr;
<br/>
系统: Linux (RHEL/Ubuntu) > Unix (FreeBSD, OS X) > Windows Server
<br/>
英语: CET-6 536, 经常参与 stackoverflow 回答讨论问题, 并著有英文博客

## 教育背景

[武汉大学](http://www.whu.edu.cn/){:target='_blank'}
&middot;
信息安全专业
&middot; 2011/09/01 - 2015/07/01 &middot; 校级二等奖学金 (2012)
