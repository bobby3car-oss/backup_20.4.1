# Aftercare UX, Stability and Security Design

## Goal
Build a professional-grade patient aftercare experience that is clear, trustworthy, resilient offline, and consistent with medical product expectations, without breaking existing timeline, task, plan versioning, dashboard, roles, or permission systems.

## Scope
This design is Stage 1 only:
- Patient-facing aftercare experience polish
- Offline-first task interaction for item completion
- Undo flow and human-centered error handling
- Performance and consistency hardening

Out of scope for this stage:
- Large dashboard redesigns
- Core domain model rewrites
- New monetization flows (explicitly forbidden)

## Constraints and Non-Negotiables
- No monetization in this feature area
- Feature remains fully free for doctors and organizations
- Existing systems must remain compatible and undamaged:
  - Timeline system
  - Task system
  - Plan system including versioning and snapshots
  - Doctor and organization dashboards
  - Roles and permissions

## Existing Baseline
Current implementation already includes:
- Patient plan view screen with today section and phase cards
- Plan status banners for paused, completed, and cancelled
- Progress tracking service for item completion
- Timeline mapping support for paused plans
- Firestore rules for aftercare plans, progress, notes, and immutable change logs

The design extends this baseline without changing core ownership or lifecycle semantics.

## Architecture Approach
Recommended approach: Experience-layer extension on top of existing architecture.

Principles:
- Keep existing services and data contracts intact
- Add focused extensions for offline queue, undo, and UX consistency
- Avoid broad refactors and avoid touching unrelated feature areas
- Preserve current Firestore and role-based access assumptions

## UX and Visual Hierarchy Design
### Information hierarchy
1. Primary focus: Today block with urgent relevance
2. Secondary context: plan status, progress, and key metadata
3. Detailed content: phase lists with reduced cognitive load
4. Tertiary content: archive access and medical disclaimer

### Today-first clarity
- Sort today items by clinical relevance and actionability:
  - critical and open first
  - non-critical open second
  - completed last
- Show explicit state markers per item:
  - open
  - completed
  - critical
- Keep language calm and clear

### Medical visual tone
- Serious, modern, and calm UI
- No overloaded visual effects
- Keep critical area feedback subtle
- Use consistent icon mapping by category:
  - medication
  - wound
  - appointments
  - exercises

## Micro-Interactions
- Completion interaction includes:
  - subtle check confirmation
  - haptic feedback when platform supports it
- Critical tasks do not use celebratory animation
- Non-critical completion may use small positive confirmation
- Maintain reduced-motion friendliness by keeping animations short and optional-safe

## Error Tolerance and Recovery
- Confirm critical actions before destructive transitions
- Add undo window for item completion changes:
  - duration: 8 seconds
- Replace technical error copy with patient-centered language
- Provide retry pathways for failed loading and sync

## Offline-First Design
### Interaction model
- Item toggles can be performed while offline
- Toggle actions are applied optimistically in UI
- Actions are stored in a local persistent queue

### Sync strategy
- Re-sync automatically on connectivity recovery and screen resume
- Conflict resolution rule:
  - last-write-wins using server timestamp
- Record conflict-related outcomes in audit-safe logs without sensitive medical free text

### Safety
- No data loss goal for user actions
- Failed sync keeps action in queue with bounded retry behavior and visible status

## Performance Design
- Keep stream subscriptions minimal and scoped
- Avoid expensive recomputation inside build paths
- Precompute today and critical subsets where needed
- Use lazy list rendering for long archive/history views
- Minimize unnecessary rebuild cascades in patient plan screen

## Security and Privacy
- Do not persist sensitive plaintext notes in local sync queue
- Store only minimum toggle metadata locally:
  - planId
  - itemId
  - intended completion state
  - local timestamp
- Respect existing Firestore permission model
- Ensure logs remain free of sensitive personal medical details

## Trust and Medical Guidance
Required trust messaging remains visible and consistent:
- Please contact your doctor if unsure
- This does not replace medical diagnosis

No gamification in critical care contexts.

## Edge Cases
- No tasks today: clear and reassuring empty state
- No current plan: informative guidance state
- Plan paused: visible but visually de-emphasized tasks plus pause explanation
- Plan completed: completion summary view with key metadata
- Plan cancelled: clear status and support guidance
- Loading or network error: understandable copy plus retry action

## Consistency Rules
- Same terminology across all aftercare screens
- Same status semantics across:
  - patient plan view
  - timeline mapping
  - status banners
  - progress indicators
- No mixed logic for what is active, paused, completed, cancelled, archived

## Integration and Compatibility
The implementation must remain compatible with:
- Timeline integration route and timeline task state mapping
- Task orchestration behavior and state transitions
- Snapshot-based patient plan assignments and versioning
- Doctor and organization management views that consume plan status data
- Role-based access and linked-caregiver permissions

## Proposed File-Level Impact
Primary modifications:
- lib/features/aftercare/presentation/patient_plan_view_screen.dart
- lib/features/aftercare/presentation/widgets/today_hero_section.dart
- lib/features/aftercare/presentation/widgets/plan_status_banner.dart
- lib/features/aftercare/presentation/widgets/error_retry_widget.dart
- lib/features/aftercare/data/patient_aftercare_progress_service.dart
- lib/features/aftercare/domain/aftercare_item_progress.dart

Validation touchpoints:
- lib/features/aftercare/data/aftercare_timeline_mapper.dart
- lib/features/aftercare/data/patient_aftercare_plan_service.dart
- firestore.rules

## Test and Verification Strategy
- Add widget tests for key UX states and flows:
  - no plan
  - paused plan
  - completed plan
  - retry state
  - undo snackbar
- Add service-level tests for queue and sync:
  - offline enqueue
  - retry success
  - conflict handling with last-write-wins
- Run targeted analysis and regression checks for aftercare module
- Verify no permission regressions

## Risks and Mitigations
- Risk: regressions in existing completion flow
  - Mitigation: additive extensions, targeted tests, no schema-breaking changes
- Risk: inconsistent status handling across screens
  - Mitigation: centralized status mapping and exhaustive switch validation
- Risk: stale local queue actions
  - Mitigation: bounded retries, conflict-safe merge, clear pending state in UI

## Acceptance Criteria
- Patients can complete tasks online and offline without data loss
- Undo is available for 8 seconds after completion toggle
- Critical actions are protected by clear confirmation
- UI is calmer, clearer, and focused on today
- Error and empty states are understandable and actionable
- Timeline and plan systems continue to work unchanged
- Roles and permissions continue to enforce access correctly
- No monetization added to this area
