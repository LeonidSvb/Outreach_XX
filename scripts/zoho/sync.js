// Syncs positive reply leads (INTERESTED/MEETING_BOOKED/MEETING_COMPLETED) to Zoho CRM Contacts.
// One-way. Dedup via zoho_contact_id in leads table + duplicate_check_fields by Email in Zoho.
import https from 'https';
import pool, { logSync } from '../db.js';


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
    client_id: process.env.ZOHO_CLIENT_ID,
    client_secret: process.env.ZOHO_CLIENT_SECRET,
    refresh_token: process.env.ZOHO_REFRESH_TOKEN,
  });
  const res = await httpsPost('accounts.zoho.com', '/oauth/v2/token', params.toString(), {
    'Content-Type': 'application/x-www-form-urlencoded'
  });
  if (!res.body.access_token) throw new Error('Token error: ' + JSON.stringify(res.body));
  return res.body.access_token;
}

async function createZohoContact(token, lead) {
  const description = [
    'Source: PlusVibe',
    'Campaign: ' + (lead.campaign_name || ''),
    'Sending account: ' + (lead.email_acc_name || ''),
    'Label: ' + (lead.label || ''),
    lead.tags ? 'Tags: ' + lead.tags : null,
    lead.linkedin_person_url ? 'LinkedIn: ' + lead.linkedin_person_url : null,
    lead.company_website ? 'Website: ' + lead.company_website : null,
    'PlusVibe ID: ' + lead.id,
  ].filter(Boolean).join('\n');

  const contact = {
    data: [{
      Email: lead.email,
      First_Name: lead.first_name || '',
      Last_Name: lead.last_name || lead.email,
      Title: (lead.job_title || '').slice(0, 100),
      Account_Name: lead.company_name || '',
      Phone: lead.phone_number || '',
      Mailing_City: lead.city || '',
      Mailing_Country: lead.country || '',
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
    SELECT l.id, l.email, l.first_name, l.last_name, l.job_title,
           l.company_name, l.company_website, l.phone_number,
           l.linkedin_person_url, l.city, l.country,
           l.campaign_name, l.email_acc_name, l.label,
           STRING_AGG(t.name, ', ') as tags
    FROM leads l
    LEFT JOIN email_accounts ea ON ea.email = l.email_acc_name AND ea.deleted_from_source_at IS NULL
    LEFT JOIN account_tags at ON at.account_id = ea.id
    LEFT JOIN tags t ON t.id = at.tag_id
    WHERE l.status = 'REPLIED'
    AND l.label IN ('INTERESTED', 'MEETING_BOOKED', 'MEETING_COMPLETED')
    AND l.zoho_contact_id IS NULL
    AND l.deleted_from_source_at IS NULL
    GROUP BY l.id, l.email, l.first_name, l.last_name, l.job_title,
             l.company_name, l.company_website, l.phone_number,
             l.linkedin_person_url, l.city, l.country,
             l.campaign_name, l.email_acc_name, l.label
    ORDER BY l.modified_at DESC
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
