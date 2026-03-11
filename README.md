# dotcastle

**Your configs are your castle. Guard them well.**

Keep two (or more) Macs perfectly in sync — packages, configs, and app settings — without iCloud or any cloud service touching your stuff. Zero accounts. Zero trust. Just your machines talking directly to each other over LAN.

---

## The Problem

You have a MacBook and a Mac Mini. You install an app on one, tweak a config on the other, and within a week they've drifted apart like two ships in the night. You SSH into your Mini and nothing feels right. Your shell aliases are missing. Your Git config is different. That one VS Code extension you need? Not here.

iCloud sync is a black box that corrupts things. Dropbox wants $12/month. Google Drive indexes your SSH keys. And rsync scripts feel like defusing a bomb every time you run them.

dotcastle fixes this with three boring, reliable, open-source tools — and zero cloud services in between.

## How It Works

```
MacBook  <── Syncthing (LAN, encrypted) ──>  Mac Mini
                 ~/.mackup-sync/
                      └── Mackup/
                          ├── .gitconfig
                          ├── .config/ghostty/
                          ├── .config/fish/
                          ├── Brewfile-unified
                          └── ...everything that matters
```

**Three tools. One workflow. Zero cloud.**

| Tool | Job | Why this one |
|------|-----|-------------|
| **[Syncthing](https://syncthing.net/)** | Syncs `~/.mackup-sync/` between Macs | No cloud, no accounts, encrypted, works offline, peer-to-peer. Your files never leave your network. |
| **[Mackup](https://github.com/lra/mackup)** | Symlinks app configs into the sync folder | You pick exactly which configs to sync. Surgical precision, not a sledgehammer. |
| **[Homebrew](https://brew.sh/) + [mas](https://github.com/mas-cli/mas)** | Installs CLI tools, GUI apps, Mac App Store apps | One `Brewfile` reproduces your entire software stack. |

The magic: change a config on Machine A, Syncthing pushes it to Machine B in seconds. Mackup's symlinks mean the apps on Machine B pick it up immediately. No restart, no manual copy, no "did I remember to sync?"

## Quick Start

### Machine A (the one with all your stuff)

```bash
git clone https://github.com/pleasedodisturb/dotcastle.git
cd dotcastle

# Install everything from the Brewfile
brew bundle install --file=brewfiles/Brewfile-unified

# Start Syncthing
brew services start syncthing
mkdir -p ~/.mackup-sync
open http://localhost:8384  # pair with Machine B here

# Push your configs into the sync folder
cp mackup/mackup.cfg ~/.mackup.cfg
mkdir -p ~/.mackup && cp mackup/*.cfg ~/.mackup/
mackup backup --force
```

### Machine B (the fresh/second Mac)

```bash
brew install syncthing mackup
brew services start syncthing
mkdir -p ~/.mackup-sync

# Pair with Machine A via Syncthing web UI (port 8384)
# Share ~/.mackup-sync, wait for initial sync, then:

cp mackup/mackup.cfg ~/.mackup.cfg
mkdir -p ~/.mackup && cp mackup/*.cfg ~/.mackup/
mackup restore --force

# Install all packages
brew bundle install --file=brewfiles/Brewfile-unified
```

### Verify everything

```bash
./scripts/validate-sync.sh         # see what's missing
./scripts/validate-sync.sh --fix   # auto-install missing packages
```

## What's Inside

```
dotcastle/
├── brewfiles/
│   ├── Brewfile-unified          # The canonical package list (source of truth)
│   ├── Brewfile-macbook          # Latest dump from MacBook
│   └── Brewfile-mac-mini         # Latest dump from Mac Mini
├── mackup/
│   ├── mackup.cfg                # Main Mackup config → ~/.mackup.cfg
│   ├── ai-tools.cfg              # Claude, Cursor, Codex configs
│   ├── alfred.cfg                # Alfred prefs (not databases/caches)
│   ├── cursor-editor.cfg         # Cursor MCP, hooks, CLI config
│   └── custom-dotfiles.cfg       # Dotfiles + XDG configs
├── syncthing/
│   └── stignore                  # Keeps caches/junk out of sync
├── scripts/
│   ├── brew-dump.sh              # Dump packages (auto-detects machine)
│   ├── validate-sync.sh          # Verify everything is installed & linked
│   └── publish-public.sh         # Sanitize & publish to public repo
├── CHANGELOG.md                  # Decisions, bugs, fixes log
├── LICENSE                       # MIT
└── README.md                     # You are here
```

## The Brewfile

`brewfiles/Brewfile-unified` is the single source of truth. One file, both machines:

- **5 taps** (Homebrew repos)
- **25+ CLI tools** (zsh, gh, docker, node, tmux, starship, fzf, bat...)
- **100 GUI apps** (brew casks)
- **35+ Mac App Store apps** (via `mas`)
- **VS Code extensions**

After adding or removing packages, run:
```bash
bash scripts/brew-dump.sh
```
It auto-detects which machine you're on and saves the dump.

## What Gets Synced (Mackup)

Mackup symlinks config files into `~/.mackup-sync/Mackup/`, which Syncthing keeps in sync.

**Built-in profiles** (just list them in `mackup.cfg`):
Shell (zsh, fish, bash), Git, GitHub CLI, SSH, Vim, Docker, Alfred, Keyboard Maestro, CleanShot, iStat Menus, Homebrew, Proxyman, OBS, Sublime Text, Dash, ForkLift, Karabiner, Ghostty, iTerm2

**Custom profiles** (in `mackup/`):
- `ai-tools.cfg` — Claude Code, Cursor, Codex, Gemini, Aider (specific config files, no caches)
- `cursor-editor.cfg` — MCP config, hooks, CLI config, argv
- `custom-dotfiles.cfg` — `.gitallowedsigners`, shell integrations, XDG configs
- `alfred.cfg` — prefs and history only (not databases)

> **Rule:** Never point Mackup at entire directories. Always specify individual files, or you'll sync thousands of cache files and regret everything.

## Syncthing Ignore Patterns

The `syncthing/stignore` keeps the sync folder clean:

- `.DS_Store`, `node_modules`, logs, temp files
- AI tool caches (statsig, telemetry, image-cache)
- Editor caches (extensions, sessions, browser-logs)
- Databases and large binaries

Copy it after setup: `cp syncthing/stignore ~/.mackup-sync/.stignore`

## Scripts

| Script | What it does |
|--------|-------------|
| `brew-dump.sh` | Dumps current Homebrew packages. Auto-detects machine, names file accordingly. |
| `validate-sync.sh` | Checks packages, casks, extensions, configs, services. `--fix` to auto-install missing. |
| `publish-public.sh` | Strips PII and publishes sanitized copy to the public repo. |

## Adapting This for Your Setup

1. **Fork it** — make it your castle
2. **Edit `Brewfile-unified`** — your apps, your rules
3. **Edit `mackup/mackup.cfg`** — pick which configs to sync
4. **Add custom `.cfg` profiles** for apps that need specific files
5. **Run `validate-sync.sh`** — verify everything works

### Tips

- **Brew casks over Mac App Store** when both exist — they're trackable in the Brewfile
- **`mas`** for App Store-only apps
- **Machine-specific configs** (git signing keys, local paths) should NOT go through Mackup — use `includeIf` or `.local` override files
- **Test `mackup restore` on one machine** before syncing changes to the other
- **Git repos sync via GitHub**, not Syncthing — never mix the two

## The Bigger Picture

dotcastle is the plumbing. **[macOS-nirvana](https://github.com/pleasedodisturb/macOS-nirvana)** is the blueprint — the opinionated guide to *which* apps to install and *why*. Together:

- **macOS-nirvana** tells you what to install
- **dotcastle** keeps it all in sync

## How This Was Made

Built in a series of sessions with [Claude Code](https://claude.com/claude-code) — Anthropic's AI coding assistant. The human debugged the edge cases. The AI wrote the scripts. The configs got synced. Nobody's Mac drifted apart again.

## License

[MIT](./LICENSE) — build your own castle.

---

*"A man's home is his castle, and his castle's configs should follow him everywhere."* — nobody, until now
