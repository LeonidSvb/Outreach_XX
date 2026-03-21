# Outreach XX — Project Context for Claude

## What This Project Is

Email outreach data warehouse. Syncs PlusVibe data to PostgreSQL on Hostinger VPS.
Goal: single source of truth that survives lead deletions, enables cross-campaign analytics and deliverability monitoring.

## Infrastructure

- **VPS:** Hostinger, IP `72.61.143.225`, SSH via `~/.ssh/id_ed25519_hostinger`
- **Docker Compose:** `/root/docker-compose.yml` on VPS — runs traefik, postgres, n8n, metabase
- **Postgres:** port `5432` exposed to `127.0.0.1`, user `n8n`, password in `.env`
- **Sync scripts:** `/root/outreach-sync/` on VPS (Node.js ESM, pg library)
- **Cron:** configured on VPS root user

## Databases on Postgres

| DB | Purpose |
|----|---------|
| `n8n` | N8N internal data |
| `outreach` | Our data warehouse |
| `metabase` | Metabase internal data |

## Key Files

- `.env` — all credentials (gitignored, never commit)
- `.env.example` — template without secrets
- `docs/plusvibe-api.md` — verified PlusVibe API paths (official docs are often wrong)
- `scripts/index.js` — sync entry point (campaigns/accounts/leads/stats/tags/zoho)
- `scripts/sync/` — PlusVibe sync modules per entity
- `scripts/zoho/sync.js` — Zoho CRM sync (positive reply leads → Contacts)
- `scripts/notifications/` — Telegram daily report + alerts
- `/root/docker-compose.yml` — full stack config on VPS

## PlusVibe API — Critical Notes

- Base URL: `https://api.plusvibe.ai/api/v1`
- Auth header: `x-api-key`
- Rate limit: 5 req/sec — always add 210ms delay between calls in loops
- Many official doc paths are WRONG — verified paths are in `docs/plusvibe-api.md`
- Key correct paths: `/campaign/list-all` (not /get/campaigns), `/lead/workspace-leads` (not /fetch), `/lead/count/lead-status` (not /count/status), `/account/warmup-stats` (not /warmup/stats), `/hook/list` (not /webhooks/list)

## Sync Strategy

| Entity | Strategy | Notes |
|--------|----------|-------|
| campaigns | Full upsert + soft delete | 35 campaigns, fast |
| email_accounts | Full upsert + soft delete | 196 accounts |
| leads | Full paginated upsert + soft delete | 14k+ leads, ~4min |
| campaign_stats | Daily snapshot (ON CONFLICT DO UPDATE) | Per campaign per day |
| warmup_stats | Daily snapshot | Workspace-level |
| lead_status_counts | Append-only snapshots | Hourly counts |
| emails | Real-time via N8N webhook | FIRST_EMAIL_REPLIES event |

## Soft Delete Pattern

Deleted records in PlusVibe get `deleted_from_source_at = NOW()` set in Postgres. Data is never physically deleted — this is the whole point.

## Deploy Flow

**RULE: Always Local → GitHub → VPS. Never edit files directly on VPS.**

```bash
# 1. Push to GitHub
git push origin main

# 2. Pull on VPS
ssh -i ~/.ssh/id_ed25519_hostinger root@72.61.143.225 "cd /root/outreach-sync && git pull origin main"
```

## Running SSH Commands

```bash
ssh -i ~/.ssh/id_ed25519_hostinger -o StrictHostKeyChecking=no root@72.61.143.225 "command"
```

## Checking Sync

```bash
# Sync log
docker exec root-postgres-1 psql -U n8n -d outreach -c "SELECT sync_type, records_upserted, status, started_at FROM sync_log ORDER BY id DESC LIMIT 10;"

# Cron schedule
crontab -l

# Live logs
tail -50 /var/log/outreach-sync.log
tail -20 /var/log/outreach-notify.log
```

## Zoho CRM

- OAuth app: Server-based, data center `.com`
- Redirect URI: `https://www.zohocorp.com/home.html`
- Scope: `ZohoCRM.modules.ALL,ZohoCRM.settings.READ`
- Syncs leads WHERE status=REPLIED AND label IN (INTERESTED, MEETING_BOOKED, MEETING_COMPLETED)
- Deduplication: `zoho_contact_id IS NULL` + Zoho duplicate_check_fields by Email

## Metabase Connection (when asked to add DB)

- Host: `postgres` (internal Docker hostname)
- Port: `5432`
- Database: `outreach`
- User: `n8n`
- Password: in `.env`

## Future Plans

- Add Instantly / Smartlead as additional sources (same schema, add `source` column)
- Lead validation pipeline (bulk validate from Apollo/other sources)
- Deliverability alerts via N8N (health_7d < 95% → notification)
- Airtable sync for leads management if needed
