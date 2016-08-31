---
layout: post
title: Django Basics
date: 2014-02-27 17:31:01.000000000 +08:00
type: post
published: true
status: publish
categories:
- Server
- Django
tags:
- Django
---

## Install

1. Download the latest release from our download page.
2. Untar the downloaded file
3. Locate the <tt>site-packages</tt> directory. To find your system’s <tt>site-packages</tt> location, execute the following:

   ```shell
   python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"
   echo ABSPATH-TO-DJANGO > SITE-PACKAGES-DIR/django.pth
   ```

4. Install

   ```shell
   ln -s WORKING-DIR/django-trunk/django/bin/django-admin.py /usr/local/bin/
   ```
