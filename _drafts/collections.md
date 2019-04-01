---
title: Collections
layout: page
---

{{ site.collections | jsonify }}

{% if site.collections.size > 0 %}
Title | Author | Categories | Tags | Date
:---- | :----: | :--------- | :--- | :--:
	{% for collection in site.collections %} <a href="{{ post.url | prepend: site.baseurl }}">{{ collection.label }}</a> | {{ "||||" }} | {{ post.categories }} | {{ post.tags | }} | {{ post.date }}
	{% endfor %}
{% else %}

No collections available now.

{% endif %}
