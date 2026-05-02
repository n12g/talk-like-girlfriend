#!/usr/bin/env bash
# talk-like-girlfriend — smart multi-agent installer
#
# One line:
#   curl -fsSL https://raw.githubusercontent.com/n12g/talk-like-girlfriend/main/install.sh | bash
#
# Detects which AI coding agents are on your machine and installs
# talk-like-girlfriend for each one using its native distribution.

set -euo pipefail

# ── Constants ──────────────────────────────────────────────────────────────
REPO="n12g/talk-like-girlfriend"

# ── Color setup ────────────────────────────────────────────────────────────
NO_COLOR=${NO_COLOR:-0}
if [ ! -t 1 ]; then NO_COLOR=1; fi

if [ "$NO_COLOR" = "1" ]; then
  c_pink=""; c_dim=""; c_red=""; c_green=""; c_reset=""
else
  c_pink=$'\033[38;5;205m'
  c_dim=$'\033[2m'
  c_red=$'\033[31m'
  c_green=$'\033[32m'
  c_reset=$'\033[0m'
fi

say()  { printf '%s%s%s\n' "$c_pink" "$1" "$c_reset"; }
note() { printf '%s%s%s\n' "$c_dim" "$1" "$c_reset"; }
warn() { printf '%s%s%s\n' "$c_red" "$1" "$c_reset" >&2; }
ok()   { printf '%s%s%s\n' "$c_green" "$1" "$c_reset"; }

# ── Helpers ────────────────────────────────────────────────────────────────
has() { command -v "$1" >/dev/null 2>&1; }

run() {
  echo "  $ $*"
  "$@"
}

# ── Agent detection ────────────────────────────────────────────────────────
detect_opencode() {
  has opencode || [ -d "$HOME/.config/opencode" ] || [ -f "$HOME/.config/opencode/AGENTS.md" ]
}

detect_claude() {
  has claude
}

detect_codex() {
  has codex
}

# ── Install functions ──────────────────────────────────────────────────────
install_opencode() {
  say "→ OpenCode detected"
  
  local skills_dir=""
  if [ -d "$HOME/.agents/skills" ]; then
    skills_dir="$HOME/.agents/skills"
  elif [ -d "$HOME/.config/opencode/skills" ]; then
    skills_dir="$HOME/.config/opencode/skills"
  else
    skills_dir="$HOME/.agents/skills"
    mkdir -p "$skills_dir"
  fi
  
  local target_dir="$skills_dir/talk-like-girlfriend"
  
  if [ -d "$target_dir" ]; then
    note "  talk-like-girlfriend already installed at $target_dir"
    note "  (delete it and re-run to reinstall)"
    return 0
  fi
  
  mkdir -p "$target_dir"
  
  if [ -f "SKILL.md" ]; then
    cp "SKILL.md" "$target_dir/"
    ok "  installed from local SKILL.md"
  else
    note "  downloading from GitHub..."
    curl -fsSL "https://raw.githubusercontent.com/$REPO/main/SKILL.md" -o "$target_dir/SKILL.md"
    ok "  downloaded and installed"
  fi
  
  note "  location: $target_dir/SKILL.md"
}

install_claude() {
  say "→ Claude Code detected"
  
  if ! has claude; then
    warn "  claude CLI not found on PATH"
    return 1
  fi
  
  note "  installing via Claude plugin marketplace..."
  
  if claude plugin list 2>/dev/null | grep -qi "talk-like-girlfriend"; then
    note "  talk-like-girlfriend plugin already installed"
    return 0
  fi
  
  if run claude plugin marketplace add "$REPO"; then
    if run claude plugin install "talk-like-girlfriend@talk-like-girlfriend"; then
      ok "  installed successfully"
    else
      warn "  plugin install failed"
      return 1
    fi
  else
    warn "  marketplace add failed"
    return 1
  fi
}

install_codex() {
  say "→ Codex CLI detected"
  
  if ! has npx; then
    warn "  npx not found — install Node.js (https://nodejs.org) and re-run"
    return 1
  fi
  
  note "  installing via npx skills..."
  
  if run npx -y skills add "$REPO" -a codex; then
    ok "  installed successfully"
  else
    warn "  npx skills add failed"
    return 1
  fi
}

install_generic_skills() {
  say "→ no specific agents detected — trying generic npx skills installer"
  
  if ! has npx; then
    warn "  npx not found — install Node.js (https://nodejs.org) and re-run"
    return 1
  fi
  
  note "  this will auto-detect your agent..."
  
  if run npx -y skills add "$REPO"; then
    ok "  installed successfully"
  else
    warn "  npx skills add failed"
    return 1
  fi
}

# ── Main ───────────────────────────────────────────────────────────────────
say "💕 talk-like-girlfriend installer"
note "  $REPO"
echo

INSTALLED=0

if detect_opencode; then
  install_opencode
  INSTALLED=$((INSTALLED + 1))
  echo
fi

if detect_claude; then
  install_claude
  INSTALLED=$((INSTALLED + 1))
  echo
fi

if detect_codex; then
  install_codex
  INSTALLED=$((INSTALLED + 1))
  echo
fi

if [ "$INSTALLED" -eq 0 ]; then
  install_generic_skills
  echo
fi

say "💕 done"
note "  start any session and say 'talk like my girlfriend' or type /gf"
note "  uninstall: see https://github.com/$REPO#installation"
