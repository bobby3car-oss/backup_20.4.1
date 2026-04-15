---
applyTo: "functions/**"
---

# Cloud Functions (Node.js)

## Setup
- Runtime: Node.js 18
- Region: `europe-west1` (all functions)
- Entry: `functions/index.js`
- Dependencies: `functions/package.json`

## Key Functions
- `acceptDoctorInvite` / `acceptDoctorPermanentCode` — Patient-doctor linking
- `createStaffMember` / `updateStaffMember` / `resetStaffPassword` — Staff management
- `suspendDoctor` / `unsuspendDoctor` / `deleteDoctor` — Doctor lifecycle
- `getAdminStats` — Dashboard statistics
- `askAssistant` / `askAssistantStream` — Bella AI (OpenAI integration)
- `verifyOrganisation` / `registerOrgDoctor` — Organisation management
- `sendPushNotification` — FCM push delivery

## Patterns
- All callable functions use `onCall` with `region: 'europe-west1'`
- Admin functions check `isAdmin(uid)` helper
- Doctor functions verify doctor ownership
- Staff functions verify staff permissions

## Reference
Read `/memories/repo/firebase_deploy_notes.md` for deployment procedures.
Read `/memories/repo/bella_ai_comprehensive_guide.md` for AI assistant details.
