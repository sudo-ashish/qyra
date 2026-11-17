#!/usr/bin/env bash
# ==============================================================================
# Qyra Desktop Environment - Idempotent, Non-Destructive Bootstrapper
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODE="local"
DRY_RUN=false
DO_UNINSTALL=false

usage() {
  cat <<'EOF'
Usage: ./install.sh [OPTIONS]

Qyra: Standalone Arch Linux + Hyprland (Lua) + Quickshell Desktop Environment

Options:
  --local          Install Tier 1 into ~/.local/share/qyra/ (Default for git clone)
  --system         Configure user-space files for system package (/usr/share/qyra/)
  --uninstall      Cleanly remove Tier 1 and restore pre-installation hypr backup
  --dry-run        Print all filesystem operations without executing them
  -h, --help       Show this help message and exit

Architectural Layout:
  Tier 1 (Core):   ~/.local/share/qyra/ or /usr/share/qyra/ (Immutable)
  Tier 2 (State):  ~/.local/state/qyra/state.json (Managed by Quickshell)
  Tier 3 (User):   ~/.config/hypr/, ~/.config/qyra/, ~/.config/themes/ (User Sandbox)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --local) MODE="local"; shift ;;
    --system) MODE="system"; shift ;;
    --uninstall) DO_UNINSTALL=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Error: Unknown argument '$1'." >&2; usage; exit 1 ;;
  esac
done

run_cmd() {
  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN] $*"
  else
    "$@"
  fi
}

# ------------------------------------------------------------------------------
# UNINSTALLATION FLOW
# ------------------------------------------------------------------------------
if [[ "$DO_UNINSTALL" == true ]]; then
  echo "==> Uninstalling Qyra Desktop Environment..."

  if [[ -d "$HOME/.local/share/qyra" ]]; then
    echo "  • Removing Tier 1 core: ~/.local/share/qyra"
    run_cmd rm -rf "$HOME/.local/share/qyra"
  fi

  echo "  • Removing helper symlinks in ~/.local/bin"
  run_cmd rm -f "$HOME/.local/bin/qyractl" "$HOME/.local/bin/qyra-theme-gen"

  # Restore most recent backup if available
  LATEST_BAK="$(find "$HOME/.config" -maxdepth 1 -name "hypr.bak.*" -type d 2>/dev/null | sort -r | head -n1 || true)"
  if [[ -n "$LATEST_BAK" && -d "$LATEST_BAK" ]]; then
    echo "  • Restoring pre-installation backup: $LATEST_BAK -> ~/.config/hypr"
    run_cmd rm -rf "$HOME/.config/hypr"
    run_cmd mv "$LATEST_BAK" "$HOME/.config/hypr"
  fi

  echo "==> Qyra uninstalled successfully. (Themes & state snapshots were preserved)"
  exit 0
fi

# ------------------------------------------------------------------------------
# STEP 1: SAFETY PRE-FLIGHT & BACKUP
# ------------------------------------------------------------------------------
echo "=========================================================================="
echo "  Qyra Desktop Environment — Bootstrap ($MODE mode)"
echo "=========================================================================="

HYPR_CONFIG_DIR="$HOME/.config/hypr"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

if [[ -d "$HYPR_CONFIG_DIR" ]]; then
  # Check if existing hypr is already Qyra-managed
  if ! grep -q "core_init" "$HYPR_CONFIG_DIR/hyprland.lua" 2>/dev/null; then
    BACKUP_DIR="$HOME/.config/hypr.bak.$TIMESTAMP"
    echo "==> Non-Qyra ~/.config/hypr detected. Creating full backup at:"
    echo "    $BACKUP_DIR"
    run_cmd cp -a "$HYPR_CONFIG_DIR" "$BACKUP_DIR"
  else
    echo "==> Existing Qyra configuration detected in ~/.config/hypr."
  fi
fi

# ------------------------------------------------------------------------------
# STEP 2: TIER 1 CORE DEPLOYMENT
# ------------------------------------------------------------------------------
if [[ "$MODE" == "local" ]]; then
  TIER1_TARGET="$HOME/.local/share/qyra"
  echo "==> Deploying Tier 1 Immutable Core to $TIER1_TARGET..."
  run_cmd mkdir -p "$TIER1_TARGET" "$HOME/.local/bin"

  run_cmd cp -a "$SCRIPT_DIR/shell" "$TIER1_TARGET/"
  run_cmd cp -a "$SCRIPT_DIR/hypr" "$TIER1_TARGET/"
  run_cmd cp -a "$SCRIPT_DIR/defaults" "$TIER1_TARGET/"
  run_cmd cp -a "$SCRIPT_DIR/bin" "$TIER1_TARGET/"
  [[ -f "$SCRIPT_DIR/VERSION" ]] && run_cmd cp -a "$SCRIPT_DIR/VERSION" "$TIER1_TARGET/"

  run_cmd chmod +x "$TIER1_TARGET/bin/qyractl" "$TIER1_TARGET/bin/qyra-theme-gen"
  run_cmd ln -sfn "$TIER1_TARGET/bin/qyractl" "$HOME/.local/bin/qyractl"
  run_cmd ln -sfn "$TIER1_TARGET/bin/qyra-theme-gen" "$HOME/.local/bin/qyra-theme-gen"
  THEME_GEN_BIN="$TIER1_TARGET/bin/qyra-theme-gen"
else
  TIER1_TARGET="/usr/share/qyra"
  echo "==> Using system-installed Tier 1 Core at $TIER1_TARGET..."
  THEME_GEN_BIN="/usr/bin/qyra-theme-gen"
fi

# ------------------------------------------------------------------------------
# STEP 3: TIER 2 STATE INITIALIZATION
# ------------------------------------------------------------------------------
STATE_DIR="$HOME/.local/state/qyra"
SNAPSHOTS_DIR="$STATE_DIR/snapshots"
STATE_FILE="$STATE_DIR/state.json"

echo "==> Initializing Tier 2 Machine State in $STATE_DIR..."
run_cmd mkdir -p "$SNAPSHOTS_DIR"

if [[ ! -f "$STATE_FILE" ]]; then
  echo "  • Seeding initial state.json from defaults/config.json"
  run_cmd cp "$SCRIPT_DIR/defaults/config.json" "$STATE_FILE"
else
  echo "  • Existing state.json preserved (non-destructive guarantee)."
fi

# ------------------------------------------------------------------------------
# STEP 4: TIER 3 USER SANDBOX INITIALIZATION
# ------------------------------------------------------------------------------
echo "==> Initializing Tier 3 User Sandbox (~/.config)..."
run_cmd mkdir -p "$HOME/.config/hypr" "$HOME/.config/qyra" "$HOME/.config/themes"

# 4a. Minimal Non-Crashing Hyprland Loader
LOADER_FILE="$HOME/.config/hypr/hyprland.lua"
echo "  • Deploying entrypoint loader: $LOADER_FILE"
run_cmd cp "$SCRIPT_DIR/defaults/hyprland.lua" "$LOADER_FILE"

# 4b. User Sandbox Overrides
CUSTOM_LUA="$HOME/.config/hypr/custom.lua"
if [[ ! -f "$CUSTOM_LUA" ]]; then
  echo "  • Deploying starter ~/.config/hypr/custom.lua"
  run_cmd cp "$SCRIPT_DIR/defaults/custom.lua" "$CUSTOM_LUA"
fi

CUSTOM_JSON="$HOME/.config/qyra/custom.json"
if [[ ! -f "$CUSTOM_JSON" ]]; then
  echo "  • Deploying starter ~/.config/qyra/custom.json"
  run_cmd cp "$SCRIPT_DIR/defaults/custom.json" "$CUSTOM_JSON"
fi

HYPRLOCK_CONF="$HOME/.config/hypr/hyprlock.conf"
if [[ ! -f "$HYPRLOCK_CONF" ]]; then
  echo "  • Deploying ~/.config/hypr/hyprlock.conf"
  run_cmd cp "$SCRIPT_DIR/hypr/hyprlock.conf" "$HYPRLOCK_CONF"
fi

# 4c. Themes Deployment
echo "  • Deploying bundled starter theme presets..."
if [[ -d "$SCRIPT_DIR/defaults/themes" ]]; then
  for theme_dir in "$SCRIPT_DIR"/defaults/themes/*; do
    if [[ -d "$theme_dir" ]]; then
      theme_name="$(basename "$theme_dir")"
      dest_theme="$HOME/.config/themes/$theme_name"
      if [[ ! -d "$dest_theme" ]]; then
        run_cmd cp -r "$theme_dir" "$dest_theme"
        if [[ -x "$THEME_GEN_BIN" ]]; then
          run_cmd "$THEME_GEN_BIN" "$dest_theme" 2>/dev/null || true
        fi
      fi
    fi
  done
fi

# Set active theme symlink if unset
if [[ ! -L "$HOME/.config/themes/current" && ! -e "$HOME/.config/themes/current" ]]; then
  echo "  • Symlinking active theme -> ~/.config/themes/gruvbox-dark"
  run_cmd ln -sfn "$HOME/.config/themes/gruvbox-dark" "$HOME/.config/themes/current"
fi

# 4d. Kitty Terminal Configuration
KITTY_DIR="$HOME/.config/kitty"
echo "  • Configuring Kitty terminal with dynamic theme support..."
run_cmd mkdir -p "$KITTY_DIR"
if [[ ! -f "$KITTY_DIR/kitty.conf" && -f "$SCRIPT_DIR/defaults/kitty.conf" ]]; then
  echo "  • Deploying starter ~/.config/kitty/kitty.conf"
  run_cmd cp "$SCRIPT_DIR/defaults/kitty.conf" "$KITTY_DIR/kitty.conf"
fi

if [[ ! -L "$KITTY_DIR/color.conf" && ! -f "$KITTY_DIR/color.conf" ]]; then
  echo "  • Symlinking active theme color.conf -> ~/.config/kitty/color.conf"
  run_cmd ln -sfn "$HOME/.config/themes/current/color.conf" "$KITTY_DIR/color.conf"
fi

# ------------------------------------------------------------------------------
# STEP 5: VERIFICATION & COMPLETION
# ------------------------------------------------------------------------------
echo ""
echo "=========================================================================="
echo "  ✓ Qyra Desktop Environment Successfully Configured!"
echo "=========================================================================="
echo "  • Tier 1 Core:     $TIER1_TARGET"
echo "  • Tier 2 State:    $STATE_FILE"
echo "  • Tier 3 Hyprland: $LOADER_FILE"
echo "  • User Overrides:  ~/.config/hypr/custom.lua & ~/.config/qyra/custom.json"
echo "  • Themes:          ~/.config/themes/ (active: ~/.config/themes/current)"
echo "  • CLI Bridge:      qyractl (settings, config, theme, snapshot, osd)"
echo ""
if [[ "$MODE" == "local" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo "  [Notice] Please ensure ~/.local/bin is in your PATH."
fi
echo "  Launch Hyprland to start your Qyra session!"
echo "=========================================================================="
exit 0
