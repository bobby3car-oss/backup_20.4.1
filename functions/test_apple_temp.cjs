const jwt = require('jsonwebtoken');
const fs = require('fs');
const https = require('https');

const privateKey = fs.readFileSync('/tmp/apple_key.txt', 'utf8').trim();
const now = Math.floor(Date.now() / 1000);

let token;
try {
  token = jwt.sign(
    {iss: 'ddd35699-6c0c-4dd6-88ff-cfa9c1b408e4', iat: now, exp: now + 300, aud: 'appstoreconnect-v1', bid: 'com.example.operationsbegleiterV3'},
    privateKey,
    {algorithm: 'ES256', header: {kid: 'G48UBVWJ3Y', alg: 'ES256'}}
  );
  console.log('JWT generated OK');
} catch(e) {
  console.error('JWT gen FAILED:', e.message);
  process.exit(1);
}

async function testUrl(label, url, authToken) {
  const r = await fetch(url, {headers: {Authorization: 'Bearer ' + authToken}});
  const body = await r.text();
  console.log(label, '→ STATUS:', r.status, 'BODY:', JSON.stringify(body));
}

(async () => {
  await testUrl('WRONG TOKEN PROD', 'https://api.storekit.itunes.apple.com/inApps/v1/transactions/test123', 'WRONG');
  await testUrl('REAL PROD', 'https://api.storekit.itunes.apple.com/inApps/v1/transactions/test123', token);
  await testUrl('REAL SANDBOX', 'https://api.storekit-sandbox.itunes.apple.com/inApps/v1/transactions/test123', token);
})();
