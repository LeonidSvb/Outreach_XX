-- Migration: 2026-04-05-enrichment-companies.sql
-- Add enrichment.companies table for domain-level enrichment data
-- Migrated from leads.db (SQLite) companies table

CREATE TABLE IF NOT EXISTS enrichment.companies (
    domain                   TEXT PRIMARY KEY,
    company_name             TEXT,
    clean_company            TEXT,
    company_website          TEXT,
    company_linkedin_url     TEXT,
    company_short_description TEXT,
    company_seo_description  TEXT,
    keywords                 TEXT,
    company_technologies     TEXT,
    employees_count          INTEGER,
    company_annual_revenue   TEXT,
    company_founded_year     INTEGER,
    company_total_funding    TEXT,
    mx_provider              TEXT,
    mx_checked_at            TIMESTAMP WITH TIME ZONE,
    website_js_type          TEXT,
    website_pages_raw        TEXT,
    website_summary          TEXT,
    website_scraped_at       TIMESTAMP WITH TIME ZONE,
    website_scrape_source    TEXT,
    primary_service          TEXT,
    sub_industry             TEXT,
    client_profile           TEXT,
    extractability           TEXT,
    extracted_at             TIMESTAMP WITH TIME ZONE,
    extraction_raw           JSONB,
    is_addressable           BOOLEAN,
    addressable_reason       TEXT,
    created_at               TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at               TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_companies_mx_provider
    ON enrichment.companies (mx_provider);

CREATE INDEX IF NOT EXISTS idx_companies_is_addressable
    ON enrichment.companies (is_addressable);
