const test = require("node:test");
const assert = require("node:assert/strict");

const {
  buildPublicUserData,
  sanitizeProfilePayload,
  validateUsernameLower,
} = require("../profile_validation");

test("validateUsernameLower accepts normalized usernames", () => {
  const result = validateUsernameLower("ahmedphoto23");
  assert.equal(result.ok, true);
});

test("validateUsernameLower rejects reserved usernames", () => {
  const result = validateUsernameLower("adminsupport");
  assert.equal(result.ok, false);
  assert.equal(result.code, "already-exists");
});

test("sanitizeProfilePayload normalizes username and allowed fields", () => {
  const result = sanitizeProfilePayload({
    role: "photographer",
    username: "AhmedPhoto23",
    name: " Ahmed ",
    governorate: "Baghdad",
    over18Confirmed: true,
    ignoredField: "x",
  });

  assert.equal(result.ok, true);
  assert.deepEqual(result.payload, {
    role: "photographer",
    username: "ahmedphoto23",
    usernameLower: "ahmedphoto23",
    name: "Ahmed",
    governorate: "Baghdad",
    over18Confirmed: true,
  });
});

test("sanitizeProfilePayload rejects invalid role", () => {
  const result = sanitizeProfilePayload({
    role: "admin",
    username: "validuser",
  });

  assert.equal(result.ok, false);
  assert.equal(result.code, "invalid-argument");
});

test("buildPublicUserData keeps only public-safe fields", () => {
  const serverTimestamp = { __serverTimestamp: true };
  const result = buildPublicUserData(
    {
      name: "Ahmed",
      username: "ahmed",
      usernameLower: "ahmed",
      photoUrl: "https://example.com/a.jpg",
      governorate: "Baghdad",
      role: "customer",
      phone: "07700000000",
      email: "secret@example.com",
    },
    serverTimestamp,
  );

  assert.deepEqual(result, {
    name: "Ahmed",
    username: "ahmed",
    usernameLower: "ahmed",
    photoUrl: "https://example.com/a.jpg",
    governorate: "Baghdad",
    role: "customer",
    createdAt: serverTimestamp,
    updatedAt: serverTimestamp,
  });
});
