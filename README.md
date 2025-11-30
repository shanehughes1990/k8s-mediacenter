# k8s-mediacenter

A containerized media center solution using Docker Compose.

## Current Apps

### Core & Infrastructure
- **Traefik**: Reverse proxy and load balancer.
- **Cloudflare-DDNS**: Dynamic DNS updater for Cloudflare.
- **Postgres**: Relational database service.
- **Cloud SQL Proxy**: Proxy for connecting to Google Cloud SQL instances.
- **Watchtower**: Automates Docker container base image updates.

### Media Server & Management
- **Plex**: Media server for organizing and streaming video.
- **Overseerr**: Request management and media discovery tool for the Plex ecosystem.
- **Tautulli**: Monitoring and tracking tool for Plex.
- **Sonarr**: Smart TV show PVR for newsgroup and bittorrent users.
- **Radarr**: Movie collection manager for Usenet and BitTorrent users.
- **Prowlarr**: Indexer manager/proxy built on the popular arr .net/react stack.

### Downloaders
- **Sabnzbd**: Open-source binary newsreader.

### Utilities & Tools
- **Organizr**: HTPC/Homelab Services Organizer.
- **Vaultwarden**: Unofficial Bitwarden compatible server written in Rust.
- **Scrutiny**: Hard Drive S.M.A.R.T Monitoring, Historical Trends & Real World Failure Thresholds.

## Future Apps

- [ ] **Decluttarr**: Automates the clean-up for *arr download queues, keeping them free of stalled / redundant downloads.
- [ ] **Flemmarr**: Automates configuration for *arr apps using YAML configuration files.
- [ ] **Huntarr.io**: Automates discovering missing and upgrading your media collection.
- [ ] **Maintainerr**: Maintenance tool for the Plex ecosystem to manage and clean up media.
- [ ] **Notifiarr**: Notification aggregation, system monitoring, and Discord integration for the media stack.
- [ ] **Profilarr**: Configuration management tool for Radarr/Sonarr that automates importing and version control of custom formats and quality profiles.
- [ ] **Recyclarr**: Automatically syncs TRaSH guides recommended settings to Sonarr/Radarr instances.
- [ ] **SuggestArr**: Automates media content recommendations and download requests based on user activity.
- [ ] **Watchlistarr**: Syncs Plex Watchlist to Sonarr/Radarr.
- [ ] **Wizarr**: Advanced user invitation and management system for Jellyfin, Plex, Emby, etc.

## Organizr Alternatives

Research into alternatives for the dashboard/organizer role:

- **[Homepage](https://github.com/gethomepage/homepage)**: A modern, secure, highly customizable application dashboard with integrations for over 100 services and translations into multiple languages. Configured via YAML.
    - **RBAC**: No. Static dashboard; everyone sees the same configuration.
- **[Homarr](https://github.com/homarr-labs/homarr)**: A sleek, modern dashboard with a drag-and-drop grid system, tight integration with the *Arr stack, and built-in media request management.
    - **RBAC**: Partial. Supports permissions at the **Board** level (e.g., Admin Board vs. Family Board), but cannot hide individual items on a shared board.
- **[Heimdall](https://github.com/linuxserver/Heimdall)**: A simple, user-friendly application dashboard/launcher. Features "Enhanced Apps" that display live data from supported applications directly on the tiles.
    - **RBAC**: No. Multi-user support exists, but each user manages their own separate, personal dashboard.
- **[Dashy](https://github.com/lissy93/dashy)**: A privacy-respecting, highly customizable dashboard. Supports widgets, status monitoring, themes, and is configured via YAML or UI.
    - **RBAC**: Yes. Supports granular visibility rules (e.g., `showForUsers: ['admin']`) to hide specific links or sections based on the logged-in user.
- **[Homer](https://github.com/bastienwirtz/homer)**: A dead simple, static homepage for your server. Very lightweight, configured via a single YAML file, served as a static HTML page.
    - **RBAC**: No. Static dashboard; everyone sees the same configuration.
- **[Fenrus](https://github.com/revenz/fenrus)**: A personal homepage/dashboard that supports multi-user environments, guest access, and user-specific dashboards.
    - **RBAC**: No. Multi-user support exists, but users manage their own personal dashboards.
