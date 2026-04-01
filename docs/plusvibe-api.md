# PlusVibe API — Справочник (проверено 2026-03-20)

**Base URL:** `https://api.plusvibe.ai/api/v1`
**Auth header:** `x-api-key: YOUR_API_KEY`
**Rate limit:** 5 req/sec
**Обязательный параметр везде:** `workspace_id`

> Все пути проверены реальными запросами. Пути из официальной документации часто неверные — используй только этот файл.

---

## Workspace

| Method | Path | Параметры | Ответ |
|--------|------|-----------|-------|
| GET | `/authenticate` | — | `{ status, account, workspaces: [{_id, name}] }` |
| POST | `/workspaces/add/` | body: `workspace_name` | `{ status, _id }` |

---

## Campaigns

| Method | Path | Параметры | Ответ |
|--------|------|-----------|-------|
| GET | `/campaign/list` | query: `skip`, `limit` (max 100) | `[{id, status, name, tags, last_lead_sent, last_lead_replied}]` |
| GET | `/campaign/list-all` | query: `status` (ACTIVE/PAUSED/COMPLETED/ARCHIVED), `campaign_type` (all/parent/subseq), `skip`, `limit` | полный объект кампании с метриками |
| GET | `/campaign/get/name` | query: `campaign_id` | `{campaign_id, campaign_name}` |
| GET | `/campaign/get/status` | query: `campaign_id` | `{campaign_id, status}` |
| GET | `/campaign/get/accounts` | query: `campaign_id` | `["email@domain.com", ...]` |
| POST | `/campaign/add/campaign` | body: `camp_name` | `{status, id}` |
| POST | `/campaign/add/subsequence` | body: `name`, `parent_camp_id`, `events[]` | `{status, id}` |
| POST | `/campaign/set/name` | body: `campaign_id`, `name` | `{status}` |
| POST | `/campaign/launch` | body: `campaign_id` | `{status}` |
| POST | `/campaign/pause` | body: `campaign_id` | `{status}` |
| PATCH | `/campaign/update/campaign` | body: `campaign_id` + любые поля | `{id, camp_name, status, updated_at}` |
| DELETE | `/campaign/delete` | body: `campaign_id`, `is_archive` (yes/no), `is_save_lead_data` (yes/no) | `{status}` |

**Полный объект кампании (`/campaign/list-all`) содержит:**
`camp_name`, `status`, `lead_count`, `sent_count`, `unique_opened_count`, `replied_count`, `bounced_count`, `positive_reply_count`, `negative_reply_count`, `neutral_reply_count`, `opportunity_val`, `lead_contacted_count`, `completed_lead_count`, `open_rate`, `replied_rate`, `schedule` (days, tz, from_time, to_time), `sequences[]` (body, subject, wait_time), `email_accounts[]`, `created_at`, `modified_at`

---

## Analytics

| Method | Path | Параметры | Ответ |
|--------|------|-----------|-------|
| GET | `/analytics/campaign/summary` | query: `campaign_id` | `{campaign_name, completed, contacted, leads_who_read, leads_who_replied, bounced, unsubscribed, positive_reply_count, total_sent_emails}` |
| GET | `/analytics/campaign/stats` | query: `campaign_id`, `start_date` (req), `end_date` | детальные метрики за период |
| GET | `/campaign/stats/all` | query: `start_date` (req), `end_date` | `{lead_count, sent_count, unique_opened_count, replied_count, bounced_count, positive_reply_count, opportunity_val, ...}` |

**Реальные данные (2026-01-01 → 2026-03-20):**
- `sent_count`: 13 317
- `replied_count`: 111 (reply rate ~1.4%)
- `bounced_count`: 165 (2.25%)
- `positive_reply_count`: 34
- `unique_opened_count`: 111

---

## Leads

| Method | Path | Параметры | Ответ |
|--------|------|-----------|-------|
| GET | `/lead/workspace-leads` | query: `campaign_id`, `status`, `label`, `email`, `page`, `limit`, `sort`, `direction` | массив лидов |
| GET | `/lead/get` | query: `email` (req), `campaign_id`, `skip`, `limit` | объект лида |
| GET | `/lead/count/lead-status` | query: `campaign_id` (opt) | `[{status, count}]` |
| POST | `/lead/add` | body: `campaign_id`, `leads[]` + опции skip/resume | `{total_sent, leads_uploaded, duplicate_email_count, invalid_email_count, ...}` |
| POST | `/lead/add-lead-in-subseq` | body: `subseq_id`, `parent_lead_ids[]` | `{status, inserted}` |
| POST | `/lead/delete` | body: `delete_list[]`, `campaign_id?` | `{status}` |
| POST | `/lead/data/update` | body: `email`, `variables{}` | `{status}` |
| POST | `/lead/update/status` | body: `campaign_id`, `email`, `new_status` (только "COMPLETED") | `{status}` |

**Статусы лидов:** `NOT_CONTACTED`, `CONTACTED`, `COMPLETED`, `REPLIED`, `RESCHEDULED`, `UNSUBSCRIBED`, `BOUNCED`, `SKIPPED`

**Реальные counts (весь workspace):**
- NOT_CONTACTED: 8 406
- CONTACTED: 1 670
- COMPLETED: 2 570
- REPLIED: 89
- BOUNCED: 161
- SKIPPED: 1 581

**Полный объект лида содержит:**
`_id`, `campaign_id`, `workspace_id`, `status`, `label`, `email`, `first_name`, `last_name`, `job_title`, `company_name`, `company_website`, `phone_number`, `linkedin_person_url`, `linkedin_company_url`, `city`, `country`, `email_acc_name`, `camp_name`, `sent_step`, `total_steps`, `replied_count`, `opened_count`, `last_sent_at`, `mx` (GOOGLE_WORKSPACE/MICROSOFT/etc), `notes`, `bounce_msg`, `created_at`, `modified_at`

**Lead labels:** `INTERESTED`, `NOT_INTERESTED`, `AUTOMATIC_REPLY`, `OUT_OF_OFFICE`, кастомные

---

## Email Accounts

| Method | Path | Параметры | Ответ |
|--------|------|-----------|-------|
| GET | `/account/list` | query: `skip`, `limit`, `tags`, `email` | `{accounts: [{id, email, status, warmup_status, provider, payload}]}` |
| GET | `/account/status` | query: `email` | `{status, warmup_status, account}` |
| GET | `/account/warmup-stats` | query: `start_date` (req), `end_date` (req), `email_acc_id` (opt) | `{emailAcc: {google_percent, microsoft_percent, other_percent, inbox_percent, spam_percent, total_warmup_sent, chart_data[]}}` |
| POST | `/account/test/vitals` | body: `accounts[]` | `{success_list: [{domain, allPass, spf, dkim, dmarc}], failure_list}` |
| POST | `/account/warmup/enable` | body: `email` | `{status}` |
| POST | `/account/warmup/pause` | body: `email` | `{status}` |
| POST | `/account/delete` | body: `email` | `{status}` |
| POST | `/account/bulk-add-regular-accounts` | body: `accounts[]` (email, smtp/imap, limits) | `{status}` |
| PUT | `/account/bulk-update` | body: `ids[]` + настройки | `{status}` |
| PATCH | `/account/bulk-update-warmup` | body: `ids[]`, `warmup_status` (ACTIVE/INACTIVE) | `{updated_count, updated_ids[]}` |
| PUT | `/account/bulk-assign-tags` | body: `ids[]`, `tag_id`, `action` (ASSIGN/UNASSIGN) | `{status}` |
| POST | `/account/bulk-reconnect` | body: `ids[]` | `{status}` |

**Реальные данные (196 аккаунтов, 3 домена):**
- `b2bconnects.info` — ~100 аккаунтов, daily_limit 3, Microsoft365
- `itstaffingnow.com` — ~50 аккаунтов, daily_limit 5
- `etservicesllc.com` — ~46 аккаунтов, daily_limit 5-10

**Warmup stats (workspace, с начала года):**
- `inbox_percent`: 99.4%
- `spam_percent`: 0.6%
- `google_percent`: 97.0%, `microsoft_percent`: 99.9%
- `total_warmup_sent`: 16 454

**Поля в `payload` аккаунта:** `name` (first/last), `daily_limit`, `sending_gap`, `warmup` (limit, reply_rate, increment), `tags[]`, `cmps[]` (кампании), `analytics` (health_scores, reply_rates, daily_counters)

---

## Unibox

| Method | Path | Параметры | Ответ |
|--------|------|-----------|-------|
| GET | `/unibox/emails` | query: `email_type` (all/received/sent), `lead`, `campaign_id`, `label`, `page_trail` | `{page_trail, data: [{id, direction, subject, body, label, lead, campaign_id, thread_id, eaccount, timestamp_created}]}` |
| GET | `/unibox/other-emails` | query: `page_trail` | `{page_trail, data: []}` |
| GET | `/unibox/emails/count/unread` | — | `{count}` |
| GET | `/unibox/campaign-emails` | query: `lead` (req, email), `campaign_id` (opt) | возвращает исходящие step-письма из кампании для лида — включая точный body холодного письма, step номер, дату отправки, вариант (A/B), sending account |
| POST | `/unibox/emails/reply` | query: `workspace_id`, body: `reply_to_id`, `subject`, `from`, `to`, `body` (HTML) | `{status, id}` |
| POST | `/unibox/emails/forward` | query: `workspace_id`, body: `from`, `to`, `reply_to_id`, `body` | `{status, id}` |
| POST | `/unibox/emails/compose` | query: `workspace_id`, body: `lead_id`, `camp_id`, `subject`, `from`, `body` | `{status, id}` |
| POST | `/unibox/threads/{thread_id}/mark-as-read` | body: `workspace_id` | `{status}` |
| POST | `/unibox/emails/save-as-draft` | body: `parent_message_id`, `from`, `subject`, `body` | `{status}` |
| DELETE | `/unibox/threads/delete` | body: `thread_id` | `{status}` |
| DELETE | `/unibox/emails/delete` | body: `message_id` | `{status}` |

**Поля email-объекта:** `id`, `direction` (IN/OUT), `message_id`, `is_unread`, `lead_id`, `campaign_id`, `from_address_email`, `to_address_json`, `subject`, `body` (html + text), `content_preview`, `thread_id`, `eaccount`, `label` (OUT_OF_OFFICE/INTERESTED/etc), `source_modified_at`

**Поля campaign-emails объекта:** `id`, `lead_id`, `lead` (email), `campaign_id`, `current_step` (номер шага), `sent_on`, `variation` (A/B), `message_id`, `subject`, `body` (plain text холодного письма), `is_text`, `eaccount` (sending account)

**Использование campaign-emails для copy analysis:**
- Позволяет вытащить точный текст холодного письма для любого лида
- Можно батчем пройти по всем INTERESTED/NOT_INTERESTED лидам из БД
- Сопоставить body письма с outcome (label) → понять какая копи конвертит
- Пример: `GET /unibox/campaign-emails?workspace_id=WS&lead=email@domain.com`
- Проверено: возвращает step 1 письмо, campaign_id опционален

---

## Webhooks

| Method | Path | Параметры | Ответ |
|--------|------|-----------|-------|
| GET | `/hook/list` | — | `{hooks: [{_id, url, name, camp_ids, evt_types, status, ignore_ooo, ignore_automatic}]}` |
| POST | `/hook/add` | body: `name`, `url`, `camp_ids[]`, `event_types[]`, `is_slack`, `secret?`, `ignore_ooo?`, `ignore_automatic?` | `{status, _id}` |
| DELETE | `/hook/del` | body: `ids[]` | `{status}` |

**События:** `FIRST_EMAIL_REPLIES`, `ALL_EMAIL_REPLIES`, `ALL_POSITIVE_REPLIES`, `LEAD_MARKED_AS_INTERESTED`, `EMAIL_SENT`, `BOUNCED_EMAIL`

**Уже настроен вебхук:** `https://n8n.srv1133622.hstgr.cloud/webhook/...` — событие `FIRST_EMAIL_REPLIES`, все кампании

---

## Tags

| Method | Path | Параметры | Ответ |
|--------|------|-----------|-------|
| GET | `/tags/list` | query: `skip`, `limit` | `[{_id, name, color, description, status}]` |
| POST | `/tags/create` | body: `name`, `color` (hex) | `{status, tag_id}` |
| PUT | `/tags/update` | body: `tag_id`, `name`, `color` | `{status}` |
| DELETE | `/tags/delete` | body: `ids[]` | `{status}` |

---

## Blocklist

| Method | Path | Параметры | Ответ |
|--------|------|-----------|-------|
| GET | `/blocklist/list` | query: `skip`, `limit` | `[{_id, value, created_by_label, created_at}]` |
| POST | `/blocklist/add/entries` | body: `entries[]` | `{status, entries_added, already_in_blocklist}` |
| POST | `/blocklist/delete/entries` | body: `entries[]` | `{status, entries_deleted}` |

---

## Email Placement Testing

| Method | Path | Параметры |
|--------|------|-----------|
| GET | `/email-placement/list/parent-tests` | query: `status`, `type`, `limit`, `page` |
| GET | `/email-placement/get/parent-test-detail` | query: `parent_test_id` |
| GET | `/email-placement/list/tests` | query: `parent_test_id` |
| GET | `/email-placement/get/test-detail` | query: `test_id` |
| GET | `/emailplacement/get/test-summary` | query: `parent_test_id` (**путь без дефиса!**) |
| GET | `/email-placement/get/test-stats` | query: `test_id` |
| GET | `/email-placement/get/recipient-providers` | — |
| POST | `/email-placement/create/parent-test` | body: `name`, `type` |
| PATCH | `/email-placement/update/parent-test` | body: `test_id` + настройки |
| DELETE | `/email-placement/delete/parent-test` | body: `ids[]` |
| POST | `/email-placement/duplicate/parent-test` | body: `parent_test_id`, `name` |

---

## Client Access

| Method | Path | Описание |
|--------|------|----------|
| GET | `/client/` | Список клиентов |
| POST | `/client` | Создать клиента |
| PUT | `/client` | Редактировать |
| PATCH | `/client` | Изменить статус |
| DELETE | `/client` | Удалить |

---

## Примеры запросов

```bash
# Проверка API ключа и workspaces
curl "https://api.plusvibe.ai/api/v1/authenticate" \
  -H "x-api-key: YOUR_KEY"

# Все активные кампании
curl "https://api.plusvibe.ai/api/v1/campaign/list-all?workspace_id=WS_ID&status=ACTIVE" \
  -H "x-api-key: YOUR_KEY"

# Общая статистика за период
curl "https://api.plusvibe.ai/api/v1/campaign/stats/all?workspace_id=WS_ID&start_date=2026-01-01&end_date=2026-03-20" \
  -H "x-api-key: YOUR_KEY"

# Лиды со статусом REPLIED
curl "https://api.plusvibe.ai/api/v1/lead/workspace-leads?workspace_id=WS_ID&status=REPLIED&limit=100" \
  -H "x-api-key: YOUR_KEY"

# Warmup статистика за период
curl "https://api.plusvibe.ai/api/v1/account/warmup-stats?workspace_id=WS_ID&start_date=2026-01-01&end_date=2026-03-20" \
  -H "x-api-key: YOUR_KEY"

# Количество лидов по статусам
curl "https://api.plusvibe.ai/api/v1/lead/count/lead-status?workspace_id=WS_ID" \
  -H "x-api-key: YOUR_KEY"
```

---

## Планируемая синхронизация → PostgreSQL

| Сущность | Endpoint | Таблица в PG | Частота |
|----------|----------|--------------|---------|
| Campaigns | `/campaign/list-all` | `campaigns` | каждый час |
| Campaign stats | `/analytics/campaign/stats` + `/campaign/stats/all` | `campaign_stats_daily` | каждый час |
| Email accounts | `/account/list` | `email_accounts` | каждый час |
| Email account analytics | `/account/list` (поле payload.analytics) | `account_stats_daily` | каждый час |
| Warmup stats | `/account/warmup-stats` | `warmup_stats_daily` | раз в 6 часов |
| Leads | `/lead/workspace-leads` | `leads` | каждый час (incremental) |
| Lead counts | `/lead/count/lead-status` | snapshot в `lead_status_snapshots` | каждый час |
| Unibox emails | webhook `EMAIL_SENT` + `ALL_EMAIL_REPLIES` | `emails` | real-time |
| Blocklist | `/blocklist/list` | `blocklist` | раз в день |
| Tags | `/tags/list` | `tags` | раз в день |
