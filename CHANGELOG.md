# Changelog

## 2026-03-10 — MacBook full app consolidation + MAS→brew migration

### What was done

1. **MAS→brew migration** — uninstalled 14 Mac App Store apps and reinstalled as brew casks
   - Acorn, AusweisApp, Canva, Cardhop, DaisyDisk, Fantastical, GrandPerspective, HazeOver, Keka, LookAway, Soulver, TextSniper, TickTick (Spark skipped — not needed)
   - Installed `mas` CLI to manage remaining MAS-only apps

2. **Manual app→brew migration** — deleted manually-installed apps, reinstalled as brew casks
   - BIAS FX 2, GPT4All, Insta360 Link Controller, iStat Menus (upgraded 6→7), Little Snitch, MacWhisper, Microsoft Office (consolidated suite), Monologue, Proton Mail + Bridge, Quitter, SoundSource, superwhisper, Threema, Transnomino, VIA
   - OBSBOT Center skipped (cask disabled by Homebrew)

3. **Tailscale full wipe & reinstall** — killed processes, removed system extension, containers, preferences, launch agents, reinstalled clean via brew

4. **Package review removals** (from `mac-mini-package-review.md`)
   - CLI: fresh-editor, strands-agents-sops, telnet
   - Casks: 1password-cli, adobe-digital-editions, anaconda, antigravity, arc, backblaze, beamer, crossover, dockmate, element, firefox, handbrake-app, kiro, libreoffice, logitech-options, logitech-unifying, macforge, microsoft-edge, nessie-app, parallels, raindropio, slack, superset, tabby, teamviewer, telegram, transmission
   - Rectangle Pro restored (was in removal list but actively used)

5. **Unwanted unmanaged apps removed** — Adobe Digital Editions (old), iTermAI, iTermBrowserPlugin, Jabra Direct/Firmware, Kairos Reader, Kensington Konnect, Magic Keys, Mastodon, MouseAssistant, NuPhyIO, NUX Device Updater, Sparkle, THR Remote, TrioManager, Synergy

6. **New cross-machine installs** — alt-tab, bitwarden, busycontacts, claude, cursor, ente, linear-linear, muteme, obsidian, proton-drive

7. **GitHub repos synced** — all 8 repos cloned/pulled to `~/Projects/`, renamed to match GitHub, switched from HTTPS to SSH remotes

8. **Brewfile-unified updated** — now includes MAS apps (via `mas`), all migrated brew casks, VS Code extensions. Total: ~100 casks + 38 MAS apps

9. **Project setup** — added `.claude/CLAUDE.md` with 3-layer memory framework, moved cleanup scripts to `scripts/`

### Bugs & Issues Found

#### `mas uninstall` requires sudo
- **Symptom**: `mas uninstall` fails in sandboxed/non-interactive shells
- **Fix**: Must run in terminal with password entry

#### `obsbot-center` cask disabled
- **Symptom**: `brew install --cask obsbot-center` → "has been disabled because download is behind a signed URL"
- **Fix**: Install manually from obsbot.com
- **Since**: 2025-04-07

#### `set -euo pipefail` kills script on first cask error
- **Symptom**: obsbot-center failure stopped all subsequent installs
- **Fix**: Split into continuation scripts; consider `|| true` per-cask in future

#### `tee` output redirection fails in fish shell
- **Symptom**: `bash script.sh 2>&1 | tee file` → "Unknown command: file"
- **Fix**: Syntax is the same in fish, but the shell was interpreting `~/path` on the second line of a multi-line paste incorrectly. Use single-line command.

#### Rectangle Pro incorrectly marked for removal
- **Symptom**: Removed in step 4 based on `mac-mini-package-review.md`
- **Fix**: Reinstalled via `brew install --cask rectangle-pro`, added back to Brewfile-unified

### Decisions Made

| Decision | Rationale |
|----------|-----------|
| Prefer brew casks over MAS | Trackable in Brewfile, consistent across machines |
| Include MAS apps in Brewfile-unified | Complete machine reproducibility via `brew bundle` + `mas` |
| Keep myNoise as-is | It's a webapp, no brew cask needed |
| Remove Synergy | Not working currently, reinstall from symless.com when needed |
| Linear via `linear-linear` cask | User preference for brew-managed |
| Spark removed | User doesn't need it |
| `mas` added as CLI tool | Enables MAS app management in Brewfile |
| Scripts in `scripts/` not `~` | Keep home directory clean (global Claude rule) |

---

## 2026-03-10 — Git signing key fix + clone missing repos

### What was done

1. **Git signing key — includeIf approach**
   - Added `[includeIf "gitdir:~/"]` → `~/.gitconfig-local` to `~/.gitconfig`
   - Created `~/.gitconfig-local` with Mac Mini's signing key (`YOUR_EMAIL@example.com`)
   - Removed per-repo signing key override from `mac-sync-setup/.git/config`
   - `~/.gitconfig-local` is machine-specific, not synced via Mackup/Syncthing

2. **Cloned missing GitHub repos to `~/Projects/`**
   - `private-repo-1`
   - `private-repo-2`
   - `private-repo-3`

3. **Pushed `private-repo` to GitHub**
   - Already had local git repo with .gitignore excluding CSVs and YNAB exports
   - Created private repo `username/private-repo` and pushed
   - Financial data (CSVs) synced via Syncthing, not git

### Bugs & Issues Found

#### MacBook signing key doesn't work on Mac Mini
- **Symptom**: `git commit` fails with signing error — `~/.gitconfig` (synced via Mackup) contains MacBook's Secretive key (`YOUR_SIGNING_KEY@secretive.local`) which doesn't exist on Mac Mini
- **Fix**: `includeIf` in global gitconfig loads `~/.gitconfig-local` which overrides with Mac Mini's key
- **Why not just edit .gitconfig?**: It's synced via Mackup — changes would propagate to MacBook and break signing there

---

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

- [x] Run removal commands from `mac-mini-package-review.md`
- [x] Install Mac Mini-only apps (alt-tab, bitwarden, busycontacts, etc.)
- [x] Remove `signal` from `~/.mackup.cfg`
- [x] Add `obs`, `sublime-text`, `dash`, `forklift`, `karabiner` to `~/.mackup.cfg`
- [ ] Run `bash scripts/macbook-cleanup-remaining.sh` (steps 6-9 remaining: onedrive, proton-mail, etc.)
- [ ] Run `bash ~/.mackup-sync/Mackup/brew-dump.sh`
- [ ] Install OBSBOT Center manually from obsbot.com
- [ ] Verify Syncthing fully synced
- [ ] Copy updated Brewfile-unified to `~/.mackup-sync/Mackup/`


