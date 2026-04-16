# Route 1 Stage 2: Bella Server Guardrails

## Objective

Close the next high-impact privacy gaps in Bella by making consent server-readable and server-enforced, removing trust in client-assembled medical context, and restricting wound-analysis inputs to owner-scoped Firebase Storage objects.

## Scope

1. Add RED tests for Bella consent guardrails, wound-analysis input validation, and private-profile Firestore rules.
2. Persist Bella consent in a server-readable owner-only profile document while keeping local cache only as a UX optimization.
3. Enforce Bella consent on the backend before any third-party AI processing.
4. Remove client-provided Bella context payloads from request assembly and rely on server-built context only.
5. Restrict wound-analysis inputs to validated `woundAnalysis/{uid}/...` Storage objects instead of arbitrary external HTTPS URLs.
6. Align Bella endpoints and client callers with the EU function boundary where it is safe to do so without introducing an unknown deployment URL.

## Tasks

1. RED: add policy tests for Bella consent enforcement, client-context removal, and wound-analysis storage-path validation.
2. RED: add a Firestore emulator test proving `users/{uid}/private/profile` is owner-only.
3. GREEN: implement consent sync/backfill in `BellaConsentService` and stop carrying Bella consent across sign-out.
4. GREEN: enforce consent and server-owned context in Bella backend/client paths.
5. GREEN: switch wound-analysis uploads to storage paths and validate those paths server-side before loading bytes.
6. Verify with targeted Flutter tests, Firestore rules emulator test, `dart analyze`, and `node --check functions/index.js`.

## Done Criteria

- Bella cannot call external AI without a server-readable current consent record.
- Bella clients no longer send device-assembled medical context blobs to the backend.
- Wound analysis no longer accepts arbitrary external image URLs.
- Private Bella consent metadata is writable/readable only by the signed-in owner.
- Existing unrelated worktree churn remains untouched.