---
title: "Telegraf with Phoenix Contact Empro MA370 & CS Instruments VA525"
date: 2021-05-27T12:41:08+02:00
---

I work on a small side project where I want to read data from an Phoenix Contact [EMpro MA370](https://www.phoenixcontact.com/online/portal/gb/?uri=pxc-oc-itemdetail:pid=2907983&library=gben&pcck=P-14-04-01-01&tab=1&selectedCategory=ALL) Multi-functional energy measuring and 
a CS Instruments [VA525](https://www.cs-instruments.com/products/d/flow-meter/va-525-compact-inline-flow-sensor-for-compressed-air-and-gas) air flow sensor, 
both offering a Modbus TCP interface.

<!--more-->

The goal is to store the measurement data in a [InfluxDB](https://www.influxdata.com/products/influxdb-overview/) database and visualize it using [Grafana](https://grafana.com/).

## EMpro MA370

To read the data from the EMpro I want to utilize [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/) and its [Modbus input plugin](https://github.com/influxdata/telegraf/blob/release-1.18/plugins/inputs/modbus/README.md).

The specification of all the registers can be downloaded from the Phoenix Contact website (see the Various section unter Downloads of the product page linked before)
The manual states "The specification only defines that the register has to be represented as “big endian”. This means that the high byte of a register is sent first, followed by the low byte."

So I tried configuring Telegraf to read the data as described in the Telegraf config file:

```
[[inputs.modbus]]
  ## Connection Configuration
  ##
  ## The plugin supports connections to PLCs via MODBUS/TCP or
  ## via serial line communication in binary (RTU) or readable (ASCII) encoding
  ##
  ## Device name
  name = "EMpro"

  ## Slave ID - addresses a MODBUS device on the bus
  ## Range: 0 - 255 [0 = broadcast; 248 - 255 = reserved]
  slave_id = 1

  ## Timeout for each request
  timeout = "1s"

  # TCP - connect via Modbus/TCP
  controller = "tcp://192.168.100.2:502"

  ## Analog Variables, Input Registers and Holding Registers
  ## measurement - the (optional) measurement name, defaults to "modbus"
  ## name        - the variable name
  ## byte_order  - the ordering of bytes
  ##  |---AB, ABCD   - Big Endian
  ##  |---BA, DCBA   - Little Endian
  ##  |---BADC       - Mid-Big Endian
  ##  |---CDAB       - Mid-Little Endian
  ## data_type  - INT16, UINT16, INT32, UINT32, INT64, UINT64,
  ##              FLOAT32-IEEE, FLOAT64-IEEE (the IEEE 754 binary representation)
  ##              FLOAT32, FIXED, UFIXED (fixed-point representation on input)
  ## scale      - the final numeric variable representation
  ## address    - variable address

  holding_registers = [
    { name = "u12", byte_order = "ABCD", data_type = "FLOAT32-IEEE", scale=1.0, address = [32768, 32769]}
  ]
```

As you can see I set byte_order to Big Endian (ABCD) according to the Phoenix manual. But that gave me just garbage values :thinking:
So I decided to try different Endianess variants just to realize that they gave me other variants of :shit:

I even tried to use [modbus-cli](https://github.com/favalex/modbus-cli) to read the values by hand and see what I need to do in order to get the right values out of that little sucker.

No success either, same shit different tool :sob:

After having lunch I finally realized that maybe the byteorder of the two bytes I read is not correct and the endianess only affects the order of the bits in one byte.

So I tried swapping the order of the addresses I defined in the telegraf.conf:

```
  holding_registers = [
    { name = "u12", byte_order = "ABCD", data_type = "FLOAT32-IEEE", scale=1.0, address = [32769, 32768]}
  ]
```

Et voila! That did the trick :partying_face:

## VA525

So I went on with the VA525 just to realize that this little beast has its own Modbus quirks :roll_eyes:

The documentation can be found on the manufacturers [website](https://www.cs-instruments.com/fileadmin/cs-data/Bedienungsanleitungen/Instruction%20manuals_EN_new/Instruction_manual_VA525_EN.pdf) (page 28). 

Again I went straight for this config:

```
# # Retrieve data from MODBUS slave devices
[[inputs.modbus]]
  ## Connection Configuration
  ##
  ## The plugin supports connections to PLCs via MODBUS/TCP or
  ## via serial line communication in binary (RTU) or readable (ASCII) encoding
  ##
  ## Device name
  name = "VA525"

  ## Slave ID - addresses a MODBUS device on the bus
  ## Range: 0 - 255 [0 = broadcast; 248 - 255 = reserved]
  slave_id = 1

  ## Timeout for each request
  timeout = "1s"

  # TCP - connect via Modbus/TCP
  controller = "tcp://192.168.100.3:502"

  ## Analog Variables, Input Registers and Holding Registers
  ## measurement - the (optional) measurement name, defaults to "modbus"
  ## name        - the variable name
  ## byte_order  - the ordering of bytes
  ##  |---AB, ABCD   - Big Endian
  ##  |---BA, DCBA   - Little Endian
  ##  |---BADC       - Mid-Big Endian
  ##  |---CDAB       - Mid-Little Endian
  ## data_type  - INT16, UINT16, INT32, UINT32, INT64, UINT64,
  ##              FLOAT32-IEEE, FLOAT64-IEEE (the IEEE 754 binary representation)
  ##              FLOAT32, FIXED, UFIXED (fixed-point representation on input)
  ## scale      - the final numeric variable representation
  ## address    - variable address

  holding_registers = [
    { name = "flow_m3_h", byte_order = "ABCD", data_type = "FLOAT32-IEEE", scale=1.0, address = [1100,1101]}
  ]
```

This time my connection to the device giot refused :raised_eyebrow:

The documentation says :
- Modbus register: 1101
- Modbus Address: 1100
- No.of Bytes: 4
- Data Type: Float
- Description: Flow in m³/h
- Read/Write: R

The word order can be configured for a VA525 and its set to ABCD by default, so I stuck with that.
Somewhere on the internet I read that a modbus register is 16bits in size, so I guessed that by stating 4 bytes, that means two registers.

After some experimentation I relaized that I just have to skip a register address:

```
  holding_registers = [
    { name = "flow_m3_h", byte_order = "ABCD", data_type = "FLOAT32-IEEE", scale=1.0, address = [1100,1102]}
  ]
```

:boom: Here we go, the VA525 is also working like a charm!

I hope that documenting this maybe helps other people searching for a solution getting a MA370 and/or VA525 working.
