const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require("@firebase/rules-unit-testing");
const { readFileSync } = require("fs");
const { resolve } = require("path");

const PROJECT_ID = "operationsbegleiter-860e7";
const RULES = readFileSync(resolve(__dirname, "../../firestore.rules"), "utf8");

const OWNER_UID = "bellaOwner001";
const OTHER_UID = "bellaOther002";

let testEnv;

async function seed(env) {
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await db.doc(`users/${OWNER_UID}`).set({
      role: "patient",
      createdAt: new Date(),
    });
    await db.doc(`users/${OTHER_UID}`).set({
      role: "patient",
      createdAt: new Date(),
    });
    await db.doc(`users/${OWNER_UID}/private/profile`).set({
      bellaConsent: {
        granted: true,
        version: 2,
        grantedAt: new Date().toISOString(),
      },
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

describe("users/{uid}/private/profile", () => {
  it("allows the owner to read and write private Bella consent metadata", async () => {
    const db = authedDb(OWNER_UID);
    await assertSucceeds(db.doc(`users/${OWNER_UID}/private/profile`).get());
    await assertSucceeds(
      db.doc(`users/${OWNER_UID}/private/profile`).set({
        bellaConsent: {
          granted: true,
          version: 2,
          grantedAt: new Date().toISOString(),
          updatedAt: new Date().toISOString(),
        },
      }, { merge: true }),
    );
  });

  it("denies other users from reading or writing another user's private profile", async () => {
    const db = authedDb(OTHER_UID);
    await assertFails(db.doc(`users/${OWNER_UID}/private/profile`).get());
    await assertFails(
      db.doc(`users/${OWNER_UID}/private/profile`).set({
        bellaConsent: { granted: false },
      }, { merge: true }),
    );
  });
});