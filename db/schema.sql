--
-- PostgreSQL database dump
--

\restrict h0K7a6yjhcN1xjwycJvnzxRJkgSDwkR7gGAxq7YuSbTtW9Ju1KenA9dMcf3psol

-- Dumped from database version 16.13 (Debian 16.13-1.pgdg13+1)
-- Dumped by pg_dump version 16.13 (Debian 16.13-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: enrichment; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA enrichment;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: leads_master; Type: TABLE; Schema: enrichment; Owner: -
--

CREATE TABLE enrichment.leads_master (
    email text NOT NULL,
    first_name text,
    last_name text,
    company_name text,
    company_website text,
    company_linkedin text,
    linkedin_url text,
    title text,
    city text,
    country text,
    employees_count integer,
    industry text,
    keywords text,
    company_revenue text,
    company_short_description text,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    source text DEFAULT 'apollo'::text NOT NULL,
    first_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: tasks; Type: TABLE; Schema: enrichment; Owner: -
--

CREATE TABLE enrichment.tasks (
    id integer NOT NULL,
    workspace_id integer,
    type text DEFAULT 'enrichment'::text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    total integer DEFAULT 0,
    processed integer DEFAULT 0,
    errors integer DEFAULT 0,
    error_msg text,
    created_at timestamp with time zone DEFAULT now(),
    started_at timestamp with time zone,
    finished_at timestamp with time zone
);


--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: enrichment; Owner: -
--

CREATE SEQUENCE enrichment.tasks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: enrichment; Owner: -
--

ALTER SEQUENCE enrichment.tasks_id_seq OWNED BY enrichment.tasks.id;


--
-- Name: workspace_leads; Type: TABLE; Schema: enrichment; Owner: -
--

CREATE TABLE enrichment.workspace_leads (
    id integer NOT NULL,
    workspace_id integer NOT NULL,
    email text NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: workspace_leads_id_seq; Type: SEQUENCE; Schema: enrichment; Owner: -
--

CREATE SEQUENCE enrichment.workspace_leads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workspace_leads_id_seq; Type: SEQUENCE OWNED BY; Schema: enrichment; Owner: -
--

ALTER SEQUENCE enrichment.workspace_leads_id_seq OWNED BY enrichment.workspace_leads.id;


--
-- Name: workspaces; Type: TABLE; Schema: enrichment; Owner: -
--

CREATE TABLE enrichment.workspaces (
    id integer NOT NULL,
    name text NOT NULL,
    file_name text,
    source text DEFAULT 'apollo'::text NOT NULL,
    total_rows integer,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: workspaces_id_seq; Type: SEQUENCE; Schema: enrichment; Owner: -
--

CREATE SEQUENCE enrichment.workspaces_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: workspaces_id_seq; Type: SEQUENCE OWNED BY; Schema: enrichment; Owner: -
--

ALTER SEQUENCE enrichment.workspaces_id_seq OWNED BY enrichment.workspaces.id;


--
-- Name: account_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_stats (
    id integer NOT NULL,
    account_id character varying(50) NOT NULL,
    email character varying(255),
    snapshot_date date NOT NULL,
    email_sent_today integer,
    warmup_sent_today integer,
    health_7d numeric(6,2),
    bounce_rate_3d numeric(6,2),
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: account_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.account_stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: account_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.account_stats_id_seq OWNED BY public.account_stats.id;


--
-- Name: account_tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account_tags (
    account_id character varying(50) NOT NULL,
    tag_id character varying(50) NOT NULL
);


--
-- Name: calcom_bookings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calcom_bookings (
    id integer NOT NULL,
    uid text NOT NULL,
    event_type_id integer,
    title text,
    status text,
    start_time timestamp with time zone,
    end_time timestamp with time zone,
    attendee_email text,
    attendee_name text,
    attendee_tz text,
    company_name text,
    website text,
    revenue text,
    qualification text,
    video_call_url text,
    from_reschedule text,
    cancelled_by text,
    rescheduled_by text,
    cal_created_at timestamp with time zone,
    synced_at timestamp with time zone DEFAULT now()
);


--
-- Name: campaign_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaign_stats (
    id integer NOT NULL,
    campaign_id character varying(50) NOT NULL,
    campaign_name text,
    snapshot_date date NOT NULL,
    lead_count integer,
    completed_lead_count integer,
    lead_contacted_count integer,
    sent_count integer,
    unique_opened_count integer,
    replied_count integer,
    bounced_count integer,
    unsubscribed_count integer,
    positive_reply_count integer,
    opportunity_val numeric(10,2),
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: campaign_stats_daily; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaign_stats_daily (
    id integer NOT NULL,
    campaign_id character varying(50) NOT NULL,
    campaign_name text,
    stat_date date NOT NULL,
    sent_count integer DEFAULT 0,
    new_lead_contacted_count integer DEFAULT 0,
    replied_count integer DEFAULT 0,
    bounced_count integer DEFAULT 0,
    positive_reply_count integer DEFAULT 0,
    unique_opened_count integer DEFAULT 0,
    opportunity_val numeric(10,2) DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: campaign_stats_daily_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.campaign_stats_daily_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaign_stats_daily_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.campaign_stats_daily_id_seq OWNED BY public.campaign_stats_daily.id;


--
-- Name: campaign_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.campaign_stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaign_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.campaign_stats_id_seq OWNED BY public.campaign_stats.id;


--
-- Name: campaigns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campaigns (
    id character varying(50) NOT NULL,
    name text NOT NULL,
    status character varying(20),
    campaign_type character varying(20),
    parent_camp_id character varying(50),
    lead_count integer,
    sent_count integer,
    unique_opened_count integer,
    replied_count integer,
    bounced_count integer,
    unsubscribed_count integer,
    positive_reply_count integer,
    negative_reply_count integer,
    neutral_reply_count integer,
    lead_contacted_count integer,
    completed_lead_count integer,
    open_rate numeric(6,2),
    replied_rate numeric(6,2),
    opportunity_val numeric(10,2),
    daily_limit integer,
    schedule_timezone character varying(50),
    schedule_from_time character varying(10),
    schedule_to_time character varying(10),
    stop_on_lead_replied boolean,
    sequence_steps integer,
    created_at timestamp with time zone,
    modified_at timestamp with time zone,
    last_lead_sent timestamp with time zone,
    last_lead_replied timestamp with time zone,
    deleted_from_source_at timestamp with time zone,
    synced_at timestamp with time zone DEFAULT now()
);


--
-- Name: email_accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_accounts (
    id character varying(50) NOT NULL,
    email character varying(255) NOT NULL,
    domain character varying(100),
    provider character varying(50),
    status character varying(20),
    warmup_status character varying(20),
    daily_limit integer,
    sending_gap_min integer,
    warmup_limit integer,
    health_7d numeric(6,2),
    bounce_rate_3d numeric(6,2),
    email_sent_today integer,
    warmup_sent_today integer,
    warmup_enabled_at timestamp with time zone,
    created_at timestamp with time zone,
    modified_at timestamp with time zone,
    deleted_from_source_at timestamp with time zone,
    synced_at timestamp with time zone DEFAULT now()
);


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emails (
    id character varying(100) NOT NULL,
    thread_id character varying(100),
    campaign_id character varying(50),
    lead_id character varying(50),
    lead_email character varying(255),
    from_email character varying(255),
    sending_account character varying(255),
    subject text,
    body_text text,
    direction character varying(10),
    label character varying(50),
    is_unread boolean DEFAULT false,
    sentiment character varying(20),
    event_type character varying(50),
    sent_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    step_number integer,
    source character varying(20) DEFAULT 'api_sync'::character varying,
    zoho_note_id character varying(50)
);


--
-- Name: fathom_calls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fathom_calls (
    recording_id integer NOT NULL,
    meeting_title text,
    url text,
    share_url text,
    scheduled_start_time timestamp with time zone,
    scheduled_end_time timestamp with time zone,
    recording_start_time timestamp with time zone,
    recording_end_time timestamp with time zone,
    duration_minutes integer,
    external_invitee_email text,
    external_invitee_name text,
    all_invitees jsonb,
    has_summary boolean DEFAULT false,
    has_transcript boolean DEFAULT false,
    summary text,
    action_items jsonb,
    crm_matches jsonb,
    cal_created_at timestamp with time zone,
    synced_at timestamp with time zone DEFAULT now()
);


--
-- Name: lead_status_counts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lead_status_counts (
    id integer NOT NULL,
    snapshot_at timestamp with time zone NOT NULL,
    status character varying(30) NOT NULL,
    count integer NOT NULL,
    campaign_id character varying(50)
);


--
-- Name: lead_status_counts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.lead_status_counts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lead_status_counts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lead_status_counts_id_seq OWNED BY public.lead_status_counts.id;


--
-- Name: leads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.leads (
    id character varying(50) NOT NULL,
    campaign_id character varying(50),
    campaign_name text,
    email character varying(255),
    first_name character varying(100),
    last_name character varying(100),
    job_title character varying(255),
    company_name character varying(255),
    company_website character varying(500),
    phone_number character varying(50),
    linkedin_person_url character varying(500),
    city character varying(100),
    country character varying(100),
    status character varying(30),
    label character varying(100),
    email_acc_name character varying(255),
    sent_step integer,
    total_steps integer,
    replied_count integer,
    opened_count integer,
    mx character varying(50),
    notes text,
    bounce_msg text,
    last_sent_at timestamp with time zone,
    next_email_time timestamp with time zone,
    deleted_from_source_at timestamp with time zone,
    created_at timestamp with time zone,
    modified_at timestamp with time zone,
    synced_at timestamp with time zone DEFAULT now(),
    zoho_contact_id character varying(50),
    enrichment jsonb DEFAULT '{}'::jsonb,
    source character varying(50) DEFAULT 'plusvibe'::character varying
);


--
-- Name: sync_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sync_log (
    id integer NOT NULL,
    sync_type character varying(50) NOT NULL,
    started_at timestamp with time zone NOT NULL,
    finished_at timestamp with time zone,
    records_processed integer DEFAULT 0,
    records_upserted integer DEFAULT 0,
    records_deleted integer DEFAULT 0,
    status character varying(20),
    error_message text
);


--
-- Name: sync_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sync_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sync_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sync_log_id_seq OWNED BY public.sync_log.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    color character varying(20),
    description text,
    synced_at timestamp with time zone DEFAULT now()
);


--
-- Name: v_account_health; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_account_health AS
 SELECT email,
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
            WHEN (health_7d < (90)::numeric) THEN 'CRITICAL'::text
            WHEN (health_7d < (95)::numeric) THEN 'WARNING'::text
            WHEN (health_7d IS NULL) THEN 'UNKNOWN'::text
            ELSE 'OK'::text
        END AS health_status,
    round((((email_sent_today)::numeric / (NULLIF(daily_limit, 0))::numeric) * (100)::numeric), 1) AS daily_capacity_used_pct,
    synced_at
   FROM public.email_accounts
  WHERE (deleted_from_source_at IS NULL)
  ORDER BY health_7d;


--
-- Name: v_campaign_pace; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_campaign_pace AS
 SELECT id AS campaign_id,
    name AS campaign_name,
    status,
    lead_count AS total_leads,
    lead_contacted_count AS contacted,
    ((lead_count - lead_contacted_count) - completed_lead_count) AS remaining_to_contact,
    daily_limit AS campaign_daily_limit,
        CASE
            WHEN ((daily_limit > 0) AND ((lead_count - lead_contacted_count) > 0)) THEN ceil(((((lead_count - lead_contacted_count) - completed_lead_count))::numeric / (daily_limit)::numeric))
            ELSE NULL::numeric
        END AS est_days_to_complete,
    sequence_steps,
    schedule_from_time,
    schedule_to_time,
    schedule_timezone,
    last_lead_sent
   FROM public.campaigns
  WHERE ((deleted_from_source_at IS NULL) AND ((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'PAUSED'::character varying])::text[])))
  ORDER BY ((lead_count - lead_contacted_count) - completed_lead_count) DESC;


--
-- Name: v_campaign_performance; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_campaign_performance AS
 SELECT id AS campaign_id,
    name AS campaign_name,
    status,
    lead_count,
    lead_contacted_count AS contacted,
    sent_count AS emails_sent,
    replied_count AS total_replies,
    positive_reply_count AS positive_replies,
    (((replied_count - positive_reply_count) - COALESCE(negative_reply_count, 0)) - COALESCE(neutral_reply_count, 0)) AS auto_replies,
    bounced_count AS bounces,
        CASE
            WHEN (lead_contacted_count > 0) THEN round((((replied_count)::numeric / (lead_contacted_count)::numeric) * (100)::numeric), 2)
            ELSE NULL::numeric
        END AS reply_rate_pct,
        CASE
            WHEN (replied_count > 0) THEN round((((positive_reply_count)::numeric / (replied_count)::numeric) * (100)::numeric), 2)
            ELSE NULL::numeric
        END AS positive_of_replies_pct,
        CASE
            WHEN (lead_contacted_count > 0) THEN round((((positive_reply_count)::numeric / (lead_contacted_count)::numeric) * (100)::numeric), 2)
            ELSE NULL::numeric
        END AS positive_rate_pct,
        CASE
            WHEN (lead_contacted_count > 0) THEN round((((bounced_count)::numeric / (lead_contacted_count)::numeric) * (100)::numeric), 2)
            ELSE NULL::numeric
        END AS bounce_rate_pct,
    last_lead_sent,
    last_lead_replied,
    created_at
   FROM public.campaigns
  WHERE (deleted_from_source_at IS NULL)
  ORDER BY lead_contacted_count DESC;


--
-- Name: v_daily_sending_volume; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_daily_sending_volume AS
 SELECT snapshot_date,
    sum(sent_count) AS total_sent,
    sum(replied_count) AS total_replies,
    sum(positive_reply_count) AS total_positive,
    sum(bounced_count) AS total_bounced,
    count(DISTINCT campaign_id) AS active_campaigns,
        CASE
            WHEN (sum(sent_count) > 0) THEN round((((sum(replied_count))::numeric / (sum(sent_count))::numeric) * (100)::numeric), 2)
            ELSE NULL::numeric
        END AS reply_rate_pct,
        CASE
            WHEN (sum(sent_count) > 0) THEN round((((sum(bounced_count))::numeric / (sum(sent_count))::numeric) * (100)::numeric), 2)
            ELSE NULL::numeric
        END AS bounce_rate_pct
   FROM public.campaign_stats
  GROUP BY snapshot_date
  ORDER BY snapshot_date DESC;


--
-- Name: v_deliverability_by_domain; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_deliverability_by_domain AS
 SELECT domain,
    count(*) AS total_accounts,
    count(*) FILTER (WHERE ((status)::text = 'ACTIVE'::text)) AS active_accounts,
    count(*) FILTER (WHERE ((warmup_status)::text = 'ACTIVE'::text)) AS warmup_active,
    round(avg(health_7d), 2) AS avg_health_7d,
    min(health_7d) AS min_health_7d,
    count(*) FILTER (WHERE (health_7d < (95)::numeric)) AS accounts_below_95,
    count(*) FILTER (WHERE (health_7d < (90)::numeric)) AS accounts_below_90,
    sum(email_sent_today) AS sent_today,
    sum(warmup_sent_today) AS warmup_today,
    sum(daily_limit) AS total_daily_limit,
    round((((sum(email_sent_today))::numeric / (NULLIF(sum(daily_limit), 0))::numeric) * (100)::numeric), 1) AS capacity_used_pct
   FROM public.email_accounts
  WHERE ((deleted_from_source_at IS NULL) AND (domain IS NOT NULL))
  GROUP BY domain
  ORDER BY domain;


--
-- Name: v_deliverability_by_tag; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_deliverability_by_tag AS
 SELECT t.name AS tag_name,
    t.description AS tag_description,
    count(ea.id) AS total_accounts,
    count(ea.id) FILTER (WHERE ((ea.status)::text = 'ACTIVE'::text)) AS active_accounts,
    round(avg(ea.health_7d), 2) AS avg_health_7d,
    min(ea.health_7d) AS min_health_7d,
    count(ea.id) FILTER (WHERE (ea.health_7d < (95)::numeric)) AS accounts_below_95,
    count(ea.id) FILTER (WHERE (ea.health_7d < (90)::numeric)) AS accounts_below_90,
    sum(ea.email_sent_today) AS sent_today,
    sum(ea.daily_limit) AS total_daily_limit,
    round((((sum(ea.email_sent_today))::numeric / (NULLIF(sum(ea.daily_limit), 0))::numeric) * (100)::numeric), 1) AS utilization_pct,
    count(ea.id) FILTER (WHERE ((ea.provider)::text ~~ '%GOOGLE%'::text)) AS google_accounts,
    count(ea.id) FILTER (WHERE ((ea.provider)::text ~~ '%MICROSOFT%'::text)) AS microsoft_accounts,
    round(avg(ea.health_7d) FILTER (WHERE ((ea.provider)::text ~~ '%GOOGLE%'::text)), 2) AS google_avg_health,
    round(avg(ea.health_7d) FILTER (WHERE ((ea.provider)::text ~~ '%MICROSOFT%'::text)), 2) AS microsoft_avg_health
   FROM ((public.tags t
     JOIN public.account_tags at ON (((t.id)::text = (at.tag_id)::text)))
     JOIN public.email_accounts ea ON (((at.account_id)::text = (ea.id)::text)))
  WHERE (ea.deleted_from_source_at IS NULL)
  GROUP BY t.id, t.name, t.description
  ORDER BY (count(ea.id)) DESC;


--
-- Name: v_domain_capacity; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_domain_capacity AS
 SELECT domain,
    count(*) FILTER (WHERE ((status)::text = 'ACTIVE'::text)) AS active_accounts,
    sum(daily_limit) FILTER (WHERE ((status)::text = 'ACTIVE'::text)) AS max_daily_capacity,
    sum(email_sent_today) AS sent_today,
    (sum(daily_limit) FILTER (WHERE ((status)::text = 'ACTIVE'::text)) - sum(email_sent_today)) AS remaining_today,
    round((((sum(email_sent_today))::numeric / (NULLIF(sum(daily_limit) FILTER (WHERE ((status)::text = 'ACTIVE'::text)), 0))::numeric) * (100)::numeric), 1) AS utilization_pct
   FROM public.email_accounts
  WHERE (deleted_from_source_at IS NULL)
  GROUP BY domain
  ORDER BY (sum(daily_limit) FILTER (WHERE ((status)::text = 'ACTIVE'::text))) DESC;


--
-- Name: v_leads_funnel; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_leads_funnel AS
 SELECT status,
    label,
    count(*) AS count,
    round((((count(*))::numeric / sum(count(*)) OVER ()) * (100)::numeric), 2) AS pct_of_total
   FROM public.leads
  WHERE (deleted_from_source_at IS NULL)
  GROUP BY status, label
  ORDER BY (count(*)) DESC;


--
-- Name: v_leads_funnel_by_campaign; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_leads_funnel_by_campaign AS
 SELECT campaign_name,
    campaign_id,
    count(*) AS total_leads,
    count(*) FILTER (WHERE ((status)::text = 'NOT_CONTACTED'::text)) AS not_contacted,
    count(*) FILTER (WHERE ((status)::text = 'CONTACTED'::text)) AS contacted,
    count(*) FILTER (WHERE ((status)::text = 'REPLIED'::text)) AS replied,
    count(*) FILTER (WHERE ((status)::text = 'COMPLETED'::text)) AS completed,
    count(*) FILTER (WHERE ((status)::text = 'BOUNCED'::text)) AS bounced,
    count(*) FILTER (WHERE ((status)::text = 'SKIPPED'::text)) AS skipped,
    count(*) FILTER (WHERE ((label)::text = 'INTERESTED'::text)) AS interested,
    count(*) FILTER (WHERE ((label)::text = 'NOT_INTERESTED'::text)) AS not_interested,
    count(*) FILTER (WHERE ((label)::text = 'OUT_OF_OFFICE'::text)) AS out_of_office,
    round((((count(*) FILTER (WHERE ((status)::text = 'REPLIED'::text)))::numeric / (NULLIF(count(*) FILTER (WHERE ((status)::text <> 'NOT_CONTACTED'::text)), 0))::numeric) * (100)::numeric), 2) AS reply_rate_pct
   FROM public.leads
  WHERE (deleted_from_source_at IS NULL)
  GROUP BY campaign_name, campaign_id
  ORDER BY (count(*)) DESC;


--
-- Name: v_performance_by_tag; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_performance_by_tag AS
 SELECT t.name AS tag_name,
    t.description AS tag_description,
    t.color AS tag_color,
    count(DISTINCT ea.id) AS accounts_in_tag,
    count(DISTINCT l.id) AS total_leads,
    count(DISTINCT l.id) FILTER (WHERE ((l.status)::text <> 'NOT_CONTACTED'::text)) AS contacted_leads,
    count(DISTINCT l.id) FILTER (WHERE ((l.status)::text = 'REPLIED'::text)) AS replied_leads,
    count(DISTINCT l.id) FILTER (WHERE ((l.label)::text = 'INTERESTED'::text)) AS interested_leads,
    count(DISTINCT l.id) FILTER (WHERE ((l.label)::text = ANY ((ARRAY['OUT_OF_OFFICE'::character varying, 'AUTOMATIC_REPLY'::character varying])::text[]))) AS auto_reply_leads,
    count(DISTINCT l.id) FILTER (WHERE ((l.status)::text = 'BOUNCED'::text)) AS bounced_leads,
    round((((count(DISTINCT l.id) FILTER (WHERE ((l.status)::text = 'REPLIED'::text)))::numeric / (NULLIF(count(DISTINCT l.id) FILTER (WHERE ((l.status)::text <> 'NOT_CONTACTED'::text)), 0))::numeric) * (100)::numeric), 2) AS reply_rate_pct,
    round((((count(DISTINCT l.id) FILTER (WHERE ((l.label)::text = 'INTERESTED'::text)))::numeric / (NULLIF(count(DISTINCT l.id) FILTER (WHERE ((l.status)::text = 'REPLIED'::text)), 0))::numeric) * (100)::numeric), 2) AS positive_of_replies_pct,
    round((((count(DISTINCT l.id) FILTER (WHERE ((l.label)::text = ANY ((ARRAY['OUT_OF_OFFICE'::character varying, 'AUTOMATIC_REPLY'::character varying])::text[]))))::numeric / (NULLIF(count(DISTINCT l.id) FILTER (WHERE ((l.status)::text <> 'NOT_CONTACTED'::text)), 0))::numeric) * (100)::numeric), 2) AS auto_reply_rate_pct,
    round((((count(DISTINCT l.id) FILTER (WHERE ((l.status)::text = 'BOUNCED'::text)))::numeric / (NULLIF(count(DISTINCT l.id) FILTER (WHERE ((l.status)::text <> 'NOT_CONTACTED'::text)), 0))::numeric) * (100)::numeric), 2) AS bounce_rate_pct
   FROM (((public.tags t
     JOIN public.account_tags at ON (((t.id)::text = (at.tag_id)::text)))
     JOIN public.email_accounts ea ON (((at.account_id)::text = (ea.id)::text)))
     LEFT JOIN public.leads l ON ((((l.email_acc_name)::text = (ea.email)::text) AND (l.deleted_from_source_at IS NULL))))
  WHERE (ea.deleted_from_source_at IS NULL)
  GROUP BY t.id, t.name, t.description, t.color
  ORDER BY (count(DISTINCT l.id) FILTER (WHERE ((l.status)::text <> 'NOT_CONTACTED'::text))) DESC;


--
-- Name: v_replied_leads; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_replied_leads AS
 SELECT email,
    first_name,
    last_name,
    job_title,
    company_name,
    campaign_name,
    status,
    label,
    last_sent_at,
    modified_at AS last_activity,
    linkedin_person_url,
    email_acc_name AS sent_from
   FROM public.leads l
  WHERE (((status)::text = 'REPLIED'::text) AND (deleted_from_source_at IS NULL))
  ORDER BY modified_at DESC;


--
-- Name: v_weekly_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_weekly_summary AS
 SELECT date_trunc('week'::text, (snapshot_date)::timestamp with time zone) AS week_start,
    sum(sent_count) AS total_sent,
    sum(replied_count) AS total_replies,
    sum(positive_reply_count) AS positive_replies,
    sum(bounced_count) AS bounces,
        CASE
            WHEN (sum(sent_count) > 0) THEN round((((sum(replied_count))::numeric / (sum(sent_count))::numeric) * (100)::numeric), 2)
            ELSE NULL::numeric
        END AS reply_rate_pct,
        CASE
            WHEN (sum(replied_count) > 0) THEN round((((sum(positive_reply_count))::numeric / (sum(replied_count))::numeric) * (100)::numeric), 2)
            ELSE NULL::numeric
        END AS positive_of_replies_pct,
        CASE
            WHEN (sum(sent_count) > 0) THEN round((((sum(bounced_count))::numeric / (sum(sent_count))::numeric) * (100)::numeric), 2)
            ELSE NULL::numeric
        END AS bounce_rate_pct
   FROM public.campaign_stats
  GROUP BY (date_trunc('week'::text, (snapshot_date)::timestamp with time zone))
  ORDER BY (date_trunc('week'::text, (snapshot_date)::timestamp with time zone)) DESC;


--
-- Name: warmup_stats; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.warmup_stats (
    id integer NOT NULL,
    snapshot_date date NOT NULL,
    google_percent numeric(6,2),
    microsoft_percent numeric(6,2),
    other_percent numeric(6,2),
    inbox_percent numeric(6,2),
    spam_percent numeric(6,2),
    promotion_percent numeric(6,2),
    total_warmup_sent integer,
    total_inbox_sent integer,
    total_spam_sent integer,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: warmup_stats_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.warmup_stats_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: warmup_stats_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.warmup_stats_id_seq OWNED BY public.warmup_stats.id;


--
-- Name: tasks id; Type: DEFAULT; Schema: enrichment; Owner: -
--

ALTER TABLE ONLY enrichment.tasks ALTER COLUMN id SET DEFAULT nextval('enrichment.tasks_id_seq'::regclass);


--
-- Name: workspace_leads id; Type: DEFAULT; Schema: enrichment; Owner: -
--

ALTER TABLE ONLY enrichment.workspace_leads ALTER COLUMN id SET DEFAULT nextval('enrichment.workspace_leads_id_seq'::regclass);


--
-- Name: workspaces id; Type: DEFAULT; Schema: enrichment; Owner: -
--

ALTER TABLE ONLY enrichment.workspaces ALTER COLUMN id SET DEFAULT nextval('enrichment.workspaces_id_seq'::regclass);


--
-- Name: account_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_stats ALTER COLUMN id SET DEFAULT nextval('public.account_stats_id_seq'::regclass);


--
-- Name: campaign_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_stats ALTER COLUMN id SET DEFAULT nextval('public.campaign_stats_id_seq'::regclass);


--
-- Name: campaign_stats_daily id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_stats_daily ALTER COLUMN id SET DEFAULT nextval('public.campaign_stats_daily_id_seq'::regclass);


--
-- Name: lead_status_counts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_status_counts ALTER COLUMN id SET DEFAULT nextval('public.lead_status_counts_id_seq'::regclass);


--
-- Name: sync_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sync_log ALTER COLUMN id SET DEFAULT nextval('public.sync_log_id_seq'::regclass);


--
-- Name: warmup_stats id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warmup_stats ALTER COLUMN id SET DEFAULT nextval('public.warmup_stats_id_seq'::regclass);


--
-- Name: leads_master leads_master_pkey; Type: CONSTRAINT; Schema: enrichment; Owner: -
--

ALTER TABLE ONLY enrichment.leads_master
    ADD CONSTRAINT leads_master_pkey PRIMARY KEY (email);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: enrichment; Owner: -
--

ALTER TABLE ONLY enrichment.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: workspace_leads workspace_leads_pkey; Type: CONSTRAINT; Schema: enrichment; Owner: -
--

ALTER TABLE ONLY enrichment.workspace_leads
    ADD CONSTRAINT workspace_leads_pkey PRIMARY KEY (id);


--
-- Name: workspace_leads workspace_leads_workspace_id_email_key; Type: CONSTRAINT; Schema: enrichment; Owner: -
--

ALTER TABLE ONLY enrichment.workspace_leads
    ADD CONSTRAINT workspace_leads_workspace_id_email_key UNIQUE (workspace_id, email);


--
-- Name: workspaces workspaces_pkey; Type: CONSTRAINT; Schema: enrichment; Owner: -
--

ALTER TABLE ONLY enrichment.workspaces
    ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);


--
-- Name: account_stats account_stats_account_id_snapshot_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_stats
    ADD CONSTRAINT account_stats_account_id_snapshot_date_key UNIQUE (account_id, snapshot_date);


--
-- Name: account_stats account_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_stats
    ADD CONSTRAINT account_stats_pkey PRIMARY KEY (id);


--
-- Name: account_tags account_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account_tags
    ADD CONSTRAINT account_tags_pkey PRIMARY KEY (account_id, tag_id);


--
-- Name: calcom_bookings calcom_bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calcom_bookings
    ADD CONSTRAINT calcom_bookings_pkey PRIMARY KEY (id);


--
-- Name: calcom_bookings calcom_bookings_uid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calcom_bookings
    ADD CONSTRAINT calcom_bookings_uid_key UNIQUE (uid);


--
-- Name: campaign_stats campaign_stats_campaign_id_snapshot_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_stats
    ADD CONSTRAINT campaign_stats_campaign_id_snapshot_date_key UNIQUE (campaign_id, snapshot_date);


--
-- Name: campaign_stats_daily campaign_stats_daily_campaign_id_stat_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_stats_daily
    ADD CONSTRAINT campaign_stats_daily_campaign_id_stat_date_key UNIQUE (campaign_id, stat_date);


--
-- Name: campaign_stats_daily campaign_stats_daily_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_stats_daily
    ADD CONSTRAINT campaign_stats_daily_pkey PRIMARY KEY (id);


--
-- Name: campaign_stats campaign_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaign_stats
    ADD CONSTRAINT campaign_stats_pkey PRIMARY KEY (id);


--
-- Name: campaigns campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campaigns
    ADD CONSTRAINT campaigns_pkey PRIMARY KEY (id);


--
-- Name: email_accounts email_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_accounts
    ADD CONSTRAINT email_accounts_pkey PRIMARY KEY (id);


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: fathom_calls fathom_calls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fathom_calls
    ADD CONSTRAINT fathom_calls_pkey PRIMARY KEY (recording_id);


--
-- Name: lead_status_counts lead_status_counts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lead_status_counts
    ADD CONSTRAINT lead_status_counts_pkey PRIMARY KEY (id);


--
-- Name: leads leads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.leads
    ADD CONSTRAINT leads_pkey PRIMARY KEY (id);


--
-- Name: sync_log sync_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sync_log
    ADD CONSTRAINT sync_log_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: warmup_stats warmup_stats_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warmup_stats
    ADD CONSTRAINT warmup_stats_pkey PRIMARY KEY (id);


--
-- Name: warmup_stats warmup_stats_snapshot_date_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.warmup_stats
    ADD CONSTRAINT warmup_stats_snapshot_date_key UNIQUE (snapshot_date);


--
-- Name: idx_workspace_leads_email; Type: INDEX; Schema: enrichment; Owner: -
--

CREATE INDEX idx_workspace_leads_email ON enrichment.workspace_leads USING btree (email);


--
-- Name: idx_workspace_leads_workspace; Type: INDEX; Schema: enrichment; Owner: -
--

CREATE INDEX idx_workspace_leads_workspace ON enrichment.workspace_leads USING btree (workspace_id);


--
-- Name: tasks_status_idx; Type: INDEX; Schema: enrichment; Owner: -
--

CREATE INDEX tasks_status_idx ON enrichment.tasks USING btree (status);


--
-- Name: tasks_workspace_id_idx; Type: INDEX; Schema: enrichment; Owner: -
--

CREATE INDEX tasks_workspace_id_idx ON enrichment.tasks USING btree (workspace_id);


--
-- Name: calcom_bookings_attendee_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calcom_bookings_attendee_email_idx ON public.calcom_bookings USING btree (attendee_email);


--
-- Name: calcom_bookings_start_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calcom_bookings_start_time_idx ON public.calcom_bookings USING btree (start_time DESC);


--
-- Name: calcom_bookings_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX calcom_bookings_status_idx ON public.calcom_bookings USING btree (status);


--
-- Name: fathom_calls_external_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fathom_calls_external_email_idx ON public.fathom_calls USING btree (external_invitee_email);


--
-- Name: fathom_calls_has_summary_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fathom_calls_has_summary_idx ON public.fathom_calls USING btree (has_summary);


--
-- Name: fathom_calls_start_time_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fathom_calls_start_time_idx ON public.fathom_calls USING btree (recording_start_time DESC);


--
-- Name: idx_account_stats_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_account_stats_date ON public.account_stats USING btree (account_id, snapshot_date);


--
-- Name: idx_account_tags_account; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_account_tags_account ON public.account_tags USING btree (account_id);


--
-- Name: idx_account_tags_tag; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_account_tags_tag ON public.account_tags USING btree (tag_id);


--
-- Name: idx_campaign_stats_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_campaign_stats_date ON public.campaign_stats USING btree (campaign_id, snapshot_date);


--
-- Name: idx_csd_campaign; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_csd_campaign ON public.campaign_stats_daily USING btree (campaign_id);


--
-- Name: idx_csd_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_csd_date ON public.campaign_stats_daily USING btree (stat_date);


--
-- Name: idx_emails_campaign; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emails_campaign ON public.emails USING btree (campaign_id);


--
-- Name: idx_emails_direction; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emails_direction ON public.emails USING btree (direction);


--
-- Name: idx_emails_lead; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emails_lead ON public.emails USING btree (lead_email);


--
-- Name: idx_emails_lead_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emails_lead_id ON public.emails USING btree (lead_id);


--
-- Name: idx_emails_sent_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emails_sent_at ON public.emails USING btree (sent_at);


--
-- Name: idx_emails_thread_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_emails_thread_id ON public.emails USING btree (thread_id);


--
-- Name: idx_leads_campaign_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_leads_campaign_id ON public.leads USING btree (campaign_id);


--
-- Name: idx_leads_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_leads_email ON public.leads USING btree (email);


--
-- Name: idx_leads_modified_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_leads_modified_at ON public.leads USING btree (modified_at);


--
-- Name: idx_leads_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_leads_status ON public.leads USING btree (status);


--
-- Name: tasks tasks_workspace_id_fkey; Type: FK CONSTRAINT; Schema: enrichment; Owner: -
--

ALTER TABLE ONLY enrichment.tasks
    ADD CONSTRAINT tasks_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES enrichment.workspaces(id) ON DELETE CASCADE;


--
-- Name: workspace_leads workspace_leads_email_fkey; Type: FK CONSTRAINT; Schema: enrichment; Owner: -
--

ALTER TABLE ONLY enrichment.workspace_leads
    ADD CONSTRAINT workspace_leads_email_fkey FOREIGN KEY (email) REFERENCES enrichment.leads_master(email);


--
-- Name: workspace_leads workspace_leads_workspace_id_fkey; Type: FK CONSTRAINT; Schema: enrichment; Owner: -
--

ALTER TABLE ONLY enrichment.workspace_leads
    ADD CONSTRAINT workspace_leads_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES enrichment.workspaces(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict h0K7a6yjhcN1xjwycJvnzxRJkgSDwkR7gGAxq7YuSbTtW9Ju1KenA9dMcf3psol

