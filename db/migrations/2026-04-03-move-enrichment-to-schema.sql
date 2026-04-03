-- Migration: move enrichment tables from public to enrichment schema
-- Date: 2026-04-03

CREATE SCHEMA IF NOT EXISTS enrichment;

ALTER TABLE public.leads_master    SET SCHEMA enrichment;
ALTER TABLE public.workspaces      SET SCHEMA enrichment;
ALTER TABLE public.workspace_leads SET SCHEMA enrichment;
