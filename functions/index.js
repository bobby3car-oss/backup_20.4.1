const crypto = require("crypto");
const admin = require("firebase-admin");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
const {onDocumentCreated, onDocumentWritten} = require("firebase-functions/v2/firestore");
const {defineSecret} = require("firebase-functions/params");

admin.initializeApp();

const db = admin.firestore();

// ── Secrets for IAP server-side verification ────────────────────
// Apple App Store Server API (v2)
const APPLE_ISSUER_ID = defineSecret("APPLE_ISSUER_ID");
const APPLE_KEY_ID = defineSecret("APPLE_KEY_ID");
const APPLE_PRIVATE_KEY = defineSecret("APPLE_PRIVATE_KEY");
const APPLE_BUNDLE_ID = defineSecret("APPLE_BUNDLE_ID");
// Google Play Developer API
const GOOGLE_SERVICE_ACCOUNT_KEY = defineSecret("GOOGLE_SERVICE_ACCOUNT_KEY");
const ANDROID_PACKAGE_NAME = defineSecret("ANDROID_PACKAGE_NAME");
// Pro Key salt for hashing
const PRO_KEY_SALT = defineSecret("PRO_KEY_SALT");

const ROLES = new Set(["patient", "doctor", "caregiver", "admin"]);
const LINK_TYPES = new Set(["doctor", "caregiver"]);

function requireAuth(request) {
  if (!request.auth || !request.auth.uid) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  return request.auth.uid;
}

function isAdmin(request) {
  return request.auth?.token?.admin === true;
}

function sha256(input) {
  return crypto.createHash("sha256").update(input).digest("hex");
}

/**
 * SHA-256 hash with a server-side salt.
 * Used for Pro key hashing so raw keys are never stored.
 */
function saltedHash(input, salt) {
  return crypto.createHash("sha256").update(salt + input).digest("hex");
}

/**
 * Generates a Pro key in the format OBPRO-XXXX-XXXX-XXXX.
 * Characters: uppercase A-Z and 0-9 only.
 */
function generateProKey() {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  const segments = [];
  for (let s = 0; s < 3; s++) {
    let seg = "";
    const bytes = crypto.randomBytes(4);
    for (let i = 0; i < 4; i++) {
      seg += chars[bytes[i] % chars.length];
    }
    segments.push(seg);
  }
  return `OBPRO-${segments.join("-")}`;
}

function generateInviteCode() {
  // Keep invite short for manual entry while still random enough.
  return crypto.randomBytes(6).toString("hex").toUpperCase();
}

exports.createInvite = onCall(async (request) => {
  const callerUid = requireAuth(request);
  const data = request.data || {};
  const patientId = String(data.patientId || callerUid);
  const linkType = String(data.linkType || "").trim();
  const rawPermissions = data.permissions || {};
  const expiresInHours = Number(data.expiresInHours || 72);

  if (!LINK_TYPES.has(linkType)) {
    throw new HttpsError("invalid-argument", "Invalid linkType.");
  }
  if (patientId !== callerUid && !isAdmin(request)) {
    throw new HttpsError("permission-denied", "Only owner can create invite.");
  }

  const permissions = {
    read: rawPermissions.read !== false,
    write: rawPermissions.write === true,
  };
  if (permissions.write) {
    permissions.read = true;
  }

  const code = generateInviteCode();
  const codeHash = sha256(code);
  const inviteRef = db.collection(`patients/${patientId}/invites`).doc();
  const expiresAtDate = new Date(Date.now() + expiresInHours * 60 * 60 * 1000);

  await inviteRef.set({
    linkType,
    permissions,
    status: "pending",
    codeHash,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    createdBy: callerUid,
    expiresAt: admin.firestore.Timestamp.fromDate(expiresAtDate),
  });

  return {
    inviteId: inviteRef.id,
    patientId,
    code,
    expiresAt: expiresAtDate.toISOString(),
  };
});

exports.acceptInvite = onCall(async (request) => {
  const callerUid = requireAuth(request);
  const data = request.data || {};
  const code = String(data.code || "").trim().toUpperCase();

  if (!code) {
    throw new HttpsError("invalid-argument", "Invite code required.");
  }

  const codeHash = sha256(code);
  const invitesSnapshot = await db
      .collectionGroup("invites")
      .where("codeHash", "==", codeHash)
      .where("status", "==", "pending")
      .limit(1)
      .get();

  if (invitesSnapshot.empty) {
    throw new HttpsError("not-found", "Invite not found.");
  }

  const inviteDoc = invitesSnapshot.docs[0];
  const inviteData = inviteDoc.data();
  const linkType = String(inviteData.linkType || "");
  if (!LINK_TYPES.has(linkType)) {
    throw new HttpsError("failed-precondition", "Invite payload invalid.");
  }

  const patientRef = inviteDoc.ref.parent.parent;
  if (!patientRef) {
    throw new HttpsError("failed-precondition", "Invite path invalid.");
  }
  const patientId = patientRef.id;
  const expiresAt = inviteData.expiresAt?.toDate?.();
  if (expiresAt instanceof Date && expiresAt.getTime() < Date.now()) {
    throw new HttpsError("failed-precondition", "Invite expired.");
  }

  const linkRef = db.doc(`patients/${patientId}/links/${callerUid}_${linkType}`);

  await db.runTransaction(async (tx) => {
    const freshInvite = await tx.get(inviteDoc.ref);
    if (!freshInvite.exists) {
      throw new HttpsError("not-found", "Invite missing.");
    }
    const freshData = freshInvite.data() || {};
    if (freshData.status !== "pending") {
      throw new HttpsError("failed-precondition", "Invite already used.");
    }

    tx.update(inviteDoc.ref, {
      status: "accepted",
      acceptedByUid: callerUid,
      acceptedAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    tx.set(linkRef, {
      linkType,
      linkedUid: callerUid,
      status: "active",
      permissions: {
        read: freshData.permissions?.read !== false,
        write: freshData.permissions?.write === true,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: freshData.createdBy || patientId,
    }, {merge: true});
  });

  return {
    patientId,
    linkType,
    linkId: `${callerUid}_${linkType}`,
    status: "active",
  };
});

exports.setUserRole = onCall(async (request) => {
  requireAuth(request);
  if (!isAdmin(request)) {
    throw new HttpsError("permission-denied", "Admin only.");
  }
  const data = request.data || {};
  const uid = String(data.uid || "").trim();
  const role = String(data.role || data.newRole || "").trim();
  if (!uid || !ROLES.has(role)) {
    throw new HttpsError("invalid-argument", "Invalid uid or role.");
  }

  await db.doc(`users/${uid}`).set({
    role,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, {merge: true});

  if (role === "patient") {
    await db.doc(`patients/${uid}`).set({
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, {merge: true});
  }

  return {uid, role};
});

// ═══════════════════════════════════════════════════════════════════════
// In-App Purchase Verification
// ═══════════════════════════════════════════════════════════════════════

const VALID_PRODUCT_IDS = new Set([
  "operationsbegleiter_pro_monthly",
  "operationsbegleiter_pro_yearly",
]);

/**
 * Called from the Flutter client after a successful purchase.
 * Validates the receipt / token server-side and writes the entitlement
 * fields to Firestore (users/{uid} – flat fields).
 *
 * Input: { platform, productId, purchaseToken, transactionId }
 */
exports.verifyPurchase = onCall(
    {
      secrets: [
        APPLE_ISSUER_ID, APPLE_KEY_ID, APPLE_PRIVATE_KEY, APPLE_BUNDLE_ID,
        GOOGLE_SERVICE_ACCOUNT_KEY, ANDROID_PACKAGE_NAME,
      ],
    },
    async (request) => {
      const uid = requireAuth(request);
      const data = request.data || {};
      const productId = String(data.productId || "").trim();
      const purchaseToken = String(data.purchaseToken || "").trim();
      const transactionId = String(data.transactionId || "").trim();
      const platform = String(data.platform || "").trim();

      if (!VALID_PRODUCT_IDS.has(productId)) {
        throw new HttpsError("invalid-argument", "Unknown product ID.");
      }
      if (!purchaseToken && !transactionId) {
        throw new HttpsError(
            "invalid-argument",
            "Missing purchaseToken or transactionId.",
        );
      }
      if (platform !== "ios" && platform !== "android") {
        throw new HttpsError("invalid-argument", "Invalid platform.");
      }

      let verificationResult;

      if (platform === "ios") {
        verificationResult = await verifyApple(transactionId, productId);
      } else {
        verificationResult = await verifyGoogle(purchaseToken, productId);
      }

      // Write entitlement to Firestore.
      await writeEntitlement(uid, verificationResult, productId, platform);

      return {
        isPro: verificationResult.valid,
        productId,
        expiresAt: verificationResult.expiresAt
          ? verificationResult.expiresAt.toISOString()
          : null,
      };
    },
);

// ── Write entitlement to Firestore ──────────────────────────────────

async function writeEntitlement(uid, result, productId, platform) {
  const isPro = result.valid === true;
  const updateData = {
    isPro,
    proProductId: productId,
    proPlatform: platform,
    proExpiresAt: result.expiresAt
      ? admin.firestore.Timestamp.fromDate(result.expiresAt)
      : null,
    lastReceiptValidationAt:
      admin.firestore.FieldValue.serverTimestamp(),
  };

  // Set proSince only on the first activation.
  if (isPro) {
    const userDoc = await db.doc(`users/${uid}`).get();
    const existing = userDoc.exists ? userDoc.data() : {};
    if (!existing.proSince) {
      updateData.proSince =
        admin.firestore.FieldValue.serverTimestamp();
    }
  }

  await db.doc(`users/${uid}`).set(updateData, {merge: true});
}

// ═══════════════════════════════════════════════════════════════════════
// Apple App Store Server API v2
// ═══════════════════════════════════════════════════════════════════════

/**
 * Generates a signed JWT for Apple App Store Server API.
 */
function generateAppleJWT() {
  const jwt = require("jsonwebtoken");
  const issuerId = APPLE_ISSUER_ID.value();
  const keyId = APPLE_KEY_ID.value();
  const privateKey = APPLE_PRIVATE_KEY.value().replace(/\\n/g, "\n");
  const bundleId = APPLE_BUNDLE_ID.value();

  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: issuerId,
    iat: now,
    exp: now + 3600, // 1 hour
    aud: "appstoreconnect-v1",
    bid: bundleId,
  };

  return jwt.sign(payload, privateKey, {
    algorithm: "ES256",
    header: {alg: "ES256", kid: keyId, typ: "JWT"},
  });
}

/**
 * Decodes Apple's signed transaction / renewal info (JWS).
 * We only decode the payload (signature verified by Apple's API response).
 */
function decodeAppleJWS(jws) {
  const parts = jws.split(".");
  if (parts.length !== 3) {
    throw new HttpsError("internal", "Invalid Apple JWS format.");
  }
  return JSON.parse(Buffer.from(parts[1], "base64url").toString("utf8"));
}

/**
 * Verifies an iOS purchase via Apple App Store Server API v2.
 * Uses the transactionId to look up the transaction.
 */
async function verifyApple(transactionId, productId) {
  if (!transactionId) {
    throw new HttpsError(
        "invalid-argument",
        "transactionId is required for iOS verification.",
    );
  }

  const token = generateAppleJWT();
  const prodBase = "https://api.storekit.itunes.apple.com/inApps/v1";
  const sandboxBase =
    "https://api.storekit-sandbox.itunes.apple.com/inApps/v1";

  // Try production first, fall back to sandbox.
  for (const baseUrl of [prodBase, sandboxBase]) {
    const txResponse = await fetch(
        `${baseUrl}/transactions/${transactionId}`,
        {headers: {Authorization: `Bearer ${token}`}},
    );

    if (txResponse.status === 404) continue; // not found → try next env
    if (!txResponse.ok) {
      throw new HttpsError(
          "failed-precondition",
          `Apple transaction lookup failed (HTTP ${txResponse.status}).`,
      );
    }

    return parseAppleTransactionResponse(await txResponse.json(), productId);
  }

  throw new HttpsError(
      "not-found",
      "Transaction not found in production or sandbox.",
  );
}

function parseAppleTransactionResponse(json, productId) {
  const signedTransaction = json.signedTransactionInfo;
  if (!signedTransaction) {
    return {valid: false, expiresAt: null};
  }

  const txInfo = decodeAppleJWS(signedTransaction);

  // Verify product matches.
  if (txInfo.productId !== productId) {
    return {valid: false, expiresAt: null};
  }

  // Check expiration.
  const expiresAt = txInfo.expiresDate
    ? new Date(txInfo.expiresDate)
    : null;

  const revoked = !!txInfo.revocationDate;
  const expired = expiresAt ? expiresAt.getTime() <= Date.now() : false;
  const valid = !revoked && !expired;

  return {valid, expiresAt};
}

// ═══════════════════════════════════════════════════════════════════════
// Google Play Developer API v3 (Subscriptions v2)
// ═══════════════════════════════════════════════════════════════════════

async function verifyGoogle(purchaseToken, productId) {
  const {google} = require("googleapis");

  let serviceAccount;
  try {
    serviceAccount = JSON.parse(GOOGLE_SERVICE_ACCOUNT_KEY.value());
  } catch {
    throw new HttpsError(
        "internal",
        "Google service account key is not configured.",
    );
  }

  const packageName = ANDROID_PACKAGE_NAME.value();
  if (!packageName) {
    throw new HttpsError("internal", "ANDROID_PACKAGE_NAME not configured.");
  }

  const auth = new google.auth.JWT(
      serviceAccount.client_email,
      null,
      serviceAccount.private_key,
      ["https://www.googleapis.com/auth/androidpublisher"],
  );

  const androidPublisher = google.androidpublisher({version: "v3", auth});

  try {
    const res = await androidPublisher.purchases.subscriptionsv2.get({
      packageName,
      token: purchaseToken,
    });

    const sub = res.data;

    // subscriptionState: SUBSCRIPTION_STATE_ACTIVE,
    // SUBSCRIPTION_STATE_EXPIRED, SUBSCRIPTION_STATE_REVOKED, etc.
    const state = sub.subscriptionState || "";
    const isActive =
      state === "SUBSCRIPTION_STATE_ACTIVE" ||
      state === "SUBSCRIPTION_STATE_IN_GRACE_PERIOD";

    // Find expiry from lineItems.
    let expiresAt = null;
    const lineItems = sub.lineItems || [];
    for (const item of lineItems) {
      if (item.productId === productId && item.expiryTime) {
        expiresAt = new Date(item.expiryTime);
        break;
      }
    }
    // Fallback: first line item with expiryTime.
    if (!expiresAt && lineItems.length > 0 && lineItems[0].expiryTime) {
      expiresAt = new Date(lineItems[0].expiryTime);
    }

    const valid = isActive &&
      (!expiresAt || expiresAt.getTime() > Date.now());

    return {valid, expiresAt};
  } catch (err) {
    throw new HttpsError(
        "internal",
        `Google Play verification failed: ${err.message}`,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Pro Key System
// ═══════════════════════════════════════════════════════════════════════

/**
 * Admin-only: creates one or more Pro keys in batch.
 *
 * Input:
 *   count:     number   – how many keys to generate (1–100)
 *   grantDays: number   – days of Pro each key grants (1–3650)
 *   expiresAt: string?  – optional ISO-8601 date after which the key
 *                          can no longer be redeemed
 *
 * Returns: { keys: Array<{ keyId, key }>, grantDays, count }
 *
 * Raw keys are returned ONCE in this response.
 * Only their salted SHA-256 hashes are stored in Firestore.
 */
exports.createProKeys = onCall(
    {region: "europe-west1", secrets: [PRO_KEY_SALT]},
    async (request) => {
      requireAuth(request);
      const callerDoc = await db.doc(`users/${request.auth.uid}`).get();
      const callerRole = callerDoc.exists ? callerDoc.data().role : null;
      if (!isAdmin(request) && callerRole !== "admin" && callerRole !== "superAdmin") {
        throw new HttpsError("permission-denied", "Admin only.");
      }

      const data = request.data || {};
      const count = Number(data.count);
      const grantDays = Number(data.grantDays);
      const rawExpiresAt = data.expiresAt || null;

      if (!Number.isFinite(count) || count < 1 || count > 100) {
        throw new HttpsError(
            "invalid-argument",
            "count must be between 1 and 100.",
        );
      }
      if (!Number.isFinite(grantDays) || grantDays < 1 || grantDays > 3650) {
        throw new HttpsError(
            "invalid-argument",
            "grantDays must be between 1 and 3650.",
        );
      }

      // Optional: key-level expiration (cannot redeem after this date).
      let keyExpiresAt = null;
      if (rawExpiresAt) {
        const parsed = new Date(rawExpiresAt);
        if (isNaN(parsed.getTime()) || parsed.getTime() <= Date.now()) {
          throw new HttpsError(
              "invalid-argument",
              "expiresAt must be a valid future ISO-8601 date.",
          );
        }
        keyExpiresAt = admin.firestore.Timestamp.fromDate(parsed);
      }

      const salt = PRO_KEY_SALT.value();
      const batch = db.batch();
      const rawKeys = [];

      for (let i = 0; i < count; i++) {
        const rawKey = generateProKey();
        const keyHash = saltedHash(rawKey, salt);
        const keyRef = db.collection("pro_keys").doc();

        const docData = {
          keyHash,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          status: "active",
          grantDays,
        };
        if (keyExpiresAt) {
          docData.expiresAt = keyExpiresAt;
        }

        batch.set(keyRef, docData);
        rawKeys.push({keyId: keyRef.id, key: rawKey});
      }

      await batch.commit();

      return {keys: rawKeys, grantDays, count};
    },
);

/**
 * Authenticated user redeems a Pro key.
 *
 * Input: { key: string }
 * Returns: { isPro, expiresAt }
 *
 * Flow:
 *   1. Normalise rawKey (trim, uppercase, strip whitespace/dashes)
 *   2. Compute salted keyHash
 *   3. Find matching pro_keys doc with status == "active"
 *   4. Validate expiresAt > now (if set)
 *   5. Transactionally: mark key redeemed + write user entitlement
 */
exports.redeemProKey = onCall(
    {region: "europe-west1", secrets: [PRO_KEY_SALT]},
    async (request) => {
  const uid = requireAuth(request);
  const data = request.data || {};

  // 1. Normalise: trim, uppercase, remove dashes and spaces.
  const rawInput = String(data.key || "");
  const normalised = rawInput.trim().toUpperCase().replace(/[-\s]/g, "");

  if (!normalised) {
    throw new HttpsError("invalid-argument", "Key is required.");
  }

  // 2. Compute salted hash.
  //    Re-insert the canonical format before hashing so it matches what
  //    createProKeys stored:  "OBPRO-XXXX-XXXX-XXXX"
  const canonical = normalised.length === 16
      ? `OBPRO-${normalised.slice(0, 4)}-${normalised.slice(4, 8)}-${normalised.slice(8, 12)}`
      : normalised.length === 17 && normalised.startsWith("OBPRO")
          ? `OBPRO-${normalised.slice(5, 9)}-${normalised.slice(9, 13)}-${normalised.slice(13, 17)}`
          : rawInput.trim().toUpperCase(); // fallback: use as-is

  const salt = PRO_KEY_SALT.value();
  const keyHash = saltedHash(canonical, salt);

  // 3. Find pro_keys document.
  const snap = await db
      .collection("pro_keys")
      .where("keyHash", "==", keyHash)
      .where("status", "==", "active")
      .limit(1)
      .get();

  if (snap.empty) {
    throw new HttpsError("not-found", "Key not found or already used.");
  }

  const keyDoc = snap.docs[0];
  const keyData = keyDoc.data();

  // 4. Validate: expiresAt > now (redemption deadline on the key itself).
  const keyExpiry = keyData.expiresAt?.toDate?.();
  if (keyExpiry instanceof Date && keyExpiry.getTime() < Date.now()) {
    throw new HttpsError("failed-precondition", "Key is expired.");
  }

  const grantDays = keyData.grantDays || 30;
  const now = new Date();
  const grantMs = grantDays * 24 * 60 * 60 * 1000;

  // 5. Transaction: redeem key + update user entitlement.
  await db.runTransaction(async (tx) => {
    // Re-read inside transaction for consistency.
    const freshKey = await tx.get(keyDoc.ref);
    if (!freshKey.exists) {
      throw new HttpsError("not-found", "Key missing.");
    }
    if ((freshKey.data() || {}).status !== "active") {
      throw new HttpsError("failed-precondition", "Key already redeemed.");
    }

    const userDoc = await tx.get(db.doc(`users/${uid}`));
    const userData = userDoc.exists ? userDoc.data() : {};

    // Calculate new proExpiresAt:
    //   If user already has pro with proExpiresAt in the future → add grantDays
    //   Otherwise → now + grantDays
    let newExpiry;
    if (userData.proExpiresAt) {
      const currentExpiry = userData.proExpiresAt.toDate();
      if (currentExpiry.getTime() > now.getTime()) {
        newExpiry = new Date(currentExpiry.getTime() + grantMs);
      } else {
        newExpiry = new Date(now.getTime() + grantMs);
      }
    } else {
      newExpiry = new Date(now.getTime() + grantMs);
    }

    // Mark key as redeemed.
    tx.update(keyDoc.ref, {
      status: "redeemed",
      redeemedAt: admin.firestore.FieldValue.serverTimestamp(),
      redeemedByUid: uid,
    });

    // Update user entitlement.
    const entitlementUpdate = {
      isPro: true,
      proSource: "key",
      proExpiresAt: admin.firestore.Timestamp.fromDate(newExpiry),
      lastReceiptValidationAt:
        admin.firestore.FieldValue.serverTimestamp(),
    };

    // Set proSince only on first activation.
    if (!userData.proSince) {
      entitlementUpdate.proSince =
        admin.firestore.FieldValue.serverTimestamp();
    }

    tx.set(db.doc(`users/${uid}`), entitlementUpdate, {merge: true});
  });

  // Return final state.
  const updated = await db.doc(`users/${uid}`).get();
  const finalExpiry = updated.data()?.proExpiresAt?.toDate?.();

  return {
    isPro: true,
    expiresAt: finalExpiry ? finalExpiry.toISOString() : null,
  };
});

/**
 * Admin-only: lists Pro keys with optional status filter.
 *
 * Input: { status?: "active" | "redeemed" | "disabled", limit?: number }
 * Returns: { keys: Array<{ keyId, status, grantDays, createdAt, ... }> }
 */
exports.listProKeys = onCall(
    {region: "europe-west1"},
    async (request) => {
  requireAuth(request);
  const callerDoc = await db.doc(`users/${request.auth.uid}`).get();
  const callerRole = callerDoc.exists ? callerDoc.data().role : null;
  if (!isAdmin(request) && callerRole !== "admin" && callerRole !== "superAdmin") {
    throw new HttpsError("permission-denied", "Admin only.");
  }

  const data = request.data || {};
  const statusFilter = data.status || null;
  const queryLimit = Math.min(Number(data.limit) || 100, 500);

  let query = db.collection("pro_keys").orderBy("createdAt", "desc");

  if (statusFilter && ["active", "redeemed", "disabled"].includes(statusFilter)) {
    query = query.where("status", "==", statusFilter);
  }

  const snap = await query.limit(queryLimit).get();

  const keys = snap.docs.map((doc) => {
    const d = doc.data();
    return {
      keyId: doc.id,
      status: d.status,
      grantDays: d.grantDays,
      createdAt: d.createdAt?.toDate?.()?.toISOString() || null,
      redeemedAt: d.redeemedAt?.toDate?.()?.toISOString() || null,
      redeemedByUid: d.redeemedByUid || null,
      expiresAt: d.expiresAt?.toDate?.()?.toISOString() || null,
    };
  });

  return {keys};
});

/**
 * Admin-only: disables an active Pro key so it can no longer be redeemed.
 *
 * Input: { keyId: string }
 */
exports.disableProKey = onCall(
    {region: "europe-west1"},
    async (request) => {
  requireAuth(request);
  const callerDoc = await db.doc(`users/${request.auth.uid}`).get();
  const callerRole = callerDoc.exists ? callerDoc.data().role : null;
  if (!isAdmin(request) && callerRole !== "admin" && callerRole !== "superAdmin") {
    throw new HttpsError("permission-denied", "Admin only.");
  }

  const data = request.data || {};
  const keyId = String(data.keyId || "").trim();
  if (!keyId) {
    throw new HttpsError("invalid-argument", "keyId is required.");
  }

  const keyRef = db.doc(`pro_keys/${keyId}`);
  const keyDoc = await keyRef.get();
  if (!keyDoc.exists) {
    throw new HttpsError("not-found", "Key not found.");
  }
  if (keyDoc.data().status !== "active") {
    throw new HttpsError(
        "failed-precondition",
        "Only active keys can be disabled.",
    );
  }

  await keyRef.update({
    status: "disabled",
    disabledAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {keyId, status: "disabled"};
});

// ═══════════════════════════════════════════════════════════════════════
// Scheduled: Check expired subscriptions
// ═══════════════════════════════════════════════════════════════════════

/**
 * Runs every hour. Finds users whose proExpiresAt has passed and
 * sets isPro = false.
 */
exports.checkExpiredSubscriptions = onSchedule(
    {schedule: "every 60 minutes", timeZone: "Europe/Berlin"},
    async () => {
      const now = admin.firestore.Timestamp.now();

      const expiredSnap = await db
          .collection("users")
          .where("isPro", "==", true)
          .where("proExpiresAt", "<=", now)
          .get();

      if (expiredSnap.empty) return;

      const batch = db.batch();
      for (const doc of expiredSnap.docs) {
        batch.update(doc.ref, {
          isPro: false,
          lastReceiptValidationAt:
            admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      console.log(
          `[checkExpiredSubscriptions] Deactivated ${expiredSnap.size} expired subscriptions.`,
      );
    },
);

// ═══════════════════════════════════════════════════════════════════════
// Admin Key System v2 – Firestore-triggered key redemption
// ═══════════════════════════════════════════════════════════════════════
//
// Flow:
//   1. Client marks adminKeys/{keyId}.status = "used" (rules enforce strict
//      transition: active→used, usedByUid==auth.uid).
//   2. Client writes keyRedemptions/{auto-id} with {uid, keyId, type, status:"pending"}.
//   3. This trigger fires, validates the key doc, applies the effect
//      (PRO or DOCTOR), writes adminEvents, updates adminStats, and marks
//      the redemption as "completed".
//
// Security: Cloud Functions run with Admin SDK → bypass security rules.
//           Even if a malicious client writes a bogus keyRedemptions doc,
//           the function validates the adminKeys doc before applying anything.
// ═══════════════════════════════════════════════════════════════════════

exports.onKeyRedemptionCreated = onDocumentCreated(
    "keyRedemptions/{redemptionId}",
    async (event) => {
      const snap = event.data;
      if (!snap) return;

      const redemption = snap.data();
      const {uid, keyId, type} = redemption;
      const redemptionRef = snap.ref;

      // Validate required fields.
      if (!uid || !keyId || !type) {
        await redemptionRef.update({
          status: "failed",
          error: "Missing required fields.",
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return;
      }

      const keyRef = db.doc(`adminKeys/${keyId}`);

      try {
        // Read the key doc to validate.
        const keyDoc = await keyRef.get();
        if (!keyDoc.exists) {
          await redemptionRef.update({
            status: "failed",
            error: "Key not found.",
            processedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          return;
        }

        const keyData = keyDoc.data();

        // Validate the key was actually used by this user.
        if (keyData.status !== "used" || keyData.usedByUid !== uid) {
          await redemptionRef.update({
            status: "failed",
            error: "Key not properly redeemed by this user.",
            processedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          return;
        }

        // Validate type matches the key.
        const keyType = (keyData.type || "").toUpperCase();
        if (keyType !== type.toUpperCase()) {
          await redemptionRef.update({
            status: "failed",
            error: `Key type mismatch: expected ${keyType}, got ${type}.`,
            processedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
          return;
        }

        // Apply the effect.
        const userRef = db.doc(`users/${uid}`);
        const now = admin.firestore.FieldValue.serverTimestamp();

        if (keyType === "PRO") {
          // Read existing user to handle proSince.
          const userDoc = await userRef.get();
          const userData = userDoc.exists ? userDoc.data() : {};

          const updateData = {
            isPro: true,
            pro: true,
            proSource: "admin_key",
            lastReceiptValidationAt: now,
          };

          // Set proSince only on first activation.
          if (!userData.proSince) {
            updateData.proSince = now;
          }

          await userRef.set(updateData, {merge: true});

          console.log(`[onKeyRedemption] PRO granted to ${uid} via key ${keyId.substring(0, 12)}...`);
        } else if (keyType === "DOCTOR") {
          await userRef.set({
            role: "doctor",
            doctorVerified: true,
            updatedAt: now,
          }, {merge: true});

          console.log(`[onKeyRedemption] DOCTOR granted to ${uid} via key ${keyId.substring(0, 12)}...`);
        }

        // Write admin event.
        const eventAction = keyType === "PRO" ? "PRO_GRANTED" : "DOCTOR_GRANTED";
        await db.collection("adminEvents").add({
          actorUid: uid,
          action: keyType === "PRO" ? "KEY_USED" : "KEY_USED",
          targetUid: uid,
          createdAt: now,
          metadata: {
            keyId: keyId.substring(0, 16),
            keyType,
            via: "key_redemption",
          },
        });

        // Also write the grant event.
        await db.collection("adminEvents").add({
          actorUid: "system",
          action: eventAction,
          targetUid: uid,
          createdAt: now,
          metadata: {
            keyId: keyId.substring(0, 16),
            via: "cloud_function",
          },
        });

        // Update admin stats counters.
        const statsRef = db.doc("adminStats/global");
        await statsRef.set({
          keysUsedTotal: admin.firestore.FieldValue.increment(1),
          ...(keyType === "PRO" ? {proUsers: admin.firestore.FieldValue.increment(1)} : {}),
          ...(keyType === "DOCTOR" ? {totalDoctors: admin.firestore.FieldValue.increment(1)} : {}),
        }, {merge: true});

        // Mark redemption as completed.
        await redemptionRef.update({
          status: "completed",
          effect: eventAction,
          processedAt: now,
        });

        console.log(`[onKeyRedemption] Redemption ${event.params.redemptionId} completed.`);
      } catch (err) {
        console.error(`[onKeyRedemption] Error: ${err.message}`, err);
        await redemptionRef.update({
          status: "failed",
          error: err.message,
          processedAt: admin.firestore.FieldValue.serverTimestamp(),
        }).catch(() => {});
      }
    },
);

// ═════════════════════════════════════════════════════════════════
// Helper: send FCM to patient + linked users
// ═════════════════════════════════════════════════════════════════

async function sendFcmToPatientAndLinks(patientId, notification, data = {}) {
  const tokens = [];

  // Patient token
  const patientDoc = await db.doc(`users/${patientId}`).get();
  if (patientDoc.exists && patientDoc.data().fcmToken) {
    tokens.push(patientDoc.data().fcmToken);
  }

  // Linked users tokens
  const linksSnap = await db.collection(`patients/${patientId}/links`)
      .where("status", "==", "active")
      .get();
  for (const linkDoc of linksSnap.docs) {
    const linkedUid = linkDoc.data().linkedUid;
    if (linkedUid) {
      const userDoc = await db.doc(`users/${linkedUid}`).get();
      if (userDoc.exists && userDoc.data().fcmToken) {
        tokens.push(userDoc.data().fcmToken);
      }
    }
  }

  if (tokens.length === 0) return;

  const uniqueTokens = [...new Set(tokens)];
  const message = {
    notification,
    data: {...data, patientId},
    tokens: uniqueTokens,
  };

  try {
    await admin.messaging().sendEachForMulticast(message);
  } catch (err) {
    console.error("[sendFcmToPatientAndLinks] Error:", err.message);
  }
}

// ═════════════════════════════════════════════════════════════════
// Timeline item due reminder (scheduled – runs every 15 min)
// ═════════════════════════════════════════════════════════════════

exports.onTimelineItemDue = onSchedule(
    {schedule: "every 15 minutes", region: "europe-west1"},
    async () => {
      const now = admin.firestore.Timestamp.now();
      const soon = admin.firestore.Timestamp.fromMillis(
          now.toMillis() + 15 * 60 * 1000,
      );

      const snapshot = await db.collectionGroup("timeline")
          .where("state", "==", "planned")
          .where("scheduledAt", ">=", now)
          .where("scheduledAt", "<=", soon)
          .get();

      for (const doc of snapshot.docs) {
        const data = doc.data();
        // Path: patients/{patientId}/timeline/{itemId}
        const patientId = doc.ref.parent.parent.id;

        await sendFcmToPatientAndLinks(patientId, {
          title: "Erinnerung",
          body: `„${data.title || "Aufgabe"}" steht gleich an.`,
        }, {type: "timeline_reminder", itemId: doc.id});
      }
    },
);

// ═════════════════════════════════════════════════════════════════
// Observation created → FCM notify patient + links
// ═════════════════════════════════════════════════════════════════

exports.onObservationCreated = onDocumentCreated(
    {
      document: "patients/{patientId}/observations/{observationId}",
      region: "europe-west1",
    },
    async (event) => {
      const data = event.data?.data();
      if (!data) return;

      const patientId = event.params.patientId;
      const authorName = data.authorName || "Begleiter";
      const severity = data.severity || "info";
      const severityLabel = severity === "critical" ? "🔴 Kritisch" :
        severity === "warning" ? "🟡 Warnung" : "ℹ️ Info";

      await sendFcmToPatientAndLinks(patientId, {
        title: `Neue Beobachtung (${severityLabel})`,
        body: `${authorName}: ${(data.text || "").substring(0, 100)}`,
      }, {type: "observation", observationId: event.params.observationId});

      // Write audit log
      await db.collection("auditLog").add({
        action: "OBSERVATION_CREATED",
        actorUid: data.authorUid || null,
        patientId,
        detail: `Severity: ${severity}`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
    },
);

// ═════════════════════════════════════════════════════════════════
// Wound warning turns red → FCM alert
// ═════════════════════════════════════════════════════════════════

exports.onWoundWarningRed = onDocumentWritten(
    {
      document: "patients/{patientId}/warnings/{warningId}",
      region: "europe-west1",
    },
    async (event) => {
      const after = event.data?.after?.data();
      const before = event.data?.before?.data();
      if (!after) return;

      // Only fire when severity becomes 'red' (and wasn't before)
      if (after.severity === "red" && (!before || before.severity !== "red")) {
        const patientId = event.params.patientId;
        await sendFcmToPatientAndLinks(patientId, {
          title: "⚠️ Wundalarm",
          body: `Wundkontrolle zeigt ROT – bitte prüfen.`,
        }, {type: "wound_warning", warningId: event.params.warningId});

        await db.collection("auditLog").add({
          action: "WOUND_WARNING_RED",
          patientId,
          detail: `Warning ${event.params.warningId} turned red`,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    },
);

// ═════════════════════════════════════════════════════════════════
// Pro expiring soon (scheduled – runs daily)
// ═════════════════════════════════════════════════════════════════

exports.sendProExpiringSoon = onSchedule(
    {schedule: "every day 09:00", region: "europe-west1", timeZone: "Europe/Berlin"},
    async () => {
      const now = admin.firestore.Timestamp.now();
      const threeDays = admin.firestore.Timestamp.fromMillis(
          now.toMillis() + 3 * 24 * 60 * 60 * 1000,
      );

      const snapshot = await db.collection("users")
          .where("isPro", "==", true)
          .where("proExpiresAt", ">=", now)
          .where("proExpiresAt", "<=", threeDays)
          .get();

      for (const doc of snapshot.docs) {
        const data = doc.data();
        if (!data.fcmToken) continue;

        try {
          await admin.messaging().send({
            token: data.fcmToken,
            notification: {
              title: "Pro läuft bald ab",
              body: "Dein Pro-Zugang läuft in weniger als 3 Tagen ab.",
            },
            data: {type: "pro_expiring"},
          });
        } catch (err) {
          console.error(`[sendProExpiringSoon] Error for ${doc.id}:`, err.message);
        }
      }
    },
);

// ═════════════════════════════════════════════════════════════════
// Admin Stats (callable)
// ═════════════════════════════════════════════════════════════════

exports.getAdminStats = onCall(
    {region: "europe-west1"},
    async (request) => {
      requireAuth(request);

      // Allow access for admin custom-claim OR superAdmin Firestore role.
      const callerDoc = await db.doc(`users/${request.auth.uid}`).get();
      const callerRole = callerDoc.exists ? callerDoc.data().role : null;
      if (!isAdmin(request) && callerRole !== "superAdmin") {
        throw new HttpsError("permission-denied", "Admin access required.");
      }

      const usersSnap = await db.collection("users").get();
      let totalPatients = 0;
      let totalDoctors = 0;
      let totalCaregivers = 0;
      let proActive = 0;

      for (const doc of usersSnap.docs) {
        const role = doc.data().role;
        if (role === "patient") totalPatients++;
        else if (role === "doctor") totalDoctors++;
        else if (role === "caregiver") totalCaregivers++;
        if (doc.data().isPro === true) proActive++;
      }

      const stats = {
        totalUsers: usersSnap.size,
        totalPatients,
        totalDoctors,
        totalCaregivers,
        proActive,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      await db.doc("adminStats/global").set(stats, {merge: true});

      return stats;
    },
);

// ═════════════════════════════════════════════════════════════════
// DSGVO Account Deletion (callable)
// ═════════════════════════════════════════════════════════════════

exports.deleteUserAccount = onCall(
    {region: "europe-west1"},
    async (request) => {
      requireAuth(request);
      const uid = request.auth.uid;

      // 1. Delete Firestore user doc
      await db.doc(`users/${uid}`).delete().catch(() => {});

      // 2. Delete patient data
      const patientRef = db.doc(`patients/${uid}`);
      const patientDoc = await patientRef.get();
      if (patientDoc.exists) {
        // Delete subcollections
        const subcollections = [
          "timeline", "wounds", "pain", "voice_memos",
          "appointments", "documents", "photos", "packing",
          "questions", "doctor_questions", "warnings",
          "observations", "links", "invites",
        ];
        for (const sub of subcollections) {
          const snap = await patientRef.collection(sub).get();
          const batch = db.batch();
          snap.docs.forEach((d) => batch.delete(d.ref));
          if (snap.docs.length > 0) await batch.commit();
        }
        await patientRef.delete();
      }

      // 3. Delete Storage files
      try {
        const bucket = admin.storage().bucket();
        await bucket.deleteFiles({prefix: `patients/${uid}/`});
      } catch (err) {
        console.error(`[deleteUserAccount] Storage cleanup error: ${err.message}`);
      }

      // 4. Delete Firebase Auth account
      try {
        await admin.auth().deleteUser(uid);
      } catch (err) {
        console.error(`[deleteUserAccount] Auth delete error: ${err.message}`);
      }

      // 5. Audit log
      await db.collection("auditLog").add({
        action: "ACCOUNT_DELETED",
        actorUid: uid,
        detail: "DSGVO account deletion",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {success: true};
    },
);
