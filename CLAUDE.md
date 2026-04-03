# Outreach XX — Claude Context

## Infrastructure
- VPS: `72.61.143.225` — `ssh -i ~/.ssh/id_ed25519_hostinger -o StrictHostKeyChecking=no root@72.61.143.225`
- Postgres: `outreach` DB, user `n8n`, port `5432` — credentials in `.env`
- Sync scripts on VPS: `/root/outreach-sync/`
- Docker: `docker exec root-postgres-1 psql -U n8n -d outreach -c "..."`

## Key Files
- `.env` — all credentials (never commit)
- `docs/plusvibe-api.md` — verified API paths (official docs have ~30% wrong paths)
- `db/schema.sql` — current DB schema (auto-generated, update after every migration)
- `scripts/index.js` — sync entry point

## PlusVibe API
- Rate limit: 5 req/sec → always 210ms delay in loops
- Auth: `x-api-key` header
- Always use `docs/plusvibe-api.md`, not official docs

## Deploy Flow
Local → GitHub → VPS. Never edit files directly on VPS.
```bash
git add -A && git commit -m "..." && git push origin main
ssh -i ~/.ssh/id_ed25519_hostinger root@72.61.143.225 "cd /root/outreach-sync && git pull origin main"
```

## Ground Rules

### DB Safety
- NEVER run ALTER TABLE / DROP / INSERT / UPDATE without explicit user confirmation
- Show SQL first, wait for "да" / "ОК" / "делай"
- All schema changes → migration file in `db/migrations/YYYY-MM-DD-description.sql`, committed before execution

### Migration Workflow — ОБЯЗАТЕЛЬНО
After every migration:
1. Apply SQL on VPS
2. Update `db/schema.sql`:
```bash
ssh -i ~/.ssh/id_ed25519_hostinger -o StrictHostKeyChecking=no root@72.61.143.225 \
  "docker exec root-postgres-1 pg_dump -U n8n -d outreach --schema-only --no-owner --no-acl" \
  > db/schema.sql
```
3. Commit both files together

Without updating `db/schema.sql` — migration is not complete.

### General
- Never push to git without explicit command
- Never edit files directly on VPS
- Confirm before any destructive action (data deletion, schema change, service restart)
