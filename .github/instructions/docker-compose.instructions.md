# Docker Compose Standards and Practices

This document outlines the standards and practices for creating and maintaining Docker Compose files in this repository. The primary goal is to ensure consistency, readability, and maintainability across all service definitions.

## General Guidelines

1.  **One Service Per File**: Each application should have its own Docker Compose file located in the `apps/` directory (e.g., `apps/sonarr.yml`).
2.  **Naming Convention**: File names should match the service name (lowercase, kebab-case if needed).
3.  **Indentation**: Use 2 spaces for indentation.
4.  **Quotes**: Use double quotes `"` for string values that contain special characters or variables.

## Key Ordering and Style

To maintain a uniform structure, keys within a service definition must follow this specific order:

### 1. Identity (First)
The first two keys must always be:
1.  `image`
2.  `container_name`

### 2. Single Value Configuration (Middle)
Followed by single-value fields (scalars). These should be grouped together before any lists or objects. Examples include:
*   `restart`
*   `hostname`
*   `user`
*   `privileged`
*   `network_mode`
*   `stop_grace_period`

### 3. Lists and Complex Objects (Last)
Finally, list and object fields should be placed at the end. These **must be sorted alphabetically** by their key name. Common examples include:
*   `cap_add`
*   `command`
*   `deploy`
*   `devices`
*   `environment`
*   `healthcheck`
*   `labels`
*   `networks`
*   `ports`
*   `volumes`

## Example

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

## Traefik Labels

When adding Traefik labels, follow this logical order for consistency:
1.  Enable Traefik: `traefik.enable=true`
2.  Router Rule: `traefik.http.routers.<name>.rule`
3.  Entrypoints: `traefik.http.routers.<name>.entrypoints`
4.  Service Port: `traefik.http.services.<name>.loadbalancer.server.port`
5.  Middlewares: `traefik.http.routers.<name>.middlewares` (if applicable)
6.  TLS/Cert Resolver: `traefik.http.routers.<name>.tls.certresolver` (if applicable)

## Environment Variables

*   Use `${VARIABLE_NAME}` syntax for environment variables.
*   Common variables like `PUID`, `PGID`, and `TZ` should be included in almost every service.
