-- Migration: enrichment tasks table
-- Date: 2026-04-03

CREATE TABLE enrichment.tasks (
    id           SERIAL PRIMARY KEY,
    workspace_id INT REFERENCES enrichment.workspaces(id) ON DELETE CASCADE,
    type         TEXT NOT NULL DEFAULT 'enrichment',
    status       TEXT NOT NULL DEFAULT 'pending',
    payload      JSONB NOT NULL DEFAULT '{}',
    total        INT DEFAULT 0,
    processed    INT DEFAULT 0,
    errors       INT DEFAULT 0,
    error_msg    TEXT,
    created_at   TIMESTAMPTZ DEFAULT NOW(),
    started_at   TIMESTAMPTZ,
    finished_at  TIMESTAMPTZ
);

CREATE INDEX ON enrichment.tasks(status);
CREATE INDEX ON enrichment.tasks(workspace_id);
