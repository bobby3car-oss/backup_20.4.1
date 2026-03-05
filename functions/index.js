const crypto = require("crypto");
const admin = require("firebase-admin");
const {onCall, HttpsError} = require("firebase-functions/v2/https");

admin.initializeApp();

const db = admin.firestore();

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
