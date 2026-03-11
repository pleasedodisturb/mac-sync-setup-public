#!/bin/bash
# =============================================================================
# Publish sanitized copy to the public repo
#
# Strips all PII (names, emails, device IDs, domains, private repo refs)
# and force-pushes to mac-sync-setup-public.
#
# Usage: bash scripts/publish-public.sh
# =============================================================================
set -euo pipefail

PUBLIC_REPO="git@github.com:pleasedodisturb/mac-sync-setup-public.git"
PRIVATE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR=$(mktemp -d)

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

echo "==> Cloning private repo to temp dir..."
git clone --quiet "$PRIVATE_DIR" "$TMP_DIR/repo"
cd "$TMP_DIR/repo"

# Remove git origin (pointed at local clone) — we'll set the public one
git remote remove origin

echo "==> Sanitizing PII..."

# --- Define all replacements ---
# Format: OLD_STRING|NEW_STRING (using | as delimiter since strings contain @)
REPLACEMENTS=(
  "Vitalik's MacBook|User's MacBook"
  "Vitalik's Mac mini|User's Mac Mini"
  "Vitalik's Mac Mini|User's Mac Mini"
  "for Vitalik's|for User's"
  "github@grn.8shield.net|YOUR_EMAIL@example.com"
  "Github--Notify@secretive.G14P.local|YOUR_SIGNING_KEY@secretive.local"
  "G14P.local|YOUR_MACHINE.local"
  "grn.8shield.net|example.com"
  "JMK4BDS-Q25CB6L-BGKL...|XXXXXXX-XXXXXXX-XXXX..."
  "LGEJ72L-POGEHHD-U7DF...|YYYYYYY-YYYYYYY-YYYY..."
  "pleasedodisturb/Money|username/private-repo"
  "Pushed \`Money\`|Pushed \`private-repo\`"
  "job-search-private|private-repo-1"
  "personal-learning-system|private-repo-2"
  "obsidian-backup|private-repo-3"
  "W5364U7YZB|TAILSCALE_TEAM_ID"
)

# Find all text files tracked by git (skip binary files)
TEXT_FILES=$(git ls-files)

for pair in "${REPLACEMENTS[@]}"; do
  OLD="${pair%%|*}"
  NEW="${pair#*|}"
  for f in $TEXT_FILES; do
    if [ -f "$f" ]; then
      OLD="$OLD" NEW="$NEW" perl -pi -e 's/\Q$ENV{OLD}\E/$ENV{NEW}/g' "$f"
    fi
  done
done

# Remove .mcp-auth from ai-tools.cfg (credentials shouldn't be in public repo)
if [ -f "mackup/ai-tools.cfg" ]; then
  sed -i '' '/^\.mcp-auth$/d' "mackup/ai-tools.cfg"
fi

echo "==> Committing sanitized version..."
git add -A
git commit --quiet -m "Sanitized publish from private repo" --allow-empty

echo "==> Pushing to public repo..."
git remote add public "$PUBLIC_REPO"
git push --force public main

echo "==> Done! Public repo updated: https://github.com/pleasedodisturb/mac-sync-setup-public"
