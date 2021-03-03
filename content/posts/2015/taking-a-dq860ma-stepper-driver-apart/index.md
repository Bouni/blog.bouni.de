---
layout: post
title: Taking a DQ860MA stepper driver apart
date: 2015-02-03 09:05:39 +0100
tags: [ stepper driver, DQ860MA, teardown, reverse engeneering]
---

I've bought 4 large stepper motors and 4 DQ860MA drivers on ebay a few days ago. Unfortunately one was faulty from the beginning.
The seller sent me a new one winthin 2 days which is awesome, but the best part is that i hadn't to return the damaged one!

So i decided that there are pepole out there who for sure are interested in a teardown :-)

<!--more-->

This is the view when taking the plasic cover off. Its basically what i expected to see, the control part on the top layer,
the FET's on the bottom where the the heat sink is. As you can see the PCB is labled with V2.2 which seems to be the most recent version.


!["The cover removed"](DQ860MA-1.JPG)


Here is another picture of the top side without reflections. The controller is unfortunately not labeled at all. Its not polished so i assume that its a counterfeit chip.
The enable optocoupler is a PC817, the STEP and DIR optocoupler is a HCPL2531. The Mosfet drivers are [IR2106S](http://www.irf.com/product-info/datasheets/data/ir2106.pdf) high and low side drivers.
In the lower left corner is a switching regulator cicuit that generates the voltage for the Mosfet drivers, next to that is a AMS1117 5.0 that generates the 5V for the controller.


!["The top side"](DQ860MA-2.JPG)


On the bottom are the 2 H-Bridges built from 8 [IRF540N](http://www.irf.com/product-info/datasheets/data/irf540n.pdf) HexFet Power Mosfets. Furthermore there are the protection diodes [UF2G](http://pdf.datasheetcatalog.com/datasheet/wte/UF2B-T1.pdf). And a lot of small passives.

!["The bottom side"](DQ860MA-3.JPG)


I decided to remove all the THT components to get a better look on the PCB traces below. Actually i just damaged 1 part doing this, the PC817 optocoupler, which is a good result in my eyes ;-)


!["The top side without THTs"](DQ860MA-4.JPG)


!["The bottom side without THTs"](DQ860MA-5.JPG)


I will try to create an Eagle schematic for this driver within the next weeks and publish it here. In the meantime if you whant to know something, just use the comments below!
