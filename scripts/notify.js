// Notification runner. Usage: node notify.js [report|alerts]
import { sendDailyReport } from './notifications/daily_report.js';
import { checkAndSendAlerts } from './notifications/alerts.js';
import pool from './db.js';

const arg = process.argv[2];

try {
  if (arg === 'report') await sendDailyReport();
  else if (arg === 'alerts') await checkAndSendAlerts();
  else {
    console.error('Usage: node src/notify.js report|alerts');
    process.exit(1);
  }
} catch (e) {
  console.error('Notification failed:', e.message);
  process.exit(1);
} finally {
  await pool.end();
}
