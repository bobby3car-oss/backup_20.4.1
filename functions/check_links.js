process.env.GCLOUD_PROJECT = 'operationsbegleiter-860e7';

const admin = require('firebase-admin');
const {initializeApp} = require('firebase-admin/app');
const {getFirestore} = require('firebase-admin/firestore');

initializeApp({projectId: 'operationsbegleiter-860e7'});
const db = getFirestore();

async function main() {
  // Look up the permanent code to find the doctorUid
  const codeSnap = await db.doc('doctor_permanent_codes/25FB937494').get();
  if (codeSnap.exists === false) {
    console.log('Permanent code 25FB937494 NOT FOUND');
    return;
  }
  const doctorUid = codeSnap.data().doctorUid;
  console.log('doctorUid from code:', doctorUid);

  // Check the link document
  const patientId = 'bK3ooqnr0vhXukbzvNhvksDhI4p2';
  const linkId = doctorUid + '_doctor';
  const linkRef = db.doc('patients/' + patientId + '/links/' + linkId);
  const linkSnap = await linkRef.get();
  
  if (linkSnap.exists === false) {
    console.log('LINK DOC DOES NOT EXIST at patients/' + patientId + '/links/' + linkId);
  } else {
    console.log('LINK DOC EXISTS:');
    console.log(JSON.stringify(linkSnap.data(), null, 2));
  }
  
  // Check if the patients root doc exists
  const patientDoc = await db.doc('patients/' + patientId).get();
  console.log('Patient root doc exists:', patientDoc.exists);
  if (patientDoc.exists) {
    console.log('Patient root data keys:', Object.keys(patientDoc.data()));
  }
  
  // Check the collectionGroup query as the doctor would see it
  const querySnap = await db.collectionGroup('links')
    .where('linkedUid', '==', doctorUid)
    .where('status', '==', 'active')
    .where('linkType', '==', 'doctor')
    .limit(100)
    .get();
  
  console.log('CollectionGroup query result count:', querySnap.docs.length);
  for (const doc of querySnap.docs) {
    console.log('  -', doc.ref.path, JSON.stringify(doc.data()));
  }
  
  // Also list ALL docs in patients/{patientId}/links/
  const allLinks = await db.collection('patients/' + patientId + '/links').get();
  console.log('All links for patient ' + patientId + ':', allLinks.docs.length);
  for (const doc of allLinks.docs) {
    console.log('  -', doc.id, JSON.stringify(doc.data()));
  }
}

main().then(() => process.exit(0)).catch(e => { console.error(e); process.exit(1); });
