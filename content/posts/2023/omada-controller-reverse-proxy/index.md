---
title: "Omada Controller with caddy as reverse proxy"
date: 2023-07-04
tags: [Omada, TP-Link, network, self-hosted, Wifi, reverse proxy, caddy]
---

I switched from Mikrotiks wAP accesspoints to TP-Link Omada EAP650s a while ago (check out my [blog post](/posts/2022/tp-link-tl-sg2428p-fan-mod/)).
As explained in that post, I started self hosting [Omada controller](https://hub.docker.com/r/mbentley/omada-controller) which is the management software for these APs.

But I never mangaged to get it working behind [caddy](https://caddyserver.com/), my webserver / reverse proxy.

So it ran as a docker container on my home server with exposed ports without HTTPS.
In my home environment that's not a big deal but it always felt wrong.

A few days ago I setup [blocky](https://0xerr0r.github.io/blocky) as my DNS server, again check the [blog post](/posts/2023/dns-ad-blocking-with-blocky/) if you're interested.
So I setup `omada.bouni.de` as a local DNS entry and let caddy serve it via HTTPS using a wildcard certificate.
I decided to not have this subdomain in my public entries because I don't need to access it remotly. If I need to, I can do that via a Wireguard tunnel.

First the relevant part of my `docker-compose.yml`

```yml
  omada-controller:
    container_name: omada-controller
    image: mbentley/omada-controller:latest
    restart: unless-stopped
    environment:
      - TZ=Europe/Berlin
      - MANAGE_HTTP_PORT=8088
      - MANAGE_HTTPS_PORT=8043
      - PORTAL_HTTP_PORT=8088
      - PORTAL_HTTPS_PORT=8043
      - PORT_APP_DISCOVERY=27001
      - PORT_ADOPT_V1=29812
      - PORT_UPGRADE_V1=29813
      - PORT_MANAGER_V1=29811
      - PORT_MANAGER_V2=29814
      - PORT_DISCOVERY=29810
      - SHOW_SERVER_LOGS=true
      - SHOW_MONGODB_LOGS=false
      - PGID=508
      - PUID=508
    ports:
      - 8043:8043
      - 29810:29810/udp
      - 29811:29811
      - 29812:29812
      - 29813:29813
      - 29814:29814
    volumes:
      - ./omada/data:/opt/tplink/EAPController/data
      - ./omada/logs:/opt/tplink/EAPController/logs

```

And this is what my `Caddyfile` looks like:

```Caddyfile
{
    admin off
    log {
        format console
    }

}

*.bouni.de, bouni.de {

  tls {
    dns hetzner {env.HETZNER_AUTH_API_TOKEN}
  }
  
  @omada host omada.bouni.de
  handle @omada {
    reverse_proxy omada-controller:8043 {
      transport http {
        tls_insecure_skip_verify
      }
      header_up Host {host}:8043
      header_down Location :8043 :443
    }
  }

}
```

Be aware that the `dns hetzner` part only works with a custom caddy build, explained [here](/posts/2022/caddy-hetzner-dns-challenge/)

I found this solution in the [caddy forums](https://caddy.community/t/example-tp-link-omada-controller/11857/8), posted by user [drglove](https://caddy.community/u/drglove)

As I had a hard time finding this, I decided to write this blog post, hoping to help others getting this working.
