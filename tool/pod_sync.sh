#!/usr/bin/env zsh
# ─────────────────────────────────────────────────────────────
#  pod_sync.sh – Ensures Pods/Manifest.lock is in sync with
#  Podfile.lock. Run this before flutter build/run if you get:
#    "The sandbox is not in sync with the Podfile.lock"
#
#  Usage:  zsh tool/pod_sync.sh
#  Or add to your IDE's pre-build step.
# ─────────────────────────────────────────────────────────────
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IOS_DIR="$REPO_ROOT/ios"

if [[ ! -f "$IOS_DIR/Podfile.lock" ]]; then
  echo "ℹ️  No Podfile.lock yet – running flutter pub get first."
  (cd "$REPO_ROOT" && flutter pub get)
fi

if [[ ! -f "$IOS_DIR/Pods/Manifest.lock" ]] || \
   ! diff -q "$IOS_DIR/Podfile.lock" "$IOS_DIR/Pods/Manifest.lock" > /dev/null 2>&1; then
  echo "🔄 Pods out of sync – running pod install …"
  (cd "$IOS_DIR" && pod install --repo-update)
  echo "✅ Pods synced."
else
  echo "✅ Pods already in sync."
fi
