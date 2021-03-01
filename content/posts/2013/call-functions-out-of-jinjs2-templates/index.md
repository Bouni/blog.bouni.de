---
layout: post
title: Call functions out of jinja2 templates
date: 2013-04-24 06:16:00
comments: true
tags: [ jinja2, flask, programming, python ]
---

I do a few webprojects with [Flask](http://flask.pocoo.org) and I love it!
While creating a template i searched for a way to call functions from within the template, and found out that i can use a `@app.context_processor` decorator.
<!-- more -->

```python
@app.context_processor
def my_utility_processor():

    def date_now(format="%d.m.%Y %H:%M:%S"):
        """ returns the formated datetime """
        return datetime.datetime.now().strftime(format)

    def foo():
        """ returns bulshit """
        return "bar bar bar"

    return dict(date_now=date_now, baz=foo)
```

In the jinja2 template you can now simply call the functions like this:

```jinja
{% raw %}

{% for n in news %}
    Give me some {{ baz() }}!
{% endfor %}

Copyright by me 2005 - {{ date_now("%Y") }}    

{% endraw %}
```

Lets assume news contains 2 elements, the result looks like this:


```jinja
Give me some bar bar bar!

Give me some bar bar bar!

Copyright by me 2005 - 2013    
```


The important part is `return dict(date_now=date_now, baz=foo)`. The first word is the key, the value is a function pointer.
The key is the keyword you write in your template code `{{ baz() }}` for example, `foo` is the name of the function that get called.


