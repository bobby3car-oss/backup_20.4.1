#!/usr/bin/env zsh
# ─────────────────────────────────────────────────────────────
#  backup.sh – Commit, Push & optionales ZIP-Backup
#  Nutzung:  ./tool/backup.sh [-z] [-f] [-m "Nachricht"]
#
#  Flags:
#    -m "msg"   Eigene Commit-Nachricht (wird an Timestamp angehängt)
#    -z         Zusätzlich ZIP-Snapshot erstellen
#    -f         Vorher `dart format .` ausführen
#    -h         Hilfe anzeigen
# ─────────────────────────────────────────────────────────────
set -euo pipefail

# ── Farben ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ── Defaults ─────────────────────────────────────────────────
CUSTOM_MSG=""
DO_ZIP=false
DO_FORMAT=false

# ── Hilfe ────────────────────────────────────────────────────
usage() {
  echo ""
  echo "${CYAN}Backup-Tool für Flutter-Repo${NC}"
  echo ""
  echo "Nutzung:  ./tool/backup.sh [Optionen]"
  echo ""
  echo "Optionen:"
  echo "  -m \"msg\"   Eigene Nachricht (wird an Timestamp angehängt)"
  echo "  -z         Zusätzlich ZIP-Snapshot erstellen"
  echo "  -f         Vorher dart format . ausführen"
  echo "  -h         Diese Hilfe anzeigen"
  echo ""
  exit 0
}

# ── Argumente parsen ─────────────────────────────────────────
while getopts "m:zfh" opt; do
  case $opt in
    m) CUSTOM_MSG="$OPTARG" ;;
    z) DO_ZIP=true ;;
    f) DO_FORMAT=true ;;
    h) usage ;;
    *) usage ;;
  esac
done

# ── Repo-Root prüfen ────────────────────────────────────────
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
  echo "${RED}✗ Nicht in einem Git-Repository.${NC}"
  exit 1
}
cd "$REPO_ROOT"
echo "${CYAN}▸ Repo-Root: ${REPO_ROOT}${NC}"

# ── Optional: Format ────────────────────────────────────────
if $DO_FORMAT; then
  echo "${YELLOW}▸ Führe dart format . aus …${NC}"
  dart format . || {
    echo "${RED}✗ dart format fehlgeschlagen.${NC}"
    exit 1
  }
  echo "${GREEN}✓ Formatierung abgeschlossen.${NC}"
fi

# ── Uncommitted Changes prüfen ──────────────────────────────
if git diff --quiet && git diff --cached --quiet && [[ -z "$(git ls-files --others --exclude-standard)" ]]; then
  echo "${YELLOW}✓ Keine Änderungen vorhanden – nichts zu tun.${NC}"
  exit 0
fi

# ── Timestamp & Commit-Message ──────────────────────────────
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
TIMESTAMP_FILE=$(date "+%Y%m%d_%H%M")

if [[ -n "$CUSTOM_MSG" ]]; then
  COMMIT_MSG="backup: ${TIMESTAMP} - ${CUSTOM_MSG}"
else
  COMMIT_MSG="backup: ${TIMESTAMP}"
fi

# ── Git Add + Commit ────────────────────────────────────────
echo "${YELLOW}▸ Stage all changes …${NC}"
git add -A

echo "${YELLOW}▸ Commit: ${COMMIT_MSG}${NC}"
git commit -m "$COMMIT_MSG"
echo "${GREEN}✓ Commit erstellt.${NC}"

# ── Git Push ─────────────────────────────────────────────────
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "${YELLOW}▸ Push nach origin/${BRANCH} …${NC}"
git push origin "$BRANCH" || {
  echo "${RED}✗ Push fehlgeschlagen. Prüfe deine Remote-Konfiguration.${NC}"
  exit 1
}
echo "${GREEN}✓ Push erfolgreich.${NC}"

# ── Optional: ZIP Snapshot ───────────────────────────────────
if $DO_ZIP; then
  BACKUP_DIR="${REPO_ROOT}/backups"
  ZIP_NAME="backup_${TIMESTAMP_FILE}.zip"
  ZIP_PATH="${BACKUP_DIR}/${ZIP_NAME}"

  mkdir -p "$BACKUP_DIR"

  echo "${YELLOW}▸ Erstelle ZIP-Snapshot: ${ZIP_NAME} …${NC}"
  cd "$REPO_ROOT"
  zip -r "$ZIP_PATH" . \
    -x "build/*" \
    -x ".dart_tool/*" \
    -x ".idea/*" \
    -x "ios/Pods/*" \
    -x "**/DerivedData/*" \
    -x "node_modules/*" \
    -x ".git/*" \
    -x "backups/*" \
    -x ".build/*" \
    -x ".pub-cache/*" \
    -x "functions/node_modules/*" \
    > /dev/null 2>&1

  ZIP_SIZE=$(du -sh "$ZIP_PATH" | cut -f1)
  echo "${GREEN}✓ ZIP erstellt: ${ZIP_PATH} (${ZIP_SIZE})${NC}"
fi

# ── Fertig ───────────────────────────────────────────────────
echo ""
echo "${GREEN}══════════════════════════════════════${NC}"
echo "${GREEN}  ✓ Backup abgeschlossen!${NC}"
echo "${GREEN}══════════════════════════════════════${NC}"
echo ""
