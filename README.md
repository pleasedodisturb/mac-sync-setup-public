# Mac Sync Setup

Keep two (or more) Macs perfectly in sync — packages, configs, and app settings — without iCloud or any cloud service. Uses **Syncthing** for LAN file sync, **Mackup** for config symlinks, and **Homebrew** for package management.

> Built for a MacBook + Mac Mini setup, but easily adaptable to any multi-Mac workflow.

## How It Works

```
Mac A <--Syncthing (LAN)--> Mac B
           ~/.mackup-sync/
                └── Mackup/     ← shared config storage
                    ├── .gitconfig
                    ├── .config/fish/
                    ├── Brewfile-unified
                    └── ...
```

**Three tools, one workflow:**

| Tool | What it does | Why |
|------|-------------|-----|
| **Syncthing** | Syncs `~/.mackup-sync/` between Macs over LAN | No cloud, no accounts, works offline, encrypted |
| **Mackup** | Symlinks app configs into the sync folder | You pick exactly which configs to sync |
| **Homebrew + mas** | Installs CLI tools, GUI apps, and Mac App Store apps | One `Brewfile` to reproduce your entire setup |

## Quick Start

### On your first Mac (the one with all your apps)

```bash
# 1. Clone this repo
git clone https://github.com/pleasedodisturb/mac-sync-setup-public.git
cd mac-sync-setup-public

# 2. Install Homebrew (if you haven't)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Install everything from the Brewfile
brew bundle install --file=brewfiles/Brewfile-unified

# 4. Set up Syncthing
brew services start syncthing
mkdir -p ~/.mackup-sync
open http://localhost:8384  # Syncthing web UI

# 5. Set up Mackup
cp mackup/mackup.cfg ~/.mackup.cfg
mkdir -p ~/.mackup && cp mackup/*.cfg ~/.mackup/
mackup backup --force  # push configs into sync folder
```

### On your second Mac

```bash
# 1. Install Homebrew + Syncthing
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install syncthing mackup
brew services start syncthing
mkdir -p ~/.mackup-sync

# 2. Pair with your first Mac via Syncthing web UI (port 8384)
#    Share the ~/.mackup-sync folder, wait for initial sync

# 3. Pull configs from sync folder
cp mackup/mackup.cfg ~/.mackup.cfg
mkdir -p ~/.mackup && cp mackup/*.cfg ~/.mackup/
mackup restore --force

# 4. Install all packages
brew bundle install --file=brewfiles/Brewfile-unified
```

### Validate everything is in sync

```bash
./scripts/validate-sync.sh         # check what's missing
./scripts/validate-sync.sh --fix   # auto-install missing packages
```

## Directory Structure

```
mac-sync-setup/
├── brewfiles/
│   ├── Brewfile-unified          # The canonical package list
│   ├── Brewfile-macbook          # Latest dump from Mac A
│   └── Brewfile-mac-mini         # Latest dump from Mac B
├── mackup/
│   ├── mackup.cfg                # Main Mackup config → ~/.mackup.cfg
│   ├── ai-tools.cfg              # AI tools (Claude, Cursor, etc.)
│   ├── alfred.cfg                # Alfred prefs (not databases)
│   ├── cursor-editor.cfg         # Cursor — 4 config files only
│   └── custom-dotfiles.cfg       # Dotfiles + XDG configs
├── syncthing/
│   └── stignore                  # Keeps caches out of sync
├── scripts/
│   ├── brew-dump.sh              # Dump current packages (auto-detects machine)
│   ├── validate-sync.sh          # Verify everything is installed & linked
│   └── publish-public.sh         # Sanitize & publish to public repo
├── CHANGELOG.md                  # Bugs, fixes, decisions log
└── README.md
```

## The Brewfile

`brewfiles/Brewfile-unified` is the single source of truth. It includes:
- **5 taps** (Homebrew repos)
- **25+ CLI tools** (fish, gh, docker, node, etc.)
- **100 GUI apps** (brew casks)
- **35+ Mac App Store apps** (via `mas`)
- **VS Code extensions**

Run `bash scripts/brew-dump.sh` after adding or removing packages — it auto-detects which machine you're on and saves the dump to the sync folder.

## App Highlights

Here are some of the standout apps in this setup and why they're worth checking out:

### Productivity & Window Management

- **[Alfred](https://www.alfredapp.com/)** — Spotlight on steroids. Custom workflows, clipboard history, snippets. The Powerpack is worth every penny.
- **[Raycast](https://www.raycast.com/)** — Modern Alfred alternative with built-in extensions. Great for quick calculations, window management, and developer tools.
- **[Rectangle Pro](https://rectangleapp.com/pro)** — Window snapping and management. Drag to edges, keyboard shortcuts, custom layouts.
- **[Alt-Tab](https://alt-tab-macos.netlify.app/)** — Windows-style alt-tab with window previews. Free and open source.
- **[Swish](https://highlyopinionated.co/swish/)** — Trackpad gesture window management. Swipe to snap, pinch to minimize. Feels native.
- **[Keyboard Maestro](https://www.keyboardmaestro.com/)** — The ultimate Mac automation tool. If you can describe it, you can automate it.
- **[Karabiner-Elements](https://karabiner-elements.pqrs.org/)** — Remap any key to anything. Essential for custom keyboard layouts and hyper keys.

### Menu Bar & System

- **[Bartender](https://www.macbartender.com/)** — Tame your menu bar. Hide, rearrange, and show icons on demand.
- **[iStat Menus](https://bjango.com/mac/istatmenus/)** — CPU, memory, network, disk, battery stats in your menu bar. Beautiful and detailed.
- **[HazeOver](https://hazeover.com/)** — Dims background windows so you focus on the active one. Subtle but effective.
- **[Amphetamine](https://apps.apple.com/app/amphetamine/id937984704)** — Keep your Mac awake. Per-app rules, scheduled sessions, triggers.
- **[LookAway](https://apps.apple.com/app/lookaway/id6747192301)** — Reminds you to take screen breaks. Uses your camera to detect when you're looking.
- **[Quitter](https://marco.org/2016/05/02/quitter)** — Auto-hides or quits apps after inactivity. Great for keeping Slack/Discord from distracting you.

### Development

- **[Cursor](https://cursor.sh/)** — AI-first code editor (VS Code fork). Inline AI editing, chat, and codebase-aware completions.
- **[Claude Code](https://claude.ai/code)** — Anthropic's CLI coding agent. The tool that built this repo.
- **[Ghostty](https://ghostty.org/)** — Fast, native terminal emulator. GPU-accelerated, zero-config beautiful defaults.
- **[iTerm2](https://iterm2.com/)** — The classic Mac terminal. Split panes, profiles, triggers, shell integration.
- **[Dash](https://kapeli.com/dash)** — Offline documentation browser. Instant search across 200+ API docs.
- **[ForkLift](https://binarynights.com/)** — Dual-pane file manager with SFTP, S3, and cloud storage built in.
- **[Proxyman](https://proxyman.io/)** — Modern HTTP debugging proxy. Beautiful UI, easy SSL setup, great for API work.
- **[Wireshark](https://www.wireshark.org/)** — Network protocol analyzer. When you need to see what's really going on.

### Writing & Notes

- **[Obsidian](https://obsidian.md/)** — Markdown-based knowledge base with backlinks, graph view, and plugins. Local-first.
- **[Sublime Text](https://www.sublimetext.com/)** — Lightning-fast text editor. Perfect for quick edits and large files.
- **[SnippetsLab](https://www.renfei.org/snippets-lab/)** — Code snippet manager with syntax highlighting and iCloud sync.
- **[Soulver](https://soulver.app/)** — Notepad meets calculator. Write natural math expressions and get instant answers.
- **[Calca](https://calca.io/)** — Another great text-based calculator, Markdown-native.

### Privacy & Security

- **[Proton Mail](https://proton.me/mail)** + **[Proton Drive](https://proton.me/drive)** + **[ProtonVPN](https://protonvpn.com/)** — End-to-end encrypted email, storage, and VPN. The whole Proton ecosystem.
- **[Bitwarden](https://bitwarden.com/)** — Open-source password manager. Self-hostable, cross-platform.
- **[Secretive](https://github.com/maxgoedjen/secretive)** — Store SSH keys in the Secure Enclave. Keys never leave the hardware.
- **[Little Snitch](https://www.obdev.at/products/littlesnitch/)** — Network monitor and firewall. See and control every connection your Mac makes.
- **[Standard Notes](https://standardnotes.com/)** — Encrypted, long-lasting notes. Simple and private.

### Media & Creative

- **[Pixelmator Pro](https://www.pixelmator.com/pro/)** — Powerful image editor, native Mac app. Great Photoshop alternative.
- **[Acorn](https://flyingmeat.com/acorn/)** — Another excellent image editor. Lighter than Pixelmator, still very capable.
- **[CleanShot X](https://cleanshot.com/)** — The best screenshot tool for Mac. Annotations, scrolling capture, cloud upload, screen recording.
- **[OBS](https://obsproject.com/)** — Open-source streaming and recording. Professional-quality, completely free.
- **[SoundSource](https://rogueamoeba.com/soundsource/)** — Per-app volume control, EQ, and audio routing. Control exactly what you hear.
- **[MacWhisper](https://goodsnooze.gumroad.com/l/macwhisper)** — Local speech-to-text using OpenAI's Whisper model. Fast, private, accurate.
- **[Superwhisper](https://superwhisper.com/)** — Voice-to-text anywhere on your Mac. Dictate into any app.
- **[VLC](https://www.videolan.org/vlc/)** — Plays anything. The universal media player.

### Utilities

- **[DaisyDisk](https://daisydiskapp.com/)** — Visualize disk usage. Find what's eating your storage in seconds.
- **[GrandPerspective](https://grandperspectiv.sourceforge.net/)** — Another disk visualizer. Free and open source.
- **[Keka](https://www.keka.io/)** — File archiver. Handles every format, clean UI.
- **[TextSniper](https://textsniper.app/)** — OCR anywhere on screen. Select any text in an image and copy it.
- **[ImageOptim](https://imageoptim.com/mac)** — Lossless image compression. Drag, drop, smaller files. Free.
- **[Timing](https://timingapp.com/)** — Automatic time tracking. Knows what you worked on without manual timers.
- **[Transnomino](https://transnomino.bastiaanverreijt.com/)** — Batch file renamer with regex, counters, and date patterns.

## Mackup: What Gets Synced

Mackup works by symlinking config files into `~/.mackup-sync/Mackup/`, which Syncthing keeps in sync across machines.

**Built-in Mackup profiles** (just works):
- Shell configs (bash, zsh, fish, iTerm2, Ghostty)
- Git, GitHub CLI, SSH, Vim, Docker
- Alfred, Keyboard Maestro, CleanShot, iStat Menus, Bartender
- Homebrew, Proxyman, OBS, Sublime Text, Dash, ForkLift, Karabiner

**Custom profiles** (in `mackup/`):
- `ai-tools.cfg` — Claude, Cursor, Codex, Gemini, Aider, Continue (specific config files only, no caches)
- `cursor-editor.cfg` — MCP config, hooks, CLI config, argv
- `custom-dotfiles.cfg` — `.gitallowedsigners`, shell integrations, XDG configs
- `alfred.cfg` — Prefs and history only (not databases or caches)

> **Important:** Never point Mackup at entire directories. Always specify individual files in custom `.cfg` profiles, or you'll sync thousands of cache/runtime files.

## Syncthing Ignore Patterns

The `syncthing/stignore` file keeps junk out of sync:
- Caches, `node_modules`, `.DS_Store`, logs, temp files
- AI tool caches (statsig, telemetry, image-cache, etc.)
- Editor caches (extensions, sessions, browser-logs)
- Databases and large binaries

Copy it to `~/.mackup-sync/.stignore` after setup.

## Scripts

| Script | What it does |
|--------|-------------|
| `brew-dump.sh` | Dumps your current Homebrew packages to a Brewfile. Auto-detects which machine you're on and names the file accordingly. |
| `validate-sync.sh` | Checks that all packages, casks, extensions, configs, and services are properly installed. Use `--fix` to auto-install missing items. |
| `publish-public.sh` | Strips PII and publishes a sanitized copy to the public repo. |

## Adapting This for Your Setup

1. **Fork this repo** and make it your own
2. **Edit `Brewfile-unified`** — remove apps you don't want, add ones you do
3. **Edit `mackup/mackup.cfg`** — pick which apps to sync configs for
4. **Add custom Mackup profiles** in `mackup/` for apps that need specific files synced
5. **Run `validate-sync.sh`** to verify everything installed correctly

### Tips

- Prefer **brew casks** over Mac App Store when both exist — they're trackable in the Brewfile and easier to automate
- Use **`mas`** for apps that are App Store-only
- Keep your Brewfile updated: run `brew-dump.sh` after adding/removing packages
- Test `mackup restore` on one machine before letting it sync to the other
- Machine-specific configs (like git signing keys) should NOT go through Mackup — use git's `includeIf` or a `.local` config file instead

## License

MIT — do whatever you want with it.
