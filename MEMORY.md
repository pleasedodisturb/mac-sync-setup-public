# Mac Sync Setup — Memory

## Current State

- **MacBook cleanup**: Steps 1-5 complete, step 6 partial (obsbot-center failure stopped remaining cask installs)
- **Remaining**: Run `scripts/macbook-cleanup-remaining.sh` for: onedrive, proton-mail, proton-mail-bridge, quitter, soundsource, superwhisper, threema, transnomino, via + unwanted app deletion + cross-machine installs + brew dump
- **Rectangle Pro**: Restored after accidental removal (actively used)
- **Tailscale**: Wiped and reinstalled, needs login
- **GitHub repos**: All 8 cloned to ~/Projects, SSH remotes, matching names

## Architecture

- Syncthing (LAN) syncs `~/.mackup-sync/Mackup/` between MacBook + Mac Mini
- Mackup symlinks individual config files (NOT directories) to sync folder
- Brewfile-unified is canonical — includes brew casks + MAS apps + VS Code extensions
- Git repos synced via GitHub independently

## Known Issues

- `obsbot-center` brew cask disabled since 2025-04-07 — install manually
- `mas uninstall` requires sudo/interactive terminal
- `set -euo pipefail` in scripts kills on first error — use `|| true` per-command for bulk operations
- Git signing keys are machine-specific: MacBook=Secretive, Mac Mini=~/.gitconfig-local
