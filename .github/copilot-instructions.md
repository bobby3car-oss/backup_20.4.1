# Operationsbegleiter v3 — Project Context

## App Overview
German medical app for **post-operative patient care**. Flutter 3.x, Dart 3.11+, Firebase backend, targeting iOS, Android, and Web.

### Roles & Routing
| Role | Home Screen | Verification |
|------|-------------|-------------|
| Patient | `MainNavigation` (3-tab: Timeline, Mehr, Profil) | None |
| Doctor | `DoctorHome` (patients, staff, templates, calendar) | Admin approval required |
| Organisation | `OrgHome` (doctors, patients, staff, profile) | Admin approval required |
| Family | `FamilyHome` (linked patients, messages) | None |
| Caregiver | `CaregiverHome` | None |
| Admin | `AdminHome` (PIN-gated dashboard) | Hardcoded admin UIDs |

### Tech Stack
- **State management**: Stateful widgets + StreamBuilder (no Riverpod/Bloc)
- **Backend**: Cloud Firestore (offline-first with SyncService), Cloud Functions (europe-west1)
- **Auth**: Firebase Auth (Email, Google, Apple)
- **Payments**: RevenueCat (`purchases_flutter`)
- **Ads**: Google Mobile Ads
- **AI**: Bella AI assistant (Cloud Functions + OpenAI)
- **Push**: FCM + flutter_local_notifications
- **Deep Links**: app_links for doctor/family invitations
- **Localization**: ARB-based, German primary (`lib/l10n/`)
- **Theme**: Material 3, iOS-blue primary (#007AFF), glass/frosted effects

### Architecture Patterns
- **Feature modules**: `lib/features/<name>/` with `data/`, `domain/`, `presentation/` layers
- **Firestore paths**: Centralized in `lib/firebase/firebase_paths.dart`
- **Local repositories**: Singleton pattern with `StreamController.broadcast`, `watchAll()` → Stream
- **Timeline**: `TaskOrchestrator` + `TimelineEngine` with phase-based task states
- **Offline sync**: `SyncService` → `SyncQueueLocal` → `FirestoreClient` with retry logic
- **Role-based screens**: `lib/roles/` (admin_home, doctor_home, org_home, caregiver_home)

### Key Firestore Collections
- `users/{uid}`, `patients/{patientId}`, `doctors/{doctorId}`, `organisations/{orgId}`
- Patient subcollections: timeline, wounds, pain, appointments, documents, red_flags, etc.
- Doctor subcollections: staff, documents
- `doctor_invites/{code}`, `doctor_permanent_codes/{code}`
- `patient_aftercare_plans/{planId}` with `progress/items` subcollection
- `system_aftercare_templates`, `doctor_aftercare_templates`, `organization_aftercare_templates`
- `support_tickets/`, `appConfig/global`

### Cloud Functions (europe-west1)
All in `functions/index.js`: acceptDoctorInvite, createStaffMember, suspendDoctor, getAdminStats, askAssistant (Bella AI), etc.

### Testing
- `flutter test` — unit + widget tests in `test/`
- `dart analyze` — static analysis
- Tests use `AppLocalizations` mocking (see `/memories/repo/widget_test_localization_notes.md`)

### Memory System
This project has 40+ detailed repo-memory files in `/memories/repo/`. When working on a specific feature, **read the relevant repo memory file first** to avoid rediscovering architecture. Key files:
- `flutter_project_comprehensive_structure.md` — Full project map
- `aftercare_system_complete_analysis.md` — Aftercare/Nachbehandlungsplan system
- `routing_navigation_comprehensive.md` — All navigation flows
- `ui_theme_system_comprehensive.md` — Theme, colors, spacing, glass system
- `stream_and_feed_patterns.md` — Timeline, repositories, streaming patterns
- `firestore_collectiongroup_rules.md` — Firestore security rules
- `firebase_deploy_notes.md` — Deployment procedures
- `bella_ai_comprehensive_guide.md` — AI assistant system
- `paywall_subscription_complete_system.md` — RevenueCat integration
- `doctor_role_system_comprehensive.md` — Doctor features
- `staff_management_comprehensive_guide.md` — Staff system

---

# Superpowers - Agentic Development Workflow

This project uses the **Superpowers** methodology (by obra) for structured, high-quality agentic development.

## Core Workflow

1. **Brainstorming** → Before any creative work, explore intent, requirements, and design before implementation.
2. **Writing Plans** → Break approved designs into bite-sized, actionable implementation plans with TDD.
3. **Executing Plans / Subagent-Driven Development** → Execute plans task-by-task with review checkpoints.
4. **Test-Driven Development** → RED-GREEN-REFACTOR cycle for all features and bugfixes.
5. **Systematic Debugging** → Root cause investigation before proposing fixes.
6. **Verification Before Completion** → Evidence before claims, always.
7. **Code Review** → Review early, review often.

## Key Principles

- **YAGNI** — You Aren't Gonna Need It. Remove unnecessary features.
- **DRY** — Don't Repeat Yourself.
- **TDD** — Write tests first. Watch them fail. Write minimal code to pass.
- **No production code without a failing test first.**
- **Systematic over ad-hoc** — Process over guessing.
- **Evidence over claims** — Verify before declaring success.

## Skills

The following skills are available in `.github/skills/` and should be invoked automatically based on context:

| Skill | When to Use |
|-------|-------------|
| `brainstorming` | Before any creative work — creating features, building components, adding functionality |
| `writing-plans` | When you have a spec or requirements for a multi-step task |
| `executing-plans` | When you have a written implementation plan to execute |
| `subagent-driven-development` | When executing plans with independent tasks in the current session |
| `test-driven-development` | When implementing any feature or bugfix |
| `systematic-debugging` | When encountering any bug, test failure, or unexpected behavior |
| `verification-before-completion` | Before claiming work is complete, fixed, or passing |
| `requesting-code-review` | When completing tasks or before merging |
| `frontend-design` | When building web components, pages, or applications — distinctive, production-grade UI |
| `code-reviewer` | After completing any implementation — automated quality, reuse, and simplification pass |
| `security-auditor` | When reviewing auth flows, data handling, API endpoints, or security-sensitive code |
| `architecture` | When designing system architecture, component structure, or evaluating design decisions |
| `office-hours` | YC-style product discovery — use before building anything new to challenge premises and expose demand reality |
| `ship-workflow` | When code is ready to ship — tests, review, version bump, changelog, PR creation |
| `retrospective` | Weekly or post-milestone engineering retrospective — shipping velocity, test health, action items |
| `qa-review` | Systematic QA testing — find bugs, fix with atomic commits, generate regression tests |

<!-- GSD Configuration — managed by get-shit-done installer -->
# Instructions for GSD

- Use the get-shit-done skill when the user asks for GSD or uses a `gsd-*` command.
- Treat `/gsd-...` or `gsd-...` as command invocations and load the matching file from `.github/skills/gsd-*`.
- When a command says to spawn a subagent, prefer a matching custom agent from `.github/agents`.
- Do not apply GSD workflows unless the user explicitly asks for them.
- After completing any `gsd-*` command (or any deliverable it triggers: feature, bug fix, tests, docs, etc.), ALWAYS: (1) offer the user the next step by prompting via `ask_user`; repeat this feedback loop until the user explicitly indicates they are done.
<!-- /GSD Configuration -->
