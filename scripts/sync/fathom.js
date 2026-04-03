// Sync all Fathom Video recordings into public.fathom_calls
// Paginated via cursor. Safe to re-run — full upsert.
// Links to leads/campaigns via external_invitee_email → public.leads.email
import { query, logSync } from '../db.js';

const FATHOM_BASE = 'https://api.fathom.ai/external/v1';
const API_KEY     = process.env.FATHOM_API_KEY;

async function fetchAllMeetings() {
  if (!API_KEY) throw new Error('FATHOM_API_KEY not set');

  const meetings = [];
  let cursor = null;

  while (true) {
    const url = cursor
      ? `${FATHOM_BASE}/meetings?limit=100&cursor=${encodeURIComponent(cursor)}`
      : `${FATHOM_BASE}/meetings?limit=100`;

    const res = await fetch(url, { headers: { 'X-Api-Key': API_KEY } });
    if (!res.ok) throw new Error(`Fathom API error ${res.status}: ${await res.text()}`);
    const data = await res.json();

    meetings.push(...(data.items || []));

    if (!data.next_cursor) break;
    cursor = data.next_cursor;
  }

  return meetings;
}

function durationMinutes(start, end) {
  if (!start || !end) return null;
  const diff = new Date(end) - new Date(start);
  return Math.round(diff / 60000);
}

export async function syncFathom() {
  const startedAt = new Date();
  console.log('  Syncing Fathom calls...');

  try {
    const meetings = await fetchAllMeetings();
    let upserted = 0;

    for (const m of meetings) {
      // Find first external (client) invitee
      const external = (m.calendar_invitees || []).find(i => i.is_external);

      await query(`
        INSERT INTO public.fathom_calls (
          recording_id, meeting_title, url, share_url,
          scheduled_start_time, scheduled_end_time,
          recording_start_time, recording_end_time, duration_minutes,
          external_invitee_email, external_invitee_name, all_invitees,
          has_summary, has_transcript, summary, action_items, crm_matches,
          cal_created_at, synced_at
        ) VALUES (
          $1,$2,$3,$4,
          $5,$6,
          $7,$8,$9,
          $10,$11,$12,
          $13,$14,$15,$16,$17,
          $18, NOW()
        )
        ON CONFLICT (recording_id) DO UPDATE SET
          meeting_title          = EXCLUDED.meeting_title,
          share_url              = EXCLUDED.share_url,
          recording_start_time   = EXCLUDED.recording_start_time,
          recording_end_time     = EXCLUDED.recording_end_time,
          duration_minutes       = EXCLUDED.duration_minutes,
          external_invitee_email = EXCLUDED.external_invitee_email,
          external_invitee_name  = EXCLUDED.external_invitee_name,
          all_invitees           = EXCLUDED.all_invitees,
          has_summary            = EXCLUDED.has_summary,
          has_transcript         = EXCLUDED.has_transcript,
          summary                = EXCLUDED.summary,
          action_items           = EXCLUDED.action_items,
          crm_matches            = EXCLUDED.crm_matches,
          synced_at              = NOW()
      `, [
        m.recording_id,
        m.meeting_title || m.title || null,
        m.url || null,
        m.share_url || null,
        m.scheduled_start_time || null,
        m.scheduled_end_time   || null,
        m.recording_start_time || null,
        m.recording_end_time   || null,
        durationMinutes(m.recording_start_time, m.recording_end_time),
        external?.email || null,
        external?.name  || null,
        JSON.stringify(m.calendar_invitees || []),
        !!m.default_summary,
        !!m.transcript,
        m.default_summary || null,
        m.action_items ? JSON.stringify(m.action_items) : null,
        m.crm_matches  ? JSON.stringify(m.crm_matches)  : null,
        m.created_at || null,
      ]);
      upserted++;
    }

    await logSync('fathom_calls', startedAt, { upserted, status: 'success' });
    console.log(`  Fathom: ${upserted} calls upserted`);
  } catch (e) {
    await logSync('fathom_calls', startedAt, { status: 'error', error: e.message });
    throw e;
  }
}
