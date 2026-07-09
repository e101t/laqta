const test = require('node:test');
const assert = require('node:assert/strict');

const {
  normalizeCurrency,
  toNumber,
  validateAmountAndCurrency,
} = require('../payment_validation');

test('normalizeCurrency trims and lowercases', () => {
  assert.equal(normalizeCurrency(' IQD '), 'iqd');
  assert.equal(normalizeCurrency(null), '');
});

test('toNumber returns null for invalid values', () => {
  assert.equal(toNumber('abc'), null);
  assert.equal(toNumber('10.5'), 10.5);
});

test('validateAmountAndCurrency detects mismatches', () => {
  const booking = { price: 1000, currency: 'IQD' };
  assert.equal(validateAmountAndCurrency(booking, 1000, 'iqd'), null);
  assert.equal(validateAmountAndCurrency(booking, 900, 'iqd'), 'amount_mismatch');
  assert.equal(validateAmountAndCurrency(booking, 1000, 'usd'), 'currency_mismatch');
});
