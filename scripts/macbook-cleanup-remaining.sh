#!/bin/bash
# Remaining steps after obsbot-center failure
# Skips obsbot-center (cask disabled by Homebrew)

echo "=========================================="
echo "  Step 6 (remaining): Install brew casks"
echo "=========================================="
brew install --cask \
  onedrive \
  proton-mail \
  proton-mail-bridge \
  quitter \
  soundsource \
  superwhisper \
  threema \
  transnomino \
  via

echo ""
echo "=========================================="
echo "  Step 7: Delete unwanted unmanaged apps"
echo "=========================================="
echo "Removing apps with no brew cask (not needed)..."
sudo rm -rf \
  "/Applications/Adobe Digital Editions 4.5.app" \
  "/Applications/Adobe Digital Editions.app" \
  "/Applications/iTermAI.app" \
  "/Applications/iTermBrowserPlugin.app" \
  "/Applications/Jabra Direct.app" \
  "/Applications/Jabra Firmware Update.app" \
  "/Applications/Kairos Reader.app" \
  "/Applications/Kensington Konnect™.app" \
  "/Applications/Magic Keys.app" \
  "/Applications/Mastodon.app" \
  "/Applications/MouseAssistant.app" \
  "/Applications/NuPhyIO.app" \
  "/Applications/NUX Device Updater.app" \
  "/Applications/Sparkle.app" \
  "/Applications/THR Remote.app" \
  "/Applications/TrioManager.app" \
  "/Applications/Synergy.app"

echo ""
echo "=========================================="
echo "  Step 8: Install missing cross-machine apps + Linear"
echo "=========================================="
brew install --cask \
  alt-tab \
  bitwarden \
  busycontacts \
  claude \
  cursor \
  ente \
  linear-linear \
  muteme \
  obsidian \
  proton-drive

echo ""
echo "=========================================="
echo "  Step 9: Refresh Brewfile dump"
echo "=========================================="
bash ~/.mackup-sync/Mackup/brew-dump.sh

echo ""
echo "=========================================="
echo "  Done! OBSBOT Center must be installed"
echo "  manually from https://www.obsbot.com/"
echo "=========================================="
