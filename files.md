---
layout: page
title: Static Files
published: false
---


{% if site.posts.size > 0 %}
Path | Last Modified Time
:--- | :----------------:
	{% for file in site.static_files %} <a href="{{ file.path | prepend: site.baseurl }}">{{ file.path }}</a> | {{ file.modified_time }}
	{% endfor %}
{% else %}
No static files available now.
{% endif %}
