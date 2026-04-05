const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const client = new Client({
  connectionString: 'postgresql://postgres:ZunXlkdpcygCTalLfrkimDoqsNiWyGCD@junction.proxy.rlwy.net:33582/railway',
  ssl: false
});

async function run() {
  await client.connect();
  console.log('Connected to Railway PostgreSQL');

  let sql = fs.readFileSync(path.join(__dirname, '../../db/schema.sql'), 'utf8');

  // Remove psql meta-commands (lines starting with backslash) and comment-only lines
  const lines = sql.split('\n').filter(line => {
    const t = line.trim();
    return !t.startsWith('\x5c') && !t.startsWith('--');
  });
  sql = lines.join('\n');

  // Split on semicolons followed by newline (proper statement boundaries)
  const statements = sql.split(/;\s*\n/).map(s => s.trim()).filter(s => s.length > 0);

  let ok = 0, skipped = 0, errors = 0;
  for (const stmt of statements) {
    try {
      await client.query(stmt);
      ok++;
    } catch(e) {
      if (e.message.includes('already exists')) { skipped++; continue; }
      console.error('ERROR:', e.message.substring(0, 150));
      errors++;
    }
  }

  console.log(`Done: ${ok} applied, ${skipped} already existed, ${errors} errors`);
  await client.end();
}

run().catch(e => { console.error(e.message); process.exit(1); });
