#!/usr/bin/env bash
# talk-like-girlfriend — multi-agent skill installer
#
# One line:
#   curl -fsSL https://raw.githubusercontent.com/n12g/talk-like-girlfriend/main/install.sh | bash
#
# Installs the skill for Claude Code, OpenCode, and Codex
# using each agent's native skill directory.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$REPO_DIR/skills/talk-like-girlfriend"
GITHUB_RAW="https://raw.githubusercontent.com/n12g/talk-like-girlfriend/main"

SKILL_NAME="talk-like-girlfriend"

# ── Color ───────────────────────────────────────────────────────────────────
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

# ── CLI flags ───────────────────────────────────────────────────────────────
FORCE=0
ONLY=""
DRY_RUN=0
UNINSTALL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force|-f) FORCE=1; shift ;;
    --only) ONLY="$2"; shift 2 ;;
    --dry-run|-n) DRY_RUN=1; shift ;;
    --uninstall) UNINSTALL=1; shift ;;
    --help|-h)
      echo "Usage: ./install.sh [--force] [--only <agent>] [--dry-run] [--uninstall]"
      echo ""
      echo "Flags:"
      echo "  --force, -f       Reinstall even if already present"
      echo "  --only <agent>    Target a single agent (claude, opencode, codex)"
      echo "  --dry-run, -n     Preview without making changes"
      echo "  --uninstall       Remove the skill from all detected agents"
      echo "  --help, -h        Show this help"
      echo ""
      echo "One-line uninstall:"
      echo "  curl -fsSL https://raw.githubusercontent.com/n12g/talk-like-girlfriend/main/install.sh | bash -s -- --uninstall"
      exit 0
      ;;
    *) warn "unknown flag: $1"; exit 1 ;;
  esac
done

# ── Helpers ─────────────────────────────────────────────────────────────────
has() { command -v "$1" >/dev/null 2>&1; }

run() {
  if [ "$DRY_RUN" = "1" ]; then
    echo "  [dry-run] $*"
    return 0
  fi
  "$@"
}

download_skill() {
  local dest="$1"
  mkdir -p "$dest"
  curl -fsSL "$GITHUB_RAW/skills/$SKILL_NAME/SKILL.md" -o "$dest/SKILL.md"
}

link_or_copy_skill() {
  local dest="$1"

  if [ -e "$dest" ] && [ "$FORCE" = "0" ]; then
    note "  already installed at $dest (use --force to reinstall)"
    return 0
  fi

  if [ -e "$dest" ]; then
    rm -rf "$dest"
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -d "$SKILL_SRC" ]; then
    # Running from inside the repo — symlink for live updates
    if [ "$DRY_RUN" = "1" ]; then
      echo "  [dry-run] ln -s $SKILL_SRC $dest"
    else
      ln -sfn "$SKILL_SRC" "$dest"
      ok "  symlinked $dest -> $SKILL_SRC"
    fi
  else
    # Running via curl pipe — download from GitHub
    note "  downloading from GitHub..."
    if [ "$DRY_RUN" = "1" ]; then
      echo "  [dry-run] curl $GITHUB_RAW/skills/$SKILL_NAME/SKILL.md -> $dest/SKILL.md"
    else
      download_skill "$dest"
      ok "  downloaded to $dest/SKILL.md"
    fi
  fi
}

# ── Detectors ───────────────────────────────────────────────────────────────
detect_claude() {
  has claude || [ -d "$HOME/.claude" ]
}

detect_opencode() {
  has opencode || [ -d "$HOME/.config/opencode" ] || [ -d "$HOME/.agents" ]
}

detect_codex() {
  has codex
}

# ── Installers ──────────────────────────────────────────────────────────────

install_claude() {
  say "Claude Code detected"
  local dest="$HOME/.claude/skills/$SKILL_NAME"
  link_or_copy_skill "$dest"
}

install_opencode() {
  say "OpenCode detected"
  local skills_root=""

  # Check for existing skills directories
  if [ -d "$HOME/.agents/skills" ]; then
    skills_root="$HOME/.agents/skills"
  elif [ -d "$HOME/.config/opencode/skills" ]; then
    skills_root="$HOME/.config/opencode/skills"
  else
    skills_root="$HOME/.agents/skills"
    mkdir -p "$skills_root"
  fi

  local dest="$skills_root/$SKILL_NAME"
  link_or_copy_skill "$dest"
}

install_codex() {
  say "Codex detected"

  if ! has npx; then
    warn "  npx not found — install Node.js (https://nodejs.org) and re-run"
    return 1
  fi

  note "  installing via npx skills..."
  run npx -y skills add "n12g/$SKILL_NAME"
  ok "  installed via npx skills"
}

# ── Uninstallers ───────────────────────────────────────────────────────────

uninstall_claude() {
  local dest="$HOME/.claude/skills/$SKILL_NAME"
  if [ -e "$dest" ]; then
    if [ "$DRY_RUN" = "1" ]; then
      echo "  [dry-run] rm -rf $dest"
    else
      rm -rf "$dest"
      ok "  removed $dest"
    fi
  else
    note "  not installed at $dest — nothing to do"
  fi
}

uninstall_opencode() {
  local dest
  if [ -d "$HOME/.agents/skills/$SKILL_NAME" ]; then
    dest="$HOME/.agents/skills/$SKILL_NAME"
  elif [ -d "$HOME/.config/opencode/skills/$SKILL_NAME" ]; then
    dest="$HOME/.config/opencode/skills/$SKILL_NAME"
  else
    note "  not installed — nothing to do"
    return 0
  fi

  if [ "$DRY_RUN" = "1" ]; then
    echo "  [dry-run] rm -rf $dest"
  else
    rm -rf "$dest"
    ok "  removed $dest"
  fi
}

uninstall_codex() {
  if ! has npx; then
    note "  npx not found — cannot uninstall via npx skills"
    return 0
  fi

  note "  uninstalling via npx skills..."
  if [ "$DRY_RUN" = "1" ]; then
    echo "  [dry-run] npx skills remove $SKILL_NAME"
  else
    run npx -y skills remove "$SKILL_NAME"
    ok "  removed via npx skills"
  fi
}

uninstall_all() {
  say "talk-like-girlfriend uninstaller"
  echo

  if [ -n "$ONLY" ]; then
    case "$ONLY" in
      claude) uninstall_claude ;;
      opencode) uninstall_opencode ;;
      codex) uninstall_codex ;;
      *) warn "unknown agent: $ONLY (use claude, opencode, or codex)"; exit 1 ;;
    esac
    echo
    say "done"
    exit 0
  fi

  uninstall_claude
  echo
  uninstall_opencode
  echo
  uninstall_codex
  echo

  say "done — talk-like-girlfriend uninstalled"
  note "  .gf_state.json files in individual workspaces must be removed manually"
}

# ── Main ────────────────────────────────────────────────────────────────────

if [ "$UNINSTALL" = "1" ]; then
  uninstall_all
  exit 0
fi
say "talk-like-girlfriend installer"
echo

if [ -n "$ONLY" ]; then
  case "$ONLY" in
    claude) install_claude ;;
    opencode) install_opencode ;;
    codex) install_codex ;;
    *) warn "unknown agent: $ONLY (use claude, opencode, or codex)"; exit 1 ;;
  esac
  echo
  say "done"
  exit 0
fi

INSTALLED=0

if detect_claude; then
  install_claude
  INSTALLED=$((INSTALLED + 1))
  echo
fi

if detect_opencode; then
  install_opencode
  INSTALLED=$((INSTALLED + 1))
  echo
fi

if detect_codex; then
  install_codex
  INSTALLED=$((INSTALLED + 1))
  echo
fi

if [ "$INSTALLED" -eq 0 ]; then
  warn "no supported agent detected"
  warn "  looked for: claude, opencode, codex"
  warn "  try installing manually or use --only <agent>"
  exit 1
fi

say "done"
note "  start any session and say 'talk like my girlfriend' or type /gf"
note "  to uninstall: rm -rf ~/.claude/skills/talk-like-girlfriend ~/.agents/skills/talk-like-girlfriend"
