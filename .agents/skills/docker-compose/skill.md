---
id: docker-compose
name: Docker Compose house style
description: How to write and keep service files consistent in this repo
enabled: true
---

# 🎀 Docker Compose house style

These are the happy little rules for Compose files in this repo. Follow them and every service file feels like it belongs to the same family: easy to read, easy to scan, and easy to love.

## The basics, with a smile

1. **One service per file.** Each app gets its own file in `apps/`, such as `apps/sonarr.yml`. A file may include a tiny helper that exists only for that app, the way `profilarr.yml` includes `profilarr-parser` and `postgresql.yml` includes `postgresql-init`.
2. **Names match.** The file name matches the service name: lowercase, and kebab-case when a name needs a hyphen.
3. **Indentation.** Two spaces. Always two. The files love it.
4. **Quotes.** Use double quotes `"` when a string holds special characters or a variable.

## Key order

Keep the keys in this order so a glance down the file always lands in the same place.

### 1. Identity, first

These two come first, in this order:

1. `image`
2. `container_name`

### 2. Single values, next

Scalars sit together before any list or object. Common ones:

* `restart`
* `hostname`
* `user`
* `privileged`
* `network_mode`
* `stop_grace_period`

### 3. Lists and objects, last, A to Z

List and object keys go at the end, sorted alphabetically by key name. The usual guests:

* `cap_add`
* `command`
* `deploy`
* `devices`
* `environment`
* `healthcheck`
* `labels`
* `networks`
* `ports`
* `volumes`

## A cheerful example

```yaml
services:
  example-app:
    # 1. Identity
    image: example/app:latest
    container_name: example-app

    # 2. Single Value Configuration
    restart: unless-stopped
    hostname: example-host

    # 3. Lists and Complex Objects (Alphabetical Order)
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    labels:
      - "traefik.enable=true"
    networks:
      - mediacenter
    ports:
      - "8080:80"
    volumes:
      - /path/to/config:/config
```

## Traefik labels, in this order

When an app gets Traefik labels, lay them out like this:

1. Enable Traefik: `traefik.enable=true`
2. Router rule: `traefik.http.routers.<name>.rule`
3. Entrypoints: `traefik.http.routers.<name>.entrypoints`
4. Service port: `traefik.http.services.<name>.loadbalancer.server.port`
5. Middlewares: `traefik.http.routers.<name>.middlewares`, when the app uses them
6. TLS cert resolver: `traefik.http.routers.<name>.tls.certresolver`, when the app sets one

## Environment variables

* Write them as `${VARIABLE_NAME}`.
* `PUID`, `PGID`, and `TZ` belong on almost every service. They are the little constants that keep the whole stack feeling at home.
