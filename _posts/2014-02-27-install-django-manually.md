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

## Table of Contents

* TOC
{:toc}

<!--more-->

## Install

### Install Manually

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

### apt-get

```
sudo apt-get install python-django
```

### pip

**Ubuntu 16.04**

```shell
sudo apt-get install python-pip
sudo pip install Django==1.8.15
```

**RHEL 7.2**

```shell
yum install epel-release
yum install python-pip
sudo pip install Django
```

## Writing App

A application will consists of two parts:

* a public site
* an admin site

### Create Project

```shell
django-admin startproject calc
cd calc
# starting development server at http://0.0.0.0:8000/
python manage.py runserver
python manage.py runserver 0.0.0.0:8080
```

The development server automatically reloads Python code for each request as needed.

```
calc/
    manage.py
	calc/
        __init__.py
        settings.py
        urls.py
        wsgi.py
```

### Database Setup

calc/settings.py

* ENGINE
    * django.db.backends.sqlite3
    * django.db.backends.mysql
* NAME: the name of your database
    * os.path.join(BASE_DIR, 'db.sqlite3')
    * `CREATE DATABASE database_name;`
* USER
* PASSWORD
* HOST
* TIME_ZONE

Some of apps make use of at least one database table, so we need to create the tables in the database before we can use them. To do that, run the following command:

```
python manage.py migrate
```

### Create App

```
python manage.py startapp vm
```

### Models

vm/models.py

```python
class Task(models.Model):
    tid = models.IntegerField(default = 0)
    desc = models.CharField(max_length = 255)
```

#### Activate Models

calc/settings.py

```python
INSTALLED_APPS = (
   ...
   'vm',
)
```

```shell
python manage.py makemigrations vm
# sqlmigrate command takes migration names and returns their SQL
python manage.py sqlmigrate vm 0001
# apply changes to the database
python manage.py migrate
```

```python
# python manage.py shell
from vm.models import Task
task = Task(desc = 'first task')
task.save()
task.id
```

### Admin

```
python manage.py createsuperuser
```

vm/admin.py

```python
from .models import Task
admin.site.register(Task)
class TaskAdmin(admin.ModelAdmin):
    fields = ['desc']
admin.site.register(Task, TaskAdmin)
```

### Views

vm/views.py

```python
from django.http import HTTPResponse
from django.template import loader
from django.shortcuts import render, get_object_or_404
from .models import Task

def index(request):
    tasks = Task.objects.all()
    template = loader.get_template('vm/index.html')
    context = {
        'tasks': tasks,
    }
    return render(request, 'vm/index.html', {'tasks': tasks})

def task(request, task_id):
    task = get_object_or_404(Task, id = task_id)
    return HttpResponse(task)

from django.views.generic import View

class TaskView(View):
    def get(self, request, *args, **kwargs):
        # <view logic>
        return HttpResponse('result')
    def post(self, request, *args, **kwargs):
        # <view logic>
        return HttpResponseRedirect('/success/')
```

vm/urls.py

```python
from django.conf.urls import url
from . import views
from django.contrib.auth.decorators import login_required

urlpatterns = [
    url(r'^$', views.index, name = 'index'),
	url(r'^(?P<task_id>[0-9]+)/$', login_required(views.TaskVew.as_view), name = 'task'),
]
```

calc/urls.py

```python
urlpatterns = [
    url(r'^vm/', include('vm.urls')),
    ...
]
```

calc/settings.py

```
TEMPLATES = [
    {
        DIRS': [os.path.join(BASE_DIR, 'templates')],
    ...
```

vm/template/vm/index.html

```html
% if tasks %
    <ul>
        % for task in tasks %
        <li><a href='% url "vm:task" task.id%'>{{task.id}}. {{task.desc}}</a></li>
        % endfor %
    </ul>
% else %
<p>No tasks available right now.</p>
% endif %
```

#### Function-based generic views

Eearly on it was recognized that there were common idioms and patterns found in view development. Function-based generic views were introduced to abstract these patterns and ease view development for the common cases.

they covered the simple cases well, there was no way to extend or customize them beyond some simple configuration options, limiting thier usefulness in many real-world applications.

#### Class-based Views

* organization of code related to specific HTTP methods (GET, POST, etc) can be addressed by separate methods instead of conditional braching
* object oriented techniques such as mixins (multiple inheritance) can be used to factor code into reusable components

more extensible and flexible than their function-based counterparts.

### URL Namespace

calc/urls.py

```python
urlpatterns = [
    url(r'^vm/', include('vm.urls', namespace = 'vm')),
    ...
]
```

### Tests

#### Why

* Tests will save you time
* Tests don't just identify problems, they prevent them
* Tests make your code more attractive
* Tests help teams work together

#### TestCase

* a separate TestClass for each model or view
* a separate test method for each set of conditions you want to test
* test method names that describe their function

#### Running Tests

```
python manage.py test [vm]
```

## Deploy

Django follows the WSGI spec (PEP 3333), which allows it to run on a variety of server platforms.

### Static Files

```shell
python manage.py collectstatic
```

### Apache with mod_wsgi

mod_wsgi can operate in two modes:

* an embedded mode
    * in embedded mode, mod_wsgi is similar to mod_perl, it embeds Python within Apache and loads Python code into memory when the server starts.
    * Code stays in memory throughout the life of an Apache process, which leads to significant performance gains over other server arrangements.
* a daemon mode
    * In daemon mode, mod_wsgi spawns an independent daemon process that handles requests.
    * The daemon process can run as a different user that the Web server, possibly leading to improved security, and the daemon process can be restarted without restarting the entire Apache Web server, possibly making refreshing your codebase more seamless.

Before going on, make sure you have Apache installed, with the mod_wsgi module activated.

### Nginx with uWSGI

```ini
# web_uwsgi.ini
[uwsgi]
# Django-related settings
socket = :8000

# the base dir (full path)
chdir = /var/www/blog
# Django's wsgi file
module = web.wsgi
# process-related settings
master = true
# maximum number of worker processes
processes = 4

# with appropriate permissions
chmod-socket = 644
# clear env on exit
vacuum = true
```

```conf
# nginx.conf
http {
   server {
        listen 80;
        server_name blog.oxnz.github.io;
        charset UTF-8;
        access_log /var/log/nginx/blog_access.log
        error_log /var/log/nginx/blog_error.log

        client_max_body_size 10M;
        location / {
            include uwsgi_params;
            uwsgi_pass 127.0.0.1:8000;
            uwsgi_read_timeout 2;
        }
        location /static {
            expires 30d;
            autoindex on;
            add_header Cache-Control private;
            alias /var/www/blog/static;
        }
    }
}
```
