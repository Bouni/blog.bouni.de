---
layout: post
title: Sending and Receiving 9-bit Frames with Arduino
date: 2014-10-07 16:04:57 +0200
comments: true
categories: mdb, vending, Arduino, 9-bit, serial
---

My MateDealer project was entirely written in C because the Arduino IDE or more detailed the HardwareSerial part lacks the 9-bit support. It is easy to send a 8 bit data frame, but nearly impossible to do that with 9 bit frames. I worked for a while on implementing 9-bit support for the Arduino IDE and recently i finished my work!

<!--more-->

I've implemented 9-bit support for Arduino IDE 1.0.5 (unfortunately the 1.0.6 version came out just days later :-/ ) as well as 1.5.7. The later includes support for AVR based boards such as the Mega2560 as well as for ARM based boards like the Due.

The maintainers have not yet merged my pull request into the main project and I'm not sure if they ever will. Therefore i explain how you can use my code anyway :-)

## Setup 

These are the steps you need to do on a linux machine. I've not ried the proccess on Windows yet, but it should work as well.

1. Clone the repo from github:

```sh    
git clone https://github.com/Bouni/Arduino.git
cd Arduino
```

2. Select the IDE Version you want to use:


*For V1.0.5*

```sh
git checkout hardware-serial-9-bit
```

*For V1.5.7*

```sh
git checkout ide-1.5.x-hardware-serial-9-bit
```


3. Build the IDE

```sh
cd build
ant build
ant run
```

The IDE should come up and you can write your programs as normally.

## Example

The API works like you would expect:

```arduino
// Arduino 9-bit example

int answer;

setup() {
    Serial1.begin(9600, SERIAL_9N1);
}

loop() {
    // send a 9-bit frame on Serial1   
    Serial1.write(0x112);
    
    // wait for an answer
    while(!Serial1.available());

    // read the answer
    answer = Serial1.read();   

    // do what ever you want to do now ;-)

}
```

## Details

My implementation uses 2 bytes in the ringbuffer to store a single 9-bit frame. This has the downside for 9-bit users that the buffer is just half as big as normally, but has a great advantage for normal users. They don't get the overhead a 16-bit ringbuffer would have (which is absolutely useless for all other framesizes).

All functions should work as far as I've tested them. If you find a bug, please let me know!

