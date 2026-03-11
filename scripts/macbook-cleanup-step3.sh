#!/bin/bash
# Continuation — steps 3-9 (step 1-2 already done, spark removed)
set -euo pipefail

echo "=========================================="
echo "  Step 3: Full Tailscale wipe & reinstall"
echo "=========================================="
echo "Killing Tailscale..."
killall Tailscale 2>/dev/null || true
killall "io.tailscale.ipn.macsys.network-extension" 2>/dev/null || true
sleep 2

echo "Uninstalling brew cask..."
brew uninstall --cask tailscale-app 2>/dev/null || true

echo "Removing Tailscale data & config..."
rm -rf ~/Library/Containers/io.tailscale.ipn.macos*
rm -rf ~/Library/Group\ Containers/TAILSCALE_TEAM_ID.group.io.tailscale.ipn.macos
rm -rf ~/Library/LaunchAgents/homebrew.mxcl.tailscale.plist
rm -f ~/Library/Preferences/io.tailscale.ipn.macsys.plist
rm -f /usr/local/bin/tailscale 2>/dev/null || sudo rm -f /usr/local/bin/tailscale

echo "Removing system extension (may need sudo)..."
sudo systemextensionsctl uninstall TAILSCALE_TEAM_ID io.tailscale.ipn.macsys.network-extension 2>/dev/null || true

echo "Reinstalling Tailscale..."
brew install --cask tailscale-app

echo ""
echo "=========================================="
echo "  Step 4: Remove packages per review"
echo "=========================================="
echo "Removing CLI tools..."
brew uninstall fresh-editor strands-agents-sops telnet 2>/dev/null || true

echo "Removing casks..."
brew uninstall --cask \
  1password-cli \
  adobe-digital-editions \
  anaconda \
  antigravity \
  arc \
  backblaze \
  beamer \
  crossover \
  dockmate \
  element \
  firefox \
  handbrake-app \
  "jordanbaird-ice@beta" \
  kiro \
  libreoffice \
  logitech-options \
  logitech-unifying \
  macforge \
  microsoft-edge \
  nessie-app \
  parallels \
  raindropio \
  rectangle-pro \
  slack \
  superset \
  tabby \
  teamviewer \
  telegram \
  transmission \
  2>/dev/null || true

echo "Removing Capture One..."
brew uninstall --cask capture-one 2>/dev/null || true

echo ""
echo "=========================================="
echo "  Step 5: Uninstall VS Code language packs"
echo "=========================================="
for lang in cs de es fr it ja ko pl pt-br ru zh-hans zh-hant; do
  code --uninstall-extension "ms-ceintl.vscode-language-pack-$lang" 2>/dev/null || true
done

echo ""
echo "=========================================="
echo "  Step 6: Delete manual apps → reinstall as brew casks"
echo "=========================================="
echo "Removing manually-installed apps from /Applications..."
sudo rm -rf \
  "/Applications/BIAS FX 2.app" \
  "/Applications/cTrader.app" \
  "/Applications/GPT4All.app" \
  "/Applications/Insta360 Link Controller.app" \
  "/Applications/iStat Menus 6.app" \
  "/Applications/Little Snitch.app" \
  "/Applications/MacWhisper.app" \
  "/Applications/MetaTrader 5.app" \
  "/Applications/Monologue.app" \
  "/Applications/OBSBOT_Center.app" \
  "/Applications/OneDrive.app" \
  "/Applications/Parallels Toolbox.app" \
  "/Applications/Proton Mail Bridge.app" \
  "/Applications/Proton Mail Uninstaller.app" \
  "/Applications/Proton Mail.app" \
  "/Applications/Quitter.app" \
  "/Applications/SoundSource.app" \
  "/Applications/superwhisper.app" \
  "/Applications/Threema Beta.app" \
  "/Applications/Transnomino.app" \
  "/Applications/VIA.app" \
  "/Applications/Microsoft Excel.app" \
  "/Applications/Microsoft OneNote.app" \
  "/Applications/Microsoft Outlook.app" \
  "/Applications/Microsoft PowerPoint.app" \
  "/Applications/Microsoft Teams.app" \
  "/Applications/Microsoft Word.app" \
  "/Applications/Microsoft Defender Shim.app"

echo "Installing brew cask versions..."
brew install --cask \
  bias-fx \
  gpt4all \
  insta360-link-controller \
  istat-menus \
  little-snitch \
  macwhisper \
  microsoft-office \
  monologue \
  obsbot-center \
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
echo "  ✓ All done!"
echo "=========================================="
echo "Next steps:"
echo "  1. Open Tailscale and log in"
echo "  2. Reboot if system extension removal was needed"
echo "  3. myNoise left as-is (webapp)"
echo "  4. Synergy removed (reinstall when needed from symless.com)"
