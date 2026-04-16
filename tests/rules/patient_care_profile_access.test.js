const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");
const { readFileSync } = require("fs");
const { resolve } = require("path");

const PROJECT_ID = "operationsbegleiter-860e7";
const RULES = readFileSync(resolve(__dirname, "../../firestore.rules"), "utf8");

const PATIENT_UID = "carePatient001";
const DOCTOR_UID = "careDoctor001";
const FAMILY_UID = "careFamily001";
const OTHER_UID = "careOther001";

let testEnv;

async function seed(env) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await db.doc(`users/${PATIENT_UID}`).set({ role: "patient" });
    await db.doc(`users/${DOCTOR_UID}`).set({ role: "doctor" });
    await db.doc(`users/${FAMILY_UID}`).set({ role: "family" });
    await db.doc(`users/${OTHER_UID}`).set({ role: "patient" });

    await db.doc(`patients/${PATIENT_UID}`).set({
      ownerId: PATIENT_UID,
      createdAt: new Date(),
    });

    await db.doc(`patients/${PATIENT_UID}/links/${DOCTOR_UID}_doctor`).set({
      linkedUid: DOCTOR_UID,
      linkType: "doctor",
      status: "active",
      permissions: { read: true, write: false },
    });

    await db.doc(`patients/${PATIENT_UID}/links/${FAMILY_UID}_family`).set({
      linkedUid: FAMILY_UID,
      linkType: "family",
      status: "active",
      permissions: { read: true, write: false },
    });

    await db.doc(`patients/${PATIENT_UID}/care_profile/current`).set({
      displayName: "Max Mustermann",
      diagnosis: "Appendizitis",
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
  await seed(testEnv);
});

after(async () => {
  await testEnv.cleanup();
});

function authedDb(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

describe("patients/{patientId}/care_profile/current", () => {
  it("allows owner and linked care roles to read, but only owner/admin to write", async () => {
    const ownerDb = authedDb(PATIENT_UID);
    const doctorDb = authedDb(DOCTOR_UID);
    const familyDb = authedDb(FAMILY_UID);
    const otherDb = authedDb(OTHER_UID);

    await assertSucceeds(ownerDb.doc(`patients/${PATIENT_UID}/care_profile/current`).get());
    await assertSucceeds(
      ownerDb.doc(`patients/${PATIENT_UID}/care_profile/current`).set(
        {
          displayName: "Max Mustermann",
          diagnosis: "Appendizitis",
          updatedAt: new Date(),
        },
        { merge: true },
      ),
    );

    await assertSucceeds(doctorDb.doc(`patients/${PATIENT_UID}/care_profile/current`).get());
    await assertFails(
      doctorDb.doc(`patients/${PATIENT_UID}/care_profile/current`).set(
        { diagnosis: "Geaendert" },
        { merge: true },
      ),
    );

    await assertSucceeds(familyDb.doc(`patients/${PATIENT_UID}/care_profile/current`).get());
    await assertFails(
      familyDb.doc(`patients/${PATIENT_UID}/care_profile/current`).set(
        { diagnosis: "Geaendert" },
        { merge: true },
      ),
    );

    await assertFails(otherDb.doc(`patients/${PATIENT_UID}/care_profile/current`).get());
  });
});