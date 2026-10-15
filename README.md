# 🍿 The Happiest Little Media Center

Welcome in! This is a home media stack that loves movie night, tidy folders, and Docker Compose. It is bright, it is ready to binge, and it is thrilled you are here. 🎉

## 🌟 Who is in the stack

### 🎬 The show

* **[Plex](https://www.plex.tv/)** 🍿 streams the library, with NVIDIA GPU transcoding cheering it on.
* **[Seerr](https://github.com/seerr-team/seerr)** 🔮 takes requests for the next obsession.
* **[Tautulli](https://tautulli.com/)** 📊 keeps a cheerful eye on who is watching.
* **[Homarr](https://homarr.dev/)** 🏠 is the pretty front door. The Plex theme pack lives in `config/homarr/`.
* **[Wizarr](https://github.com/wizarrrr/wizarr)** 🧙 sends out invites with a little sparkle.

### 🤖 The *Arr crew

* **[Sonarr](https://sonarr.tv/)** 📺 looks after TV shows.
* **[Radarr](https://radarr.video/)** 🎬 looks after movies.
* **[Prowlarr](https://prowlarr.com/)** 🕸️ keeps the indexers in a row.
* **[SABnzbd](https://sabnzbd.org/)** 📥 does the heavy lifting for Usenet.
* **[NZBFast](https://github.com/nzbfast/nzbfast)** ⚡ sits beside SABnzbd and uses the same downloads folder.
* **[Profilarr](https://github.com/Dictionarry-Hub/profilarr)** ⚙️ v2, plus `profilarr-parser`, keeps quality profiles in sync.

### 🛡️ The friendly guardians

* **[Traefik](https://traefik.io/)** 🚦 is the reverse proxy, with HTTPS from the certs in `secrets/certs/`.
* **[Authentik](https://goauthentik.io/)** 🪪 greets visitors at the door. See `docs/AUTHENTIK_APP_SETUP.md` when you want another app on the list.
* **[PostgreSQL](https://www.postgresql.org/)** 🐘 holds the app databases. `postgresql-init` creates them for you.
* **[Vaultwarden](https://github.com/dani-garcia/vaultwarden)** 🔐 keeps passwords at home, stored in Postgres.
* **[Cloudflare DDNS](https://github.com/hotio/cloudflareddns)** ☁️ keeps the zone pointed at home, including `triton-dev`.
* **[Cloud SQL Proxy](https://github.com/GoogleCloudPlatform/cloud-sql-proxy)** ☁️ opens a safe path to Google Cloud SQL.
* **[Watchtower](https://containrrr.dev/watchtower/)** 🗼 tucks container updates in while you sleep.

Scrutiny has a compose file in `apps/scrutiny.yml` and is sitting this one out. Its include line in `docker-compose.yml` is commented, ready for a comeback whenever you like.

## ✨ Little bits of magic

* **GPU power.** Plex uses the NVIDIA runtime for transcoding.
* **Databases on arrival.** `postgresql-init` creates the app users and databases, including Vaultwarden.
* **HTTPS by default.** Traefik serves the certificates from `secrets/certs/`.
* **One app per file.** Service files live in `apps/` and get pulled in by `docker-compose.yml`.
* **House style.** Compose conventions live in `.agents/skills/docker-compose/skill.md`.

## 🚀 Let's go

1. Copy `.env.example` to `.env` and fill in the values. 📝
2. Put `tls.crt` and `tls.key` in `secrets/certs/`.
3. Bring the whole party up:

```bash
docker compose up -d
```

4. Put on something fun. 🍿

## 🧰 Host helpers

The scripts in `scripts/` look after the machine that runs this stack. The installers copy them to `/usr/local/sbin` and wire up systemd. They need root.

| Script | What it does |
| --- | --- |
| `mediacenter-boot.sh` | Waits for Docker, checks NVIDIA, then runs `docker compose up -d` and `postgresql-init`. |
| `fix-nvidia-mismatch.sh` | Reloads NVIDIA modules when the loaded driver and userspace disagree, then starts Plex again. |
| `install-nvidia-prevention.sh` | Keeps daily unattended upgrades away from NVIDIA packages and adds a driver check every 6 hours. |
| `system-maintenance.sh` | Runs a full apt upgrade, pulls compose images, and reboots so the new kernel module loads cleanly. |
| `install-system-maintenance.sh` | Installs the boot service, the Monday 04:00 America/Toronto maintenance timer, and the NVIDIA package blacklist. |
| `plex-db-backup.sh` | Backs up the Plex SQLite databases with Plex's own SQLite binary and checks integrity. `--repair` is there when a check is unhappy. |
| `list_disks.sh` | Prints a friendly roll call of the disks: model, serial, and HDD, SSD, or NVMe. |

## 🔮 Someday, with confetti

* [ ] **Decluttarr** 🧹 for a tidier library
* [ ] **Flemmarr** 📄 for Arr config as code
* [ ] **Huntarr.io** 🏹 for finding what is missing
* [ ] **Maintainerr** 🛠️ for keeping the library fresh
* [ ] **Notifiarr** 🔔 for a ding when something finishes
* [ ] **Recyclarr** ♻️ for TRaSH guide sync
* [ ] **SuggestArr** 💡 for "you might also like"
* [ ] **Watchlistarr** 📋 for Plex watchlist sync

---

Built with ❤️ and a very full popcorn bowl. ☕
