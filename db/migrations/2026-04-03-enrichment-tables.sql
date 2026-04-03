-- Migration: enrichment tables for WebScraping_Exa / Clay-like enrichment system
-- Date: 2026-04-03
-- Schema: outreach

-- All unique leads across all sources. Key: email.
-- Global enrichments (MX check, website_summary, etc.) go into data jsonb.
-- New global enrichments = just add a key to data, no ALTER TABLE needed.
CREATE TABLE IF NOT EXISTS leads_master (
    email                     TEXT PRIMARY KEY,
    first_name                TEXT,
    last_name                 TEXT,
    company_name              TEXT,
    company_website           TEXT,
    company_linkedin          TEXT,
    linkedin_url              TEXT,
    title                     TEXT,
    city                      TEXT,
    country                   TEXT,
    employees_count           INT,
    industry                  TEXT,
    keywords                  TEXT,
    company_revenue           TEXT,
    company_short_description TEXT,
    data                      JSONB NOT NULL DEFAULT '{}',
    source                    TEXT NOT NULL DEFAULT 'apollo',
    first_seen_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at                TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- One workspace = one project / CSV batch.
-- Examples: "US Recruiting 5k", "EU Logistics Mar 2026"
CREATE TABLE IF NOT EXISTS workspaces (
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL,
    file_name   TEXT,
    source      TEXT NOT NULL DEFAULT 'apollo',
    total_rows  INT,
    notes       TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Working table: lead in the context of a specific workspace.
-- Contextual enrichments (icebreaker, icp_score, custom fields) go into data jsonb.
-- Same lead can exist in multiple workspaces independently.
CREATE TABLE IF NOT EXISTS workspace_leads (
    id           SERIAL PRIMARY KEY,
    workspace_id INT NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    email        TEXT NOT NULL REFERENCES leads_master(email),
    data         JSONB NOT NULL DEFAULT '{}',
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (workspace_id, email)
);

CREATE INDEX IF NOT EXISTS idx_workspace_leads_workspace ON workspace_leads(workspace_id);
CREATE INDEX IF NOT EXISTS idx_workspace_leads_email ON workspace_leads(email);
