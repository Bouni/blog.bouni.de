---
title: "RaspberryPi Wallboard"
date: 2025-07-02
tags: [ TV, HDMI, RaspberryPi, Wallboard ]
---

Back in 2017 I built two displays for my fire brigade that show alarm data in case of an alarm.
These use a 40" Samsung TV + a RaspberryPi 3B.

A friend alreada had a [working solution](https://github.com/samuelb/minimal-wallboard), so I adapted his work.
It is a minimal approach that uses a matchbox-window-manager + midori

The dispalys worked fine for all the years but recently I wanted to upgrade the installed RaspberryPi OS from Stretch to Bookworm.

That failed horribly 😏

On one system the upgrade worked but the browser no longer started the other didn't boot after the update.
So I decided to start from scratch and install the latest RaspberryPi OS lite 64-bit on one Pi and simply andd the .xinitrc + the xinit-login.service and call it a day.
That didn't work for whatever reason. The folks that maintain RaspberryPi OS changed a lot of things under the hood but I was not able to figure out what exactly prevented this from working.

So I started from the ground up and created a complete [script](https://gist.github.com/Bouni/a7d8f6e78ecc5bc4d5c28ed72707d29a) that automates the entire process.

Here is what the script does:

### Upgrade system

```sh
apt update && sudo apt upgrade -y
```

### Install dependencies
```sh
apt install -y lightdm openbox chromium-browser unclutter xorg
```
We use lightdm as our display manager, openbox as our minimalistic window manager, chromium as our browser, unclutter to hide the mouse pointer. Everything on top of Xorg.
I concidered using wayland in the beginning but that has its problems with overscan according to several sources and I need that.

### Configure lightdm
```sh
cat << 'EOF' > /etc/lightdm/lightdm.conf
[LightDM]

[Seat:*]
autologin-user=pi
autologin-user-timeout=0
user-session=openbox

[XDMCPServer]

[VNCServer]
EOF
```
The lightdm session does autologin and start openbox.

### Configure openbox
```sh
mkdir -p /home/pi/.config/openbox

cat << 'EOF' > /home/pi/.config/openbox/autostart
#!/bin/bash

# Disable screen blanking
xset s off
xset -dpms
xset s noblank

# Hide mouse cursor when inactive
unclutter -idle 0.5 -root &

# Wait for network (optional)
until ping -c1 9.9.9.9 >/dev/null 2>&1; do sleep 1; done

# Launch Chromium in kiosk mode
chromium-browser \
  --noerrdialogs \
--disable-infobars \
  --kiosk \
  --disable-session-crashed-bubble \
  --disable-restore-session-state \
  --disable-web-security \
  --disable-features=VizDisplayCompositor \
  --start-fullscreen \
  --no-first-run \
  --fast \
  --fast-start \
  --disable-background-timer-throttling \
  --disable-backgrounding-occluded-windows \
  --disable-renderer-backgrounding \
  --app=https://display.fireplan.de/
EOF

chmod +x /home/pi/.config/openbox/autostart
chown pi:pi /home/pi/.config/openbox/autostart
```

This Openbox config is for autostart, it disables all screen blanking, starts unclutter, waits for network access and then launches the chromium browser.

### Configure services
```sh
systemctl set-default graphical.target
systemctl disable bluetooth
systemctl disable hciuart
systemctl disable triggerhappy
systemctl disable cups cups-browsed
systemctl disable avahi-daemon
systemctl disable ModemManager
```

We disable unused services to reduce start up time.

### Configure Overscan
```sh
sed -i '1{/video/!s/$/ video=HDMI-A-1:margin_left=50,margin_right=50,margin_top=30,margin_bottom=30/}' /boot/firmware/cmdline.txt
```

Here we configure Overscan, this has been done in `/boot/config.txt` on Stretch. I tried a lot of variations on Bookworm in `/boot/firmware/config.txt` but none worked.
After hours of searching, I finally found the solution hidden in a [forum post](https://forums.raspberrypi.com/viewtopic.php?p=2212931#p2212931).
Apparently nowadays we have to append settings to `/boot/firmware/cmdline.txt`.
It is important to append to the existing line and not put this in a new line, otherwise it will not work.


### Configure VNC
```sh
raspi-config nonint do_vnc 0

# Start and enable the VNC service (just to be sure)
systemctl enable vncserver-x11-serviced
systemctl start vncserver-x11-serviced
```

The website I call needs to beee configured with credentials that are then stored in the local storage of the browser.
In order to do this I set up VNC and use UltraVNC Client for the connection. I tried TightVNC bt that does not support the offered encryption methods.

### Summary

After a reboot everything woked as expected. The start time is a bit longer than in the old version, but that doesn't matter in my use case.
