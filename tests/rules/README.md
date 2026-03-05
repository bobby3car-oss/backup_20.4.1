# Admin Security Rules – Emulator Tests

## Voraussetzungen

- **Node.js ≥ 18** (empfohlen: 20 LTS)
- **Firebase CLI** (`npm install -g firebase-tools`)
- **Java Runtime ≥ 11** (für Firestore Emulator)

## Installation

```bash
cd tests/rules
npm install
```

## Tests ausführen

### Variante 1 – Automatisch (empfohlen)

Startet den Emulator, führt Tests aus und beendet ihn:

```bash
cd tests/rules
npm run test:emulator
```

### Variante 2 – Manuell (mit laufendem Emulator)

Terminal 1 – Emulator starten:
```bash
cd tests/rules
npx firebase emulators:start --only firestore
```

Terminal 2 – Tests starten:
```bash
cd tests/rules
npm test
```

## Teststruktur

| Suite                       | Was wird geprüft                                               |
|-----------------------------|----------------------------------------------------------------|
| `adminKeys`                 | GET/LIST/CREATE/DELETE/UPDATE; Redemption-Transition-Logik     |
| `adminStats`                | Nur superAdmin darf lesen/schreiben                            |
| `adminEvents`               | superAdmin liest; KEY_USED Create; kein Update/Delete          |
| `keyRedemptions`            | Client darf nur `pending`-Docs erstellen; kein Update/Delete   |
| `users – server-only`       | Normal-User darf `role`/`isPro`/`doctorVerified` NICHT setzen  |
| `pro_keys (legacy)`         | Vollständig gesperrt                                           |
| `Unauthenticated`           | Kein Zugriff ohne Auth                                         |

## Cloud Function: `onKeyRedemptionCreated`

Trigger: `keyRedemptions/{redemptionId}` wird erstellt.

Ablauf:
1. Validiert `adminKeys/{keyId}` (existiert, status == „used", Uid-Match).
2. PRO-Key → `users/{uid}.isPro = true, pro = true, proSource = "adminKey"`.
3. DOCTOR-Key → `users/{uid}.role = "doctor", doctorVerified = true`.
4. Schreibt `adminEvents` + inkrementiert `adminStats/global`.
5. Setzt `keyRedemptions/{id}.status = "completed"` (oder `"failed"` bei Fehler).

## Tipps

- Bei Timeout-Fehlern in CI: `FIRESTORE_EMULATOR_HOST=localhost:8080` setzen.
- Die Tests nutzen `initializeTestEnvironment` aus `@firebase/rules-unit-testing v3`.
- Die `firestore.rules` werden automatisch aus dem Projekt-Root geladen (`../../firestore.rules`).
