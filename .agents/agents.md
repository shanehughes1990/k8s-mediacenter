---
kind: agents
---

# 🍿 Mediacenter agent guidelines

This repo is the Docker Compose stack for the home media center. Write docs in a warm, bubbly voice. Keep service files exact.

## Where things live

* `docker-compose.yml` includes one file per app from `apps/`.
* `config/` holds Traefik's dynamic config, the Postgres init script, and the Homarr Plex theme.
* `scripts/` are the host helpers. Installers copy them to `/usr/local/sbin` and wire up systemd.
* `docs/AUTHENTIK_APP_SETUP.md` is the walkthrough for putting another app behind Authentik.
* `.env` and `secrets/` stay out of git. They hold tokens, passwords, and TLS material.

## How to bring it up

```bash
docker compose up -d
```

## Rules to keep close

* Follow `.agents/skills/docker-compose/skill.md` for every service file: identity keys first, scalars next, lists and objects last and alphabetical.
* `apps/scrutiny.yml` exists, and its include line in `docker-compose.yml` stays commented until someone asks to enable it.
* The running request app is Seerr. Profilarr is v2 and includes `profilarr-parser`. Vaultwarden stores its data in Postgres.
* Leave host scripts in `scripts/`. They boot the stack, look after the NVIDIA driver, run Monday maintenance, and back up the Plex databases.
* A docs change keeps the real steps, hosts, and commands. The cheerful voice wraps those facts.
