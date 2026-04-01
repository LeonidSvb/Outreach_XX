-- Fix emails.direction: PlusVibe returns 'IN'/'OUT' but upsert script checked for 'incoming'
-- Result: all emails were stored as OUT. Fix: emails where from_email = lead_email are inbound.

UPDATE emails
SET direction = 'IN'
WHERE from_email = lead_email
  AND direction = 'OUT';

-- Verify:
-- SELECT direction, COUNT(*) FROM emails GROUP BY direction;
