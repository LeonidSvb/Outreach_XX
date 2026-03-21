# Changelog - Outreach XX

**RULES: Follow [Keep a Changelog](https://keepachangelog.com/) standard strictly. Only 6 categories: Added/Changed/Deprecated/Removed/Fixed/Security. Be concise, technical, no fluff.**

---

## [Unreleased]

### Added
- **NocoDB** подключён к базе `outreach` на VPS — UI для просмотра и управления данными
  - URL: `https://nocodb.srv1133622.hstgr.cloud`
  - Видимые таблицы: campaigns, leads, emails, email_accounts, campaign_stats, campaign_stats_daily, tags, warmup_stats, lead_status_counts, sync_log + все v_* views

### Notes: NocoDB подключение (обход сложностей)
Версия NocoDB 0.301.5 CE блокирует подключение к internal Docker hostname через `request-filtering-agent` (`allowPrivateIPAddress: false` по умолчанию). Переменная `NC_DISABLE_REQUEST_FILTER=true` в этой версии не работает (код обфусцирован).

**Решение:** Патч напрямую в контейнере:
```bash
docker exec root-nocodb-1 sed -i \
  -e '7s/allowPrivateIPAddress: false/allowPrivateIPAddress: true/' \
  -e '188s/allowPrivateIPAddress !== undefined ? options.allowPrivateIPAddress : false/allowPrivateIPAddress !== undefined ? options.allowPrivateIPAddress : true/' \
  /usr/src/app/node_modules/request-filtering-agent/lib/request-filtering-agent.js
docker restart root-nocodb-1
```
Патч применяется автоматически при каждом старте через `/root/nocodb-start.sh`, смонтированный в docker-compose как замена `/usr/src/appEntry/start.sh`. При `docker pull` / пересборке повторять не нужно.

После подключения через UI (Settings → Data Sources → Add Data Source):
- Connection: выбрать сохранённый `outreach`
- Database: вписать `outreach` вручную (не выбирать из дропдауна)
- Schema: `public`

NocoDB тянет все таблицы включая `nc_*` внутренние. Скрытие через прямой UPDATE в PostgreSQL:
```sql
UPDATE nc_models_v2 SET enabled = false
WHERE table_name LIKE 'nc_%' OR table_name LIKE 'xc_%'
   OR table_name IN ('workspace', 'workspace_user', 'notification');
```

### Planned
- Lead Warehouse: создать таблицы `leads_master`, `leads_enrichment`, `lead_events`
- 5000 лидов (рекрутинг США): импорт CSV → валидация email (MillionVerifier) → загрузка в PlusVibe
- Zoho CRM: проверить маппинг всех полей контакта (city, country, LinkedIn, tags)
- N8N webhook ALL_EMAIL_REPLIES: протестировать передачу body_text письма → PostgreSQL emails → Zoho Note
- `scripts/zoho/sync.js`: доработать по результатам тестов webhook
- Metabase: дашборд — reply rate, positive rate, pipeline по статусам, emails view
- Автореплаер на PlusVibe: follow-up при получении ответа (через N8N или встроенный)
- Cal.com: решить — синк в PostgreSQL или прямая интеграция в Zoho CRM
- Zoho: нуртуринг sequences, pipeline stages, автоматизации

---

## [0.7.0] - 2026-03-21 - Email Threads + Zoho CRM Full Integration

### Added
- **`scripts/zoho/sync.js`** — обогащение контакта: city, country, LinkedIn, website, tags (JOIN через account_tags), sending account, label, source=PlusVibe
- **`emails` таблица** — хранит все письма из PlusVibe (id, thread_id, direction IN/OUT, lead_email, from_email, sending_account, subject, body_text, label, sent_at, source, zoho_note_id)
- **`scripts/sync/emails.js`** — два экспорта: `backfillEmails()` (бэкфилл через /unibox/emails), `syncRecentEmails()` (safety net последние 48h)
- **`n8n/positive-reply-crm.json`** — N8N workflow: PlusVibe ALL_EMAIL_REPLIES webhook → PostgreSQL emails → Zoho Note
- PlusVibe webhook `ALL_EMAIL_REPLIES` зарегистрирован (ignore_ooo, ignore_automatic)
- Cron: `node scripts/index.js emails` ежедневно в 02:00 (safety net)

### Changed
- `leads` таблица: добавлена колонка `zoho_contact_id VARCHAR(50)` — деdup и ссылка на Zoho Contact
- Zoho Contact Description: Source, Campaign, Sending account, Label, Tags, LinkedIn, Website, PlusVibe ID
- `scripts/index.js`: добавлены args `zoho`, `emails`, `emails_backfill`, `daily_stats`
- Deploy flow: Local → GitHub → VPS git pull (никогда не редактировать напрямую на VPS)
- Все скрипты: однострочный комментарий-описание в начале файла

### Notes
- Бэкфилл: 416 писем из unibox (только OUT — ручные/авто ответы из inbox)
- 14k campaign sends не доступны через unibox API — только агрегаты в campaign_stats
- Входящие ответы лидов теперь пишутся через webhook ALL_EMAIL_REPLIES в реальном времени

---

## [0.6.0] - 2026-03-21 - Daily Stats + Metabase Dashboard Foundation

### Added
- **`db/campaign_stats_daily` table** — daily activity per campaign (not cumulative): `sent_count`, `new_lead_contacted_count`, `replied_count`, `bounced_count`, `positive_reply_count`, `unique_opened_count`, `opportunity_val`; unique constraint on `(campaign_id, stat_date)`
- **`scripts/sync/daily_stats.js`** — two exports:
  - `backfillDailyStats(fromDate)` — one-time backfill, calls PlusVibe `/analytics/campaign/stats` per campaign per day, skips days with zero activity
  - `syncYesterdayDailyStats()` — daily cron function, writes yesterday's activity for all campaigns
- **Cron** — `30 1 * * *`: `node scripts/index.js daily_stats` (runs after campaign_stats snapshot at 01:00)
- **`scripts/index.js`** — added `daily_stats` arg and `syncYesterdayDailyStats` import
- **Metabase dashboard** (id=2) — created fully via Metabase REST API (`x-api-key`):
  - 3 tabs: Overview / Campaigns / Deliverability
  - Tab 1: 4 KPI scalars (Contacted, Reply Rate, Positive Rate, Bounce Rate) + 2 charts (Daily Emails Sent bar, Daily Replies & Bounces line)
  - Tab 2: Campaigns table with rates
  - Tab 3: Domain deliverability + Account health summary + Lead pipeline
  - Date filter (`date/all-options`, default `past30days`) mapped to both charts via field filter on `campaign_stats_daily.stat_date` (field id=362)

### Notes
- Backfill result: 102 rows, 25 campaigns with activity, 2026-01-02 → 2026-03-20
- `campaign_stats` (cumulative YTD) kept for KPI totals; `campaign_stats_daily` used for time-series charts
- PlusVibe `/analytics/campaign/stats?start_date=DAY&end_date=DAY` returns period totals (not cumulative)

---

## [0.6.0] - 2026-03-21 - Zoho CRM Integration

### Added
- **`scripts/zoho/sync.js`** — syncs positive reply leads to Zoho CRM Contacts
- **`scripts/sync/daily_stats.js`** — daily per-campaign stats backfill
- `leads.zoho_contact_id VARCHAR(50)` — column added to track sync state and prevent duplicates
- Zoho OAuth tokens stored in `.env` (ZOHO_CLIENT_ID/SECRET/REFRESH_TOKEN/ACCESS_TOKEN)
- `.env.example` updated with Zoho variables

### Changed
- **Deploy flow**: VPS `/root/outreach-sync/` is now a git repo pointing to GitHub — deploy via `git pull origin main`
- **Cron paths**: updated from `src/` to `scripts/` to match repo structure
- `scripts/index.js` — added `zoho` as sync target, runs after warmup in full sync
- Zoho Contact `Description` field includes: campaign name, sending account, label, PlusVibe ID

### Notes
- 31 existing positive reply leads synced to Zoho on first run
- Deduplication: `zoho_contact_id IS NULL` in PostgreSQL + `duplicate_check_fields: [Email]` in Zoho API
- Cron: `node scripts/index.js zoho` runs hourly

---

## [0.5.0] - 2026-03-20 - N8N Migration SQLite → PostgreSQL

### Changed
- **N8N** migrated from SQLite to PostgreSQL (same `postgres` container, database `n8n`)
- `docker-compose.yml` — added `N8N_ENCRYPTION_KEY` env var to n8n service
- `/root/.env` on VPS — added `N8N_ENCRYPTION_KEY=SgdKhq8TQ0TpLZ7QiH7mRqsO1l9EI4BZ`, corrected `POSTGRES_PASSWORD`

### Added
- `.env` — added `VPS_HOST`, `POSTGRES_HOST`, `N8N_URL`, `METABASE_URL`

### Fixed
- N8N owner account recreated with original UUID (`441afe9c-d085-4951-9606-a1fc7b8a7fdc`) to preserve workflow ownership
- 30 workflows and 25 credentials imported from SQLite export

### Notes
- SQLite file (1.4GB) preserved at `n8n_data` volume — not deleted yet
- N8N login: `leo@systemhustle.com`
- Outreach DB (postgres) is separate from N8N DB — no conflict

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
