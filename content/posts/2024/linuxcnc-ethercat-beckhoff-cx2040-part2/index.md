---
title: "LinuxCNC with EtherCat on a Beckhoff CX2040 [Part 2]"
date: 2024-09-05
tags: [LinuxCNC, linux, cnc, ethercat, beckhoff, cx2040, ccat]
---

In my [previous post](https://blog.bouni.de/posts/2023/linuxcnc-ethercat-beckhoff-cx2040/) on this topic I successfully managed to get LinuxCNC with EtherCat running on a Beckhoff CX2040.
That was over a year ago and since then I didn't have the time to dig deeper into the matter.
Until now, and a lot has changed in the meantime ...

<!--more-->

Last weekend I attended [DDos](https://ddos.odenwilusenz.ch/Hauptseite) at the [Odenwilusenz](https://odenwilusenz.ch/) Hackerspace in Beringen, Switzerland.
In the days before that, I planned to reactivate my setup and bring it along.

When I started the system, everything worked exactly like when I left it.
So I added a [Beckhoff EL1804](https://www.beckhoff.com/en-en/products/i-o/ethercat-terminals/el1xxx-digital-input/el1804.html) and as [Beckhoff EL2828](https://www.beckhoff.com/en-en/products/i-o/ethercat-terminals/el2xxx-digital-output/el2828.html) just to find out that the used version of the linuxcnc-ethercat does not sopport these two types.

An attempt to update to the latest version failed. So I looked at the LinuxCNC website to check out what's the latest version.
I ran 2.8.4 and the latest release was 2.9.3 which, to my surprise now comes from a debian repo along withthe latest version of linuxcn-ethercat.
And that also includes the CCAT driver which I had to build from source the last time.

So I decided to start all over and install the 2.9.3 ISO on a new CF card.

## Installation

The installation was straight forward as expected.
After booting the system for the first time, I got an error at the attempt to do a system update.

The reason is a missing or wrong GPG key in the sources.list

However, the recommended solution from the LinuxCNC forum didn't work for me, but I was able to use the instructions from the [Etherlab website](https://etherlab.org/en_GB/getting-started)

```sh
export KEYRING=/usr/share/keyrings/etherlab.gpg
curl -fsSL https://download.opensuse.org/repositories/science:/EtherLab/Debian_12/Release.key | gpg --dearmor | sudo tee "$KEYRING" >/dev/null
echo "deb [signed-by=$KEYRING] https://download.opensuse.org/repositories/science:/EtherLab/Debian_12/ ./" | sudo tee /etc/apt/sources.list.d/etherlab.list > /dev/null
```

This adds a new file called `etherlab.list` to `/etc/apt/sources.list.d/`, which requires that the original .list file is deleted.

After that I was able ti update and upgrade with 

```sh
sudo apt update
sudo apt upgrade
```

I installed LinuxCNC and linuxcnc-ethercat from the repo

```sh
sudo apt install ethercat-master libethercat-dev linuxcnc-ethercat
```

Then I enabled and started the EtherCat Master

```sh
sudo systemctl enable ethercat.service
sudo systemctl start ethercat.service
```

That failed because I was missing configuration in `/etc/ethercat.conf`.
The config file requires two settings `MASTER0_DEVICE` and `DEVICE_MODULES`.
To get the MAC of `eth0` which is the CCAT simply run `ip a` and read the MAC address from there.

I set `MASTER0_DEVICE="00:01:05:1e:6b:8e"` and `DEVICE_MODULES="ccat"`

Luckily the Etherlab master comes with prebuild ccat drivers.

After a reboot there was still no `/dev/EtherCAT` device :thinking:

So I ran `sudo systemctl restart ethercat.service` and that worked.

The LinuxCNC forum recommends to add a udev rule for correct permissions, so I added `/etc/udev/rules.d/99-ethercat.rules` with this content:

```sh
KERNEL=="EtherCAT[0-9]", MODE="0777"
```

After another reboot `/dev/EtherCAT` was gone again. `sudo systemctl restart ethercat.service` brought it back.

At the time of writing this I was not able to figure out whats causing this and how to fix it other than running a `sudo systemctl restart ethercat.service` after every system start.

## Testing EtherCat

I quickly checked if the master was running

```sh
ethercat master

Master0
  Phase: Idle
  Active: no
  Slaves: 3
  Ethernet devices:
    Main: 00:01:05:1e:6b:8e (attached)
      Link: UP
      Tx frames:   18587429
      Tx bytes:    1299386046
      Rx frames:   18587422
      Rx bytes:    1596784378
      Tx errors:   0
      Tx frame rate [1/s]:    122    121    121
      Tx rate [KByte/s]:      7.1    7.1    7.1
      Rx frame rate [1/s]:    122    121    121
      Rx rate [KByte/s]:      9.1    9.0    9.0
    Common:
      Tx frames:   18587429
      Tx bytes:    1299386046
      Rx frames:   18587422
      Rx bytes:    1596784378
      Lost frames: 7
      Tx frame rate [1/s]:    122    121    121
      Tx rate [KByte/s]:      7.1    7.1    7.1
      Rx frame rate [1/s]:    122    121    121
      Rx rate [KByte/s]:      9.1    9.0    9.0
      Loss rate [1/s]:          0      0      0
      Frame loss [%]:         0.0    0.0    0.0
  Distributed clocks:
    Reference clock:   Slave 0
    DC reference time: 0
    Application time:  0
                       2000-01-01 00:00:00.000000000
```

Nice :sunglasses:

## Creating a test config

I started LinuxCNC with the sim.axis config to have a template to start with.

In the `[HAL]` section of `axis.ini` I added a `HALFILE = ethercat.hal`.

Next I created two new files in the same folder, `ethercat.hal` and `ethercat-config.xml`.

The first looks like this:

```
loadusr -W lcec_conf ethercat-conf.xml
loadrt lcec
addf lcec.read-all              servo-thread
addf lcec.write-all             servo-thread
```

The later like this

```xml
<masters>
    <master idx="0" appTimePeriod="1000000" refClockSyncCycles="-1" name="master0">
        <slave idx="0" type="EL1018" name="DI1"/>
        <slave idx="1" type="EL2008" name="DO1"/>
    </master>
</masters>
```

I switched my setup back to the old EL1018 and EL2008 terminals because I knew they were working in the old setup.

After starting LinuxCNC with this config I was able to see inputs in the Show HAL configuration menu under `Pins -> lcec -> Master0`.

Overall a very easy setup compared to what I had to do last time. 

Nice work from the people at [LinuxCNC](http://linuxcnc.org/), [Etherlab/IgH](https://etherlab.org/en_GB) and [linuxcnc-ethercat](https://github.com/linuxcnc-ethercat/linuxcnc-ethercat)
