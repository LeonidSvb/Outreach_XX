-- Cal.com bookings sync table
-- Each booking = one scheduled/cancelled/accepted call
-- Links to leads via attendee_email → public.leads.email

CREATE TABLE IF NOT EXISTS public.calcom_bookings (
    id              INT PRIMARY KEY,          -- Cal.com numeric booking ID
    uid             TEXT UNIQUE NOT NULL,      -- Cal.com uid (used for reschedule tracking)
    event_type_id   INT,
    title           TEXT,
    status          TEXT,                      -- ACCEPTED, CANCELLED, NO_SHOW, PENDING
    start_time      TIMESTAMPTZ,
    end_time        TIMESTAMPTZ,
    attendee_email  TEXT,                      -- first (guest) attendee email
    attendee_name   TEXT,
    attendee_tz     TEXT,
    company_name    TEXT,                      -- from booking form responses
    website         TEXT,
    revenue         TEXT,
    qualification   TEXT,
    video_call_url  TEXT,
    from_reschedule TEXT,                      -- uid of original booking if rescheduled
    cancelled_by    TEXT,
    rescheduled_by  TEXT,
    cal_created_at  TIMESTAMPTZ,
    synced_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS calcom_bookings_attendee_email_idx ON public.calcom_bookings (attendee_email);
CREATE INDEX IF NOT EXISTS calcom_bookings_start_time_idx     ON public.calcom_bookings (start_time DESC);
CREATE INDEX IF NOT EXISTS calcom_bookings_status_idx         ON public.calcom_bookings (status);
