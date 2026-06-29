const test = require('node:test');
const assert = require('node:assert/strict');

const { validateEnrollmentEligibility } = require('../courses');

test('validateEnrollmentEligibility rejects missing course data', () => {
  assert.equal(validateEnrollmentEligibility(null), 'course_not_found');
});

test('validateEnrollmentEligibility rejects unpublished courses', () => {
  assert.equal(
    validateEnrollmentEligibility({ isPublished: false, seatsRemaining: 5 }),
    'course_not_published',
  );
});

test('validateEnrollmentEligibility rejects full courses', () => {
  assert.equal(
    validateEnrollmentEligibility({ isPublished: true, seatsRemaining: 0 }),
    'course_full',
  );
  assert.equal(
    validateEnrollmentEligibility({ isPublished: true, seatsRemaining: 'not-a-number' }),
    'course_full',
  );
});

test('validateEnrollmentEligibility allows published courses with seats', () => {
  assert.equal(
    validateEnrollmentEligibility({ isPublished: true, seatsRemaining: 3 }),
    null,
  );
});
