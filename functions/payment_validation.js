const ALLOWED_CURRENCIES = new Set(['iqd']);

function normalizeCurrency(value) {
  if (typeof value !== 'string') return '';
  return value.trim().toLowerCase();
}

function toNumber(value) {
  const num = Number(value);
  return Number.isFinite(num) ? num : null;
}

function validateAmountAndCurrency(bookingData, amount, currency) {
  const bookingAmount = toNumber(bookingData.price);
  const bookingCurrency = normalizeCurrency(bookingData.currency || 'iqd');
  if (bookingAmount == null || bookingAmount <= 0) {
    return 'invalid_booking_amount';
  }
  if (amount == null || amount <= 0 || Math.round(amount) !== Math.round(bookingAmount)) {
    return 'amount_mismatch';
  }
  if (!ALLOWED_CURRENCIES.has(currency) || currency !== bookingCurrency) {
    return 'currency_mismatch';
  }
  return null;
}

module.exports = {
  normalizeCurrency,
  toNumber,
  validateAmountAndCurrency,
};
