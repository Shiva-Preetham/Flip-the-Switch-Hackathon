'use strict';

// "Sends" a customer reply: moves outbox/drafts/<ticket>.md to outbox/sent/<ticket>.md.
// In a real deployment this would call the help desk's API. Running it needs a
// person's approval in the room (see .claude/settings.json, "ask" rules).
// Usage: node scripts/send-reply.js T-1042

const fs = require('node:fs');
const path = require('node:path');

const ticket = process.argv[2];
if (!ticket || !/^T-\d+$/.test(ticket)) {
  console.error('Usage: node scripts/send-reply.js T-<number>');
  process.exit(1);
}

const root = path.join(__dirname, '..', 'outbox');
const draft = path.join(root, 'drafts', `${ticket}.md`);
const sentDir = path.join(root, 'sent');

if (!fs.existsSync(draft)) {
  console.error(`No draft at outbox/drafts/${ticket}.md. Write the reply there first.`);
  process.exit(1);
}

fs.mkdirSync(sentDir, { recursive: true });
const body = fs.readFileSync(draft, 'utf8');
const stamped = `Sent: ${new Date().toISOString()}\n\n${body}`;
fs.writeFileSync(path.join(sentDir, `${ticket}.md`), stamped);
fs.rmSync(draft);

console.log(`Reply for ${ticket} sent to the customer (${body.length} chars).`);
