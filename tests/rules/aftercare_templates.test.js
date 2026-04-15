/**
 * Firestore Security Rules – Aftercare Template Tests
 * ===========================================================
 *
 * Tests that:
 *   1. Admin can CRUD system_aftercare_templates
 *   2. Org user can CRUD organization_aftercare_templates
 *   3. Doctor can CRUD doctor_aftercare_templates
 *   4. Doctor can READ system_aftercare_templates
 *   5. Org can READ system_aftercare_templates
 *   6. Org member (doctor with orgId) can READ org templates
 *   7. Staff CANNOT read/write templates (enforced at app level,
 *      but rules still allow for staff via staffOf)
 *   8. Unauthenticated users cannot access any templates
 *
 * Run with:
 *   cd tests/rules
 *   npm run test:templates:emulator
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
const ADMIN_UID = "admin001";
const DOCTOR_UID = "doctor001";
const DOCTOR2_UID = "doctor002"; // not in org
const ORG_UID = "org001";
const STAFF_UID = "staff001";
const PATIENT_UID = "patient001";

// Template IDs
const SYS_TEMPLATE_ID = "systpl001";
const ORG_TEMPLATE_ID = "orgtpl001";
const DOC_TEMPLATE_ID = "doctpl001";

let testEnv;

async function seedData(env) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();

    // Admin user doc
    await db.doc(`users/${ADMIN_UID}`).set({
      role: "admin",
      displayName: "Admin",
      email: "admin@test.com",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

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

    // Doctor2 user doc (NOT in any org)
    await db.doc(`users/${DOCTOR2_UID}`).set({
      role: "doctor",
      displayName: "Dr. Solo",
      email: "doctor2@test.com",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // Staff user doc (staffOf → doctor)
    await db.doc(`users/${STAFF_UID}`).set({
      role: "staff",
      staffOf: DOCTOR_UID,
      displayName: "Staff One",
      email: "staff@test.com",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // Patient user doc
    await db.doc(`users/${PATIENT_UID}`).set({
      role: "patient",
      displayName: "Patient One",
      email: "patient@test.com",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // ── Seed template data ──────────────────────────────────────

    // System template
    await db.doc(`system_aftercare_templates/${SYS_TEMPLATE_ID}`).set({
      title: "Knie-TEP Standard",
      description: "System-wide knee replacement template",
      surgeryType: "Knie-TEP",
      bodyRegion: "Knie",
      createdBy: ADMIN_UID,
      templateType: "system",
      version: 1,
      createdAt: new Date(),
      updatedAt: new Date(),
      phases: [],
    });

    // Organisation template
    await db
      .doc(`organization_aftercare_templates/${ORG_TEMPLATE_ID}`)
      .set({
        title: "Org Hüft-TEP",
        description: "Org-level hip replacement template",
        surgeryType: "Hüft-TEP",
        bodyRegion: "Hüfte",
        organizationId: ORG_UID,
        createdBy: ORG_UID,
        templateType: "organization",
        version: 1,
        createdAt: new Date(),
        updatedAt: new Date(),
        phases: [],
      });

    // Doctor template
    await db.doc(`doctor_aftercare_templates/${DOC_TEMPLATE_ID}`).set({
      title: "Dr. Test Schulter",
      description: "Doctor-specific shoulder template",
      surgeryType: "Schulter-OP",
      bodyRegion: "Schulter",
      createdBy: DOCTOR_UID,
      templateType: "doctor",
      version: 1,
      createdAt: new Date(),
      updatedAt: new Date(),
      phases: [],
    });
  });
}

describe("Aftercare Template Rules", function () {
  this.timeout(30000);

  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: { rules: RULES },
    });
    await seedData(testEnv);
  });

  afterEach(async () => {
    // Do NOT clearFirestore — we need the seed data across tests
  });

  after(async () => {
    await testEnv.cleanup();
  });

  // ═══════════════════════════════════════════════════════════════
  // 1. System Templates
  // ═══════════════════════════════════════════════════════════════

  describe("system_aftercare_templates", () => {
    it("admin can read system templates", async () => {
      const db = testEnv
        .authenticatedContext(ADMIN_UID, { admin: true })
        .firestore();
      await assertSucceeds(
        db.doc(`system_aftercare_templates/${SYS_TEMPLATE_ID}`).get()
      );
    });

    it("admin can create system templates", async () => {
      const db = testEnv
        .authenticatedContext(ADMIN_UID, { admin: true })
        .firestore();
      await assertSucceeds(
        db.doc("system_aftercare_templates/new001").set({
          title: "New System Template",
          createdBy: ADMIN_UID,
          templateType: "system",
          version: 1,
          createdAt: new Date(),
          updatedAt: new Date(),
          phases: [],
        })
      );
    });

    it("admin can update system templates", async () => {
      const db = testEnv
        .authenticatedContext(ADMIN_UID, { admin: true })
        .firestore();
      await assertSucceeds(
        db
          .doc(`system_aftercare_templates/${SYS_TEMPLATE_ID}`)
          .update({ title: "Updated Title" })
      );
    });

    it("admin can delete system templates", async () => {
      const db = testEnv
        .authenticatedContext(ADMIN_UID, { admin: true })
        .firestore();
      // Create one to delete
      await db.doc("system_aftercare_templates/todelete").set({
        title: "Delete Me",
        createdBy: ADMIN_UID,
        templateType: "system",
        version: 1,
        createdAt: new Date(),
        updatedAt: new Date(),
        phases: [],
      });
      await assertSucceeds(
        db.doc("system_aftercare_templates/todelete").delete()
      );
    });

    it("doctor can read system templates", async () => {
      const db = testEnv.authenticatedContext(DOCTOR_UID).firestore();
      await assertSucceeds(
        db.doc(`system_aftercare_templates/${SYS_TEMPLATE_ID}`).get()
      );
    });

    it("org can read system templates", async () => {
      const db = testEnv.authenticatedContext(ORG_UID).firestore();
      await assertSucceeds(
        db.doc(`system_aftercare_templates/${SYS_TEMPLATE_ID}`).get()
      );
    });

    it("doctor CANNOT write system templates", async () => {
      const db = testEnv.authenticatedContext(DOCTOR_UID).firestore();
      await assertFails(
        db.doc("system_aftercare_templates/hack").set({
          title: "Hacked",
          createdBy: DOCTOR_UID,
          templateType: "system",
          version: 1,
          createdAt: new Date(),
          updatedAt: new Date(),
          phases: [],
        })
      );
    });

    it("unauthenticated CANNOT read system templates", async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(
        db.doc(`system_aftercare_templates/${SYS_TEMPLATE_ID}`).get()
      );
    });

    it("doctor can query (list) system templates", async () => {
      const db = testEnv.authenticatedContext(DOCTOR_UID).firestore();
      await assertSucceeds(
        db
          .collection("system_aftercare_templates")
          .orderBy("updatedAt", "desc")
          .get()
      );
    });

    it("org can query (list) system templates", async () => {
      const db = testEnv.authenticatedContext(ORG_UID).firestore();
      await assertSucceeds(
        db
          .collection("system_aftercare_templates")
          .orderBy("updatedAt", "desc")
          .get()
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 2. Organisation Templates
  // ═══════════════════════════════════════════════════════════════

  describe("organization_aftercare_templates", () => {
    it("org owner can read own org templates", async () => {
      const db = testEnv.authenticatedContext(ORG_UID).firestore();
      await assertSucceeds(
        db
          .doc(`organization_aftercare_templates/${ORG_TEMPLATE_ID}`)
          .get()
      );
    });

    it("org owner can create org templates", async () => {
      const db = testEnv.authenticatedContext(ORG_UID).firestore();
      await assertSucceeds(
        db.doc("organization_aftercare_templates/orgnew001").set({
          title: "New Org Template",
          organizationId: ORG_UID,
          createdBy: ORG_UID,
          templateType: "organization",
          version: 1,
          createdAt: new Date(),
          updatedAt: new Date(),
          phases: [],
        })
      );
    });

    it("org owner can update org templates", async () => {
      const db = testEnv.authenticatedContext(ORG_UID).firestore();
      await assertSucceeds(
        db
          .doc(`organization_aftercare_templates/${ORG_TEMPLATE_ID}`)
          .update({ title: "Updated Org Title" })
      );
    });

    it("org owner can delete org templates", async () => {
      const db = testEnv.authenticatedContext(ORG_UID).firestore();
      await db.doc("organization_aftercare_templates/orgdel001").set({
        title: "Delete Me",
        organizationId: ORG_UID,
        createdBy: ORG_UID,
        templateType: "organization",
        version: 1,
        createdAt: new Date(),
        updatedAt: new Date(),
        phases: [],
      });
      await assertSucceeds(
        db.doc("organization_aftercare_templates/orgdel001").delete()
      );
    });

    it("org member doctor can read org templates", async () => {
      const db = testEnv.authenticatedContext(DOCTOR_UID).firestore();
      await assertSucceeds(
        db
          .doc(`organization_aftercare_templates/${ORG_TEMPLATE_ID}`)
          .get()
      );
    });

    it("org member doctor can query org templates", async () => {
      const db = testEnv.authenticatedContext(DOCTOR_UID).firestore();
      await assertSucceeds(
        db
          .collection("organization_aftercare_templates")
          .where("organizationId", "==", ORG_UID)
          .orderBy("updatedAt", "desc")
          .get()
      );
    });

    it("non-member doctor CANNOT read org templates", async () => {
      const db = testEnv.authenticatedContext(DOCTOR2_UID).firestore();
      await assertFails(
        db
          .doc(`organization_aftercare_templates/${ORG_TEMPLATE_ID}`)
          .get()
      );
    });

    it("org owner can query own org templates", async () => {
      const db = testEnv.authenticatedContext(ORG_UID).firestore();
      await assertSucceeds(
        db
          .collection("organization_aftercare_templates")
          .where("organizationId", "==", ORG_UID)
          .orderBy("updatedAt", "desc")
          .get()
      );
    });

    it("patient CANNOT read org templates", async () => {
      const db = testEnv.authenticatedContext(PATIENT_UID).firestore();
      await assertFails(
        db
          .doc(`organization_aftercare_templates/${ORG_TEMPLATE_ID}`)
          .get()
      );
    });

    it("unauthenticated CANNOT read org templates", async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(
        db
          .doc(`organization_aftercare_templates/${ORG_TEMPLATE_ID}`)
          .get()
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 3. Doctor Templates
  // ═══════════════════════════════════════════════════════════════

  describe("doctor_aftercare_templates", () => {
    it("doctor can read own templates", async () => {
      const db = testEnv.authenticatedContext(DOCTOR_UID).firestore();
      await assertSucceeds(
        db.doc(`doctor_aftercare_templates/${DOC_TEMPLATE_ID}`).get()
      );
    });

    it("doctor can create own templates", async () => {
      const db = testEnv.authenticatedContext(DOCTOR_UID).firestore();
      await assertSucceeds(
        db.doc("doctor_aftercare_templates/docnew001").set({
          title: "New Doctor Template",
          createdBy: DOCTOR_UID,
          templateType: "doctor",
          version: 1,
          createdAt: new Date(),
          updatedAt: new Date(),
          phases: [],
        })
      );
    });

    it("doctor can update own templates", async () => {
      const db = testEnv.authenticatedContext(DOCTOR_UID).firestore();
      await assertSucceeds(
        db
          .doc(`doctor_aftercare_templates/${DOC_TEMPLATE_ID}`)
          .update({ title: "Updated Doctor Title" })
      );
    });

    it("doctor can delete own templates", async () => {
      const db = testEnv.authenticatedContext(DOCTOR_UID).firestore();
      await db.doc("doctor_aftercare_templates/docdel001").set({
        title: "Delete Me",
        createdBy: DOCTOR_UID,
        templateType: "doctor",
        version: 1,
        createdAt: new Date(),
        updatedAt: new Date(),
        phases: [],
      });
      await assertSucceeds(
        db.doc("doctor_aftercare_templates/docdel001").delete()
      );
    });

    it("doctor can query own templates", async () => {
      const db = testEnv.authenticatedContext(DOCTOR_UID).firestore();
      await assertSucceeds(
        db
          .collection("doctor_aftercare_templates")
          .where("createdBy", "==", DOCTOR_UID)
          .orderBy("updatedAt", "desc")
          .get()
      );
    });

    it("staff can read doctor's templates (via staffOf)", async () => {
      const db = testEnv.authenticatedContext(STAFF_UID).firestore();
      await assertSucceeds(
        db.doc(`doctor_aftercare_templates/${DOC_TEMPLATE_ID}`).get()
      );
    });

    it("other doctor CANNOT read another doctor's templates", async () => {
      const db = testEnv.authenticatedContext(DOCTOR2_UID).firestore();
      await assertFails(
        db.doc(`doctor_aftercare_templates/${DOC_TEMPLATE_ID}`).get()
      );
    });

    it("patient CANNOT read doctor templates", async () => {
      const db = testEnv.authenticatedContext(PATIENT_UID).firestore();
      await assertFails(
        db.doc(`doctor_aftercare_templates/${DOC_TEMPLATE_ID}`).get()
      );
    });

    it("unauthenticated CANNOT read doctor templates", async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(
        db.doc(`doctor_aftercare_templates/${DOC_TEMPLATE_ID}`).get()
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // 4. Adopt (clone) system → doctor/org
  // ═══════════════════════════════════════════════════════════════

  describe("adopt system template", () => {
    it("doctor can adopt system template to doctor scope", async () => {
      const db = testEnv.authenticatedContext(DOCTOR_UID).firestore();
      await assertSucceeds(
        db.doc("doctor_aftercare_templates/adopted001").set({
          title: "Adopted from System",
          createdBy: DOCTOR_UID,
          templateType: "doctor",
          version: 1,
          createdAt: new Date(),
          updatedAt: new Date(),
          phases: [],
        })
      );
    });

    it("org can adopt system template to org scope", async () => {
      const db = testEnv.authenticatedContext(ORG_UID).firestore();
      await assertSucceeds(
        db.doc("organization_aftercare_templates/adopted001").set({
          title: "Adopted from System",
          organizationId: ORG_UID,
          createdBy: ORG_UID,
          templateType: "organization",
          version: 1,
          createdAt: new Date(),
          updatedAt: new Date(),
          phases: [],
        })
      );
    });
  });
});
