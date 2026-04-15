---
applyTo: "lib/features/**"
---

# Feature Module Conventions

## Structure
Every feature follows `data/`, `domain/`, `presentation/` layers:
- **domain/**: Models, enums, interfaces (no imports from data/presentation)
- **data/**: Repositories, services, Firestore interaction
- **presentation/**: Screens, widgets, UI logic

## Patterns
- **Local repos**: Singleton with `StreamController.broadcast`, expose `watchAll()` → `Stream<List<T>>`
- **State**: `StatefulWidget` + `StreamBuilder` (no Riverpod/Bloc)
- **Firestore paths**: Always use `FirestorePaths` from `lib/firebase/firebase_paths.dart`
- **Localization**: Use `AppLocalizations.of(context)!.keyName` — all keys defined in `lib/l10n/app_de.arb`
- **Theme**: Use `AppColors`, `AppSpacing`, `AppRadius` from `lib/ui/theme/`
- **Glass UI**: Use `GlassContainer` with `GlassElevation` for frosted card effects

## Repo Memory
Before making significant changes, read the relevant `/memories/repo/` file for that feature.
