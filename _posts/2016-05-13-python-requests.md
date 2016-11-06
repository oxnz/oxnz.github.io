---
layout: post
title: Requests HTTP library for Python
date: 2016-05-13 22:28:00 +0800
categories: python
tags: [requests]
---

## Table of Contents

* TOC
{:toc}

## Make Requests

### JSON-Encoded POST/PATCH

```python
requests.post(url, data=json.dumps(payload))
# or just pass to json parameter (v2.4.2+)
requests.post(url, json=payload)
```

### Form-Encoded

```python
import requests

r = requests.get('https://api.github.com/events')
r = requests.post('https://api.github.com/post', data = {'key':'value'})
r = requests.put('http://httpbin.org/put', data = {'key':'value'})
r = requests.delete('http://httpbin.org/delete')
r = requests.head('http://httpbin.org/get')
r = requests.options('http://httpbin.org/get')
```

<!--more-->

## Passing Parameters In URLs

{% highlight python %}
payload = {'key1': 'value1', 'key2': 'value2'}
r = requests.get('http://httpbin.org/get', params=payload)
{% endhighlight %}

## Authentication

```python
from requests.auth import HTTPBasicAuth
auth = HTTPBasicAuth('username', 'password')

# this is a short hand for HTTPBasicAuth
auth = ('username', 'password')

# digest auth
from requests.auth import HTTPDigestAuth
auth = HTTPBasicAuth('username', 'password')

url = 'http://api.github.com'
r = requests.get(url, auth=auth)

# or pass auth in the url
url = 'http://username:password@api.github.com'
```

## Response Content

{% highlight python %}
r = requests.get('https://api.github.com/events')
r.text
# u'[{"repository":{"open_issues":0,"url":"https://github.com/...
r.encoding
# 'utf-8'
{% endhighlight %}

### Binary Response Content

{% highlight python %}
r.content
# b'[{"repository":{"open_issues":0,"url":"https://github.com/...
{% endhighlight %}

### JSON Response Content

{% highlight python %}
r = requests.get('https://api.github.com/events')
r.json()
# [{u'repository': {u'open_issues': 0, u'url': 'https://github.com/...
{% endhighlight %}

### Raw Response Content

{% highlight python %}
Python 2.7.6 (default, Jun 22 2015, 17:58:13)
[GCC 4.8.2] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import requests
>>> r = requests.get('https://api.github.com/events', stream=True)
>>> r.raw
<urllib3.response.HTTPResponse object at 0x7f78bb5c3310>
>>> r.raw.read(10)
'\x1f\x8b\x08\x00\x00\x00\x00\x00\x00\x03'
{% endhighlight %}

In general, however, you should use a pattern like this to save what is being streamed to a file:

{% highlight python %}
with open(filename, 'wb') as fd:
    for chunk in r.iter_content(chunk_size):
        fd.write(chunk)
{% endhighlight %}

## Custom Headers

{% highlight python %}
>>> url = 'https://api.github.com/some/endpoint'
>>> headers = {'user-agent': 'my-app/0.0.1'}

>>> r = requests.get(url, headers=headers)
{% endhighlight %}

## POST a Multipart-Encoded File

{% highlight python %}
>>> url = 'http://httpbin.org/post'
>>> files = {'file': open('report.xls', 'rb')}

>>> r = requests.post(url, files=files)
>>> r.text
{
  ...
  "files": {
    "file": "<censored...binary...data>"
  },
  ...
}
{% endhighlight %}

## Response Status Codes

{% highlight python %}
>>> r = requests.get('http://httpbin.org/get')
>>> r.status_code
200
>>> r.status_code == requests.codes.ok
True
>>> r.raise_for_status()
None
>>> bad_r = requests.get('http://httpbin.org/status/404')
>>> bad_r.status_code
404

>>> bad_r.raise_for_status()
Traceback (most recent call last):
  File "requests/models.py", line 832, in raise_for_status
    raise http_error
requests.exceptions.HTTPError: 404 Client Error
{% endhighlight %}

## Timeouts

{% highlight python %}
>>> requests.get('http://github.com', timeout=0.001)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
requests.exceptions.Timeout: HTTPConnectionPool(host='github.com', port=80): Request timed out. (timeout=0.001)
{% endhighlight %}

## Errors and Exceptions

{% highlight python %}
requests.exceptions.RequestException
{% endhighlight %}

## References

* [Requests: HTTP for Humans](http://docs.python-requests.org/en/master/)
