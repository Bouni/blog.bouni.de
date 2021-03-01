---
layout: post
title: SICK FlexiSoft, Modbus/TCP and python
date: 2014-11-09 11:54:07 +0100
comments: true
tags: [ SICK, FlexiSoft, Python, Modbus ]
tags: [ SICK, FlexiSoft, Python, Modbus ]
---

Last week i tried to read and write data to and from a [SICK FlexiSoft Safty controller](http://www.sick.com/group/EN/home/products/product_portfolio/safe_control_solutions/Pages/safety_controller_flexi_soft.aspx) which has a Modbus/TCP gateway.

Because i had a lot of trouble to get that up and running i decided to write a few lines about i managed to solve my problems.

<!--more-->

I connected the safety controller to my computer using a normal 100Mbit switch. But at first i did the mistake to use port 9100 instead of port 502 which is the standard port for Modbus/TCP. I did that mistake because on the SICK FlexiSoft Designer configuration the port 9100 is shown but no word about port 502.

I decided not to use a ready to use Modbus lib like pyModbus because i wanted to learn something.

So here is my code:

```python
#!/usr/bin/env python
#-*- coding: utf-8 -*-

#DEBUG = True
DEBUG = False

import socket
from struct import pack

class Modbus:
    
    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.socket = None

    def connect(self):
        if self.socket is None:
            try:
                self.socket = socket.create_connection((self.host,self.port))
            except socket.error as msg:
                print("Connection to {0}{1} failed:\n{2}".format(self.host, self.port, msg))

    def disconnect(self):
        if self.socket is not None:
            self.socket.close()
            self.socket = None

    def read_holding_registers(self, reg_addr, reg_cnt, tid=0, uid=0):
        _tid        = pack('>H', tid)
        _pid        = pack('>H', 0)
        _uid        = pack('>B', uid)
        _fcode      = pack('>B', 0x03)
        _reg_addr   = pack('>H', reg_addr-1)
        _reg_cnt    = pack('>H', reg_cnt)
        _length     = pack('>H', (len(_uid) + len(_fcode) + len(_reg_addr) + len(_reg_cnt)))
        msg = _tid + _pid + _length + _uid + _fcode + _reg_addr + _reg_cnt
    
        if DEBUG:
            print("sent:\n{0}".format([hex(b) for b in msg]))
    
        self.socket.send(msg)

        header = self.socket.recv(9)
        if DEBUG:
            print("recieved header:\n{0}".format([hex(b) for b in header]))
            print("receive {0} bytes of data".format(header[8]))

        _data = self.socket.recv(header[8])

        if DEBUG:
            print("recieved data:\n{0}".format([hex(b) for b in _data]))

        data = []
        # rotate big endian 16bit values
        for i in range(0,len(_data)-1,2):
            data.append(_data[i+1])
            data.append(_data[i])
        return data

    def write_multiple_registers(self, reg_addr, data, tid=0, uid=0):
        _tid        = pack('>H', tid)
        _pid        = pack('>H', 0)
        _uid        = pack('>B', uid)
        _fcode      = pack('>B', 0x10)
        _reg_addr   = pack('>H', reg_addr-1)
        _reg_cnt    = pack('>H', int(len(data)/2))
        _byte_cnt   = pack('>B', len(data))
        _data       = b''
        # rotate big endian 16bit values
        for i in range(0,len(data)-1,2):
            _data += pack('>B', data[i+1])
            _data += pack('>B', data[i])
        _length     = pack('>H', (len(_uid) + len(_fcode) + len(_reg_addr) + len(_reg_cnt) + len(_byte_cnt) + len(_data)))

        msg = _tid + _pid + _length + _uid + _fcode + _reg_addr + _reg_cnt + _byte_cnt + _data

        if DEBUG:
            print("sent:\n{0}".format([hex(b) for b in msg]))


        self.socket.send(msg)

        data = self.socket.recv(12)
        if DEBUG:
            print("recieved data:\n{0}".format([hex(b) for b in data]))
        return [hex(b) for b in data]
```

So far I've just implemented `read_holding_registers` and `write_multiple_registers` beacuse the gateway does only support these two commands and one other.
For me those two functions are everything i need, so i will not implement any other commands.

I use the code to read status information from the controller and write bits to trigger actions.
 
