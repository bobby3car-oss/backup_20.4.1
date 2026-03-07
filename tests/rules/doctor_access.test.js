/**
 * Firestore Security Rules – Doctor Access Tests
 * ===========================================================
 *
 * Tests that a linked doctor can:
 *   1. Query links via collectionGroup
 *   2. Read patient user documents
 *   3. Read patient root documents
 *   4. Read patient feature subcollections (timeline, wounds, etc.)
 *
 * Run with:
 *   cd tests/rules
 *   npm install
 *   npm run test:doctor:emulator
 */

const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");
const { expect } = require("chai");
const { readFileSync } = require("fs");
const { resolve } = require("path");

const PROJECT_ID = "operationsbegleiter-860e7";
const RULES_PATH = resolve(__dirname, "../../firestore.rules");
const RULES = readFileSync(RULES_PATH, "utf8");

// Test users
const DOCTOR_UID = "doctor001";
const PATIENT_UID = "patient001";
const PATIENT2_UID = "patient002"; // not linked to doctor
const CAREGIVER_UID = "caregiver001";
const OTHER_UID = "other001";

let testEnv;

// ── Seed data ─────────────────────────────────────────────────────

async function seedData(env) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();

    // ── User documents ──
    await db.doc(`users/${DOCTOR_UID}`).set({
      role: "doctor",
      displayName: "Dr. Test",
      email: "doctor@test.com",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await db.doc(`users/${PATIENT_UID}`).set({
      role: "patient",
      displayName: "Patient One",
      email: "patient1@test.com",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await db.doc(`users/${PATIENT2_UID}`).set({
      role: "patient",
      displayName: "Patient Two",
      email: "patient2@test.com",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // ── Patient root documents ──
    await db.doc(`patients/${PATIENT_UID}`).set({
      profile: {
        opDate: "2026-03-15",
        diagnosis: "Knie-TEP",
      },
      settings: {},
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await db.doc(`patients/${PATIENT2_UID}`).set({
      profile: {
        opDate: "2026-04-01",
        diagnosis: "Hüfte-TEP",
      },
      settings: {},
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // ── Active doctor link for PATIENT_UID → DOCTOR_UID ──
    await db
      .doc(`patients/${PATIENT_UID}/links/${DOCTOR_UID}_doctor`)
      .set({
        linkType: "doctor",
        linkedUid: DOCTOR_UID,
        status: "active",
        permissions: { read: true, write: false },
        createdAt: new Date(),
        createdBy: PATIENT_UID,
      });

    // ── NO link for PATIENT2_UID (doctor NOT linked) ──

    // ── Feature subcollection data for PATIENT_UID ──
    await db.doc(`patients/${PATIENT_UID}/timeline/entry1`).set({
      ownerId: PATIENT_UID,
      type: "wound",
      createdAt: new Date(),
      updatedAt: new Date(),
      title: "Wunddokumentation",
    });

    await db.doc(`patients/${PATIENT_UID}/wounds/w1`).set({
      ownerId: PATIENT_UID,
      createdAt: new Date(),
      updatedAt: new Date(),
      severity: 3,
    });

    await db.doc(`patients/${PATIENT_UID}/pain/p1`).set({
      ownerId: PATIENT_UID,
      createdAt: new Date(),
      updatedAt: new Date(),
      occurredAt: new Date(),
      level: 5,
    });

    await db.doc(`patients/${PATIENT_UID}/appointments/a1`).set({
      ownerId: PATIENT_UID,
      createdAt: new Date(),
      updatedAt: new Date(),
      startAt: new Date(),
      title: "Nachuntersuchung",
    });

    await db.doc(`patients/${PATIENT_UID}/documents/d1`).set({
      ownerId: PATIENT_UID,
      createdAt: new Date(),
      updatedAt: new Date(),
      name: "Arztbrief.pdf",
    });

    await db.doc(`patients/${PATIENT_UID}/photos/ph1`).set({
      ownerId: PATIENT_UID,
      createdAt: new Date(),
      updatedAt: new Date(),
      url: "https://example.com/photo.jpg",
    });

    await db.doc(`patients/${PATIENT_UID}/red_flags/rf1`).set({
      ownerId: PATIENT_UID,
      createdAt: new Date(),
      updatedAt: new Date(),
      type: "fever",
    });

    await db.doc(`patients/${PATIENT_UID}/observations/obs1`).set({
      ownerId: PATIENT_UID,
      createdAt: new Date(),
      updatedAt: new Date(),
      note: "Schwellung am Knie",
    });
  });
}

// ── Mocha setup ───────────────────────────────────────────────────

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: RULES,
      host: "127.0.0.1",
      port: 8080,
    },
  });
});

beforeEach(async () => {
  await testEnv.clearFirestore();
  await seedData(testEnv);
});

after(async () => {
  await testEnv.cleanup();
});

// ── Helpers ───────────────────────────────────────────────────────

function doctorDb() {
  return testEnv.authenticatedContext(DOCTOR_UID).firestore();
}

function patientDb() {
  return testEnv.authenticatedContext(PATIENT_UID).firestore();
}

function otherDb() {
  return testEnv.authenticatedContext(OTHER_UID).firestore();
}

function unauthedDb() {
  return testEnv.unauthenticatedContext().firestore();
}

// ═══════════════════════════════════════════════════════════════════
// 1. LINKS – collectionGroup query
// ═══════════════════════════════════════════════════════════════════

describe("Doctor links – collectionGroup queries", () => {

  it("doctor can GET their own link document directly", async () => {
    const db = doctorDb();
    const ref = db.doc(
      `patients/${PATIENT_UID}/links/${DOCTOR_UID}_doctor`
    );
    const snap = await assertSucceeds(ref.get());
    expect(snap.exists).to.equal(true);
    expect(snap.data().linkedUid).to.equal(DOCTOR_UID);
  });

  it("doctor can query links collectionGroup filtered by linkedUid", async () => {
    const db = doctorDb();
    const query = db
      .collectionGroup("links")
      .where("linkedUid", "==", DOCTOR_UID)
      .where("status", "==", "active")
      .where("linkType", "==", "doctor");
    const snap = await assertSucceeds(query.get());
    expect(snap.docs.length).to.equal(1);
    expect(snap.docs[0].data().linkedUid).to.equal(DOCTOR_UID);
  });

  it("other user CANNOT query links collectionGroup for doctor's links", async () => {
    const db = otherDb();
    const query = db
      .collectionGroup("links")
      .where("linkedUid", "==", DOCTOR_UID)
      .where("status", "==", "active")
      .where("linkType", "==", "doctor");
    // This should fail because other user's uid != DOCTOR_UID
    await assertFails(query.get());
  });

  it("patient can read their own links", async () => {
    const db = patientDb();
    const query = db
      .collection(`patients/${PATIENT_UID}/links`)
      .get();
    await assertSucceeds(query);
  });

  it("unauthenticated user CANNOT query links", async () => {
    const db = unauthedDb();
    const query = db
      .collectionGroup("links")
      .where("linkedUid", "==", DOCTOR_UID);
    await assertFails(query.get());
  });
});

// ═══════════════════════════════════════════════════════════════════
// 2. USER DOCUMENTS – doctor reads patient's user doc
// ═══════════════════════════════════════════════════════════════════

describe("Doctor reading user documents", () => {

  it("doctor can read linked patient's user doc", async () => {
    const db = doctorDb();
    const snap = await assertSucceeds(
      db.doc(`users/${PATIENT_UID}`).get()
    );
    expect(snap.exists).to.equal(true);
    expect(snap.data().displayName).to.equal("Patient One");
  });

  it("doctor CANNOT read unlinked patient's user doc", async () => {
    const db = doctorDb();
    await assertFails(db.doc(`users/${PATIENT2_UID}`).get());
  });

  it("doctor can read their own user doc", async () => {
    const db = doctorDb();
    await assertSucceeds(db.doc(`users/${DOCTOR_UID}`).get());
  });
});

// ═══════════════════════════════════════════════════════════════════
// 3. PATIENT ROOT DOCUMENT – doctor reads patient root
// ═══════════════════════════════════════════════════════════════════

describe("Doctor reading patient root document", () => {

  it("doctor can read linked patient's root document", async () => {
    const db = doctorDb();
    const snap = await assertSucceeds(
      db.doc(`patients/${PATIENT_UID}`).get()
    );
    expect(snap.exists).to.equal(true);
    expect(snap.data().profile.diagnosis).to.equal("Knie-TEP");
  });

  it("doctor CANNOT read unlinked patient's root document", async () => {
    const db = doctorDb();
    await assertFails(db.doc(`patients/${PATIENT2_UID}`).get());
  });
});

// ═══════════════════════════════════════════════════════════════════
// 4. FEATURE SUBCOLLECTIONS – doctor reads patient data
// ═══════════════════════════════════════════════════════════════════

describe("Doctor reading patient feature subcollections", () => {

  const features = [
    { name: "timeline", docId: "entry1" },
    { name: "wounds", docId: "w1" },
    { name: "pain", docId: "p1" },
    { name: "appointments", docId: "a1" },
    { name: "documents", docId: "d1" },
    { name: "photos", docId: "ph1" },
    { name: "red_flags", docId: "rf1" },
    { name: "observations", docId: "obs1" },
  ];

  for (const { name, docId } of features) {
    it(`doctor can read linked patient's ${name}`, async () => {
      const db = doctorDb();
      const ref = db.doc(
        `patients/${PATIENT_UID}/${name}/${docId}`
      );
      await assertSucceeds(ref.get());
    });

    it(`doctor CANNOT read unlinked patient's ${name}`, async () => {
      const db = doctorDb();
      // No documents seeded for PATIENT2, but even if they exist
      // the read should fail because there's no link.
      // We need a doc to exist for the rule to be evaluated.
      // Seed one first via admin context.
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        const adminDb = ctx.firestore();
        await adminDb.doc(`patients/${PATIENT2_UID}/${name}/test1`).set({
          ownerId: PATIENT2_UID,
          createdAt: new Date(),
          updatedAt: new Date(),
        });
      });

      const ref = db.doc(
        `patients/${PATIENT2_UID}/${name}/test1`
      );
      await assertFails(ref.get());
    });
  }

  it("doctor can list linked patient's timeline collection", async () => {
    const db = doctorDb();
    const query = db
      .collection(`patients/${PATIENT_UID}/timeline`)
      .get();
    const snap = await assertSucceeds(query);
    expect(snap.docs.length).to.be.greaterThan(0);
  });
});

// ═══════════════════════════════════════════════════════════════════
// 5. WRITE ACCESS – doctor with read-only link cannot write
// ═══════════════════════════════════════════════════════════════════

describe("Doctor write access (read-only link)", () => {

  it("doctor CANNOT write to linked patient's timeline", async () => {
    const db = doctorDb();
    await assertFails(
      db.doc(`patients/${PATIENT_UID}/timeline/new_entry`).set({
        ownerId: PATIENT_UID,
        type: "note",
        createdAt: new Date(),
        updatedAt: new Date(),
      })
    );
  });

  it("doctor CAN create appointments for linked patient (special rule)", async () => {
    const db = doctorDb();
    await assertSucceeds(
      db.doc(`patients/${PATIENT_UID}/appointments/new_appt`).set({
        ownerId: PATIENT_UID,
        createdAt: new Date(),
        updatedAt: new Date(),
        startAt: new Date(),
        title: "Kontrolltermin",
      })
    );
  });
});

// ═══════════════════════════════════════════════════════════════════
// 6. INACTIVE LINK – doctor should not have access
// ═══════════════════════════════════════════════════════════════════

describe("Doctor with inactive link", () => {

  beforeEach(async () => {
    // Deactivate the link
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await db
        .doc(`patients/${PATIENT_UID}/links/${DOCTOR_UID}_doctor`)
        .update({
          status: "inactive",
          deactivatedAt: new Date(),
        });
    });
  });

  it("doctor CANNOT read patient user doc with inactive link", async () => {
    const db = doctorDb();
    await assertFails(db.doc(`users/${PATIENT_UID}`).get());
  });

  it("doctor CANNOT read patient root doc with inactive link", async () => {
    const db = doctorDb();
    await assertFails(db.doc(`patients/${PATIENT_UID}`).get());
  });

  it("doctor CANNOT read patient timeline with inactive link", async () => {
    const db = doctorDb();
    await assertFails(
      db.doc(`patients/${PATIENT_UID}/timeline/entry1`).get()
    );
  });
});
