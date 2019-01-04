---
title: System Administration - macOS
categories: [sysadm]
tags: [macOS]
---

## Introduction

This article describes system administration tasks focused on macOS.

<!--more-->

## Table of Contents

* TOC
{:toc}

## Network

### Setup

`networksetup(8)`

```shell
networksetup -setdhcp "VPN (PPTP123)"
networksetup -renamenetworkservice "VPN (PPTP123" CISCO_VPN
# create new VPN PPTP service on the ethernet interface
networksetup -createnetworkservice "VPN (PPTP)" en0 - where en0
# set IP, subnet, router IP (order = ip subnet route)
networksetup -setmanual "VPN (PPTP)" 192.168.1.172 255.255.255.0 192.168.1.1
networksetup -setdhcp "VPN (PPTP)"
# set DNS
networksetup -setdnsservers "VPN (PPTP)" 8.8.8.8
# set search domain
networksetup -setsearchdomains "VPN (PPTP)" oxnz.github.io
networksetup -removenetworkservice "VPN (PPTP)"
```

### Inspect

get all connection names

```applescript
tell application "System Events"
    tell current location of network preferences
        set names to get name of every service whose active is true
        display dialog names
    end tell
end tell
```

get default gateway

```shell
netstat -nr | grep '^default'
```

### Misc

**Reset DNS Cache**

```shell
sudo killall -HUP mDNSResponder
```

do shell script "some command" with administrator privileges

## NTFS 读写问题

其实os x原生是支持写NTFS分区的，可能是出去安全考虑，默认的NTFS分区都是以只读格式挂载的，所以我也建议平时若非需要，不要更改。如果要写，先推出，后挂载为读写模式。

```console
# 先mount一下看看挂载情况
xinyitekiMacBook-Pro:~ xinyi$ mount
/dev/disk0s2 on / (hfs, local, journaled)
devfs on /dev (devfs, local, nobrowse)
map -hosts on /net (autofs, nosuid, automounted, nobrowse)
map auto_home on /home (autofs, automounted, nobrowse)
/dev/disk0s1 on /Volumes/Windows 8 (ntfs, local, read-only, noowners)
/dev/disk0s8 on /Volumes/Share (ntfs, local, read-only, noowners)
# 要想写把Windows 8 的系统分区，则先推出
umount /Volumes/Windows 8
# 然后指定读写模式挂载
mkdir /Volumes/Windows 8
mount -t ntfs -o rw /dev/disk0s1 /Volumes/Windows 8
# OK!
```

## Terminal

### 终端乱码

表现为javac的输出？？？？？？？？

解决方案:

```bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
```

设置成en_US.UTF-8的好处是，它依然可以正常地显示中文。如果直接是en的话，那么ls的时候中文的文件名就会乱码。

### 高亮

```console
vi ~/.bash_profile
# bash_profile
export CLICOLOR=1
:x # save and exit
```

### File Hidden/Unhidden

苹果Mac OS X操作系统下，隐藏文件是否显示有很多种设置方法，最简单的要算在Mac终端输入命令。显示/隐藏Mac隐藏文件命令如下(注意其中的空格并且区分大小写):

显示Mac隐藏文件的命令:

```shell
defaults write com.apple.finder AppleShowAllFiles -bool true
# or
defaults write com.apple.finder AppleShowAllFiles YES
```

隐藏Mac隐藏文件的命令:

```shell
defaults write com.apple.finder AppleShowAllFiles -bool false
# or
defaults write com.apple.finder AppleShowAllFiles NO
```

after this command executed, relaunch Finder.

重启Finder：鼠标单击窗口左上角的苹果标志-->强制退出-->Finder-->重新启动

### Tips

通常情况下，只有高端用户才会经常用到终端应用。这并不意味着命令行非常难学，有的时候命令行可以轻松、快速的解决问题。相信所有Mac用户都尝试过命令行，今天为大家带来9个非常实用的命令行操作。一些命令行需要安装Xcode之后才可以实用，Xcode在Mac App Store中免费供应。

1. 使用caffeinate阻止Mac运行屏幕保护和睡眠

	caffeinate能阻止Mac进入睡眠状态，而且屏幕保护也不会激活。我们最好使用-t为命令加入具体的时间。比如下面的命令可以使Mac一小时内不进入睡眠状态。

   ```
   caffeinate -t 3600
   ```

2. 使用pkgutil解压PKG文件

	如果你想查看PKG安装文件中的某个特殊文件，你可以使用pkgutil命令完成。下面的命令会将macx.pkg文件解压至桌面

   ```
   pkgutil --expand macx.pkg ~/Desktop/
   ```

3. 使用purge命令释放内存

	purge命令可以清除内存和硬盘的缓存，与重启Mac的效果差不多。purge命令可以让不活跃的系统内存转变为可以使用的内存。你只需在终端中输入下面的命令即可。

   ```
   purge
   ```

4. 使用open命令开启多个相同应用

	open命令可以在终端中开启应用，使用-n可以开启多个相同应用。比如你可以使用下面的命令开启新Safari窗口

   ```
   open -n /Applications/Safari.app/
   ```

5. 不通过App Store更新OS X

	想要更新系统却不想打开臃肿的Mac App Store？下面的命令可以帮助你使用终端升级OS X。

   ```
   sudo softwareupdate -i -a
   ```

6. 将所有下载过的文件列出来

	我们可以通过下面的命令将所有下载过的内容列出来

   ```
   sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'select LSQuarantineDataURLString from LSQuarantineEvent' |more
   ```

7. 使用chflags命令隐藏文件或文件夹

	如果你想让某个文件或文件夹影藏，那么chflags命令可以实现。你只需将文件路径填对即可，比如我们向隐藏桌面上的macx文件夹。如果你想再次看到文件夹，只需将hidden改为nohidden即可。

   ```
   chflags hidden ~/Desktop/macx
   ```

8. 自动输入文件路径

	你知道从Finder中将任意文件拖拽至终端窗口即可获得文件的详细路径么。当你想输入某个文件的路径，不妨将文件拖拽试试。

9. 创建有密码保护的压缩文件

	你可以通过下面的命令将桌面上的macx.txt文件创建成有密码保护压缩文件protected.zip。

   ```shell
   zip -e protected.zip ~/Desktop/macx.txt
   ```
