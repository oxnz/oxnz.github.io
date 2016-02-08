---
title: Articles
layout: page
---


{% if site.posts.size > 0 %}
Title | Author | Categories | Tags | Date
:---- | :----: | :--------- | :--- | :--:
	{% for post in site.posts %} <a href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a> | {{ post.author.display_name }} | {{ post.categories | sort | join: ', ' }} | {{ post.tags | sort | join: ', ' }} | {{ post.date | date: "%Y/%m/%d" }}
	{% endfor %}
{% else %}
No articles available now.
{% endif %}
