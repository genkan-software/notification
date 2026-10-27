# notification

Consumes RabbitMQ workplace events, stores the notification log, sends FCM pushes.

Part of Genkan. Architecture, endpoints and the full stack: see the **setup** repo.

## Layout

```
src/
  Genkan.Notification.Domain/
  Genkan.Notification.Infrastructure/
  Genkan.Notification.Firebase/
  Genkan.Notification.Application/
  Genkan.Notification.Rabbit/
  Genkan.Notification.Api/
Genkan.Notification.slnx
```

## Build / run

`Genkan.Shared` comes from GitHub Packages, so restore needs a token with `read:packages`:

```bash
export GITHUB_PACKAGES_TOKEN=ghp_xxx
dotnet build Genkan.Notification.slnx
docker build --secret id=github_token,env=GITHUB_PACKAGES_TOKEN -t notification .
```

## Configuration (env)

`ConnectionStrings__Postgres`, `RabbitMq__Host/User/Password`, `Firebase__Enabled`, `Firebase__ProjectId`, `Firebase__Client__*`, `GOOGLE_APPLICATION_CREDENTIALS` (service-account JSON, mounted as a secret).
The database schema is owned by **migrator** (run it first).

## CI / release

- push to `main` -> image `ghcr.io/genkan-software/notification:main`, `:sha-xxxxxxx`, `:latest`
- tag `vX.Y.Z` -> also `:X.Y.Z` and `:X.Y`. Normally created for you: tagging **setup** releases every service with the same version.
- Pull requests only build.

Secrets: if `GITHUB_TOKEN` cannot read the `Genkan.Shared` package, either grant this repo access in the package settings
(Package settings > Manage Actions access) or add a `PACKAGES_TOKEN` secret (PAT, `read:packages`).
Dependabot (`.github/dependabot.yml`) opens a PR when a new `Genkan.Shared` is published; it needs `PACKAGES_TOKEN` as a *Dependabot* secret too.
