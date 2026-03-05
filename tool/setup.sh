#!/usr/bin/env zsh
# ─────────────────────────────────────────────────────────────
#  setup.sh – Einmalig nach git clone ausführen.
#
#  Richtet Git-Hooks ein und installiert iOS Pods, damit
#  "The sandbox is not in sync with the Podfile.lock"
#  nie wieder auftritt.
#
#  Nutzung:  zsh tool/setup.sh
# ─────────────────────────────────────────────────────────────
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

echo "${CYAN}▸ Git-Hooks einrichten …${NC}"
mkdir -p .git/hooks
ln -sf ../../tool/git-hooks/post-checkout .git/hooks/post-checkout
ln -sf ../../tool/git-hooks/post-checkout .git/hooks/post-merge
ln -sf ../../tool/git-hooks/pre-commit .git/hooks/pre-commit
echo "${GREEN}✓${NC} post-checkout, post-merge & pre-commit Hooks installiert."

echo ""
echo "${CYAN}▸ Flutter pub get …${NC}"
flutter pub get

echo ""
echo "${CYAN}▸ iOS pod install …${NC}"
(cd ios && pod install)
echo "${GREEN}✓${NC} Pods installiert."

echo ""
echo "${GREEN}✓ Setup abgeschlossen. Du kannst die App jetzt starten.${NC}"
