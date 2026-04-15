---
applyTo: "lib/l10n/**"
---

# Localization (ARB-based)

## Setup
- Primary language: German (`app_de.arb`)
- Config: `l10n.yaml` at project root
- Generated: `AppLocalizations` class
- Usage: `AppLocalizations.of(context)!.keyName`

## Adding New Keys
1. Add key + value to `lib/l10n/app_de.arb`
2. Run `flutter gen-l10n` (or let `flutter run` regenerate)
3. Use in code: `AppLocalizations.of(context)!.newKey`

## Conventions
- Key names: camelCase, descriptive (e.g., `doctorPatientListTitle`, `painDiaryEmptyState`)
- Placeholders: `{name}` syntax in ARB, `String name` parameter in generated code
- All UI-facing text must be localized — no hardcoded German strings in Dart files
