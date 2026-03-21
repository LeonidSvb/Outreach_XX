-- Migration: 2026-03-22
-- Description: Add enrichment (JSONB) and source columns to leads table
-- Executed: 2026-03-22 manually via psql on VPS
-- Reason: Prepare leads table for multi-source imports and flexible enrichment data

ALTER TABLE leads
  ADD COLUMN IF NOT EXISTS enrichment JSONB DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS source VARCHAR(50) DEFAULT 'plusvibe';

-- Set source for all existing leads (they came from PlusVibe sync)
UPDATE leads SET source = 'plusvibe' WHERE source IS NULL;

-- enrichment stores flexible per-provider data, e.g.:
-- {"deliverability": "valid", "millionverifier": {"result": "ok", "score": 99}}
