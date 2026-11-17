# Qyra Desktop Environment

> **A standalone, modular, schema-driven Arch Linux desktop environment powered by Hyprland (Lua API) and Quickshell (Native C++/QML).**

---

## Highlights

- **Pure Hyprland Lua Configuration**: No deprecated `.conf` hyprlang files (except `hyprlock.conf`). Configured via the `hl.*` Lua API with failsafe boot loading.
- **Native-Only Quickshell Runtime**: Zero CLI wrapper polling (`nmcli`, `pactl`, `upower`, `playerctl` strictly forbidden). Integrates directly with native C++ services for PipeWire, NetworkManager, BlueZ, UPower, MPRIS, System Tray, and Hyprland IPC.
- **Dual-Mode Bar Parity**: Hot-swap between **FullBar** (edge-anchored panel) and **IslandBar** (centered dynamic floating pill with smooth width expansion) via IPC or settings with 0 ms reload stutter.
- **3-Tier Non-Destructive Architecture**:
  - **Tier 1 (Immutable Core)**: `~/.local/share/qyra/` or `/usr/share/qyra/`
  - **Tier 2 (Machine State)**: `~/.local/state/qyra/state.json` (Quickshell atomic JSON adapter)
  - **Tier 3 (User Sandbox)**: `~/.config/hypr/custom.lua`, `~/.config/qyra/custom.json`, `~/.config/themes/`
- **Schema-Driven Settings App**: Reusable control widgets generated dynamically from `Schema.qml`, with per-setting modified indicators and 1-click reset to default.
- **Instant Live Hyprland Sync**: Modifying settings in the UI or via CLI updates Hyprland live via a debounced (20ms) `hl.config()` call without restarting or stuttering.
- **Non-Destructive Updater & Snapshot Manager**: Automatic `last-good.json` self-healing on corrupted configs and timestamped pre-update milestones.

---

## Architecture: The 3-Tier Split

```text
┌────────────────────────────────────────────────────────────────────────┐
│ TIER 3: USER SANDBOX (~/.config/)                                      │
│  ├── hypr/hyprland.lua       (Minimal 5-line loader; calls Tier 1)     │
│  ├── hypr/custom.lua         (Personal keybinds, monitors & rules)     │
│  ├── qyra/custom.json        (Sparse JSON overrides; never clobbered)  │
│  └── themes/<name>/          (Custom color palettes and wallpapers)    │
└────────────────────────────────────▲───────────────────────────────────┘
                                     │ Merged over active state
┌────────────────────────────────────┴───────────────────────────────────┐
│ TIER 2: MACHINE STATE (~/.local/state/qyra/)                           │
│  ├── state.json              (Active configuration managed by QML)     │
│  └── snapshots/              (last-good.json & automated recovery)     │
└────────────────────────────────────▲───────────────────────────────────┘
                                     │ Consumed by
┌────────────────────────────────────┴───────────────────────────────────┐
│ TIER 1: IMMUTABLE CORE (~/.local/share/qyra/ or /usr/share/qyra/)       │
│  ├── shell/                  (Quickshell QML application & singletons) │
│  ├── hypr/                   (Core Lua modules, keybinds, autostart)   │
│  └── bin/                    (qyractl CLI bridge & qyra-theme-gen)     │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Installation

### Prerequisites (Arch Linux)
Ensure you have the base development packages installed:
```bash
sudo pacman -S --needed base-devel git
```

### Method A: Arch Linux Package (PKGBUILD)
```bash
git clone https://github.com/pear/qyra.git
cd qyra
makepkg -si
qyra-setup --system
```

### Method B: Git Clone & Local Bootstrapper (No sudo required)
```bash
git clone https://github.com/pear/qyra.git
cd qyra
./install.sh --local
```

> **Safety Guarantee**: `install.sh` will **never** overwrite an existing `~/.config/hypr` without creating a timestamped backup (`~/.config/hypr.bak.<date>`) first, and preserves your existing `state.json` and themes.

---

## Core Keybindings

The primary modifier key is **`SUPER`** (Windows key).

### Window & Tiling Controls
| Keybinding | Action |
| :--- | :--- |
| `Super + Q` | Close active window |
| `Super + Return` | Launch terminal (`kitty`) |
| `Super + E` | Open file manager (`nautilus`) |
| `Super + Space` | Toggle floating mode |
| `Super + F` | Toggle fullscreen |
| `Super + H/J/K/L` | Move window focus |
| `Super + Shift + H/J/K/L` | Swap window position |
| `Super + 1..9` | Switch to workspace 1–9 |
| `Super + Shift + 1..9` | Move window to workspace 1–9 |

### Qyra Desktop Controls
| Keybinding | Action |
| :--- | :--- |
| `Super + Comma` | Toggle Qyra Settings App |
| `Super + Alt + B` | Toggle Status Bar visibility |
| `Super + Alt + I` | Cycle Bar Mode (`"bar"` ⟷ `"island"`) |
| `Super + Alt + P` | Cycle Bar Position (`"top"` ⟷ `"bottom"`) |
| `Super + Alt + W` | Cycle Workspace Style (`"pills"` ⟷ `"numbers"` ⟷ `"dots"`) |
| `Super + Alt + T` | Open Appearance / Theme settings |
| `Super + Alt + S` | Create an instant state snapshot |
| `Super + L` | Lock screen (`hyprlock`) |

### Hardware & OSD
| Keybinding | Action |
| :--- | :--- |
| `XF86AudioRaiseVolume` | Raise volume +5% (Triggers OSD) |
| `XF86AudioLowerVolume` | Lower volume -5% (Triggers OSD) |
| `XF86AudioMute` | Toggle audio mute (Triggers OSD) |
| `XF86AudioMicMute` | Toggle microphone mute (Triggers OSD) |
| `XF86MonBrightnessUp` | Raise screen brightness |
| `XF86MonBrightnessDown` | Lower screen brightness |
| `Print` | Interactive screenshot area (`slurp` + `grim`) |
| `Super + Print` | Fullscreen screenshot to clipboard |

---

## CLI Bridge: `qyractl`

`qyractl` is the POSIX command-line bridge into the running Quickshell desktop session via IPC:

```bash
# Query and mutate configuration
qyractl config get bar.mode
qyractl config set bar.mode island
qyractl config toggle bar.visible
qyractl config cycle bar.workspaceStyle

# Manage Settings Window
qyractl settings toggle
qyractl settings openCategory Theme
qyractl settings openCategory Snapshots

# Themes & Wallpaper
qyractl theme apply gruvbox-dark

# State Snapshots
qyractl snapshot create "before-theme-tweak"
qyractl snapshot restore "20261117-203000-before-theme-tweak.json"

# Audio & OSD
qyractl osd outputVolume raise
qyractl osd outputVolume mute-toggle
```

---

## Custom Themes & Palette Engine

Themes reside in `~/.config/themes/<theme_name>/`:
```text
~/.config/themes/gruvbox-dark/
├── background               # Wallpaper image
├── colors.toml              # Base color tokens
└── generated/               # Auto-compiled assets
    ├── colors.json          # Used by Quickshell Theme.qml
    ├── hypr.lua             # 0xffRRGGBB borders for Hyprland
    └── hyprlock-color.conf  # Hyprlock color definitions
```

### Creating a New Theme
1. Open Settings (`Super + Comma`) ➔ **Appearance** ➔ **+ New Theme**.
2. Or create a directory `~/.config/themes/my-theme/`, drop a `background` image and a `colors.toml`:
   ```toml
   [colors]
   bg = "#1e1e2e"
   surface = "#313244"
   fg = "#cdd6f4"
   accent = "#cba6f7"
   urgent = "#f38ba8"
   border = "#313244"
   muted = "#6c7086"
   ```
3. Compile and apply:
   ```bash
   qyra-theme-gen ~/.config/themes/my-theme
   qyractl theme apply my-theme
   ```

---

## Non-Destructive Uninstallation

To cleanly remove Qyra and restore your pre-installation configuration:
```bash
./install.sh --uninstall
```
This removes the Tier 1 core (`~/.local/share/qyra`) and CLI symlinks, and automatically restores the latest `~/.config/hypr.bak.*` backup while preserving your custom themes and configuration snapshots.

---

## License

Distributed under the [MIT License](LICENSE).
