---
layout: page
title: Japanese
nav_order: 3
permalink: /japanese/
---

{% comment %}
  The charts and their positions live in _data/japanese_charts.yml.
{% endcomment %}
{% for stack in site.data.japanese_charts.stacks %}
{% include chart-stack.html stack=stack %}
{% endfor %}

<script src="{{ '/public/js/chart-stack.js' | relative_url }}"></script>
<script src="{{ '/public/js/chart-arrange.js' | relative_url }}"></script>
