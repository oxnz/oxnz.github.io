---
title: CentOS Install
published: false
---

# 电脑安装Linux系统步骤

## 下载easybcd 需要安装的linux版本

## 安装easybcd 

##### 打开easybcd ---> 添加新条目   选择NeoGrub  -->添加 --->配置    

### 添加配置文件内容：

```
set title "install centOS"   //设置打开标题 
root(hd0,x)          //x:为磁盘下标 
kernel(hd0,x)/isolinux/vmlinuz repo=hd:/dev/sdb1:/
initrdv(hd0,x)/isolinux/initrd.img
```

##### 打开电脑磁盘管理

###### 新加卷 分配8G内存 再新加卷 分配2G左右内存 类型为FAT32 （用来存放下载的iso文件及解压之后的文件

##### 重启电脑

##### 重启时会提醒： 正常启动windows 、NeoGrub引导加载器（选择NeoGrub引导加载器）

##### 如果配置正确 系统会自动进行安装  如果配置有误 则会提示信息

##### 在提示处输入：root(hd0,按Tab键 选中FAT32分区的磁盘 依次修改kernel initrdv配置

##### 安装完成后 有安装信息设置：语言、时间、键盘、安装源（选择放置iso解压文件的磁盘）、最小安装、安装位置（选择新加卷为8G的磁盘 、选择系统挂载点，设置挂载目录为“/” 大小为8G ）、是否启用KDUMP等 

##### 设置root账户及密码、设置管理员用户及密码

## 从U盘安装

##### 制作镜像至U盘

##### sudo dd if=centos.iso of=/dev/sda bs=lM 

##### 启动时 选择从U盘启动

##### root(hd0,x)选择U盘路径

##### 启动完成shezhi设置语言及时间等选项 

###### 启动 windows系统命令：chainloader (hd0.msdos1)+1  boot 



