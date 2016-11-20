---
layout: page
order: 1
title: Articles
---

{{ site.posts.size }} posts

{% if site.posts.size > 0 %}
Title | Author | Categories | Tags | Date
------|--------|------------|------|------
	{% for post in site.posts %} <a href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a> | {% if post.author.display_name %}{{ post.author.display_name }}{% else %}{{ post.author }}{% endif %} | {{ post.categories | sort | join: ', ' }} | {{ post.tags | sort | join: ', ' }} | {{ post.date | date: "%Y/%m/%d" }}
	{% endfor %}
{% else %}
No articles available now.
{% endif %}
