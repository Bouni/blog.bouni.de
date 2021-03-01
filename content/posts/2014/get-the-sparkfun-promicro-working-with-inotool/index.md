---
layout: post
title: Get the SparkFun ProMicro working with inotool
date: 2014-04-08 06:13:26 +0200
tags: [ Arduino, ino, shell, vim]
---

I've recently bought a few [SparkFun ProMicro 5V 16Mhz](https://www.sparkfun.com/products/12640) clones from Ebay because they are extremely cheap (7 Euro each) and habe native USB.
The only problem i had is that i was not able to program them using [inotool](http://inotool.org/). 
<!-- more -->

## The upload issue

To get them working with the Arduino IDE you simply have to download the so called "Arduino Addon files" from Sparkfun and place them in the hardware folder of your Arduino installation. The IDE then recognizes them and provides you the new board models for compilation and uploads. Sometimes it works, but somtimes it will not upload the compiled source and give me this error message:

```sh
Found programmer: Id = "Hello w"; type = o
    Software Version = H.e; Hardware Version = l.l
avrdude: error: buffered memory access not supported. Maybe it isn't
a butterfly/AVR109 but a AVR910 device?
```

As you can see you can read parts of the Hello World string that is continously sent by the [Example 1: Blinkies!](https://learn.sparkfun.com/tutorials/pro-micro--fio-v3-hookup-guide/example-1-blinkies) sketch that was running at the time i tried to upload source. This indicates that the software reset didn't worked correctly for some unknown reason.

## arduino modifications

So I decided to get this working with inotool to avoid using the Arduino IDE and probably fix the upload issue at the same time.
I downloaded the Arduino Addon Files again and checked the contents:

```sh
    ├── boards.txt
    ├── bootloaders
    │   └── caterina
    │       ├── build.txt
    │       ├── Caterina.c
    │       ├── Caterina-fio.hex
    │       ├── Caterina.h
    │       ├── Caterina.hex
    │       ├── Caterina-lilypadusb.hex
    │       ├── Caterina-makey.hex
    │       ├── Caterina-minibench.hex
    │       ├── Caterina-promicro16.hex
    │       ├── Caterina-promicro8.hex
    │       ├── Caterina-wiflyin.hex
    │       ├── Descriptors.c
    │       ├── Descriptors.h
    │       ├── Makefile
    │       ├── program.txt
    │       └── Readme.txt
    ├── driver
    │   ├── FioV3.inf
    │   ├── LilyPadUSB.inf
    │   ├── MakeyMakey.inf
    │   ├── Minibench.inf
    │   ├── ProMicro.inf
    │   └── WiFlyin.inf
    ├── README.md
    └── variants
        ├── minibench
        │   └── pins_arduino.h
        └── promicro
            └── pins_arduino.h

    6 directories, 26 files
```

 - The boards.txt has the definitions for the 4 Sparkfun boards with AtMega32u4 processors (Pro Micro 5V, Pro Micro 3.3V, Fio 3.3V, Makey Makey).
 - In the bootloaders folder is a modified/extended version of the original caterina bootloader for the Leonardo.
 - The drivers folder contains the windows drivers for the boards.
 - variants contains the pin configurations.

If you simply install the Addon files as usually (copy the folder into the hardware folder), inotool recognizes the new boards, but fails to compile/upload.
So i tried to integrate the new files into the original folders:


```sh
sed -i 's/caterina/caterina-sparkfun/g' ~/Downloads/SF32u4_boards-master/boards.txt
cat ~/Downloads/SF32u4_boards-master/boards.txt >> /usr/share/arduino/hardware/arduino/boards.txt
cp -r ~/Downloads/SF32u4_boards-master/bootloaders/caterina/ /usr/share/arduino/hardware/arduino/bootloaders/caterina-sparkfun
cp -r ~/Downloads/SF32u4_boards-master/variants/* /usr/share/arduino/hardware/arduino/variants/
```

 1. replace caterina in boards.txt with caterina-sparkfun. This makes sure that the modified bootloader is used and not the original one.
 2. append the contents of the new boards.txt to the original boards.txt.
 3. copy the new caterina bootloader into the original bootloaders folder, but rename it to caterina-sparkfun.
 4. copy the new variants into the original variants folder

If we now go into a inotool project and call ino `list-models` we get this list:

```sh
             uno: [DEFAULT] Arduino Uno
       atmega328: Arduino Duemilanove w/ ATmega328
       diecimila: Arduino Diecimila or Duemilanove w/ ATmega168
         nano328: Arduino Nano w/ ATmega328
            nano: Arduino Nano w/ ATmega168
        mega2560: Arduino Mega 2560 or Mega ADK
            mega: Arduino Mega (ATmega1280)
        leonardo: Arduino Leonardo
         esplora: Arduino Esplora
           micro: Arduino Micro
         mini328: Arduino Mini w/ ATmega328
            mini: Arduino Mini w/ ATmega168
        ethernet: Arduino Ethernet
             fio: Arduino Fio
           bt328: Arduino BT w/ ATmega328
              bt: Arduino BT w/ ATmega168
      LilyPadUSB: LilyPad Arduino USB
      lilypad328: LilyPad Arduino w/ ATmega328
         lilypad: LilyPad Arduino w/ ATmega168
        pro5v328: Arduino Pro or Pro Mini (5V, 16 MHz) w/ ATmega328
           pro5v: Arduino Pro or Pro Mini (5V, 16 MHz) w/ ATmega168
          pro328: Arduino Pro or Pro Mini (3.3V, 8 MHz) w/ ATmega328
             pro: Arduino Pro or Pro Mini (3.3V, 8 MHz) w/ ATmega168
       atmega168: Arduino NG or older w/ ATmega168
         atmega8: Arduino NG or older w/ ATmega8
    robotControl: Arduino Robot Control
      robotMotor: Arduino Robot Motor
      promicro16: SparkFun Pro Micro 5V/16MHz
       promicro8: SparkFun Pro Micro 3.3V/8MHz
           fiov3: SparkFun Fio V3 3.3V/8MHz
       minibench: SparkFun Makey Makey
```

## inotool modifications

As you can see, at the end of the list are the new boards. If they do not appear, do a `ino clean` first.
Now ino compiles our source but fails to upload it :-(

So we have to do a little modification to ino itself, see the [Github diff](https://github.com/Bouni/ino/commit/cbe0d06256e104c5dfd0ec131bba75a58285807d#diff-5ed356d4542c24c6ce0440f8fe43d840) of the original repo and my fork.

I simply changed the behavior of inotool to do a softwre reset with the 1200 Baud connect/disconnect method to happen whenever the specified bootloader for a certain board model starts with "caterina" instead of is equal to "caterina".

## compile and upload code

Compilation works like a charm:

```sh
    bouni@fnord: ~/tmp/blinky$ ino build -m promicro16
    Searching for Board description file (boards.txt) ... /usr/share/arduino/hardware/arduino/boards.txt
    Searching for Arduino lib version file (version.txt) ... /usr/share/arduino/lib/version.txt
    Detecting Arduino software version ...  1.0.5 (1.0.5)
    Searching for Arduino core library ... /usr/share/arduino/hardware/arduino/cores/arduino
    Searching for Arduino standard libraries ... /usr/share/arduino/libraries
    Searching for Arduino variants directory ... /usr/share/arduino/hardware/arduino/variants
    Searching for make ... /usr/bin/make
    Searching for avr-gcc ... /usr/bin/avr-gcc
    Searching for avr-g++ ... /usr/bin/avr-g++
    Searching for avr-ar ... /usr/bin/avr-ar
    Searching for avr-objcopy ... /usr/bin/avr-objcopy
    src/sketch.ino
    Searching for Arduino lib version file (version.txt) ... /usr/share/arduino/lib/version.txt
    Detecting Arduino software version ...  1.0.5 (1.0.5)
    Scanning dependencies of src
    Scanning dependencies of arduino
    src/sketch.cpp
    arduino/wiring_shift.c
    arduino/WInterrupts.c
    arduino/wiring_digital.c
    arduino/wiring_pulse.c
    arduino/wiring.c
    arduino/wiring_analog.c
    arduino/avr-libc/malloc.c
    arduino/avr-libc/realloc.c
    arduino/IPAddress.cpp
    arduino/Stream.cpp
    arduino/WString.cpp
    arduino/Print.cpp
    arduino/Tone.cpp
    arduino/USBCore.cpp
    arduino/HID.cpp
    arduino/main.cpp
    arduino/HardwareSerial.cpp
    arduino/WMath.cpp
    arduino/new.cpp
    arduino/CDC.cpp
    Linking libarduino.a
    Linking firmware.elf
    Converting to firmware.hex
```
 

And upload also:

```sh
    bouni@fnord: ~/tmp/blinky$ ino upload -m promicro16
    Guessing serial port ... /dev/ttyACM0

    Connecting to programmer: .
    Found programmer: Id = "CATERIN"; type = S
        Software Version = 1.0; No Hardware Version given.
    Programmer supports auto addr increment.
    Programmer supports buffered memory access with buffersize=128 bytes.

    Programmer supports the following devices:
        Device code: 0x44

    avrdude: AVR device initialized and ready to accept instructions

    Reading | ################################################## | 100% 0.00s

    avrdude: Device signature = 0x1e9587
    avrdude: reading input file ".build/promicro16/firmware.hex"
    avrdude: writing flash (6076 bytes):

    Writing | ################################################## | 100% 0.48s

    avrdude: 6076 bytes of flash written
    avrdude: verifying flash memory against .build/promicro16/firmware.hex:
    avrdude: load data flash data from input file .build/promicro16/firmware.hex:
    avrdude: input file .build/promicro16/firmware.hex contains 6076 bytes
    avrdude: reading on-chip flash data:

    Reading | ################################################## | 100% 0.05s

    avrdude: verifying ...
    avrdude: 6076 bytes of flash verified

    avrdude: safemode: Fuses OK (H:CB, E:D8, L:FF)

    avrdude done.  Thank you.
```

 
