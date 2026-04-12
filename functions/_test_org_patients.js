const admin = require('firebase-admin');
admin.initializeApp({projectId: 'operationsbegleiter-860e7'});
const db = admin.firestore();

(async () => {
  const orgId = 'wdRcB3L0nRSIztHSHSzFYB8bdaz1';
  
  const doctorsSnap = await db.collection(`organisations/${orgId}/doctors`)
    .where('status', '==', 'active').get();
  console.log('Active doctors:', doctorsSnap.size);
  
  const doctorMap = {};
  for (const doc of doctorsSnap.docs) {
    doctorMap[doc.id] = (doc.data().name || '').toString();
    console.log('  doctor:', doc.id, doctorMap[doc.id]);
  }
  
  const linkedUids = new Set(Object.keys(doctorMap));
  linkedUids.add(orgId);
  console.log('\nQuerying links for UIDs:', [...linkedUids]);
  
  const seen = {};
  for (const uid of linkedUids) {
    const linkSnap = await db.collectionGroup('links')
      .where('linkedUid', '==', uid)
      .where('status', '==', 'active')
      .where('linkType', '==', 'doctor')
      .get();
    console.log('  links for', uid, ':', linkSnap.size);
    for (const linkDoc of linkSnap.docs) {
      const patientId = linkDoc.ref.parent.parent ? linkDoc.ref.parent.parent.id : null;
      if (patientId && !seen[patientId]) {
        seen[patientId] = uid;
        console.log('    patient:', patientId);
      }
    }
  }
  
  console.log('\nTotal patients found:', Object.keys(seen).length);
  
  for (const [patientId, linkedUid] of Object.entries(seen)) {
    const patientDoc = await db.doc(`users/${patientId}`).get();
    const data = patientDoc.data() || {};
    console.log('  Patient:', patientId, 'name:', data.displayName, 'email:', data.email, 'doctorId:', linkedUid);
  }
  
  process.exit(0);
})();
