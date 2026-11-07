'use strict';

// ShopLite checkout pricing.
// Policy: see docs/pricing-policy.md (the source of truth for support and engineering).

const TAX_RATES = {
  CA: 0.0725,
  NY: 0.04,
  TX: 0.0625,
  OR: 0,
};

const COUPONS = {
  SAVE10: { type: 'percent', value: 10 },
  SAVE20: { type: 'percent', value: 20, minSubtotal: 100 },
  FLAT15: { type: 'fixed', value: 15, minSubtotal: 60 },
};

const FREE_SHIPPING_THRESHOLD = 50;
const STANDARD_SHIPPING = 7.99;

function round2(n) {
  return Math.round((n + Number.EPSILON) * 100) / 100;
}

function subtotalOf(items) {
  return round2(items.reduce((sum, item) => sum + item.price * item.qty, 0));
}

function discountFor(subtotal, code) {
  if (!code) return 0;
  const coupon = COUPONS[code.toUpperCase()];
  if (!coupon) throw new Error(`Unknown coupon: ${code}`);
  if (coupon.minSubtotal && subtotal < coupon.minSubtotal) return 0;
  if (coupon.type === 'percent') return round2((subtotal * coupon.value) / 100);
  return Math.min(coupon.value, subtotal);
}

function shippingFor(amount) {
  return amount > FREE_SHIPPING_THRESHOLD ? 0 : STANDARD_SHIPPING;
}

function taxFor(amount, region) {
  const rate = TAX_RATES[region];
  if (rate === undefined) throw new Error(`Unsupported region: ${region}`);
  return round2(amount * rate);
}

function calculateTotal(items, { coupon, region }) {
  const subtotal = subtotalOf(items);
  const discount = discountFor(subtotal, coupon);
  const discounted = round2(subtotal - discount);
  const shipping = shippingFor(discounted);
  const tax = taxFor(subtotal, region);
  const total = round2(discounted + shipping + tax);
  return { subtotal, discount, shipping, tax, total };
}

module.exports = {
  calculateTotal,
  subtotalOf,
  discountFor,
  shippingFor,
  taxFor,
  round2,
  FREE_SHIPPING_THRESHOLD,
  STANDARD_SHIPPING,
};
