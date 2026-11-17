# QYRA — System Architecture & Technical Specifications

## 1. System Overview & 4-Layer Decoupled Stack

```text
┌──────────────────────────────────────────────────────────────────────┐
│ LAYER 4: PRESENTATION (Pure UI Views — Zero System/Process Logic)    │
│  ├── bars/FullBar.qml       (Edge-anchored rectangular PanelWindow)  │
│  ├── bars/IslandBar.qml     (Dynamic floating pill PanelWindow)      │
│  ├── bars/modules/*.qml     (Shared widgets: Battery, Wifi, Audio)   │
│  └── settings/Settings.qml  (Schema-driven FloatingWindow + Updater) │
└───────────────▲───────────────────────────────────────┬──────────────┘
                │ Reactive QML Property Bindings        │ Mutates
┌───────────────┴───────────────────────────────────────▼──────────────┐
│ LAYER 3: LAYERED CONFIG, SCHEMA & THEME ENGINE                       │
│  ├── config/Config.qml      (Merges Defaults + State + Custom JSON)  │
│  ├── config/Schema.qml      (UI metadata, bounds, types, defaults)   │
│  ├── services/Snapshot.qml  (Backup, restore, last-good fallback)    │
│  └── services/Theme.qml     (Watches ~/.config/themes/current/...)   │
└───────────────▲───────────────────────────────────────┬──────────────┘
                │ Reads State                           │ 20ms Debounced
┌───────────────┴───────────────────────────────────────▼──────────────┐
│ LAYER 2: NATIVE QUICKSHELL SERVICES (Pure Singletons)                │
│  ├── services/Network.qml   (Quickshell.Networking)                  │
│  ├── services/Bluetooth.qml (Quickshell.Bluetooth)                   │
│  ├── services/Audio.qml     (Quickshell.Services.Pipewire)           │
│  ├── services/Battery.qml   (Quickshell.Services.UPower)             │
│  ├── services/Hypr.qml      (Quickshell.Hyprland + hyprctl eval)     │
│  └── services/Updater.qml   (Git/AUR version check & safe upgrade)   │
└───────────────▲───────────────────────────────────────┬──────────────┘
                │ Native Wayland / DBus / Sockets       │ Lua Runtime
┌───────────────┴───────────────────────────────────────▼──────────────┐
│ LAYER 1: OS, COMPOSITOR & PACKAGING                                  │
│  └── Hyprland (Lua API) + PipeWire + NetworkManager + BlueZ + UPower │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 2. 3-Tier XDG Filesystem & Repository Map

### A. Source Repository Structure
```text
qyra/
├── GEMINI.md                        # Mandatory AI agent workspace laws
├── PKGBUILD                         # Arch Linux package build & dependencies
├── install.sh                       # Non-destructive user bootstrapper
├── VERSION                          # Semantic version string (e.g., 0.1.0)
├── bin/
│   ├── qyractl                      # POSIX CLI wrapper around `qs ipc call`
│   └── qyra-theme-gen               # Compiles colors.toml -> generated/* files
├── defaults/
│   ├── config.json                  # Read-only baseline fallback configuration
│   ├── custom.lua                   # Template copied to ~/.config/hypr/custom.lua
│   └── custom.json                  # Template copied to ~/.config/qyra/custom.json
├── docs/
│   ├── ARCHITECTURE.md              # This specification
│   └── ROADMAP.md                   # Phased build tracker
├── hypr/                            # Installed to Tier 1 (~/.local/share/qyra/hypr/)
│   ├── core_init.lua                # Orchestrates all core modules & keybinds
│   ├── hyprlock.conf                # Symlinked/copied to ~/.config/hypr/hyprlock.conf
│   ├── .luarc.json                  # Points Lua LSP to /usr/share/hypr/stubs
│   ├── modules/
│   │   ├── env.lua                  # Wayland/Qt/GDK env vars & cursor settings
│   │   ├── monitors.lua             # Default monitor & XWayland zero-scaling
│   │   ├── autostart.lua            # Starts awww-daemon and qyra shell
│   │   ├── theme.lua                # Loads ~/.config/themes/current/generated/hypr.lua
│   │   ├── looknfeel.lua            # Reads ~/.local/state/qyra/state.json on boot
│   │   ├── animation.lua            # Bezier curves and window/layer animations
│   │   ├── misc.lua                 # Disables default Hyprland logos/wallpapers
│   │   ├── input.lua                # Keyboard, mouse sensitivity, touchpad settings
│   │   ├── gesture.lua              # 3-finger workspace & 4-finger volume gestures
│   │   ├── windowrule.lua           # Floating utility rules & Quickshell blur rules
│   │   └── hyprglass.lua            # Optional hyprglass plugin presets
│   └── keybinds/
│       ├── tiling.lua               # Focus, move, resize, workspaces, groups
│       ├── multimedia.lua           # Volume, brightness, media via qyractl OSD
│       ├── utility.lua              # Screenshots, terminal, file manager, tools
│       ├── qyra.lua                 # Launcher, settings, bar mode, theme toggles
│       └── clipboard.lua            # Clipboard manager shortcuts
└── shell/                           # Installed to Tier 1 (~/.local/share/qyra/shell/)
    ├── shell.qml                    # Root ShellRoot: loads IPC, Services, Bar, Windows
    ├── config/
    │   ├── Config.qml               # Singleton: merges Defaults + State + Custom JSON
    │   └── Schema.qml               # Singleton: metadata array for all settings
    ├── services/
    │   ├── Apps.qml                 # Singleton: Quickshell.DesktopEntries application indexing
    │   ├── Audio.qml                # Singleton: Quickshell.Services.Pipewire
    │   ├── Battery.qml              # Singleton: Quickshell.Services.UPower
    │   ├── Bluetooth.qml            # Singleton: Quickshell.Bluetooth
    │   ├── Hypr.qml                 # Singleton: Quickshell.Hyprland + 20ms debounced eval
    │   ├── Media.qml                # Singleton: Quickshell.Services.Mpris
    │   ├── Network.qml              # Singleton: Quickshell.Networking
    │   ├── Notifications.qml        # Singleton: Quickshell.Services.Notifications
    │   ├── Power.qml                # Singleton: Lock, suspend, reboot, shutdown, logout
    │   ├── Snapshot.qml             # Singleton: state.json backup & rollback manager
    │   ├── Theme.qml                # Singleton: watches current/generated/colors.json
    │   └── Updater.qml              # Singleton: checks remote version & updates Tier 1
    ├── components/
    │   └── ModeViewLoader.qml       # Switcher bound to Config.activeDesignStyle
    ├── launcher/
    │   ├── BarLauncher.qml          # Crisp centered command-palette PanelWindow
    │   └── IslandLauncher.qml       # Top-anchored fluid Dynamic Island PanelWindow
    ├── powermenu/
    │   ├── BarPowerMenu.qml         # Crisp structured power dialog PanelWindow
    │   └── IslandPowerMenu.qml      # Dynamic Island floating power pill PanelWindow
    ├── bars/
    │   ├── BarController.qml        # Loader switching FullBar <-> IslandBar
    │   ├── FullBar.qml              # Edge-anchored full-width bar view
    │   ├── IslandBar.qml            # Centered dynamic floating pill view
    │   └── modules/                 # Shared mode-aware micro-widgets
    │       ├── BatteryModule.qml    # Modes: "icon" | "percentage" | "hybrid"
    │       ├── WorkspacesModule.qml
    │       ├── NetworkModule.qml
    │       ├── BluetoothModule.qml
    │       ├── AudioModule.qml
    │       ├── ClockModule.qml
    │       └── TrayModule.qml
    ├── settings/
    │   ├── SettingsWindow.qml       # FloatingWindow with sidebar & live search
    │   ├── DynamicControl.qml       # Renders Enum/Bool/Int/Real from Schema.qml
    │   ├── ThemePage.qml            # Theme switcher grid + Built-in Theme Creator
    │   ├── SnapshotPage.qml         # Create/Restore/Delete snapshots
    │   └── UpdatePage.qml           # Version check, changelog, 1-click safe update
    └── osd/
        └── OsdWindow.qml            # Volume, brightness, and config toggle OSD
```

### B. Target Installation Tiers on User Machine
```text
TIER 1: IMMUTABLE HIDDEN CORE (~/.local/share/qyra/ or /usr/share/qyra/)
├── bin/                             # qyractl, qyra-theme-gen
├── defaults/config.json             # Fallback defaults
├── hypr/                            # core_init.lua, modules/*.lua, keybinds/*.lua
└── shell/                           # All Quickshell QML files

TIER 2: HIDDEN MACHINE STATE (~/.local/state/qyra/)
├── state.json                       # Active config written by Settings App (JsonAdapter)
└── snapshots/
    ├── last-good.json               # Auto-updated on every valid boot/load
    └── <timestamp>-<label>.json     # Pre-update and user-created snapshots

TIER 3: USER-EDITABLE SANDBOX (~/.config/)
├── hypr/
│   ├── hyprland.lua                 # Loads Tier 1 core_init.lua + pcall("custom")
│   ├── custom.lua                   # User's personal keybinds/monitors/rules
│   └── hyprlock.conf                # Sources ~/.config/themes/current/generated/hyprlock-color.conf
├── qyra/
│   └── custom.json                  # Optional sparse user JSON overrides (default: {})
└── themes/
    ├── current -> gruvbox-dark      # Symlink to active theme directory
    └── <theme_name>/
        ├── background               # Wallpaper image
        ├── colors.toml              # Master color palette
        └── generated/               # Output of qyra-theme-gen
            ├── colors.json          # Read by Quickshell Theme.qml
            ├── hypr.lua             # Read by Tier 1 hypr/modules/theme.lua
            ├── hyprlock-color.conf  # Read by ~/.config/hypr/hyprlock.conf
            ├── neovim.lua
            ├── vscode.json
            └── icon.theme
```

---

## 3. Hyprland Lua Bridge & Zero-Idle-CPU Live Sync

### A. Failsafe Boot Loader (`~/.config/hypr/hyprland.lua`)
Users never touch the core Lua modules in Tier 1. Instead, `~/.config/hypr/hyprland.lua` loads the hidden core and safely wraps user customizations in `pcall`:

```lua
local home = os.getenv("HOME") or ""
package.path = home .. "/.local/share/qyra/hypr/?.lua;"
            .. "/usr/share/qyra/hypr/?.lua;"
            .. home .. "/.config/hypr/?.lua;"
            .. package.path

-- 1. Load immutable Qyra core modules & keybinds
require("core_init")

-- 2. Safely load user overrides from ~/.config/hypr/custom.lua
local ok, err = pcall(require, "custom")
if not ok then
    hl.exec_cmd("notify-send -u critical 'Qyra: Error in custom.lua' '" .. tostring(err) .. "'")
end
```

### B. Event-Driven Live Sync (`shell/services/Hypr.qml`)
- **0% Idle CPU**: There are zero background loops or polling timers watching Hyprland.
- **Boot Time**: `hypr/modules/looknfeel.lua` and `hypr/modules/theme.lua` execute once during Hyprland startup (<1ms) to apply saved values from `state.json` and `current/generated/hypr.lua`.
- **Runtime Slider/Toggle Updates**: When a user changes a `Config.hypr.*` or `Config.input.*` property in the Settings App or via keybind:
  1. `Config.qml` saves to `~/.local/state/qyra/state.json`.
  2. `Hypr.qml` queues the changed key-value pair into a `pendingChanges` JS object and restarts a **20ms single-shot debounce `Timer`**.
  3. When the 20ms timer fires, `Hypr.qml` executes a single `Quickshell.execDetached(["hyprctl", "eval", "hl.config(" + luaTable + ")"])`, updating Hyprland live at 60fps with zero process spam and zero reload flicker.

---

## 4. Layered Single-File Configuration Schema

`Config.qml` exposes a unified property tree backed by `~/.local/state/qyra/state.json` (`FileView` + `JsonAdapter`) with optional overrides merged from `~/.config/qyra/custom.json`:

```json
{
  "version": 1,
  "bar": {
    "visible": true,
    "mode": "island",
    "position": "top",
    "height": 34,
    "batteryMode": "hybrid",
    "workspaceStyle": "pills",
    "showTray": true,
    "clockFormat": "HH:mm"
  },
  "ui": {
    "designStyle": "follow-bar"
  },
  "theme": {
    "active": "gruvbox-dark",
    "followThemeBarMode": false
  },
  "hypr": {
    "gapsIn": 2,
    "gapsOut": 4,
    "borderSize": 0,
    "rounding": 10,
    "roundingPower": 10,
    "activeOpacity": 0.95,
    "inactiveOpacity": 0.88,
    "blurEnabled": true,
    "blurSize": 6,
    "blurPasses": 4,
    "animationsEnabled": true,
    "layout": "dwindle"
  },
  "input": {
    "sensitivity": 0.5,
    "naturalScroll": true,
    "disableWhileTyping": true,
    "capsToEscape": true
  },
  "updates": {
    "autoCheck": true,
    "checkIntervalHours": 12
  }
}
```

---

## 5. Theme Engine & User Theme Creation

Each theme resides in `~/.config/themes/<theme_name>/`. Users can create new themes via two supported workflows:
1. **Folder / CLI Workflow**:
   - Create `~/.config/themes/<new_theme>/` containing `background` (wallpaper) and `colors.toml` (or `colors.json`).
   - Run `qyra-theme-gen <new_theme>` (also triggered automatically if `Theme.qml` detects a theme folder missing `generated/colors.json`).
2. **In-App GUI Theme Creator (`shell/settings/ThemePage.qml`)**:
   - Clicking **"+ New Theme"** in Settings lets the user clone an existing theme, pick a wallpaper file, adjust color swatches (`background`, `surface`, `foreground`, `accent`, `urgent`, `border`) via QML color pickers, and save.
   - `Theme.qml` writes `~/.config/themes/<new_theme>/colors.toml`, copies the wallpaper to `background`, runs `qyra-theme-gen <new_theme>`, and switches `~/.config/themes/current` to the new theme.

### Kitty Terminal Live Reload
When switching themes (via `ThemePage.qml`, `qyractl theme apply <name>`, or `Theme.applyTheme`):
- `qyra-theme-gen` generates `color.conf` and `generated/color.conf` containing the 16 ANSI colors, background, foreground, cursor, active borders, and tabs.
- `~/.config/kitty/color.conf` is dynamically symlinked to `~/.config/themes/current/color.conf`.
- Running Kitty instances are signaled via `pkill -SIGUSR1 -u "$UID" -x kitty`, triggering instant zero-restart palette reconfiguration across all open terminal windows.

---

## 6. IPC & Keybind Toggle Contract (`qyractl` <-> `IpcHandler`)

All Hyprland keybinds in `hypr/keybinds/*.lua` and terminal scripts interact with Qyra through `bin/qyractl` (`qs ipc call <target> <method> [args...]`):

| Target | Function | Arguments | Description |
| :--- | :--- | :--- | :--- |
| `config` | `toggle` | `key: string` | Flips any boolean in `Schema.qml` (e.g., `qyractl config toggle bar.visible`, `qyractl config toggle hypr.blurEnabled`) |
| `config` | `cycle` | `key: string` | Cycles any enum in `Schema.qml` through its valid `options` (e.g., `qyractl config cycle bar.mode`, `qyractl config cycle bar.batteryMode`) |
| `config` | `set` | `key: string, val: string` | Explicitly sets any schema key from CLI/keybind |
| `settings` | `toggle` | none | Opens or closes `SettingsWindow` |
| `settings` | `openCategory` | `category: string` | Opens `SettingsWindow` to `"Bar"`, `"Theme"`, `"Hyprland"`, `"Input"`, `"Snapshots"`, or `"Updates"` |
| `theme` | `apply` | `name: string` | Updates `current` symlink, runs generator if needed, updates wallpaper & Hyprland border colors |
| `osd` | `outputVolume` | `action: string` | `raise`, `lower`, `raise-fine`, `lower-fine`, `mute-toggle` |
| `osd` | `inputVolume` | `action: string` | `mute-toggle` |
| `brightness` | `action` | `action: string` | `raise`, `lower`, `raise-fine`, `lower-fine` |
| `snapshot` | `create` | `label: string` | Creates a timestamped backup of `state.json` in `~/.local/state/qyra/snapshots/` |
| `launcher` | `toggle` | none | Opens or closes the application launcher |
| `powermenu` | `toggle` | none | Opens or closes the power menu overlay |

---

## 7. Reusable ModeViewLoader & Interactive Overlays Architecture

To achieve clean visual parity without duplicating business logic, interactive overlays (`launcher`, `powermenu`, `clipboard`) follow a strict 1-service-to-2-views decoupled pattern:

```text
┌─────────────────────────────────────────────────────────────────┐
│               HEADLESS SERVICE SINGLETON                        │
│   (e.g., shell/services/Apps.qml, shell/services/Power.qml)     │
│   - Holds state: isOpen, searchQuery, filtered items            │
│   - Executes actions: launch(entry), lock(), suspend(), poweroff│
│   - Pure logic & IPC bridge (Zero UI code)                      │
└────────────────────────────────┬────────────────────────────────┘
                                 │
                   ┌─────────────┴─────────────┐
                   ▼                           ▼
        ModeViewLoader (activeDesignStyle == "bar")
        └── BarLauncher.qml / BarPowerMenu.qml
            - Crisp command palette (radius: 8, 1px border)
            - Dense list layout, keyboard arrow navigation
            
        ModeViewLoader (activeDesignStyle == "island")
        └── IslandLauncher.qml / IslandPowerMenu.qml
            - Top-anchored fluid Dynamic Island pill (radius: 26)
            - Animated dimension expansion, rounded app cards
```

### Dynamic Design Style Resolution
The visual style is governed by `Config.ui.designStyle`:
- `"follow-bar"` (default): Dynamically resolves to `Config.bar.mode` (`"bar"` or `"island"`).
- `"bar"`: Forces rectangular command-palette overlay design language across all windows.
- `"island"`: Forces fluid dynamic pill overlay design language across all windows.

`ModeViewLoader.qml` automatically reacts to `Config.activeDesignStyle` changes and loads the corresponding view via QML `Loader` with zero latency or compositor restart.
