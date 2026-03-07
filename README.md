# operationsbegleiter_v3

Operationsbegleiter – iOS App für Patienten, Ärzte und Pflegekräfte rund um operative Eingriffe.

## Release

### Voraussetzungen

- Flutter SDK (stable channel)
- Xcode mit gültigem Signing-Zertifikat
- Firebase CLI (`npm i -g firebase-tools`)
- Zugang zu Apple Developer Account (Team: G6B5LV52QV)
- Zugang zum Firebase-Projekt `operationsbegleiter-860e7`

### Vor dem Release

```bash
# 1. Release-Check ausführen (Analyse, Tests, Übersetzungen, Artefakt-Prüfung)
zsh tool/release_check.sh

# 2. Version in pubspec.yaml anpassen (versionName+buildNumber)
#    Beispiel: version: 1.0.0+1 → version: 1.1.0+2

# 3. Firebase Backend deployen
firebase deploy --only functions,firestore:rules,storage --project operationsbegleiter-860e7

# 4. iOS Release-Build erstellen
flutter build ios --release

# 5. In Xcode: Product → Archive → Distribute App → App Store Connect
```

### Manuelle Go/No-Go Prüfung (TestFlight)

1. **Erststart & Login** – Registrierung, Anmeldung, Passwort-Reset
2. **Push-Berechtigung** – Systemdialog erscheint
3. **Kernnavigation** – Alle Tabs erreichbar, kein Crash
4. **OP-Workflow** – OP anlegen, Timeline generieren, Aufgabe erledigen
5. **Kauf & Wiederherstellung** – Pro-Abo kaufen (Sandbox), wiederherstellen
6. **Universal Links** – `operationsbegleiter-860e7.web.app/doctor-invite/...` öffnet App
7. **Rollenpfade** – Patient, Arzt, Pflegekraft-Flows durchspielen
8. **Rechtliche Seiten** – Impressum, Datenschutz, AGB erreichbar
9. **Offline-Verhalten** – App startet ohne Netz, Pro-Status bleibt erhalten

### Bekannte Einschränkungen (Day-2)

- **Ads**: Für den ersten Release deaktiviert. Aktivierung erfordert produktive AdMob App-ID in `ios/Runner/Info.plist` (`GADApplicationIdentifier`) und Entkommentierung in `lib/main.dart`.
- **Android**: Bundle-ID und Signing noch nicht produktionsreif konfiguriert.
- **CI/CD**: Release-Builds werden manuell erstellt. Automatisierung mit GitHub Actions geplant.

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
