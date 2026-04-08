const USERNAME_REGEX = /^[a-z][a-z0-9]{1,}$/;

const RESERVED_USERNAMES = new Set([
  "admin",
  "support",
  "system",
  "root",
  "owner",
  "official",
  "laqta",
  "photographer",
  "customer",
  "help",
  "service",
  "staff",
  "admin1",
  "mod",
  "moderator",
]);

function normalizeString(value) {
  return typeof value === "string" ? value.trim() : null;
}

function normalizeUsernameLower(value) {
  const normalized = normalizeString(value);
  return normalized ? normalized.toLowerCase() : null;
}

function isReservedUsername(usernameLower) {
  if (!usernameLower) return false;
  return (
    RESERVED_USERNAMES.has(usernameLower) ||
    usernameLower.startsWith("admin") ||
    usernameLower.startsWith("support") ||
    usernameLower.startsWith("system")
  );
}

function validateUsernameLower(usernameLower) {
  if (!usernameLower) {
    return { ok: false, code: "invalid-argument", message: "Username is required." };
  }
  if (!USERNAME_REGEX.test(usernameLower)) {
    return {
      ok: false,
      code: "invalid-argument",
      message: "Username must start with a letter and contain only lowercase letters or digits.",
    };
  }
  if (isReservedUsername(usernameLower)) {
    return {
      ok: false,
      code: "already-exists",
      message: "Username is reserved.",
    };
  }
  return { ok: true };
}

function sanitizeProfilePayload(raw) {
  const payload = {};
  const source = raw && typeof raw === "object" && !Array.isArray(raw) ? raw : {};

  const role = normalizeString(source.role);
  if (role) {
    if (role !== "customer" && role !== "photographer") {
      return {
        ok: false,
        code: "invalid-argument",
        message: "Invalid role.",
      };
    }
    payload.role = role;
  }

  const stringFields = [
    "name",
    "email",
    "phone",
    "photoUrl",
    "governorate",
    "gender",
  ];

  for (const field of stringFields) {
    const value = normalizeString(source[field]);
    if (value !== null) {
      payload[field] = value;
    }
  }

  const usernameLower = normalizeUsernameLower(
    source.usernameLower ?? source.username,
  );
  if (usernameLower !== null) {
    const validation = validateUsernameLower(usernameLower);
    if (!validation.ok) return validation;
    payload.username = usernameLower;
    payload.usernameLower = usernameLower;
  }

  if (source.birthYear !== undefined && source.birthYear !== null && source.birthYear !== "") {
    const birthYear = Number(source.birthYear);
    if (!Number.isInteger(birthYear) || birthYear < 1900 || birthYear > 2100) {
      return {
        ok: false,
        code: "invalid-argument",
        message: "Invalid birth year.",
      };
    }
    payload.birthYear = birthYear;
  }

  if (source.age !== undefined && source.age !== null && source.age !== "") {
    const age = Number(source.age);
    if (!Number.isInteger(age) || age < 0 || age > 130) {
      return {
        ok: false,
        code: "invalid-argument",
        message: "Invalid age.",
      };
    }
    payload.age = age;
  }

  const boolFields = ["profileCompleted", "over18Confirmed"];
  for (const field of boolFields) {
    if (source[field] !== undefined && source[field] !== null) {
      payload[field] = Boolean(source[field]);
    }
  }

  return { ok: true, payload };
}

function buildPublicUserData(userData, serverTimestampValue) {
  const publicData = {};
  const allowedFields = [
    "name",
    "username",
    "usernameLower",
    "photoUrl",
    "governorate",
    "role",
  ];

  for (const field of allowedFields) {
    if (Object.prototype.hasOwnProperty.call(userData, field)) {
      publicData[field] = userData[field] ?? null;
    }
  }

  publicData.createdAt = userData.createdAt ?? serverTimestampValue;
  publicData.updatedAt = serverTimestampValue;
  return publicData;
}

module.exports = {
  buildPublicUserData,
  sanitizeProfilePayload,
  validateUsernameLower,
};
