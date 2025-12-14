# 🚀 Ultimate Docker Media Center 🍿

Welcome to the **ultimate** home media stack! Powered by the pure, unadulterated joy of **Docker Compose**. It's sleek, it's fast, and it's ready to binge-watch! 🎉

## 🌟 The Star-Studded Cast

### 🎬 The Main Event
*   **[Plex](https://www.plex.tv/)** 🍿 - The king of media streaming. Now supercharged with **NVIDIA GPU** transcoding! 🏎️💨
*   **[Overseerr](https://overseerr.dev/)** 🔮 - The beautiful way to request your next obsession. (Running as `seerr`)
*   **[Tautulli](https://tautulli.com/)** 📊 - Keep an eye on who's watching what. Big Brother for your server! 👁️

### 🤖 The Automation Army (*Arr Stack)
*   **[Sonarr](https://sonarr.tv/)** 📺 - Never miss an episode of your favorite TV shows.
*   **[Radarr](https://radarr.video/)** 🎬 - Your personal movie curator.
*   **[Prowlarr](https://prowlarr.com/)** 🕸️ - The indexer manager to rule them all.
*   **[SABnzbd](https://sabnzbd.org/)** 📥 - The heavy lifter for binary newsgroups.

### 🛡️ The Guardians & Infrastructure
*   **[Traefik](https://traefik.io/)** 🚦 - The modern reverse proxy. SSL everywhere! 🔒
*   **[PostgreSQL](https://www.postgresql.org/)** 🐘 - The rock-solid database powering the *Arrs.
*   **[Cloudflare DDNS](https://github.com/hotio/cloudflareddns)** ☁️ - Keeping us found, no matter the IP.
*   **[Cloud SQL Proxy](https://github.com/GoogleCloudPlatform/cloud-sql-proxy)** ☁️ - Securely connecting to Google Cloud databases.
*   **[Vaultwarden](https://github.com/dani-garcia/vaultwarden)** 🔐 - Keep your secrets safe (and self-hosted!).
*   **[Watchtower](https://containrrr.dev/watchtower/)** 🗼 - Updates your containers automatically while you sleep. 😴
*   **[Scrutiny](https://github.com/AnalogJ/scrutiny)** 🩺 - Checking your hard drives' health so you don't have to.
*   **[Organizr](https://organizr.app/)** 📑 - One tab to rule them all.

## ✨ Cool Features
*   **GPU Acceleration**: Plex is configured to use that sweet NVIDIA power.
*   **Auto-Magic DB Init**: Our custom `postgresql-init` script handles user and DB creation automatically! 🧙‍♂️
*   **Secure by Default**: Traefik handles HTTPS certificates automatically.
*   **Modular Config**: Everything is neatly organized in `apps/` and `config/`.

## 🚀 Blast Off!

1.  **Clone the repo** (you probably already did this).
2.  **Set up your secrets**:
    *   Copy `.env.example` to `.env` and fill it in! 📝
    *   Put your certs in `secrets/certs/`.
3.  **Launch**:
    ```bash
    docker compose up -d
    ```
4.  **Enjoy!** 🍿

## 🔮 Future Dreams
*   [ ] **Decluttarr** 🧹 - Clean up the mess.
*   [ ] **Flemmarr** 📄 - Config as Code for your Arrs.
*   [ ] **Huntarr.io** 🏹 - Find what you're missing.
*   [ ] **Maintainerr** 🛠️ - Keep your library fresh.
*   [ ] **Notifiarr** 🔔 - Ding! Your download is ready.
*   [ ] **Profilarr** ⚙️ - Sync your profiles.
*   [ ] **Recyclarr** ♻️ - Sync those TRaSH guides!
*   [ ] **SuggestArr** 💡 - "You might also like..."
*   [ ] **Watchlistarr** 📋 - Sync your Plex watchlist.
*   [ ] **Wizarr** 🧙 - Invite your friends with style.

---
*Built with ❤️ and too much coffee.* ☕
