# Mac Sync Setup

Unified configuration sync between MacBook and Mac Mini using **Syncthing** (LAN) + **Mackup** (config symlinks).

## Architecture

```
MacBook <--Syncthing (LAN)--> Mac Mini
           ~/.mackup-sync/
                └── Mackup/     ← Mackup storage backend
                    ├── .claude/
                    ├── .gitconfig
                    ├── .zshrc
                    └── ...
```

- **Syncthing** handles file sync over LAN (no cloud dependency)
- **Mackup** manages which configs to sync (symlinks local files → sync folder)
- **Brewfile-unified** is the canonical package list for both machines

## Directory Structure

```
mac-sync-setup/
├── brewfiles/
│   ├── Brewfile-unified      # Canonical — what both Macs should have
│   ├── Brewfile-macbook       # Latest dump from MacBook
│   └── Brewfile-mac-mini      # Latest dump from Mac Mini
├── mackup/
│   ├── mackup.cfg             # Main config (~/.mackup.cfg)
│   ├── ai-tools.cfg           # AI tools — specific files only
│   ├── alfred.cfg             # Alfred — prefs only, no databases
│   ├── cursor-editor.cfg      # Cursor — 4 config files only
│   └── custom-dotfiles.cfg    # Individual dotfiles + XDG configs
├── syncthing/
│   └── stignore               # ~/.mackup-sync/.stignore
├── scripts/
│   └── brew-dump.sh           # Universal Brewfile dump (auto-detects machine)
├── CHANGELOG.md               # Bugs, fixes, decisions
└── README.md
```

## Quick Reference

### Dump current packages
```bash
bash ~/.mackup-sync/Mackup/brew-dump.sh
```

### Install from unified Brewfile
```bash
brew bundle install --file=~/.mackup-sync/Mackup/Brewfile-unified
```

### Mackup restore (pull configs from sync folder)
```bash
mackup restore --force
```

### Mackup backup (push configs to sync folder)
```bash
mackup backup --force
```

### Check Syncthing status
```bash
open http://localhost:8384
```

## Setup on a New Mac

1. Install Homebrew
2. `brew install syncthing mackup`
3. `brew services start syncthing`
4. `mkdir -p ~/.mackup-sync`
5. Pair with existing Mac via Syncthing web UI (port 8384)
6. Share `~/.mackup-sync` folder
7. Wait for initial sync
8. Copy mackup configs:
   ```bash
   cp ~/.mackup-sync/Mackup/.mackup.cfg ~/  # or from this repo
   mkdir -p ~/.mackup && cp mackup/*.cfg ~/.mackup/
   ```
9. `mackup restore --force`
10. `brew bundle install --file=~/.mackup-sync/Mackup/Brewfile-unified`

## Machines

| Machine | Syncthing Device ID | Hostname |
|---------|-------------------|----------|
| MacBook | `JMK4BDS-Q25CB6L-BGKL...` | Vitalik's MacBook |
| Mac Mini | `LGEJ72L-POGEHHD-U7DF...` | Vitalik's Mac mini |
