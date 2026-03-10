#!/usr/bin/env bash
# =============================================================================
# validate-sync.sh — Verify mac-sync-setup is fully applied
#
# Checks: Homebrew packages, casks, VS Code extensions, Mackup symlinks,
#          Syncthing status, shell config, and key services.
#
# Usage: ./scripts/validate-sync.sh [--fix]
#   --fix   Attempt to install missing brew packages/casks automatically
# =============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BREWFILE="$REPO_DIR/brewfiles/Brewfile-unified"
MACKUP_CFG="$REPO_DIR/mackup/mackup.cfg"
FIX_MODE=false

[[ "${1:-}" == "--fix" ]] && FIX_MODE=true

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

pass=0
fail=0
warn=0

ok()   { ((pass++)); echo -e "  ${GREEN}[OK]${NC} $1"; }
fail() { ((fail++)); echo -e "  ${RED}[MISSING]${NC} $1"; }
warn() { ((warn++)); echo -e "  ${YELLOW}[WARN]${NC} $1"; }
info() { echo -e "  ${CYAN}[INFO]${NC} $1"; }
section() { echo -e "\n${BOLD}=== $1 ===${NC}"; }

# Track missing for --fix
missing_brews=()
missing_casks=()
missing_extensions=()

# ─── Homebrew itself ─────────────────────────────────────────────────────────
section "Homebrew"
if command -v brew &>/dev/null; then
    ok "Homebrew installed ($(brew --version | head -1))"
else
    fail "Homebrew not installed"
    echo "  Install: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo -e "\n${RED}Cannot continue without Homebrew.${NC}"
    exit 1
fi

# ─── CLI Tools (brew) ────────────────────────────────────────────────────────
section "CLI Tools (brew)"
installed_brews=$(brew list --formula 2>/dev/null)
while IFS= read -r line; do
    pkg=$(echo "$line" | sed -n 's/^brew "\(.*\)"/\1/p')
    [[ -z "$pkg" ]] && continue
    # For tap/package format, check just the package name
    check_name="${pkg##*/}"
    if echo "$installed_brews" | grep -qx "$check_name"; then
        ok "$pkg"
    else
        fail "$pkg"
        missing_brews+=("$pkg")
    fi
done < "$BREWFILE"

# ─── GUI Apps (cask) ─────────────────────────────────────────────────────────
section "GUI Apps (cask)"
installed_casks=$(brew list --cask 2>/dev/null)
while IFS= read -r line; do
    pkg=$(echo "$line" | sed -n 's/^cask "\(.*\)"/\1/p')
    [[ -z "$pkg" ]] && continue
    if echo "$installed_casks" | grep -qx "$pkg"; then
        ok "$pkg"
    else
        # Some casks install as .app but aren't tracked by brew (manual installs)
        # Try to find the app by common name patterns
        app_name=$(echo "$pkg" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
        if ls /Applications/"$app_name"* &>/dev/null 2>&1; then
            warn "$pkg (installed outside Homebrew)"
        else
            fail "$pkg"
            missing_casks+=("$pkg")
        fi
    fi
done < "$BREWFILE"

# ─── VS Code Extensions ─────────────────────────────────────────────────────
section "VS Code Extensions"
if command -v code &>/dev/null; then
    installed_extensions=$(code --list-extensions 2>/dev/null)
    while IFS= read -r line; do
        ext=$(echo "$line" | sed -n 's/^vscode "\(.*\)"/\1/p')
        [[ -z "$ext" ]] && continue
        if echo "$installed_extensions" | grep -qix "$ext"; then
            ok "$ext"
        else
            fail "$ext"
            missing_extensions+=("$ext")
        fi
    done < "$BREWFILE"
else
    warn "VS Code CLI (code) not in PATH — skipping extension check"
fi

# ─── Shell Configuration ────────────────────────────────────────────────────
section "Shell Configuration"

# Fish
if command -v fish &>/dev/null; then
    ok "fish installed ($(fish --version 2>&1))"
else
    fail "fish not installed"
fi

if grep -q '/opt/homebrew/bin/fish' /etc/shells 2>/dev/null; then
    ok "fish in /etc/shells"
else
    fail "fish NOT in /etc/shells — run: echo '/opt/homebrew/bin/fish' | sudo tee -a /etc/shells"
fi

current_shell=$(dscl . -read /Users/"$USER" UserShell 2>/dev/null | awk '{print $2}')
if [[ "$current_shell" == *"fish"* ]]; then
    ok "Default shell is fish ($current_shell)"
else
    warn "Default shell is $current_shell (not fish) — run: chsh -s /opt/homebrew/bin/fish"
fi

# Check for dead conda references in fish config
fish_config="$HOME/.config/fish/config.fish"
if [[ -f "$fish_config" ]]; then
    if grep -q "conda" "$fish_config" 2>/dev/null; then
        fail "Fish config still references conda — clean it up"
    else
        ok "Fish config clean (no conda references)"
    fi
fi

# ─── Mackup & Sync ──────────────────────────────────────────────────────────
section "Mackup & Syncthing"

# Mackup installed
if command -v mackup &>/dev/null; then
    ok "mackup installed"
else
    fail "mackup not installed"
fi

# Mackup config symlink or file
mackup_home="$HOME/.mackup.cfg"
if [[ -f "$mackup_home" ]] || [[ -L "$mackup_home" ]]; then
    ok "~/.mackup.cfg exists"
else
    fail "~/.mackup.cfg missing — run: mackup restore"
fi

# Sync directory
sync_dir="$HOME/.mackup-sync/Mackup"
if [[ -d "$sync_dir" ]]; then
    file_count=$(find "$sync_dir" -type f 2>/dev/null | wc -l | tr -d ' ')
    ok "Sync directory exists ($file_count files in $sync_dir)"
else
    fail "Sync directory $sync_dir not found — is Syncthing running?"
fi

# Syncthing
if pgrep -x syncthing &>/dev/null; then
    ok "Syncthing process running"
else
    warn "Syncthing not running (may be managed by launchd)"
    if launchctl list 2>/dev/null | grep -q syncthing; then
        ok "Syncthing registered in launchd"
    fi
fi

# ─── Key Services & Tools ───────────────────────────────────────────────────
section "Key Services"

# Git SSH signing
if git config --global user.signingkey &>/dev/null; then
    ok "Git signing key configured"
else
    warn "Git signing key not configured"
fi

if git config --global gpg.format 2>/dev/null | grep -q ssh; then
    ok "Git using SSH signing format"
else
    warn "Git not using SSH signing format"
fi

# Secretive SSH agent
secretive_sock="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
if [[ -S "$secretive_sock" ]]; then
    ok "Secretive SSH agent socket exists"
else
    warn "Secretive SSH agent socket not found"
fi

# gh CLI auth
if gh auth status &>/dev/null 2>&1; then
    ok "GitHub CLI authenticated"
else
    warn "GitHub CLI not authenticated — run: gh auth login"
fi

# Docker
if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
    ok "Docker running"
else
    warn "Docker not running or not installed"
fi

# ─── Anaconda Cleanup ────────────────────────────────────────────────────────
section "Anaconda Cleanup"
anaconda_remnants=()
[[ -d /opt/homebrew/anaconda3 ]] && anaconda_remnants+=("/opt/homebrew/anaconda3")
[[ -d "$HOME/anaconda3" ]] && anaconda_remnants+=("$HOME/anaconda3")
[[ -d "$HOME/.conda" ]] && anaconda_remnants+=("$HOME/.conda")
[[ -f "$HOME/.condarc" ]] && anaconda_remnants+=("$HOME/.condarc")

# Check shell configs for conda references
for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.config/fish/config.fish"; do
    if [[ -f "$rc" ]] && grep -q "conda" "$rc" 2>/dev/null; then
        anaconda_remnants+=("$rc (has conda references)")
    fi
done

if [[ ${#anaconda_remnants[@]} -eq 0 ]]; then
    ok "No anaconda remnants found"
else
    for remnant in "${anaconda_remnants[@]}"; do
        fail "Anaconda remnant: $remnant"
    done
fi

# ─── --fix mode ──────────────────────────────────────────────────────────────
if $FIX_MODE; then
    section "Auto-Fix"
    if [[ ${#missing_brews[@]} -gt 0 ]]; then
        echo -e "  Installing ${#missing_brews[@]} missing CLI tools..."
        for pkg in "${missing_brews[@]}"; do
            echo -e "  ${CYAN}brew install $pkg${NC}"
            brew install "$pkg" 2>&1 | tail -1 || true
        done
    fi
    if [[ ${#missing_casks[@]} -gt 0 ]]; then
        echo -e "  Installing ${#missing_casks[@]} missing casks..."
        for pkg in "${missing_casks[@]}"; do
            echo -e "  ${CYAN}brew install --cask $pkg${NC}"
            brew install --cask "$pkg" 2>&1 | tail -1 || true
        done
    fi
    if [[ ${#missing_extensions[@]} -gt 0 ]] && command -v code &>/dev/null; then
        echo -e "  Installing ${#missing_extensions[@]} missing VS Code extensions..."
        for ext in "${missing_extensions[@]}"; do
            echo -e "  ${CYAN}code --install-extension $ext${NC}"
            code --install-extension "$ext" 2>&1 | tail -1 || true
        done
    fi
    if [[ ${#missing_brews[@]} -eq 0 && ${#missing_casks[@]} -eq 0 && ${#missing_extensions[@]} -eq 0 ]]; then
        info "Nothing to fix — everything is in sync"
    fi
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
section "Summary"
total=$((pass + fail + warn))
echo -e "  ${GREEN}$pass passed${NC}  ${RED}$fail failed${NC}  ${YELLOW}$warn warnings${NC}  (${total} checks)"

if [[ $fail -gt 0 ]]; then
    echo -e "\n  Run ${BOLD}./scripts/validate-sync.sh --fix${NC} to auto-install missing brew packages."
    exit 1
elif [[ $warn -gt 0 ]]; then
    echo -e "\n  ${YELLOW}Some warnings — review above.${NC}"
    exit 0
else
    echo -e "\n  ${GREEN}Everything is in sync!${NC}"
    exit 0
fi
