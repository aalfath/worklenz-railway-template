[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/worklenz?utm_medium=integration&utm_source=button&utm_campaign=worklenz)

# Worklenz on Railway

One-click [Railway](https://railway.com) template for [Worklenz](https://github.com/Worklenz/worklenz) **3.4.2**, the open-source project management tool for teams (AGPL-3.0). Every service builds from this repository, so when we bump the version here, Railway offers deployers an update.

## What the template deploys

| Service | Built from | What it does |
|---|---|---|
| `worklenz` (public) | [`web/`](web) | nginx 1.30.7 serving the official Worklenz frontend build (`chamikajaycey/worklenz-frontend:3.4.2`), proxying the API, the realtime socket and file storage on the one public domain. Health check `/healthz`. |
| `worklenz-backend` | [`backend/`](backend) | The official Worklenz API (`chamikajaycey/worklenz-backend:3.4.2`). On first boot it loads Worklenz's base database schema; on every boot it applies pending migrations, then starts. Health check `/public/health`. |
| `seaweedfs` | [`seaweedfs/`](seaweedfs) | SeaweedFS 4.54 (single-process `mini` mode): S3-compatible storage for attachments, avatars and logos, on a volume at `/data`. Health check `/healthz`. |
| `Postgres` | Railway's PostgreSQL | All Worklenz data and login sessions. |

Upstream images are pinned by version and digest in each `Dockerfile`. The base schema SQL comes from the matching upstream release commit (`v3.4.2`, `ccd4dd2`), because the official backend image ships only the migrations.

## After deploy

1. Open the `worklenz` service's public URL and choose **Sign up**. The first account creates your organisation and team; you're its owner.
2. Invite colleagues from **Settings → Team members**. Anyone with the URL can also sign up and get their own separate team, as on upstream's self-hosted build.
3. Optional: email (invitations, password resets, notifications) needs SMTP or SES settings on `worklenz-backend` (`EMAIL_PROVIDER`, `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD`, `EMAIL_FROM`); Google sign-in needs `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` and `GOOGLE_CALLBACK_URL`. See upstream's [`.env.example`](https://github.com/Worklenz/worklenz/blob/v3.4.2/.env.example).

## Variables

All are set by the template; nothing has to be typed in.

| Service | Variable | Value |
|---|---|---|
| `worklenz-backend` | `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` | References to the `Postgres` service |
| `worklenz-backend` | `SESSION_SECRET`, `COOKIE_SECRET`, `JWT_SECRET`, `ENCRYPTION_KEY`, `INVITE_SECRET` | Generated 64-character hex secrets |
| `worklenz-backend` | `FRONTEND_URL`, `HOSTNAME`, `S3_PUBLIC_URL` | Derived from the `worklenz` public domain |
| `worklenz-backend` | `S3_ENDPOINT`, `S3_SECRET_ACCESS_KEY` | References to `seaweedfs` over the private network |
| `worklenz` | `BACKEND_HOST`, `BACKEND_PORT`, `STORAGE_HOST`, `STORAGE_PORT` | Private-network references |
| `seaweedfs` | `S3_SECRET_ACCESS_KEY` | Generated 40-character secret |

The backend sends Worklenz's anonymous weekly installation heartbeat by default ([TELEMETRY.md](https://github.com/Worklenz/worklenz/blob/v3.4.2/TELEMETRY.md)); set `WORKLENZ_TELEMETRY_ENABLED=false` on `worklenz-backend` to turn it off.

## Resources

Each service runs within 0.5 GB RAM / 1 vCPU (tested on Railway: backend about 110 MB, SeaweedFS about 130 MB, nginx under 10 MB at idle). The backend caps the Node.js heap at 320 MB (`WORKLENZ_HEAP_MB` changes it). Any unexpected stop exits non-zero, so Railway's `ON_FAILURE` restart policy brings it back.

## Updates

We bump the pinned upstream images in this repository and note each version in [CHANGELOG.md](CHANGELOG.md), breaking changes first. Railway then shows an update notice on your project; apply it when you're ready. Database migrations run automatically when the new backend starts, so back up the `Postgres` service first (Railway's volume backups or `pg_dump`).

## Local test

```sh
docker build -t wl-backend backend && docker build -t wl-web web && docker build -t wl-sw seaweedfs
```

Then run them with a PostgreSQL 15+ database and the variables above (`BACKEND_HOST`/`STORAGE_HOST` pointing at the other containers).

## Licence

The wrapper files in this repository are MIT. Worklenz is AGPL-3.0, SeaweedFS Apache-2.0, nginx BSD-2-Clause.
