'use strict';

// Reproduce a customer's checkout from the command line.
// Usage: node scripts/quote.js --region CA --coupon SAVE20 --item 120x1 --item 15.5x2
// Each --item is <price>x<qty>.

const { calculateTotal } = require('../src/pricing');

const args = process.argv.slice(2);
const items = [];
let region = 'OR';
let coupon;

for (let i = 0; i < args.length; i++) {
  const a = args[i];
  if (a === '--region') region = args[++i];
  else if (a === '--coupon') coupon = args[++i];
  else if (a === '--item') {
    const [price, qty] = args[++i].split('x').map(Number);
    items.push({ price, qty: qty || 1 });
  }
}

if (items.length === 0) {
  console.error('Add at least one --item <price>x<qty>');
  process.exit(1);
}

console.log(JSON.stringify(calculateTotal(items, { coupon, region }), null, 2));
