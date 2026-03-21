import { readFileSync } from 'fs';
import { resolve } from 'path';
import https from 'https';
import pool, { logSync } from '../db.js';

const envPath = resolve('/root/outreach-sync/.env');
const env = Object.fromEntries(
  readFileSync(envPath, 'utf8').split('\n')
    .filter(l => l && !l.startsWith('#'))
    .map(l => {
      const idx = l.indexOf('=');
      return [l.slice(0, idx).trim(), l.slice(idx + 1).trim()];
    })
);

function httpsPost(hostname, path, data, headers) {
  return new Promise((resolve, reject) => {
    const body = typeof data === 'string' ? data : JSON.stringify(data);
    const req = https.request({
      hostname, path, method: 'POST',
      headers: { 'Content-Length': Buffer.byteLength(body), ...headers }
    }, (res) => {
      let raw = '';
      res.on('data', c => raw += c);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(raw) }); }
        catch { resolve({ status: res.statusCode, body: raw }); }
      });
    });
    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

async function getAccessToken() {
  const params = new URLSearchParams({
    grant_type: 'refresh_token',
    client_id: env.ZOHO_CLIENT_ID,
    client_secret: env.ZOHO_CLIENT_SECRET,
    refresh_token: env.ZOHO_REFRESH_TOKEN,
  });
  const res = await httpsPost('accounts.zoho.com', '/oauth/v2/token', params.toString(), {
    'Content-Type': 'application/x-www-form-urlencoded'
  });
  if (!res.body.access_token) throw new Error('Token error: ' + JSON.stringify(res.body));
  return res.body.access_token;
}

async function createZohoContact(token, lead) {
  const description = [
    'Campaign: ' + (lead.campaign_name || ''),
    'Sending account: ' + (lead.email_acc_name || ''),
    'Label: ' + (lead.label || ''),
    'PlusVibe ID: ' + lead.id,
  ].join('\n');

  const contact = {
    data: [{
      Email: lead.email,
      First_Name: lead.first_name || '',
      Last_Name: lead.last_name || lead.email,
      Title: (lead.job_title || '').slice(0, 100),
      Account_Name: lead.company_name || '',
      Phone: lead.phone_number || '',
      Lead_Source: 'Cold Email',
      Description: description,
    }],
    duplicate_check_fields: ['Email'],
  };
  const res = await httpsPost('www.zohoapis.com', '/crm/v8/Contacts/upsert', contact, {
    'Authorization': 'Zoho-oauthtoken ' + token,
    'Content-Type': 'application/json',
  });
  const record = res.body && res.body.data && res.body.data[0];
  if (!record) throw new Error('Zoho API error: ' + JSON.stringify(res.body));
  if (record.status === 'error') throw new Error('Zoho record error: ' + record.message + ' (' + record.code + ')');
  return record.details.id;
}

export async function syncZoho() {
  const startedAt = new Date();
  console.log('[' + startedAt.toISOString() + '] Starting Zoho sync...');

  const { rows: leads } = await pool.query(`
    SELECT id, email, first_name, last_name, job_title, company_name,
           phone_number, campaign_name, email_acc_name, label
    FROM leads
    WHERE status = 'REPLIED'
    AND label IN ('INTERESTED', 'MEETING_BOOKED', 'MEETING_COMPLETED')
    AND zoho_contact_id IS NULL
    AND deleted_from_source_at IS NULL
    ORDER BY modified_at DESC
  `);

  console.log('Found ' + leads.length + ' leads to sync');
  if (leads.length === 0) {
    await logSync('zoho', startedAt, { processed: 0, upserted: 0, deleted: 0 });
    return;
  }

  const token = await getAccessToken();
  let upserted = 0;
  let errors = 0;

  for (const lead of leads) {
    try {
      const zohoId = await createZohoContact(token, lead);
      await pool.query('UPDATE leads SET zoho_contact_id = $1 WHERE id = $2', [zohoId, lead.id]);
      console.log('Synced ' + lead.email + ' -> ' + zohoId);
      upserted++;
    } catch (e) {
      console.error('Error syncing ' + lead.email + ': ' + e.message);
      errors++;
    }
    await new Promise(r => setTimeout(r, 250));
  }

  await logSync('zoho', startedAt, {
    processed: leads.length,
    upserted,
    deleted: 0,
    status: errors > 0 ? 'partial' : 'success',
    error: errors > 0 ? errors + ' errors' : null,
  });

  console.log('[' + new Date().toISOString() + '] Zoho sync done: ' + upserted + ' synced, ' + errors + ' errors');
}
