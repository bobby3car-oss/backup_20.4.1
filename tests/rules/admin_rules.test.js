/**
 * Firestore Security Rules – Emulator Tests
 * ===========================================================
 *
 * Tests for the Admin Key System, Admin Stats, Admin Events,
 * Key Redemptions, and User document protections.
 *
 * Run with:
 *   cd tests/rules
 *   npm install
 *   npm run test:emulator
 *
 * Or (manual emulator):
 *   firebase emulators:start --only firestore --project operationsbegleiter-860e7
 *   npm test
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

// Read rules from project root.
const RULES_PATH = resolve(__dirname, "../../firestore.rules");
const RULES = readFileSync(RULES_PATH, "utf8");

// UIDs for test users.
const SUPER_ADMIN_UID = "superAdmin001";
const NORMAL_USER_UID = "normalUser001";
const OTHER_USER_UID  = "otherUser002";
const UNAUTHED        = null; // not signed in

// A deterministic "keyId" (in reality sha256 hash).
const KEY_ID_1 = "abc123keyid_pro";
const KEY_ID_2 = "abc456keyid_doctor";
const KEY_ID_EXPIRED = "expired_key_id";

let testEnv;

// ── Setup helpers ─────────────────────────────────────────────────

/**
 * Seed the emulator with baseline data using the admin context
 * (bypasses security rules).
 */
async function seedData(env) {
  const adminDb = env.authenticatedContext(SUPER_ADMIN_UID).firestore();

  // We need to use the unauthed admin-like context.
  // The rules-unit-testing v3 provides withSecurityRulesDisabled:
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();

    // ── SuperAdmin user doc ──
    await db.doc(`users/${SUPER_ADMIN_UID}`).set({
      role: "superAdmin",
      displayName: "Super Admin",
      email: "admin@test.com",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // ── Normal user doc ──
    await db.doc(`users/${NORMAL_USER_UID}`).set({
      role: "patient",
      displayName: "Normal User",
      email: "user@test.com",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // ── Other user doc ──
    await db.doc(`users/${OTHER_USER_UID}`).set({
      role: "patient",
      displayName: "Other User",
      email: "other@test.com",
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // ── Active PRO key ──
    await db.doc(`adminKeys/${KEY_ID_1}`).set({
      keyId: KEY_ID_1,
      type: "PRO",
      status: "active",
      createdAt: new Date(),
      createdByUid: SUPER_ADMIN_UID,
      label: "Test Key",
    });

    // ── Active DOCTOR key ──
    await db.doc(`adminKeys/${KEY_ID_2}`).set({
      keyId: KEY_ID_2,
      type: "DOCTOR",
      status: "active",
      createdAt: new Date(),
      createdByUid: SUPER_ADMIN_UID,
    });

    // ── Expired key ──
    const pastDate = new Date("2020-01-01T00:00:00Z");
    await db.doc(`adminKeys/${KEY_ID_EXPIRED}`).set({
      keyId: KEY_ID_EXPIRED,
      type: "PRO",
      status: "active",
      createdAt: new Date(),
      createdByUid: SUPER_ADMIN_UID,
      expiresAt: pastDate,
    });

    // ── Admin stats ──
    await db.doc("adminStats/global").set({
      totalUsers: 3,
      keysCreatedTotal: 3,
      keysUsedTotal: 0,
    });

    // ── Admin event ──
    await db.collection("adminEvents").doc("evt001").set({
      actorUid: SUPER_ADMIN_UID,
      action: "KEY_CREATED",
      createdAt: new Date(),
      metadata: { keyType: "PRO" },
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

// ── Helper: get Firestore for a given user ────────────────────────

function authedDb(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

function unauthedDb() {
  return testEnv.unauthenticatedContext().firestore();
}

function superAdminDb() {
  return authedDb(SUPER_ADMIN_UID);
}

function normalUserDb() {
  return authedDb(NORMAL_USER_UID);
}

function otherUserDb() {
  return authedDb(OTHER_USER_UID);
}

// ═══════════════════════════════════════════════════════════════════
// TEST SUITES
// ═══════════════════════════════════════════════════════════════════

// ── 1. adminKeys ──────────────────────────────────────────────────

describe("adminKeys", () => {

  // ── 1a. GET (single doc lookup) ──
  describe("GET (single doc)", () => {
    it("allows authenticated user to get a key by ID", async () => {
      const db = normalUserDb();
      await assertSucceeds(db.doc(`adminKeys/${KEY_ID_1}`).get());
    });

    it("denies unauthenticated user from getting a key", async () => {
      const db = unauthedDb();
      await assertFails(db.doc(`adminKeys/${KEY_ID_1}`).get());
    });

    it("allows superAdmin to get a key by ID", async () => {
      const db = superAdminDb();
      await assertSucceeds(db.doc(`adminKeys/${KEY_ID_1}`).get());
    });
  });

  // ── 1b. LIST / QUERY ──
  describe("LIST / QUERY (enumeration prevention)", () => {
    it("denies normal user from listing/querying adminKeys", async () => {
      const db = normalUserDb();
      await assertFails(db.collection("adminKeys").get());
    });

    it("denies normal user from querying adminKeys with filter", async () => {
      const db = normalUserDb();
      await assertFails(
        db.collection("adminKeys").where("status", "==", "active").get()
      );
    });

    it("allows superAdmin to list adminKeys", async () => {
      const db = superAdminDb();
      await assertSucceeds(db.collection("adminKeys").get());
    });

    it("allows superAdmin to query adminKeys by status", async () => {
      const db = superAdminDb();
      await assertSucceeds(
        db.collection("adminKeys").where("status", "==", "active").get()
      );
    });

    it("denies unauthenticated user from listing adminKeys", async () => {
      const db = unauthedDb();
      await assertFails(db.collection("adminKeys").get());
    });
  });

  // ── 1c. CREATE ──
  describe("CREATE", () => {
    it("allows superAdmin to create a key", async () => {
      const db = superAdminDb();
      await assertSucceeds(
        db.doc("adminKeys/newKey001").set({
          keyId: "newKey001",
          type: "PRO",
          status: "active",
          createdAt: new Date(),
          createdByUid: SUPER_ADMIN_UID,
        })
      );
    });

    it("denies normal user from creating a key", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc("adminKeys/newKey002").set({
          keyId: "newKey002",
          type: "PRO",
          status: "active",
          createdAt: new Date(),
          createdByUid: NORMAL_USER_UID,
        })
      );
    });

    it("denies unauthenticated from creating a key", async () => {
      const db = unauthedDb();
      await assertFails(
        db.doc("adminKeys/newKey003").set({
          keyId: "newKey003",
          type: "PRO",
          status: "active",
          createdAt: new Date(),
          createdByUid: "nobody",
        })
      );
    });
  });

  // ── 1d. DELETE ──
  describe("DELETE", () => {
    it("allows superAdmin to delete a key", async () => {
      const db = superAdminDb();
      await assertSucceeds(db.doc(`adminKeys/${KEY_ID_1}`).delete());
    });

    it("denies normal user from deleting a key", async () => {
      const db = normalUserDb();
      await assertFails(db.doc(`adminKeys/${KEY_ID_1}`).delete());
    });
  });

  // ── 1e. UPDATE – Redemption (active → used) ──
  describe("UPDATE – Key Redemption (active → used)", () => {
    it("allows normal user to mark key as used with correct fields", async () => {
      const db = normalUserDb();
      await assertSucceeds(
        db.doc(`adminKeys/${KEY_ID_1}`).update({
          status: "used",
          usedByUid: NORMAL_USER_UID,
          usedAt: new Date(),
        })
      );
    });

    it("denies normal user from marking key as used for ANOTHER user", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc(`adminKeys/${KEY_ID_1}`).update({
          status: "used",
          usedByUid: OTHER_USER_UID, // NOT the caller
          usedAt: new Date(),
        })
      );
    });

    it("denies normal user from setting status to anything other than 'used'", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc(`adminKeys/${KEY_ID_1}`).update({
          status: "revoked",
          usedByUid: NORMAL_USER_UID,
          usedAt: new Date(),
        })
      );
    });

    it("denies normal user from changing immutable field 'type'", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc(`adminKeys/${KEY_ID_1}`).update({
          status: "used",
          usedByUid: NORMAL_USER_UID,
          usedAt: new Date(),
          type: "DOCTOR", // was PRO – immutable!
        })
      );
    });

    it("denies normal user from changing immutable field 'keyId'", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc(`adminKeys/${KEY_ID_1}`).update({
          status: "used",
          usedByUid: NORMAL_USER_UID,
          usedAt: new Date(),
          keyId: "TAMPERED",
        })
      );
    });

    it("denies normal user from changing immutable field 'createdByUid'", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc(`adminKeys/${KEY_ID_1}`).update({
          status: "used",
          usedByUid: NORMAL_USER_UID,
          usedAt: new Date(),
          createdByUid: NORMAL_USER_UID,
        })
      );
    });

    it("denies normal user from redeeming an expired key", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc(`adminKeys/${KEY_ID_EXPIRED}`).update({
          status: "used",
          usedByUid: NORMAL_USER_UID,
          usedAt: new Date(),
        })
      );
    });

    it("denies normal user from marking already-used key as used again", async () => {
      // First: use the key via admin bypass.
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        await ctx.firestore().doc(`adminKeys/${KEY_ID_1}`).update({
          status: "used",
          usedByUid: OTHER_USER_UID,
          usedAt: new Date(),
        });
      });

      // Now try to "re-use" it.
      const db = normalUserDb();
      await assertFails(
        db.doc(`adminKeys/${KEY_ID_1}`).update({
          status: "used",
          usedByUid: NORMAL_USER_UID,
          usedAt: new Date(),
        })
      );
    });

    it("denies unauthenticated from redeeming a key", async () => {
      const db = unauthedDb();
      await assertFails(
        db.doc(`adminKeys/${KEY_ID_1}`).update({
          status: "used",
          usedByUid: "nobody",
          usedAt: new Date(),
        })
      );
    });

    it("denies normal user from omitting usedAt", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc(`adminKeys/${KEY_ID_1}`).update({
          status: "used",
          usedByUid: NORMAL_USER_UID,
          // missing usedAt
        })
      );
    });
  });

  // ── 1f. UPDATE – Revocation (superAdmin only) ──
  describe("UPDATE – Key Revocation", () => {
    it("allows superAdmin to revoke an active key", async () => {
      const db = superAdminDb();
      await assertSucceeds(
        db.doc(`adminKeys/${KEY_ID_1}`).update({
          status: "revoked",
        })
      );
    });

    it("denies normal user from revoking a key", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc(`adminKeys/${KEY_ID_1}`).update({
          status: "revoked",
        })
      );
    });
  });
});

// ── 2. adminStats ─────────────────────────────────────────────────

describe("adminStats", () => {
  describe("READ", () => {
    it("allows superAdmin to read stats", async () => {
      const db = superAdminDb();
      await assertSucceeds(db.doc("adminStats/global").get());
    });

    it("denies normal user from reading stats", async () => {
      const db = normalUserDb();
      await assertFails(db.doc("adminStats/global").get());
    });

    it("denies unauthenticated from reading stats", async () => {
      const db = unauthedDb();
      await assertFails(db.doc("adminStats/global").get());
    });
  });

  describe("WRITE", () => {
    it("allows superAdmin to write stats", async () => {
      const db = superAdminDb();
      await assertSucceeds(
        db.doc("adminStats/global").set(
          { totalUsers: 10 },
          { merge: true }
        )
      );
    });

    it("denies normal user from writing stats", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc("adminStats/global").set(
          { totalUsers: 999 },
          { merge: true }
        )
      );
    });
  });

  describe("LIST", () => {
    it("allows superAdmin to list stats docs", async () => {
      const db = superAdminDb();
      await assertSucceeds(db.collection("adminStats").get());
    });

    it("denies normal user from listing stats docs", async () => {
      const db = normalUserDb();
      await assertFails(db.collection("adminStats").get());
    });
  });
});

// ── 3. adminEvents ────────────────────────────────────────────────

describe("adminEvents", () => {
  describe("READ", () => {
    it("allows superAdmin to read events", async () => {
      const db = superAdminDb();
      await assertSucceeds(db.doc("adminEvents/evt001").get());
    });

    it("allows superAdmin to list events", async () => {
      const db = superAdminDb();
      await assertSucceeds(db.collection("adminEvents").get());
    });

    it("denies normal user from reading events", async () => {
      const db = normalUserDb();
      await assertFails(db.doc("adminEvents/evt001").get());
    });

    it("denies normal user from listing events", async () => {
      const db = normalUserDb();
      await assertFails(db.collection("adminEvents").get());
    });
  });

  describe("CREATE", () => {
    it("allows superAdmin to create events", async () => {
      const db = superAdminDb();
      await assertSucceeds(
        db.collection("adminEvents").add({
          actorUid: SUPER_ADMIN_UID,
          action: "KEY_CREATED",
          createdAt: new Date(),
        })
      );
    });

    it("allows normal user to create KEY_USED event for themselves", async () => {
      const db = normalUserDb();
      await assertSucceeds(
        db.collection("adminEvents").add({
          actorUid: NORMAL_USER_UID,
          action: "KEY_USED",
          createdAt: new Date(),
        })
      );
    });

    it("denies normal user from creating non-KEY_USED events", async () => {
      const db = normalUserDb();
      await assertFails(
        db.collection("adminEvents").add({
          actorUid: NORMAL_USER_UID,
          action: "KEY_CREATED",
          createdAt: new Date(),
        })
      );
    });

    it("denies normal user from creating event with wrong actorUid", async () => {
      const db = normalUserDb();
      await assertFails(
        db.collection("adminEvents").add({
          actorUid: OTHER_USER_UID, // not the caller
          action: "KEY_USED",
          createdAt: new Date(),
        })
      );
    });
  });

  describe("UPDATE / DELETE", () => {
    it("denies superAdmin from updating events", async () => {
      const db = superAdminDb();
      await assertFails(
        db.doc("adminEvents/evt001").update({ action: "TAMPERED" })
      );
    });

    it("denies superAdmin from deleting events", async () => {
      const db = superAdminDb();
      await assertFails(db.doc("adminEvents/evt001").delete());
    });
  });
});

// ── 4. keyRedemptions ─────────────────────────────────────────────

describe("keyRedemptions", () => {
  describe("CREATE", () => {
    it("allows normal user to create a pending redemption for themselves", async () => {
      const db = normalUserDb();
      await assertSucceeds(
        db.collection("keyRedemptions").add({
          uid: NORMAL_USER_UID,
          keyId: KEY_ID_1,
          type: "PRO",
          status: "pending",
        })
      );
    });

    it("denies normal user from creating a redemption for another user", async () => {
      const db = normalUserDb();
      await assertFails(
        db.collection("keyRedemptions").add({
          uid: OTHER_USER_UID,
          keyId: KEY_ID_1,
          type: "PRO",
          status: "pending",
        })
      );
    });

    it("denies normal user from creating a non-pending redemption", async () => {
      const db = normalUserDb();
      await assertFails(
        db.collection("keyRedemptions").add({
          uid: NORMAL_USER_UID,
          keyId: KEY_ID_1,
          type: "PRO",
          status: "completed",
        })
      );
    });

    it("denies creating a redemption with invalid type", async () => {
      const db = normalUserDb();
      await assertFails(
        db.collection("keyRedemptions").add({
          uid: NORMAL_USER_UID,
          keyId: KEY_ID_1,
          type: "INVALID",
          status: "pending",
        })
      );
    });

    it("denies unauthenticated from creating a redemption", async () => {
      const db = unauthedDb();
      await assertFails(
        db.collection("keyRedemptions").add({
          uid: "nobody",
          keyId: KEY_ID_1,
          type: "PRO",
          status: "pending",
        })
      );
    });
  });

  describe("READ", () => {
    it("allows user to read their own redemption", async () => {
      // Seed a redemption doc first.
      let redemptionId;
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        const ref = await ctx.firestore().collection("keyRedemptions").add({
          uid: NORMAL_USER_UID,
          keyId: KEY_ID_1,
          type: "PRO",
          status: "completed",
        });
        redemptionId = ref.id;
      });

      const db = normalUserDb();
      await assertSucceeds(db.doc(`keyRedemptions/${redemptionId}`).get());
    });

    it("denies user from reading another user's redemption", async () => {
      let redemptionId;
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        const ref = await ctx.firestore().collection("keyRedemptions").add({
          uid: OTHER_USER_UID,
          keyId: KEY_ID_1,
          type: "PRO",
          status: "completed",
        });
        redemptionId = ref.id;
      });

      const db = normalUserDb();
      await assertFails(db.doc(`keyRedemptions/${redemptionId}`).get());
    });
  });

  describe("UPDATE / DELETE", () => {
    it("denies user from updating their own redemption", async () => {
      let redemptionId;
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        const ref = await ctx.firestore().collection("keyRedemptions").add({
          uid: NORMAL_USER_UID,
          keyId: KEY_ID_1,
          type: "PRO",
          status: "pending",
        });
        redemptionId = ref.id;
      });

      const db = normalUserDb();
      await assertFails(
        db.doc(`keyRedemptions/${redemptionId}`).update({ status: "completed" })
      );
    });

    it("denies user from deleting their own redemption", async () => {
      let redemptionId;
      await testEnv.withSecurityRulesDisabled(async (ctx) => {
        const ref = await ctx.firestore().collection("keyRedemptions").add({
          uid: NORMAL_USER_UID,
          keyId: KEY_ID_1,
          type: "PRO",
          status: "pending",
        });
        redemptionId = ref.id;
      });

      const db = normalUserDb();
      await assertFails(db.doc(`keyRedemptions/${redemptionId}`).delete());
    });
  });
});

// ── 5. users – server-only field protection ───────────────────────

describe("users – server-only field protection", () => {
  describe("Normal user updating own doc", () => {
    it("allows updating displayName (safe field)", async () => {
      const db = normalUserDb();
      await assertSucceeds(
        db.doc(`users/${NORMAL_USER_UID}`).update({
          displayName: "Updated Name",
          updatedAt: new Date(),
        })
      );
    });

    it("allows updating lastSeenAt (safe field)", async () => {
      const db = normalUserDb();
      await assertSucceeds(
        db.doc(`users/${NORMAL_USER_UID}`).update({
          lastSeenAt: new Date(),
        })
      );
    });

    it("denies changing own role", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc(`users/${NORMAL_USER_UID}`).update({
          role: "superAdmin",
        })
      );
    });

    it("denies setting own isPro", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc(`users/${NORMAL_USER_UID}`).update({
          isPro: true,
        })
      );
    });

    it("denies setting own pro", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc(`users/${NORMAL_USER_UID}`).update({
          pro: true,
        })
      );
    });

    it("denies setting own doctorVerified", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc(`users/${NORMAL_USER_UID}`).update({
          doctorVerified: true,
        })
      );
    });

    it("denies setting proSource", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc(`users/${NORMAL_USER_UID}`).update({
          proSource: "key",
        })
      );
    });
  });

  describe("Normal user cannot update other user's doc", () => {
    it("denies updating another user's displayName", async () => {
      const db = normalUserDb();
      await assertFails(
        db.doc(`users/${OTHER_USER_UID}`).update({
          displayName: "Hacked",
        })
      );
    });
  });

  describe("SuperAdmin can update any user's server-only fields", () => {
    it("allows superAdmin to change another user's role", async () => {
      const db = superAdminDb();
      await assertSucceeds(
        db.doc(`users/${NORMAL_USER_UID}`).update({
          role: "doctor",
        })
      );
    });

    it("allows superAdmin to grant pro to another user", async () => {
      const db = superAdminDb();
      await assertSucceeds(
        db.doc(`users/${NORMAL_USER_UID}`).update({
          isPro: true,
          pro: true,
        })
      );
    });

    it("allows superAdmin to set doctorVerified", async () => {
      const db = superAdminDb();
      await assertSucceeds(
        db.doc(`users/${NORMAL_USER_UID}`).update({
          doctorVerified: true,
          role: "doctor",
        })
      );
    });

    it("allows superAdmin to revoke pro", async () => {
      const db = superAdminDb();
      await assertSucceeds(
        db.doc(`users/${NORMAL_USER_UID}`).update({
          isPro: false,
          pro: false,
        })
      );
    });
  });

  describe("SuperAdmin can read any user doc", () => {
    it("allows superAdmin to read another user", async () => {
      const db = superAdminDb();
      await assertSucceeds(db.doc(`users/${NORMAL_USER_UID}`).get());
    });

    it("allows superAdmin to read own doc", async () => {
      const db = superAdminDb();
      await assertSucceeds(db.doc(`users/${SUPER_ADMIN_UID}`).get());
    });
  });

  describe("User doc creation", () => {
    it("allows user to create own doc without server-only fields", async () => {
      const newUid = "brandNewUser";
      const db = authedDb(newUid);
      await assertSucceeds(
        db.doc(`users/${newUid}`).set({
          displayName: "New User",
          email: "new@test.com",
          createdAt: new Date(),
          updatedAt: new Date(),
        })
      );
    });

    it("denies user from creating own doc with role field", async () => {
      const newUid = "brandNewUser2";
      const db = authedDb(newUid);
      await assertFails(
        db.doc(`users/${newUid}`).set({
          displayName: "Evil",
          role: "superAdmin",
          createdAt: new Date(),
          updatedAt: new Date(),
        })
      );
    });

    it("denies user from creating own doc with isPro", async () => {
      const newUid = "brandNewUser3";
      const db = authedDb(newUid);
      await assertFails(
        db.doc(`users/${newUid}`).set({
          displayName: "Evil",
          isPro: true,
          createdAt: new Date(),
          updatedAt: new Date(),
        })
      );
    });
  });
});

// ── 6. pro_keys (legacy) ──────────────────────────────────────────

describe("pro_keys (legacy – fully locked)", () => {
  it("denies all reads", async () => {
    const db = superAdminDb();
    await assertFails(db.doc("pro_keys/someKey").get());
  });

  it("denies all writes", async () => {
    const db = superAdminDb();
    await assertFails(db.doc("pro_keys/someKey").set({ test: true }));
  });
});

// ── 7. Cross-cutting: unauthenticated access ─────────────────────

describe("Unauthenticated access", () => {
  it("cannot read users", async () => {
    const db = unauthedDb();
    await assertFails(db.doc(`users/${NORMAL_USER_UID}`).get());
  });

  it("cannot read adminKeys", async () => {
    const db = unauthedDb();
    await assertFails(db.doc(`adminKeys/${KEY_ID_1}`).get());
  });

  it("cannot read adminStats", async () => {
    const db = unauthedDb();
    await assertFails(db.doc("adminStats/global").get());
  });

  it("cannot read adminEvents", async () => {
    const db = unauthedDb();
    await assertFails(db.doc("adminEvents/evt001").get());
  });

  it("cannot write adminKeys", async () => {
    const db = unauthedDb();
    await assertFails(
      db.doc("adminKeys/hack").set({ keyId: "hack", status: "active" })
    );
  });

  it("cannot create keyRedemptions", async () => {
    const db = unauthedDb();
    await assertFails(
      db.collection("keyRedemptions").add({
        uid: "nobody",
        keyId: KEY_ID_1,
        type: "PRO",
        status: "pending",
      })
    );
  });
});
