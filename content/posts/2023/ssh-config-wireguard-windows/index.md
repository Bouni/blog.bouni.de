---
title: "SSH config conditions for Wireguard on Windows"
date: 2023-03-16
tags: [SSH, Match, condition, Windows, Wireguard]
---

I'm forced to work on a Windows machine sometimes, which was a pain in the but in the past but got much better with Windows 11.
None the less I use Wireguard to connect to my network which works super good for me with the official Windows client.

The downside was that my ssh_config had a config for one of my servers that looked like this:

```
Host osiris
    HostName osiris.bouni.de
    Port 2222
    User bouni
```

When I connected to my Wireguard VPN I wasn't able to connect any more with `ssh osiris`.
I knew that theres a way to have Match expressions within the ssh_config but only found examples for linux like this [Stack Overflow post](https://stackoverflow.com/a/40747254)

```
Match host web exec "hostname -I | grep -qF 10.10.11."
    ForwardAgent yes
    ProxyCommand ssh -p 110 -q relay.example.com nc %h %p
Host web
    HostName web.example.com
    Port 1111
```

Obviously `"hostname -I | grep -qF 10.10.11."` wouldn't work on Windows so I was on the look for something that works on Windows and finally found this solution:

```
Match host osiris exec "wmic nic where 'NetConnectionStatus=2' get  NetConnectionID | grep Goethestrasse"
    HostName 192.168.178.100
    Port 22

Host osiris
    HostName osiris.bouni.de
    Port 2222
    User bouni
```

The name of my Wireguard config is `Goethestrasse`. As soon as I connect, there's a network interface with that name and that's exactly what the `"wmic nic where 'NetConnectionStatus=2' get  NetConnectionID | grep Goethestrasse` checks for.
If the command returns success, `HostName` and `Port` of the config below are replaced and ssh horus will use the IP and port instead of subdomain and other port.
