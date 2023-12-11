---
title: "Split docker compose files"
date: 2023-09-29
tags: [docker, docker compose, split, include]
---

All my services that I selfhost are docker containers which I manage using [docker compose](https://docs.docker.com/compose/).
Until recently I had all of them in one big `docker-compose.yaml` file which started to be a hassle to manage.

For a while I looked for ways to split the file into multiple files but nothing really statisfied me.

I even mad an attempt to to have a bash script that makes use of the `-f` parameter to merge multiple files which kind of worked
but had some strange side effects such as containers were not added to networks every now an then and `depends_on` didn't work.

As of `docker compose` version 2.20 it supports the `include` function which is exactly what I was looking for :star_struck:

All my container config lies in `/opt/docker/`, this is the structure I use now:

```sh
.
├── docker-compose.yaml
├── filesharing
│   ├── filesharing.yaml
│   ├── syncthing
│   └── webdav
├── internal
│   ├── homer
│   └── internal.yaml
├── network
│   ├── blocky
│   ├── diun
│   ├── network.yaml
│   ├── omada
│   └── wg-easy
├── public
│   ├── photoview
│   ├── public.yaml
│   ├── remark42
│   ├── shiori
│   ├── vaultwarden
│   └── vikunja
├── smarthome
│   ├── homeassistant
│   ├── influxdb
│   ├── mosquitto
│   ├── postgresql
│   └── smarthome.yaml
└── webserver
    ├── caddy
    └── www
```

The main `docker-compose.yaml` is placed directly in `/opt/docker`. [Caddy](https://caddyserver.com/) is my favourit webserver and the corner stone of my setup.
It acts as my reverse proxy so I decided to place it as the "main" container in that file:

```yaml
version: "3"

include:
  - /opt/docker/filesharing/filesharing.yaml
  - /opt/docker/internal/internal.yaml
  - /opt/docker/network/network.yaml
  - /opt/docker/public/public.yaml
  - /opt/docker/smarthome/smarthome.yaml

services:
  caddy:
    container_name: caddy
    image: custom-caddy
    build: /opt/docker/webserver/caddy
    env_file:
      - /opt/docker/webserver/caddy/caddy.env
    volumes:
      - /opt/docker/webserver/caddy/Caddyfile:/etc/caddy/Caddyfile
      - /opt/docker/webserver/caddy/data:/data
      - /opt/docker/webserver/caddy/config:/config
      - /opt/docker/webserver/www:/www
    restart: unless-stopped
    ports:
      - 80:80
      - 443:443
    networks:
      - webserver

networks:
  webserver:
    name: webserver
    driver: bridge
```

You can see how I included the other yaml files, `filesharing.yaml` for example looks like this:

```yaml
services:
  syncthing:
    image: linuxserver/syncthing
    container_name: syncthing
    env_file:
      - /opt/docker/filesharing/syncthing/syncthing.env
    volumes:
      - /opt/docker/filesharing/syncthing:/config
      - /storage/syncthing:/data1
    restart: unless-stopped
    ports:
      - 8384:8384
      - 22000:22000/tcp
      - 22000:22000/udp
      - 21027:21027/udp
    networks:
      - webserver
    depends_on:
      - caddy

  webdav:
    container_name: webdav
    image: hacdias/webdav:latest
    user: 1000:1000
    restart: unless-stopped
    volumes:
      - /storage/webdav:/data
      - /opt/docker/filesharing/webdav/config.yaml:/config.yaml
    command: --config /config.yaml
    networks:
      - webserver
    depends_on:
      - caddy

networks:
  filesharing:
    name: filesharing
```

The main benefit is that `depends_on: caddy` works as expected as well as `networks: webserver`.

In order to manage my containers I can now `cd` into `/opt/docker` and use the normal docker compose commands, in my case I use the [oh-my-zsh](https://ohmyz.sh/) shortcuts like `dcup -d` and so on ([complete list](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker-compose)).

I'm really happy with how this works and will stick with it for the forseable future :sunglasses:
