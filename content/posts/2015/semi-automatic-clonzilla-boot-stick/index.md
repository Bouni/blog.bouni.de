---
layout: post
title: Semi-automatic clonezilla boot stick
date: 2015-03-02 12:45:08 +0100
comments: true
tags: [ Clonezilla, Samba, automatic]
---

I use clonezilla a lot to load images onto computers or create backups of them and it was always a hassle to enter the same values into the diolog over and over again.
Unfortunately the documentation is not the very best.

Anyway, with a lot of googling and trail and error i finally got a semi automatic configuration.

You have to modify 3 files for booting EFI machines as well as BIOS based ones.

<!-- more -->

## EFI: /EFI/boot/grub.cfg

```sh
et prefix=/EFI/boot/
set default="0"
if loadfont $prefix/unicode.pf2; then
  set gfxmode=auto
  insmod efi_gop
  insmod efi_uga
  insmod gfxterm
  terminal_output gfxterm
fi
set timeout="5"
set hidden_timeout_quiet=false

if background_image $prefix/ocswp-grub2.png; then
  set color_normal=black/black
  set color_highlight=magenta/black
else
  set color_normal=cyan/blue
  set color_highlight=white/blue
fi

menuentry "Clonezilla live, ::: Restore :::"{
  search --set -f /live/vmlinuz
  linux /live/vmlinuz boot=live username=user config quiet noswap edd=on nomodeset noeject locales=en_US.UTF-8 keyboard-layouts=ch ocs_live_extra_param="" ocs_prerun1="/lib/live/mount/medium/utils/mount.sh" ocs_live_batch=no ocs_live_run="ocs-sr -g auto -e1 auto -e2 -c -r -j2 -p true restoredisk ask_user ask_user" vga=791 ip= nosplash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 
  initrd /live/initrd.img
}

menuentry "Clonezilla live, ::: Backup :::"{
  search --set -f /live/vmlinuz
  linux /live/vmlinuz boot=live username=user config quiet noswap edd=on nomodeset noeject locales=en_US.UTF-8 keyboard-layouts=ch ocs_live_extra_param="" ocs_prerun1="/lib/live/mount/medium/utils/mount.sh" ocs_live_batch=no ocs_live_run="ocs-sr -q2 -c -j2 -z1p -i 2000 -p true savedisk ask_user ask_user" vga=791 ip= nosplash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1 
  initrd /live/initrd.img
}
```
As you can see i preset the `locales` to US-english (`en_US.UTF-8`), but the keyboard-layouts to swiss-german (`ch`). Furthermore i set ocs_prerun1 with a path to a bashscript where i configure the ethernet and mount a samba share where my images are located. (I show the script later because its the same for EFI and BIOS)

## BIOS: /syslinux/isolinux.cfg, /syslinux/syslinux.cfg

I have no idea why there are two identical cfg files, but i modified both in the same way and that works for me:

```sh
default vesamenu.c32
timeout 50
prompt 0
noescape 1
MENU MARGIN 5
 MENU BACKGROUND ocswp.png
# Set the color for unselected menu item and timout message
 MENU COLOR UNSEL 7;32;41 #c0000090 #00000000
 MENU COLOR TIMEOUT_MSG 7;32;41 #c0000090 #00000000
 MENU COLOR TIMEOUT 7;32;41 #c0000090 #00000000
 MENU COLOR HELP 7;32;41 #c0000090 #00000000

# MENU MASTER PASSWD

say **********************************************************************
say Clonezilla, the OpenSource Clone System.
say NCHC Free Software Labs, Taiwan.
say clonezilla.org, clonezilla.nchc.org.tw
say THIS SOFTWARE COMES WITH ABSOLUTELY NO WARRANTY! USE AT YOUR OWN RISK! 
say **********************************************************************

# Allow client to edit the parameters
ALLOWOPTIONS 1

# simple menu title
MENU TITLE clonezilla.org, clonezilla.nchc.org.tw

label Clonezilla live, ::: Restore :::
  MENU LABEL Clonezilla live, ::: Restore :::
  kernel /live/vmlinuz
  append initrd=/live/initrd.img boot=live username=user config quiet noswap edd=on nomodeset locales=en_US.UTF-8 keyboard-layouts=ch ocs_live_extra_param="" ocs_prerun1="/lib/live/mount/medium/utils/mount.sh" ocs_live_batch=no ocs_live_run="ocs-sr -g auto -e1 auto -e2 -c -r -j2 -p true restoredisk ask_user ask_user" ocs_live_batch=no vga=791 ip=  nosplash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1

label Clonezilla live, ::: Backup :::
  MENU LABEL Clonezilla live, ::: Backup :::
  kernel /live/vmlinuz
  append initrd=/live/initrd.img boot=live username=user config quiet noswap edd=on nomodeset locales=en_US.UTF-8 keyboard-layouts=ch ocs_live_extra_param="" ocs_prerun1="/lib/live/mount/medium/utils/mount.sh" ocs_live_batch=no ocs_live_run="ocs-sr -q2 -c -j2 -z1p -i 2000 -p true savedisk ask_user ask_user" ocs_live_batch=no vga=791 ip=  nosplash i915.blacklist=yes radeonhd.blacklist=yes nouveau.blacklist=yes vmwgfx.enable_fbdev=1
```
  
The changes are the same as for the EFI grub.cfg.

## custom mount script: /utils/mount.sh

As is said before, i call a custom mount script because i wanted to automate a few things and doing that inline is just ugly as hell :-)

```sh
#!/bin/bash

# import configuration 
source "/lib/live/mount/medium/config.sh"

dhclient -v eth0

addr0=$(ifconfig eth0 | grep "inet addr")

if [ "$addr0" == "" ]
then
    dhclient -v eth1
fi

addr1=$(ifconfig eth1 | grep "inet addr")

if [ "$addr0" == "" ] && [ "$addr1" == "" ]
then
    echo "Error: no IP received!"
    read -p enter
    reboot
fi

# mount samba share
mount -t cifs //$sambaserver/$sambapath /home/partimag -o user=$user,password=$password,domain=$domain
```

I first import a config script that is located in the root of the boot stick. Then i try to get a DHCP lease for eth0, if that fails i try the same for eth1.
If none of the two interfaces get a DHCP lease, i throw an error and reboot after the user confirms by pressing ENTER (or any other key).

Last but not least, i mount the Samba server.

## configuration: config.sh

And finally the config file with the parameters, that makes it easy to adjust the scripts in case the servername or password changes.

```sh
#!/bin/bash

sambaserver="hostname"
sambapath="clonezilla/images" #note, no leading slash!
user="username"
password="password"
domain="MyDomain"
```

And thats it, the script does everythin autmatically, except for choosing the image and the disk to restore/backup. Thats why i call it semi-automatic. In case you want to have a fully automatic script, you can simply replace the `ask_user` parameters in the grub.cfg files with `imagename` and `sda` for example.

 

