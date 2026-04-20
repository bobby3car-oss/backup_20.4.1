#!/usr/bin/env node
// Ad-hoc check: does jangoede2005@gmail.com have admin role and admin claim?
const admin = require("firebase-admin");

admin.initializeApp({projectId: "operationsbegleiter-860e7"});

(async () => {
  const email = "jangoede2005@gmail.com";
  try {
    const user = await admin.auth().getUserByEmail(email);
    console.log("uid:", user.uid);
    console.log("email:", user.email);
    console.log("customClaims:", JSON.stringify(user.customClaims || {}));
    const doc = await admin.firestore().doc(`users/${user.uid}`).get();
    console.log("firestore exists:", doc.exists);
    if (doc.exists) {
      const d = doc.data();
      console.log("firestore role:", d.role);
      console.log("firestore email:", d.email);
      console.log("firestore updatedAt:", d.updatedAt?.toDate?.().toISOString?.() || d.updatedAt);
    }
  } catch (e) {
    console.error("ERROR:", e.message);
    process.exit(1);
  }
  process.exit(0);
})();
