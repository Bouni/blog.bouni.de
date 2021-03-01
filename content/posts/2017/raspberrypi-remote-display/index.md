---
layout: post
title: Make RaspberryPi + Samsung TV a remote display 
date: 2017-12-17
tags: [ RaspberryPi, CEC, Framebuffer, Screen Resolution, VNC]
---

Our fire brigade wants to use a software that gives them details about their fire run. Unfortunately the softare is Windows only and runs on a vserver in the server room.
Two displays will be mounted in the hall where the fire trucks are as well as in the locker room so that they can see all the details while preparing.

My idea was to use a [VNC server](http://www.uvnc.com/downloads/ultravnc.html) on the Windows machine in the server room an a RaspberryPi as VNC client mounted to the backside of each TV.

Because I had some touble getting the system up and running, I decided to document the project here <s>(I maybe extend this article from time to time as the szstem evolves)</s>.

**Edit 2017-01-31:** Edited the article to make it a detailed HowTo 

# Windows server

We run a [Proxmox](https://www.proxmox.com/) setup that enables us to run several vservers on the physical server, this was straight forward, so I don't go into the details here. 
One vserver is a normal Windows 10 Pro installation that runs [Feuersoftware Einsatz Monitor](https://feuersoftware.com) and a [UltraVNC server](http://www.uvnc.com/downloads/ultravnc.html).

The Einsatz Monitor runs in fullscreen, that screen is set to a resolution of 1920x1080 and should be transmitted to the TV later on.

The only thing I've set in the VNC server is the two passwords for remote control and view only, but we will only use the view only mode later on.

# Hardware

We decided to use the following components: 

 - [RaspberryPi 3 Model B](https://www.raspberrypi.org/products/raspberry-pi-3-model-b/) 
 - [SanDisk 32GB Class 10 Micro SD Card](https://www.sandisk.de/home/memory-cards/microsd-cards/ultra-microsd-400gb)
 - [Sharkoon HDMI Kabel 1m 4K](https://de.sharkoon.com/media/35732/sharkoon_cable_catalog_v22.pdf)
 - [Samsung UE-40J5250](http://www.samsung.com/de/tvs/full-hd-j5250/UE40J5250SSXZG/)
 - [S-Impuls Wandhalterung](http://www.s-impuls.de/product/wandhalter/led-lcd-plasma-bildschirm-wandhalter/plasma-lcd-led-wandhalter-fuer-1337-displays-89739.html)
 - goobay Netzteil für Raspberry Pi 1-3 3,1A

# Raspberry PI setup

### 1. Raspbian

I've downloaded the latest Raspbian Stretch Lite from [raspberrypi.org](https://downloads.raspberrypi.org/raspbian_lite_latest) and unziped the image.
Then I installed [etcher](https://etcher.io/) and used that to flash the image onto the micro SD card.

### 2. Activate SSH 

To activate SSH, I simply created an empty file on the micro SD card named ssh. This will enable the SSH server when the Raspberry PI boots.

### 3. IP address of the PI

To get the IP address that your DHCP server assigned to the raspberry PI, you either log into the webinterface of your router and look it up there or you use for example nmap:

```sh
nmap -sn 192.168.178.0/24
...
Nmap scan report for 192.168.178.42
Host is up (0.0010s latency).
MAC Address: DE:AD:BE:EF:AC:AB (Raspberry Pi Foundation)
...
```

Note that you need to adjust the IP range to what your router is configured to.

### 4. SSH into the PI

Use [putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) (or even better [kitty](https://www.fosshub.com/KiTTY.html)) when on Windows and of course ssh if on Linux/Mac.

```sh
ssh pi@192.168.178.42
```

### 5. Configure the Raspberry PI

We start with `sudo raspi-config`

 - Change User password -> Choos a new password for the user pi
 - Network Options -> Hostname -> Set a hostname for the pi, in our case alarmmonitor-fahrzeughalle
 - Advanced -> Expand Filesystem

Then reboot the PI with `sudo reboot` and login again after a few seconds using the new password
You can check the effect of the expand filesystem command by using the `df -h` command:

```sh
pi@alarmmonitor-fahrzeughalle:~ $ df -h
Dateisystem    Größe Benutzt Verf. Verw% Eingehängt auf
/dev/root        30G    1,0G   27G    4% /
devtmpfs        460M       0  460M    0% /dev
tmpfs           464M       0  464M    0% /dev/shm
tmpfs           464M     12M  452M    3% /run
tmpfs           5,0M    4,0K  5,0M    1% /run/lock
tmpfs           464M       0  464M    0% /sys/fs/cgroup
/dev/mmcblk0p1   41M     21M   21M   51% /boot
tmpfs            93M       0   93M    0% /run/user/1000
```

You see that `/dev/root` is now the aproximate size of your SD card.

Now continue with `sudo raspi-config`

 - Localisation -> Change locale -> de_DE.UTF-8 UTF-8 -> OK -> default de_DE.UTF-8
 - Localisation -> Change timezone -> Europe -> Berlin

For sure you can choose the locale and timezone that fits for you.

Reboot again.

### 6. Update and Upgrade

Use the following two commands to update and upgrade.

```sh
sudo apt-get update
sudo apt-get upgrade
```

### 7. Install packets

Install the necessary packages.

```sh
sudo apt-get install xtightvncviewer vim cec-utils xinit \ 
xserver-xorg-legacy x11-xserver-utils xfonts-scalable \
xfonts-100dpi xfonts-75dpi xfonts-base matchbox-window-manager 
```

### 8. Edit Xwrapper.config

Edit the Xwrapper.config with `sudo vim /etc/X11/Xwrapper.config` and set `allowed_users=anybody`. (If you need help using vim, take a look at [this tutorial](https://coderwall.com/p/adv71w/basic-vim-commands-for-getting-started))

### 9. Create .xinitrc

Create a `.xinitrc` in the home directory of your pi user with `sudo vim ~/.xinitrc` and past the following lines into said file:

```sh
# don't turn off display
xset dpms 0 0 0
xset -dpms
xset s noblank
xset s off

# simple fullscreen wm
matchbox-window-manager -use_cursor no -use_titlebar no &

# start VNC client
exec echo "Password123" | xtightvncviewer -viewonly -fullscreen -autopass 192.168.178.10:0
```

Modify the `"Password123"` according to what is set in your UltraVNC server settings and the IP in the same line to the IP of that machine.

### 10. Create xinit-login.service

Create a `xinit-login.service` file with `sudo vim /etc/systemd/system/xinit-login.service` and paste following lines:

```sh
[Unit]
After=systemd-user-sessions.service

[Service]
ExecStart=/bin/su pi -l -c /usr/bin/xinit -- VT08
Restart=always

[Install]
WantedBy=multi-user.target
``` 

Now enable and start the just created file with these commands:

```sh 
sudo systemctl daemon-reload
sudo systemctl enable xinit-login
sudo systemctl start xinit-login
``` 

### 11. CEC control

To control the TV remote via a script, we need 

## VNC client

I installed `xtightvncclient` (`sudo apt-get install xtightvncclient`) and mad a shell script to start the connection:

```sh
#!/bin/sh
export DISPLAY=:0
echo "ViewOnlyPassword!1!" | xtightvncviewer -viewonly -fullscreen -autopass 192.168.1.10:0 &
```
"ViewOnlyPassword!1!" is the password configured on the VNC server, 192.168.1.10 is the IP of the Windows Server.

It took me quiet a while to figure out how to pass the password to the VNC client, so that was pitfall number 1.
Then I noticed that th screen hat black borders of about 30mm and the VNC image was cut off at the bottom and on the right side.

First I thought that it was configuration fuckup of th VNC server but that wasn't the case.

## Screen resolution

`fbset` showd me that the resolution of the framebuffer was 1824x984 which seemed odd to me because I had set the screen resolution to 1920x1080 via `raspi-config`.

The solution was to edit `/boot/config.txt`:

```sh
# For more options and information see
# http://rpf.io/configtxt
# Some settings may impact device functionality. See link above for details

# uncomment if you get no picture on HDMI for a default "safe" mode
#hdmi_safe=1

# uncomment this if your display has a black border of unused pixels visible
# and your display can output without overscan
disable_overscan=1

# uncomment the following to adjust overscan. Use positive numbers if console
# goes off screen, and negative if there is too much border
#overscan_left=16
#overscan_right=16
#overscan_top=16
#overscan_bottom=16

# uncomment to force a console size. By default it will be display's size minus
# overscan.
framebuffer_width=1920
framebuffer_height=1080

# uncomment if hdmi display is not detected and composite is being output
#hdmi_force_hotplug=1

# uncomment to force a specific HDMI mode (this will force VGA)
hdmi_group=1
hdmi_mode=16

# uncomment to force a HDMI mode rather than DVI. This can make audio work in
# DMT (computer monitor) modes
#hdmi_drive=2

# uncomment to increase signal to HDMI, if you have interference, blanking, or
# no display
#config_hdmi_boost=4

# uncomment for composite PAL
#sdtv_mode=3

#uncomment to overclock the arm. 700 MHz is the default.
#arm_freq=800

# Uncomment some or all of these to enable the optional hardware interfaces
#dtparam=i2c_arm=on
#dtparam=i2s=on
#dtparam=spi=on

# Uncomment this to enable the lirc-rpi module
#dtoverlay=lirc-rpi

# Additional overlays and parameters are documented /boot/overlays/README

# Enable audio (loads snd_bcm2835)
#dtparam=audio=on
``` 

`disable_overscan=1`mad the black border disappear, `framebuffer_width=1920` and `framebuffer_height=1080` mad the framebuffer resolution 1920x1080 so that nothing of the screen got cut off.
`hdmi_group=1` and `hdmi_mode=16` are responsible for the HDMI resolution of 1920x1080 60Hz, these were set by `raspi-config`.

## CEC controling the TV

And finally I wanted to control the TV power state by CEC commands via HDMI.
I made two more shell scripts for turn on and standby:

```sh
#!/bin/sh
# Turn on TV via CEC
echo "on 0" | cec-client -s -d 1
```

```sh
#!/bin/sh
# Turn off TV via CEC
echo "standby 0" | cec-client -s -d 1
```

First these scripts didn't work for me, the solution was to enable CEC in the TV settings (Samsung calls it Anynet+) 

In `Menu -> System -> Anynet+ (HDMI-CEC)`, I enabled both options, If I only enable the first on I can turn the TV on but not off.



