-- Migration: 2026-04-05-db-change-audit.sql
-- Goal: preview/apply audit trail for DB change runs from the app

BEGIN;

CREATE TABLE IF NOT EXISTS enrichment.db_change_runs (
    id            SERIAL PRIMARY KEY,
    workspace_id  INT REFERENCES enrichment.workspaces(id) ON DELETE SET NULL,
    source_type   TEXT NOT NULL,
    source_ref    TEXT,
    dry_run       BOOLEAN NOT NULL DEFAULT FALSE,
    rows_scanned  INT NOT NULL DEFAULT 0,
    rows_changed  INT NOT NULL DEFAULT 0,
    status        TEXT NOT NULL DEFAULT 'done',
    summary_json  JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS enrichment.db_change_items (
    id           BIGSERIAL PRIMARY KEY,
    run_id       INT NOT NULL REFERENCES enrichment.db_change_runs(id) ON DELETE CASCADE,
    entity_type  TEXT NOT NULL,
    entity_id    TEXT NOT NULL,
    target       TEXT NOT NULL,
    field_key    TEXT NOT NULL,
    old_value    JSONB,
    new_value    JSONB,
    action       TEXT NOT NULL DEFAULT 'update'
);

CREATE INDEX IF NOT EXISTS idx_db_change_runs_created_at
    ON enrichment.db_change_runs (created_at DESC);

CREATE INDEX IF NOT EXISTS idx_db_change_runs_workspace_id
    ON enrichment.db_change_runs (workspace_id);

CREATE INDEX IF NOT EXISTS idx_db_change_items_run_id
    ON enrichment.db_change_items (run_id);

CREATE INDEX IF NOT EXISTS idx_db_change_items_entity
    ON enrichment.db_change_items (entity_type, entity_id);

COMMIT;
