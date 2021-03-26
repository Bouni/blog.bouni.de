---
title: "Wireguard Fails to Start After Reboot"
date: 2021-03-26T21:04:13+01:00
draft: false
tags: [ WireGuard, Systemd ]
---

I use Wireguard for my VPNs and I'm absolutely statisfied with it.
Unfortunately, whenever I restarted my server which runs wiregurad, it didn't come up automatically.

<!--more-->

The systemd service was enabled `systemctl status wg-quick@wg0.service` gave me `Loaded: loaded (/usr/lib/systemd/system/wg-quick@.service; enabled; vendor preset: disabled)`.
When I then started it manually using `sudo systemctl start wg-quick@wg0.service` it started just fine.

After lokking into the output a little closer I saw this:

```
wg-quick[452171]: Another app is currently holding the xtables lock. Perhaps you want to use the -w option?
systemd[1]: wg-quick@wg0.service: Control process exited, code=exited, status=4/NOPERMISSION
systemd[1]: wg-quick@wg0.service: Failed with result 'exit-code'.
systemd[1]: Stopped WireGuard via wg-quick(8) for wg0.
```

So something else is locking xtables which prevents the service from starting.

I wasn't able to really figure out what locked the tabel but guessed that it does it not for very long, so I decided to put a little delay into the start of the service.

The systemctl status command tld me that the service file is at `/usr/lib/systemd/system/wg-quick@.service`, so I opened it in vim and added `ExecStartPre=/bin/sleep 30` to the `[Service]` section.

Maybe not the cleanest way of solving this problem, more of a dirty hack, but hey, it did the trick for me 🤷‍♂️ 
