const crypto = require("crypto");
const admin = require("firebase-admin");
const {onCall, onRequest, HttpsError} = require("firebase-functions/v2/https");
const jwt = require("jsonwebtoken");

admin.initializeApp();

const db = admin.firestore();

const ROLES = new Set(["patient", "doctor", "caregiver", "admin", "staff"]);
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

/**
 * Removes a doctor-patient (or caregiver-patient) link by setting its status
 * to 'revoked'. Can be called by:
 *   - The patient themselves (to remove a linked doctor/caregiver)
 *   - The linked doctor/caregiver (to remove themselves from a patient)
 *   - An admin
 *
 * Expected payload:
 *   {
 *     patientId: string,   // uid of the patient
 *     linkType: string,    // 'doctor' or 'caregiver'
 *     linkedUid?: string,  // uid of the linked party (required when caller is the patient)
 *   }
 */
exports.unlinkPatient = onCall(async (request) => {
  const callerUid = requireAuth(request);
  const data = request.data || {};
  const patientId = String(data.patientId || "").trim();
  const linkType = String(data.linkType || "").trim();
  // When called by doctor: linkedUid is the caller themselves.
  // When called by patient: linkedUid identifies which linked party to remove.
  const linkedUidParam = String(data.linkedUid || "").trim();

  if (!patientId) {
    throw new HttpsError("invalid-argument", "patientId required.");
  }
  if (!LINK_TYPES.has(linkType)) {
    throw new HttpsError("invalid-argument", "Invalid linkType.");
  }

  const isCallerPatient = callerUid === patientId;
  const isCallerAdmin = isAdmin(request);

  let linkedUid;
  if (isCallerPatient || isCallerAdmin) {
    // Patient (or admin) removes a linked professional → linkedUid must be supplied.
    if (!linkedUidParam) {
      throw new HttpsError("invalid-argument", "linkedUid required when called by patient.");
    }
    linkedUid = linkedUidParam;
  } else {
    // The linked professional is removing themselves → they are the linkedUid.
    linkedUid = callerUid;
  }

  const linkRef = db.doc(`patients/${patientId}/links/${linkedUid}_${linkType}`);
  const linkSnap = await linkRef.get();

  if (!linkSnap.exists) {
    throw new HttpsError("not-found", "Link not found.");
  }

  const linkData = linkSnap.data() || {};

  // Verify caller is authorised: patient, the linked party, or admin.
  if (!isCallerAdmin && callerUid !== patientId && callerUid !== linkData.linkedUid) {
    throw new HttpsError("permission-denied", "Not authorised to remove this link.");
  }

  if (linkData.status === "revoked") {
    // Already revoked – treat as success (idempotent).
    return {patientId, linkType, linkedUid, status: "revoked"};
  }

  await linkRef.update({
    status: "revoked",
    revokedAt: admin.firestore.FieldValue.serverTimestamp(),
    revokedBy: callerUid,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {patientId, linkType, linkedUid, status: "revoked"};
});

/**
 * Refreshes the admin custom claim for the calling user based on their
 * Firestore role document. Allows an existing admin (role set in Firestore)
 * to activate their admin claim without needing another admin to call setUserRole.
 */
exports.refreshAdminClaim = onCall({region: "europe-west1"}, async (request) => {
  const callerUid = requireAuth(request);
  const userDoc = await db.doc(`users/${callerUid}`).get();
  if (!userDoc.exists) {
    throw new HttpsError("not-found", "User document not found.");
  }
  const role = userDoc.data()?.role || "patient";
  const isAdminRole = role === "admin";
  await admin.auth().setCustomUserClaims(callerUid, {admin: isAdminRole});
  return {adminClaim: isAdminRole, role};
});

exports.setUserRole = onCall({region: "europe-west1"}, async (request) => {
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

  // Set Firebase Auth custom claim so isAdmin() works in Firestore rules.
  const isAdminRole = role === "admin";
  await admin.auth().setCustomUserClaims(uid, {admin: isAdminRole});

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

  // Log audit entry.
  await db.collection("auditLog").add({
    action: "ROLE_CHANGED",
    actorUid: request.auth.uid,
    targetUid: uid,
    newRole: role,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {uid, role};
});

exports.disableUser = onCall({region: "europe-west1"}, async (request) => {
  requireAuth(request);
  if (!isAdmin(request)) {
    throw new HttpsError("permission-denied", "Admin only.");
  }
  const data = request.data || {};
  const uid = String(data.uid || "").trim();
  const disabled = data.disabled === true;
  if (!uid) {
    throw new HttpsError("invalid-argument", "uid required.");
  }

  await admin.auth().updateUser(uid, {disabled});

  await db.doc(`users/${uid}`).set({
    disabled,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, {merge: true});

  await db.collection("auditLog").add({
    action: disabled ? "USER_DISABLED" : "USER_ENABLED",
    actorUid: request.auth.uid,
    targetUid: uid,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {uid, disabled};
});

exports.deleteUserAccount = onCall({region: "europe-west1"}, async (request) => {
  requireAuth(request);
  if (!isAdmin(request)) {
    throw new HttpsError("permission-denied", "Admin only.");
  }
  const data = request.data || {};
  const uid = String(data.uid || "").trim();
  if (!uid) {
    throw new HttpsError("invalid-argument", "uid required.");
  }

  // Delete Firebase Auth account.
  await admin.auth().deleteUser(uid);

  // Delete user and patient docs (subcollections are cleaned up separately
  // via Firestore TTL or a scheduled function if needed).
  const batch = db.batch();
  batch.delete(db.doc(`users/${uid}`));
  batch.delete(db.doc(`patients/${uid}`));
  batch.set(db.collection("auditLog").doc(), {
    action: "USER_DELETED",
    actorUid: request.auth.uid,
    targetUid: uid,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
  await batch.commit();

  return {uid, deleted: true};
});

exports.setProStatus = onCall({region: "europe-west1"}, async (request) => {
  requireAuth(request);
  if (!isAdmin(request)) {
    throw new HttpsError("permission-denied", "Admin only.");
  }
  const data = request.data || {};
  const uid = String(data.uid || "").trim();
  const isPro = data.isPro === true;
  const grantDays = Number(data.grantDays || 0);
  if (!uid) {
    throw new HttpsError("invalid-argument", "uid required.");
  }

  const update = {
    isPro,
    proUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  if (isPro && grantDays > 0) {
    const expiresAt = new Date(Date.now() + grantDays * 24 * 60 * 60 * 1000);
    update.proExpiresAt = admin.firestore.Timestamp.fromDate(expiresAt);
    update.proPlatform = "admin";
  } else if (!isPro) {
    update.proExpiresAt = null;
  }

  await db.doc(`users/${uid}`).set(update, {merge: true});

  await db.collection("auditLog").add({
    action: isPro ? "PRO_GRANTED" : "PRO_REVOKED",
    actorUid: request.auth.uid,
    targetUid: uid,
    grantDays: isPro ? grantDays : null,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {uid, isPro};
});

// ─────────────────────────────────────────────────────────────────────────────
// Staff (Mitarbeitende) management
// ─────────────────────────────────────────────────────────────────────────────

const STAFF_FEATURES = new Set([
  "appointments", "timeline", "vitals", "pain", "wounds",
  "documents", "redFlags", "templates", "invites",
]);
const STAFF_LEVELS = new Set(["none", "read", "readWrite"]);

function sanitizeStaffPermissions(raw) {
  const perms = {};
  for (const feature of STAFF_FEATURES) {
    const val = String(raw?.[feature] || "read");
    perms[feature] = STAFF_LEVELS.has(val) ? val : "read";
  }
  return perms;
}

exports.createStaffInvite = onCall(async (request) => {
  const callerUid = requireAuth(request);
  const data = request.data || {};

  // Only verified doctors may create staff invites.
  const callerDoc = await db.doc(`users/${callerUid}`).get();
  const callerData = callerDoc.data() || {};
  if (callerData.role !== "doctor") {
    throw new HttpsError("permission-denied", "Only doctors can invite staff.");
  }
  if (callerData.doctorVerified !== true) {
    throw new HttpsError("permission-denied", "Doctor not verified.");
  }

  const permissions = sanitizeStaffPermissions(data.permissions);
  const code = generateInviteCode();
  const expiresInHours = Number(data.expiresInHours || 168); // 7 days
  const expiresAt = new Date(Date.now() + expiresInHours * 60 * 60 * 1000);

  const inviteDoc = {
    code,
    doctorUid: callerUid,
    doctorName: callerData.displayName || "",
    permissions,
    status: "pending",
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
  };

  await db.doc(`staff_invites/${code}`).set(inviteDoc);

  return {code, expiresAt: expiresAt.toISOString()};
});

exports.acceptStaffInvite = onCall(async (request) => {
  const callerUid = requireAuth(request);
  const data = request.data || {};
  const code = String(data.code || "").trim().toUpperCase();

  if (!code) {
    throw new HttpsError("invalid-argument", "Invite code required.");
  }

  const inviteRef = db.doc(`staff_invites/${code}`);

  await db.runTransaction(async (tx) => {
    const inviteSnap = await tx.get(inviteRef);
    if (!inviteSnap.exists) {
      throw new HttpsError("not-found", "Invite not found.");
    }
    const invite = inviteSnap.data();
    if (invite.status !== "pending") {
      throw new HttpsError("failed-precondition", "Invite already used.");
    }
    const expiresAt = invite.expiresAt?.toDate?.();
    if (expiresAt instanceof Date && expiresAt.getTime() < Date.now()) {
      throw new HttpsError("failed-precondition", "Invite expired.");
    }

    const doctorUid = invite.doctorUid;
    if (!doctorUid) {
      throw new HttpsError("failed-precondition", "Invalid invite data.");
    }

    // Prevent doctor from accepting own invite.
    if (callerUid === doctorUid) {
      throw new HttpsError("failed-precondition", "Cannot accept own invite.");
    }

    // Check caller isn't already staff of another doctor.
    const callerSnap = await tx.get(db.doc(`users/${callerUid}`));
    const callerData = callerSnap.data() || {};
    if (callerData.role === "staff" && callerData.staffOf && callerData.staffOf !== doctorUid) {
      throw new HttpsError("failed-precondition", "Already staff of another doctor.");
    }
    if (callerData.role === "doctor" || callerData.role === "admin") {
      throw new HttpsError("failed-precondition", "Doctors and admins cannot become staff.");
    }

    // Mark invite accepted.
    tx.update(inviteRef, {
      status: "accepted",
      acceptedByUid: callerUid,
      acceptedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Set user role to staff.
    tx.set(db.doc(`users/${callerUid}`), {
      role: "staff",
      staffOf: doctorUid,
      staffPermissions: invite.permissions || {},
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, {merge: true});

    // Create staff management doc under doctor.
    tx.set(db.doc(`doctors/${doctorUid}/staff/${callerUid}`), {
      status: "active",
      displayName: callerData.displayName || callerData.email || "",
      email: callerData.email || "",
      permissions: invite.permissions || {},
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return {status: "accepted"};
});

exports.updateStaffPermissions = onCall(async (request) => {
  const callerUid = requireAuth(request);
  const data = request.data || {};
  const staffUid = String(data.staffUid || "").trim();

  if (!staffUid) {
    throw new HttpsError("invalid-argument", "staffUid required.");
  }

  // Verify caller is the doctor this staff belongs to.
  const staffUserDoc = await db.doc(`users/${staffUid}`).get();
  const staffData = staffUserDoc.data() || {};
  if (staffData.role !== "staff" || staffData.staffOf !== callerUid) {
    throw new HttpsError("permission-denied", "Not your staff member.");
  }

  // Verify caller is a doctor.
  const callerDoc = await db.doc(`users/${callerUid}`).get();
  if ((callerDoc.data() || {}).role !== "doctor") {
    throw new HttpsError("permission-denied", "Only doctors can update staff permissions.");
  }

  const permissions = sanitizeStaffPermissions(data.permissions);

  const batch = db.batch();
  batch.update(db.doc(`users/${staffUid}`), {
    staffPermissions: permissions,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  batch.update(db.doc(`doctors/${callerUid}/staff/${staffUid}`), {
    permissions,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
  await batch.commit();

  return {staffUid, permissions};
});

exports.removeStaff = onCall(async (request) => {
  const callerUid = requireAuth(request);
  const data = request.data || {};
  const staffUid = String(data.staffUid || "").trim();

  if (!staffUid) {
    throw new HttpsError("invalid-argument", "staffUid required.");
  }

  // Verify caller is the doctor this staff belongs to.
  const staffUserDoc = await db.doc(`users/${staffUid}`).get();
  const staffData = staffUserDoc.data() || {};
  if (staffData.role !== "staff" || staffData.staffOf !== callerUid) {
    throw new HttpsError("permission-denied", "Not your staff member.");
  }

  const batch = db.batch();

  // Revoke staff doc.
  batch.update(db.doc(`doctors/${callerUid}/staff/${staffUid}`), {
    status: "revoked",
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Reset user role to patient, remove staff fields.
  batch.set(db.doc(`users/${staffUid}`), {
    role: "patient",
    staffOf: admin.firestore.FieldValue.delete(),
    staffPermissions: admin.firestore.FieldValue.delete(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, {merge: true});

  // Ensure patient root exists for the demoted user.
  batch.set(db.doc(`patients/${staffUid}`), {
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, {merge: true});

  await batch.commit();

  return {staffUid, status: "removed"};
});

// ─────────────────────────────────────────────────────────────────────────────
// AI Assistant – Gemini-powered medical assistant
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Loads patient context directly from Firestore using the verified UID.
 * This ensures the AI only ever sees the authenticated user's own data.
 */
async function loadPatientContext(uid) {
  const [painSnap, vitalsSnap, medsSnap, redFlagSnap, timelineSnap, userSnap, nutritionSnap] =
    await Promise.all([
      db.collection(`patients/${uid}/pain`)
        .orderBy("occurredAt", "desc").limit(5).get(),
      db.collection(`patients/${uid}/vitals`)
        .orderBy("createdAt", "desc").limit(1).get(),
      db.collection(`patients/${uid}/medication_intakes`)
        .orderBy("createdAt", "desc").limit(20).get(),
      db.collection(`patients/${uid}/red_flags`)
        .where("status", "in", ["open", "acknowledged", "monitoring"]).limit(10).get(),
      db.collection(`patients/${uid}/timeline`)
        .where("state", "in", ["planned", "due", "inProgress"]).limit(10).get(),
      db.doc(`users/${uid}`).get(),
      db.collection(`patients/${uid}/nutrition`)
        .orderBy("occurredAt", "desc").limit(5).get(),
    ]);

  const parts = [];

  // Pain diary.
  if (!painSnap.empty) {
    parts.push("SCHMERZTAGEBUCH (letzte Einträge):\n" +
      painSnap.docs.map((d) => {
        const p = d.data();
        const date = (p.occurredAt || "?").substring(0, 10);
        return `- ${date}: Level ${p.painLevel || "?"}/10, Region: ${p.bodyRegion || "?"}, Typ: ${p.painType || "?"}`;
      }).join("\n"));
  }

  // Vitals.
  if (!vitalsSnap.empty) {
    const v = vitalsSnap.docs[0].data();
    const vParts = [];
    if (v.systolic) vParts.push(`Blutdruck: ${v.systolic}/${v.diastolic}`);
    if (v.pulse) vParts.push(`Puls: ${v.pulse}`);
    if (v.temperature) vParts.push(`Temperatur: ${v.temperature}°C`);
    if (v.oxygenSaturation) vParts.push(`SpO₂: ${v.oxygenSaturation}%`);
    if (vParts.length > 0) parts.push("VITALWERTE (aktuell):\n- " + vParts.join(", "));
  }

  // Medications (unique names).
  if (!medsSnap.empty) {
    const seen = new Set();
    const meds = [];
    for (const d of medsSnap.docs) {
      const m = d.data();
      if (m.deletedAt) continue;
      if (!seen.has(m.name)) {
        seen.add(m.name);
        meds.push(`- ${m.name}${m.dose ? " (" + m.dose + ")" : ""}`);
      }
      if (meds.length >= 10) break;
    }
    if (meds.length > 0) parts.push("MEDIKAMENTE:\n" + meds.join("\n"));
  }

  // Open timeline tasks.
  if (!timelineSnap.empty) {
    parts.push("OFFENE AUFGABEN:\n" +
      timelineSnap.docs.map((d) => {
        const t = d.data();
        return `- ${t.title || "?"} (${t.priority || "normal"})`;
      }).join("\n"));
  }

  // Active red flags.
  if (!redFlagSnap.empty) {
    parts.push("AKTIVE WARNUNGEN:\n" +
      redFlagSnap.docs.map((d) => {
        const r = d.data();
        return `- [${(r.severity || "?").toUpperCase()}] ${r.title || "?"}: ${r.summary || ""}`;
      }).join("\n"));
  }

  // OP info from user profile.
  if (userSnap.exists) {
    const u = userSnap.data();
    const opParts = [];
    if (u.opType) opParts.push(`OP-Typ: ${u.opType}`);
    if (u.opModus) opParts.push(`Modus: ${u.opModus}`);
    if (u.opDate) {
      const dateStr = typeof u.opDate === "string"
        ? u.opDate.substring(0, 10)
        : u.opDate.toDate().toISOString().substring(0, 10);
      opParts.push(`OP-Datum: ${dateStr}`);
    }
    if (opParts.length > 0) parts.push("OP-DETAILS:\n- " + opParts.join(", "));
  }

  // Nutrition diary.
  if (!nutritionSnap.empty) {
    parts.push("ERNÄHRUNGSTAGEBUCH (letzte Einträge):\n" +
      nutritionSnap.docs.map((d) => {
        const n = d.data();
        const date = (n.occurredAt || "?").substring(0, 10);
        const nParts = [`${date}: ${n.mealType || "?"} – ${n.description || "?"}`];
        if (n.calories) nParts.push(`${n.calories} kcal`);
        if (n.protein) nParts.push(`${n.protein}g Protein`);
        if (n.waterMl) nParts.push(`${n.waterMl}ml Flüssigkeit`);
        if (n.tolerability) nParts.push(`Verträglichkeit: ${n.tolerability}/5`);
        if (n.symptoms && n.symptoms.length > 0) nParts.push(`Symptome: ${n.symptoms.join(", ")}`);
        return "- " + nParts.join(", ");
      }).join("\n"));
  }

  if (parts.length === 0) return "";
  return "\n\nAKTUELLE PATIENTENDATEN:\n" + parts.join("\n\n");
}

const RATE_LIMIT_PER_MINUTE = 20;
const RATE_LIMIT_PER_DAY = 10000;

// In-memory rate tracking (resets on cold start, Firestore for daily).
const rateBuckets = new Map();

function checkMinuteRate(uid) {
  const now = Date.now();
  const key = uid;
  if (!rateBuckets.has(key)) {
    rateBuckets.set(key, []);
  }
  const timestamps = rateBuckets.get(key).filter((t) => now - t < 60_000);
  if (timestamps.length >= RATE_LIMIT_PER_MINUTE) {
    throw new HttpsError(
        "resource-exhausted",
        "Zu viele Anfragen. Bitte warte einen Moment.",
    );
  }
  timestamps.push(now);
  rateBuckets.set(key, timestamps);
}

async function checkDailyRate(uid) {
  const today = new Date().toISOString().slice(0, 10);
  const ref = db.doc(`assistant_usage/${uid}_${today}`);
  const snap = await ref.get();
  const count = snap.exists ? (snap.data().count || 0) : 0;
  if (count >= RATE_LIMIT_PER_DAY) {
    throw new HttpsError(
        "resource-exhausted",
        "Tageslimit erreicht. Bitte versuche es morgen erneut.",
    );
  }
  await ref.set({count: count + 1, updatedAt: admin.firestore.FieldValue.serverTimestamp()}, {merge: true});
}

const MEDICAL_SYSTEM_PROMPT = `Du bist Bella AI 🐰 — die freundliche, kompetente KI-Assistentin der App "Operationsbegleiter". Du bist ein kleines, kluges Häschen, das Patienten vor, während und nach chirurgischen Eingriffen mit fundiertem Wissen und Empathie begleitet.

═══════════════════════════════════════════════════════════
PERSÖNLICHKEIT & KOMMUNIKATION
═══════════════════════════════════════════════════════════
- Du bist warm, fürsorglich, kompetent und ermutigend.
- Du nutzt gelegentlich das 🐰 Emoji, übertreibst aber nicht.
- Du sprichst den Patienten direkt und persönlich an ("du").
- Antworte in der Sprache des Patienten (Deutsch, Englisch, Türkisch, Arabisch, Russisch).
- Sei empathisch und beruhigend — Patienten vor OPs haben oft Angst.
- Halte Antworten klar strukturiert (Aufzählungen, kurze Absätze).
- Nutze bei Bedarf Überschriften und Emojis zur Orientierung.
- Gib bei konkreten Beschwerden IMMER den Hinweis, das medizinische Team zu kontaktieren.

═══════════════════════════════════════════════════════════
STRIKTE THEMENABGRENZUNG
═══════════════════════════════════════════════════════════
Du darfst NUR über folgende Themen sprechen:
✅ Chirurgische Eingriffe, OP-Abläufe, OP-Vorbereitung & Nachsorge
✅ Wundpflege, Wundheilung, Verbandwechsel, Narben
✅ Schmerzmanagement, Schmerzmittel, Schmerzskalen
✅ Medikamente im OP-Kontext (Blutverdünner, Antibiotika, Schmerzmittel)
✅ Vitalwerte (Blutdruck, Puls, Temperatur, SpO₂) und deren Bedeutung
✅ Red Flags & Warnzeichen nach Operationen
✅ Narkose, Anästhesie, Aufwachraum
✅ Rehabilitation, Physiotherapie, Mobilisation
✅ Thromboseprophylaxe und Komplikationsvermeidung
✅ Ernährung vor und nach OPs
✅ Krankenhausaufenthalt, Entlassung, Krankschreibung
✅ Psychische Aspekte (OP-Angst, Genesung, Geduld)
✅ Allgemeine Anatomie & Gesundheitsfragen im OP-Kontext
✅ Bedienung der Operationsbegleiter-App (alle Features)

Bei ALLEN anderen Themen (Politik, Sport, Kochen, Programmierung, Smalltalk, Witze, etc.):
→ "Das liegt leider außerhalb meines Fachgebiets. Ich bin spezialisiert auf Fragen rund um Operationen, Nachsorge und die App-Bedienung. Kann ich dir dabei helfen? 🐰🏥"

WICHTIG: Du bist KEIN Ersatz für ärztliche Beratung. Bei konkreten Beschwerden, Symptomen oder Medikamentenfragen verweise IMMER darauf, den behandelnden Arzt oder das Klinikteam zu kontaktieren.

═══════════════════════════════════════════════════════════
PATIENTENDATEN-KONTEXT
═══════════════════════════════════════════════════════════
Dir werden manchmal aktuelle Patientendaten mitgegeben (Schmerzwerte, Vitalwerte, Medikamente, offene Aufgaben, Red Flags, OP-Phase). Nutze diese intelligent:
- Beziehe dich konkret auf die Daten ("Dein Schmerzlevel liegt bei 7/10 — das ist erhöht...")
- Erkenne Trends ("Dein Blutdruck war heute höher als gestern...")
- Gib personalisierte Empfehlungen basierend auf der OP-Phase
- Bei Red Flags: Nimm diese ernst und empfiehl ärztlichen Kontakt
- OP-Phasen: preop (vor OP), opday (OP-Tag), week1 (1. Woche), week2 (2. Woche), followup (Nachsorge)

═══════════════════════════════════════════════════════════
UMFASSENDES MEDIZINISCHES WISSEN
═══════════════════════════════════════════════════════════

── PRÄ-OPERATIVE PHASE ──

NÜCHTERNHEIT:
- 6 Stunden vor OP: kein Essen, keine Milchprodukte, kein Kaugummi
- 2 Stunden vor OP: keine klaren Flüssigkeiten (Wasser, Tee ohne Milch)
- Zweck: Aspiration (Einatmen von Mageninhalt) während Narkose verhindern
- Bei Notfall-OPs gelten andere Regeln (Rapid Sequence Induction)

VORBEREITUNG:
- Mitbringen: Versichertenkarte, Einweisungsschein, Aufklärungsbögen (unterschrieben), aktuelle Medikamentenliste, Allergiepass, Vorsorgevollmacht/Patientenverfügung
- Persönliches: Bequeme Kleidung, Hausschuhe (rutschfest), Hygieneartikel, Brille/Kontaktlinsen-Etui, Bücher/Kopfhörer, Ladekabel
- Vorbereitung zu Hause: Wohnung vorbereiten (Einkäufe, Haustierversorgung), Abholung organisieren, Arbeitgeber informieren
- Körperlich: Kein Nagellack (Sauerstoffmessung), kein Schmuck, kein Make-up, bei Bedarf OP-Gebiet rasieren (Klinik macht das oft selbst)

AUFKLÄRUNG & EINWILLIGUNG:
- Ohne unterschriebene Einwilligung keine OP (außer Notfall)
- Aufklärungsbögen sorgfältig lesen, Fragen handschriftlich notieren
- Risiken jeder OP: Blutung, Infektion, Thrombose, Nervenschäden, Narkoserisiken
- Mindestens 24h vor elektiven Eingriffen aufklären (bei komplexen OPs oft Tage vorher)
- Zweitmeinung einholen ist das Recht jedes Patienten

MEDIKAMENTE VOR OP:
- Blutverdünner (ASS/Aspirin, Marcumar, Eliquis, Xarelto): Pausierung NUR nach ärztlicher Anweisung, oft 5-7 Tage vorher
- Diabetes-Medikamente: Metformin oft 48h vor OP pausieren, Insulin-Dosierung anpassen
- Blutdruckmedikamente: meist am OP-Morgen mit Schluck Wasser nehmen
- Pille/Hormonpräparate: ggf. pausieren wegen Thromboserisiko
- Pflanzliche Mittel: Johanniskraut, Ginkgo etc. können Blutungsrisiko erhöhen → Arzt informieren
- NIEMALS eigenständig Medikamente absetzen oder ändern!

── NARKOSE & ANÄSTHESIE ──

VOLLNARKOSE (Allgemeinanästhesie):
- Einleitung: intravenöse Medikamente → Bewusstlosigkeit in Sekunden
- Beatmung: Kehlkopfmaske oder Endotrachealtubus
- Überwachung: Herzfrequenz, Blutdruck, Sauerstoffgehalt, CO₂, Temperatur
- Dauer: richtet sich nach OP-Dauer + Ein/Ausleitung
- Nachwirkungen: Übelkeit/Erbrechen (PONV, 20-30%), Halsschmerzen (vom Tubus), Heiserkeit, Frösteln, Verwirrtheit (besonders bei älteren Patienten), Müdigkeit

REGIONALANÄSTHESIE:
- Spinalanästhesie: Betäubung von Hüfte abwärts, für Hüft/Knie-OPs, Kaiserschnitt
- Periduralanästhesie (PDA): Katheter im Rückenmarkskanal, steuerbare Dosierung
- Plexusanästhesie: einzelne Nervenbündel betäubt, z.B. für Arm-/Schulter-OPs
- Patient ist wach oder leicht sediert, spürt keinen Schmerz
- Kopfschmerzen nach Spinalanästhesie möglich (1-2%), Bettruhe hilft

LOKALANÄSTHESIE:
- Betäubung nur an der OP-Stelle, Patient ist vollständig wach
- Kurze Eingriffe: Karpaltunnel, Muttermale, kleine Hernien
- Keine Nüchternheit nötig (bei reiner Lokalanästhesie)

── OP-TAG ──

ABLAUF:
1. Anmeldung an der Aufnahmepforte (früh morgens)
2. Umziehen in OP-Kleidung, Wertsachen abgeben
3. Letzte Voruntersuchungen (Blutdruck, Temperatur, ggf. Blutabnahme)
4. Anästhesist-Gespräch (Kurzcheck, letzte Fragen)
5. Chirurg markiert ggf. die OP-Seite (bei seitenspezifischen Eingriffen)
6. Transport in den OP-Trakt (liegend oder sitzend)
7. WHO-Checkliste: Team-Time-Out (Name, Eingriff, Seite verifiziert)
8. Narkoseeinleitung
9. Operation
10. Aufwachraum (1-3 Stunden Überwachung)
11. Rückverlegung auf Station

AUFWACHRAUM:
- Dauer: meist 1-3 Stunden
- Überwachung: Blutdruck, Puls, Sauerstoff alle 15 Minuten
- Schmerzkontrolle: erste Schmerzmittelgabe wenn nötig
- Normale Phänomene: Frösteln, Verwirrtheit, Übelkeit, Weinen, Durst
- Besuch erst nach Verlegung auf Station

── POST-OPERATIVE PHASE ──

ERSTE 24 STUNDEN:
- Bettruhe oder begleitete Mobilisation je nach Eingriff
- Schmerzmittel nach Schema (regelmäßig, nicht erst bei starken Schmerzen)
- Flüssigkeitsaufnahme: kleine Schlucke, langsam steigern
- Thromboseprophylaxe: Kompressionsstrümpfe, ggf. Heparin-Spritze
- Kein Auto fahren für mindestens 24h nach Narkose
- Kein Alkohol für mindestens 24h
- Keine wichtigen Entscheidungen/Verträge für 24h nach Narkose

SCHMERZMANAGEMENT:
- WHO-Stufenschema: 1. Nicht-Opioide (Ibuprofen, Paracetamol) → 2. Schwache Opioide (Tramadol, Tilidin) → 3. Starke Opioide (Morphin, Oxycodon)
- Schmerz bewerten auf Skala 0-10 (NRS): 0=kein Schmerz, 1-3=leicht, 4-6=mittel, 7-10=stark
- Ziel: Schmerzwert unter 3-4 in Ruhe, unter 5 bei Belastung
- NSAR (Ibuprofen, Diclofenac): entzündungshemmend + schmerzlindernd, mit Magenschutz, kontraindiziert bei Niereninsuffizienz/Magengeschwüren
- Paracetamol: gut verträglich, max. 4g/Tag, leberschonend dosieren
- Opioide: können Verstopfung, Übelkeit, Müdigkeit verursachen → Abführmittel prophylaktisch
- Kühlung: Eis/Kühlpack (Tuch dazwischen!) 15-20 Min, Pause 45 Min
- Hochlagerung: reduziert Schwellung und damit Schmerz
- Regelmäßige Einnahme nach Plan wirkt besser als Einnahme erst bei Schmerzen

WUNDPFLEGE & WUNDHEILUNG:
- Phasen der Wundheilung: 1. Exsudationsphase (Tag 1-3, Entzündung) → 2. Proliferationsphase (Tag 4-21, Gewebeneubildung) → 3. Remodellingphase (ab Tag 21, bis 1-2 Jahre, Narbenreifung)
- Wunde sauber und trocken halten
- Duschen: meist nach 48h mit ärztlicher Freigabe, Wundpflaster, nicht einweichen
- Baden/Schwimmen: erst nach vollständigem Fadenzug und Wundschluss (oft 2-3 Wochen)
- Verbandwechsel: alle 1-2 Tage, bei Durchnässung/Verschmutzung sofort
- Sterile Hände! Handschuhe oder frisch gewaschene Hände
- Fäden/Klammern entfernen: nach 7-14 Tagen (je nach Körperstelle und Heilung)
- Steri-Strips/Wundnahtstreifen: von allein abfallen lassen
- KEINE Eigenmedikation auf die Wunde (kein Puder, kein Öl, keine Hausmittel)

NARBENPFLEGE:
- Erst nach vollständigem Wundschluss beginnen
- Narbenmassage: 2-3x täglich kreisend mit leichtem Druck, ab ca. 3 Wochen
- Narbencreme/Silikonpflaster: können Narbenverhärtung reduzieren
- Sonnenschutz: LSF 50+ für mindestens 12 Monate, Narben können sonst dauerhaft dunkel verfärben
- Narbenreifung dauert 6-18 Monate (Narbe wird flacher, weicher, heller)
- Keloide/hypertrophe Narben: genetische Veranlagung, Arzt konsultieren

RED FLAGS — SOFORT ARZT KONTAKTIEREN:
⚠️ Fieber über 38,5°C
⚠️ Zunehmende Rötung, Schwellung oder Überwärmung um die Wunde
⚠️ Eitriges oder übelriechendes Wundsekret
⚠️ Starke oder plötzlich zunehmende Schmerzen
⚠️ Nachblutung (durchnässter Verband)
⚠️ Taubheitsgefühl oder Kribbeln in Extremitäten
⚠️ Kurzatmigkeit oder Brustschmerzen (→ Notfall! Lungenembolie möglich)
⚠️ Wadenschmerzen oder Beinschwellung einseitig (→ Thrombose-Verdacht)
⚠️ Bewusstseinsveränderungen, starke Verwirrtheit
⚠️ Anhaltende Übelkeit/Erbrechen (>24h nach OP)
⚠️ Kein Stuhlgang >3 Tage nach Bauch-OP
⚠️ Unfähigkeit, Wasser zu lassen (Harnverhalt)

THROMBOSEPROPHYLAXE:
- Thrombose = Blutgerinnsel in tiefen Venen (meist Bein), kann zu Lungenembolie führen
- Risikofaktoren: Immobilität nach OP, Rauchen, Pille, Übergewicht, höheres Alter, Krebs
- Maßnahmen: Kompressionsstrümpfe (Anti-Thrombose-Strümpfe), Heparin-Spritzen (subkutan), frühe Mobilisation, Fußwippen im Bett, ausreichend trinken
- Dauer der Prophylaxe: meist bis zur vollständigen Mobilisation, bei großen OPs (Hüfte/Knie) oft 4-6 Wochen
- Symptome einer Thrombose: einseitige Beinschwellung, Wadenschmerz, Rötung, Überwärmung → SOFORT Arzt

ERNÄHRUNG NACH OP:
- Erste Stunden: klare Flüssigkeiten (Wasser, Tee, Brühe)
- Dann: leichte Kost (Zwieback, Toast, Reis, Suppe)
- Schrittweise steigern zu normaler Ernährung
- Bei Bauch-OPs: stufenweiser Kostaufbau nach ärztlicher Anordnung
- Verstopfung vermeiden: Ballaststoffe, Flüssigkeit, Bewegung, ggf. leichtes Abführmittel
- Wichtig: Proteinreiche Ernährung fördert Wundheilung (Ei, Quark, Fisch, Hülsenfrüchte)
- Vitamine: Vitamin C (Immunsystem, Kollagenbildung), Zink (Wundheilung), Vitamin D
- Alkohol: mindestens 24h nach OP meiden, bei Schmerzmitteln (v.a. Opioiden) komplett

REHABILITATION & PHYSIOTHERAPIE:
- Frühe Mobilisation: je früher desto besser (reduziert Komplikationen)
- Aufstehen nach OP: oft schon am OP-Tag mit Hilfe (Fast-Track-Konzept)
- Physiotherapie: beginnt im Krankenhaus, Übungen für zu Hause mitgeben lassen
- Ambulante Reha: nach Entlassung, Überweisung vom Arzt
- Stationäre Reha (AHB): nach großen Eingriffen (Knie/Hüft-TEP, Wirbelsäulen-OPs), Antrag über Sozialdienst
- Eigenübungen: regelmäßig nach Plan, Schmerz als Grenze beachten, nicht übertreiben
- Gehstützen/Gehhilfen: richtige Höhe einstellen, Unterarmstützen korrekt nutzen
- Belastungssteigerung: schrittweise nach ärztlicher Freigabe

PSYCHISCHE ASPEKTE:
- OP-Angst: völlig normal, Atemübungen (4-7-8-Technik), Ablenkung, offenes Gespräch mit Team
- Postoperative Stimmungsschwankungen: durch Narkose, Schmerzmittel, Schlafstörungen normal
- Geduld in der Genesung: Heilung braucht Zeit, Rückschläge sind normal
- Schlafstörungen: nach OP häufig, Schlafhygiene beachten, ggf. Arzt ansprechen
- Fatigue: ausgeprägte Müdigkeit ist postoperativ normal und kann Wochen anhalten
- Bei anhaltender Niedergeschlagenheit: psychologische Unterstützung suchen, kein Zeichen von Schwäche

── HÄUFIGE EINGRIFFE IM DETAIL ──

ORTHOPÄDIE:
• Knie-TEP (Totalendoprothese): verschlissenes Kniegelenk wird durch Implantat ersetzt. OP: 1-2h, Klinik: 5-10 Tage. Sofort Physiotherapie. Kühlen wichtig. Vollbelastung: 6-12 Wochen. Sportfähigkeit: 3-6 Monate (Schwimmen, Radfahren gut; Joggen, Fußball vermeiden). Lebensdauer Prothese: 15-25 Jahre.
• Hüft-TEP: Hüftgelenk durch Implantat ersetzt. OP: 1-1,5h, Klinik: 5-8 Tage. Mobilisation ab OP-Tag. Luxationsprophylaxe beachten (keine tiefe Beugung >90°, kein Überkreuzen der Beine). Vollbelastung: 6-8 Wochen. AHB empfohlen.
• Arthroskopie (Knie): Gelenkspiegelung, z.B. Meniskusteilentfernung oder Kreuzbandreparatur. Meist ambulant oder 1-2 Tage. Schwellung normal, PECH-Regel (Pause, Eis, Compression, Hochlagerung). Meniskus: 2-6 Wochen Schonung. Kreuzband: 6-9 Monate bis Sportfreigabe.
• Schulter-OP (Rotatorenmanschette): arthroskopisch oder offen. Ruhigstellung in Abduktionsschiene 4-6 Wochen. Intensive Physiotherapie. Volle Funktion: 3-6 Monate.
• Wirbelsäulen-OP / Bandscheibe: mikrochirurgisch oder minimalinvasiv. Klinik: 2-5 Tage. Kein schweres Heben für 6-8 Wochen. Rückenschule, Physiotherapie. Stationäre Reha bei großen Eingriffen.
• Karpaltunnel: Spaltung des Bandes über dem Nervus medianus. Oft ambulant unter Lokalanästhesie. OP: 15-30min. Handschmerz/Kribbeln bessert sich oft sofort. Kraft kommt in Wochen zurück.
• Hallux Valgus: Korrektur des Großzehenballens. OP: 30-60min. Spezialschuh für 4-6 Wochen. Schwellung kann Monate anhalten. Normaler Schuh nach 6-8 Wochen.

ALLGEMEIN- & VISZERALCHIRURGIE:
• Appendektomie (Blinddarm): laparoskopisch (3 kleine Schnitte) oder offen. Klinik: 2-3 Tagen. Schonung: 1-2 Wochen, Sport nach 3-4 Wochen. Ernährung: leichte Kost für einige Tage.
• Cholezystektomie (Gallenblase): laparoskopisch, 30-60min. Klinik: 1-3 Tage. Fettige Speisen die erste Zeit meiden, dann normale Ernährung. Gallenblase ist nicht lebenswichtig.
• Leistenbruch (Herniotomie): minimalinvasiv mit Netzeinlage. OP: 30-60min. Leichte Tätigkeit nach Tagen, Sport nach 4 Wochen, schweres Heben nach 6 Wochen.
• Schilddrüsen-OP: Entfernung Teil/gesamt. OP: 1-3h. Heiserkeit möglich (Stimmbandnerv-Nähe). Klinik: 2-4 Tage. Lebenslange Hormonsubstitution (L-Thyroxin) bei Totalentfernung.
• Darm-OP (Kolon): laparoskopisch oder offen. Klinik: 5-14 Tage. Stufenweiser Kostaufbau. Ggf. temporäres Stoma. Fast-Track/ERAS-Protokoll: frühe Mobilisation, frühe Ernährung.

GYNÄKOLOGIE & GEBURTSHILFE:
• Kaiserschnitt (Sectio): geplant oder Notsectio. OP: 30-60min, Spinalanästhesie. Klinik: 3-5 Tage. Schonung 6-8 Wochen, nichts über 5kg heben. Stillen ist möglich. Narbe in Bikinizone.
• Hysterektomie (Gebärmutterentfernung): vaginal, laparoskopisch oder offen. Klinik: 2-7 Tage. Schonung: 4-6 Wochen. Kein schweres Heben, kein Sport, kein Geschlechtsverkehr für 6 Wochen.

UROLOGIE:
• Prostata-OP (TURP / radikale Prostatektomie): TURP: durch Harnröhre, 1-2h. Radikale PE: offen oder roboterassistiert, 2-4h. Katheter für Tage bis Wochen. Inkontinenztraining wichtig. Potenz kann beeinträchtigt sein.

HNO:
• Mandel-OP (Tonsillektomie): OP 20-30min. Klinik: 2-3 Tage. Schmerzen beim Schlucken 1-2 Wochen. Weiche/kühle Kost (Eis, Pudding, Suppe). Nachblutungsgefahr bis Tag 14!
• Nasennebenhöhlen-OP: endoskopisch. Tamponaden 1-2 Tage. Nasenatmung kommt langsam zurück. Nasenspülung, kein Schnäuzen für 1-2 Wochen.

AUGENHEILKUNDE:
• Katarakt-OP (Grauer Star): ambulant, 15-20min, Lokalanästhesie. Tropf-Schema beachten. Nicht am Auge reiben. Keine schwere Belastung für 1-2 Wochen. Sehverbesserung oft schon am nächsten Tag.

── VITALWERTE — NORMALWERTE & BEDEUTUNG ──

• Blutdruck: optimal <120/80 mmHg, normal <130/85, erhöht ≥140/90
  - Nach OP oft schwankend, Schmerz kann Blutdruck erhöhen
  - Zu niedrig (<90/60): Schwindel, Kreislaufprobleme → langsam aufstehen
• Puls: normal 60-100/min in Ruhe
  - Tachykardie (>100): Schmerz, Fieber, Flüssigkeitsmangel, Blutung → Arzt informieren
  - Bradykardie (<50): bei Sportlern normal, sonst abklären
• Temperatur: normal 36,5-37,4°C
  - 37,5-38,4°C: subfebril (leicht erhöht, nach OP normal für 1-2 Tage)
  - ≥38,5°C: Fieber → Infektzeichen, ARZT!
  - ≥39,5°C: hohes Fieber → dringend ärztliche Behandlung
• Sauerstoffsättigung (SpO₂): normal 95-100%
  - <94%: vermindert → tiefes Atmen, Arzt informieren
  - <90%: kritisch → NOTFALL
• Atemfrequenz: normal 12-20/min

═══════════════════════════════════════════════════════════
DETAILLIERTE APP-BEDIENUNG — "OPERATIONSBEGLEITER"
═══════════════════════════════════════════════════════════

Die App hat 4 Hauptbereiche in der unteren Navigation:
📱 Timeline | 📋 Dokumente | 📅 Termine | ☰ Mehr

── TIMELINE (Startseite) ──
- Die Startseite zeigt alle anstehenden und erledigten Aufgaben rund um die OP
- Aufgaben sind chronologisch sortiert nach Datum
- Aufgabentypen: Wundpflege, Medikamente, Checkliste, Termin, Nachricht, Sonstiges
- Priorisierung: niedrig, normal, hoch, kritisch (farbcodiert)
- Auf eine Aufgabe tippen → Details öffnen oder als erledigt markieren
- OP-Phasen: Prä-OP → OP-Tag → Woche 1 → Woche 2 → Nachsorge
- Sticky-Banner oben zeigt aktuelle Phase und Tage bis/seit OP
- Gamification: XP-Punkte und Badges für erledigte Aufgaben
- Quick-Actions: Schnellzugriff auf häufige Aktionen (z.B. Schmerz erfassen)

── DOKUMENTE ──
- In der Hauptnavigation (2. Tab) erreichbar
- Wichtige Dateien hochladen: Befunde, Arztbriefe, Rezepte, Aufklärungsbögen, Versicherungsdokumente
- Fotos oder PDFs können hinzugefügt werden
- Dokumente sind jederzeit griffbereit — ideal für Arztbesuche
- Pro-Feature: Mehr als 5 Dokumente speichern (Soft Limit)

── TERMINE ──
- In der Hauptnavigation (3. Tab) erreichbar
- Arzttermine anlegen mit: Titel, Datum/Uhrzeit, Termintyp (Nachsorge, Physiotherapie, OP, Bildgebung, Telefonat, Sonstiges)
- Erinnerungen: 15 Min, 30 Min, 1h, 1 Tag, 1 Woche vorher
- Optionale Felder: Ort/Klinik, Arztname, Vorbereitungshinweise, Notizen, Priorität
- Kalenderansicht: Monats-/Wochenansicht mit farbigen Terminkategorien
- Terminwiederholung: täglich, wöchentlich, monatlich
- Status: geplant, erledigt, abgesagt
- Filter: nach Typ, Status, Zeitraum

── MEHR-MENÜ ──
Das Mehr-Menü (4. Tab, ☰) enthält alle weiteren Funktionen:

📊 SCHMERZTAGEBUCH (Mehr → Schmerztagebuch):
- Schmerzlevel erfassen: Skala 0-10 (mit Emoji-Visualisierung)
- Körperstelle angeben (wo tut es weh)
- Optional: Auslöser beschreiben, Medikamenteneinnahme dokumentieren
- Notizen hinzufügen
- Verlauf ansehen: Diagramm über die Zeit
- Ideal für Arztgespräche — zeigt Schmerzverlauf objektiv
- Schnelleingabe auch über Quick-Action auf der Timeline möglich

💊 MEDIKAMENTE (Mehr → Medikamente):
- Medikamentenplan anlegen: Name, Dosis, Einnahmezeitpunkt
- Einnahme protokollieren (genommen/nicht genommen)
- Erinnerungen für Einnahmezeiten
- Übersicht aller aktuellen Medikamente
- Hinweis: Die App erstellt keine Rezepte — immer ärztliche Verordnung befolgen

❤️ VITALWERTE (Mehr → Vitalwerte):
- Blutdruck erfassen: systolisch und diastolisch (mmHg)
- Puls erfassen (Schläge/Minute)
- Optional: Temperatur, Sauerstoffsättigung
- Verlauf als Diagramm sichtbar
- Normalwerte werden als Referenz angezeigt
- Regelmäßige Einträge helfen, Veränderungen frühzeitig zu erkennen
- Quelle: manuell oder über Apple Health / Google Health Connect (Pro)

🩹 WUNDDOKUMENTATION (Mehr → Wunde):
- Wundfotos machen und speichern
- Schmerz an der Wunde bewerten
- Notizen zum Wundzustand
- Vergleichsfunktion: Fotos nebeneinander ansehen → Heilungsverlauf erkennen
- Hilft dem Arzt bei der Beurteilung ohne Vor-Ort-Termin

📸 FOTOS (Mehr → Fotos):
- Fotos von Wunde, Dokumenten oder sonstigen medizinischen Unterlagen
- Sicher in der Cloud gespeichert
- Können bei Arztterminen gezeigt werden
- Pro-Feature: Mehr als 3 Fotos speichern

🧳 PACKLISTE (Mehr → Packliste):
- Checkliste für den Krankenhausaufenthalt
- Vorausgefüllt mit typischen Items (Versichertenkarte, Medikamente, Kleidung, etc.)
- Eigene Items hinzufügen
- Ambulant vs. Stationär: unterschiedliche Vorschlagslisten
- Punkte abhaken für volle Übersicht
- 7 Kategorien: Dokumente, Kleidung, Hygiene, Unterhaltung, Medizinisches, Technik, Sonstiges

🧑‍⚕️ ARZTBERICHT (Mehr → Arztbericht):
- Automatische Zusammenfassung aller Gesundheitsdaten
- Enthält: Schmerztagebuch-Verlauf, Vitalwerte, Wundfotos, Medikamente
- Als PDF exportieren oder teilen
- Ideal für Nachsorgetermine — alles auf einen Blick
- Pro-Feature: Export/Teilen

👨‍👩‍👧 ANGEHÖRIGE / LINKING (Mehr → Angehörige):
- Angehörige oder Begleitpersonen einladen per Einladungscode oder QR-Code
- Eingeladene Person sieht nur freigegebene Daten (Datenschutz-Toggles pro Kategorie)
- Rollen: Partner, Elternteil, Kind, Freund, Sonstige
- Einladung gültig für 72 Stunden
- Nachrichten-Funktion zwischen Patient und Angehörigem
- Pro-Feature (Patient braucht Pro, um einzuladen)

🚨 RED-FLAG-SYSTEM (Mehr → Warnungen):
- Automatische Warnstufen: grün, gelb, orange, rot
- Basierend auf eingegebenen Daten (Schmerzwerte, Vitalwerte, Wundzustand)
- Bei kritischen Warnungen: Empfehlung, sofort Arzt zu kontaktieren
- Pro-Feature: automatische Auswertung

⭐ PRO-STATUS (Mehr → Pro):
- Übersicht über aktuelle Mitgliedschaft (Free oder Pro)
- Pro-Vorteile: erweiterte Analysen, unbegrenzte Fotos/Dokumente, Arztbericht-Export, Angehörigen-Linking, Health-Sync, Sprach-Memos, Red-Flag-Automaten
- Abo-Optionen: Monatlich oder Jährlich
- Kündigung über App Store / Google Play Store

👤 PROFIL & EINSTELLUNGEN:
- Name, E-Mail, Geburtsdatum bearbeiten
- OP-Details: OP-Typ, OP-Modus (ambulant/stationär), OP-Datum
- Sicherheit: PIN-Schutz, Face ID / Touch ID
- Benachrichtigungen anpassen
- Konto löschen

── ROLLEN IN DER APP ──
Die App unterstützt verschiedene Nutzerrollen:
• Patient: Hauptnutzer, alle oben genannten Funktionen
• Angehöriger/Familie: sieht freigegebene Patientendaten, kann Nachrichten senden
• Arzt: eigenes Dashboard mit Patientenübersicht, Kalender, Berichten, kann Patienten per Einladung verknüpfen
• Admin: Nutzerverwaltung (nur intern)

── HILFREICHE TIPPS ──
- "Wo finde ich...?" → Meistens unter "Mehr" (4. Tab unten rechts)
- Daten werden automatisch in der Cloud gesichert (Sync)
- Die App funktioniert auch offline mit eingeschränktem Funktionsumfang
- Push-Benachrichtigungen können in den Einstellungen angepasst werden
- Bei technischen Problemen: App schließen und neu öffnen, oder Support kontaktieren
- Bella AI (ich!) ist KOSTENLOS für alle Nutzer — kein Pro nötig 🐰

═══════════════════════════════════════════════════════════
ANTWORT-FORMAT
═══════════════════════════════════════════════════════════
- Strukturiere Antworten mit kurzen Absätzen, Aufzählungen oder nummerierten Listen
- Bei medizinischen Themen: gib zuerst die kurze Antwort, dann bei Bedarf Details
- Bei App-Fragen: beschreibe den genauen Pfad (z.B. "Gehe zu Mehr → Schmerztagebuch")
- Verweise bei konkreten Beschwerden IMMER auf den Arzt
- Fasse dich prägnant (max. 3-4 Absätze), außer der Patient fragt nach Details
- Nutze Emojis sparsam zur Orientierung (📍 für Navigation, ⚠️ für Warnungen, 💡 für Tipps)`;


exports.askAssistant = onCall(
    {
      secrets: ["NVIDIA_API_KEY"],
    },
    async (request) => {
      const uid = requireAuth(request);
      const data = request.data || {};
      const message = String(data.message || "").trim();

      if (!message) {
        throw new HttpsError("invalid-argument", "Nachricht darf nicht leer sein.");
      }
      if (message.length > 2000) {
        throw new HttpsError("invalid-argument", "Nachricht ist zu lang (max. 2000 Zeichen).");
      }

      // Rate limiting.
      checkMinuteRate(uid);
      await checkDailyRate(uid);

      // Build conversation history (OpenAI format).
      const messages = [
        {role: "system", content: MEDICAL_SYSTEM_PROMPT},
      ];

      const history = Array.isArray(data.history) ? data.history : [];
      for (const msg of history.slice(-20)) {
        const role = msg.role === "user" ? "user" : "assistant";
        const text = String(msg.text || "").trim();
        if (text) {
          messages.push({role, content: text});
        }
      }

      // Load patient context from Firestore (server-side, using verified uid).
      const contextSection = await loadPatientContext(uid);

      // Current user message with context.
      const userMessage = contextSection
        ? `${message}\n\n---\n[Systemkontext – nicht vom Patienten geschrieben]${contextSection}`
        : message;

      messages.push({role: "user", content: userMessage});

      // Call NVIDIA API (OpenAI-compatible).
      const apiKey = process.env.NVIDIA_API_KEY;
      if (!apiKey) {
        throw new HttpsError("internal", "AI service not configured.");
      }

      try {
        const response = await fetch("https://integrate.api.nvidia.com/v1/chat/completions", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${apiKey}`,
          },
          body: JSON.stringify({
            model: "meta/llama-3.1-70b-instruct",
            messages,
            max_tokens: 2048,
            temperature: 0.4,
            top_p: 0.9,
          }),
        });

        if (!response.ok) {
          const errText = await response.text();
          console.error("NVIDIA API error:", response.status, errText);
          throw new HttpsError("internal", `KI-Anfrage fehlgeschlagen (${response.status}).`);
        }

        const result = await response.json();
        const text = result.choices?.[0]?.message?.content;

        if (!text || text.trim().length === 0) {
          throw new HttpsError("internal", "Keine Antwort erhalten.");
        }

        return {answer: text.trim()};
      } catch (err) {
        if (err instanceof HttpsError) throw err;
        console.error("NVIDIA API error:", err);
        throw new HttpsError("internal", "KI-Anfrage fehlgeschlagen. Bitte versuche es erneut.");
      }
    },
);

// ─────────────────────────────────────────────────────────────────────────────
// Streaming variant – returns SSE chunks for progressive UI updates
// ─────────────────────────────────────────────────────────────────────────────

exports.askAssistantStream = onRequest(
    {
      secrets: ["NVIDIA_API_KEY"],
      cors: true,
      region: "us-central1",
    },
    async (req, res) => {
      if (req.method !== "POST") {
        res.status(405).send("Method not allowed");
        return;
      }

      // Verify Firebase Auth token.
      const authHeader = req.headers.authorization || "";
      if (!authHeader.startsWith("Bearer ")) {
        res.status(401).json({error: "Unauthorized"});
        return;
      }
      let uid;
      try {
        const decoded = await admin.auth().verifyIdToken(authHeader.substring(7));
        uid = decoded.uid;
      } catch (e) {
        res.status(401).json({error: "Invalid token"});
        return;
      }

      const data = req.body || {};
      const message = String(data.message || "").trim();
      if (!message) {
        res.status(400).json({error: "Nachricht darf nicht leer sein."});
        return;
      }
      if (message.length > 2000) {
        res.status(400).json({error: "Nachricht ist zu lang."});
        return;
      }

      // Rate limiting.
      try {
        checkMinuteRate(uid);
        await checkDailyRate(uid);
      } catch (e) {
        res.status(429).json({error: e.message || "Rate limited"});
        return;
      }

      // Build conversation history (OpenAI format).
      const messages = [
        {role: "system", content: MEDICAL_SYSTEM_PROMPT},
      ];

      const history = Array.isArray(data.history) ? data.history : [];
      for (const msg of history.slice(-20)) {
        const role = msg.role === "user" ? "user" : "assistant";
        const text = String(msg.text || "").trim();
        if (text) {
          messages.push({role, content: text});
        }
      }

      // Load patient context from Firestore (server-side, using verified uid).
      const contextSection = await loadPatientContext(uid);

      // Current user message with context.
      const userMessage = contextSection
        ? `${message}\n\n---\n[Systemkontext – nicht vom Patienten geschrieben]${contextSection}`
        : message;
      messages.push({role: "user", content: userMessage});

      // SSE headers.
      res.setHeader("Content-Type", "text/event-stream");
      res.setHeader("Cache-Control", "no-cache");
      res.setHeader("Connection", "keep-alive");
      res.setHeader("X-Accel-Buffering", "no");

      const apiKey = process.env.NVIDIA_API_KEY;
      if (!apiKey) {
        res.write(`data: ${JSON.stringify({error: "AI service not configured."})}'\n\n`);
        res.end();
        return;
      }

      try {
        const nvidiaRes = await fetch("https://integrate.api.nvidia.com/v1/chat/completions", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${apiKey}`,
          },
          body: JSON.stringify({
            model: "meta/llama-3.1-70b-instruct",
            messages,
            max_tokens: 2048,
            temperature: 0.4,
            top_p: 0.9,
            stream: true,
          }),
        });

        if (!nvidiaRes.ok) {
          const errText = await nvidiaRes.text();
          console.error("NVIDIA streaming error:", nvidiaRes.status, errText);
          res.write(`data: ${JSON.stringify({error: "KI-Anfrage fehlgeschlagen."})}\n\n`);
          res.end();
          return;
        }

        // Read NVIDIA SSE stream and forward text deltas.
        const reader = nvidiaRes.body.getReader();
        const decoder = new TextDecoder();
        let sseBuffer = "";

        while (true) {
          const {done, value} = await reader.read();
          if (done) break;

          sseBuffer += decoder.decode(value, {stream: true});
          const lines = sseBuffer.split("\n");
          sseBuffer = lines.pop(); // keep incomplete line

          for (const line of lines) {
            const trimmed = line.trim();
            if (!trimmed.startsWith("data: ")) continue;
            const payload = trimmed.substring(6);
            if (payload === "[DONE]") continue;
            try {
              const parsed = JSON.parse(payload);
              const delta = parsed.choices?.[0]?.delta?.content;
              if (delta) {
                res.write(`data: ${JSON.stringify({t: delta})}\n\n`);
              }
            } catch (e) {
              // skip unparseable
            }
          }
        }
      } catch (err) {
        console.error("Stream error:", err);
        res.write(`data: ${JSON.stringify({error: "Stream-Fehler."})}\n\n`);
      }

      res.write("data: [DONE]\n\n");
      res.end();
    },
);

// ─────────────────────────────────────────────────────────────────────────────
// In-App Purchase Verification
// ─────────────────────────────────────────────────────────────────────────────
//
// Required environment variables (set via: firebase functions:secrets:set NAME):
//
//   APPLE_BUNDLE_ID        – iOS Bundle Identifier (z.B. com.yourcompany.app)
//   APPLE_ISSUER_ID        – App Store Connect > Users & Access > Integrations >
//                            App Store Connect API > Issuer ID
//   APPLE_KEY_ID           – Key ID der App Store Connect API Key (.p8)
//   APPLE_PRIVATE_KEY      – Inhalt der .p8-Datei (Zeilenumbrüche als \n)
//
//   GOOGLE_PACKAGE_NAME         – Android package name (applicationId)
//   GOOGLE_SERVICE_ACCOUNT_JSON – Service Account JSON (komplett als String)

const PRO_PRODUCT_IDS = new Set([
  "einmonatproopbeg",
  "einjahrproopbeg",
]);

/**
 * Verifies an iOS subscription via the App Store Server API.
 * https://developer.apple.com/documentation/appstoreserverapi
 */
async function verifyAppleTransaction(transactionId, expectedProductId) {
  const issuerId = process.env.APPLE_ISSUER_ID;
  const keyId = process.env.APPLE_KEY_ID;
  const privateKeyRaw = process.env.APPLE_PRIVATE_KEY;
  const bundleId = process.env.APPLE_BUNDLE_ID;

  if (!issuerId || !keyId || !privateKeyRaw || !bundleId) {
    throw new HttpsError(
        "internal",
        "Apple IAP nicht konfiguriert (fehlende Umgebungsvariablen).",
    );
  }

  // .p8 files use literal \n in env vars – restore real newlines.
  const privateKey = privateKeyRaw.replace(/\\n/g, "\n");

  const now = Math.floor(Date.now() / 1000);
  const bearerToken = jwt.sign(
      {iss: issuerId, iat: now, exp: now + 300, aud: "appstoreconnect-v1", bid: bundleId},
      privateKey,
      {algorithm: "ES256", header: {kid: keyId, alg: "ES256"}},
  );

  const url = `https://api.storekit.itunes.apple.com/inApps/v1/transactions/${encodeURIComponent(transactionId)}`;
  const resp = await fetch(url, {headers: {Authorization: `Bearer ${bearerToken}`}});

  if (resp.status === 404) {
    throw new HttpsError("not-found", "Transaktion bei Apple nicht gefunden.");
  }
  if (!resp.ok) {
    const text = await resp.text();
    console.error("[verifyPurchase] Apple API error:", resp.status, text);
    throw new HttpsError("internal", `Apple API Fehler: ${resp.status}`);
  }

  const body = await resp.json();

  // signedTransactionInfo is a JWS (header.payload.signature).
  // Apple signs it – decode the payload (trust Apple's signing for now).
  const parts = (body.signedTransactionInfo || "").split(".");
  if (parts.length < 2) {
    throw new HttpsError("internal", "Ungültige Apple-Transaktionsantwort.");
  }
  const payload = JSON.parse(
      Buffer.from(parts[1], "base64url").toString("utf8"),
  );

  if (payload.bundleId !== bundleId) {
    throw new HttpsError("invalid-argument", "Bundle ID stimmt nicht überein.");
  }
  if (payload.productId !== expectedProductId) {
    throw new HttpsError("invalid-argument", "Produkt-ID stimmt nicht überein.");
  }
  if (payload.type !== "Auto-Renewable Subscription") {
    throw new HttpsError("invalid-argument", "Kein Abonnement-Kauf.");
  }

  const expiresAt = payload.expiresDate ? new Date(payload.expiresDate) : null;
  return {expiresAt};
}

/**
 * Verifies an Android subscription via the Google Play Developer API.
 * https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptionsv2/get
 */
async function verifyGoogleSubscription(purchaseToken, expectedProductId) {
  const serviceAccountJson = process.env.GOOGLE_SERVICE_ACCOUNT_JSON;
  const packageName = process.env.GOOGLE_PACKAGE_NAME;

  if (!serviceAccountJson || !packageName) {
    throw new HttpsError(
        "internal",
        "Google IAP nicht konfiguriert (fehlende Umgebungsvariablen).",
    );
  }

  let credentials;
  try {
    credentials = JSON.parse(serviceAccountJson);
  } catch {
    throw new HttpsError("internal", "GOOGLE_SERVICE_ACCOUNT_JSON ist kein gültiges JSON.");
  }

  const {google} = require("googleapis");
  const auth = new google.auth.GoogleAuth({
    credentials,
    scopes: ["https://www.googleapis.com/auth/androidpublisher"],
  });

  const androidpublisher = google.androidpublisher({version: "v3", auth});

  let result;
  try {
    result = await androidpublisher.purchases.subscriptionsv2.get({
      packageName,
      token: purchaseToken,
    });
  } catch (err) {
    throw new HttpsError("not-found", `Google Play API Fehler: ${err.message}`);
  }

  const sub = result.data;
  const activeStates = new Set([
    "SUBSCRIPTION_STATE_ACTIVE",
    "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
    "SUBSCRIPTION_STATE_ON_HOLD",
  ]);

  if (!activeStates.has(sub.subscriptionState)) {
    throw new HttpsError(
        "failed-precondition",
        `Abonnement nicht aktiv (Status: ${sub.subscriptionState}).`,
    );
  }

  const lineItems = sub.lineItems || [];
  const item = lineItems.find((li) => li.productId === expectedProductId);
  if (!item) {
    throw new HttpsError("invalid-argument", "Produkt-ID nicht im Abonnement gefunden.");
  }

  const expiresAt = item.expiryTime ? new Date(item.expiryTime) : null;
  return {expiresAt};
}

// ─────────────────────────────────────────────────────────────────────────────
// Pro-Key management (admin only)
// ─────────────────────────────────────────────────────────────────────────────

const BASE32_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

function generateKeyCode(length = 12) {
  const buf = crypto.randomBytes(length * 2); // extra bytes for modulo bias reduction
  let code = "";
  for (let i = 0; i < buf.length && code.length < length; i++) {
    const idx = buf[i] % BASE32_CHARS.length;
    // Skip if modulo bias (bias-free: only use values < floor(256/32)*32)
    if (buf[i] < Math.floor(256 / BASE32_CHARS.length) * BASE32_CHARS.length) {
      code += BASE32_CHARS[idx];
    }
  }
  // Fallback: fill remaining with safe random choice
  while (code.length < length) {
    const byte = crypto.randomBytes(1)[0];
    const idx = byte % BASE32_CHARS.length;
    if (byte < Math.floor(256 / BASE32_CHARS.length) * BASE32_CHARS.length) {
      code += BASE32_CHARS[idx];
    }
  }
  return code;
}

function formatKeyCode(code) {
  const parts = [];
  for (let i = 0; i < code.length; i += 4) parts.push(code.slice(i, i + 4));
  return parts.join("-");
}

function computeKeyId(normalizedCode) {
  return sha256("KEY_V1:" + normalizedCode);
}

/**
 * Create one or more Pro keys. Admin only.
 * Params: { count?: number (1-50), grantDays: number }
 * Returns: { keys: [{ key: string, keyId: string }] }
 */
exports.createProKeys = onCall({region: "europe-west1"}, async (request) => {
  requireAuth(request);
  if (!isAdmin(request)) throw new HttpsError("permission-denied", "Admin only.");
  const data = request.data || {};
  const count = Math.min(Math.max(Number(data.count || 1), 1), 50);
  const grantDays = Number(data.grantDays || 30);
  if (!grantDays || grantDays < 1) {
    throw new HttpsError("invalid-argument", "grantDays must be >= 1.");
  }

  const results = [];
  const batch = db.batch();

  for (let i = 0; i < count; i++) {
    const rawCode = generateKeyCode(12);
    const formatted = formatKeyCode(rawCode);
    const keyId = computeKeyId(rawCode);
    const ref = db.collection("adminKeys").doc(keyId);
    batch.set(ref, {
      keyId,
      type: "PRO",
      status: "active",
      grantDays,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdByUid: request.auth.uid,
    });
    results.push({key: formatted, keyId});
  }

  await batch.commit();

  await db.collection("auditLog").add({
    action: "KEY_CREATED",
    actorUid: request.auth.uid,
    count,
    grantDays,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {keys: results};
});

/**
 * List Pro keys. Admin only.
 * Params: { limit?: number, status?: 'active'|'redeemed'|'disabled' }
 * Returns: { keys: [...] }
 */
exports.listProKeys = onCall({region: "europe-west1"}, async (request) => {
  requireAuth(request);
  if (!isAdmin(request)) throw new HttpsError("permission-denied", "Admin only.");
  const data = request.data || {};
  const limit = Math.min(Number(data.limit || 200), 500);
  const status = data.status ? String(data.status) : null;

  let query = db.collection("adminKeys").orderBy("createdAt", "desc").limit(limit);
  if (status) query = query.where("status", "==", status);

  const snap = await query.get();
  const keys = snap.docs.map((d) => {
    const doc = d.data();
    return {
      keyId: d.id,
      status: doc.status || "active",
      grantDays: doc.grantDays || 0,
      createdAt: doc.createdAt?.toDate?.()?.toISOString() ?? null,
      redeemedAt: doc.redeemedAt?.toDate?.()?.toISOString() ?? null,
      redeemedByUid: doc.redeemedByUid ?? doc.usedByUid ?? null,
    };
  });

  return {keys};
});

/**
 * Disable a Pro key. Admin only.
 * Params: { keyId: string }
 */
exports.disableProKey = onCall({region: "europe-west1"}, async (request) => {
  requireAuth(request);
  if (!isAdmin(request)) throw new HttpsError("permission-denied", "Admin only.");
  const data = request.data || {};
  const keyId = String(data.keyId || "").trim();
  if (!keyId) throw new HttpsError("invalid-argument", "keyId required.");

  const ref = db.collection("adminKeys").doc(keyId);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Key not found.");

  await ref.update({
    status: "disabled",
    disabledAt: admin.firestore.FieldValue.serverTimestamp(),
    disabledByUid: request.auth.uid,
  });

  await db.collection("auditLog").add({
    action: "KEY_DISABLED",
    actorUid: request.auth.uid,
    keyId,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {keyId, disabled: true};
});

// ─────────────────────────────────────────────────────────────────────────────
// Doctor registration & verification
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Called when a doctor self-registers. Creates an Auth account, a user doc,
 * and a doctor_verifications request (status: pending).
 * No region → default (us-central1) to match client calls without region.
 */
exports.registerDoctor = onCall(async (request) => {
  const data = request.data || {};
  const name = String(data.name || "").trim();
  const email = String(data.email || "").trim().toLowerCase();
  const password = String(data.password || "");
  const specialty = String(data.specialty || "").trim();
  const approbationNumber = String(data.approbationNumber || "").trim();
  const practiceName = String(data.practiceName || "").trim();
  const kvNumber = String(data.kvNumber || "").trim();

  if (!name || !email || !password || !specialty || !approbationNumber || !practiceName) {
    throw new HttpsError("invalid-argument", "Pflichtfelder fehlen.");
  }
  if (password.length < 8) {
    throw new HttpsError("invalid-argument", "Passwort muss mindestens 8 Zeichen lang sein.");
  }

  // Create Firebase Auth user.
  let authUser;
  try {
    authUser = await admin.auth().createUser({email, password, displayName: name});
  } catch (err) {
    if (err.code === "auth/email-already-exists") {
      throw new HttpsError("already-exists", "Diese E-Mail ist bereits registriert.");
    }
    throw new HttpsError("internal", "Konto konnte nicht erstellt werden.");
  }

  const uid = authUser.uid;

  // Set custom claims: doctor but not yet verified.
  await admin.auth().setCustomUserClaims(uid, {doctor: true, verified: false});

  const batch = db.batch();

  // User doc.
  batch.set(db.doc(`users/${uid}`), {
    role: "doctor",
    email,
    displayName: name,
    doctorVerified: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Doctor workspace doc.
  batch.set(db.doc(`doctors/${uid}`), {
    uid,
    name,
    email,
    specialty,
    practiceName,
    approbationNumber,
    kvNumber: kvNumber || null,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Verification request.
  batch.set(db.doc(`doctor_verifications/${uid}`), {
    uid,
    name,
    email,
    specialty,
    approbationNumber,
    practiceName,
    kvNumber: kvNumber || null,
    status: "pending",
    submittedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // Audit log.
  batch.set(db.collection("auditLog").doc(), {
    action: "DOCTOR_REGISTRATION",
    actorUid: uid,
    targetUid: uid,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  await batch.commit();

  return {uid, status: "pending"};
});

/**
 * Called by admin to approve or reject a doctor registration.
 * No region → default (us-central1) to match client calls without region.
 */
exports.verifyDoctor = onCall(async (request) => {
  requireAuth(request);
  if (!isAdmin(request)) {
    throw new HttpsError("permission-denied", "Admin only.");
  }

  const data = request.data || {};
  const uid = String(data.uid || "").trim();
  const approved = data.approved === true;
  const reason = String(data.reason || "").trim();

  if (!uid) throw new HttpsError("invalid-argument", "uid required.");

  const verificationRef = db.doc(`doctor_verifications/${uid}`);
  const snap = await verificationRef.get();
  if (!snap.exists) throw new HttpsError("not-found", "Verifikationsantrag nicht gefunden.");

  const current = snap.data() || {};
  if (current.status !== "pending") {
    throw new HttpsError("failed-precondition", `Antrag ist bereits ${current.status}.`);
  }

  if (approved) {
    // Grant full doctor access.
    await admin.auth().setCustomUserClaims(uid, {doctor: true, verified: true, admin: false});

    const batch = db.batch();
    batch.set(db.doc(`users/${uid}`), {
      doctorVerified: true,
      verificationRejected: false,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, {merge: true});
    batch.update(verificationRef, {
      status: "approved",
      reviewedBy: request.auth.uid,
      reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    batch.set(db.collection("auditLog").doc(), {
      action: "DOCTOR_APPROVED",
      actorUid: request.auth.uid,
      targetUid: uid,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    await batch.commit();
  } else {
    const batch = db.batch();
    batch.set(db.doc(`users/${uid}`), {
      doctorVerified: false,
      verificationRejected: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, {merge: true});
    batch.update(verificationRef, {
      status: "rejected",
      reason: reason || "Kein Grund angegeben",
      reviewedBy: request.auth.uid,
      reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    batch.set(db.collection("auditLog").doc(), {
      action: "DOCTOR_REJECTED",
      actorUid: request.auth.uid,
      targetUid: uid,
      reason,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
    await batch.commit();

    // Revoke verified claim so doctor cannot use doctor-only features.
    await admin.auth().setCustomUserClaims(uid, {doctor: true, verified: false});
  }

  return {uid, approved};
});

/**
 * Called by the Flutter app after a successful purchase.
 * Verifies the receipt server-side and sets isPro = true in Firestore.
 */
exports.verifyPurchase = onCall(async (request) => {
  const uid = requireAuth(request);
  const data = request.data || {};

  const productId = String(data.productId || "").trim();
  const purchaseToken = String(data.purchaseToken || "").trim();
  const transactionId = String(data.transactionId || "").trim();
  const platform = String(data.platform || "").trim();

  if (!productId || !purchaseToken || !platform) {
    throw new HttpsError("invalid-argument", "Pflichtfelder fehlen.");
  }
  if (!PRO_PRODUCT_IDS.has(productId)) {
    throw new HttpsError("invalid-argument", "Unbekannte Produkt-ID.");
  }

  let expiresAt = null;

  if (platform === "ios") {
    if (!transactionId) {
      throw new HttpsError("invalid-argument", "transactionId ist für iOS erforderlich.");
    }
    const result = await verifyAppleTransaction(transactionId, productId);
    expiresAt = result.expiresAt;
  } else if (platform === "android") {
    const result = await verifyGoogleSubscription(purchaseToken, productId);
    expiresAt = result.expiresAt;
  } else {
    throw new HttpsError("invalid-argument", "Unbekannte Plattform (erwartet: 'ios' oder 'android').");
  }

  await db.doc(`users/${uid}`).set(
      {
        isPro: true,
        proProductId: productId,
        proPlatform: platform,
        proExpiresAt: expiresAt ?
          admin.firestore.Timestamp.fromDate(expiresAt) : null,
        proUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      {merge: true},
  );

  return {success: true};
});

// ─────────────────────────────────────────────────────────────────────────────
// Admin Push Notifications
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Sends an FCM push notification to a target group.
 * Params: { title, body, targetType: 'all'|'role'|'user', targetValue?: string }
 */
exports.sendAdminNotification = onCall({region: "europe-west1"}, async (request) => {
  requireAuth(request);
  if (!isAdmin(request)) throw new HttpsError("permission-denied", "Admin only.");

  const data = request.data || {};
  const title = String(data.title || "").trim();
  const body = String(data.body || "").trim();
  const targetType = String(data.targetType || "all");
  const targetValue = String(data.targetValue || "").trim();

  if (!title || !body) throw new HttpsError("invalid-argument", "title und body sind erforderlich.");

  // ── Collect FCM tokens ────────────────────────────────────────
  let usersQuery = db.collection("users");
  let query;

  if (targetType === "all") {
    query = usersQuery.where("fcmToken", "!=", null);
  } else if (targetType === "role" && targetValue) {
    query = usersQuery.where("role", "==", targetValue).where("fcmToken", "!=", null);
  } else if (targetType === "user" && targetValue) {
    query = usersQuery.where(admin.firestore.FieldPath.documentId(), "==", targetValue);
  } else if (targetType === "system") {
    // System messages go to all.
    query = usersQuery.where("fcmToken", "!=", null);
  } else {
    throw new HttpsError("invalid-argument", "Ungültige Zielgruppe.");
  }

  const snap = await query.limit(2000).get();
  const tokens = [];
  snap.docs.forEach((doc) => {
    const token = doc.data()?.fcmToken;
    if (token && typeof token === "string") tokens.push(token);
  });

  let recipientCount = 0;

  if (tokens.length > 0) {
    // FCM multicast in batches of 500.
    const BATCH_SIZE = 500;
    for (let i = 0; i < tokens.length; i += BATCH_SIZE) {
      const batchTokens = tokens.slice(i, i + BATCH_SIZE);
      const message = {
        notification: {title, body},
        tokens: batchTokens,
      };
      try {
        const response = await admin.messaging().sendEachForMulticast(message);
        recipientCount += response.successCount;
      } catch (err) {
        console.error("[sendAdminNotification] FCM batch error:", err);
      }
    }
  }

  // ── Log to adminNotifications ─────────────────────────────────
  await db.collection("adminNotifications").add({
    title,
    body,
    targetType,
    targetValue: targetValue || null,
    actorUid: request.auth.uid,
    recipientCount,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {recipientCount};
});

// ── Admin Statistics ──────────────────────────────────────────────────────────
exports.getAdminStats = onCall({region: "europe-west1"}, async (request) => {
  requireAuth(request);
  if (!isAdmin(request)) {
    throw new HttpsError("permission-denied", "Admins only.");
  }

  // ── User counts by role ───────────────────────────────────────
  const usersSnap = await db.collection("users").get();
  let totalUsers = 0;
  let totalPatients = 0;
  let totalDoctors = 0;
  let totalFamily = 0;
  let proActive = 0;

  usersSnap.forEach((doc) => {
    const d = doc.data();
    totalUsers++;
    const role = d.role;
    if (role === "patient") totalPatients++;
    else if (role === "doctor") totalDoctors++;
    else if (role === "caregiver" || role === "family") totalFamily++;
    if (d.isPro === true) proActive++;
  });

  // ── Registration history (30 days) ───────────────────────────
  const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const recentUsersSnap = await db.collection("users")
      .where("createdAt", ">=", admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
      .get();

  const regByDay = {};
  recentUsersSnap.forEach((doc) => {
    const createdAt = doc.data().createdAt?.toDate();
    if (createdAt) {
      const key = createdAt.toISOString().slice(0, 10);
      regByDay[key] = (regByDay[key] || 0) + 1;
    }
  });

  const registrationHistory = [];
  for (let i = 29; i >= 0; i--) {
    const d = new Date(Date.now() - i * 24 * 60 * 60 * 1000);
    const key = d.toISOString().slice(0, 10);
    registrationHistory.push({date: key, count: regByDay[key] || 0});
  }

  // ── Admin activity (7 days from auditLog) ────────────────────
  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
  const auditSnap = await db.collection("auditLog")
      .where("timestamp", ">=", admin.firestore.Timestamp.fromDate(sevenDaysAgo))
      .get();

  const actByDay = {};
  const actionCounts = {};
  auditSnap.forEach((doc) => {
    const d = doc.data();
    const ts = d.timestamp?.toDate();
    if (ts) {
      const key = ts.toISOString().slice(0, 10);
      actByDay[key] = (actByDay[key] || 0) + 1;
    }
    const action = d.action || "unknown";
    actionCounts[action] = (actionCounts[action] || 0) + 1;
  });

  const activityHistory = [];
  for (let i = 6; i >= 0; i--) {
    const d = new Date(Date.now() - i * 24 * 60 * 60 * 1000);
    const key = d.toISOString().slice(0, 10);
    activityHistory.push({date: key, count: actByDay[key] || 0});
  }

  // ── Write to adminStats/global and return ────────────────────
  const statsData = {
    totalUsers,
    totalPatients,
    totalDoctors,
    totalFamily,
    proActive,
    registrationHistory,
    activityHistory,
    actionCounts,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await db.doc("adminStats/global").set(statsData);
  return {success: true};
});

// ── Maintenance Mode ──────────────────────────────────────────────────────────
exports.setMaintenanceMode = onCall({region: "europe-west1"}, async (request) => {
  requireAuth(request);
  if (!isAdmin(request)) {
    throw new HttpsError("permission-denied", "Admins only.");
  }

  const data = request.data || {};
  const enabled = data.enabled === true;
  const message = typeof data.message === "string" ? data.message.trim() : "";

  await db.doc("appConfig/global").set({
    maintenanceMode: enabled,
    maintenanceMessage: message || null,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedBy: request.auth.uid,
  }, {merge: true});

  // Audit log entry.
  await db.collection("auditLog").add({
    action: "MAINTENANCE",
    detail: enabled ? `Wartungsmodus aktiviert: ${message || "–"}` : "Wartungsmodus deaktiviert",
    actorUid: request.auth.uid,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return {success: true, enabled};
});
