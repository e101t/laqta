const test = require('node:test');
const assert = require('node:assert/strict');

const {
  buildBookingForAcceptedOffer,
  normalizeAvailabilitySettings,
  parseTimeToMinutes,
  toBaghdadDateString,
  validateBookingAgainstAvailability,
  weekdayIndex,
} = require('../booking_authority');

function makeAvailability(overrides = {}) {
  return {
    allowSameDayBookings: false,
    minBookingPrice: 150,
    days: [
      { isEnabled: true, startMinutes: 540, endMinutes: 1020 },
      { isEnabled: true, startMinutes: 540, endMinutes: 1020 },
      { isEnabled: true, startMinutes: 540, endMinutes: 1020 },
      { isEnabled: true, startMinutes: 540, endMinutes: 1020 },
      { isEnabled: true, startMinutes: 540, endMinutes: 1020 },
      { isEnabled: false, startMinutes: 540, endMinutes: 1020 },
      { isEnabled: false, startMinutes: 540, endMinutes: 1020 },
    ],
    ...overrides,
  };
}

function makeBooking(overrides = {}) {
  return {
    customerId: 'cust1',
    photographerId: 'photog1',
    requestId: 'req1',
    offerId: 'offer1',
    date: '2026-02-02',
    time: '10:00',
    duration: 120,
    type: 'Wedding',
    price: 200,
    currency: 'IQD',
    status: 'pending',
    payment: { status: 'pending', intentId: null, amount: null, paidAt: null },
    location: { lat: null, lng: null, text: 'Baghdad' },
    deliverables: null,
    notes: null,
    chatId: null,
    deliveryId: null,
    disputeId: null,
    revisionCount: 0,
    canceledBy: null,
    timeline: {
      confirmedAt: null,
      inProgressAt: null,
      deliveredAt: null,
      revisionRequestedAt: null,
      completedAt: null,
      canceledAt: null,
    },
    createdAt: new Date('2026-01-01T00:00:00.000Z'),
    updatedAt: new Date('2026-01-01T00:00:00.000Z'),
    ...overrides,
  };
}

test('booking authority: normalizes missing availability settings safely', () => {
  assert.equal(normalizeAvailabilitySettings(null), null);
  const normalized = normalizeAvailabilitySettings({});
  assert.equal(normalized.allowSameDayBookings, false);
  assert.equal(normalized.minBookingPrice, null);
  assert.equal(normalized.days.length, 7);
  assert.deepEqual(normalized.days[0], {
    isEnabled: false,
    startMinutes: 540,
    endMinutes: 1020,
  });
});

test('booking authority: parses weekday and time consistently', () => {
  assert.equal(parseTimeToMinutes('10:30'), 630);
  assert.equal(parseTimeToMinutes('25:00'), null);
  assert.equal(weekdayIndex('2026-02-02'), 1);
});

test('booking authority: rejects bookings below photographer minimum', () => {
  const result = validateBookingAgainstAvailability({
    booking: makeBooking({ price: 100 }),
    availabilitySettings: makeAvailability({ minBookingPrice: 150 }),
    now: new Date('2026-01-01T00:00:00.000Z'),
  });
  assert.equal(result, 'booking_price_below_minimum');
});

test('booking authority: rejects same-day bookings when disabled', () => {
  const now = new Date('2026-02-02T09:00:00.000Z');
  const result = validateBookingAgainstAvailability({
    booking: makeBooking({ date: toBaghdadDateString(now) }),
    availabilitySettings: makeAvailability({ allowSameDayBookings: false }),
    now,
  });
  assert.equal(result, 'same_day_booking_unavailable');
});

test('booking authority: rejects disabled days', () => {
  const result = validateBookingAgainstAvailability({
    booking: makeBooking({ date: '2026-02-06' }),
    availabilitySettings: makeAvailability(),
    now: new Date('2026-01-01T00:00:00.000Z'),
  });
  assert.equal(result, 'photographer_unavailable_day');
});

test('booking authority: rejects times outside working hours', () => {
  const result = validateBookingAgainstAvailability({
    booking: makeBooking({ time: '08:00' }),
    availabilitySettings: makeAvailability(),
    now: new Date('2026-01-01T00:00:00.000Z'),
  });
  assert.equal(result, 'photographer_unavailable_time');
});

test('booking authority: rejects overlapping active bookings', () => {
  const result = validateBookingAgainstAvailability({
    booking: makeBooking({ date: '2026-02-02', time: '10:00', duration: 120 }),
    availabilitySettings: makeAvailability(),
    existingBookings: [
      {
        id: 'existing-booking',
        date: '2026-02-02',
        time: '11:00',
        duration: 60,
        status: 'confirmed',
      },
    ],
    now: new Date('2026-01-01T00:00:00.000Z'),
  });
  assert.equal(result, 'booking_time_conflict');
});

test('booking authority: allows valid slots', () => {
  const result = validateBookingAgainstAvailability({
    booking: makeBooking({ date: '2026-02-02', time: '10:00', duration: 60 }),
    availabilitySettings: makeAvailability(),
    existingBookings: [
      {
        id: 'later-booking',
        date: '2026-02-02',
        time: '12:30',
        duration: 60,
        status: 'confirmed',
      },
    ],
    now: new Date('2026-01-01T00:00:00.000Z'),
  });
  assert.equal(result, null);
});

test('booking authority: builds booking payload from request and offer server-side', () => {
  const now = new Date('2026-01-01T08:00:00.000Z');
  const booking = buildBookingForAcceptedOffer({
    bookingId: 'book1',
    requestId: 'req1',
    offerId: 'offer1',
    customerId: 'cust1',
    now,
    requestData: {
      date: '2026-02-02',
      time: '10:00',
      duration: 2,
      type: 'Wedding',
      notes: 'Need classic edit',
      latitude: 33.3,
      longitude: 44.4,
      locationLabel: 'Baghdad',
    },
    offerData: {
      photographerId: 'photog1',
      price: 250,
      currency: 'IQD',
      deliverables: {
        photosCount: 40,
        videoMinutes: null,
        includesEditing: true,
        includesVideo: false,
        notes: null,
      },
    },
    bookingInput: {
      location: { lat: 1, lng: 2, text: 'Custom location' },
    },
  });

  assert.equal(booking.customerId, 'cust1');
  assert.equal(booking.photographerId, 'photog1');
  assert.equal(booking.duration, 120);
  assert.equal(booking.status, 'pending');
  assert.equal(booking.payment.status, 'pending');
  assert.deepEqual(booking.location, {
    lat: 1,
    lng: 2,
    text: 'Custom location',
  });
  assert.equal(booking.notes, 'Need classic edit');
});
