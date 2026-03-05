const crypto = require("crypto");
const admin = require("firebase-admin");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {onSchedule} = require("firebase-functions/v2/scheduler");
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
  const role = String(data.role || "").trim();
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
