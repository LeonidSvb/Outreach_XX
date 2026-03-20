# Outreach XX — Email Outreach Data Warehouse

Single source of truth for email outreach analytics. Syncs data from PlusVibe (and future tools like Instantly, Smartlead) into PostgreSQL so historical data is preserved even when leads are deleted from the source.

## Problem

PlusVibe deletes all analytics when you delete leads. No historical data, no cross-account view, no deliverability alerts. This project solves that.

## Architecture

```
PlusVibe API
    ↓  hourly cron (Node.js scripts)
PostgreSQL — outreach database (source of truth)
    ↓  read-only connection
Metabase — dashboards & SQL explorer
```

## What Gets Synced

| Table | Source | Frequency |
|-------|--------|-----------|
| `campaigns` | `/campaign/list-all` | Every hour |
| `email_accounts` | `/account/list` | Every hour |
| `leads` | `/lead/workspace-leads` | Every hour (full upsert + soft delete) |
| `campaign_stats` | `/analytics/campaign/stats` | Daily at 01:00 |
| `warmup_stats` | `/account/warmup-stats` | Every 6 hours |
| `lead_status_counts` | `/lead/count/lead-status` | Every hour (snapshot) |
| `emails` | N8N webhook | Real-time |

## Key Features

- Leads deleted from PlusVibe are soft-deleted (`deleted_from_source_at`) — data is never lost
- Full pagination for 14k+ leads
- `sync_log` table tracks every sync run (status, records, errors)
- Metabase for dashboards and SQL queries

## Stack

- **PostgreSQL 16** — data storage (Hostinger VPS, Docker)
- **Node.js 20** — sync scripts
- **N8N** — webhook handler for real-time email events
- **Metabase** — dashboards and data explorer
- **Traefik** — reverse proxy + SSL

## URLs

- Metabase: `https://metabase.srv1133622.hstgr.cloud`
- N8N: `https://n8n.srv1133622.hstgr.cloud`

## Setup

### Prerequisites
- Hostinger VPS with Docker
- PlusVibe Business plan (API access required)

### Environment Variables

Copy `.env.example` to `.env` and fill in:

```bash
PLUSVIBE_API_KEY=
PLUSVIBE_WORKSPACE_ID=
PLUSVIBE_BASE_URL=https://api.plusvibe.ai/api/v1

VPS_HOST=
POSTGRES_HOST=
POSTGRES_DB=outreach
POSTGRES_USER=
POSTGRES_PASSWORD=
```

### Run Sync Manually

```bash
# On VPS: /root/outreach-sync/
node src/index.js           # full sync
node src/index.js campaigns # campaigns only
node src/index.js leads     # leads only
node src/index.js accounts  # email accounts only
node src/index.js stats     # stats + warmup
```

### Cron Schedule (VPS)

```
0 * * * *   campaigns + accounts + leads
0 1 * * *   campaign stats (daily snapshot)
0 */6 * * * warmup stats
```

## Database Schema

```
campaigns           — all campaigns with metrics, soft delete
email_accounts      — 196 accounts with health scores, daily counters
leads               — all leads with full contact data, soft delete
campaign_stats      — daily snapshot per campaign
account_stats       — daily snapshot per email account
warmup_stats        — workspace-level warmup performance per day
lead_status_counts  — hourly lead count snapshot by status
emails              — inbound/outbound emails (from webhook)
sync_log            — sync run history
```

## API Reference

See `docs/plusvibe-api.md` for verified endpoint paths and response schemas.

> Note: Official PlusVibe docs have ~30% incorrect paths. Use our reference instead.
