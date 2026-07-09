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

**Correction (post-launch finding):** an earlier version of this doc said course CRUD
didn't need REST endpoints because the Flutter client writes directly to Firestore.
That was wrong — the Flutter app has **no real Firestore client at all**
(`lib/core/utils/legacy_data_compat.dart` is an inert stub; every read/write through it
silently no-ops). Course CRUD and "my enrollments" listing **do** need real REST
endpoints, added below. `firestore.rules`'s `courses`/`course_enrollments` blocks are
therefore dead weight from the client's perspective (kept here only as a reference for
the validation logic the backend should replicate).

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

### Course CRUD — needed, mirrors `lib/features/requests/data/datasources/api_requests_remote_data_source.dart`'s style

`GET /courses` (optional query param `?specialty=Wedding`) — published courses only.
Response: `{ "courses": [ {...course}, ... ] }`.

`GET /courses/photographer/{photographerId}` — a photographer's own courses (including
unpublished drafts when the caller IS that photographer; published-only for anyone
else, or just require the caller to be that photographer and 403 otherwise — match
whatever auth model the rest of the backend uses for "my own resource" reads).

`GET /courses/{courseId}` — single course. Response: `{ "course": {...} }` (or the
course object directly — the Flutter client accepts either, see
`ApiCourseRemoteDataSource._readMap`).

`POST /courses` — photographer creates a course. Request body: the course fields minus
`id`/`seatsRemaining`/timestamps (see `CourseDto.toBackendCreateJson()` for the exact
shape: title, description, type, specialties, basePrice, currency, capacity, sessions,
location, meetingLink, thumbnailUrl, isPublished). Backend must set
`seatsRemaining = capacity` and `photographerId = callerUid` server-side — do not trust
client-supplied values for either field, matching the `isValidCourseCreate` check in
`firestore.rules` (`seatsRemaining == capacity` on create). Response: `{ "course": { "id": "...", ... } }`.

`PATCH /courses/{courseId}` — photographer updates their own course. Same body shape as
create. Reject (permission-denied) if caller isn't the course's `photographerId`. Do
NOT let this endpoint change `seatsRemaining` directly (that's only ever touched by the
payment-confirmation transaction above) — mirrors `isValidCourseOwnerUpdate`'s
`seatsRemaining == resource.data.seatsRemaining` invariant in `firestore.rules`.

`DELETE /courses/{courseId}` — photographer deletes their own course.

### `GET /courses/enrollments/my` — needed
The signed-in customer's own enrollments (any status). Response:
`{ "enrollments": [ {...enrollment}, ... ] }`. Mirrors `course_enrollments`'s read rule
(owner or that enrollment's photographer can read) — scope this endpoint to the caller's
own `customerId`.

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
