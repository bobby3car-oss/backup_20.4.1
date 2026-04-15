/**
 * Firestore Security Rules – Staff Aftercare Plan Tests
 * ===========================================================
 *
 * Tests that a staff member can:
 *   1. Read user docs (own, doctor's, patient's)
 *   2. Read patient doc
 *   3. Read patient_aftercare_plans
 *   4. Create patient_aftercare_plans
 *   5. Update patient_aftercare_plans (archive)
 *   6. Query patient_aftercare_plans
 *
 * Run with:
 *   cd tests/rules
 *   npm run test:aftercare:emulator
 */

const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");
const { readFileSync } = require("fs");
const { resolve } = require("path");

const PROJECT_ID = "operationsbegleiter-860e7";
const RULES_PATH = resolve(__dirname, "../../firestore.rules");
const RULES = readFileSync(RULES_PATH, "utf8");

// Test users
const DOCTOR_UID = "doctor001";
const STAFF_UID = "staff001";
const ORG_UID = "org001";
const ORG_STAFF_UID = "orgstaff001";
const PATIENT_UID = "patient001";
const PATIENT2_UID = "patient002"; // not linked to doctor
const PLAN_ID = "plan001";
const ORG_PLAN_ID = "orgplan001";

let testEnv;

async function seedData(env) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();

    // Organisation user doc
    await db.doc(`users/${ORG_UID}`).set({
      role: "organisation",
      displayName: "Test Org",
      email: "org@test.com",
      orgVerified: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // Doctor user doc (member of org)
    await db.doc(`users/${DOCTOR_UID}`).set({
      role: "doctor",
      displayName: "Dr. Test",
      email: "doctor@test.com",
      orgId: ORG_UID,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // Direct staff user doc (staffOf → doctor)
    await db.doc(`users/${STAFF_UID}`).set({
      role: "staff",
      staffOf: DOCTOR_UID,
      displayName: "Staff One",
      email: "staff@test.com",
      staffPermissions: {
        appointments: "readWrite",
        timeline: "read",
        templates: "readWrite",
      },
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // Org-staff user doc (staffOf → organisation)
    await db.doc(`users/${ORG_STAFF_UID}`).set({
      role: "staff",
      staffOf: ORG_UID,
      displayName: "Org Staff One",
      email: "orgstaff@test.com",
      staffPermissions: {
        appointments: "readWrite",
        templates: "readWrite",
      },
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // Patient user doc
    await db.doc(`users/${PATIENT_UID}`).set({
      role: "patient",
      displayName: "Patient One",
      email: "patient1@test.com",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // Another patient (not linked)
    await db.doc(`users/${PATIENT2_UID}`).set({
      role: "patient",
      displayName: "Patient Two",
      email: "patient2@test.com",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // Patient root documents
    await db.doc(`patients/${PATIENT_UID}`).set({
      profile: { opDate: "2026-03-15" },
      createdAt: new Date(),
    });
    await db.doc(`patients/${PATIENT2_UID}`).set({
      profile: { opDate: "2026-04-01" },
      createdAt: new Date(),
    });

    // Active doctor link for PATIENT_UID → DOCTOR_UID
    // (legacy per-doctor link, NOT using org UID)
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

    // Existing aftercare plan (created by direct doctor)
    await db.doc(`patient_aftercare_plans/${PLAN_ID}`).set({
      patientId: PATIENT_UID,
      doctorId: DOCTOR_UID,
      organizationId: ORG_UID,
      title: "Existing Plan",
      status: "active",
      surgeryDate: new Date(),
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // Existing aftercare plan (created by org-staff, using org UID as doctorId)
    await db.doc(`patient_aftercare_plans/${ORG_PLAN_ID}`).set({
      patientId: PATIENT_UID,
      doctorId: ORG_UID,
      organizationId: ORG_UID,
      title: "Org Plan",
      status: "active",
      surgeryDate: new Date(),
      createdAt: new Date(),
      updatedAt: new Date(),
    });
  });
}

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

function staffDb() {
  return testEnv.authenticatedContext(STAFF_UID).firestore();
}

function orgStaffDb() {
  return testEnv.authenticatedContext(ORG_STAFF_UID).firestore();
}

function doctorDb() {
  return testEnv.authenticatedContext(DOCTOR_UID).firestore();
}

// ═══════════════════════════════════════════════════════════════════
// 1. USER DOC READS
// ═══════════════════════════════════════════════════════════════════

describe("Staff user doc reads", () => {
  it("staff can read own user doc", async () => {
    const db = staffDb();
    await assertSucceeds(db.doc(`users/${STAFF_UID}`).get());
  });

  it("staff can read doctor's user doc (via staffOf == userId)", async () => {
    const db = staffDb();
    await assertSucceeds(db.doc(`users/${DOCTOR_UID}`).get());
  });

  it("staff can read linked patient's user doc (via linkedReadAllowed)", async () => {
    const db = staffDb();
    await assertSucceeds(db.doc(`users/${PATIENT_UID}`).get());
  });

  it("staff CANNOT read unlinked patient's user doc", async () => {
    const db = staffDb();
    await assertFails(db.doc(`users/${PATIENT2_UID}`).get());
  });
});

// ═══════════════════════════════════════════════════════════════════
// 2. PATIENT DOC READS
// ═══════════════════════════════════════════════════════════════════

describe("Staff patient doc reads", () => {
  it("staff can read linked patient doc", async () => {
    const db = staffDb();
    await assertSucceeds(db.doc(`patients/${PATIENT_UID}`).get());
  });

  it("staff CANNOT read unlinked patient doc", async () => {
    const db = staffDb();
    await assertFails(db.doc(`patients/${PATIENT2_UID}`).get());
  });
});

// ═══════════════════════════════════════════════════════════════════
// 3. PATIENT AFTERCARE PLAN READS
// ═══════════════════════════════════════════════════════════════════

describe("Staff aftercare plan reads", () => {
  it("staff can read individual plan (get)", async () => {
    const db = staffDb();
    await assertSucceeds(
      db.doc(`patient_aftercare_plans/${PLAN_ID}`).get()
    );
  });

  it("staff can query plans by patientId + doctorId", async () => {
    const db = staffDb();
    await assertSucceeds(
      db.collection("patient_aftercare_plans")
        .where("patientId", "==", PATIENT_UID)
        .where("doctorId", "==", DOCTOR_UID)
        .where("status", "in", ["active", "paused"])
        .limit(2)
        .get()
    );
  });

  it("staff can query all plans by patientId", async () => {
    const db = staffDb();
    await assertSucceeds(
      db.collection("patient_aftercare_plans")
        .where("patientId", "==", PATIENT_UID)
        .get()
    );
  });
});

// ═══════════════════════════════════════════════════════════════════
// 4. PATIENT AFTERCARE PLAN CREATES
// ═══════════════════════════════════════════════════════════════════

describe("Staff aftercare plan creates", () => {
  it("staff can create plan with doctorId == staffOf", async () => {
    const db = staffDb();
    await assertSucceeds(
      db.collection("patient_aftercare_plans").doc("newPlan001").set({
        patientId: PATIENT_UID,
        doctorId: DOCTOR_UID,
        organizationId: "org001",
        title: "New Plan",
        status: "active",
        surgeryDate: new Date(),
        createdAt: new Date(),
        updatedAt: new Date(),
      })
    );
  });

  it("staff CANNOT create plan with wrong doctorId", async () => {
    const db = staffDb();
    await assertFails(
      db.collection("patient_aftercare_plans").doc("newPlan002").set({
        patientId: PATIENT_UID,
        doctorId: "wrongDoctor",
        organizationId: "org001",
        title: "Bad Plan",
        status: "active",
        surgeryDate: new Date(),
        createdAt: new Date(),
        updatedAt: new Date(),
      })
    );
  });
});

// ═══════════════════════════════════════════════════════════════════
// 5. PATIENT AFTERCARE PLAN UPDATES (archive)
// ═══════════════════════════════════════════════════════════════════

describe("Staff aftercare plan updates", () => {
  it("staff can update (archive) existing plan", async () => {
    const db = staffDb();
    await assertSucceeds(
      db.doc(`patient_aftercare_plans/${PLAN_ID}`).update({
        status: "archived",
        archivedReason: "New plan assigned",
        updatedAt: new Date(),
      })
    );
  });
});

// ═══════════════════════════════════════════════════════════════════
// 6. DOCTOR COMPARISON (control group)
// ═══════════════════════════════════════════════════════════════════

describe("Doctor aftercare plan operations (control)", () => {
  it("doctor can create plan", async () => {
    const db = doctorDb();
    await assertSucceeds(
      db.collection("patient_aftercare_plans").doc("doctorPlan001").set({
        patientId: PATIENT_UID,
        doctorId: DOCTOR_UID,
        organizationId: "org001",
        title: "Doctor Plan",
        status: "active",
        surgeryDate: new Date(),
        createdAt: new Date(),
        updatedAt: new Date(),
      })
    );
  });

  it("doctor can read plan", async () => {
    const db = doctorDb();
    await assertSucceeds(
      db.doc(`patient_aftercare_plans/${PLAN_ID}`).get()
    );
  });
});

// ═══════════════════════════════════════════════════════════════════
// 7. ORG-STAFF SCENARIOS (staffOf → organisation UID)
// ═══════════════════════════════════════════════════════════════════

describe("Org-staff aftercare plan operations", () => {
  it("org-staff can create plan with doctorId == orgUid (staffOf)", async () => {
    const db = orgStaffDb();
    await assertSucceeds(
      db.collection("patient_aftercare_plans").doc("orgNewPlan001").set({
        patientId: PATIENT_UID,
        doctorId: ORG_UID,
        organizationId: ORG_UID,
        title: "Org Staff Plan",
        status: "active",
        surgeryDate: new Date(),
        createdAt: new Date(),
        updatedAt: new Date(),
      })
    );
  });

  it("org-staff can read plan where doctorId == orgUid (via staffOf check)", async () => {
    const db = orgStaffDb();
    await assertSucceeds(
      db.doc(`patient_aftercare_plans/${ORG_PLAN_ID}`).get()
    );
  });

  it("org-staff can update plan where doctorId == orgUid", async () => {
    const db = orgStaffDb();
    await assertSucceeds(
      db.doc(`patient_aftercare_plans/${ORG_PLAN_ID}`).update({
        status: "archived",
        archivedReason: "Replaced",
        updatedAt: new Date(),
      })
    );
  });

  it("org-staff can query plans by patientId + doctorId (orgUid)", async () => {
    const db = orgStaffDb();
    await assertSucceeds(
      db.collection("patient_aftercare_plans")
        .where("patientId", "==", PATIENT_UID)
        .where("doctorId", "==", ORG_UID)
        .get()
    );
  });

  it("org-staff CANNOT read plan from another doctor (doctorId != orgUid)", async () => {
    const db = orgStaffDb();
    // PLAN_ID has doctorId=DOCTOR_UID, org-staff's staffOf=ORG_UID
    await assertFails(
      db.doc(`patient_aftercare_plans/${PLAN_ID}`).get()
    );
  });
});
