# Mac Sync Setup — Claude Code Instructions

## Project

Cross-machine configuration sync for Vitalik's MacBook + Mac Mini.
Uses **Syncthing** (LAN sync) + **Mackup** (config symlinks) + **Homebrew** (package management).

## Architecture

```
MacBook <--Syncthing (LAN)--> Mac Mini
           ~/.mackup-sync/
                └── Mackup/     ← Mackup storage backend
```

- Syncthing handles file sync (no cloud)
- Mackup manages which configs to symlink
- Brewfile-unified is the canonical package list
- Git repos synced independently via GitHub, NOT Syncthing

## Memory Strategy (3 layers)

1. **MEMORY.md** (boot loader) — current state, updated end of session, <200 lines
2. **MCP memory** (searchable) — detailed facts, decisions via `store_memory`/`memory_search`
3. **Git** (audit trail) — commit history IS the log, no state dump files

## Key Files

| Path | Purpose |
|------|---------|
| `brewfiles/Brewfile-unified` | Canonical package list for both Macs |
| `brewfiles/Brewfile-macbook` | Latest MacBook dump |
| `brewfiles/Brewfile-mac-mini` | Latest Mac Mini dump |
| `mackup/mackup.cfg` | Main Mackup config → `~/.mackup.cfg` |
| `mackup/*.cfg` | Custom app configs → `~/.mackup/` |
| `scripts/brew-dump.sh` | Universal Brewfile dump (detects machine) |
| `syncthing/stignore` | Syncthing ignore patterns |
| `CHANGELOG.md` | Bugs, fixes, decisions log |

## Machines

| Machine | Hostname | Signing Key |
|---------|----------|-------------|
| MacBook | Vitalik's MacBook | Secretive (Github--Notify@secretive.G14P.local) |
| Mac Mini | Vitalik's Mac mini | `~/.gitconfig-local` (github@grn.8shield.net) |

## Safety Rules

- NEVER modify `~/.mackup.cfg` or `~/.mackup/*.cfg` without confirming — changes propagate to both machines via Syncthing
- NEVER run `mackup backup/restore` without explicit confirmation
- NEVER delete Brewfile-unified — it's the single source of truth
- Confirm before any `brew uninstall` or `mas uninstall` — these are destructive
- Scripts go in `scripts/`, NEVER in `~` home directory

## Package Management

- **brew casks** preferred over Mac App Store when both exist (trackable in Brewfile)
- **mas** (Mac App Store CLI) for MAS-only apps
- Run `bash scripts/brew-dump.sh` after any package changes
- Update `brewfiles/Brewfile-unified` when adding/removing packages intentionally

## Mackup Rules

- NEVER point Mackup at entire directories (causes cache/runtime bloat)
- Always specify individual config files in custom `.cfg` files
- Test `mackup restore` on one machine before syncing changes

## Git Signing

- MacBook uses Secretive (hardware key in Secure Enclave)
- Mac Mini uses `includeIf` → `~/.gitconfig-local` to override signing key
- `~/.gitconfig-local` is machine-specific, NOT synced
