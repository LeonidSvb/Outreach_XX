import { syncCampaigns } from './sync/campaigns.js';
import { syncEmailAccounts } from './sync/email_accounts.js';
import { syncLeads } from './sync/leads.js';
import { syncCampaignStats, syncWarmupStats, syncLeadStatusCounts } from './sync/stats.js';
import { syncTags } from './sync/tags.js';
import { syncZoho } from './zoho/sync.js';
import pool from './db.js';

const arg = process.argv[2];

async function runAll() {
  console.log(`[${new Date().toISOString()}] Starting full sync...`);
  await syncTags();
  await syncCampaigns();
  await syncEmailAccounts();
  await syncLeads();
  await syncLeadStatusCounts();
  await syncCampaignStats();
  await syncWarmupStats();
  await syncZoho();
  console.log(`[${new Date().toISOString()}] Full sync complete.`);
}

try {
  if (!arg || arg === 'all') await runAll();
  else if (arg === 'campaigns') await syncCampaigns();
  else if (arg === 'accounts') { await syncTags(); await syncEmailAccounts(); }
  else if (arg === 'leads') await syncLeads();
  else if (arg === 'stats') { await syncCampaignStats(); await syncWarmupStats(); await syncLeadStatusCounts(); }
  else if (arg === 'tags') await syncTags();
  else if (arg === 'zoho') await syncZoho();
  else console.error(`Unknown: ${arg}`);
} catch (e) {
  console.error('Sync failed:', e.message);
  process.exit(1);
} finally {
  await pool.end();
}
