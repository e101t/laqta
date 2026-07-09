const ACTIVE_BOOKING_STATUSES = [
  "pending",
  "confirmed",
  "in_progress",
  "awaiting_delivery",
  "delivered",
  "revision_requested",
  "dispute_open",
];

function parseDateParts(date) {
  if (typeof date !== "string") return null;
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(date.trim());
  if (!match) return null;
  return {
    year: Number.parseInt(match[1], 10),
    month: Number.parseInt(match[2], 10),
    day: Number.parseInt(match[3], 10),
  };
}

function parseTimeToMinutes(time) {
  if (typeof time !== "string") return null;
  const match = /^(\d{2}):(\d{2})$/.exec(time.trim());
  if (!match) return null;
  const hour = Number.parseInt(match[1], 10);
  const minute = Number.parseInt(match[2], 10);
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    return null;
  }
  return hour * 60 + minute;
}

function weekdayIndex(date) {
  const parts = parseDateParts(date);
  if (!parts) return null;
  return new Date(Date.UTC(parts.year, parts.month - 1, parts.day)).getUTCDay();
}

function toBaghdadDateString(now = new Date()) {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Baghdad",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(now);

  const values = Object.fromEntries(parts.map((part) => [part.type, part.value]));
  return `${values.year}-${values.month}-${values.day}`;
}

function normalizeAvailabilitySettings(raw) {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    return null;
  }

  const days = Array.isArray(raw.days) ? raw.days : [];
  return {
    allowSameDayBookings: raw.allowSameDayBookings === true,
    minBookingPrice: Number.isFinite(raw.minBookingPrice)
      ? Number(raw.minBookingPrice)
      : null,
    days: Array.from({ length: 7 }, (_, index) => {
      const value = days[index];
      return {
        isEnabled: value?.isEnabled === true,
        startMinutes: Number.isFinite(value && value.startMinutes)
          ? Number(value.startMinutes)
          : 540,
        endMinutes: Number.isFinite(value && value.endMinutes)
          ? Number(value.endMinutes)
          : 1020,
      };
    }),
  };
}

function hasTimeOverlap(left, right) {
  return left.startMinutes < right.endMinutes && right.startMinutes < left.endMinutes;
}

function buildBookingForAcceptedOffer({
  bookingId,
  requestId,
  offerId,
  requestData,
  offerData,
  customerId,
  bookingInput,
  now = new Date(),
}) {
  const durationHours = Number(requestData.duration || 1);
  const durationMinutes = Math.max(1, Math.round(durationHours * 60));

  const location = bookingInput && bookingInput.location && typeof bookingInput.location === "object"
    ? bookingInput.location
    : {};

  return {
    customerId,
    photographerId: offerData.photographerId,
    requestId,
    offerId,
    date: String(requestData.date || ""),
    time: String(requestData.time || ""),
    duration: durationMinutes,
    type: String(requestData.type || ""),
    price: Number(offerData.price || 0),
    currency: String(offerData.currency || "IQD"),
    status: "pending",
    payment: {
      status: "pending",
      intentId: null,
      amount: null,
      paidAt: null,
    },
    location: {
      lat:
        Number.isFinite(location.lat) ? Number(location.lat) :
        Number.isFinite(requestData.latitude) ? Number(requestData.latitude) :
        null,
      lng:
        Number.isFinite(location.lng) ? Number(location.lng) :
        Number.isFinite(requestData.longitude) ? Number(requestData.longitude) :
        null,
      text:
        (typeof location.text === "string" && location.text.trim()) ||
        requestData.locationLabel ||
        requestData.address ||
        requestData.governorate ||
        null,
    },
    deliverables: offerData.deliverables || {
      photosCount: null,
      videoMinutes: null,
      includesEditing: false,
      includesVideo: false,
      notes: null,
    },
    notes: typeof requestData.notes === "string" ? requestData.notes : null,
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
    createdAt: now,
    updatedAt: now,
  };
}

function validateBookingAgainstAvailability({
  booking,
  availabilitySettings,
  existingBookings = [],
  now = new Date(),
}) {
  const normalized = normalizeAvailabilitySettings(availabilitySettings);
  if (!normalized) {
    return null;
  }

  const bookingPrice = Number(booking.price || 0);
  if (
    Number.isFinite(normalized.minBookingPrice) &&
    bookingPrice < normalized.minBookingPrice
  ) {
    return "booking_price_below_minimum";
  }

  if (
    normalized.allowSameDayBookings === false &&
    booking.date === toBaghdadDateString(now)
  ) {
    return "same_day_booking_unavailable";
  }

  const dayIndex = weekdayIndex(booking.date);
  const startMinutes = parseTimeToMinutes(booking.time);
  const durationMinutes = Number(booking.duration || 0);
  if (dayIndex == null || startMinutes == null || durationMinutes <= 0) {
    return "invalid_booking_schedule";
  }

  const day = normalized.days[dayIndex];
  if (!day || !day.isEnabled) {
    return "photographer_unavailable_day";
  }

  const endMinutes = startMinutes + durationMinutes;
  if (startMinutes < day.startMinutes || endMinutes > day.endMinutes) {
    return "photographer_unavailable_time";
  }

  const requestedSlot = { startMinutes, endMinutes };
  const conflicting = existingBookings.some((item) => {
    if (!item || item.date !== booking.date) return false;
    if (!ACTIVE_BOOKING_STATUSES.includes(item.status)) return false;
    const existingStart = parseTimeToMinutes(item.time);
    const existingDuration = Number(item.duration || 0);
    if (existingStart == null || existingDuration <= 0) return false;
    return hasTimeOverlap(requestedSlot, {
      startMinutes: existingStart,
      endMinutes: existingStart + existingDuration,
    });
  });

  return conflicting ? "booking_time_conflict" : null;
}

module.exports = {
  ACTIVE_BOOKING_STATUSES,
  buildBookingForAcceptedOffer,
  normalizeAvailabilitySettings,
  parseTimeToMinutes,
  toBaghdadDateString,
  validateBookingAgainstAvailability,
  weekdayIndex,
};
