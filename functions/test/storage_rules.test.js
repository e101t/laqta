const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const { doc, setDoc, Timestamp } = require('firebase/firestore');
const { ref, getDownloadURL, uploadBytes } = require('firebase/storage');

const projectId = 'demo-no-project';
let testEnv;

const firestoreRules = fs.readFileSync(
  path.resolve(__dirname, '../../firestore.rules'),
  'utf8',
);
const storageRules = fs.readFileSync(
  path.resolve(__dirname, '../../storage.rules'),
  'utf8',
);

function requestDocPayload({ clientId, photographerId }) {
  const timestamp = Timestamp.fromDate(new Date());
  return {
    clientId,
    type: 'Wedding',
    date: '2026-02-01',
    time: '10:00',
    governorate: 'Baghdad',
    address: 'Test Address',
    budgetMin: 100,
    budgetMax: 200,
    duration: 2,
    style: 'Classic',
    deliverables: null,
    notes: 'notes',
    referenceImages: [],
    status: 'published',
    offersCount: 0,
    selectedOfferId: null,
    selectedPhotographerId: photographerId,
    expiresAt: null,
    latitude: 33.3,
    longitude: 44.3,
    locationLabel: 'Baghdad',
    location: { lat: 33.3, lng: 44.3, label: 'Baghdad' },
    createdAt: timestamp,
    updatedAt: timestamp,
  };
}

function publicUserDocPayload({ role, governorate }) {
  const timestamp = Timestamp.fromDate(new Date());
  return {
    name: 'User',
    username: null,
    usernameLower: null,
    photoUrl: null,
    governorate,
    role,
    createdAt: timestamp,
    updatedAt: timestamp,
  };
}

test.before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId,
    firestore: { rules: firestoreRules },
    storage: { rules: storageRules },
  });
});

test.after(async () => {
  await testEnv.cleanup();
});

test.beforeEach(async () => {
  await testEnv.clearFirestore();
});

test('request reference images are denied for non-participants', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await setDoc(
      doc(adminDb, 'requests/req1'),
      requestDocPayload({ clientId: 'userA', photographerId: 'userB' }),
    );

    const adminStorage = context.storage();
    const adminRef = ref(adminStorage, 'requests/req1/references/test.jpg');
    await uploadBytes(adminRef, new Uint8Array([1, 2, 3]), {
      contentType: 'image/jpeg',
    });
  });

  const unauthorizedStorage = testEnv
    .authenticatedContext('userC')
    .storage();
  const unauthorizedRef = ref(
    unauthorizedStorage,
    'requests/req1/references/test.jpg',
  );
  let error;
  try {
    await getDownloadURL(unauthorizedRef);
  } catch (err) {
    error = err;
  }
  assert.ok(error);
  assert.match(String(error), /storage\/unauthorized/);

});

test('request reference images are denied for unselected photographers even with matching governorate', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await setDoc(
      doc(adminDb, 'requests/req-open'),
      requestDocPayload({ clientId: 'userA', photographerId: null }),
    );

    await setDoc(
      doc(adminDb, 'users_public/photogGov'),
      publicUserDocPayload({ role: 'photographer', governorate: 'Baghdad' }),
    );
    await setDoc(
      doc(adminDb, 'users_public/photogOther'),
      publicUserDocPayload({ role: 'photographer', governorate: 'Basra' }),
    );

    const adminStorage = context.storage();
    const adminRef = ref(adminStorage, 'requests/req-open/references/test.jpg');
    await uploadBytes(adminRef, new Uint8Array([1, 2, 3]), {
      contentType: 'image/jpeg',
    });
  });

  const allowedStorage = testEnv.authenticatedContext('photogGov').storage();
  const allowedRef = ref(allowedStorage, 'requests/req-open/references/test.jpg');
  await assertFails(getDownloadURL(allowedRef));

  const deniedStorage = testEnv.authenticatedContext('photogOther').storage();
  const deniedRef = ref(deniedStorage, 'requests/req-open/references/test.jpg');
  await assertFails(getDownloadURL(deniedRef));
});

test('request reference images are allowed only for selected photographer', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await setDoc(
      doc(adminDb, 'requests/req-selected'),
      requestDocPayload({ clientId: 'userA', photographerId: 'photogSelected' }),
    );

    const adminStorage = context.storage();
    const adminRef = ref(adminStorage, 'requests/req-selected/references/test.jpg');
    await uploadBytes(adminRef, new Uint8Array([1, 2, 3]), {
      contentType: 'image/jpeg',
    });
  });

  const selectedStorage = testEnv.authenticatedContext('photogSelected').storage();
  const selectedRef = ref(
    selectedStorage,
    'requests/req-selected/references/test.jpg',
  );
  await assertSucceeds(getDownloadURL(selectedRef));
});

test('deleted users are denied storage access even if the request still points to them', async () => {
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await setDoc(
      doc(adminDb, 'requests/req-deleted-photog'),
      requestDocPayload({ clientId: 'userA', photographerId: 'photogDeleted' }),
    );
    await setDoc(doc(adminDb, 'deleted_users/photogDeleted'), {
      userId: 'photogDeleted',
      status: 'deleted',
      requestedAt: Timestamp.fromDate(new Date()),
    });

    const adminStorage = context.storage();
    const adminRef = ref(
      adminStorage,
      'requests/req-deleted-photog/references/test.jpg',
    );
    await uploadBytes(adminRef, new Uint8Array([1, 2, 3]), {
      contentType: 'image/jpeg',
    });
  });

  const deletedUserStorage = testEnv
    .authenticatedContext('photogDeleted')
    .storage();
  const deletedUserRef = ref(
    deletedUserStorage,
    'requests/req-deleted-photog/references/test.jpg',
  );
  await assertFails(getDownloadURL(deletedUserRef));
});

test('delivery uploads: only the booking photographer can write', async () => {
  const bookingId = 'booking_upload_1';
  const customerId = 'cust_upload';
  const photographerId = 'photog_upload';

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const adminDb = context.firestore();
    await setDoc(doc(adminDb, `bookings/${bookingId}`), {
      customerId,
      photographerId,
    });
  });

  const photographerStorage = testEnv
    .authenticatedContext(photographerId)
    .storage();
  const okRef = ref(
    photographerStorage,
    `deliveries/${bookingId}/${bookingId}/file.jpg`,
  );
  await assertSucceeds(
    uploadBytes(okRef, new Uint8Array([1, 2, 3]), { contentType: 'image/jpeg' }),
  );

  const customerStorage = testEnv.authenticatedContext(customerId).storage();
  const customerRef = ref(
    customerStorage,
    `deliveries/${bookingId}/${bookingId}/file2.jpg`,
  );
  await assertFails(
    uploadBytes(customerRef, new Uint8Array([1, 2, 3]), {
      contentType: 'image/jpeg',
    }),
  );

  const badPathRef = ref(
    photographerStorage,
    `deliveries/${bookingId}/other/file3.jpg`,
  );
  await assertFails(
    uploadBytes(badPathRef, new Uint8Array([1, 2, 3]), {
      contentType: 'image/jpeg',
    }),
  );
});
