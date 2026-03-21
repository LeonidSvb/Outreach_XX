// PostgreSQL connection pool, query helper, and sync logger.
import pg from 'pg';
import { readFileSync } from 'fs';
import { resolve } from 'path';

const envPath = resolve('/root/outreach-sync/.env');
const env = Object.fromEntries(
  readFileSync(envPath, 'utf8').split('\n')
    .filter(l => l && !l.startsWith('#'))
    .map(l => l.split('=').map(s => s.trim()))
);

const pool = new pg.Pool({
  host: env.PGHOST,
  port: parseInt(env.PGPORT),
  database: env.PGDATABASE,
  user: env.PGUSER,
  password: env.PGPASSWORD,
});

export async function query(sql, params) {
  return pool.query(sql, params);
}

export async function logSync(type, startedAt, result) {
  await pool.query(
    `INSERT INTO sync_log (sync_type, started_at, finished_at, records_processed, records_upserted, records_deleted, status, error_message)
     VALUES ($1, $2, NOW(), $3, $4, $5, $6, $7)`,
    [type, startedAt, result.processed || 0, result.upserted || 0, result.deleted || 0, result.status || 'success', result.error || null]
  );
}

export default pool;
