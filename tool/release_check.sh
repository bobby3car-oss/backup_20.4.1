#!/usr/bin/env zsh
# ─────────────────────────────────────────────────────────────
#  release_check.sh – Vor jedem Release ausführen.
#
#  Prüft Analyse, Tests, Übersetzungen und Release-Artefakte.
#
#  Nutzung:  zsh tool/release_check.sh
# ─────────────────────────────────────────────────────────────
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "${CYAN}═══════════════════════════════════════${NC}"
echo "${CYAN}       Release Readiness Check         ${NC}"
echo "${CYAN}═══════════════════════════════════════${NC}"
echo ""

ERRORS=0
WARNINGS=0

# ── 1. Version ────────────────────────────────────────────────

VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //')
echo "${CYAN}▸ Version:${NC} $VERSION"
echo ""

# ── 2. flutter pub get ────────────────────────────────────────

echo "${CYAN}▸ flutter pub get …${NC}"
flutter pub get --no-example > /dev/null 2>&1
echo "${GREEN}✓${NC} Dependencies resolved."
echo ""

# ── 3. Analyse ────────────────────────────────────────────────

echo "${CYAN}▸ flutter analyze …${NC}"
if flutter analyze --no-fatal-infos lib/ 2>&1 | tail -3; then
  echo "${GREEN}✓${NC} Keine Analyse-Fehler."
else
  echo "${RED}✗ Analyse-Fehler gefunden!${NC}"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# ── 4. Übersetzungen ─────────────────────────────────────────

echo "${CYAN}▸ Übersetzungen prüfen …${NC}"
if dart run tool/check_translations.dart 2>&1 | tail -5; then
  echo "${GREEN}✓${NC} Übersetzungen OK."
else
  echo "${RED}✗ Übersetzungsfehler!${NC}"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# ── 5. Tests ─────────────────────────────────────────────────

echo "${CYAN}▸ Tests ausführen …${NC}"
if flutter test 2>&1 | tail -5; then
  echo "${GREEN}✓${NC} Alle Tests bestanden."
else
  echo "${RED}✗ Tests fehlgeschlagen!${NC}"
  ERRORS=$((ERRORS + 1))
fi
echo ""

# ── 6. Release-Artefakte prüfen ──────────────────────────────

echo "${CYAN}▸ Release-Artefakte prüfen …${NC}"

# 6a. print() statt debugPrint
PRINT_COUNT=0
PRINT_COUNT=$(grep -rn '^\s*print(' lib/ --include='*.dart' 2>/dev/null | grep -v 'debugPrint' | wc -l | tr -d ' ') || PRINT_COUNT=0
if [ "$PRINT_COUNT" -gt 0 ]; then
  echo "  ${RED}⚠ $PRINT_COUNT print()-Aufrufe gefunden (verwende debugPrint):${NC}"
  grep -rn '^\s*print(' lib/ --include='*.dart' | grep -v 'debugPrint' | head -5
  WARNINGS=$((WARNINGS + 1))
fi

# 6b. Test-Ad-Unit-ID
if grep -q 'ca-app-pub-3940256099942544' ios/Runner/Info.plist 2>/dev/null; then
  echo "  ${YELLOW}⚠ Test-Ad-Unit-ID in Info.plist! Für Produktion ersetzen.${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

# 6c. com.example Bundle-ID
if grep -q 'com\.example' ios/Runner.xcodeproj/project.pbxproj 2>/dev/null; then
  echo "  ${YELLOW}⚠ com.example Bundle-ID gefunden! Für Produktion ersetzen.${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

# 6d. com.example Android Bundle-ID
if grep -q 'com\.example' android/app/build.gradle.kts 2>/dev/null; then
  echo "  ${YELLOW}⚠ com.example Android-ID gefunden (android/app/build.gradle.kts).${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

# 6e. Android debug signing
if grep -q 'signingConfigs.getByName("debug")' android/app/build.gradle.kts 2>/dev/null; then
  echo "  ${YELLOW}⚠ Android Release-Build nutzt Debug-Signing.${NC}"
  WARNINGS=$((WARNINGS + 1))
fi

if [ "$WARNINGS" -eq 0 ]; then
  echo "  ${GREEN}✓ Keine Release-Artefakte-Probleme.${NC}"
fi
echo ""

# ── Zusammenfassung ──────────────────────────────────────────

echo "${CYAN}═══════════════════════════════════════${NC}"
echo "  Version:       $VERSION"
if [ "$ERRORS" -eq 0 ]; then
  echo "  Qualitätsgates: ${GREEN}BESTANDEN${NC}"
else
  echo "  Qualitätsgates: ${RED}$ERRORS FEHLER${NC}"
fi
if [ "$WARNINGS" -gt 0 ]; then
  echo "  Warnungen:      ${YELLOW}$WARNINGS${NC}"
else
  echo "  Warnungen:      ${GREEN}0${NC}"
fi
echo "${CYAN}═══════════════════════════════════════${NC}"
echo ""

if [ "$ERRORS" -gt 0 ]; then
  echo "${RED}✗ Release-Blocker vorhanden. Behebe die Fehler oben.${NC}"
  exit 1
elif [ "$WARNINGS" -gt 0 ]; then
  echo "${YELLOW}⚠ Release möglich, aber Warnungen prüfen!${NC}"
  exit 0
else
  echo "${GREEN}✓ Release-Ready!${NC}"
  exit 0
fi
