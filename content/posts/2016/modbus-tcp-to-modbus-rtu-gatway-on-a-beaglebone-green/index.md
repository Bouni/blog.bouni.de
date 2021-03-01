---
layout: post
title: Modbus TCP to Modbus RTU gateway on a BeagleBone Green
date: 2016-12-10 20:22:30 +0100
comments: true
tags: [ Modbus, Gateway, TCP, RTU, BeaglBone, ]
tags: [ Modbus, Gateway, TCP, RTU, BeaglBone, ]
---

In my last [post](/2016/rs485-on-a-beaglebonegreen-waveshare-cape.html) I've explained how I got RS485 working on a BeagleBone Green.
Since then I managed to build a Modbus TCP to Modbus RTU gateway based on that and want to show how it works.

<!--more-->

First of all I try to expalin the basics because I found it rather hard to understand the other explantations out there, because they often lack actual examples with real data.

Modbus TCP and Modbus RTU are pretty much the same, except that a Modbus RTU frame has two CRC bytes at the end which Modbus TCP does not have (CRC is covered by TCP), but has a header that comes before the actual Modbus data.

Here is an example of a ModbusTCP frame:

`0x00 0x01 0x00 0x00 0x00 0x06 0x01 0x04 0x00 0x0A 0x00 0x01`

- `0x00 0x01` is the transaction number, it gets incremented for each frame
- `0x00 0x00` is the protocol identifier, it is always zero
- `0x00 0x06` is the number of bytes that follow after this one
- `0x01` is the unit identifier
- `0x04` is the function code, read input registers in this case
- `0x00 0x0A` is the start address, here register number 10
- `0x00 0x01` is the number of regsiters to read, here just one register

A Modbus RTU request for the exact same regsiters would look like this:

`0x01 0x04 0x00 0x0A 0x00 0x01 0x11 0xC8`

- `0x01` is the unit identifier
- `0x04` is the function code, read input registers in this case
- `0x00 0x0A` is the start address, here register number 10
- `0x00 0x01` is the number of regsiters to read, here just one register
- `0x11 0xC8` is the CRC16 checksum

So you can see that the bytes that we need to send to the RTU device are just a subset of the TCP frame plus we need to calculate a CRC16 checksum for these bytes.

The answer from the Modbus RTU device looks like this:

`0x01 0x04 0x02 0x00 0x28 0xB9 0x2E`

- `0x01` is the unit identifier
- `0x04` is the function code, read input registers in this case
- `0x02` is the number of data bytes to follow
- `0x00 0x28` is the actual data, 40 in this case (which coud be a sensor value)
- `0xB9 0x2E` is the checksum for this frame

To send a valid response back to the Modbus TCP Master that sent the initial request, we need to merge parts of the request with the RTU reply:

`0x00 0x01 0x00 0x00 0x00 0x04 0x01 0x04 0x02 0x00 0x28`

- `0x00 0x01` is the transaction number, it gets incremented for each frame
- `0x00 0x00` is the protocol identifier, it is always zero
- `0x00 0x04` is the number of bytes that follow after the unit identifier
- `0x01` is the unit identifier
- `0x04` is the function code
- `0x02` is the number of data bytes
- `0x00 0x28` is the actual data

My code can be found on [GitHub](https://github.com/Bouni/ModBusGateway)

If you find a bug or extend the code, please submit a pull request!





