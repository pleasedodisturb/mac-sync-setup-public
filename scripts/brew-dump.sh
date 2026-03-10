#!/bin/bash
# =============================================================================
# Universal Brewfile Dump — runs on any Mac
# =============================================================================
# Detects which machine it's on, dumps a Brewfile, and saves it to the
# Syncthing sync folder so the other Mac can compare.
# =============================================================================

set -euo pipefail

SYNC_DIR="$HOME/.mackup-sync/Mackup"
HOSTNAME=$(scutil --get ComputerName 2>/dev/null || hostname -s)

# Normalize to a safe filename
MACHINE=$(echo "$HOSTNAME" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-')
BREWFILE="$SYNC_DIR/Brewfile-$MACHINE"

echo "[$HOSTNAME] Generating Brewfile..."
brew bundle dump --file="$BREWFILE" --force 2>/dev/null

TAP_COUNT=$(grep -c '^tap ' "$BREWFILE" 2>/dev/null || echo 0)
BREW_COUNT=$(grep -c '^brew ' "$BREWFILE" 2>/dev/null || echo 0)
CASK_COUNT=$(grep -c '^cask ' "$BREWFILE" 2>/dev/null || echo 0)
VSCODE_COUNT=$(grep -c '^vscode ' "$BREWFILE" 2>/dev/null || echo 0)

echo "Found: $TAP_COUNT taps, $BREW_COUNT CLI tools, $CASK_COUNT GUI apps, $VSCODE_COUNT VS Code extensions"
echo "Saved to: $BREWFILE"
echo ""
echo "This will sync to your other Mac via Syncthing automatically."
