# 🪪 Let's tuck a new app behind Authentik

Hooray, a new app! This guide walks through Authentik's Proxy method (ForwardAuth) so the login happens before the request ever reaches the app.

It is the happy path for apps that do not speak OIDC or SAML themselves, such as Sonarr, Radarr, and Prowlarr. It is also lovely when you want the public internet to meet Authentik first.

## Proxy or OIDC? Both are wonderful

| Method | Lovely for | Why it feels good | What to watch |
| --- | --- | --- | --- |
| **OIDC / SAML** | Apps with built-in SSO, such as Homarr, Plex, and Grafana | The login is seamless and the app knows who you are. | The app has to support it. |
| **Proxy (ForwardAuth)** | Apps without SSO, such as Sonarr and Radarr, and simple sites | It wraps anything, and the app stays off the public internet until Authentik says hello. | The app only learns who logged in if it reads the forwarded headers. |

---

## Step 1: Say hello in Docker and Traefik

Add the app's Traefik labels so traffic passes through the Authentik middleware.

1. Give it a host rule on its own subdomain, such as `sonarr.${CLOUDFLARE_ZONE_NAME}`.
2. Add the `authentik@docker` middleware label.

`apps/sonarr.yml` already looks like this:

```yaml
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.sonarr.rule=Host(`sonarr.${CLOUDFLARE_ZONE_NAME}`)"
      - "traefik.http.routers.sonarr.entrypoints=websecure"
      - "traefik.http.routers.sonarr.middlewares=authentik@docker"
      - "traefik.http.services.sonarr.loadbalancer.server.port=8989"
```

The `authentik@docker` middleware is defined on `authentik-server` in `apps/authentik.yml`. You get to reuse it everywhere. How nice!

---

## Step 2: Create the provider

The provider tells Authentik how to greet this app: where to send people, and which flow to use.

1. Go to **Applications** → **Providers**.
2. Click **Create**.
3. Select **Proxy Provider**.
4. **Name**: the app name, such as `Sonarr`.
5. **Authorization flow**: `default-provider-authorization-implicit-consent`. This skips the extra "Authorize Application" screen.
6. **External Host**: the full URL, such as `https://sonarr.example.com` when `CLOUDFLARE_ZONE_NAME` is `example.com`. It needs to match the Traefik Host rule exactly.
7. **Internal Host**: leave this blank. Traefik already knows the way.
8. Click **Finish**.

---

## Step 3: Create the application

The application ties that provider to the people and groups who get to come in.

1. Go to **Applications** → **Applications**.
2. Click **Create**.
3. **Name**: the app name, such as `Sonarr`.
4. **Slug**: `sonarr`.
5. **Provider**: the provider from Step 2.
6. **Policy Engine Mode**: **ANY**. A person gets in when they match at least one bound group.
7. Click **Create**.

### Invite the right groups

1. Open the new application.
2. Open the **Policy / Group Bindings** tab.
3. Click **Bind Group**.
4. Pick the groups who belong here, such as `media-admins` and `media-power-users`.

Bind the groups on purpose. An application with no bindings follows the global default, and an explicit list is the cozier choice.

---

## Step 4: Tell the outpost about the new friend

The embedded outpost is the worker that actually handles proxy requests. It does not notice a new proxy application on its own, so this step is the important one.

1. Go to **Applications** → **Outposts**.
2. Find **authentik Embedded Outpost**.
3. Click **Edit**.
4. In **Applications**, find the new app, such as `Sonarr`.
5. Select it, and keep the apps that are already selected. Hold Ctrl or Cmd so the existing ones stay highlighted.
6. Click **Update**.

Skip this and the app answers with an Authentik error page or "Not Found". A tiny click here saves that whole adventure.

---

## Step 5: Take it for a spin

Restart the app container so Traefik picks up the labels:

```bash
docker compose up -d sonarr
```

Visit `https://sonarr.${CLOUDFLARE_ZONE_NAME}` and enjoy the result:

* Signed out: a cheerful redirect to the Authentik login.
* Signed in, and allowed: Sonarr opens right up.
* Signed in, and not in a bound group: Authentik shows "Permission Denied".
