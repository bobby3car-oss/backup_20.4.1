# Security Hardening Route 1 Design

## Goal
Raise the app's real security and privacy posture by removing the structural weaknesses identified in the audit instead of layering mitigations on top of them.

This design targets the root causes behind the low score:
- client-reconstructable shared encryption model
- fail-open encryption behavior
- client-only Bella consent enforcement
- mixed function region behavior and accidental non-EU processing
- plaintext local persistence of sensitive notification data
- unclear boundaries between shared profile data and owner-only PII

## Scope
This design covers the minimum architecture needed to close the current Critical and High findings with a durable model.

Included:
- user and patient data boundary redesign
- removal of the shared client-side master-key trust model
- fail-closed local secure storage behavior
- server-verified Bella consent and data minimization
- EU region pinning for sensitive backend processing
- secure local notification persistence
- telemetry and crash reporting default-off until consent is technically applied
- migration plan for existing encrypted and shared data

Out of scope for this design:
- unrelated UI redesigns
- monetization or paywall changes
- broad timeline or aftercare feature refactors unrelated to security
- replacing Firebase with another backend
- redesign of the legal or operational GDPR export and deletion workflow

## Security Outcome Target
The target is not a marketing claim of perfect security. The target is a materially stronger architecture where the current known structural weaknesses are removed and a new review should find no remaining known Critical issues in these areas.

Success means:
- no global client decryption path for shared medical or profile data
- no external Bella processing without server-verified consent
- no sensitive plaintext local file persistence on supported platforms
- no accidental default-region execution for sensitive functions
- no fail-open behavior for secure local writes in production

## Existing Baseline
The project already has meaningful security foundations:
- Firebase Auth and role-aware Firestore rules
- App Check integration
- screen and app switcher protection
- Android backups disabled
- rate limiting on multiple backend paths

The current problem is not the absence of all security controls. The problem is that a few core architecture decisions undermine confidentiality and data governance despite those controls.

## Chosen Approach
Chosen route: split-model redesign.

This design removes the idea that client-side encryption can safely protect data that multiple independent clients must read. Shared data will instead rely on explicit access control boundaries, while owner-only data remains isolated by data model and rules.

Principles:
- use access control as the security boundary for shared care data
- reserve encryption for local device storage and narrowly scoped secrets
- fail closed when secure storage is unavailable in production
- centralize region and consent enforcement on the server
- make shared data explicit instead of leaking it through broad user documents

## Data Classification Model
Data is split into three classes.

### 1. Shared Identity Data
Path:
- `users/{uid}`

Purpose:
- hold non-sensitive shared identity and relationship data needed by the app shell and role routing

Allowed examples:
- role
- account status
- display name suitable for shared views
- profile image reference if approved for shared use
- relation metadata required for linking and navigation

Disallowed examples:
- private phone numbers
- private email addresses unless operationally required for self only
- home address
- detailed emergency contact data
- medical notes

### 2. Owner-Only Private Profile Data
Path:
- `users/{uid}/private/profile`

Purpose:
- store private PII and privacy metadata only readable by the owner and admin flows

Allowed examples:
- email
- phone number
- address
- exact emergency contact information
- Bella consent state and timestamps
- privacy and regulatory consent metadata

Access:
- self
- admin where explicitly required

### 3. Shared Care Profile Data
Path:
- `patients/{patientId}/care_profile/current`

Purpose:
- hold the minimal patient-facing and clinician-facing data that must be visible to linked care roles

Allowed examples:
- patient display information needed by doctors, family, and caregivers
- selected care contact metadata
- clinically necessary shared profile fields
- approved communication preferences relevant to treatment coordination

Disallowed examples:
- data that only the account owner needs
- broad copy of all user profile fields

Access:
- governed by patient ownership, doctor/family/caregiver links, staff inheritance, and admin rules

## Architecture Decisions

### Remove Shared Client-Side Master Key Model
The existing shared key retrieval and restore flow will be retired after migration.

Consequences:
- `getEncryptionKey` is no longer part of the long-term trust model
- field-level encryption for server-shared profile data is not preserved as a compatibility layer
- confidentiality for shared records is enforced through data separation and Firestore rules, not through a universal client key

Rationale:
- if multiple unrelated clients can reconstruct the same decryption capability, the encryption layer does not provide meaningful confidentiality against compromised clients or future read leaks

### Keep Local Encryption, But Only For Device-Local Data
Local storage encryption remains valuable for on-device caches and offline data.

Rules:
- secure local writes must use the device-local encryption path
- production writes must fail when secure encryption cannot be initialized
- plaintext fallback is only acceptable for explicitly non-sensitive preferences

### Centralize Cloud Functions Region Selection
All sensitive callable, HTTP, scheduled, and AI-related functions will explicitly use `europe-west1`.

Client-side rule:
- Flutter code uses one centralized Functions accessor
- direct `FirebaseFunctions.instance` use is removed for sensitive paths

Rationale:
- region consistency must be enforced in code, not assumed by convention

### Move Bella Privacy Controls Server-Side
Bella processing is gated by server-readable consent and server-built context.

Rules:
- client-only SharedPreferences consent is insufficient
- server checks auth, App Check, role context, consent state, and allowed data class before forwarding any payload to a third party
- client-provided freeform health context blobs are no longer trusted as the direct source for prompts
- server builds the minimum prompt from approved data sources

### Default Telemetry To Off Until Consent
Analytics and crash reporting must remain technically disabled until consent is loaded and applied.

Rules:
- startup must not assume consent before consent state is resolved
- runtime toggles alone are not enough if providers can emit pre-consent events during initialization
- platform and app initialization should prefer disabled-by-default behavior where supported
- enabling telemetry is an explicit post-consent transition

### Restrict Wound Analysis Inputs
Bella wound analysis and related image flows will accept only validated Firebase Storage objects belonging to the allowed user or patient context.

Disallowed:
- arbitrary remote HTTPS image URLs
- images not bound to an authorized patient or owner context

## Component Boundaries

### Flutter Client
Responsibilities:
- display and capture user intent
- read and write the correct data class path
- use centralized Functions client access
- store sensitive local data only through secure storage abstractions

Must not:
- reconstruct shared master keys
- decide Bella consent purely locally
- send arbitrary privileged context for AI processing

### Cloud Functions
Responsibilities:
- enforce consent and data minimization
- construct allowed AI prompts from approved server-side reads
- validate region-bound processing
- execute migration and cleanup jobs

Must not:
- expose globally reusable decryption material to all registered clients
- accept unvalidated external image sources for medical analysis

### Firestore and Storage Rules
Responsibilities:
- enforce the new split between shared identity, owner-only private profile, and shared care profile
- preserve existing linked-role patterns while narrowing readable fields and paths

## Data Flow Design

### Profile Reads
1. App loads shared shell identity from `users/{uid}`.
2. Self-only profile screens read `users/{uid}/private/profile`.
3. Doctor, family, caregiver, and staff patient-facing screens read `patients/{patientId}/care_profile/current`.

This removes implicit over-sharing via broad user documents.

### Bella Chat and Streaming
1. Client sends the user action and minimal request payload.
2. Server verifies auth, App Check, consent, and access context.
3. Server fetches only approved data sources.
4. Server builds the minimum prompt.
5. Server calls the configured AI provider from `europe-west1` only.
6. Server logs only bounded, non-sensitive operational metadata.

### Bella Wound Analysis
1. Client references an owned or authorized Storage object.
2. Server validates path ownership and role access.
3. Server fetches or signs access internally.
4. Server forwards only the validated image and minimal analysis context.

### Local Notifications and Cached Sensitive Data
1. Notification repository writes through `UserScopedStorage.writeSecure`.
2. Reads use `readSecure`.
3. Secure storage init failure causes a controlled error in production instead of plaintext fallback.

## Security Defaults
The system intentionally becomes stricter.

Defaults:
- no plaintext fallback for secure local writes in production
- no Bella call without server-side consent
- no default Functions region for sensitive calls
- no arbitrary remote image URLs for wound analysis
- no sensitive notification cache in plaintext files
- no mixed data classes inside broad user documents
- no analytics or crash reporting before consent is applied

Trade-off:
- some flows will fail visibly instead of silently continuing insecurely

This is the correct behavior for a medical app.

## Migration Strategy
Migration is phased to avoid a partial but insecure steady state.

### Phase 1: Introduce New Paths and Rules
- add `users/{uid}/private/profile`
- add `patients/{patientId}/care_profile/current`
- add rules for both paths
- keep old reads temporarily only where needed for migration

### Phase 2: Server-Side Data Rebuild
- create admin-only migration tooling
- use server-controlled access to existing encrypted values
- transform records into the new split model
- backfill consent state into server-readable storage

### Phase 3: Client Read Path Cutover
- move Flutter screens and services to new data sources
- route self-only screens to private profile
- route care team views to care profile
- replace direct function instance usage with centralized region-bound access

### Phase 4: Retire Legacy Security Debt
- remove legacy shared-key restore flows
- disable `getEncryptionKey`
- remove old sensitive fields from `users/{uid}`
- remove insecure Bella payload assembly paths

### Phase 5: Enforce Upgrade Boundary
- old clients should not appear to partially work in a weakened mode
- prefer explicit compatibility checks and version gating where necessary

## Compatibility Rules
- preserve role system semantics
- preserve doctor/family/caregiver linking model
- preserve offline-first behavior where possible
- do not keep insecure compatibility shims that prolong the shared-key model

## Proposed File-Level Impact
Primary backend impact:
- `functions/index.js`
- Firestore migration helpers and any related admin tooling

Primary rules impact:
- `firestore.rules`
- `storage.rules`

Primary Flutter impact:
- `lib/security/encryption_key_manager.dart`
- `lib/security/field_encryption_service.dart`
- `lib/security/local_storage_encryption.dart`
- `lib/sync/user_scoped_storage.dart`
- `lib/notifications/notification_repository.dart`
- `lib/features/assistant/data/bella_consent_service.dart`
- `lib/features/assistant/presentation/*`
- function-calling services that currently use default region instances

## Testing and Verification Strategy
Verification is split across four tracks.

### 1. Rules Tests
Add or update tests for:
- self access
- linked doctor access
- family access
- caregiver access
- staff access
- admin access
- unauthenticated denial
- owner-only private profile denial for non-owners

### 2. Functions Tests
Add tests for:
- Bella rejection without consent
- Bella rejection without App Check where required
- Bella rejection for unauthorized patient context
- wound analysis rejection for arbitrary external URLs
- region-bound callable wiring
- migration tooling auth restrictions
- telemetry-disabled-before-consent behavior where testable

### 3. Flutter Tests
Add tests for:
- secure notification persistence
- no plaintext fallback in production mode
- centralized Functions helper usage for sensitive calls
- self profile reads from private profile
- care views reading from shared care profile

### 4. Verification Commands
Required verification before completion:
- `dart analyze`
- targeted `flutter test`
- relevant functions tests
- relevant rules tests

## Risks and Mitigations
- Risk: data migration could strand fields in old and new locations.
  Mitigation: phased migration with explicit cutover and cleanup checks.

- Risk: old clients may break once insecure compatibility paths are removed.
  Mitigation: version gate and controlled rollout instead of silent fallback.

- Risk: role views may temporarily lose fields during path split.
  Mitigation: define allowed care profile fields explicitly before UI cutover.

- Risk: server-built Bella prompts could initially omit useful context.
  Mitigation: start with minimum safe context and expand deliberately, not through arbitrary client payloads.

## Acceptance Criteria
- Shared medical and profile data no longer depends on a client-reconstructable universal key.
- Owner-only PII is separated from shared care data by path and rules.
- Secure local writes fail closed in production.
- Sensitive notifications are not persisted as plaintext files.
- Bella chat and wound analysis enforce server-side consent and authorized context.
- Sensitive backend processing runs only through explicitly EU-pinned functions.
- Arbitrary external wound image URLs are rejected.
- Analytics and crash reporting stay disabled until consent is explicitly applied.
- Legacy shared-key restore flows are removed or disabled after migration.

## Implementation Readiness
This design is intentionally focused enough for one implementation plan, but large enough to require staged execution.

Recommended implementation order:
1. Region and Functions client centralization
2. fail-closed local storage and secure notification persistence
3. Bella server-side consent and wound input validation
4. data model split and client read-path cutover
5. legacy shared-key migration and removal