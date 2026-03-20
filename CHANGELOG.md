# Changelog - Outreach XX

**RULES: Follow [Keep a Changelog](https://keepachangelog.com/) standard strictly. Only 6 categories: Added/Changed/Deprecated/Removed/Fixed/Security. Be concise, technical, no fluff.**

---

## [Unreleased]

### Next Session Plan
**Goal:** Configure daily report cron via N8N MCP

**Priority Tasks:**
1. Test N8N MCP connection (restart Claude Code first)
2. Create + execute daily report workflow via MCP
3. Set up daily schedule (8:00 AM) in N8N
4. Push unpushed commit to GitHub

---

## [0.4.0] - 2026-03-20 - Telegram Notifications + N8N Workflows

### Added
- **`scripts/notifications/telegram.js`** - Telegram Bot API sender
- **`scripts/notifications/daily_report.js`** - Full daily report: yesterday stats, active campaigns, by-tag breakdown, domain health, warmup, lead pipeline, sync errors
- **`scripts/notifications/alerts.js`** - Proactive alerts: health_7d < 95%, bounce rate > 5%, sync errors
- **`scripts/notify.js`** - Entry point: `node src/notify.js report|alerts`
- **`n8n/daily-report-v1-ssh.json`** - N8N workflow: Schedule → SSH → runs Node.js report script
- **`n8n/daily-report-v2-native.json`** - N8N workflow: Schedule → single Postgres CTE → Code → HTTP Telegram (no external scripts)
- N8N SSH credential created via API (ID: `ZfFlprO9onp2jYFi`)
- N8N MCP server configured in `~/.claude/settings.json`

### Fixed
- **`v_performance_by_tag`**: `auto_reply_rate_pct` denominator changed from `replied_leads` to `contacted_leads` — was producing >100% for OOO leads with COMPLETED status

### Notes
- N8N Community Edition: Schedule trigger workflows cannot be triggered via REST API (`POST /run` = 405). Requires webhook trigger or MCP
- Telegram report tested and working: `node src/notify.js report` on VPS

---

## [0.3.0] - 2026-03-20 - SQL Views + Tag Analytics

### Added
- **`db/views.sql`** — 11 SQL views:
  - `v_campaign_performance` — reply rate, bounce rate, positive rate per campaign
  - `v_daily_sending_volume` — daily stats from campaign_stats snapshots
  - `v_deliverability_by_domain` — health, capacity, accounts below 95% per domain
  - `v_account_health` — all accounts with CRITICAL/WARNING/OK flags
  - `v_leads_funnel` — lead counts by status across all campaigns
  - `v_leads_funnel_by_campaign` — funnel breakdown per campaign
  - `v_domain_capacity` — daily limit utilization per domain
  - `v_replied_leads` — replied leads for manual follow-up
  - `v_weekly_summary` — weekly rollup from campaign_stats
  - `v_campaign_pace` — remaining leads + estimated days to complete
  - `v_performance_by_tag` — reply/positive/auto-reply/bounce rates per account tag
- **`scripts/sync/tags.js`** — syncTags() + syncAccountTags() for tags and account_tags tables

---

## [0.2.0] - 2026-03-19 - Full Sync Pipeline

### Added
- **`scripts/index.js`** — sync entry point, supports: campaigns / accounts / leads / stats / all
- **`scripts/db.js`** — PostgreSQL pool + logSync() helper
- **`scripts/plusvibe.js`** — PlusVibe API client with 210ms rate limiting
- **`scripts/sync/campaigns.js`** — full upsert + soft delete, 35 campaigns
- **`scripts/sync/email_accounts.js`** — full upsert + soft delete, 196 accounts
- **`scripts/sync/leads.js`** — paginated upsert + soft delete, 14k+ leads (~4 min)
- **`scripts/sync/stats.js`** — daily campaign_stats snapshot + warmup_stats
- **`docs/plusvibe-api.md`** — verified API paths (official docs ~30% wrong)
- Cron configured on VPS: hourly sync + daily stats at 01:00 + warmup every 6h

### Notes
- Official PlusVibe docs had wrong paths: `/campaign/list-all` not `/get/campaigns`, `/lead/workspace-leads` not `/fetch`, etc.
- Postgres exposed via `127.0.0.1:5432:5432` in docker-compose for direct connection

---

## [0.1.0] - 2026-03-18 - Infrastructure

### Added
- PostgreSQL `outreach` database on Hostinger VPS (Docker, same compose as N8N)
- 9 tables: `campaigns`, `email_accounts`, `leads`, `campaign_stats`, `account_stats`, `warmup_stats`, `lead_status_counts`, `emails`, `sync_log`
- Soft delete pattern: `deleted_from_source_at` — data never physically deleted
- Metabase connected to `outreach` DB (read-only, internal Docker hostname `postgres`)
- **`.env.example`** — template without secrets
- **`.gitignore`** — `.env`, `node_modules/`, `*.log`
- **`CLAUDE.md`** — project context for Claude
- **`README.md`** — architecture, setup, cron schedule

---

**Maintained by:** Leo
**Last Updated:** 2026-03-20
