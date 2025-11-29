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
