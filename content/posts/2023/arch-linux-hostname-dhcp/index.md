---
title: "Inform DHCP server of hostname on Arch linux"
date: 2023-04-06
tags: [Arch linux, DHCP, network, hostname]
---

I run a Mikrotik router in my home network setup and several Arch linux machines.
It bothered me that the hostnames of the Arch linux machines didn't show up in the Mikrotik DHCP server leases table.
Almost all the other network devices showed up nicely which makes it quite easy to identify them.

I fiddeled around witch avahi, systemd-resolve and varous config files but nothing seemed to work.

After a lot of searching I finally came accross [this post](https://bbs.archlinux.org/viewtopic.php?id=272186) in the Arch linux forums.

The answer is quite simple and obvious in hindsight, I need to inform the DHCP server of my hostname in order to be shown in the leases list.

My /etc/dhcpcd.conf looked like this:

```conf
# A sample configuration for dhcpcd.
# See dhcpcd.conf(5) for details.

# Allow users of this group to interact with dhcpcd via the control socket.
#controlgroup wheel

# Inform the DHCP server of our hostname for DDNS.
#hostname

...
```

So I simply had to remove the comment from `#hostname` to `hostname` and after a reboot the hostname showd up as expected.
