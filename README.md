# operationsbegleiter_v3

A new Flutter project.

## Backup

Schnelles Commit + Push mit optionalem ZIP-Snapshot.

```bash
# Standard: add, commit, push (mit Auto-Timestamp)
./tool/backup.sh

# Mit eigener Nachricht
./tool/backup.sh -m "Login-Screen fertig"

# Mit dart format vorher
./tool/backup.sh -f -m "Code aufgeräumt"

# Mit ZIP-Snapshot (landet in backups/, ist gitignored)
./tool/backup.sh -z -m "Release-Kandidat"

# Alles zusammen
./tool/backup.sh -f -z -m "Großes Feature fertig"
```

| Flag | Beschreibung |
|------|-------------|
| `-m "msg"` | Eigene Nachricht (wird an Timestamp angehängt) |
| `-z` | ZIP-Snapshot erstellen (ohne Build-Artefakte) |
| `-f` | `dart format .` vorher ausführen |
| `-h` | Hilfe anzeigen |

Commit-Format: `backup: 2026-03-05 14:30 - Login-Screen fertig`

> **Windows:** `tool/backup.ps1` ist als Stub vorhanden.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
