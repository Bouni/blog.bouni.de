---
layout: post
title: Clone a Firmware RAID 1 using Clonezilla
date: 2014-11-20 13:26:32 +0100
tags: [ clonezilla, RAID1, Intel-Matrix, Firmware-RAID, Intel-RST, FakeRaid]
---

I had two identical computers of which one had a damaged Windows 7 installation that refused to boot.
The other was a spare machine for that case, but unfortunately it wasn't updated for about 2 years.
So I had to install about 200 Updates which was really annoying.

After all the updates were installed I decided to make an image of the up-to-date computer and restore it on 
the damaged one.

Since I'm a big fan of open source tools, I wanted to use one and decided to use [Clonezilla](http://clonezilla.org/).
The biggest problem with Clonezilla is that it does not support creating images of Software/Fake Raid's/Firmware RAID's according to their website.

My computers both have 2 SSD disks with 120GB each configured as RAID1. The RAID controller is the one provided by the Intel X79 chipset of the ASUS P9X79 Pro Mainboards, which is a Firmware RAID.

<!--more-->

But never give up! So I booted from my Clonezilla USB Drive, followed all the instructions for creating a image and finally arrived at the point where I had to choose which disk I want to save.
I saw 2 entries, `sda`  and `sdb` which told me that clonezilla didn't recognizeed the disks as a single RAID disk.

I created a copy of the good computers `sda` disk because I hoped that the RAID on the damaged one will sync after i've restored the image.

But it failed! Instead the RAID synced the damaged disk back to the one I've just resored! 

:man_facepalming:

But then I thought that maybe if I delete the RAID completely and restore the image afterwards it will work. And, it did :partying_face:

After restoring the image again and rebooting, windows booted up like a charm. Then it took a while to install all drivers (I don't know why the ones contained in the image didn't worked).
When all drivers were installed I saw that the disk was just a single disk, so I started the Intel Matrix RAID utility where i was able to combine both disks into a RAID 1.

The utility emediately started to sync the disks and after about 15 minutes or so I had 2 identical and working computers.

The last thing to do was to activate Windows on the restored computer with its Windows 7 key.

