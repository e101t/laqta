# Courses Feature — REST API Spec for the `api.laqta.cloud` Backend

## Context

The Flutter app's courses feature (`lib/features/courses/`) calls these REST endpoints
via `BackendApiClient`, mirroring the existing booking/payment REST calls
(`/payments/payment-intents`, etc.). **These endpoints must be implemented in the
`api.laqta.cloud` backend service (a separate repository, not this one).**

The exact business logic each endpoint must implement is already written, tested, and
deployed as Firebase Cloud Functions in `functions/index.js` and `functions/courses.js`
in *this* repo — use those as the reference implementation. The 57-test suite in
`functions/test/` (`courses.test.js`, `firestore_rules.test.js`) documents the expected
behavior precisely.

## Endpoints needed

### `POST /courses/enrollments`
Mirrors `exports.createCourseEnrollment` in `functions/index.js`.

Request body: `{ "courseId": string }`
Response: `{ "enrollmentId": string }`

Logic:
1. Require authenticated user.
2. Load `courses/{courseId}` from Firestore. 404 if missing.
3. Reject (`failed-precondition`) if the caller is the course's own
   `photographerId` — photographers cannot enroll in their own course.
4. Reject if `isPublished !== true` ("course not available for enrollment") or
   `seatsRemaining <= 0` ("no seats remaining").
5. Create a `course_enrollments` doc: `{ courseId, photographerId, customerId: callerUid,
   payment: { status: "pending", intentId: null, amount: null, paidAt: null },
   status: "pending_payment", createdAt, updatedAt }`.
6. Return the new doc id as `enrollmentId`.

### `POST /payments/course-enrollments/payment-intents`
Mirrors `exports.createCourseEnrollmentPaymentIntent`.

Request body: `{ "enrollmentId": string, "amount": number, "currency": string }`
Response: `{ "paymentIntentId": string, "clientSecret": string }`
(The Flutter client also accepts a `{ "paymentIntent": {...} }` wrapper — see
`BackendCourseEnrollmentRemoteDataSource.createEnrollmentPaymentIntent`.)

Logic:
1. Require authenticated user.
2. Load the enrollment; require `enrollment.customerId === callerUid` (permission-denied
   otherwise).
3. Load the enrollment's course; validate `amount`/`currency` against
   `course.basePrice`/`course.currency` using the same rules as
   `payment_validation.js`'s `validateAmountAndCurrency` (amount must round-match,
   currency must match and be in the allowed set).
4. Create a Stripe PaymentIntent with `metadata: { courseEnrollmentId, courseId,
   userId: callerUid }` and an idempotency key of
   `create_course_intent_${enrollmentId}_${roundedAmount}_${currency}`.
5. Return `{ paymentIntentId, clientSecret }`.

### `POST /payments/course-enrollments/payment-intents/confirm`
Mirrors `exports.confirmCourseEnrollmentPayment`. **This is the most important endpoint
to get exactly right — it enforces seat capacity atomically.**

Request body: `{ "enrollmentId": string, "paymentIntentId": string, "amount": number }`
Response: `{ "ok": true }`

Logic:
1. Require authenticated user; require `enrollment.customerId === callerUid`.
2. Re-validate amount/currency against the course price (same as above).
3. Retrieve the PaymentIntent from Stripe; require `status === "succeeded"`, and that
   `intent.amount`/`intent.currency` exactly match the expected course price, and that
   `intent.metadata.courseEnrollmentId === enrollmentId` and
   `intent.metadata.userId === callerUid`.
4. **Inside a single Firestore transaction**: read both the enrollment and course docs.
   - If `enrollment.payment.status === "succeeded"` already, return `{ ok: true }`
     as a no-op (idempotent re-confirmation — a client retry must not double-process).
   - Otherwise read `course.seatsRemaining`; if `<= 0`, fail with
     `resource-exhausted` ("no seats remaining") — **do not let this race**.
   - Update the enrollment: `payment.status = "succeeded"`, `payment.intentId`,
     `payment.amount`, `payment.paidAt = now`, `status = "confirmed"`.
   - Update the course: `seatsRemaining = seatsRemaining - 1`.
   - Both writes must happen in the same transaction as the read, so two concurrent
     confirmations for the last seat cannot both succeed.

### `GET /courses` and course CRUD
**Not needed as REST endpoints.** Course browsing, creation, editing, and deletion are
all done by the Flutter app writing directly to Firestore (`courses` collection),
protected by `firestore.rules` (photographer owns/writes, public read when
`isPublished == true`). No backend REST involvement required for these — only
enrollment + payment need server-side logic, because only those require the atomic
seat-capacity transaction above.

### Notifications
`POST /notifications` (already exists for booking notifications) is reused as-is — the
Flutter app now calls it with `type: "course"` and `data: { courseEnrollmentId }` after
a successful course payment. If your backend's notification-permission logic mirrors
`createNotification` in `functions/index.js`, it needs the same `courseEnrollmentId`
branch added there (see lines ~888-906 of `functions/index.js` for the exact check:
caller and target user must each be either the enrollment's `customerId` or
`photographerId`).

## Verification

Once implemented, the existing Firestore-rules test suite
(`functions/test/courses.test.js`, parts of `firestore_rules.test.js`) and a manual
end-to-end pass (create course → publish → enroll → pay → confirm → check
`seatsRemaining` decremented exactly once, even under concurrent confirms for the last
seat) are the acceptance criteria.
