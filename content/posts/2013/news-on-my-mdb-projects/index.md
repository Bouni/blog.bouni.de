---
layout: post
title: News on my MDB projects
date: 2013-11-10 12:10:00
comments: true
tags: [ mdb, vending-machine]
---

Because i've got a lot of emails during the last year with several questions about my MDB projects, i try to answer them here.

<!--more-->

## The MateDealer, what is it exactly?

I've called my main MDB project [MateDealer](https://reaktor23.org/de/projects/mate_dealer) because my vending machine primary vends [Club Mate](http://clubmate.de).
It is a (incomplete) implemetation of a **Cashless Device**, which is a slave on the MDB bus. The master on the MDB bus is always a **Vending Machine Controller**.

## Can i connect a Coin Acceptor to the MateDealer?
No, because the MateDealer as well as the Coin Acceptor are both MDB slaves.


## What does the MDB bus structure looks like?
The VMC frequently polls all slaves on the bus and the slaves answer with a specified answer depending if the slave has something to tell or just confirm that its alive.
No slave sends anything on the bus without geting asked to do so by the VMC. 

## What does the MDB setup of a vending machine typically looks like?
Every Vending Machine has exactly one VMC, furter more it hat one or more MDB slaves, the most common are Coin Acceptors and Bill validators.
The VMC controls all the hardware, the motors dispense the products, the push buttons for the product selection, the display and so on.
A Coin Acceptor for example just have the job of verifying the coins and tell the VMC what types/values of coins have been inserted.

## What Arduino do i need to upload the MateDealer software?
I've just tested it on a Arduino Mega 2560, because this is the only Arduino (as far as i know) that provides more that 1 Hardware UART.

## How can i compile and upload the software to the Arduino?
I assume that you're using a linux OS. (sorry Windows users ;-) )

```sh
git clone https://github.com/Bouni/MateDealer
cd MateDealer
make all
make program
```

You need some tools to do theese steps

- git
- avr-libc
- gcc-avr
- avrdude

## Do i need the Arduino bootloader?
You don't need to change anything on the Arduino, just use it as you unboxed it.

## Other questions?
Feel free to post a comment, or send me an email.






