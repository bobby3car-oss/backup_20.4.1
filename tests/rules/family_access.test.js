/**
 * Firestore Security Rules – Family Member Access Tests
 * ===========================================================
 *
 * Tests that a linked family member can:
 *   1. Query links via collectionGroup
 *   2. Read patient user documents
 *   3. Read patient root documents
 *
 * Run with:
 *   cd tests/rules
 *   npm run test:family:emulator
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
const PATIENT_UID = "patient001";
const FAMILY_UID = "family001";
const OTHER_UID = "other001";

let testEnv;

// ── Seed data ─────────────────────────────────────────────────────

async function seedData(env) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();

    // ── User documents ──
    await db.doc(`users/${PATIENT_UID}`).set({
      role: "patient",
      displayName: "Patient One",
      email: "patient1@test.com",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    await db.doc(`users/${FAMILY_UID}`).set({
      role: "patient",
      displayName: "Family Member",
      email: "family@test.com",
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

    // ── Active family link: FAMILY_UID linked to PATIENT_UID ──
    await db
      .doc(`patients/${PATIENT_UID}/links/${FAMILY_UID}_family`)
      .set({
        linkType: "family",
        linkedUid: FAMILY_UID,
        linkedName: "Family Member",
        linkedEmail: "family@test.com",
        status: "active",
        permissions: { read: true, write: false },
        visibility: {
          timeline: true,
          vitals: false,
          pain: false,
          wounds: false,
          appointments: false,
          medications: false,
          documents: false,
          redFlags: false,
          observations: true,
        },
        createdAt: new Date(),
        createdBy: PATIENT_UID,
        role: "partner",
      });

    // ── Timeline entry for feature access test ──
    await db.doc(`patients/${PATIENT_UID}/timeline/entry1`).set({
      ownerId: PATIENT_UID,
      type: "note",
      createdAt: new Date(),
      updatedAt: new Date(),
      title: "Test entry",
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

function familyDb() {
  return testEnv.authenticatedContext(FAMILY_UID).firestore();
}

function otherDb() {
  return testEnv.authenticatedContext(OTHER_UID).firestore();
}

// ═══════════════════════════════════════════════════════════════════
// 1. LINKS – direct read & collectionGroup query
// ═══════════════════════════════════════════════════════════════════

describe("Family links – direct read", () => {
  it("family member can GET their own link document directly", async () => {
    const db = familyDb();
    const ref = db.doc(
      `patients/${PATIENT_UID}/links/${FAMILY_UID}_family`
    );
    const snap = await assertSucceeds(ref.get());
    expect(snap.exists).to.equal(true);
    expect(snap.data().linkedUid).to.equal(FAMILY_UID);
  });
});

describe("Family links – collectionGroup queries", () => {
  it("family member can query links collectionGroup filtered by linkedUid", async () => {
    const db = familyDb();
    const query = db
      .collectionGroup("links")
      .where("linkedUid", "==", FAMILY_UID)
      .where("status", "==", "active")
      .where("linkType", "==", "family");
    const snap = await assertSucceeds(query.get());
    expect(snap.docs.length).to.equal(1);
    expect(snap.docs[0].data().linkedUid).to.equal(FAMILY_UID);
  });

  it("family member can query links with only linkedUid filter", async () => {
    const db = familyDb();
    const query = db
      .collectionGroup("links")
      .where("linkedUid", "==", FAMILY_UID);
    const snap = await assertSucceeds(query.get());
    expect(snap.docs.length).to.equal(1);
  });

  it("other user CANNOT query links collectionGroup for family's links", async () => {
    const db = otherDb();
    const query = db
      .collectionGroup("links")
      .where("linkedUid", "==", FAMILY_UID)
      .where("status", "==", "active")
      .where("linkType", "==", "family");
    await assertFails(query.get());
  });
});

// ═══════════════════════════════════════════════════════════════════
// 2. USER DOCUMENTS – family reads patient's user doc
// ═══════════════════════════════════════════════════════════════════

describe("Family reading user documents", () => {
  it("family member can read linked patient's user doc", async () => {
    const db = familyDb();
    const snap = await assertSucceeds(
      db.doc(`users/${PATIENT_UID}`).get()
    );
    expect(snap.exists).to.equal(true);
    expect(snap.data().displayName).to.equal("Patient One");
  });

  it("family member can read their own user doc", async () => {
    const db = familyDb();
    await assertSucceeds(db.doc(`users/${FAMILY_UID}`).get());
  });
});

// ═══════════════════════════════════════════════════════════════════
// 3. PATIENT ROOT – family reads patient root document
// ═══════════════════════════════════════════════════════════════════

describe("Family reading patient root document", () => {
  it("family member can read linked patient's root document", async () => {
    const db = familyDb();
    const snap = await assertSucceeds(
      db.doc(`patients/${PATIENT_UID}`).get()
    );
    expect(snap.exists).to.equal(true);
  });
});

// ═══════════════════════════════════════════════════════════════════
// 4. FEATURE SUBCOLLECTIONS – family reads patient features
// ═══════════════════════════════════════════════════════════════════

describe("Family reading patient feature subcollections", () => {
  it("family member can read timeline (visibility=true)", async () => {
    const db = familyDb();
    await assertSucceeds(
      db.doc(`patients/${PATIENT_UID}/timeline/entry1`).get()
    );
  });
});
