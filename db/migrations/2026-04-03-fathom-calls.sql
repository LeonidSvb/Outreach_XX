-- Fathom Video call recordings
-- Each row = one recorded meeting (ALL calls, not just Cal.com bookings)
-- Links to calcom_bookings / leads via external_invitee_email

CREATE TABLE IF NOT EXISTS public.fathom_calls (
    recording_id            INT PRIMARY KEY,
    meeting_title           TEXT,
    url                     TEXT,
    share_url               TEXT,
    scheduled_start_time    TIMESTAMPTZ,
    scheduled_end_time      TIMESTAMPTZ,
    recording_start_time    TIMESTAMPTZ,
    recording_end_time      TIMESTAMPTZ,
    duration_minutes        INT,              -- calculated: recording_end - recording_start
    external_invitee_email  TEXT,             -- first external (client) attendee
    external_invitee_name   TEXT,
    all_invitees            JSONB,            -- full calendar_invitees array
    has_summary             BOOLEAN DEFAULT FALSE,
    has_transcript          BOOLEAN DEFAULT FALSE,
    summary                 TEXT,
    action_items            JSONB,
    crm_matches             JSONB,
    cal_created_at          TIMESTAMPTZ,
    synced_at               TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS fathom_calls_external_email_idx  ON public.fathom_calls (external_invitee_email);
CREATE INDEX IF NOT EXISTS fathom_calls_start_time_idx      ON public.fathom_calls (recording_start_time DESC);
CREATE INDEX IF NOT EXISTS fathom_calls_has_summary_idx     ON public.fathom_calls (has_summary);
