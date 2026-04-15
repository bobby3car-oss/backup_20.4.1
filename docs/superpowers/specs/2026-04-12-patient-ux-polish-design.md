# Patient UX & Polishing — Design Spec

**Datum:** 2026-04-12  
**Scope:** Patient-seitiges Nachbehandlungsplan-Erlebnis  
**Ziel:** Medizinisch professionelle, klare, vertrauenswürdige UX mit modernen Micro-Interactions

---

## Überblick

Dieses Paket poliert die Patientenansicht des Nachbehandlungsplans (`PatientPlanViewScreen`) zu einem professionellen medizinischen Erlebnis. Es umfasst 8 Bereiche: Heute-Ansicht, Fortschrittsbalken, Micro-Interactions, Plan-Status-Overlays, Medical Disclaimers, Error/Retry, Edge Cases und visuelle Hierarchie.

**Nicht enthalten:** Monetarisierung, Backend-Änderungen, Arzt-Screens, Template-Builder.

---

## 1. "Heute"-Hero Section

### Platzierung
Neuer GlassCard-Bereich ganz oben in `PatientPlanViewScreen._ActivePlanBody`, vor dem bisherigen Titel-Card.

### Logik
- Berechne `daysSinceSurgery = today.difference(plan.surgeryDate).inDays`
- Filtere alle Items über alle Phasen, die heute relevant sind:
  - Item hat `startDayOffset != null` && `startDayOffset <= daysSinceSurgery` && (`endDayOffset == null || endDayOffset >= daysSinceSurgery`)
  - ODER Item hat `exactDate != null` && `exactDate` ist heute
- Kreuze mit `AftercareItemProgress` ab: welche sind `completed`?

### UI
```
┌─────────────────────────────────────────┐
│ 📋 Heute                    3 von 5 ✓  │
│ ─────────────────────────── ░░░░████    │
│                                         │
│ ☐ Medikamente einnehmen          💊    │
│ ☐ Wundkontrolle durchführen      🩹    │
│ ✓ Physiotherapie (30 min)        🏋️    │ (grau, durchgestrichen)
│ ☐ Verband wechseln              🩹    │
│ ✓ Schmerzmittel genommen         💊    │ (grau, durchgestrichen)
│                                         │
│ "Alles geschafft!" → nur wenn 5/5      │
└─────────────────────────────────────────┘
```

### Interaktion
- Checkboxen togglen via `PatientAftercareProgressService.toggleItemCompleted(planId, itemId)`
- Toggle löst `AnimatedCheckmark` + Haptic.medium() aus
- Erledigte Items: Opacity 0.6, Strikethrough (kein Reordering — YAGNI)
- Wenn alle erledigt: Confetti-Burst + "Alles geschafft! 🎉" Message

### Wenn keine Tasks heute
```
┌─────────────────────────────────────────┐
│ 📋 Heute                               │
│                                         │
│ 📅  Heute keine Aufgaben.              │
│     Genieße deinen Tag!                 │
└─────────────────────────────────────────┘
```

---

## 2. Linearer Gesamtfortschritt

### Platzierung
Im bestehenden Titel-GlassCard, unter den InfoChips, vor dem PDF-Button.

### Logik
- `totalItems = plan.phases.fold(0, (s, p) => s + p.items.length)`
- `completedItems = progress.completedCount` (aus `AftercareItemProgress`)
- `fraction = completedItems / totalItems` (guard: totalItems == 0 → 0.0)

### UI
- Nutze existierendes `GlassProgressBar` Widget
- Gradient: `AppColors.primary → AppColors.success` (blau → grün)
- `showPercentage: true`
- Label: `"$completedItems von $totalItems erledigt"`
- Höhe: 6px

### Animation
- `GlassProgressBar` hat bereits `AnimatedContainer` (500ms, easeOutCubic)
- Streamt via `watchProgress()` → automatisches Update

---

## 3. Micro-Interactions

### AnimatedCheckmark Widget
Neues Widget: `lib/features/aftercare/presentation/widgets/animated_checkmark.dart`

- **Unchecked State**: Kreis mit grey400 Border (24px)
- **Checking Animation** (300ms, easeOutCubic):
  1. Kreis füllt sich mit grünem Gradient (scale 0 → 1)
  2. Checkmark-Icon faded ein (opacity 0 → 1, scale 0.5 → 1)
  3. `Haptic.medium()` bei Start
- **Unchecking**: Reverse (200ms, schneller)

### ConfettiBurst Widget  
Neues Widget: `lib/features/aftercare/presentation/widgets/confetti_burst.dart`

- Nur bei "Alle für heute erledigt"
- 12 Partikel, radial verteilt, zufällige Farben (success, primary, warning, accent)
- Dauer: 600ms, Partikel fliegen 40-60px nach außen, faden aus
- CustomPainter + AnimationController
- Einmalig, kein Loop

### Haptic Feedback
- `Haptic.medium()` bei Task-Toggle
- `Haptic.light()` bei Phase auf/zuklappen
- `Haptic.selection()` bei Tab-Wechsel

---

## 4. Plan-Status-Overlays

### Pausiert
Wenn `plan.status == PlanStatus.paused`:

```
┌─────────────────────────────────────────┐
│ ⏸ Plan pausiert                        │
│ Dein Arzt hat den Plan vorübergehend    │
│ pausiert. Du wirst benachrichtigt,      │
│ sobald es weitergeht.                   │
│                                         │
│ Grund: {plan.pauseReason ?? "—"}        │
└─────────────────────────────────────────┘
```
- Banner: GlassCard mit warning-Hintergrund (orange, alpha 0.08)
- Links-Border: 3px solid AppColors.warning
- Rest des Plans: `Opacity(opacity: 0.5)` + `IgnorePointer()` (keine Interaktion)

### Abgeschlossen
Wenn `plan.status == PlanStatus.completed`:

```
┌─────────────────────────────────────────┐
│ ✅ Plan abgeschlossen                   │
│                                         │
│ Abgeschlossen am: 12.04.2026           │
│ Dauer: 42 Tage                          │
│ Erledigt: 28 von 35 Aufgaben           │
│ ████████████████████████░░░░░░  80%     │
│                                         │
│ Arzt-Kommentar:                         │
│ "Sehr guter Heilungsverlauf."           │
└─────────────────────────────────────────┘
```
- Hero-GlassCard mit success-Hintergrund (grün, alpha 0.08)
- `GlassProgressBar` zeigt Endstand
- Arzt-Kommentar nur wenn `plan.completionSummary != null`
- Rest des Plans: leicht reduzierte Opacity (0.7), read-only

### Abgebrochen
Wenn `plan.status == PlanStatus.cancelled`:

```
┌─────────────────────────────────────────┐
│ ✖ Plan abgebrochen                      │
│                                         │
│ Abgebrochen am: 12.04.2026             │
│ Grund: {plan.cancelReason ?? "—"}       │
│                                         │
│ Bei Fragen kontaktiere bitte            │
│ deinen behandelnden Arzt.               │
└─────────────────────────────────────────┘
```
- GlassCard mit error-Hintergrund (rot, alpha 0.08)
- Links-Border: 3px solid AppColors.error
- Rest des Plans: nicht angezeigt (nur das Banner + Archiv-Link)

---

## 5. Medical Disclaimers

### Footer-Disclaimer
Am Ende der Plan-Ansicht (nach letzter Phase, vor Archiv-Link):

```
┌─────────────────────────────────────────┐
│ ℹ  Dieser Plan dient als Orientierung  │
│    und ersetzt keine ärztliche          │
│    Diagnose oder Behandlung.            │
│    Bei Unsicherheit kontaktiere         │
│    bitte deinen Arzt.                   │
└─────────────────────────────────────────┘
```
- Zarte Darstellung: AppColors.textSecondary, bodySmall, 0.8 Opacity
- InfoIcon in grey500

### Inline-Warnungen
Bei Items der Kategorien `wound`, `dressing`, `sutureRemoval`, `medication`:
- Kleines Icon (Icons.info_outline_rounded, 12px, AppColors.warning)
- Text unter dem Item: "Bei Bedenken Arzt kontaktieren" (labelSmall, textSecondary)
- Einmal pro Phase-Card nach der Items-Liste (nicht bei jedem Item einzeln)
- Bedingung: Phase enthält mindestens ein Item mit kritischer Kategorie

### Wichtig: Dual-Stream
`PatientPlanViewScreen` muss 2 Streams kombinieren:
1. `PatientAftercarePlanService.getActivePlan(patientId)` → Plan-Daten
2. `PatientAftercareProgressService.watchProgress(planId)` → Fortschritt

Der Progress-Stream wird erst gestartet wenn der Plan geladen ist (nested StreamBuilder oder StreamBuilder + StreamBuilder).

---

## 6. Error/Retry Widget

### Neues Widget: `AftercareErrorRetry`
Pfad: `lib/features/aftercare/presentation/widgets/error_retry_widget.dart`

```dart
AftercareErrorRetry(
  message: 'Plan konnte nicht geladen werden.',
  onRetry: () => setState(() {}), // rebuild triggers StreamBuilder
)
```

### UI
```
┌─────────────────────────────────────────┐
│         ☁ (cloud_off_rounded, 48px)     │
│                                         │
│     Plan konnte nicht geladen werden.    │
│     Bitte überprüfe deine Verbindung.   │
│                                         │
│        [ Erneut versuchen ]             │
└─────────────────────────────────────────┘
```

### Anwendung
- Ersetzt Plain-Text-Fehler in `PatientPlanViewScreen` (Hauptansicht + Archiv)
- Ersetzt Fehleranzeige wenn Plan-Stream fehlschlägt

---

## 7. Edge Cases

### Kein Plan vorhanden (bestehend, verbessern)
```
┌─────────────────────────────────────────┐
│       📋 (assignment_outlined, 48px)    │
│                                         │
│         Kein aktiver Plan               │
│   Ihr Arzt hat Ihnen noch keinen        │
│   Nachbehandlungsplan zugewiesen.       │
│                                         │
│   ℹ  Bei Fragen wende dich an          │
│      deinen behandelnden Arzt.          │
└─────────────────────────────────────────┘
```
- Bestehende Icon+Text beibehalten
- Medical disclaimer ergänzen

### Heute-Abschnitt: Alle erledigt
- "Alles geschafft! 🎉" + ConfettiBurst (einmalig)
- Subtitle: "Du hast heute alle Aufgaben erledigt."

### Heute vor OP-Datum
- `daysSinceSurgery < 0` → "Dein Plan startet am {surgeryDate}. Gute Besserung!"

---

## 8. Visuelle Hierarchie

### Kategorie-Icons (bestehend, konsistent nutzen)
Die Icons aus `AftercareItemCategory.icon` werden in der Heute-Ansicht und den Phase-Cards verwendet. Keine Änderung nötig — nur konsequente Nutzung.

### Kritische Items hervorheben
Items der Kategorien `wound`, `medication`, `sutureRemoval`:
- Links-Border: 2px solid `AppColors.warning.withValues(alpha: 0.4)`
- Icon-Farbe: `AppColors.warning` statt `AppColors.grey500`

### Erledigte Items zurücknehmen
- Opacity 0.6
- Text: strikethrough-Dekoration
- Icon: grey400
- Sortierung: Nach unten (innerhalb der Heute-Sektion)

### Phase-Cards Progress
Im Phase-Header rechts ein Mini-Badge mit "3/5" (completedInPhase/totalInPhase):
```
Phase 1: Frühphase                    3/5
```

---

## Betroffene Dateien

### Neue Dateien
1. `lib/features/aftercare/presentation/widgets/animated_checkmark.dart`
2. `lib/features/aftercare/presentation/widgets/confetti_burst.dart`
3. `lib/features/aftercare/presentation/widgets/error_retry_widget.dart`
4. `lib/features/aftercare/presentation/widgets/today_hero_section.dart`
5. `lib/features/aftercare/presentation/widgets/plan_status_banner.dart`
6. `lib/features/aftercare/presentation/widgets/medical_disclaimer.dart`

### Modifizierte Dateien
7. `lib/features/aftercare/presentation/patient_plan_view_screen.dart` — Integration aller Widgets
8. `lib/l10n/app_de.arb` — Neue l10n-Keys für alle Texte

---

## Nicht enthalten (spätere Pakete)
- Fehlertoleranz & Undo (Paket B)
- Offline-Sync-Robustness (Paket B)
- l10n-Bereinigung bestehender Strings (Paket C)
- Sicherheits-Audit (Paket C)
