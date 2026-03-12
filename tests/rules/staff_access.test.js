/**
 * Firestore Security Rules – Staff Access Tests
 * ===========================================================
 *
 * Tests that a staff member with per-feature permissions can:
 *   1. Read feature subcollections where staffPermissions[feature] is 'read' or 'readWrite'
 *   2. Write feature subcollections where staffPermissions[feature] is 'readWrite'
 *   3. NOT read/write features where staffPermissions[feature] is 'none'
 *   4. NOT access patients whose doctor has no active link
 *
 * Run with:
 *   cd tests/rules
 *   npm install
 *   npm run test:staff:emulator
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
const STAFF_UID = "staff001";
const PATIENT_UID = "patient001";
const PATIENT2_UID = "patient002"; // not linked to doctor
const OTHER_UID = "other001";

let testEnv;

// ── Seed data ─────────────────────────────────────────────────────

async function seedData(env) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();

    // ── Doctor user doc ──
    await db.doc(`users/${DOCTOR_UID}`).set({
      role: "doctor",
      displayName: "Dr. Test",
      email: "doctor@test.com",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // ── Staff user doc (with per-feature permissions) ──
    await db.doc(`users/${STAFF_UID}`).set({
      role: "staff",
      staffOf: DOCTOR_UID,
      displayName: "Staff One",
      email: "staff@test.com",
      staffPermissions: {
        appointments: "readWrite",
        timeline: "read",
        vitals: "none",
        pain: "read",
        wounds: "readWrite",
        documents: "none",
        redFlags: "read",
        templates: "none",
        invites: "none",
      },
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // ── Patient user docs ──
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
      profile: { opDate: "2026-03-15", diagnosis: "Knie-TEP" },
      settings: {},
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await db.doc(`patients/${PATIENT2_UID}`).set({
      profile: { opDate: "2026-04-01", diagnosis: "Hüfte-TEP" },
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
        permissions: { read: true, write: true },
        createdAt: new Date(),
        createdBy: PATIENT_UID,
      });

    // ── NO link for PATIENT2_UID (doctor NOT linked) ──

    // ── Feature subcollection data for PATIENT_UID ──
    await db.doc(`patients/${PATIENT_UID}/appointments/a1`).set({
      ownerId: PATIENT_UID,
      createdAt: new Date(),
      updatedAt: new Date(),
      startAt: new Date(),
      title: "Nachuntersuchung",
    });

    await db.doc(`patients/${PATIENT_UID}/timeline/entry1`).set({
      ownerId: PATIENT_UID,
      type: "wound",
      createdAt: new Date(),
      updatedAt: new Date(),
      title: "Wunddokumentation",
    });

    await db.doc(`patients/${PATIENT_UID}/vitals/v1`).set({
      ownerId: PATIENT_UID,
      createdAt: new Date(),
      updatedAt: new Date(),
      heartRate: 72,
    });

    await db.doc(`patients/${PATIENT_UID}/pain/p1`).set({
      ownerId: PATIENT_UID,
      createdAt: new Date(),
      updatedAt: new Date(),
      occurredAt: new Date(),
      level: 5,
    });

    await db.doc(`patients/${PATIENT_UID}/wounds/w1`).set({
      ownerId: PATIENT_UID,
      createdAt: new Date(),
      updatedAt: new Date(),
      severity: 3,
    });

    await db.doc(`patients/${PATIENT_UID}/documents/d1`).set({
      ownerId: PATIENT_UID,
      createdAt: new Date(),
      updatedAt: new Date(),
      name: "Arztbrief.pdf",
    });

    await db.doc(`patients/${PATIENT_UID}/red_flags/rf1`).set({
      ownerId: PATIENT_UID,
      createdAt: new Date(),
      updatedAt: new Date(),
      type: "fever",
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

function staffDb() {
  return testEnv.authenticatedContext(STAFF_UID).firestore();
}

function otherDb() {
  return testEnv.authenticatedContext(OTHER_UID).firestore();
}

// ═══════════════════════════════════════════════════════════════════
// 1. FEATURE READ — allowed features (read or readWrite)
// ═══════════════════════════════════════════════════════════════════

describe("Staff feature reads – allowed", () => {

  it("staff can read appointments (permission: readWrite)", async () => {
    const db = staffDb();
    await assertSucceeds(db.doc(`patients/${PATIENT_UID}/appointments/a1`).get());
  });

  it("staff can read timeline (permission: read)", async () => {
    const db = staffDb();
    await assertSucceeds(db.doc(`patients/${PATIENT_UID}/timeline/entry1`).get());
  });

  it("staff can read pain (permission: read)", async () => {
    const db = staffDb();
    await assertSucceeds(db.doc(`patients/${PATIENT_UID}/pain/p1`).get());
  });

  it("staff can read wounds (permission: readWrite)", async () => {
    const db = staffDb();
    await assertSucceeds(db.doc(`patients/${PATIENT_UID}/wounds/w1`).get());
  });

  it("staff can read red_flags (permission: read)", async () => {
    const db = staffDb();
    await assertSucceeds(db.doc(`patients/${PATIENT_UID}/red_flags/rf1`).get());
  });
});

// ═══════════════════════════════════════════════════════════════════
// 2. FEATURE READ — denied features (none)
// ═══════════════════════════════════════════════════════════════════

describe("Staff feature reads – denied", () => {

  it("staff CANNOT read vitals (permission: none)", async () => {
    const db = staffDb();
    await assertFails(db.doc(`patients/${PATIENT_UID}/vitals/v1`).get());
  });

  it("staff CANNOT read documents (permission: none)", async () => {
    const db = staffDb();
    await assertFails(db.doc(`patients/${PATIENT_UID}/documents/d1`).get());
  });
});

// ═══════════════════════════════════════════════════════════════════
// 3. FEATURE WRITE — allowed features (readWrite only)
// ═══════════════════════════════════════════════════════════════════

describe("Staff feature writes – allowed (readWrite)", () => {

  it("staff can create appointment (permission: readWrite)", async () => {
    const db = staffDb();
    await assertSucceeds(
      db.doc(`patients/${PATIENT_UID}/appointments/a_new`).set({
        ownerId: PATIENT_UID,
        createdAt: new Date(),
        updatedAt: new Date(),
        title: "Neuer Termin",
      })
    );
  });

  it("staff can update wound (permission: readWrite)", async () => {
    const db = staffDb();
    await assertSucceeds(
      db.doc(`patients/${PATIENT_UID}/wounds/w1`).update({
        updatedAt: new Date(),
        severity: 2,
      })
    );
  });

  it("staff can delete wound (permission: readWrite)", async () => {
    const db = staffDb();
    await assertSucceeds(
      db.doc(`patients/${PATIENT_UID}/wounds/w1`).delete()
    );
  });
});

// ═══════════════════════════════════════════════════════════════════
// 4. FEATURE WRITE — denied (read-only or none)
// ═══════════════════════════════════════════════════════════════════

describe("Staff feature writes – denied", () => {

  it("staff CANNOT write timeline (permission: read only)", async () => {
    const db = staffDb();
    await assertFails(
      db.doc(`patients/${PATIENT_UID}/timeline/new1`).set({
        ownerId: PATIENT_UID,
        createdAt: new Date(),
        updatedAt: new Date(),
        title: "Test",
      })
    );
  });

  it("staff CANNOT write pain (permission: read only)", async () => {
    const db = staffDb();
    await assertFails(
      db.doc(`patients/${PATIENT_UID}/pain/new1`).set({
        ownerId: PATIENT_UID,
        createdAt: new Date(),
        updatedAt: new Date(),
        occurredAt: new Date(),
        level: 3,
      })
    );
  });

  it("staff CANNOT write vitals (permission: none)", async () => {
    const db = staffDb();
    await assertFails(
      db.doc(`patients/${PATIENT_UID}/vitals/new1`).set({
        ownerId: PATIENT_UID,
        createdAt: new Date(),
        updatedAt: new Date(),
        heartRate: 80,
      })
    );
  });

  it("staff CANNOT write documents (permission: none)", async () => {
    const db = staffDb();
    await assertFails(
      db.doc(`patients/${PATIENT_UID}/documents/new1`).set({
        ownerId: PATIENT_UID,
        createdAt: new Date(),
        updatedAt: new Date(),
        name: "Test.pdf",
      })
    );
  });

  it("staff CANNOT write red_flags (permission: read only)", async () => {
    const db = staffDb();
    await assertFails(
      db.doc(`patients/${PATIENT_UID}/red_flags/new1`).set({
        ownerId: PATIENT_UID,
        createdAt: new Date(),
        updatedAt: new Date(),
        type: "pain",
      })
    );
  });
});

// ═══════════════════════════════════════════════════════════════════
// 5. UNLINKED PATIENT — staff cannot access patients without doctor link
// ═══════════════════════════════════════════════════════════════════

describe("Staff access – unlinked patient", () => {

  it("staff CANNOT read any feature of unlinked patient", async () => {
    const db = staffDb();
    // Patient2 has no doctor link → staff should fail on every feature
    await assertFails(db.doc(`patients/${PATIENT2_UID}/appointments/a1`).get());
  });

  it("staff CANNOT write to unlinked patient", async () => {
    const db = staffDb();
    await assertFails(
      db.doc(`patients/${PATIENT2_UID}/timeline/new1`).set({
        ownerId: PATIENT2_UID,
        createdAt: new Date(),
        updatedAt: new Date(),
        title: "Should fail",
      })
    );
  });
});

// ═══════════════════════════════════════════════════════════════════
// 6. PATIENT ROOT — staff can read patient root via binary check
// ═══════════════════════════════════════════════════════════════════

describe("Staff access – patient root doc", () => {

  it("staff can read linked patient root doc", async () => {
    const db = staffDb();
    await assertSucceeds(db.doc(`patients/${PATIENT_UID}`).get());
  });

  it("staff CANNOT read unlinked patient root doc", async () => {
    const db = staffDb();
    await assertFails(db.doc(`patients/${PATIENT2_UID}`).get());
  });
});

// ═══════════════════════════════════════════════════════════════════
// 7. LINK DOCS — staff can read doctor's link docs (patient list)
// ═══════════════════════════════════════════════════════════════════

describe("Staff access – link documents", () => {

  it("staff can read direct-path link doc for their doctor", async () => {
    const db = staffDb();
    await assertSucceeds(
      db.doc(`patients/${PATIENT_UID}/links/${DOCTOR_UID}_doctor`).get()
    );
  });

  it("staff CANNOT read link doc for unlinked patient", async () => {
    const db = staffDb();
    // Patient2 has no link → doc does not exist, but even if it did,
    // linkedUid would not match staffOfDoctor.
    await assertFails(
      db.doc(`patients/${PATIENT2_UID}/links/${DOCTOR_UID}_doctor`).get()
    );
  });

  it("staff can query collectionGroup links for their doctor", async () => {
    const db = staffDb();
    await assertSucceeds(
      db.collectionGroup("links")
        .where("linkedUid", "==", DOCTOR_UID)
        .where("status", "==", "active")
        .where("linkType", "==", "doctor")
        .get()
    );
  });

  it("staff CANNOT query collectionGroup links for another doctor", async () => {
    const db = staffDb();
    await assertFails(
      db.collectionGroup("links")
        .where("linkedUid", "==", "otherDoctor999")
        .get()
    );
  });
});

// ═══════════════════════════════════════════════════════════════════
// 8. USER DOCS — staff can read patient profile (user doc)
// ═══════════════════════════════════════════════════════════════════

describe("Staff access – patient user docs", () => {

  it("staff can read user doc of linked patient", async () => {
    const db = staffDb();
    await assertSucceeds(db.doc(`users/${PATIENT_UID}`).get());
  });

  it("staff can read their doctor's user doc", async () => {
    const db = staffDb();
    await assertSucceeds(db.doc(`users/${DOCTOR_UID}`).get());
  });

  it("staff CANNOT read user doc of unlinked patient", async () => {
    const db = staffDb();
    await assertFails(db.doc(`users/${PATIENT2_UID}`).get());
  });

  it("staff CANNOT read user doc of random user", async () => {
    const db = staffDb();
    await assertFails(db.doc(`users/${OTHER_UID}`).get());
  });
});
