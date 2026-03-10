# Changelog

## 2026-03-10 — Initial Setup

### What was done

1. **Phase 1: Inventory** — ran `mac-mini-setup.sh` on Mac Mini
   - Generated Brewfile dump of Mac Mini
   - Backed up all existing configs to `~/mackup-backup-20260310-091838`
   - Compared MacBook vs Mac Mini packages

2. **Package audit** — reviewed all 125 packages across both Macs
   - Created unified Brewfile with 112 packages (5 taps, 23 CLI, 74 GUI, 10 VS Code extensions)
   - Removed 34 packages (unused apps, duplicate browsers, old Python)
   - See `mac-mini-package-review.md` for full removal list

3. **Mackup config fix** — replaced bloated configs that synced entire directories
   - Old configs pointed at `.claude/`, `.gemini/`, `.cursor/`, `.config/goose/` etc.
   - This dumped tens of thousands of cache/runtime/browser files into sync
   - New configs specify individual files only

4. **Migrated from Proton Drive to Syncthing**
   - Installed Syncthing on Mac Mini, paired with MacBook
   - Mackup storage backend changed from Proton Drive path to `~/.mackup-sync/Mackup`
   - Direct LAN sync, no cloud dependency

5. **Installed unified packages on Mac Mini**
   - All CLI tools and GUI apps from Brewfile-unified

### Bugs & Issues Found

#### `kindle` cask no longer exists
- **Symptom**: `brew bundle install` fails with "No available formula with the name kindle"
- **Fix**: Replaced with `send-to-kindle` in Brewfile-unified

#### `signal` has no Mackup profile
- **Symptom**: `mackup restore` crashes with `KeyError: 'signal'`
- **Fix**: Removed `signal` from `[applications_to_sync]` in `.mackup.cfg`
- **Note**: Would need a custom `~/.mackup/signal.cfg` if we want Signal config sync

#### `brew bundle install` fails silently on CLI tools
- **Symptom**: First run reported failure on cask downloads, but CLI tools (formulas) also didn't install — `gh`, `aider`, `gcc`, etc. were all missing
- **Fix**: Had to run `brew install` separately for all 17 missing CLI tools
- **Root cause**: Unclear — possibly the cask download failures caused early exit before formulas were processed

#### `docker-desktop` needs sudo for CLI plugin symlink
- **Symptom**: `brew install --cask docker-desktop` fails with "sudo: a terminal is required"
- **Fix**: Run manually in terminal: `sudo mkdir -p /usr/local/cli-plugins && brew install --cask docker-desktop`
- **Note**: Can't be automated from non-interactive shells

#### `pocket-casts` CDN consistently fails
- **Symptom**: `curl: (18) Transferred a partial file` on every retry
- **Fix**: Install from Mac App Store instead, or retry later

#### Mackup bloated Proton Drive sync
- **Symptom**: `ai-tools.cfg` and `custom-dotfiles.cfg` pointed at entire directories (`.claude`, `.gemini`, `.cursor`, `.config/goose`)
- **Impact**: Tens of thousands of cache/runtime/browser-profile files synced to Proton Drive
- **Fix**: Rewrote configs to specify individual config files only
- **Lesson**: Never point Mackup at a directory unless you're sure it only contains config files

#### MacBook Brewfile missing apps that are installed
- **Symptom**: `bitwarden`, `claude`, `cursor`, `proton-drive`, `tailscale-app` were installed on MacBook but not in its Brewfile
- **Root cause**: Likely installed outside Homebrew (direct download, App Store) before being added to Homebrew cask registry
- **Fix**: Added to unified Brewfile manually

#### Brewfile-unified wasn't in Syncthing folder
- **Symptom**: `brew bundle install --file=~/.mackup-sync/Mackup/Brewfile-unified` → "No Brewfile found"
- **Root cause**: File was created in Proton Drive path, not copied to Syncthing folder
- **Fix**: Copied to `~/.mackup-sync/Mackup/`

### Decisions Made

| Decision | Rationale |
|----------|-----------|
| Syncthing over Proton Drive | Direct LAN sync, faster, no cloud dependency |
| Mackup with specific files only | Prevent cache/runtime bloat |
| No session sync for Claude Code | Sessions are machine-local (paths, terminal state) |
| `rectangle-pro` removed | Not needed on either Mac |
| `transmission` removed | Not needed on either Mac |
| `capture-one` removed | Not needed on either Mac |
| `signal` removed from Mackup | No built-in profile; not worth custom config |
| VS Code language packs removed | English only |
| Fish as default shell | Set on Mac Mini via iTerm2 |
| Git repos cloned independently | Synced via git, not Syncthing |

### TODO (MacBook side)

- [ ] Run removal commands from `mac-mini-package-review.md`
- [ ] Install Mac Mini-only apps (alt-tab, bitwarden, busycontacts, etc.)
- [ ] Remove `signal` from `~/.mackup.cfg`
- [ ] Add `obs`, `sublime-text`, `dash`, `forklift`, `karabiner` to `~/.mackup.cfg`
- [ ] Run `bash ~/.mackup-sync/Mackup/brew-dump.sh`
- [ ] Verify Syncthing fully synced


