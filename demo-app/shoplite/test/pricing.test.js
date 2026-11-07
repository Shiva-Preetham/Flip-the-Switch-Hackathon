'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { calculateTotal, discountFor, subtotalOf } = require('../src/pricing');

test('subtotal sums price * qty', () => {
  assert.equal(subtotalOf([{ price: 10, qty: 2 }, { price: 5.5, qty: 1 }]), 25.5);
});

test('order without coupon in Oregon has no tax', () => {
  const r = calculateTotal([{ price: 80, qty: 1 }], { region: 'OR' });
  assert.deepEqual(r, { subtotal: 80, discount: 0, shipping: 0, tax: 0, total: 80 });
});

test('small order pays standard shipping', () => {
  const r = calculateTotal([{ price: 20, qty: 1 }], { region: 'OR' });
  assert.equal(r.shipping, 7.99);
  assert.equal(r.total, 27.99);
});

test('SAVE10 takes 10% off', () => {
  assert.equal(discountFor(200, 'SAVE10'), 20);
});

test('SAVE20 needs a $100 subtotal', () => {
  assert.equal(discountFor(99, 'SAVE20'), 0);
  assert.equal(discountFor(150, 'SAVE20'), 30);
});

test('unknown coupon is rejected', () => {
  assert.throws(() => discountFor(100, 'NOPE'), /Unknown coupon/);
});
