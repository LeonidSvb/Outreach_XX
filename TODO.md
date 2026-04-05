# TODO — Outreach XX

## DONE this session

### DB Migration: Hostinger → Railway
- [x] Railway PostgreSQL создан (junction.proxy.rlwy.net:33582, db: railway)
- [x] `.env` обновлен — заменены все POSTGRES_* на DATABASE_URL + новые координаты Railway
- [x] `db/schema.sql` применен на Railway (123 statements, 0 errors)
  - Таблицы: enrichment.leads_master, enrichment.tasks, enrichment.workspace_leads, enrichment.workspaces
  - Таблицы: public.leads, emails, campaigns, email_accounts, calcom_bookings, fathom_calls, tags, account_tags, campaign_stats, campaign_stats_daily, warmup_stats, lead_status_counts, sync_log, account_stats

### Scripts: фикс VPS-хардкода
- [x] `scripts/db.js` — убран хардкод `/root/outreach-sync/.env`, теперь ищет `.env` относительно проекта, использует `DATABASE_URL` вместо PGHOST/PGPORT/PGDATABASE
- [x] `scripts/plusvibe.js` — убран readFileSync .env, использует `process.env`
- [x] `scripts/sync/emails.js` — аналогично
- [x] `scripts/sync/tags.js` — аналогично
- [x] `scripts/zoho/sync.js` — аналогично
- [x] `scripts/notifications/telegram.js` — аналогично

---

## TODO (следующая сессия)

### Full Sync — запустить и проверить
- [ ] `node index.js all` — полный синк с PlusVibe (leads, campaigns, accounts, stats, tags, zoho, emails)
- [ ] `node index.js calcom` — синк Cal.com bookings
- [ ] `node index.js fathom` — синк Fathom Video calls
- [ ] Проверить `sync_log` — все синки прошли без ошибок

### Metabase на Railway
- [ ] В Railway UI: New Service → Docker Image → `metabase/metabase:latest`
- [ ] Добавить env vars: `MB_DB_TYPE=postgres`, `MB_DB_HOST`, `MB_DB_PORT`, `MB_DB_DBNAME`, `MB_DB_USER`, `MB_DB_PASS` (указать Railway PostgreSQL)
- [ ] Generate domain → открыть Metabase, пройти setup
- [ ] Подключить Railway PostgreSQL как data source
- [ ] Воссоздать дашборды

### VPS (если понадобится новый для cron-синков)
- [ ] Решить где запускать cron-синки (Railway cron job, или новый VPS, или GitHub Actions)
- [ ] Обновить `.env` на новом месте запуска

### CLAUDE.md
- [ ] Обновить инфраструктурный раздел — убрать Hostinger, добавить Railway координаты
