---
layout: post
title: Reverse engineering a DQ860MA Part 1
date: 2015-03-06 20:43:15 +0100
comments: true
tags: [ stepper driver, DQ860MA, reverse engeneering]
---

As announced in one of my [last posts](/2015/taking-a-dq860ma-stepper-driver-apart.html) i will try to reverse engineer the DQ860MA.
Unfortunately i realized that the PCB is a 4 layer PCB, which makes it way harder to get a schematic.

So as a start i will get a list of all components.

<!--more-->

| part  | name          | type                          | footprint     | value         |
| --- | --- | --- | --- | --- |
| U1    | HCPL2531      | Dual High Speed Octocoupler   | DIL-8         |
| U2    | not populated |                               | SO-14         |
| U3    | 3843B         | PWM controller                | SO-8          |
| U4    | HC14AG        | Hex-Schmitt Trigger           | SO-14         |
| U5    | PC817         | Optocoupler                   | DIL-4         |
| U6    | LM317         | Voltage Regulator             | SO-8          |
| U7    | AMS1117       | LDO Voltage Regulator         | SOT-223       |
| U8    | IR2106S       | High and Low Side Driver      | SO-8          |
| U9    | IR2106S       | High and Low Side Driver      | SO-8          |
| U10   | IR2106S       | High and Low Side Driver      | SO-8          |
| U11   | IR2106S       | High and Low Side Driver      | SO-8          |
| U12   | LM339DG       | Quad Comperator               | SO-14         |
| U13   | LM339DG       | Quad Comperator               | SO-14         |
| U14   | MV358I        | Operational Amplifier         | SO-8          |
| U15   | ??            | Controller                    | TQFP-40       |
| Q1    | ??            | Transistor                    | SOT-23        |
| Q2    | IRFU220N      | Transistor                    | I-Pak         |
| Q3    | IRF540N       | Transistor                    | TO-220        |
| Q4    | IRF540N       | Transistor                    | TO-220        |
| Q5    | IRF540N       | Transistor                    | TO-220        |
| Q6    | IRF540N       | Transistor                    | TO-220        |
| Q7    | IRF540N       | Transistor                    | TO-220        |
| Q8    | IRF540N       | Transistor                    | TO-220        |
| Q9    | IRF540N       | Transistor                    | TO-220        |
| Q10   | IRF540N       | Transistor                    | TO-220        |
| D1    | ??            | Diode                         | MiniMelf      |
| D2    | ??            | Diode                         | MiniMelf      |
| D3    | ??            | Diode                         | MiniMelf      |
| D4    | ??            | Diode                         | MiniMelf      |
| D5    | ES1J          | Fast Diode                    | SMA           |
| D6    | ES1J          | Fast Diode                    | SMA           |
| D7    | ES1J          | Fast Diode                    | SMA           |
| D8    | ??            | Diode                         | MiniMelf      |
| D9    | ??            | Diode                         | MiniMelf      |
| D10   | ??            | Diode                         | MiniMelf      |
| D11   | ??            | Diode                         | MiniMelf      |
| D12   | ??            | Diode                         | MiniMelf      |
| D13   | ??            | Diode                         | MiniMelf      |
| D14   | ??            | Diode                         | MiniMelf      |
| D15   | ??            | Diode                         | MiniMelf      |
| D16   | ??            | Diode                         | MiniMelf      |
| D17   | ??            | Diode                         | MiniMelf      |
| D18   | ??            | Diode                         | MiniMelf      |
| D19   | ??            | Diode                         | MiniMelf      |
| D20   | UF2G          | Fast Diode                    | SMB           |
| D21   | UF2G          | Fast Diode                    | SMB           |
| D22   | UF2G          | Fast Diode                    | SMB           |
| D23   | UF2G          | Fast Diode                    | SMB           |
| D24   | ??            | Dual LED                      | 3mm           |
| D25   | ??            | Fast Diode                    | SMB           |
| V1    | ??            | ??                            | SMA           |
| C1    | ??            | Capacitor                     | 0805          |
| C2    | ??            | Capacitor                     | 0805          |
| C3    | ??            | Capacitor                     | 0805          |
| C4    | ??            | Capacitor                     | 0805          |
| C5    | ??            | Capacitor                     | 0805          |
| C6    | ??            | Capacitor                     | 0805          |
| C7    | ??            | Capacitor                     | 0805          |
| C8    | ??            | Capacitor                     | 0805          |
| C9    | ??            | Capacitor                     | 0805          |
| C10   | ??            | Capacitor                     | 0805          |
| C11   | ??            | Capacitor                     | 0805          |
| C12   | ??            | Capacitor                     | 0805          |
| C13   | ??            | Capacitor                     | 0805          |
| C14   | ??            | Capacitor                     | 0805          |
| C15   | ??            | Capacitor                     | 0805          |
| C16   | ??            | Capacitor                     | 0805          |
| C17   | ??            | Capacitor                     | 0805          |
| C18   | ??            | Capacitor                     | 0805          |
| C19   | ??            | Capacitor                     | 0805          |
| C20   | ??            | Capacitor                     | 0805          |
| C21   | ??            | Capacitor                     | 0805          |
| C22   | ??            | Capacitor                     | 0805          |
| C23   | ??            | Capacitor                     | 0805          |
| C24   | ??            | Capacitor                     | 0805          |
| C25   | ??            | Electrolythic Capacitor       | 6mm           | 25V, 100uF
| C26   | ??            | Electrolythic Capacitor       | 6mm           | 25V, 100uF
| C27   | ??            | Electrolythic Capacitor       | 6mm           | 25V, 100uF
| C28   | ??            | Electrolythic Capacitor       | 6mm           | 25V, 100uF
| C29   | ??            | Electrolythic Capacitor       | 6mm           | 25V, 100uF
| C30   | ??            | Capacitor                     | 0805          |
| C31   | ??            | Capacitor                     | 0805          |
| C32   | ??            | Capacitor                     | 0805          |
| C33   | ??            | Capacitor                     | 0805          |
| C34   | --            | --                            | --            |
| C35   | ??            | Electrolythic Capacitor       | 20mm          | 100V, 470uF 
| C36   | ??            | Capacitor                     | 1812          |
| C37   | ??            | Capacitor                     | 0805          |
| C38   | ??            | Capacitor                     | 0805          |
| C39   | ??            | Capacitor                     | 0805          |
| C40   | ??            | Capacitor                     | 1206          |
| C41   | ??            | Capacitor                     | 1206          |
| C42   | ??            | Capacitor                     | 1206          |
| C43   | ??            | Capacitor                     | 0805          |
| C44   | ??            | Capacitor                     | 1206          |
| C45   | ??            | Capacitor                     | 0805          |
| C46   | ??            | Capacitor                     | 0805          |
| C47   | not populated | Capacitor                     | 0805          |
| C48   | not populated | Capacitor                     | 0805          |
| C49   | ??            | Capacitor                     | 0805          |
| C50   | ??            | Capacitor                     | 0805          |
| C51   | ??            | Capacitor                     | 0805          |
| C52   | not populated | Capacitor                     | 1812          |
| R1    | 3001          | Resistor                      | 0805          | 3k 
| R2    | 3001          | Resistor                      | 0805          | 3k 
| R3    | 2200          | Resistor                      | 0805          | 220R 
| R4    | 2200          | Resistor                      | 0805          | 220R 
| R5    | 2200          | Resistor                      | 0805          | 220R 
| R6    | 2001          | Resistor                      | 0805          | 2k 
| R7    | 2001          | Resistor                      | 0805          | 2k 
| R8    | 2001          | Resistor                      | 0805          | 2k 
| R9    | 2001          | Resistor                      | 0805          | 2k 
| R10   | 103           | Resistor                      | 1206          | 10k 
| R11   | 1002          | Resistor                      | 0805          | 10k 
| R12   | 1002          | Resistor                      | 0805          | 10k
| R13   | 103           | Resistor                      | 1206          | 10k 
| R14   | 1002          | Resistor                      | 0805          | 10k
| R15   | 1002          | Resistor                      | 0805          | 10k
| R16   | 1502          | Resistor                      | 0805          | 15k
| R17   | 1502          | Resistor                      | 0805          | 15k
| R18   | 1003          | Resistor                      | 0805          | 100k
| R19   | 1003          | Resistor                      | 0805          | 100k
| R20   | 1003          | Resistor                      | 0805          | 100k
| R21   | 47R0          | Resistor                      | 0805          | 47R
| R22   | 3901          | Resistor                      | 0805          | 3k9
| R23   | 3901          | Resistor                      | 0805          | 3k9
| R24   | 1001          | Resistor                      | 0805          | 1k
| R25   | 1001          | Resistor                      | 0805          | 1k
| R26   | 1001          | Resistor                      | 0805          | 1k
| R27   | --            | --                            | --            | 
| R28   | 5101          | Resistor                      | 0805          | 5k1
| R29   | 5101          | Resistor                      | 0805          | 5k1
| R30   | 5101          | Resistor                      | 0805          | 5k1
| R31   | 5101          | Resistor                      | 0805          | 5k1
| R32   | 5101          | Resistor                      | 0805          | 5k1
| R33   | 5101          | Resistor                      | 0805          | 5k1
| R34   | 1003          | Resistor                      | 0805          | 100k
| R35   | 5101          | Resistor                      | 0805          | 5k1
| R36   | 5101          | Resistor                      | 0805          | 5k1
| R37   | 5101          | Resistor                      | 0805          | 5k1
| R38   | 5101          | Resistor                      | 0805          | 5k1
| R39   | 3600          | Resistor                      | 0805          | 360R
| R40   | 88R7          | Resistor                      | 0805          | 88.7R
| R41   | R510          | Resistor                      | 2010          | 0.51R
| R42   | 1000          | Resistor                      | 0805          | 100R
| R43   | 1000          | Resistor                      | 0805          | 100R
| R44   | 1000          | Resistor                      | 0805          | 100R
| R45   | 1000          | Resistor                      | 0805          | 100R
| R46   | 1000          | Resistor                      | 0805          | 100R
| R47   | 1000          | Resistor                      | 0805          | 100R
| R48   | 1000          | Resistor                      | 0805          | 100R
| R49   | 1000          | Resistor                      | 0805          | 100R
| R50   | 2002          | Resistor                      | 0805          | 20k
| R51   | 2002          | Resistor                      | 0805          | 20k
| R52   | 2002          | Resistor                      | 0805          | 20k
| R53   | 2002          | Resistor                      | 0805          | 20k
| R54   | 2002          | Resistor                      | 0805          | 20k
| R55   | 2002          | Resistor                      | 0805          | 20k
| R56   | 2002          | Resistor                      | 0805          | 20k
| R57   | 2002          | Resistor                      | 0805          | 20k
| R58   |               | Resistor                      | Axial         | 0.22R, 1%
| R59   |               | Resistor                      | Axial         | 0.22R, 1%
| R60   |               | Resistor                      | Axial         | 0.22R, 1%
| R61   |               | Resistor                      | Axial         | 0.22R, 1%
| R62   | 100           | Resistor                      | 0805          | 10R
| R63   | 100           | Resistor                      | 0805          | 10R
| R64   | 22R0          | Resistor                      | 0805          | 22R
| R65   | 44R2          | Resistor                      | 0805          | 44.2R
| R66   | 91R0          | Resistor                      | 0805          | 91R
| R67   | 5101          | Resistor                      | 0805          | 5.1k
| R68   | 5101          | Resistor                      | 0805          | 5.1k
| R69   | not populated | Resistor                      | Axial         | 
| R70   | 6201          | Resistor                      | 0805          | 6.2k
| R71   | 4702          | Resistor                      | 0805          | 47k
| R72   | 3902          | Resistor                      | 0805          | 39k
| R73   | 3901          | Resistor                      | 0805          | 3k9
| R74   | 1001          | Resistor                      | 0805          | 1k
| FU1   | 10A           | Fuse                          | Axial         | F10A
| TN1   |               | Transformer                   | ??            |

A long list for such a small device, can't even imagine to do that for lets say a pc motherboard :)
Unfortunately there are a few parts that i wasn't able to find a datasheet or they are not labled (like the controller).

Maybe things getting clearer when i start to reverse the wires in the circuit. To do that i will desolder all the parts and then remove the solder mask.
There is a great talk by Joe Grand on [Youtube](http://www.youtube.com/watch?v=O8FQZIPkgZM) that he held on Defcon 22 about exact this topic!

Hopefully i will get to that point soon!

