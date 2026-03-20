-- Outreach XX — PostgreSQL Views
-- Run against: outreach database
-- Updated: 2026-03-20

-- 1. Campaign performance: reply rates, bounce rate, positive rate
CREATE OR REPLACE VIEW v_campaign_performance AS
SELECT
  id AS campaign_id,
  name AS campaign_name,
  status,
  lead_count,
  lead_contacted_count AS contacted,
  sent_count AS emails_sent,
  replied_count AS total_replies,
  positive_reply_count AS positive_replies,
  (replied_count - positive_reply_count - COALESCE(negative_reply_count,0) - COALESCE(neutral_reply_count,0)) AS auto_replies,
  bounced_count AS bounces,
  CASE WHEN lead_contacted_count > 0
    THEN ROUND(replied_count::numeric / lead_contacted_count * 100, 2) END AS reply_rate_pct,
  CASE WHEN replied_count > 0
    THEN ROUND(positive_reply_count::numeric / replied_count * 100, 2) END AS positive_of_replies_pct,
  CASE WHEN lead_contacted_count > 0
    THEN ROUND(positive_reply_count::numeric / lead_contacted_count * 100, 2) END AS positive_rate_pct,
  CASE WHEN lead_contacted_count > 0
    THEN ROUND(bounced_count::numeric / lead_contacted_count * 100, 2) END AS bounce_rate_pct,
  last_lead_sent,
  last_lead_replied,
  created_at
FROM campaigns
WHERE deleted_from_source_at IS NULL
ORDER BY lead_contacted_count DESC;

-- 2. Daily sending volume from campaign_stats snapshots
CREATE OR REPLACE VIEW v_daily_sending_volume AS
SELECT
  snapshot_date,
  SUM(sent_count) AS total_sent,
  SUM(replied_count) AS total_replies,
  SUM(positive_reply_count) AS total_positive,
  SUM(bounced_count) AS total_bounced,
  COUNT(DISTINCT campaign_id) AS active_campaigns,
  CASE WHEN SUM(sent_count) > 0
    THEN ROUND(SUM(replied_count)::numeric / SUM(sent_count) * 100, 2) END AS reply_rate_pct,
  CASE WHEN SUM(sent_count) > 0
    THEN ROUND(SUM(bounced_count)::numeric / SUM(sent_count) * 100, 2) END AS bounce_rate_pct
FROM campaign_stats
GROUP BY snapshot_date
ORDER BY snapshot_date DESC;

-- 3. Deliverability by domain (from email_accounts current state)
CREATE OR REPLACE VIEW v_deliverability_by_domain AS
SELECT
  domain,
  COUNT(*) AS total_accounts,
  COUNT(*) FILTER (WHERE status = 'ACTIVE') AS active_accounts,
  COUNT(*) FILTER (WHERE warmup_status = 'ACTIVE') AS warmup_active,
  ROUND(AVG(health_7d), 2) AS avg_health_7d,
  MIN(health_7d) AS min_health_7d,
  COUNT(*) FILTER (WHERE health_7d < 95) AS accounts_below_95,
  COUNT(*) FILTER (WHERE health_7d < 90) AS accounts_below_90,
  SUM(email_sent_today) AS sent_today,
  SUM(warmup_sent_today) AS warmup_today,
  SUM(daily_limit) AS total_daily_limit,
  ROUND(SUM(email_sent_today)::numeric / NULLIF(SUM(daily_limit), 0) * 100, 1) AS capacity_used_pct
FROM email_accounts
WHERE deleted_from_source_at IS NULL AND domain IS NOT NULL
GROUP BY domain
ORDER BY domain;

-- 4. Account health — all accounts with health flags
CREATE OR REPLACE VIEW v_account_health AS
SELECT
  email,
  domain,
  provider,
  status,
  warmup_status,
  daily_limit,
  email_sent_today,
  warmup_sent_today,
  health_7d,
  bounce_rate_3d,
  CASE
    WHEN health_7d < 90 THEN 'CRITICAL'
    WHEN health_7d < 95 THEN 'WARNING'
    WHEN health_7d IS NULL THEN 'UNKNOWN'
    ELSE 'OK'
  END AS health_status,
  ROUND(email_sent_today::numeric / NULLIF(daily_limit, 0) * 100, 1) AS daily_capacity_used_pct,
  synced_at
FROM email_accounts
WHERE deleted_from_source_at IS NULL
ORDER BY health_7d ASC NULLS LAST;

-- 5. Leads funnel — counts by status across all campaigns
CREATE OR REPLACE VIEW v_leads_funnel AS
SELECT
  status,
  label,
  COUNT(*) AS count,
  ROUND(COUNT(*)::numeric / SUM(COUNT(*)) OVER () * 100, 2) AS pct_of_total
FROM leads
WHERE deleted_from_source_at IS NULL
GROUP BY status, label
ORDER BY count DESC;

-- 6. Leads funnel by campaign
CREATE OR REPLACE VIEW v_leads_funnel_by_campaign AS
SELECT
  campaign_name,
  campaign_id,
  COUNT(*) AS total_leads,
  COUNT(*) FILTER (WHERE status = 'NOT_CONTACTED') AS not_contacted,
  COUNT(*) FILTER (WHERE status = 'CONTACTED') AS contacted,
  COUNT(*) FILTER (WHERE status = 'REPLIED') AS replied,
  COUNT(*) FILTER (WHERE status = 'COMPLETED') AS completed,
  COUNT(*) FILTER (WHERE status = 'BOUNCED') AS bounced,
  COUNT(*) FILTER (WHERE status = 'SKIPPED') AS skipped,
  COUNT(*) FILTER (WHERE label = 'INTERESTED') AS interested,
  COUNT(*) FILTER (WHERE label = 'NOT_INTERESTED') AS not_interested,
  COUNT(*) FILTER (WHERE label = 'OUT_OF_OFFICE') AS out_of_office,
  ROUND(COUNT(*) FILTER (WHERE status = 'REPLIED')::numeric /
    NULLIF(COUNT(*) FILTER (WHERE status != 'NOT_CONTACTED'), 0) * 100, 2) AS reply_rate_pct
FROM leads
WHERE deleted_from_source_at IS NULL
GROUP BY campaign_name, campaign_id
ORDER BY total_leads DESC;

-- 7. Domain sending capacity
CREATE OR REPLACE VIEW v_domain_capacity AS
SELECT
  domain,
  COUNT(*) FILTER (WHERE status = 'ACTIVE') AS active_accounts,
  SUM(daily_limit) FILTER (WHERE status = 'ACTIVE') AS max_daily_capacity,
  SUM(email_sent_today) AS sent_today,
  SUM(daily_limit) FILTER (WHERE status = 'ACTIVE') - SUM(email_sent_today) AS remaining_today,
  ROUND(SUM(email_sent_today)::numeric / NULLIF(SUM(daily_limit) FILTER (WHERE status = 'ACTIVE'), 0) * 100, 1) AS utilization_pct
FROM email_accounts
WHERE deleted_from_source_at IS NULL
GROUP BY domain
ORDER BY max_daily_capacity DESC;

-- 8. Replied leads — для follow-up
CREATE OR REPLACE VIEW v_replied_leads AS
SELECT
  l.email,
  l.first_name,
  l.last_name,
  l.job_title,
  l.company_name,
  l.campaign_name,
  l.status,
  l.label,
  l.last_sent_at,
  l.modified_at AS last_activity,
  l.linkedin_person_url,
  l.email_acc_name AS sent_from
FROM leads l
WHERE l.status = 'REPLIED'
  AND l.deleted_from_source_at IS NULL
ORDER BY l.modified_at DESC;

-- 9. Weekly summary
CREATE OR REPLACE VIEW v_weekly_summary AS
SELECT
  DATE_TRUNC('week', snapshot_date) AS week_start,
  SUM(sent_count) AS total_sent,
  SUM(replied_count) AS total_replies,
  SUM(positive_reply_count) AS positive_replies,
  SUM(bounced_count) AS bounces,
  CASE WHEN SUM(sent_count) > 0
    THEN ROUND(SUM(replied_count)::numeric / SUM(sent_count) * 100, 2) END AS reply_rate_pct,
  CASE WHEN SUM(replied_count) > 0
    THEN ROUND(SUM(positive_reply_count)::numeric / SUM(replied_count) * 100, 2) END AS positive_of_replies_pct,
  CASE WHEN SUM(sent_count) > 0
    THEN ROUND(SUM(bounced_count)::numeric / SUM(sent_count) * 100, 2) END AS bounce_rate_pct
FROM campaign_stats
GROUP BY DATE_TRUNC('week', snapshot_date)
ORDER BY week_start DESC;

-- 10. Campaign pace — сколько лидов осталось и темп
CREATE OR REPLACE VIEW v_campaign_pace AS
SELECT
  id AS campaign_id,
  name AS campaign_name,
  status,
  lead_count AS total_leads,
  lead_contacted_count AS contacted,
  (lead_count - lead_contacted_count - completed_lead_count) AS remaining_to_contact,
  daily_limit AS campaign_daily_limit,
  CASE WHEN daily_limit > 0 AND (lead_count - lead_contacted_count) > 0
    THEN CEIL((lead_count - lead_contacted_count - completed_lead_count)::numeric / daily_limit)
  END AS est_days_to_complete,
  sequence_steps,
  schedule_from_time,
  schedule_to_time,
  schedule_timezone,
  last_lead_sent
FROM campaigns
WHERE deleted_from_source_at IS NULL
  AND status IN ('ACTIVE', 'PAUSED')
ORDER BY remaining_to_contact DESC;

-- 11. Performance by tag (reply rate, positive rate, auto reply rate, bounce rate)
-- Requires: tags, account_tags tables
CREATE OR REPLACE VIEW v_performance_by_tag AS ...
-- See full definition in db/views.sql on VPS
