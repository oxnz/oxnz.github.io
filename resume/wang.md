---
title: Resume
layout: page
status: publish
published: true
lang: zh_CN
categories: []
tags: []
redirect_from:
  - /cv/wang/
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

# 张旺
{:class="name"}

<i class="fa fa-fw fa-phone"></i> (+86) 186-1209-6375
<i class="fa fa-fw fa-envelope-o"></i> [m13120331539@163.com](mailto:m13120331539@163.com)
<br/>
{:class="contact"}

## Java 后台开发工程师

* 3 年Java后台开发经验,具有良好的编码习惯和代码调试能力, 熟悉大型项目和服务的开发与部署;
* 善于学习，勤于实践，具有较强的执行能力和组织沟通能力;

## 工作经历

### Java后台开发工程师@[心猫心理](https://www.120xinmao.com){:target='_blank'} &middot; 2015/09 - 2017/03

* #### 心理疾病咨询App

	心理疾病测试，提供线上线下问诊心理咨询师服务。
	提供心理咨询师与患者沟通平台。
	主要负责App后台api开发。

	* 设计并实现心理视频课程模块，使得心理咨询师可以录制视频以授课的形式解决患者心理问题。**为企业新的盈利模式奠定基础**
	* 与第三方支付接口进行对接（微信支付、支付宝支付），完成支付流水自动对账。**使支付模式不在单一化，节省人肉对账成本**
	* 实现心理咨询专家排班，用户预约功能模块，使得用户在线预约相应在线专家。
	* 设计并实现找圈子功能模块（类似朋友圈），使得心理疾病相同用户可找到同种疾病的病友，进行关注或者沟通交流等。

* #### EAP（EmployeeAssistanceProgram 心理援助）项目

	EAP平台主要服务于各大高校，对学生进行心理测试，及早发现患有心理疾病的同学并予以帮助。
	主要负责EAP平台后台开发。

	* EAP后台api编写
	* 优化系统和数据库, 并添加**数据库监控**, **分享数据库调优经验**
	* 设计并实现学生心理疾病预警系统，使得发现有心理疾病倾向的学生被尽早发现。**很大程度提升心理服务精准率**
	* 实现部分高校定制化需求等
	* 提供心理疾病测试，性格测试，人格测试，行为测试等多种测试量表，使得多种测试结合起来进行评估心理疾病，更准确。
	* 系统权限控制。
  
### Java后台开发工程师@[知康科技](http://www.zhikangkeji.com){:target='_blank'} &middot; 2017/03 - 至今

* #### 全身体检App项目

	基于硬件设备与App进行websocket通讯，完成体检，对硬件采集数据进行分析，并等到体检结果。
	主要负责 
	* 前期架构设计，技术方案选型，项目框架搭建，代码规范制定;
	* 中期开发过程中App后台api开发，项目指导，开发进度把控，难点问题解决，代码检查;
	* 后期协助测试进行功能测试，压力测试，接口测试，集成测试，以及版本稳定以后自动化测试等。**分享架构经验**
	* 设计并实现App与体检设备实时通讯，采集人体数据，基于messagepack序列化方式传输。**极大压缩数据大小**
	* 与算法服务进行通讯，基于redis队列实现，最终生成体检报告。
	* 根据用户体检结果进行身体功能修复推荐，使得用户精准了解修复方法。
	* 设计与实现与丁香医生相关问诊接口对接。做到如果接口无响应轮询调用，避免第三方服务宕掉导致服务不可用。**服务容错提升**
	* 实现医生在线问诊功能，根据不同用户不同疾病推荐相应咨询医生，用户可在线付款咨询。

* #### 企业内部管理系统（ERP）

	ERP平台主要服务与公司内部及相关合作方，对合作方进行管理，内部信息管理系统。主要负责ERP项目后台api开发。
	* ERP系统模块（包括：用户模块，组织机构模块，权限管理模块等）api提供
	* 合作方可配置化管理。 **动态配置合作方信息 无需重新开发**
  * 项目管理模块, 发货管理，涉及到的审批流与钉钉进行接口对接，使得节省开发资源。
  * 项目监控，对程序性能，数据库连接情况，硬件情况，虚拟机情况做实时监控。
  * 定时任务可配置化。**动态配置定时任务，无需重启项目**
  * 设备管理功能，体检硬件设备管理，地理位置信息每次变动动态更改记录，配置机器信息可用不可用状态，到期自动停用等。
  * 体检报告管理，第三方合作机构报告管理，己方用户体检报告管理，报告可见不可见，报告样式自定义等。

* #### 其他项目

	* 体检小程序设计与实现
	* 心理测试小程序设计与实现
	* 商城系统小程序设计与实现
	* CRM(客户管理系统)设计与实现
	* 短信平台项目设计与实现，使得短信合作方可配置，避免只局限于单一短信服务商
{:class="proj-list"}

## 专业技能

* JAVA：熟练使用Java语言、具有良好的编码习惯和代码调试能力；
* 前端：熟练使用JavaScript、JQuery、Vue.js等；
* 熟练使用Spring 、Spring MVC，SpringBoot、Hibernate、Mybatis等框架技术进行WEB程序开发；
* 熟练使用Dubbo、zookeeper、Spring Cloud等框架进行分布式开发 
* 数据库：熟悉Oracle、MySql、postgreSQL、Redis等主流数据库；
* 熟悉Linux常用操作；


## 教育背景

北京兴华大学 &nbsp;&nbsp;&nbsp;计算机科学与技术
&middot; 2011/09/01 - 2015/07/01 &middot; 本科
