---
layout: post
title: Flask / Flask SQLAlchemy tipps and tricks
date: 2013-11-15 20:47:00
comments: true
published: false
tags: [ Flask, Flask-SQLAlchemy]
---

I use Flask and Flask-SQLAlchemy for a while now. Doing so i spent a lot of time in searching for the solutions for different problems.
See this as my notebook of helpfull snippets. I will update this post from time to time because i don't want to create a new blog post for each line of helpfull code.

<!-- more -->

## Flask

## Flask SQL-Alchemy

Querying a certain year by a datetime column:

```python
invoices = Invoice.query.filter(extract("year", Invoice.date) == "2012").all()
```

This return all invoices from 2012.
