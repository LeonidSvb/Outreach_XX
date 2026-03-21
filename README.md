# Outreach XX — Email Outreach Data Warehouse

Single source of truth for email outreach analytics. Syncs data from PlusVibe (and future tools like Instantly, Smartlead) into PostgreSQL so historical data is preserved even when leads are deleted from the source.

## Problem

PlusVibe deletes all analytics when you delete leads. No historical data, no cross-account view, no deliverability alerts. This project solves that.

## Architecture

```
PlusVibe API
    ↓  hourly cron (Node.js scripts)
    ↓  webhooks (ALL_EMAIL_REPLIES → N8N)
PostgreSQL — outreach database (source of truth)
    ↓  read-only connection     ↓  sync          ↓  sync notes
Metabase — dashboards & SQL  Zoho CRM — contacts & email notes
```

## What Gets Synced

| Table | Source | Frequency |
|-------|--------|-----------|
| `campaigns` | `/campaign/list-all` | Every hour |
| `email_accounts` | `/account/list` | Every hour |
| `leads` | `/lead/workspace-leads` | Every hour (full upsert + soft delete) |
| `campaign_stats` | `/analytics/campaign/stats` | Daily at 01:00 |
| `campaign_stats_daily` | `/analytics/campaign/stats` per day | Daily at 01:30 |
| `warmup_stats` | `/account/warmup-stats` | Every 6 hours |
| `lead_status_counts` | `/lead/count/lead-status` | Every hour (snapshot) |
| `emails` | N8N webhook (real-time) + `/unibox/emails` (daily safety net) | Real-time + daily |

## Key Features

- Leads deleted from PlusVibe are soft-deleted (`deleted_from_source_at`) — data is never lost
- Full pagination for 14k+ leads
- `sync_log` table tracks every sync run (status, records, errors)
- Metabase for dashboards and SQL queries
- Zoho CRM sync: positive reply leads auto-created as Contacts with full context
- Email threads stored in PostgreSQL — inbound replies via N8N webhook, outbound via unibox API

## Stack

- **PostgreSQL 16** — data storage (Hostinger VPS, Docker)
- **Node.js 20** — sync scripts
- **N8N** — webhook handler for real-time email events + Zoho Note creation
- **Metabase** — dashboards and data explorer
- **Zoho CRM** — contact management for positive reply leads
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
node scripts/index.js              # full sync
node scripts/index.js campaigns    # campaigns only
node scripts/index.js leads        # leads only
node scripts/index.js accounts     # email accounts + tags
node scripts/index.js stats        # campaign_stats + warmup + lead_status_counts
node scripts/index.js daily_stats  # yesterday's per-day campaign stats
node scripts/index.js zoho         # sync positive reply leads to Zoho CRM
node scripts/index.js emails       # safety net: sync last 48h emails
```

### Cron Schedule (VPS)

```
0 * * * *    campaigns + accounts + leads + zoho (hourly)
0 1 * * *    campaign stats snapshot (daily)
30 1 * * *   daily per-campaign stats (daily)
0 2 * * *    email safety net: last 48h (daily)
0 */6 * * *  warmup stats
```

## Database Schema

```
campaigns              — all campaigns with metrics, soft delete
email_accounts         — 196 accounts with health scores, daily counters
leads                  — all leads with full contact data, soft delete; zoho_contact_id for CRM link
campaign_stats         — cumulative YTD snapshot per campaign
campaign_stats_daily   — daily activity per campaign (not cumulative) — for time-series charts
account_stats          — daily snapshot per email account
warmup_stats           — workspace-level warmup performance per day
lead_status_counts     — hourly lead count snapshot by status
emails                 — inbound/outbound emails (webhook + unibox API); zoho_note_id for CRM link
sync_log               — sync run history
tags                   — account tags (e.g. domain, pool)
account_tags           — many-to-many: email_accounts ↔ tags
```

## API Reference

See `docs/plusvibe-api.md` for verified endpoint paths and response schemas.

> Note: Official PlusVibe docs have ~30% incorrect paths. Use our reference instead.
