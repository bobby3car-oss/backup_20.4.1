const admin = require("firebase-admin");
if (!admin.apps.length) admin.initializeApp({ projectId: "operationsbegleiter-860e7" });
const db = admin.firestore();

/**
 * Debug: trace staff → org → patients flow
 */
(async () => {
  const orgUid = "wdRcB3L0nRSIztHSHSzFYB8bdaz1";

  // 1) Find all staff members (users with staffOf pointing to org or any org doctor)
  console.log("=== Step 1: Find staff members ===");
  
  // Staff directly under org
  const staffOfOrgSnap = await db.collection("users")
    .where("staffOf", "==", orgUid).get();
  console.log(`Staff with staffOf=${orgUid}: ${staffOfOrgSnap.size}`);
  for (const doc of staffOfOrgSnap.docs) {
    const d = doc.data();
    console.log(`  uid=${doc.id} role=${d.role} staffOf=${d.staffOf} email=${d.email} displayName=${d.displayName}`);
  }

  // Get all org doctors
  const doctorsSnap = await db.collection(`organisations/${orgUid}/doctors`)
    .where("status", "==", "active").get();
  console.log(`\nActive doctors in org: ${doctorsSnap.size}`);
  for (const doc of doctorsSnap.docs) {
    const d = doc.data();
    console.log(`  doctorUid=${doc.id} name=${d.name}`);
    
    // Staff under this doctor
    const staffOfDocSnap = await db.collection("users")
      .where("staffOf", "==", doc.id).get();
    console.log(`  Staff with staffOf=${doc.id}: ${staffOfDocSnap.size}`);
    for (const sDoc of staffOfDocSnap.docs) {
      const sd = sDoc.data();
      console.log(`    uid=${sDoc.id} role=${sd.role} staffOf=${sd.staffOf} email=${sd.email}`);
    }
  }

  // 2) Find all org staff subcollection entries
  console.log("\n=== Step 2: Organisation staff subcollection ===");
  const orgStaffSnap = await db.collection(`organisations/${orgUid}/staff`).get();
  console.log(`organisations/${orgUid}/staff docs: ${orgStaffSnap.size}`);
  for (const doc of orgStaffSnap.docs) {
    const d = doc.data();
    console.log(`  id=${doc.id} status=${d.status} name=${d.name} email=${d.email} role=${d.role}`);
  }

  // 3) Check doctor's own staff subcollection
  console.log("\n=== Step 3: Doctor staff subcollection ===");
  for (const doc of doctorsSnap.docs) {
    const staffSnap = await db.collection(`doctors/${doc.id}/staff`).get();
    console.log(`doctors/${doc.id}/staff docs: ${staffSnap.size}`);
    for (const s of staffSnap.docs) {
      const sd = s.data();
      console.log(`  id=${s.id} status=${sd.status} name=${sd.name}`);
    }
  }

  // 4) Simulate resolveOrgIdForCaller for each staff member found
  console.log("\n=== Step 4: Simulate resolveOrgIdForCaller for staff ===");
  const allStaff = [];
  for (const doc of staffOfOrgSnap.docs) allStaff.push(doc);
  for (const dDoc of doctorsSnap.docs) {
    const staffOfDocSnap = await db.collection("users")
      .where("staffOf", "==", dDoc.id).get();
    for (const doc of staffOfDocSnap.docs) allStaff.push(doc);
  }
  
  for (const staffDoc of allStaff) {
    const userData = staffDoc.data();
    const callerUid = staffDoc.id;
    console.log(`\nSimulating for staff uid=${callerUid} (role=${userData.role}, staffOf=${userData.staffOf}):`);
    
    const ROLES = new Set(["patient", "doctor", "caregiver", "family", "admin", "staff", "organisation"]);
    const rawRole = typeof userData.role === "string" ? userData.role : "";
    let resolvedRole;
    if (ROLES.has(rawRole)) resolvedRole = rawRole;
    else if (typeof userData.staffOf === "string" && userData.staffOf) resolvedRole = "staff";
    else resolvedRole = "patient";
    console.log(`  resolvedRole: ${resolvedRole}`);
    
    if (resolvedRole === "staff") {
      const staffOf = userData.staffOf;
      const ownerSnap = await db.doc(`users/${staffOf}`).get();
      const ownerData = ownerSnap.exists ? ownerSnap.data() : {};
      console.log(`  owner (staffOf=${staffOf}): role=${ownerData.role} orgVerified=${ownerData.orgVerified} orgId=${ownerData.orgId}`);
      
      if (ownerData.role === "organisation") {
        console.log(`  → resolves to orgId=${staffOf} (direct org)`);
      } else if (ownerData.orgId) {
        console.log(`  → resolves to orgId=${ownerData.orgId} (via doctor's orgId)`);
      } else {
        console.log(`  → ERROR: would throw "Der zugeordnete Arzt gehört keiner Organisation an."`);
      }
    } else {
      console.log(`  → ERROR: role is "${resolvedRole}", not "staff" — would NOT enter staff branch!`);
    }
  }

  // 5) List all patient links
  console.log("\n=== Step 5: All active doctor links ===");
  const allLinks = await db.collectionGroup("links")
    .where("linkType", "==", "doctor")
    .where("status", "==", "active")
    .get();
  console.log(`Total active doctor links: ${allLinks.size}`);
  for (const l of allLinks.docs) {
    console.log(`  ${l.ref.path} → linkedUid=${l.data().linkedUid}`);
  }

  process.exit(0);
})();
