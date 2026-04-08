const functions = require("firebase-functions");
const admin = require("firebase-admin");
const Stripe = require("stripe");

admin.initializeApp();
const db = admin.firestore();

const stripeSecret =
  (functions.config().stripe && functions.config().stripe.secret) ||
  process.env.STRIPE_SECRET_KEY;

const stripe = stripeSecret
  ? Stripe(stripeSecret, { apiVersion: "2023-10-16" })
  : null;

const {
  normalizeCurrency,
  toNumber,
  validateAmountAndCurrency,
} = require("./payment_validation");
const {
  buildPublicUserData,
  sanitizeProfilePayload,
} = require("./profile_validation");

async function getBookingOrThrow(bookingId) {
  if (typeof bookingId !== "string" || bookingId.trim().length === 0) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invalid bookingId.",
    );
  }
  const doc = await db.collection("bookings").doc(bookingId).get();
  if (!doc.exists) {
    throw new functions.https.HttpsError("not-found", "Booking not found.");
  }
  return { id: doc.id, data: doc.data() || {} };
}

function assertBookingOwnership(booking, userId) {
  if (!userId || booking.data.customerId !== userId) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "You do not own this booking.",
    );
  }
}

function assertAmountAndCurrency(booking, amount, currency) {
  const error = validateAmountAndCurrency(booking.data, amount, currency);
  if (!error) return;
  if (error === "invalid_booking_amount") {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Booking amount is invalid.",
    );
  }
  if (error === "currency_mismatch") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Currency does not match booking.",
    );
  }
  throw new functions.https.HttpsError(
    "invalid-argument",
    "Amount does not match booking.",
  );
}

function isPlainObject(value) {
  return value != null && typeof value === "object" && !Array.isArray(value);
}

exports.saveUserProfile = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required.",
    );
  }

  const source = isPlainObject(data) ? data : {};
  const userId =
    typeof source.userId === "string" && source.userId.trim()
      ? source.userId.trim()
      : context.auth.uid;
  if (userId !== context.auth.uid) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "You cannot modify another user profile.",
    );
  }

  const createIfMissing = Boolean(source.createIfMissing);
  const sanitized = sanitizeProfilePayload(source.profile ?? source);
  if (!sanitized.ok) {
    throw new functions.https.HttpsError(
      sanitized.code,
      sanitized.message,
    );
  }

  const payload = sanitized.payload || {};
  const serverTimestamp = admin.firestore.FieldValue.serverTimestamp();
  const usersRef = db.collection("users").doc(userId);
  const publicRef = db.collection("users_public").doc(userId);
  const claimsRef = db.collection("username_claims");

  await db.runTransaction(async (tx) => {
    const userSnap = await tx.get(usersRef);
    const existing = userSnap.exists ? userSnap.data() || {} : {};
    const oldUsername =
      typeof existing.usernameLower === "string" ? existing.usernameLower : null;
    const nextUsername =
      typeof payload.usernameLower === "string"
        ? payload.usernameLower
        : oldUsername;

    if (createIfMissing && !nextUsername) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Username is required.",
      );
    }

    if (nextUsername) {
      const claimRef = claimsRef.doc(nextUsername);
      const claimSnap = await tx.get(claimRef);
      const claimedBy =
        claimSnap.exists && claimSnap.data()
          ? claimSnap.data().userId
          : null;
      if (claimedBy && claimedBy !== userId) {
        throw new functions.https.HttpsError(
          "already-exists",
          "Username is already taken.",
        );
      }

      tx.set(
        claimRef,
        {
          userId,
          usernameLower: nextUsername,
          createdAt: claimSnap.exists
            ? claimSnap.data().createdAt || serverTimestamp
            : serverTimestamp,
          updatedAt: serverTimestamp,
        },
        { merge: true },
      );

      if (oldUsername && oldUsername !== nextUsername) {
        tx.delete(claimsRef.doc(oldUsername));
      }
    }

    const basePayload =
      createIfMissing && !userSnap.exists
        ? {
            uid: userId,
            lang: "ar",
            photoUrl: null,
            fcmToken: null,
            lastSeen: null,
            blockedUsers: [],
            interests: [],
            createdAt: serverTimestamp,
          }
        : {};

    const nextUserData = {
      ...basePayload,
      ...payload,
      updatedAt: serverTimestamp,
    };

    tx.set(usersRef, nextUserData, { merge: true });

    const mergedForPublic = {
      ...existing,
      ...basePayload,
      ...payload,
    };
    tx.set(
      publicRef,
      buildPublicUserData(mergedForPublic, serverTimestamp),
      { merge: true },
    );
  });

  return { ok: true };
});

exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required.",
    );
  }

  if (!stripe) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Stripe secret key is not configured.",
    );
  }

  const amount = toNumber(data.amount);
  const bookingId = typeof data.bookingId === "string" ? data.bookingId : "";
  const currency = normalizeCurrency(data.currency || "iqd");
  const booking = await getBookingOrThrow(bookingId);
  assertBookingOwnership(booking, context.auth.uid);
  assertAmountAndCurrency(booking, amount, currency);

  const intent = await stripe.paymentIntents.create(
    {
      amount: Math.round(amount),
      currency,
      automatic_payment_methods: { enabled: true },
      metadata: {
        bookingId,
        userId: context.auth.uid,
      },
    },
    {
      idempotencyKey: `create_intent_${bookingId}_${Math.round(amount)}_${currency}`,
    },
  );

  if (!intent.client_secret) {
    throw new functions.https.HttpsError(
      "internal",
      "Failed to create payment intent.",
    );
  }

  return {
    paymentIntentId: intent.id,
    clientSecret: intent.client_secret,
  };
});

exports.confirmPaymentIntent = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required.",
    );
  }

  if (!stripe) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Stripe secret key is not configured.",
    );
  }

  const bookingId = typeof data.bookingId === "string" ? data.bookingId : "";
  const paymentIntentId =
    typeof data.paymentIntentId === "string" ? data.paymentIntentId : "";
  if (!paymentIntentId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invalid paymentIntentId.",
    );
  }
  const amount = toNumber(data.amount);
  const booking = await getBookingOrThrow(bookingId);
  assertBookingOwnership(booking, context.auth.uid);

  const currency = normalizeCurrency(booking.data.currency || "iqd");
  assertAmountAndCurrency(booking, amount, currency);

  const expectedAmount = Math.round(toNumber(booking.data.price));
  if (!Number.isFinite(expectedAmount) || expectedAmount <= 0) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Booking amount is invalid.",
    );
  }

  let intent;
  try {
    intent = await stripe.paymentIntents.retrieve(paymentIntentId);
  } catch (_) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invalid paymentIntentId.",
    );
  }
  if (!intent || intent.status !== "succeeded") {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Payment not completed.",
    );
  }

  if (
    normalizeCurrency(intent.currency) !== currency ||
    intent.amount !== expectedAmount
  ) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "PaymentIntent does not match booking.",
    );
  }

  if (
    !intent.metadata ||
    intent.metadata.bookingId !== bookingId ||
    intent.metadata.userId !== context.auth.uid
  ) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "PaymentIntent is not associated with this booking.",
    );
  }

  await db.runTransaction(async (tx) => {
    const ref = db.collection("bookings").doc(bookingId);
    const doc = await tx.get(ref);
    if (!doc.exists) {
      throw new functions.https.HttpsError("not-found", "Booking not found.");
    }
    const data = doc.data() || {};
    if (data.payment && data.payment.status === "succeeded") {
      return;
    }
    tx.update(ref, {
      "payment.status": "succeeded",
      "payment.intentId": intent.id,
      "payment.paidAt": admin.firestore.FieldValue.serverTimestamp(),
      "payment.amount": intent.amount,
      status: "confirmed",
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return { ok: true };
});

exports.createNotification = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required.",
    );
  }

  const userId = typeof data.userId === "string" ? data.userId : "";
  if (!userId) {
    throw new functions.https.HttpsError("invalid-argument", "Invalid userId.");
  }

  const callerId = context.auth.uid;
  const isAdmin = !!context.auth.token?.admin;

  const payload = {
    userId,
    title: typeof data.title === "string" ? data.title : "",
    body: typeof data.body === "string" ? data.body : "",
    type: typeof data.type === "string" ? data.type : "system",
    data: isPlainObject(data.data) ? data.data : null,
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    imageUrl: typeof data.imageUrl === "string" ? data.imageUrl : null,
    actionUrl: typeof data.actionUrl === "string" ? data.actionUrl : null,
  };

  const bookingId =
    payload.data && typeof payload.data.bookingId === "string"
      ? payload.data.bookingId
      : "";
  const requestId =
    payload.data && typeof payload.data.requestId === "string"
      ? payload.data.requestId
      : "";

  if (bookingId) {
    const booking = await getBookingOrThrow(bookingId);
    if (
      booking.data.customerId !== callerId &&
      booking.data.photographerId !== callerId &&
      !isAdmin
    ) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Not allowed to send booking notification.",
      );
    }

    if (
      userId !== booking.data.customerId &&
      userId !== booking.data.photographerId &&
      !isAdmin
    ) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Not allowed to notify this user for the booking.",
      );
    }
  } else if (requestId) {
    const requestDoc = await db.collection("requests").doc(requestId).get();
    if (!requestDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Request not found.");
    }
    const requestData = requestDoc.data() || {};
    const clientId = requestData.clientId;
    const selectedPhotographerId = requestData.selectedPhotographerId;
    const requestStatus = requestData.status;

    const isRequestOwner = clientId === callerId;
    const isOfferPhotographer = async () => {
      const offerSnap = await db
        .collection("offers")
        .where("requestId", "==", requestId)
        .where("photographerId", "==", callerId)
        .limit(1)
        .get();
      return !offerSnap.empty;
    };

    const canSendAsPhotographer =
      !isAdmin && !isRequestOwner ? await isOfferPhotographer() : false;

    if (!isAdmin && !isRequestOwner && !canSendAsPhotographer) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Not allowed to send request notification.",
      );
    }

    if (!isAdmin) {
      if (isRequestOwner) {
        if (userId !== clientId && requestStatus === "draft") {
          throw new functions.https.HttpsError(
            "failed-precondition",
            "Cannot notify other users for a draft request.",
          );
        }
        if (userId === clientId) {
          // allowed
        } else if (
          selectedPhotographerId &&
          userId === selectedPhotographerId
        ) {
          // allowed
        } else {
          const recipient = await db
            .collection("users_public")
            .doc(userId)
            .get();
          const recipientData = recipient.exists ? recipient.data() || {} : {};
          const isPhotographer = recipientData.role === "photographer";
          const sameGovernorate =
            recipientData.governorate &&
            requestData.governorate &&
            recipientData.governorate === requestData.governorate;
          if (isPhotographer && sameGovernorate) {
            // allowed
          } else {
            const offerSnap = await db
              .collection("offers")
              .where("requestId", "==", requestId)
              .where("photographerId", "==", userId)
              .limit(1)
              .get();
            if (offerSnap.empty) {
              throw new functions.https.HttpsError(
                "permission-denied",
                "Not allowed to notify this user for the request.",
              );
            }
          }
        }
      } else {
        if (requestStatus === "draft") {
          throw new functions.https.HttpsError(
            "failed-precondition",
            "Cannot notify about a draft request.",
          );
        }
        // Photographer can only notify the request owner.
        if (userId !== clientId) {
          throw new functions.https.HttpsError(
            "permission-denied",
            "Not allowed to notify this user for the request.",
          );
        }
      }
    }
  } else if (userId !== callerId && !isAdmin) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Not allowed to send notification.",
    );
  }

  await db.collection("notifications").add(payload);
  return { ok: true };
});

async function getBookingForTrust(bookingId, photographerId) {
  const booking = await getBookingOrThrow(bookingId);
  if (booking.data.photographerId !== photographerId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Photographer does not match booking.",
    );
  }
  return booking;
}

exports.incrementTrustReviewStats = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required.",
      );
    }
    const bookingId = typeof data.bookingId === "string" ? data.bookingId : "";
    const photographerId =
      typeof data.photographerId === "string" ? data.photographerId : "";
    const booking = await getBookingForTrust(bookingId, photographerId);
    if (booking.data.customerId !== context.auth.uid) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only the customer can submit a review.",
      );
    }

    if (!["done", "completed"].includes(booking.data.status)) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Booking is not eligible for review.",
      );
    }

    const reviewSnap = await db
      .collection("reviews")
      .where("bookingId", "==", bookingId)
      .where("reviewerId", "==", context.auth.uid)
      .where("targetId", "==", photographerId)
      .limit(1)
      .get();
    if (reviewSnap.empty) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Review not found for this booking.",
      );
    }

    const reviewDoc = reviewSnap.docs[0];
    const reviewData = reviewDoc.data() || {};
    const quality = toNumber(reviewData.qualityRating);
    const communication = toNumber(reviewData.communicationRating);
    const onTime = toNumber(reviewData.onTimeRating);
    const deliverySpeed = toNumber(reviewData.deliverySpeedRating);
    if (
      quality == null ||
      quality < 1 ||
      quality > 5 ||
      communication == null ||
      communication < 1 ||
      communication > 5 ||
      onTime == null ||
      onTime < 1 ||
      onTime > 5 ||
      deliverySpeed == null ||
      deliverySpeed < 1 ||
      deliverySpeed > 5
    ) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Invalid review ratings.",
      );
    }

    const eventRef = db
      .collection("trust_events")
      .doc(`review_${bookingId}_${context.auth.uid}`);
    const statsRef = db.collection("trust_stats").doc(photographerId);

    await db.runTransaction(async (tx) => {
      const existing = await tx.get(eventRef);
      if (existing.exists) return;

      tx.set(
        statsRef,
        {
          photographerId,
          reviewCount: admin.firestore.FieldValue.increment(1),
          sumQuality: admin.firestore.FieldValue.increment(quality),
          sumCommunication: admin.firestore.FieldValue.increment(communication),
          sumOnTime: admin.firestore.FieldValue.increment(onTime),
          sumDelivery: admin.firestore.FieldValue.increment(deliverySpeed),
          completedBookings: admin.firestore.FieldValue.increment(0),
          canceledByPhotographer: admin.firestore.FieldValue.increment(0),
          disputesCount: admin.firestore.FieldValue.increment(0),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      tx.create(eventRef, {
        type: "review",
        bookingId,
        photographerId,
        reviewerId: context.auth.uid,
        reviewId: reviewDoc.id,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    return { ok: true };
  },
);

exports.incrementTrustCompletedBookings = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required.",
      );
    }
    const bookingId = typeof data.bookingId === "string" ? data.bookingId : "";
    const photographerId =
      typeof data.photographerId === "string" ? data.photographerId : "";
    const booking = await getBookingForTrust(bookingId, photographerId);
    if (booking.data.customerId !== context.auth.uid) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only the customer can complete a booking.",
      );
    }

    if (booking.data.status !== "completed") {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Booking is not completed.",
      );
    }

    const eventRef = db
      .collection("trust_events")
      .doc(`completed_${bookingId}`);
    const statsRef = db.collection("trust_stats").doc(photographerId);
    await db.runTransaction(async (tx) => {
      const existing = await tx.get(eventRef);
      if (existing.exists) return;

      tx.set(
        statsRef,
        {
          photographerId,
          reviewCount: admin.firestore.FieldValue.increment(0),
          sumQuality: admin.firestore.FieldValue.increment(0),
          sumCommunication: admin.firestore.FieldValue.increment(0),
          sumOnTime: admin.firestore.FieldValue.increment(0),
          sumDelivery: admin.firestore.FieldValue.increment(0),
          completedBookings: admin.firestore.FieldValue.increment(1),
          canceledByPhotographer: admin.firestore.FieldValue.increment(0),
          disputesCount: admin.firestore.FieldValue.increment(0),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      tx.create(eventRef, {
        type: "completed",
        bookingId,
        photographerId,
        actorId: context.auth.uid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
    return { ok: true };
  },
);

exports.incrementTrustCanceledByPhotographer = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required.",
      );
    }
    const bookingId = typeof data.bookingId === "string" ? data.bookingId : "";
    const photographerId =
      typeof data.photographerId === "string" ? data.photographerId : "";
    const booking = await getBookingForTrust(bookingId, photographerId);
    if (booking.data.photographerId !== context.auth.uid) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only the photographer can record cancellations.",
      );
    }

    if (
      booking.data.status !== "canceled" ||
      booking.data.canceledBy !== context.auth.uid
    ) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "Booking is not canceled by the photographer.",
      );
    }

    const eventRef = db.collection("trust_events").doc(`canceled_${bookingId}`);
    const statsRef = db.collection("trust_stats").doc(photographerId);
    await db.runTransaction(async (tx) => {
      const existing = await tx.get(eventRef);
      if (existing.exists) return;

      tx.set(
        statsRef,
        {
          photographerId,
          reviewCount: admin.firestore.FieldValue.increment(0),
          sumQuality: admin.firestore.FieldValue.increment(0),
          sumCommunication: admin.firestore.FieldValue.increment(0),
          sumOnTime: admin.firestore.FieldValue.increment(0),
          sumDelivery: admin.firestore.FieldValue.increment(0),
          completedBookings: admin.firestore.FieldValue.increment(0),
          canceledByPhotographer: admin.firestore.FieldValue.increment(1),
          disputesCount: admin.firestore.FieldValue.increment(0),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      tx.create(eventRef, {
        type: "canceled_by_photographer",
        bookingId,
        photographerId,
        actorId: context.auth.uid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
    return { ok: true };
  },
);

exports.incrementTrustDisputesCount = functions.https.onCall(
  async (data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required.",
      );
    }
    const bookingId = typeof data.bookingId === "string" ? data.bookingId : "";
    const photographerId =
      typeof data.photographerId === "string" ? data.photographerId : "";
    const booking = await getBookingForTrust(bookingId, photographerId);
    if (
      booking.data.customerId !== context.auth.uid &&
      booking.data.photographerId !== context.auth.uid
    ) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Only booking participants can open disputes.",
      );
    }

    const disputeSnap = await db
      .collection("disputes")
      .where("bookingId", "==", bookingId)
      .where("status", "==", "open")
      .limit(1)
      .get();
    if (disputeSnap.empty) {
      throw new functions.https.HttpsError(
        "failed-precondition",
        "No open dispute found for this booking.",
      );
    }
    const disputeData = disputeSnap.docs[0].data() || {};
    if (
      disputeData.photographerId !== photographerId ||
      disputeData.openedBy !== context.auth.uid
    ) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Not allowed to record dispute for this booking.",
      );
    }

    const eventRef = db.collection("trust_events").doc(`dispute_${bookingId}`);
    const statsRef = db.collection("trust_stats").doc(photographerId);
    await db.runTransaction(async (tx) => {
      const existing = await tx.get(eventRef);
      if (existing.exists) return;

      tx.set(
        statsRef,
        {
          photographerId,
          reviewCount: admin.firestore.FieldValue.increment(0),
          sumQuality: admin.firestore.FieldValue.increment(0),
          sumCommunication: admin.firestore.FieldValue.increment(0),
          sumOnTime: admin.firestore.FieldValue.increment(0),
          sumDelivery: admin.firestore.FieldValue.increment(0),
          completedBookings: admin.firestore.FieldValue.increment(0),
          canceledByPhotographer: admin.firestore.FieldValue.increment(0),
          disputesCount: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      tx.create(eventRef, {
        type: "dispute_opened",
        bookingId,
        photographerId,
        actorId: context.auth.uid,
        disputeId: disputeSnap.docs[0].id,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });
    return { ok: true };
  },
);

exports.updateReelCounter = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required.",
    );
  }
  const reelId = typeof data.reelId === "string" ? data.reelId : "";
  const field = typeof data.field === "string" ? data.field : "";
  const delta = toNumber(data.delta);
  if (!reelId || !["shares", "comments", "views"].includes(field)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invalid reel update.",
    );
  }
  if (delta == null || delta < 0 || delta > 1) {
    throw new functions.https.HttpsError("invalid-argument", "Invalid delta.");
  }
  await db
    .collection("reels")
    .doc(reelId)
    .update({
      [field]: admin.firestore.FieldValue.increment(delta),
    });
  return { ok: true };
});

exports.updateReelLike = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required.",
    );
  }
  const reelId = typeof data.reelId === "string" ? data.reelId : "";
  const delta = toNumber(data.delta);
  if (!reelId || (delta !== 1 && delta !== -1)) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Invalid like update.",
    );
  }
  const userId = context.auth.uid;
  const reelRef = db.collection("reels").doc(reelId);
  const likeRef = db
    .collection("reel_likes")
    .doc(reelId)
    .collection("users")
    .doc(userId);

  await db.runTransaction(async (tx) => {
    const reelDoc = await tx.get(reelRef);
    if (!reelDoc.exists) {
      throw new functions.https.HttpsError("not-found", "Reel not found.");
    }
    const likeDoc = await tx.get(likeRef);
    if (delta === 1) {
      if (likeDoc.exists) return;
      tx.set(likeRef, {
        userId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      tx.update(reelRef, {
        likes: admin.firestore.FieldValue.increment(1),
      });
    } else {
      if (!likeDoc.exists) return;
      tx.delete(likeRef);
      tx.update(reelRef, {
        likes: admin.firestore.FieldValue.increment(-1),
      });
    }
  });

  return { ok: true };
});

function parseBool(value, fallbackValue) {
  if (typeof value === "boolean") return value;
  if (typeof value === "number") return value !== 0;
  if (typeof value !== "string") return fallbackValue;
  const normalized = value.trim().toLowerCase();
  if (["1", "true", "yes", "y", "on"].includes(normalized)) return true;
  if (["0", "false", "no", "n", "off"].includes(normalized)) return false;
  return fallbackValue;
}

function parseIntOrNull(value) {
  if (typeof value === "number" && Number.isFinite(value))
    return Math.trunc(value);
  if (typeof value !== "string") return null;
  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) ? parsed : null;
}

function clampInt(value, min, max) {
  const safe = Number.isFinite(value) ? value : min;
  return Math.max(min, Math.min(max, safe));
}

async function deleteCollectionDocs(collectionRef, batchSize = 250) {
  let deleted = 0;
  while (true) {
    const snap = await collectionRef.limit(batchSize).get();
    if (snap.empty) break;
    const batch = db.batch();
    for (const doc of snap.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
    deleted += snap.size;
    if (snap.size < batchSize) break;
  }
  return deleted;
}

async function deleteFilesWithPrefix(prefix) {
  if (!prefix) return 0;
  const bucket = admin.storage().bucket();
  try {
    const [files] = await bucket.getFiles({ prefix });
    if (!files.length) return 0;
    const results = await Promise.allSettled(files.map((f) => f.delete()));
    return results.filter((r) => r.status === "fulfilled").length;
  } catch (_) {
    return 0;
  }
}

async function deleteDocsByQuery(query, batchSize = 250) {
  let deleted = 0;
  while (true) {
    const snap = await query.limit(batchSize).get();
    if (snap.empty) break;
    const batch = db.batch();
    for (const document of snap.docs) {
      batch.delete(document.ref);
    }
    await batch.commit();
    deleted += snap.size;
    if (snap.size < batchSize) break;
  }
  return deleted;
}

function isActiveBookingStatus(status) {
  return [
    "pending",
    "confirmed",
    "in_progress",
    "awaiting_delivery",
    "delivered",
    "revision_requested",
    "dispute_open",
  ].includes(status);
}

function isActiveRequestStatus(status) {
  return ["draft", "published", "awaiting_offers", "offer_selected"].includes(
    status,
  );
}

async function getUserScopedDocs(collectionName, fieldName, userId) {
  const snap = await db
    .collection(collectionName)
    .where(fieldName, "==", userId)
    .get();
  return snap.docs;
}

async function assertAccountDeletionAllowed(userId) {
  const bookingDocs = [
    ...(await getUserScopedDocs("bookings", "customerId", userId)),
    ...(await getUserScopedDocs("bookings", "photographerId", userId)),
  ];
  const activeBookings = bookingDocs.filter((doc) =>
    isActiveBookingStatus((doc.data() || {}).status),
  );
  if (activeBookings.length > 0) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Cannot delete account while active bookings still exist.",
    );
  }

  const requestDocs = await getUserScopedDocs("requests", "clientId", userId);
  const activeRequests = requestDocs.filter((doc) =>
    isActiveRequestStatus((doc.data() || {}).status),
  );
  if (activeRequests.length > 0) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Cannot delete account while active requests still exist.",
    );
  }

  const disputeDocs = [
    ...(await getUserScopedDocs("disputes", "customerId", userId)),
    ...(await getUserScopedDocs("disputes", "photographerId", userId)),
  ];
  const openDisputes = disputeDocs.filter(
    (doc) => (doc.data() || {}).status === "open",
  );
  if (openDisputes.length > 0) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Cannot delete account while open disputes still exist.",
    );
  }
}

async function cleanupOwnedStories(userId) {
  const snap = await db
    .collection("stories")
    .where("photographerId", "==", userId)
    .get();
  let deletedStories = 0;
  let deletedViews = 0;

  for (const storyDoc of snap.docs) {
    deletedViews += await deleteCollectionDocs(
      storyDoc.ref.collection("views"),
    );
    await storyDoc.ref.delete();
    deletedStories += 1;
  }

  const deletedFiles = await deleteFilesWithPrefix(`stories/${userId}/`);
  return { deletedStories, deletedViews, deletedFiles };
}

async function cleanupOwnedReels(userId) {
  const reelSnap = await db
    .collection("reels")
    .where("photographerId", "==", userId)
    .get();
  let deletedReels = 0;
  let deletedComments = 0;
  let deletedLikes = 0;

  for (const reelDoc of reelSnap.docs) {
    deletedComments += await deleteDocsByQuery(
      db.collection("comments").where("reelId", "==", reelDoc.id),
    );
    const likesDoc = db.collection("reel_likes").doc(reelDoc.id);
    deletedLikes += await deleteCollectionDocs(likesDoc.collection("users"));
    try {
      await likesDoc.delete();
    } catch (_) {
      // Best-effort cleanup.
    }
    await reelDoc.ref.delete();
    deletedReels += 1;
  }

  deletedComments += await deleteDocsByQuery(
    db.collection("comments").where("userId", "==", userId),
  );

  const deletedFiles = await deleteFilesWithPrefix(`reels/${userId}/`);
  return { deletedReels, deletedComments, deletedLikes, deletedFiles };
}

async function cleanupPortfolio(userId) {
  const deletedPortfolios = await deleteDocsByQuery(
    db.collection("portfolios").where("photographerId", "==", userId),
  );
  const deletedFiles = await deleteFilesWithPrefix(
    `photographers/${userId}/portfolio/`,
  );
  return { deletedPortfolios, deletedFiles };
}

async function cleanupRequestsForDeletedUser(userId) {
  const snap = await db
    .collection("requests")
    .where("clientId", "==", userId)
    .get();
  let deletedRequests = 0;
  let scrubbedRequests = 0;
  let deletedOffers = 0;
  let deletedReferenceFiles = 0;

  for (const requestDoc of snap.docs) {
    const data = requestDoc.data() || {};
    const requestId = requestDoc.id;
    const selectedPhotographerId =
      typeof data.selectedPhotographerId === "string"
        ? data.selectedPhotographerId
        : null;
    const shouldDelete = !selectedPhotographerId;

    if (shouldDelete) {
      deletedOffers += await deleteDocsByQuery(
        db.collection("offers").where("requestId", "==", requestId),
      );
      deletedReferenceFiles += await deleteFilesWithPrefix(
        `requests/${requestId}/references/`,
      );
      await requestDoc.ref.delete();
      deletedRequests += 1;
      continue;
    }

    deletedReferenceFiles += await deleteFilesWithPrefix(
      `requests/${requestId}/references/`,
    );
    await requestDoc.ref.update({
      address: null,
      notes: null,
      referenceImages: [],
      latitude: null,
      longitude: null,
      locationLabel: null,
      location: null,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    scrubbedRequests += 1;
  }

  return {
    deletedRequests,
    scrubbedRequests,
    deletedOffers,
    deletedReferenceFiles,
  };
}

async function scrubHistoricalBookings(userId) {
  const bookings = [
    ...(await getUserScopedDocs("bookings", "customerId", userId)),
    ...(await getUserScopedDocs("bookings", "photographerId", userId)),
  ];
  const seen = new Set();
  let scrubbedBookings = 0;

  for (const bookingDoc of bookings) {
    if (seen.has(bookingDoc.id)) continue;
    seen.add(bookingDoc.id);
    await bookingDoc.ref.update({
      notes: null,
      location: {
        lat: null,
        lng: null,
        text: null,
      },
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    scrubbedBookings += 1;
  }

  return scrubbedBookings;
}

exports.deleteAccountData = functions
  .runWith({ timeoutSeconds: 540, memory: "1GB" })
  .https.onCall(async (_data, context) => {
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "Authentication required.",
      );
    }

    const userId = context.auth.uid;
    await assertAccountDeletionAllowed(userId);

    const summary = {
      deletedNotifications: 0,
      deletedFavorites: 0,
      deletedFollowing: 0,
      deletedReports: 0,
      deletedAchievements: 0,
      deletedReviews: 0,
      deletedStories: 0,
      deletedStoryViews: 0,
      deletedStoryFiles: 0,
      deletedReels: 0,
      deletedReelComments: 0,
      deletedReelLikes: 0,
      deletedReelFiles: 0,
      deletedPortfolios: 0,
      deletedPortfolioFiles: 0,
      deletedRequests: 0,
      scrubbedRequests: 0,
      deletedOffers: 0,
      deletedRequestReferenceFiles: 0,
      scrubbedBookings: 0,
      deletedPrivateDocs: 0,
      deletedProfileFiles: 0,
      deletedUsernameClaims: 0,
    };

    let usernameLower = null;
    try {
      const userDoc = await db.collection("users").doc(userId).get();
      if (userDoc.exists) {
        const userData = userDoc.data() || {};
        if (typeof userData.usernameLower === "string") {
          usernameLower = userData.usernameLower;
        }
      }
    } catch (_) {
      // Best-effort lookup.
    }

    summary.deletedNotifications += await deleteDocsByQuery(
      db.collection("notifications").where("userId", "==", userId),
    );
    summary.deletedFavorites += await deleteDocsByQuery(
      db.collection("favorites").where("userId", "==", userId),
    );
    summary.deletedFavorites += await deleteDocsByQuery(
      db.collection("favorites").where("photographerId", "==", userId),
    );
    summary.deletedFollowing += await deleteDocsByQuery(
      db.collection("following").where("followerId", "==", userId),
    );
    summary.deletedFollowing += await deleteDocsByQuery(
      db.collection("following").where("followingId", "==", userId),
    );
    summary.deletedReports += await deleteDocsByQuery(
      db.collection("reports").where("reporterId", "==", userId),
    );
    summary.deletedAchievements += await deleteDocsByQuery(
      db.collection("user_achievements").where("userId", "==", userId),
    );
    summary.deletedReviews += await deleteDocsByQuery(
      db.collection("reviews").where("reviewerId", "==", userId),
    );

    const storySummary = await cleanupOwnedStories(userId);
    summary.deletedStories += storySummary.deletedStories;
    summary.deletedStoryViews += storySummary.deletedViews;
    summary.deletedStoryFiles += storySummary.deletedFiles;

    const reelSummary = await cleanupOwnedReels(userId);
    summary.deletedReels += reelSummary.deletedReels;
    summary.deletedReelComments += reelSummary.deletedComments;
    summary.deletedReelLikes += reelSummary.deletedLikes;
    summary.deletedReelFiles += reelSummary.deletedFiles;

    const portfolioSummary = await cleanupPortfolio(userId);
    summary.deletedPortfolios += portfolioSummary.deletedPortfolios;
    summary.deletedPortfolioFiles += portfolioSummary.deletedFiles;

    const requestSummary = await cleanupRequestsForDeletedUser(userId);
    summary.deletedRequests += requestSummary.deletedRequests;
    summary.scrubbedRequests += requestSummary.scrubbedRequests;
    summary.deletedOffers += requestSummary.deletedOffers;
    summary.deletedRequestReferenceFiles +=
      requestSummary.deletedReferenceFiles;

    summary.scrubbedBookings += await scrubHistoricalBookings(userId);

    const privateRef = db.collection("users").doc(userId).collection("private");
    summary.deletedPrivateDocs += await deleteCollectionDocs(privateRef);

    try {
      await db.collection("loyalty_points").doc(userId).delete();
    } catch (_) {
      // Best-effort cleanup.
    }
    try {
      await db.collection("trust_stats").doc(userId).delete();
    } catch (_) {
      // Best-effort cleanup.
    }
    try {
      await db.collection("photographers").doc(userId).delete();
    } catch (_) {
      // Best-effort cleanup.
    }
    try {
      await db.collection("users_public").doc(userId).delete();
    } catch (_) {
      // Best-effort cleanup.
    }
    try {
      await db.collection("users").doc(userId).delete();
    } catch (_) {
      // Best-effort cleanup.
    }
    if (usernameLower) {
      try {
        await db.collection("username_claims").doc(usernameLower).delete();
        summary.deletedUsernameClaims += 1;
      } catch (_) {
        // Best-effort cleanup.
      }
    }

    summary.deletedProfileFiles += await deleteFilesWithPrefix(
      `users/${userId}/profile/`,
    );

    await admin.auth().deleteUser(userId);

    return { ok: true, summary };
  });

async function cleanupStoriesInternal({
  dryRun,
  deleteExpired,
  maxDocs,
  pageSize,
  startAfter,
}) {
  const nowMs = Date.now();
  const baseQuery = db
    .collection("stories")
    .orderBy(admin.firestore.FieldPath.documentId());

  let scanned = 0;
  let updatedStories = 0;
  let deletedStories = 0;
  let cursor = typeof startAfter === "string" && startAfter ? startAfter : null;

  let batch = db.batch();
  let batchOps = 0;

  async function commitBatch() {
    if (batchOps === 0) return;
    if (!dryRun) {
      await batch.commit();
    }
    updatedStories += batchOps;
    batch = db.batch();
    batchOps = 0;
  }

  let deletedViewDocs = null;
  let deletedMediaFiles = null;
  if (!dryRun) {
    deletedViewDocs = 0;
    deletedMediaFiles = 0;
  }

  while (scanned < maxDocs) {
    const limit = Math.min(pageSize, maxDocs - scanned);
    let query = baseQuery.limit(limit);
    if (cursor) {
      query = query.startAfter(cursor);
    }

    const snap = await query.get();
    if (snap.empty) break;

    for (const doc of snap.docs) {
      scanned += 1;
      cursor = doc.id;

      const data = doc.data() || {};
      const hasViewsField = Object.prototype.hasOwnProperty.call(data, "views");
      const expiresAt = data.expiresAt;
      const expiresAtDate =
        expiresAt && typeof expiresAt.toDate === "function"
          ? expiresAt.toDate()
          : null;
      const isExpired = expiresAtDate
        ? expiresAtDate.getTime() <= nowMs
        : false;

      if (deleteExpired && isExpired) {
        await commitBatch();

        deletedStories += 1;
        if (dryRun) {
          continue;
        }

        try {
          deletedViewDocs += await deleteCollectionDocs(
            doc.ref.collection("views"),
            250,
          );
        } catch (_) {
          // Best-effort cleanup.
        }

        const photographerId =
          typeof data.photographerId === "string" ? data.photographerId : "";
        if (photographerId) {
          try {
            deletedMediaFiles += await deleteFilesWithPrefix(
              `stories/${photographerId}/${doc.id}/`,
            );
          } catch (_) {
            // Best-effort cleanup.
          }
        }

        try {
          await doc.ref.delete();
        } catch (_) {
          // Best-effort cleanup.
        }

        continue;
      }

      if (hasViewsField) {
        batch.update(doc.ref, {
          views: admin.firestore.FieldValue.delete(),
        });
        batchOps += 1;
        if (batchOps >= 450) {
          await commitBatch();
        }
      }
    }

    if (snap.size < limit) break;
  }

  await commitBatch();

  return {
    dryRun,
    deleteExpired,
    scanned,
    updatedStories,
    deletedStories,
    deletedViewDocs,
    deletedMediaFiles,
    nextStartAfter: scanned >= maxDocs ? cursor : null,
  };
}

async function isMaintenanceAuthorized(req) {
  const expectedToken =
    (functions.config().maintenance && functions.config().maintenance.token) ||
    process.env.MAINTENANCE_TOKEN;
  const suppliedToken =
    req.get("x-maintenance-token") ||
    (req.query && typeof req.query.token === "string" ? req.query.token : "");

  if (expectedToken && suppliedToken && suppliedToken === expectedToken) {
    return true;
  }

  const authHeader = req.get("authorization") || "";
  const match = authHeader.match(/^Bearer\s+(.+)$/i);
  if (!match) return false;

  try {
    const decoded = await admin.auth().verifyIdToken(match[1]);
    return decoded && decoded.admin === true;
  } catch (_) {
    return false;
  }
}

exports.maintenanceCleanupStories = functions
  .runWith({ timeoutSeconds: 540, memory: "512MB" })
  .https.onRequest(async (req, res) => {
    if (req.method !== "POST") {
      res.set("Allow", "POST");
      return res.status(405).send("Method Not Allowed");
    }

    const authorized = await isMaintenanceAuthorized(req);
    if (!authorized) {
      return res.status(403).json({ error: "Forbidden" });
    }

    const dryRun = parseBool(req.query.dryRun, true);
    const deleteExpired = parseBool(req.query.deleteExpired, true);
    const maxDocs = clampInt(parseIntOrNull(req.query.maxDocs), 1, 5000);
    const pageSize = clampInt(parseIntOrNull(req.query.pageSize), 1, 500);
    const startAfter =
      typeof req.query.startAfter === "string" ? req.query.startAfter : "";

    try {
      const result = await cleanupStoriesInternal({
        dryRun,
        deleteExpired,
        maxDocs,
        pageSize,
        startAfter,
      });
      return res.status(200).json(result);
    } catch (err) {
      return res.status(500).json({ error: String(err) });
    }
  });
