# Jekyll Index

This Jekyll plugin generates indexes from the front-matter in each post. This plugin attempts mimic the built-in functionality of **tags** and **categories**, but for any metadata specified.

## Installation and Configuration

Copy ```index_generator.rb``` into ```site/_plugins/index_generator.rb```.

Update your ``_config.yml`` with the following or similar settings:

```yaml
indexgenerator:
  - name: Author
    name_plural: Authors
    post_attribute: author_name
    directory: blog/author
    layout: blog-author-index
  - name: Tag
    name_plural: Tags
    post_attribute: tags
    directory: blog/tag
    layout: blog-tag-index
```

Per-index configuration options

<dl>
    <dt>name/name_plural</dt>
    <dd>How you want to referenced the index in a template</dd>
    <dt>post_attribute</dt>
    <dd>The variable you want to index in a post's front-matter</dd>
    <dt>directory</dt>
    <dd>The output directory during a Jekyll build</dd>
    <dt>layout</dt>
    <dd>The layout to use for displaying individual index results</dd>
</dl>

To use the generator, add the attributes you want to index to a post's front-matter:

```yml
---
published: true
private: false
type: post
layout: post
title: Post Title
excerpt: Post Excerpt
tags:
 - tag 1
 - tag 2
categories:
 - category
allow_comments: true
author_name: Josh Freeman
author_email: joshf@grok-interactive.com
---

Post content...

```
## Usage

You can access your indexes two ways: globally and through templates.

To access a single index, use your layout with the following variables:

<dl>
    <dt>page.index_name</dt>
    <dd>the name attribute in your ```_config.yml```</dd>
    <dt>page.indexes</dt>
    <dd>a list of all index names--all authors or tags, for example</dd>
    <dt>page.name</dt>
    <dd>the indivual index name--a particular author or tag, for example</dd>
    <dt>page.items</dt>
    <dd>the posts associated to a particular index</dd>
</dl>

To access all indexes globally, use  ```{{ indexes }}```. Liquid handles hashes a bit
differently than ruby, see below:

```html
{% for index in indexes %}
    <h1>{{index[1].config.name_plural}}</h1>
    <ul>
        {% for item in index[1].items %}
        <li>{{item[0]}}</li>
        {% endfor %}
    </ul>
{% endfor %}
```
Everything in the config hash are the index-specific settings from _config.yml. Everything in the items hash are the generated indexes.
