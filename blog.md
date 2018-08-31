---
layout: blog
---

[//]: #  "## Blog"

<br>

Welcome to my personal blog where I post mostly notes about programming in R or Stata. Enjoy!

<br>
<br>

<ul>
  {% for post in site.posts %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
      <br>
      {{ post.excerpt | remove: '<p>' | remove: '</p>' }}
      <br>
    </li>
    <br>
  {% endfor %}
</ul>


<ul class="tags">
{% for tag in post.tags %}
  <li><a href="/tags#{{ tag }}" class="tag">{{ tag }}</a></li>
{% endfor %}
</ul>
