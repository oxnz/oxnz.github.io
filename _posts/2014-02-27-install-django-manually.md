---
layout: post
title: 手动安装 Django
date: 2014-02-27 17:31:01.000000000 +08:00
type: post
published: true
status: publish
categories:
- Server
- Django
tags:
- Django
meta:
  _edit_last: '1'
author:
  login: oxnz
  email: yunxinyi@gmail.com
  display_name: Will Z
  first_name: Will
  last_name: Z
---
<ol>
<li>Download the latest release from our download page.</li>
<li>Untar the downloaded file (e.g. <tt>tar xzvf Django-X.Y.tar.gz</tt>, where <tt>X.Y</tt> is the version number of the latest release). If you’re using Windows, you can download the command-line tool <a href="http://gnuwin32.sourceforge.net/packages/bsdtar.htm">bsdtar</a> to do this, or you can use a GUI-based tool such as <a href="http://www.7-zip.org/">7-zip</a>.</li>
<li>Locate the <tt>site-packages</tt> directory. To find your system’s <tt>site-packages</tt> location, execute the following:<br />
python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"<br />
<span style="font-family: Consolas, Monaco, monospace; font-size: 12px; line-height: 18px;">echo ABSPATH-TO-DJANGO &gt; SITE-PACKAGES-DIR/django.pth</span></li>
<li><span style="line-height: 1.5em;">ln -s WORKING-DIR/django-trunk/django/bin/django-admin.py /usr/local/bin/</span></li>
</ol>
