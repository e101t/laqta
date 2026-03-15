const test = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const { Timestamp, doc, setDoc } = require('firebase/firestore');

const projectId = 'demo-no-project';
let testEnv;

const firestoreRules = fs.readFileSync(
  path.resolve(__dirname, '../../firestore.rules'),
  'utf8',
);

test.before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: { rules: firestoreRules },
  });
});

test.after(async () => {
  await testEnv.cleanup();
});

test.beforeEach(async () => {
  await testEnv.clearFirestore();
});

function authedDb(uid, claims) {
  return testEnv.authenticatedContext(uid, claims).firestore();
}

function requestDocData({ clientId, withLocation }) {
  return {
    clientId,
    type: 'Wedding',
    date: '2026-02-01',
    time: '10:00',
    governorate: 'Baghdad',
    address: null,
    budgetMin: 100,
    budgetMax: 200,
    duration: 2,
    style: null,
    deliverables: null,
    notes: null,
    referenceImages: [],
    status: 'draft',
    offersCount: 0,
    selectedOfferId: null,
    selectedPhotographerId: null,
    expiresAt: null,
    latitude: withLocation ? 33.3128 : null,
    longitude: withLocation ? 44.3615 : null,
    locationLabel: withLocation ? 'Baghdad' : null,
    location: withLocation
      ? { lat: 33.3128, lng: 44.3615, label: 'Baghdad' }
      : null,
    createdAt: Timestamp.fromDate(new Date()),
    updatedAt: Timestamp.fromDate(new Date()),
  };
}

test('requests create accepts location fields', async () => {
  const db = authedDb('userA');
  const docRef = db.collection('requests').doc('req1');
  await assertSucceeds(
    docRef.set(requestDocData({ clientId: 'userA', withLocation: true })),
  );
});

test('requests update accepts location fields', async () => {
  const db = authedDb('userA');
  const docRef = db.collection('requests').doc('req2');
  await assertSucceeds(
    docRef.set(requestDocData({ clientId: 'userA', withLocation: false })),
  );
  await assertSucceeds(
    docRef.update({
      latitude: 33.3128,
      longitude: 44.3615,
      locationLabel: 'Baghdad',
      location: { lat: 33.3128, lng: 44.3615, label: 'Baghdad' },
      updatedAt: Timestamp.fromDate(new Date()),
    }),
  );
});



test('requests create denies missing referenceImages', async () => {
  const db = authedDb('userMissing');
  const docRef = db.collection('requests').doc('req-missing-ref');
  const data = requestDocData({ clientId: 'userMissing', withLocation: false });
  delete data.referenceImages;
  await assertFails(docRef.set(data));
});

test('requests create denies null referenceImages', async () => {
  const db = authedDb('userNull');
  const docRef = db.collection('requests').doc('req-null-ref');
  const data = requestDocData({ clientId: 'userNull', withLocation: false });
  data.referenceImages = null;
  await assertFails(docRef.set(data));
});

test('requests create denies too many referenceImages', async () => {
  const db = authedDb('userOverflow');
  const docRef = db.collection('requests').doc('req-too-many');
  const data = requestDocData({ clientId: 'userOverflow', withLocation: false });
  data.referenceImages = Array.from({ length: 11 }, (_, index) => 'img-' + index);
  await assertFails(docRef.set(data));
});

function storyDocData({ photographerId, expiresAt }) {
  const now = new Date();
  return {
    photographerId,
    photographerName: 'Photographer',
    photographerPhotoUrl: null,
    imageUrl: 'https://example.com/story.jpg',
    caption: null,
    createdAt: Timestamp.fromDate(now),
    expiresAt,
    isActive: true,
  };
}

function publicUserDocData({ name, role, governorate }) {
  const now = Timestamp.fromDate(new Date());
  return {
    name,
    username: null,
    usernameLower: null,
    photoUrl: null,
    governorate,
    gender: null,
    age: null,
    birthYear: null,
    role,
    profileCompleted: true,
    over18Confirmed: true,
    lang: 'ar',
    lastSeen: null,
    createdAt: now,
    updatedAt: now,
  };
}

test('story views: viewer can create but cannot read', async () => {
  const photographerDb = authedDb('photog1');
  const storyRef = photographerDb.collection('stories').doc('story1');
  await assertSucceeds(
    storyRef.set(
      storyDocData({
        photographerId: 'photog1',
        expiresAt: Timestamp.fromDate(new Date(Date.now() + 60 * 60 * 1000)),
      }),
    ),
  );

  const viewerDb = authedDb('viewerA');
  const viewRef = viewerDb
    .collection('stories')
    .doc('story1')
    .collection('views')
    .doc('viewerA');

  await assertSucceeds(
    viewRef.set({
      userId: 'viewerA',
      userName: 'Viewer A',
      viewedAt: Timestamp.fromDate(new Date()),
    }),
  );

  await assertFails(viewRef.get());
  await assertSucceeds(
    photographerDb
      .collection('stories')
      .doc('story1')
      .collection('views')
      .doc('viewerA')
      .get(),
  );
});

test('story views: viewer cannot write for another user', async () => {
  const photographerDb = authedDb('photog2');
  await assertSucceeds(
    photographerDb.collection('stories').doc('story2').set(
      storyDocData({
        photographerId: 'photog2',
        expiresAt: Timestamp.fromDate(new Date(Date.now() + 60 * 60 * 1000)),
      }),
    ),
  );

  const viewerDb = authedDb('viewerB');
  const otherViewRef = viewerDb
    .collection('stories')
    .doc('story2')
    .collection('views')
    .doc('someoneElse');

  await assertFails(
    otherViewRef.set({
      userId: 'someoneElse',
      userName: 'Nope',
      viewedAt: Timestamp.fromDate(new Date()),
    }),
  );
});

test('story views: cannot create for expired story', async () => {
  const photographerDb = authedDb('photog3');
  await assertSucceeds(
    photographerDb.collection('stories').doc('story3').set(
      storyDocData({
        photographerId: 'photog3',
        expiresAt: Timestamp.fromDate(new Date(Date.now() - 60 * 60 * 1000)),
      }),
    ),
  );

  const viewerDb = authedDb('viewerC');
  const viewRef = viewerDb
    .collection('stories')
    .doc('story3')
    .collection('views')
    .doc('viewerC');

  await assertFails(
    viewRef.set({
      userId: 'viewerC',
      userName: 'Viewer C',
      viewedAt: Timestamp.fromDate(new Date()),
    }),
  );
});


test('reports create accepts rules-aligned payload', async () => {
  const db = authedDb('reporter1');
  const docRef = db.collection('reports').doc('rep1');
  await assertSucceeds(
    docRef.set({
      reporterId: 'reporter1',
      reportedUserId: 'userX',
      reportedUserName: null,
      reportType: 'user',
      reason: 'abuse',
      details: 'spam',
      timestamp: Timestamp.fromDate(new Date()),
      status: 'pending',
    }),
  );
});

test('notifications create is denied for non-admin', async () => {
  const db = authedDb('userA');
  const docRef = db.collection('notifications').doc('notif1');
  await assertFails(
    docRef.set({
      userId: 'userA',
      title: 'Test',
      body: 'Body',
      type: 'system',
      data: null,
      isRead: false,
      createdAt: Timestamp.fromDate(new Date()),
      imageUrl: null,
      actionUrl: null,
    }),
  );
});

test('trust_stats update is denied for non-admin', async () => {
  const adminDb = authedDb('admin1', { admin: true });
  const userDb = authedDb('userA');

  await assertSucceeds(
    adminDb.collection('trust_stats').doc('photog1').set({
      photographerId: 'photog1',
      reviewCount: 0,
      sumQuality: 0,
      sumCommunication: 0,
      sumOnTime: 0,
      sumDelivery: 0,
      completedBookings: 0,
      canceledByPhotographer: 0,
      disputesCount: 0,
      updatedAt: Timestamp.fromDate(new Date()),
    }),
  );

  await assertFails(
    userDb.collection('trust_stats').doc('photog1').update({
      reviewCount: 1,
      updatedAt: Timestamp.fromDate(new Date()),
    }),
  );
});

test('requests read allows owner and matching-governorate photographer', async () => {
  const ownerDb = authedDb('clientZ');
  const otherDb = authedDb('otherUser');
  const photographerDb = authedDb('photogBaghdad');
  const docRef = ownerDb.collection('requests').doc('req-own');

  await assertSucceeds(
    photographerDb.collection('users_public').doc('photogBaghdad').set(
      publicUserDocData({
        name: 'Photographer',
        role: 'photographer',
        governorate: 'Baghdad',
      }),
    ),
  );

  const requestData = requestDocData({
    clientId: 'clientZ',
    withLocation: false,
  });
  requestData.status = 'published';
  requestData.selectedPhotographerId = null;

  await assertSucceeds(
    docRef.set(requestData),
  );

  await assertSucceeds(docRef.get());
  await assertFails(otherDb.collection('requests').doc('req-own').get());
  await assertSucceeds(photographerDb.collection('requests').doc('req-own').get());
});

test('requests query allows photographer to fetch open requests with matching rule filters', async () => {
  const customerDb = authedDb('clientBaghdad');
  const photographerDb = authedDb('photogBaghdad');

  await assertSucceeds(
    photographerDb.collection('users_public').doc('photogBaghdad').set(
      publicUserDocData({
        name: 'Photographer',
        role: 'photographer',
        governorate: 'Baghdad',
      }),
    ),
  );

  const publicRequest = requestDocData({
    clientId: 'clientBaghdad',
    withLocation: false,
  });
  publicRequest.status = 'published';
  publicRequest.selectedPhotographerId = null;

  const targetedRequest = requestDocData({
    clientId: 'clientBaghdad',
    withLocation: false,
  });
  targetedRequest.status = 'awaiting_offers';
  targetedRequest.selectedPhotographerId = 'photogBaghdad';

  await assertSucceeds(
    customerDb.collection('requests').doc('req-public').set(publicRequest),
  );
  await assertSucceeds(
    customerDb.collection('requests').doc('req-targeted').set(targetedRequest),
  );

  await assertSucceeds(
    photographerDb
      .collection('requests')
      .where('status', 'in', ['published', 'awaiting_offers'])
      .where('governorate', '==', 'Baghdad')
      .where('selectedPhotographerId', '==', null)
      .get(),
  );

  await assertSucceeds(
    photographerDb
      .collection('requests')
      .where('status', 'in', ['published', 'awaiting_offers'])
      .where('selectedPhotographerId', '==', 'photogBaghdad')
      .get(),
  );
});

test('booking payment fields cannot be updated by customer', async () => {
  const adminDb = authedDb('admin1', { admin: true });
  const userDb = authedDb('userClient');
  const bookingRef = userDb.collection('bookings').doc('book-pay');
  const createdAt = Timestamp.fromDate(new Date());
  const bookingData = {
    customerId: 'userClient',
    photographerId: 'photogX',
    requestId: 'req-pay',
    offerId: null,
    date: '2026-02-01',
    time: '11:00',
    duration: 120,
    type: 'Wedding',
    price: 1000,
    currency: 'IQD',
    status: 'pending',
    payment: {
      status: 'pending',
      intentId: null,
      amount: 0,
      paidAt: null,
    },
    location: {
      lat: 0,
      lng: 0,
      text: 'Baghdad',
    },
    deliverables: null,
    notes: null,
    chatId: null,
    deliveryId: null,
    disputeId: null,
    revisionCount: 0,
    canceledBy: null,
    timeline: {
      confirmedAt: Timestamp.fromDate(new Date()),
      inProgressAt: null,
      deliveredAt: null,
      revisionRequestedAt: null,
      completedAt: null,
      canceledAt: null,
    },
    createdAt,
    updatedAt: createdAt,
  };

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'bookings/book-pay'), bookingData);
  });

  await assertFails(
    bookingRef.update({
      payment: {
        ...bookingData.payment,
        status: 'succeeded',
        amount: 1000,
      },
      updatedAt: Timestamp.fromDate(new Date()),
    }),
  );

  await assertSucceeds(
    adminDb.collection('bookings').doc('book-pay').update({
      payment: {
        ...bookingData.payment,
        status: 'succeeded',
        amount: 1000,
      },
      updatedAt: Timestamp.fromDate(new Date()),
    }),
  );
});

test('offers create: photographer can create offer and increment offersCount', async () => {
  const customerId = 'cust_offer';
  const photographerId = 'photog_offer';
  const requestId = 'req_offer_1';
  const offerId = 'offer_1';

  const customerDb = authedDb(customerId);
  const photographerDb = authedDb(photographerId);

  await assertSucceeds(
    photographerDb
      .collection('users_public')
      .doc(photographerId)
      .set(
        publicUserDocData({
          name: 'Photographer',
          role: 'photographer',
          governorate: 'Baghdad',
        }),
      ),
  );

  const requestData = requestDocData({ clientId: customerId, withLocation: true });
  requestData.status = 'published';
  requestData.offersCount = 0;
  requestData.selectedOfferId = null;
  requestData.selectedPhotographerId = null;

  await assertSucceeds(
    customerDb.collection('requests').doc(requestId).set(requestData),
  );

  const offerData = {
    requestId,
    photographerId,
    price: 150,
    currency: 'IQD',
    deliveryDays: 3,
    deliverables: {
      photosCount: 20,
      videoMinutes: null,
      includesEditing: true,
      includesVideo: false,
      notes: null,
    },
    notes: null,
    status: 'submitted',
    createdAt: Timestamp.fromDate(new Date()),
    updatedAt: Timestamp.fromDate(new Date()),
  };

  const batch = photographerDb.batch();
  batch.set(photographerDb.collection('offers').doc(offerId), offerData);
  batch.update(photographerDb.collection('requests').doc(requestId), {
    offersCount: 1,
    updatedAt: Timestamp.fromDate(new Date()),
  });

  await assertSucceeds(batch.commit());
});

test('accept offer batch: booking create allows confirmed status', async () => {
  const customerId = 'cust_accept';
  const photographerId = 'photog_accept';
  const requestId = 'req_accept_1';
  const offerId = 'offer_accept_1';
  const bookingId = 'booking_accept_1';

  const customerDb = authedDb(customerId);
  const photographerDb = authedDb(photographerId);

  await assertSucceeds(
    photographerDb
      .collection('users_public')
      .doc(photographerId)
      .set(
        publicUserDocData({
          name: 'Photographer',
          role: 'photographer',
          governorate: 'Baghdad',
        }),
      ),
  );

  const requestData = requestDocData({ clientId: customerId, withLocation: true });
  requestData.status = 'awaiting_offers';
  await assertSucceeds(
    customerDb.collection('requests').doc(requestId).set(requestData),
  );

  const offerData = {
    requestId,
    photographerId,
    price: 180,
    currency: 'IQD',
    deliveryDays: 2,
    deliverables: {
      photosCount: 40,
      videoMinutes: null,
      includesEditing: true,
      includesVideo: false,
      notes: null,
    },
    notes: null,
    status: 'submitted',
    createdAt: Timestamp.fromDate(new Date()),
    updatedAt: Timestamp.fromDate(new Date()),
  };
  await assertSucceeds(
    photographerDb.collection('offers').doc(offerId).set(offerData),
  );

  const now = new Date();
  const bookingData = {
    customerId,
    photographerId,
    requestId,
    offerId,
    date: '2026-02-01',
    time: '10:00',
    duration: 120,
    type: 'Wedding',
    price: 180,
    currency: 'IQD',
    status: 'confirmed',
    payment: {
      status: 'pending',
      intentId: null,
      amount: null,
      paidAt: null,
    },
    location: { lat: null, lng: null, text: null },
    deliverables: {
      photosCount: 40,
      videoMinutes: null,
      includesEditing: true,
      includesVideo: false,
      notes: null,
    },
    notes: null,
    chatId: null,
    deliveryId: null,
    disputeId: null,
    revisionCount: 0,
    canceledBy: null,
    timeline: {
      confirmedAt: Timestamp.fromDate(now),
      inProgressAt: null,
      deliveredAt: null,
      revisionRequestedAt: null,
      completedAt: null,
      canceledAt: null,
    },
    createdAt: Timestamp.fromDate(now),
    updatedAt: Timestamp.fromDate(now),
  };

  const batch = customerDb.batch();
  batch.update(customerDb.collection('requests').doc(requestId), {
    status: 'offer_selected',
    selectedOfferId: offerId,
    selectedPhotographerId: photographerId,
    updatedAt: Timestamp.fromDate(new Date()),
  });
  batch.update(customerDb.collection('offers').doc(offerId), {
    status: 'accepted',
    updatedAt: Timestamp.fromDate(new Date()),
  });
  batch.set(customerDb.collection('bookings').doc(bookingId), bookingData);

  await assertSucceeds(batch.commit());
});

test('booking revision: allows re-delivery with new deliveredAt timestamp', async () => {
  const bookingId = 'booking_revision_1';
  const customerId = 'cust_revision';
  const photographerId = 'photog_revision';

  const baseMs = Date.now();
  const t0 = Timestamp.fromMillis(baseMs);
  const t1 = Timestamp.fromMillis(baseMs + 1000);
  const t2 = Timestamp.fromMillis(baseMs + 2000);
  const t3 = Timestamp.fromMillis(baseMs + 3000);
  const t4 = Timestamp.fromMillis(baseMs + 4000);
  const t5 = Timestamp.fromMillis(baseMs + 5000);

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await setDoc(doc(adminDb, `bookings/${bookingId}`), {
      customerId,
      photographerId,
      requestId: 'req_revision_1',
      offerId: 'offer_revision_1',
      date: '2026-02-01',
      time: '10:00',
      duration: 60,
      type: 'Wedding',
      price: 100,
      currency: 'IQD',
      status: 'confirmed',
      payment: { status: 'pending', intentId: null, amount: null, paidAt: null },
      location: { lat: null, lng: null, text: null },
      deliverables: null,
      notes: null,
      chatId: null,
      deliveryId: null,
      disputeId: null,
      revisionCount: 0,
      canceledBy: null,
      timeline: {
        confirmedAt: t0,
        inProgressAt: null,
        deliveredAt: null,
        revisionRequestedAt: null,
        completedAt: null,
        canceledAt: null,
      },
      createdAt: t0,
      updatedAt: t0,
    });
  });

  const photographerDb = authedDb(photographerId);
  const customerDb = authedDb(customerId);

  const bookingRefPhotog = photographerDb.collection('bookings').doc(bookingId);
  const bookingRefCust = customerDb.collection('bookings').doc(bookingId);

  await assertSucceeds(
    bookingRefPhotog.update({
      status: 'in_progress',
      timeline: {
        confirmedAt: t0,
        inProgressAt: t1,
        deliveredAt: null,
        revisionRequestedAt: null,
        completedAt: null,
        canceledAt: null,
      },
      updatedAt: t1,
    }),
  );

  await assertSucceeds(
    bookingRefPhotog.update({
      status: 'delivered',
      deliveryId: bookingId,
      timeline: {
        confirmedAt: t0,
        inProgressAt: t1,
        deliveredAt: t2,
        revisionRequestedAt: null,
        completedAt: null,
        canceledAt: null,
      },
      updatedAt: t2,
    }),
  );

  await assertSucceeds(
    bookingRefCust.update({
      status: 'revision_requested',
      revisionCount: 1,
      timeline: {
        confirmedAt: t0,
        inProgressAt: t1,
        deliveredAt: t2,
        revisionRequestedAt: t3,
        completedAt: null,
        canceledAt: null,
      },
      updatedAt: t3,
    }),
  );

  await assertSucceeds(
    bookingRefPhotog.update({
      status: 'delivered',
      timeline: {
        confirmedAt: t0,
        inProgressAt: t1,
        deliveredAt: t4,
        revisionRequestedAt: t3,
        completedAt: null,
        canceledAt: null,
      },
      updatedAt: t4,
    }),
  );

  await assertFails(
    bookingRefPhotog.update({
      status: 'done',
      timeline: {
        confirmedAt: t0,
        inProgressAt: t1,
        deliveredAt: t5,
        revisionRequestedAt: t3,
        completedAt: null,
        canceledAt: null,
      },
      updatedAt: t5,
    }),
  );
});

test('deliveries update: customer cannot change delivery urls', async () => {
  const bookingId = 'booking_delivery_1';
  const customerId = 'cust_delivery';
  const photographerId = 'photog_delivery';

  const baseMs = Date.now();
  const createdAt = Timestamp.fromMillis(baseMs);
  const updatedAt = Timestamp.fromMillis(baseMs + 1000);
  const updatedAt2 = Timestamp.fromMillis(baseMs + 2000);

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await setDoc(doc(adminDb, `bookings/${bookingId}`), {
      customerId,
      photographerId,
      requestId: 'req_delivery_1',
      offerId: 'offer_delivery_1',
      date: '2026-02-01',
      time: '10:00',
      duration: 60,
      type: 'Wedding',
      price: 100,
      currency: 'IQD',
      status: 'delivered',
      payment: { status: 'pending', intentId: null, amount: null, paidAt: null },
      location: { lat: null, lng: null, text: null },
      deliverables: null,
      notes: null,
      chatId: null,
      deliveryId: bookingId,
      disputeId: null,
      revisionCount: 0,
      canceledBy: null,
      timeline: {
        confirmedAt: createdAt,
        inProgressAt: createdAt,
        deliveredAt: createdAt,
        revisionRequestedAt: null,
        completedAt: null,
        canceledAt: null,
      },
      createdAt,
      updatedAt,
    });

    await setDoc(doc(adminDb, `deliveries/${bookingId}`), {
      bookingId,
      photographerId,
      customerId,
      status: 'submitted',
      photoUrls: ['https://example.com/a.jpg'],
      videoUrls: [],
      otherUrls: [],
      note: null,
      revisionNote: null,
      revisionCount: 0,
      createdAt,
      updatedAt,
    });
  });

  const customerDb = authedDb(customerId);
  const deliveryRef = customerDb.collection('deliveries').doc(bookingId);

  await assertSucceeds(
    deliveryRef.update({
      status: 'accepted',
      updatedAt: updatedAt2,
    }),
  );

  await assertFails(
    deliveryRef.update({
      status: 'accepted',
      photoUrls: ['https://example.com/hack.jpg'],
      updatedAt: updatedAt2,
    }),
  );
});

test('download_links: only booking participants can read/write and only photographer can delete', async () => {
  const bookingId = 'booking_download_links_1';
  const customerId = 'cust_dl';
  const photographerId = 'photog_dl';

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await setDoc(doc(adminDb, `bookings/${bookingId}`), {
      customerId,
      photographerId,
    });
  });

  const photographerDb = authedDb(photographerId);
  const customerDb = authedDb(customerId);
  const outsiderDb = authedDb('outsider_dl');
  const linkRef = photographerDb.collection('download_links').doc(bookingId);

  await assertSucceeds(
    linkRef.set({
      batchId: 'batch_1',
      bookingId,
      links: [
        {
          linkId: `${bookingId}__1__0`,
          bookingId,
          photographerId,
          customerId,
          fileUrl: 'https://example.com/file.jpg',
          temporaryUrl: 'https://example.com/file.jpg',
          createdAt: '2026-02-01T10:00:00.000Z',
          expiresAt: '2026-03-03T10:00:00.000Z',
          extensionsUsed: 0,
          maxExtensions: 1,
          isExpired: false,
          downloadCount: 0,
          maxDownloads: -1,
        },
      ],
      photoCount: 1,
      createdAt: '2026-02-01T10:00:00.000Z',
      includesRaw: false,
      includesEdited: true,
    }),
  );

  await assertSucceeds(customerDb.collection('download_links').doc(bookingId).get());
  await assertFails(outsiderDb.collection('download_links').doc(bookingId).get());
  await assertFails(customerDb.collection('download_links').doc(bookingId).delete());
  await assertSucceeds(photographerDb.collection('download_links').doc(bookingId).delete());
});

test('chats create: only booking participants can create with exact participants', async () => {
  const bookingId = 'booking_chat_1';
  const customerId = 'cust_chat';
  const photographerId = 'photog_chat';

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    const now = Timestamp.fromDate(new Date());
    await setDoc(doc(adminDb, `bookings/${bookingId}`), {
      customerId,
      photographerId,
      requestId: 'req_chat_1',
      offerId: 'offer_chat_1',
      date: '2026-02-01',
      time: '10:00',
      duration: 60,
      type: 'Wedding',
      price: 100,
      currency: 'IQD',
      status: 'confirmed',
      payment: { status: 'pending', intentId: null, amount: null, paidAt: null },
      location: { lat: null, lng: null, text: null },
      deliverables: null,
      notes: null,
      chatId: null,
      deliveryId: null,
      disputeId: null,
      revisionCount: 0,
      canceledBy: null,
      timeline: {
        confirmedAt: now,
        inProgressAt: null,
        deliveredAt: null,
        revisionRequestedAt: null,
        completedAt: null,
        canceledAt: null,
      },
      createdAt: now,
      updatedAt: now,
    });
  });

  const customerDb = authedDb(customerId);
  const attackerDb = authedDb('attacker_user');

  const now = Timestamp.fromDate(new Date());
  await assertSucceeds(
    customerDb.collection('chats').doc('chat_ok').set({
      bookingId,
      participants: [customerId, photographerId],
      lastMessageAt: now,
    }),
  );

  await assertFails(
    customerDb.collection('chats').doc('chat_bad').set({
      bookingId,
      participants: [customerId, 'someoneElse'],
      lastMessageAt: now,
    }),
  );

  await assertFails(
    attackerDb.collection('chats').doc('chat_attack').set({
      bookingId,
      participants: ['attacker_user', customerId],
      lastMessageAt: now,
    }),
  );

  await assertFails(
    customerDb.collection('chats').doc('chat_dupe').set({
      bookingId,
      participants: [customerId, customerId],
      lastMessageAt: now,
    }),
  );
});
