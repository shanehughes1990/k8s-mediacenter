# Adding a New Proxied Application to Authentik

This guide explains how to secure an application using Authentik's "Proxy" method (ForwardAuth). This is used for applications that **do not** support OIDC/SAML natively (like Sonarr, Radarr, Prowlarr) or when you want to enforce authentication *before* the request even reaches the application.

## When to use Proxy vs OIDC

| Method | Use Case | Pros | Cons |
| :--- | :--- | :--- | :--- |
| **OIDC / SAML** | Apps with built-in SSO support (Homarr, Plex, Grafana) | Seamless login, app knows user identity, cleaner integration. | Requires app support. |
| **Proxy (ForwardAuth)** | Apps without SSO (Sonarr, Radarr) or simple static sites | Works with *anything*, protects the app completely from public internet. | App might not know *who* logged in (unless it reads headers). |

---

## Step 1: Docker / Traefik Configuration

You need to update the application's `docker-compose.yml` entry to route traffic through the Authentik middleware.

**Required Changes:**
1.  **Domain Rule**: Ensure it uses a specific subdomain (e.g., `sonarr.tecsharp.com`).
2.  **Middleware**: Add the `authentik@docker` middleware label.

**Example (`apps/sonarr.yml`):**
```yaml
    labels:
      - "traefik.enable=true"
      # 1. Define the Host rule
      - "traefik.http.routers.sonarr.rule=Host(`sonarr.tecsharp.com`)"
      - "traefik.http.routers.sonarr.entrypoints=websecure"
      # 2. Add the Authentik Middleware (CRITICAL)
      - "traefik.http.routers.sonarr.middlewares=authentik@docker"
      - "traefik.http.services.sonarr.loadbalancer.server.port=8989"
```

*Note: The `authentik@docker` middleware is defined globally in `apps/authentik.yml`.*

---

## Step 2: Create the Provider in Authentik

The Provider tells Authentik *how* to handle the request (e.g., where to redirect, what flow to use).

1.  Go to **Applications** -> **Providers**.
2.  Click **Create**.
3.  Select **Proxy Provider**.
4.  **Name**: Name of the app (e.g., `Sonarr`).
5.  **Authorization flow**: Select `default-provider-authorization-implicit-consent` (Recommended: skips the "Authorize Application" approval screen).
6.  **External Host**: The full URL of the app (e.g., `https://sonarr.tecsharp.com`).
    *   *Important: Must match the Traefik Host rule exactly.*
7.  **Internal Host**: Leave blank (Traefik handles the routing).
8.  Click **Finish**.

---

## Step 3: Create the Application in Authentik

The Application binds the Provider to specific Users/Groups (Policies).

1.  Go to **Applications** -> **Applications**.
2.  Click **Create**.
3.  **Name**: Name of the app (e.g., `Sonarr`).
4.  **Slug**: `sonarr` (URL friendly name).
5.  **Provider**: Select the Provider you created in Step 2.
6.  **Policy Engine Mode**: Select **ANY** (Allows access if user matches *at least one* bound group).
7.  Click **Create**.

### Bind Permissions (Groups)
1.  Click on the newly created Application name.
2.  Go to the **Policy / Group Bindings** tab.
3.  Click **Bind Group**.
4.  Select the groups allowed to access this app (e.g., `media-admins`, `media-power-users`).
    *   *If you bind no groups, it might default to allowing everyone or no one depending on global settings. Explicit binding is safer.*

---

## Step 4: Update the Outpost (CRITICAL STEP)

Authentik's "Embedded Outpost" is the actual worker that processes the proxy requests. **It does not automatically know about new Proxy applications.** You must explicitly add them.

1.  Go to **Applications** -> **Outposts**.
2.  Locate the **authentik Embedded Outpost**.
3.  Click **Edit** (Pencil Icon).
4.  **Applications**: Locate your new application (e.g., `Sonarr`) in the list.
5.  **Select it** (Ensure existing apps remain selected by holding Ctrl/Cmd).
6.  Click **Update**.

*If you skip this step, you will see a broken Authentik error page or "Not Found" when visiting the app.*

---

## Step 5: Verify

1.  Restart the application container (to apply Traefik labels):
    ```bash
    docker compose up -d sonarr
    ```
2.  Visit `https://sonarr.tecsharp.com`.
3.  **Expected Behavior**:
    *   If not logged in -> Redirects to Authentik Login.
    *   If logged in as Allowed User -> Loads Sonarr.
    *   If logged in as Restricted User -> Shows "Permission Denied".
