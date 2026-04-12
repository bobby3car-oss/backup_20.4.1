# Arztmodus Next Level – Implementation Plan

**Goal:** Elevate the doctor mode from functional dashboard to clinical-grade surgical tool with (1) wound photo display + Bella AI analysis in doctor view, (2) triage dashboard redesign, (3) SOAP notes + discharge workflow.

**Architecture:** Three independent phases modifying existing files. Phase 1 modifies `patient_wounds_tab.dart` to display wound photos and AI analysis badges instead of "Foto vorhanden" text. Bella overlay controller writes analysis results back to `WoundEntry.metadata['bellaAnalysis']`. Phase 2 replaces the alert section in `doctor_overview_tab.dart` with rich triage cards showing healing progress. Phase 3 extends `DoctorNote` with SOAP fields and adds a discharge wizard.

**Tech Stack:** Flutter, Firestore, existing `WoundAnalysisResult` model, `GlassCard` UI system, `BellaWoundAnalysisCard` widget (reusable).

---

## Phase 1: Wound Photos + AI Analysis in Doctor View

### Task 1: Display wound photos in PatientWoundsTab

**Files:**
- Modify: `lib/features/doctor_patients/presentation/tabs/patient_wounds_tab.dart`

- [ ] **Step 1: Add dart:io import and replace "Foto vorhanden" with actual photo thumbnail**

Replace the current "Foto vorhanden" text indicator (lines 96-108) with an actual photo thumbnail:

```dart
// Add at top of file:
import 'dart:io';

// Replace the photo indicator section in the GlassCard child Column:
// BEFORE:
if (wound.photoPath != null) ...[
  const SizedBox(height: AppSpacing.sm),
  Row(
    children: [
      Icon(Icons.photo_rounded, size: 16, color: AppColors.grey600),
      const SizedBox(width: 4),
      Text('Foto vorhanden', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    ],
  ),
],

// AFTER:
if (wound.photoPath != null || wound.photoUrl != null) ...[
  const SizedBox(height: AppSpacing.sm),
  _WoundPhotoThumbnail(
    photoPath: wound.photoPath,
    photoUrl: wound.photoUrl,
  ),
],
```

- [ ] **Step 2: Create _WoundPhotoThumbnail widget at bottom of same file**

```dart
class _WoundPhotoThumbnail extends StatelessWidget {
  const _WoundPhotoThumbnail({this.photoPath, this.photoUrl});

  final String? photoPath;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final path = photoPath;
    final hasLocal = path != null && path.trim().isNotEmpty && File(path.trim()).existsSync();
    final hasRemote = photoUrl != null && photoUrl!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: double.infinity,
        height: 180,
        child: hasLocal
            ? Image.file(File(path!.trim()), fit: BoxFit.cover)
            : hasRemote
                ? Image.network(photoUrl!, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.grey100,
      child: Center(
        child: Icon(Icons.image_not_supported_outlined, size: 30, color: AppColors.grey400),
      ),
    );
  }
}
```

- [ ] **Step 3: Run `flutter analyze` to verify no errors**

Run: `flutter analyze lib/features/doctor_patients/presentation/tabs/patient_wounds_tab.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add lib/features/doctor_patients/presentation/tabs/patient_wounds_tab.dart
git commit -m "feat(doctor): display wound photos in patient wounds tab"
```

---

### Task 2: Add Bella AI analysis badge to wound cards

**Files:**
- Modify: `lib/features/doctor_patients/presentation/tabs/patient_wounds_tab.dart`

- [ ] **Step 1: Import WoundAnalysisResult and add analysis display**

```dart
// Add import:
import '../../../../features/assistant/domain/wound_analysis_result.dart';
```

- [ ] **Step 2: Add AI analysis badge + expandable section to wound card**

After the photo thumbnail section, add the Bella analysis display. In the GlassCard child Column, after the photo section:

```dart
// After the photo thumbnail section, add:
if (wound.metadata['bellaAnalysis'] != null) ...[
  const SizedBox(height: AppSpacing.sm),
  _BellaAnalysisBadge(
    analysis: WoundAnalysisResult.fromJson(
      Map<String, dynamic>.from(wound.metadata['bellaAnalysis'] as Map),
    ),
  ),
],
```

- [ ] **Step 3: Create _BellaAnalysisBadge widget**

```dart
class _BellaAnalysisBadge extends StatefulWidget {
  const _BellaAnalysisBadge({required this.analysis});

  final WoundAnalysisResult analysis;

  @override
  State<_BellaAnalysisBadge> createState() => _BellaAnalysisBadgeState();
}

class _BellaAnalysisBadgeState extends State<_BellaAnalysisBadge> {
  bool _expanded = false;

  Color get _statusColor => switch (widget.analysis.status) {
        'green' => AppColors.success,
        'yellow' => AppColors.warning,
        'red' => AppColors.error,
        _ => AppColors.grey400,
      };

  @override
  Widget build(BuildContext context) {
    final a = widget.analysis;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _statusColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(a.statusEmoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  'KI: ${a.statusLabel}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: _statusColor,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: AppSpacing.sm),
          if (a.observations.isNotEmpty)
            ...a.observations.map((obs) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          width: 5, height: 5,
                          decoration: BoxDecoration(
                            color: _statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(obs,
                            style: const TextStyle(fontSize: 12, height: 1.4)),
                      ),
                    ],
                  ),
                )),
          if (a.recommendation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(a.recommendation,
                        style: const TextStyle(fontSize: 12, height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
          if (a.comparisonNote != null && a.comparisonNote!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📊', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(a.comparisonNote!,
                        style: const TextStyle(fontSize: 12, height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}
```

- [ ] **Step 4: Run `flutter analyze`**

Run: `flutter analyze lib/features/doctor_patients/presentation/tabs/patient_wounds_tab.dart`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add lib/features/doctor_patients/presentation/tabs/patient_wounds_tab.dart
git commit -m "feat(doctor): show Bella AI wound analysis badge in wounds tab"
```

---

### Task 3: Write Bella analysis back to WoundEntry.metadata

**Files:**
- Modify: `lib/features/assistant/presentation/bella_overlay_controller.dart`

**Context:** When Bella completes a wound analysis, the result is stored in the chat message but NOT in the WoundEntry. We need to write it back to `WoundEntry.metadata['bellaAnalysis']` so the doctor can see it.

- [ ] **Step 1: Find the wound analysis completion point and add write-back**

In `bella_overlay_controller.dart`, after the wound analysis streaming completes and the assistant message has `woundAnalysis` set, we write it back to the most recent WoundEntry.

After the `_persistMessage` calls for wound analysis (around line 625-636), add:

```dart
// Write analysis result back to the latest wound entry for doctor visibility.
if (assistantMsg.woundAnalysis != null) {
  _writeBackWoundAnalysis(assistantMsg.woundAnalysis!);
}
```

- [ ] **Step 2: Add the _writeBackWoundAnalysis method to the controller**

```dart
/// Writes the Bella analysis result to the latest WoundEntry's metadata
/// so doctors can see AI analysis in the patient wounds tab.
Future<void> _writeBackWoundAnalysis(WoundAnalysisResult result) async {
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('patients/$uid/wounds')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return;

    final doc = snap.docs.first;
    final existingMetadata =
        Map<String, dynamic>.from((doc.data()['metadata'] as Map?) ?? {});
    existingMetadata['bellaAnalysis'] = result.toJson();

    await doc.reference.update({'metadata': existingMetadata});
  } catch (e) {
    debugPrint('[Bella] Write-back wound analysis failed: $e');
  }
}
```

- [ ] **Step 3: Ensure imports exist**

Verify `FirebaseAuth` and `FirebaseFirestore` imports exist at top of file. They likely already do since the controller uses Firebase.

- [ ] **Step 4: Run `flutter analyze`**

Run: `flutter analyze lib/features/assistant/presentation/bella_overlay_controller.dart`
Expected: No issues found

- [ ] **Step 5: Commit**

```bash
git add lib/features/assistant/presentation/bella_overlay_controller.dart
git commit -m "feat(bella): write wound analysis result back to WoundEntry metadata"
```

---

### Task 4: Add wound photo timeline grouped by body location

**Files:**
- Create: `lib/features/doctor_patients/presentation/tabs/wound_photo_timeline.dart`
- Modify: `lib/features/doctor_patients/presentation/tabs/patient_wounds_tab.dart`

- [ ] **Step 1: Create the WoundPhotoTimeline widget**

Create `lib/features/doctor_patients/presentation/tabs/wound_photo_timeline.dart`:

```dart
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../features/assistant/domain/wound_analysis_result.dart';
import '../../../../features/wound/domain/wound_entry.dart';
import '../../../../ui/ui.dart';

/// Horizontal photo timeline grouped by body location.
class WoundPhotoTimeline extends StatelessWidget {
  const WoundPhotoTimeline({super.key, required this.wounds});

  final List<WoundEntry> wounds;

  @override
  Widget build(BuildContext context) {
    // Group wounds by body location.
    final groups = <String, List<WoundEntry>>{};
    for (final w in wounds) {
      if (w.photoPath == null && w.photoUrl == null) continue;
      final loc = w.bodyLocation ?? 'Unbekannt';
      (groups[loc] ??= []).add(w);
    }

    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_outlined, size: 48, color: AppColors.grey400),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Keine Fotos vorhanden',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // Sort each group chronologically (oldest first).
    for (final list in groups.values) {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return ListView(
      padding: AppSpacing.screenPadding,
      children: groups.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 16,
                      color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.value.length} Fotos',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 160,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: entry.value.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final w = entry.value[i];
                  return _TimelinePhoto(wound: w);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        );
      }).toList(),
    );
  }
}

class _TimelinePhoto extends StatelessWidget {
  const _TimelinePhoto({required this.wound});

  final WoundEntry wound;

  @override
  Widget build(BuildContext context) {
    final path = wound.photoPath;
    final hasLocal = path != null &&
        path.trim().isNotEmpty &&
        File(path.trim()).existsSync();
    final hasRemote = wound.photoUrl != null && wound.photoUrl!.isNotEmpty;

    final analysisMap = wound.metadata['bellaAnalysis'];
    final hasAnalysis = analysisMap != null && analysisMap is Map;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 120,
                height: 120,
                child: hasLocal
                    ? Image.file(File(path!.trim()), fit: BoxFit.cover)
                    : hasRemote
                        ? Image.network(wound.photoUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder())
                        : _placeholder(),
              ),
            ),
            // AI status badge if analysis exists
            if (hasAnalysis)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    WoundAnalysisResult.fromJson(
                      Map<String, dynamic>.from(analysisMap as Map),
                    ).statusEmoji,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 120,
          child: Row(
            children: [
              Text(
                '${wound.createdAt.day}.${wound.createdAt.month}.',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const Spacer(),
              _MiniPainBadge(level: wound.pain),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.grey100,
      child: Center(
        child: Icon(Icons.image_not_supported_outlined,
            size: 24, color: AppColors.grey400),
      ),
    );
  }
}

class _MiniPainBadge extends StatelessWidget {
  const _MiniPainBadge({required this.level});

  final int level;

  Color get _color {
    if (level <= 3) return AppColors.success;
    if (level <= 6) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$level',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _color),
      ),
    );
  }
}
```

- [ ] **Step 2: Add view toggle (List/Timeline) to PatientWoundsTab**

In `patient_wounds_tab.dart`, add a toggle between list and photo timeline:

```dart
// Add import:
import 'wound_photo_timeline.dart';

// Add to _PatientWoundsTabState:
bool _showTimeline = false;

// In build method, wrap the current content:
// After the empty-state check, before the ListView.builder, add toggle + conditional:
```

Specifically, after `final wounds = snapshot.data ?? [];` and the empty check, add:

```dart
return Column(
  children: [
    // View toggle
    Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      child: Row(
        children: [
          _ViewToggle(
            isTimeline: _showTimeline,
            onToggle: () => setState(() => _showTimeline = !_showTimeline),
          ),
        ],
      ),
    ),
    Expanded(
      child: _showTimeline
          ? WoundPhotoTimeline(wounds: wounds)
          : ListView.builder(/* existing code */),
    ),
  ],
);
```

And add the `_ViewToggle` widget.

- [ ] **Step 3: Run `flutter analyze`**

Run: `flutter analyze lib/features/doctor_patients/presentation/tabs/`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add lib/features/doctor_patients/presentation/tabs/
git commit -m "feat(doctor): add wound photo timeline grouped by body location"
```

---

## Phase 2: Clinical Dashboard Redesign

### Task 5: Create TriagePatientCard widget

**Files:**
- Create: `lib/features/doctor_overview/presentation/triage_patient_card.dart`

- [ ] **Step 1: Create the triage card widget**

The card shows: patient name, phase badge, days-post-OP, pain trend indicator, wound AI status, red flag count, healing progress bar.

Uses existing `LinkedPatient` fields plus `GlassCard` as base.

- [ ] **Step 2: Run `flutter analyze`**

- [ ] **Step 3: Commit**

```bash
git add lib/features/doctor_overview/presentation/triage_patient_card.dart
git commit -m "feat(doctor): create TriagePatientCard with clinical indicators"
```

---

### Task 6: Replace alert section with triage cards

**Files:**
- Modify: `lib/features/doctor_overview/presentation/doctor_overview_tab.dart`

- [ ] **Step 1: Import TriagePatientCard**

- [ ] **Step 2: Replace `_buildAlertSection` to use triage cards instead of `_AlertPatientCard`**

Show ALL patients (not just alerts) sorted by urgency: red → yellow → unanswered questions → green. The triage section becomes the primary clinical view.

- [ ] **Step 3: Run `flutter analyze`**

- [ ] **Step 4: Commit**

```bash
git add lib/features/doctor_overview/presentation/
git commit -m "feat(doctor): replace alert section with clinical triage cards"
```

---

### Task 7: Add Morning Brief header

**Files:**
- Modify: `lib/features/doctor_overview/presentation/doctor_overview_tab.dart`

- [ ] **Step 1: Replace static greeting with Morning Brief context line**

After the greeting and date line, add a summary line:
`"2 Termine heute · 1 neue Frage · 3 Post-OP im Blick"`

Uses existing data: `_todayAppointments.length`, `_statsData?.unansweredQuestions`, postOp count.

- [ ] **Step 2: Commit**

```bash
git add lib/features/doctor_overview/presentation/doctor_overview_tab.dart
git commit -m "feat(doctor): add Morning Brief contextual header"
```

---

### Task 8: Add healing progress bars to patient cards

**Files:**
- Modify: `lib/features/doctor_patients/presentation/doctor_patients_tab.dart` (or `patient_card.dart`)

- [ ] **Step 1: Add color-coded progress bar**

`progressPercent` already exists. Add color logic: <25% blue (early post-OP), 25-75% green (active healing), >75% teal (near complete).

- [ ] **Step 2: Commit**

```bash
git commit -m "feat(doctor): color-coded healing progress bars in patient list"
```

---

## Phase 3: SOAP Notes & Discharge Management

### Task 9: Extend DoctorNote with SOAP fields

**Files:**
- Modify: `lib/features/doctor_notes/domain/doctor_note.dart`
- Modify: `lib/features/doctor_notes/data/doctor_notes_repository.dart`

- [ ] **Step 1: Add noteType enum and soapData fields to DoctorNote**

```dart
enum DoctorNoteType { freeform, soap, discharge }

// Add to DoctorNote:
final DoctorNoteType noteType;
final Map<String, String>? soapData; // keys: s, o, a, p
```

- [ ] **Step 2: Update fromFirestore/toFirestore/copyWith**

- [ ] **Step 3: Update repository for new fields**

- [ ] **Step 4: Commit**

```bash
git commit -m "feat(doctor): extend DoctorNote with SOAP and discharge note types"
```

---

### Task 10: Create SOAP note editor widget

**Files:**
- Create: `lib/features/doctor_notes/presentation/soap_note_editor.dart`
- Modify: `lib/features/doctor_notes/presentation/doctor_notes_tab.dart`

- [ ] **Step 1: Create SOAP editor with 4 expandable sections**

S (Subjektiv), O (Objektiv), A (Assessment), P (Plan) — each with a GlassTextField and descriptive hint.

- [ ] **Step 2: Add note type selector in _NoteEditorSheet**

When creating a new note, show type selection: Freitext | SOAP | Entlassung. When SOAP selected, show SOAP editor instead of single content field.

- [ ] **Step 3: Update _NoteCard display for SOAP notes**

Show S/O/A/P labels in the card preview.

- [ ] **Step 4: Commit**

```bash
git commit -m "feat(doctor): add SOAP note editor with structured S/O/A/P fields"
```

---

### Task 11: Create discharge wizard

**Files:**
- Create: `lib/features/doctor_notes/presentation/discharge_wizard_sheet.dart`
- Modify: `lib/features/doctor_patients/presentation/patient_detail_screen.dart`

- [ ] **Step 1: Create discharge wizard bottom sheet**

Multi-step wizard:
1. Discharge date + diagnosis
2. Final wound assessment (pull from latest bellaAnalysis or manual)
3. Course note (SOAP or freeform)
4. Patient instructions (from template or freeform)

- [ ] **Step 2: Trigger wizard on phase change to discharged**

In PatientDetailScreen, when patient phase is set to `discharged`, open the discharge wizard.

- [ ] **Step 3: Create discharge DoctorNote on wizard completion**

Save as `DoctorNote` with `noteType: discharge` containing all wizard data.

- [ ] **Step 4: Commit**

```bash
git commit -m "feat(doctor): add discharge wizard with structured documentation"
```

---

## Execution Order

1. Task 1 → Task 2 → Task 3 → Task 4 (Phase 1, sequential — wound photos first, then AI, then timeline)
2. Task 5 → Task 6 → Task 7 → Task 8 (Phase 2, sequential — card first, then integration)
3. Task 9 → Task 10 → Task 11 (Phase 3, sequential — model first, then UI)

Phases 1, 2, 3 are independent and could run in parallel, but each task within a phase depends on the previous.
