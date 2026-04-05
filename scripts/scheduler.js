// Scheduler: runs sync jobs on cron schedule.
// All times are UTC. Railway worker — stays alive indefinitely.
import cron from 'node-cron';
import { spawn } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));

function run(script, arg) {
  return new Promise((res, rej) => {
    const args = arg ? [script, arg] : [script];
    const child = spawn('node', args, { stdio: 'inherit' });
    child.on('close', code => {
      if (code !== 0) rej(new Error(`${script} ${arg || ''} exited with code ${code}`));
      else res();
    });
  });
}

const index = resolve(__dirname, 'index.js');
const notify = resolve(__dirname, 'notify.js');

// Every hour at :00 — main sync (tags, campaigns, accounts, leads, stats, zoho)
cron.schedule('0 * * * *', async () => {
  console.log(`[${new Date().toISOString()}] Running: all`);
  await run(index, 'all').catch(e => console.error('[all]', e.message));
});

// Every hour at :30 — recent emails (last 48h)
cron.schedule('30 * * * *', async () => {
  console.log(`[${new Date().toISOString()}] Running: emails`);
  await run(index, 'emails').catch(e => console.error('[emails]', e.message));
});

// 3x/day — calcom + fathom (08:00, 14:00, 20:00 UTC)
cron.schedule('0 8,14,20 * * *', async () => {
  console.log(`[${new Date().toISOString()}] Running: calcom, fathom`);
  await run(index, 'calcom').catch(e => console.error('[calcom]', e.message));
  await run(index, 'fathom').catch(e => console.error('[fathom]', e.message));
});

// 3x/day — daily_stats (06:00, 12:00, 18:00 UTC)
cron.schedule('0 6,12,18 * * *', async () => {
  console.log(`[${new Date().toISOString()}] Running: daily_stats`);
  await run(index, 'daily_stats').catch(e => console.error('[daily_stats]', e.message));
});

// Daily at 09:00 UTC — Telegram report
cron.schedule('0 9 * * *', async () => {
  console.log(`[${new Date().toISOString()}] Running: daily report`);
  await run(notify, 'report').catch(e => console.error('[report]', e.message));
});

// Every 2 hours — alerts check
cron.schedule('0 */2 * * *', async () => {
  console.log(`[${new Date().toISOString()}] Running: alerts`);
  await run(notify, 'alerts').catch(e => console.error('[alerts]', e.message));
});

console.log(`[${new Date().toISOString()}] Scheduler started`);
