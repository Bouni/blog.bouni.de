---
title: "Get OMRON 1S Servo drives working with Linuxcnc EtherCat"
date: 2024-09-20
tags: [LinuxCNC, linux, cnc, ethercat, beckhoff, cx2040, ccat, OMRON, 1S]
---

I have access to a lot of EtherCat components, among them the brand new [OMRON 1S](https://industrial.omron.co.uk/en/products/1s-servo-drive) series servo drives.
Obviously I wanted to get them working in LinuxCNC but there were no drivers for them.

There were [drivers](https://github.com/linuxcnc-ethercat/linuxcnc-ethercat/blob/master/src/devices/lcec_omrg5.c) for the [OMRON G5](https://industrial.omron.co.uk/en/products/accurax-g5-drives) series drives however. So I compared the PDOs used in that driver with the PDOs of the 1S series.

Turns out they are identical :nerd_face:

I cloned the git repo of [linuxcnc-ethercat](https://github.com/linuxcnc-ethercat/linuxcnc-ethercat) and began to tinker around.

I created a copy of the driver, named it `omr1s.c`. Then I replaced all the `omrg5` stuff with `omr1s` and set the correct encoder resolution at the top of the file.
Also all the [drive models and their PID](https://github.com/linuxcnc-ethercat/linuxcnc-ethercat/blob/f6c6af992dbc892b4371656654887a6ce0edd10e/src/devices/lcec_omr1s.c#L29-L53) had to be correct, but that was an easy task with the help of the [esi-data](https://linuxcnc-ethercat.github.io/esi-data/devices/#OMRON) website, also created by [@scottlaird](https://github.com/scottlaird) who is the driving force behind linuxcnc-ethercat.

A simple `sudo make install` was enough to have the modified version in place.

I also had to create a correct `ethercat-conf.xml`:

```xml
<masters>
    <master idx="0" appTimePeriod="1000000" refClockSyncCycles="-1" name="master0">
        <slave idx="0" type="EK1110" />
        <slave idx="1" type="R88D-1SN01H-ECT" name="x-servo">
            <dcConf assignActivate="300" sync0Cycle="*1" sync0Shift="0"/>
            <watchdog divider="2498" intervals="1000"/>
          </slave>
        <slave idx="2" type="R88D-1SN01H-ECT" name="y-servo">
            <dcConf assignActivate="300" sync0Cycle="*1" sync0Shift="0"/>
            <watchdog divider="2498" intervals="1000"/>
           </slave>
        <slave idx="3" type="R88D-1SN01H-ECT" name="z-servo">
            <dcConf assignActivate="300" sync0Cycle="*1" sync0Shift="0"/>
            <watchdog divider="2498" intervals="1000"/>
           </slave>
      </master>
  </masters>
```

Along with a ethercat.hal file

```hal
# vi: ft=linuxcnc-hal

loadrt [KINS]KINEMATICS
loadrt [EMCMOT]EMCMOT servo_period_nsec=[EMCMOT]SERVO_PERIOD num_joints=[KINS]JOINTS
loadusr -W lcec_conf ethercat-conf.xml
loadrt lcec

addf lcec.read-all              servo-thread
addf motion-command-handler     servo-thread
addf motion-controller          servo-thread
addf lcec.write-all             servo-thread

net emc-enable => iocontrol.0.emc-enable-in
sets emc-enable 1

##*******************
##  AXIS X
##*******************

net x-enable    <= joint.0.amp-enable-out => lcec.master0.x-servo.enable
net x-amp-fault => joint.0.amp-fault-in   <= lcec.master0.x-servo.fault
net x-pos-cmd   <= joint.0.motor-pos-cmd  => lcec.master0.x-servo.pos-cmd
net x-pos-fb    => joint.0.motor-pos-fb   <= lcec.master0.x-servo.pos-fb

##*******************
##  AXIS Y
##*******************

net y-enable    <= joint.1.amp-enable-out => lcec.master0.y-servo.enable
net y-amp-fault => joint.1.amp-fault-in   <= lcec.master0.y-servo.fault
net y-pos-cmd   <= joint.1.motor-pos-cmd  => lcec.master0.y-servo.pos-cmd
net y-pos-fb    => joint.1.motor-pos-fb   <= lcec.master0.y-servo.pos-fb

##*******************
##  AXIS Z
##*******************

net z-enable    <= joint.2.amp-enable-out => lcec.master0.z-servo.enable
net z-amp-fault => joint.2.amp-fault-in   <= lcec.master0.z-servo.fault
net z-pos-cmd   <= joint.2.motor-pos-cmd  => lcec.master0.z-servo.pos-cmd
net z-pos-fb    => joint.2.motor-pos-fb   <= lcec.master0.z-servo.pos-fb
```

Finally the .ini file

```ini
[EMC]
VERSION = 1.0
MACHINE = Omron 1S test setup
DEBUG = 0

[DISPLAY]
DISPLAY = axis
CYCLE_TIME = 0.100
HELP_FILE = doc/help.txt
POSITION_OFFSET = RELATIVE
POSITION_FEEDBACK = ACTUAL
MAX_FEED_OVERRIDE = 1.2
MAX_SPINDLE_OVERRIDE = 1.0
MAX_LINEAR_VELOCITY = 25
DEFAULT_LINEAR_VELOCITY = 1
DEFAULT_SPINDLE_SPEED = 200
PROGRAM_PREFIX = /home/user/linuxcnc/nc_files

[FILTER]
PROGRAM_EXTENSION = .png,.gif,.jpg Grayscale Depth Image
PROGRAM_EXTENSION = .py Python Script

png = image-to-gcode
gif = image-to-gcode
jpg = image-to-gcode
py = python3

[TASK]
TASK = milltask
CYCLE_TIME = 0.001

[RS274NGC]
PARAMETER_FILE = sim.var

[EMCMOT]
EMCMOT = motmod
COMM_TIMEOUT = 1.0
BASE_PERIOD = 0
SERVO_PERIOD = 1000000

[EMCIO]
EMCIO = io
CYCLE_TIME = 0.100
TOOL_TABLE = sim.tbl
TOOL_CHANGE_POSITION = 0 0 0
TOOL_CHANGE_QUILL_UP = 1

[HAL]
HALFILE = ethercat.hal
HALUI = halui

[TRAJ]
COORDINATES = X Y Z
LINEAR_UNITS = mm
ANGULAR_UNITS = degree
MAX_LINEAR_VELOCITY = 4
POSITION_FILE = position.txt
NO_FORCE_HOMING = 1

[KINS]
KINEMATICS = trivkins
JOINTS = 3

[AXIS_X]
MAX_VELOCITY                = 1000
MAX_ACCELERATION            = 10000.0

[AXIS_Y]
MAX_VELOCITY                = 1000
MAX_ACCELERATION            = 10000.0

[AXIS_Z]
MAX_VELOCITY                = 1000
MAX_ACCELERATION            = 10000.0

[JOINT_0]
TYPE                        = LINEAR
MAX_VELOCITY                = 1000
MAX_ACCELERATION            = 10000.0
SCALE                       = 8388608
HOME_ABSOLUTE_ENCODER       = 2

[JOINT_1]
TYPE                        = LINEAR
MAX_VELOCITY                = 1000
MAX_ACCELERATION            = 10000.0
SCALE                       = 8388608
HOME_ABSOLUTE_ENCODER       = 2

[JOINT_2]
TYPE                        = LINEAR
MAX_VELOCITY                = 1000
MAX_ACCELERATION            = 10000.0
SCALE                       = 8388608
HOME_ABSOLUTE_ENCODER       = 2
```

This config, especially the .ini file is far from production ready, but it allows me to move all 3 axis.

I opened a pull-request and Scott quickly merged it. It is not yet release but will be in the next release.

I'm still in the process of experimenting with the absolute encoders that don't require a battery, which is a absolutely cool feature.

Here is a short video showing the drives in actions:

{{< video src="omron1s.mp4" controls="yes" >}}
