---
layout: post
title: locale-gen fails on raspberry Pi
date: 2013-12-12 13:08:00
comments: true
tags: [ arch, locale, locale-gen, raspberrypi]
---

I've tried to generate the locales on my Raspberry Pi, but i ran into a problem that i was not able to solve for a few hours.

```sh
root@rpi: ~$ locale-gen
Generating locales...
  en_US.UTF-8.../usr/bin/locale-gen: line 41:   303 Killed
localedef -i $input -c -f $charset -A /usr/share/locale/locale.alias
$locale
```

`locale` gave me another error

```sh
root@rpi: ~$ locale
locale: Cannot set LC_CTYPE to default locale: No such file or directory
locale: Cannot set LC_ALL to default locale: No such file or directory
LANG=en_US.UTF-8
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_MESSAGES=C
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
LC_ALL=
```

But finally i found the solution in an inconsiderable forum post. The reason for the locale-gen error is simply not enough RAM!

The solution is easy, just create a swapfile:

```sh
fallocate -l 512M /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
```

Then run `locale-gen` again and it works :-)
