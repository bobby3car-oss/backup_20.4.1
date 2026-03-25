#!/usr/bin/env node
// Quick diagnostic script – run from functions/ with: node check_codes.js
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();

(async () => {
  try {
    const permSnap = await db.collection("doctor_permanent_codes").get();
    console.log("=== doctor_permanent_codes ===");
    console.log("count:", permSnap.size);
    permSnap.docs.forEach((d) => {
      const data = d.data();
      console.log(`  code: ${d.id}  doctorUid: ${data.doctorUid}`);
    });

    const invSnap = await db
      .collection("doctor_invites")
      .orderBy("createdAt", "desc")
      .limit(10)
      .get();
    console.log("\n=== doctor_invites (last 10) ===");
    console.log("count:", invSnap.size);
    invSnap.docs.forEach((d) => {
      const data = d.data();
      console.log(
        `  code: ${d.id}  status: ${data.status}  doctorUid: ${data.doctorUid}`
      );
    });

    const docsSnap = await db.collection("doctors").get();
    console.log("\n=== doctors (permanentCode field) ===");
    docsSnap.docs.forEach((d) => {
      const data = d.data();
      if (data.permanentCode) {
        console.log(`  doctorUid: ${d.id}  permanentCode: ${data.permanentCode}`);
      }
    });
  } catch (e) {
    console.error("Error:", e.message);
  }
  process.exit(0);
})();
