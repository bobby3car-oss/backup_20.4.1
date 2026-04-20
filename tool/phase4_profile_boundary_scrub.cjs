const crypto = require("crypto");
const {execSync} = require("child_process");
const path = require("path");
const {createRequire} = require("module");

const functionsRequire = createRequire(
  path.resolve(__dirname, "../functions/package.json"),
);
const admin = functionsRequire("firebase-admin");
const {applicationDefault} = functionsRequire("firebase-admin/app");

const PROJECT_ID = "operationsbegleiter-860e7";
const PRIVATE_NORMALIZE_FIELDS = [
  "email",
  "hospitalName",
  "doctorName",
  "emergencyContactName",
  "emergencyContactPhone",
];
const SHELL_PRIVATE_DELETE_FIELDS = [
  "hospitalName",
  "doctorName",
  "emergencyContactName",
  "emergencyContactPhone",
  "hospitalPhone",
  "doctorPhone",
  "insuranceInfo",
  "bloodType",
  "allergies",
  "currentMedications",
  "bellaConsent",
];
const SHELL_CARE_DELETE_FIELDS = ["age", "opType", "opDate"];

if (!admin.apps.length) {
  admin.initializeApp({
    credential: applicationDefault(),
    projectId: PROJECT_ID,
  });
}

const db = admin.firestore();

function getActorEmail() {
  try {
    return execSync("gcloud config get-value account 2>/dev/null", {
      encoding: "utf8",
    }).trim() || null;
  } catch (_) {
    return null;
  }
}

async function loadLegacySharedKey() {
  const snap = await db.doc("appConfig/encryption").get();
  if (!snap.exists) {
    return null;
  }

  const data = snap.data() || {};
  const version = data.version || 1;
  const salt = version >= 2 ? data.salt : "OpBegleiter2025SharedFieldKey";
  if (!salt || !data.encryptedKey) {
    return null;
  }

  const wrapKey = crypto.createHash("sha256")
      .update(`opbegleiter:${salt}:shared_field_encryption`)
      .digest();

  const backupBlob = Buffer.from(data.encryptedKey, "base64");
  const wrapIv = backupBlob.subarray(0, 16);
  const wrapCipher = backupBlob.subarray(16);
  const wrapTagStart = wrapCipher.length - 16;
  const wrapCiphertext = wrapCipher.subarray(0, wrapTagStart);
  const wrapTag = wrapCipher.subarray(wrapTagStart);

  const decipher = crypto.createDecipheriv("aes-256-gcm", wrapKey, wrapIv);
  decipher.setAuthTag(wrapTag);
  const masterKeyBase64 = Buffer.concat([
    decipher.update(wrapCiphertext),
    decipher.final(),
  ]).toString("utf8");

  return Buffer.from(masterKeyBase64, "base64");
}

function decryptLegacySharedField(value, legacyKey) {
  if (!legacyKey || typeof value !== "string" || !value) {
    return null;
  }

  try {
    const blob = Buffer.from(value, "base64");
    if (blob.length < 17) {
      return null;
    }

    const iv = blob.subarray(0, 16);
    const rest = blob.subarray(16);
    const tagStart = rest.length - 16;
    if (tagStart <= 0) {
      return null;
    }

    const ciphertext = rest.subarray(0, tagStart);
    const tag = rest.subarray(tagStart);
    const decipher = crypto.createDecipheriv("aes-256-gcm", legacyKey, iv);
    decipher.setAuthTag(tag);
    return Buffer.concat([
      decipher.update(ciphertext),
      decipher.final(),
    ]).toString("utf8");
  } catch (_) {
    return null;
  }
}

async function main() {
  const legacyKey = await loadLegacySharedKey();
  if (!legacyKey) {
    throw new Error("Legacy shared key unavailable");
  }

  const actorEmail = getActorEmail();
  const usersSnap = await db.collection("users").get();
  const summary = {
    usersScanned: usersSnap.size,
    usersTouched: 0,
    shellDisplayNamesNormalized: 0,
    privateFieldsNormalized: 0,
    careDisplayNamesNormalized: 0,
    shellPrivateFieldsRemoved: 0,
    shellCareFieldsRemoved: 0,
    lastUid: null,
  };

  let batch = db.batch();
  let batchWrites = 0;

  async function commitBatch() {
    if (batchWrites == 0) {
      return;
    }
    await batch.commit();
    batch = db.batch();
    batchWrites = 0;
  }

  for (const userDoc of usersSnap.docs) {
    const uid = userDoc.id;
    summary.lastUid = uid;
    const userData = userDoc.data() || {};
    const userRef = db.doc(`users/${uid}`);
    const privateRef = db.doc(`users/${uid}/private/profile`);
    const careRef = db.doc(`patients/${uid}/care_profile/current`);

    const [privateSnap, careSnap] = await Promise.all([
      privateRef.get(),
      careRef.get(),
    ]);

    const userPatch = {};
    const privatePatch = {};
    const carePatch = {};

    const normalizedDisplayName = decryptLegacySharedField(
        userData.displayName,
        legacyKey,
    );
    if (normalizedDisplayName && normalizedDisplayName !== userData.displayName) {
      userPatch.displayName = normalizedDisplayName;
      summary.shellDisplayNamesNormalized += 1;
    }

    const privateData = privateSnap.data() || {};
    for (const field of PRIVATE_NORMALIZE_FIELDS) {
      const currentValue = privateData[field];
      const normalizedValue = decryptLegacySharedField(currentValue, legacyKey);
      if (normalizedValue && normalizedValue !== currentValue) {
        privatePatch[field] = normalizedValue;
        summary.privateFieldsNormalized += 1;
      }
    }

    if (privateSnap.exists) {
      for (const field of SHELL_PRIVATE_DELETE_FIELDS) {
        if (Object.prototype.hasOwnProperty.call(userData, field)) {
          userPatch[field] = admin.firestore.FieldValue.delete();
          summary.shellPrivateFieldsRemoved += 1;
        }
      }
    }

    const careData = careSnap.data() || {};
    if (careSnap.exists) {
      const normalizedCareDisplayName = decryptLegacySharedField(
          careData.displayName,
          legacyKey,
      );
      if (
        normalizedCareDisplayName &&
        normalizedCareDisplayName !== careData.displayName
      ) {
        carePatch.displayName = normalizedCareDisplayName;
        summary.careDisplayNamesNormalized += 1;
      }

      for (const field of SHELL_CARE_DELETE_FIELDS) {
        if (Object.prototype.hasOwnProperty.call(userData, field)) {
          userPatch[field] = admin.firestore.FieldValue.delete();
          summary.shellCareFieldsRemoved += 1;
        }
      }
    }

    let touched = false;
    if (Object.keys(userPatch).length > 0) {
      userPatch.updatedAt = admin.firestore.FieldValue.serverTimestamp();
      batch.set(userRef, userPatch, {merge: true});
      batchWrites += 1;
      touched = true;
    }
    if (Object.keys(privatePatch).length > 0) {
      privatePatch.updatedAt = admin.firestore.FieldValue.serverTimestamp();
      batch.set(privateRef, privatePatch, {merge: true});
      batchWrites += 1;
      touched = true;
    }
    if (Object.keys(carePatch).length > 0) {
      carePatch.updatedAt = admin.firestore.FieldValue.serverTimestamp();
      batch.set(careRef, carePatch, {merge: true});
      batchWrites += 1;
      touched = true;
    }
    if (touched) {
      summary.usersTouched += 1;
    }

    if (batchWrites >= 400) {
      await commitBatch();
    }
  }

  batch.set(db.collection("auditLog").doc(), {
    action: "PROFILE_BOUNDARIES_PHASE4_SCRUBBED",
    actorUid: null,
    actorEmail,
    mode: "adc-script",
    ...summary,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });
  batchWrites += 1;
  await commitBatch();

  console.log(JSON.stringify(summary, null, 2));
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});