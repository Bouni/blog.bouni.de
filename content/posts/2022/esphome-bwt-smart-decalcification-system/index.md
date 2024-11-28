---
title: "Making BWT AQA Smart Life S decalcification system a bit smarter"
date: 2022-01-19T09:11:00+01:00
tags: [BWT, AQA life S, ESPHome, esp, esp32, TCS34725, smart home, home-assistant]
---

I run a [BWT AQA Life S](https://www.bwt.com/de-at/shop/AQA-life/82016) decalcification system because where I live we have enormous amounts of calcium in our tap water.
In the past I had multiple occasions where the system malfunctioned and spilled water in my basement where it is located.
The system is not smart by any means, it just starts to beep when ever attention is needed. Unfortunately this beep is not really audible in the living area of the house.
Thats also the case when I need to top up the regenartion salt which is the most common "error".

<!--more-->

As the device itself does not have an interface I could use to get information out of, I make use of the fact that the display changes color depending on the state.
It blue in **normal** operation, green-ish yellow in **regeneration mode** and red in **error** mode.

{{<thumbnail width="400x" src="bwt-aqa-life-s.jpg" alt="BWT AQA Life S" caption="Image from Selfio.de" link="https://www.selfio.de/media/image/9a/c7/a4/wasseraufbereitung-enthaertungsanlage-bwt-aqa_live_s-selfio-11316-1-magento_600x600.jpg">}}

Thats enough information for me, conection to the control electronics itself is unecessary in my opinion.

I bought an Adafruit **RGB Color Sensor with IR filter and White LED** which uses the **AMS TCS34725 Color Sensor** as its main part.

{{<thumbnail width="400x" src="adafruit-tcs34725.jpg" alt="Adafruit TCS34725 board" caption="Image from AliExpress" link="https://de.aliexpress.com/item/32756859926.html">}}

That is connected to an **MH-ET LIVE MiniKit ESP32** which is my favourite ESP32 dev board because of its small form factor and low price.

{{<thumbnail width="400x" src="MH-ET-LIVE-D1-Mini-ESP32.jpg" alt="MH-ET LIVE MiniKit ESP32 board" caption="Image from AliExpress" link="https://de.aliexpress.com/item/1005003696879715.html">}}

## Wiring

The wiring is pretty straight forward


{{<thumbnail width="400x" src="wiring.jpg" alt="wiring" >}}

 1. 3.3V <-> 3V3
 2. GND <-> GND
 3. IO21 <-> SDA
 4. IO22 <-> SCL

 I added a bridge wire from GND to LED on the TCS34725 board to deactivate the build in LED as I don't need it.

 ## Code

 I initially ran a self written REST implementation but decided to go for [ESPhome](esphome.io/) because it integrates nicely with [Home-Assistant](home-assistant.io/) and handles the Wifi stuff like captive portal, reconnect etc. perfectly.

 {{<github repo="bouni/esphome-bwt-sensor" file="bwt.yaml" lang="yaml" linenos=true style="onedark">}}

 ## Result

 I temporarily mounted the boards with tape to the decalcification system but I plan to create a 3D printed mount for it.

{{<thumbnail width="400x" src="bwt-sensor-setup.png" alt="setup" >}}

Adding the sensor to Home-Assistant ist very easy, the ESPHome integration is absolutely perfect!

{{<thumbnail width="400x" src="bwt-ha.png" alt="Home Assistant card" >}}

I also added an automation to Home-Assistant that sens me a notification whenever the state changes to error.

