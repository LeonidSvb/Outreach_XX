-- Migration: 2026-04-05-enrichment-canonical-alignment.sql
-- Goal: additive alignment of enrichment.leads_master and enrichment.companies
-- Notes:
--   1. additive only, no destructive changes
--   2. legacy company-like columns stay in leads_master for compatibility
--   3. dynamic enrichment output continues to live in JSONB

BEGIN;

ALTER TABLE enrichment.leads_master
    ADD COLUMN IF NOT EXISTS domain TEXT,
    ADD COLUMN IF NOT EXISTS headline TEXT,
    ADD COLUMN IF NOT EXISTS seniority TEXT,
    ADD COLUMN IF NOT EXISTS state TEXT,
    ADD COLUMN IF NOT EXISTS source_file TEXT;

ALTER TABLE enrichment.companies
    ADD COLUMN IF NOT EXISTS industry TEXT,
    ADD COLUMN IF NOT EXISTS data JSONB NOT NULL DEFAULT '{}'::jsonb;

CREATE INDEX IF NOT EXISTS idx_leads_master_domain
    ON enrichment.leads_master (domain);

CREATE INDEX IF NOT EXISTS idx_leads_master_data_gin
    ON enrichment.leads_master USING GIN (data);

CREATE INDEX IF NOT EXISTS idx_companies_data_gin
    ON enrichment.companies USING GIN (data);

COMMIT;
