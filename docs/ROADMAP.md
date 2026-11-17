# QYRA — Phased Implementation Roadmap

> **AGENT MANDATE**: Execute phases strictly in order. Before starting ANY task:
> 1. **Research First (`RULE 0`)**: Inspect `/usr/share/hypr/stubs` or official Hyprland Lua & Quickshell v0.3.2+ docs to verify exact APIs and property names. Never guess.
> 2. **Native Only (`RULE 1`)**: Never wrap CLI tools (`nmcli`, `bluetoothctl`, `pactl`, `upower`, `playerctl`) when native Quickshell C++ modules exist.
> 3. **3-Tier Isolation (`RULE 2`)**: Keep immutable core files in Tier 1 (`~/.local/share/qyra/`), machine state in Tier 2 (`~/.local/state/qyra/`), and user overrides in Tier 3 (`~/.config/`).
> 4. Mark a task `[x]` only after verifying it loads and runs with zero errors.

---

## Phase 1: Layered Config Engine, Schema & Snapshot System
*Goal: Build the single-file configuration engine and corruption recovery before writing any UI widgets.*

- [ ] **1.1 Create Baseline Defaults (`defaults/config.json`, `defaults/custom.lua`, `defaults/custom.json`)**:
  - Populate `defaults/config.json` with the canonical schema from `@docs/ARCHITECTURE.md`.
  - Create starter templates for `~/.config/hypr/custom.lua` and `~/.config/qyra/custom.json`.
- [ ] **1.2 Create Metadata Schema (`shell/config/Schema.qml`)**:
  - Define singleton exposing metadata for all settings (`bar.*`, `theme.*`, `hypr.*`, `input.*`, `updates.*`).
  - Include `key`, `category`, `label`, `description`, `type` (`"enum" | "bool" | "int" | "real" | "string"`), `defaultValue`, and `options` / `min` / `max` / `step`.
- [ ] **1.3 Create Layered Config Manager (`shell/config/Config.qml`)**:
  - Verify `Quickshell.Io` (`FileView`, `JsonAdapter`, `JsonObject`) documentation first.
  - Bind `JsonAdapter` to `~/.local/state/qyra/state.json` (`watchChanges: true`, `atomicWrites: true`).
  - Add a secondary read-only `FileView` watching `~/.config/qyra/custom.json` to merge sparse user overrides safely, falling back gracefully on JSON syntax errors with a desktop notification.
  - Implement generic `toggleBool(key)` and `cycleEnum(key)` helpers driven by `Schema.qml`.
- [ ] **1.4 Create Snapshot & Auto-Recovery Service (`shell/services/Snapshot.qml`)**:
  - Copy valid `state.json` to `~/.local/state/qyra/snapshots/last-good.json` on load.
  - Implement `createSnapshot(label)`, `listSnapshots()`, `restoreSnapshot(filename)`, and automatic rollback to `last-good.json` on `onLoadFailed`.

---

## Phase 2: Theme Pipeline & Hyprland Lua Bridge
*Goal: Connect `.config/themes/<theme_name>/` and live `hyprctl eval` syncing with 0% idle CPU usage.*

- [ ] **2.1 Build Theme Compiler (`bin/qyra-theme-gen`)**:
  - Parse `~/.config/themes/<theme_name>/colors.toml` (and optional `colors.json`).
  - Emit `generated/colors.json`, `generated/hypr.lua`, `generated/hyprlock-color.conf`, `generated/neovim.lua`, `generated/vscode.json`, and `generated/icon.theme`.
- [ ] **2.2 Create Reactive Theme Service (`shell/services/Theme.qml`)**:
  - Watch `~/.config/themes/current/generated/colors.json` via `FileView`.
  - Expose reactive QML color tokens (`bg`, `surface`, `fg`, `accent`, `urgent`, `border`).
  - Implement `applyTheme(name)` to update symlink `~/.config/themes/current`, auto-run `qyra-theme-gen` if `generated/` is missing, set wallpaper via `awww img ~/.config/themes/current/background`, and update Hyprland border colors.
  - Implement `createTheme(name, baseTheme, wallpaperPath, palette)` for the in-app theme creator.
- [ ] **2.3 Wire Hyprland Lua Core & Failsafe Loader (`hypr/*`)**:
  - Verify Hyprland Lua API syntax against `/usr/share/hypr/stubs`.
  - Create `hypr/core_init.lua` orchestrating `modules/*.lua` and `keybinds/*.lua`.
  - Update `hypr/modules/theme.lua` to load `~/.config/themes/current/generated/hypr.lua`.
  - Update `hypr/modules/looknfeel.lua` and `modules/input.lua` to read `~/.local/state/qyra/state.json` on boot with fallback defaults.
  - Create the Tier 3 loader template (`~/.config/hypr/hyprland.lua`) using `pcall(require, "custom")`.
- [ ] **2.4 Create Hyprland IPC & Debounced Live Sync Service (`shell/services/Hypr.qml`)**:
  - Wrap `Quickshell.Hyprland` for reactive workspace and active window tracking.
  - Observe `Config.hypr.*` and `Config.input.*` changes, queue mutations into a 20ms single-shot `Timer`, and apply live via `hyprctl eval 'hl.config({...})'`.

---

## Phase 3: Native Backend Services & IPC Contract
*Goal: Build 100% native C++/QML service singletons and the `qyractl` CLI wrapper.*

- [ ] **3.1 Battery & Power (`shell/services/Battery.qml`)**:
  - Wrap `Quickshell.Services.UPower` (`UPower.displayDevice`, `PowerProfiles`).
- [ ] **3.2 Wi-Fi & Networking (`shell/services/Network.qml`)**:
  - Wrap `Quickshell.Networking` (`Networking.devices`, `WifiDevice`, `WifiNetwork`). Zero `nmcli`.
- [ ] **3.3 Bluetooth (`shell/services/Bluetooth.qml`)**:
  - Wrap `Quickshell.Bluetooth` (adapter power, connected devices, discovery, pairing). Zero `bluetoothctl`.
- [ ] **3.4 PipeWire Audio (`shell/services/Audio.qml`)**:
  - Wrap `Quickshell.Services.Pipewire` (`defaultAudioSink`, `defaultAudioSource`, `PwObjectTracker`, per-app streams). Zero `pactl`/`wpctl`.
- [ ] **3.5 Media & Notifications (`shell/services/Media.qml`, `Notifications.qml`)**:
  - Wrap `Quickshell.Services.Mpris` and `Quickshell.Services.Notifications`.
- [ ] **3.6 Register `IpcHandler` Targets & `bin/qyractl`**:
  - Implement `config`, `settings`, `theme`, `osd`, and `snapshot` IPC handlers in `shell/shell.qml`.
  - Create POSIX executable `bin/qyractl` forwarding arguments to `qs ipc call`.
  - Bind key toggles (`qyractl config toggle ...`, `qyractl config cycle ...`) in `hypr/keybinds/qyra.lua`.

---

## Phase 4: Centric Settings App & Non-Destructive Updater
*Goal: Build the schema-driven `FloatingWindow` control center, theme creator, snapshot manager, and safe updater.*

- [ ] **4.1 Build Dynamic Control Renderer (`shell/settings/DynamicControl.qml`)**:
  - Render segmented selectors (`enum`), switches (`bool`), and sliders (`int`/`real`) directly from `Schema.qml` metadata, two-way bound to `Config.qml`.
  - Add per-setting modified indicator and 1-click reset to `defaultValue`.
- [ ] **4.2 Build Main Settings Window (`shell/settings/SettingsWindow.qml`)**:
  - Implement as a Quickshell `FloatingWindow` with category navigation (`Bar`, `Theme`, `Hyprland`, `Input`, `Snapshots`, `Updates`) and live search filtering.
- [ ] **4.3 Build Theme & Snapshot Pages (`shell/settings/ThemePage.qml`, `SnapshotPage.qml`)**:
  - `ThemePage.qml`: Visual grid scanning `~/.config/themes/*` (wallpaper preview + color swatches) plus **"+ New Theme"** builder modal.
  - `SnapshotPage.qml`: List, create, restore, and delete backups in `~/.local/state/qyra/snapshots/`.
- [ ] **4.4 Build Safe Updater (`shell/services/Updater.qml`, `shell/settings/UpdatePage.qml`)**:
  - Compare local `VERSION` against remote git/GitHub release.
  - On update: 1) Call `Snapshot.createSnapshot("pre-update")`, 2) Update Tier 1 (`~/.local/share/qyra/`) without touching Tier 2 (`state.json`) or Tier 3 (`~/.config/`), 3) Trigger Quickshell reload.

---

## Phase 5: Shared Micro-Widgets & Dual Bar Design Languages
*Goal: Build mode-aware widgets and iterate freely on the visual design of `FullBar` and `IslandBar`.*

- [ ] **5.1 Build Mode-Aware Micro-Widgets (`shell/bars/modules/*.qml`)**:
  - `BatteryModule.qml`: Reactively renders `"icon"`, `"percentage"`, or `"hybrid"` based on `Config.bar.batteryMode`.
  - `WorkspacesModule.qml`, `NetworkModule.qml`, `BluetoothModule.qml`, `AudioModule.qml`, `ClockModule.qml`, `TrayModule.qml`.
- [ ] **5.2 Build Bar Mode Switcher (`shell/bars/BarController.qml`)**:
  - Use a `Loader` bound to `Config.bar.mode` (`"bar"` vs `"island"`) and `Config.bar.visible`.
- [ ] **5.3 Design & Implement `FullBar.qml` & `IslandBar.qml`**:
  - `FullBar.qml`: Edge-anchored rectangular panel (`PanelWindow` anchored top/left/right).
  - `IslandBar.qml`: Centered floating dynamic pill (`PanelWindow` with animated width expansion).
  - Iterate visual polish using `Theme.qml` tokens with zero backend changes.

---

## Phase 6: Standalone Installer & Arch Packaging
*Goal: Make Qyra install cleanly with all dependencies and non-destructive user setup.*

- [ ] **6.1 Create `PKGBUILD`**:
  - Declare dependencies (`hyprland`, `quickshell`, `awww`, `hyprlock`, `pipewire`, `wireplumber`, `networkmanager`, `bluez`, `upower`, `ttf-jetbrains-mono-nerd`).
- [ ] **6.2 Create `install.sh` Bootstrapper**:
  - Back up any existing `~/.config/hypr/` directory.
  - Install Tier 1 files to `~/.local/share/qyra/` (or `/usr/share/qyra/`).
  - Initialize Tier 2 (`~/.local/state/qyra/state.json`) from `defaults/config.json`.
  - Deploy Tier 3 loader `~/.config/hypr/hyprland.lua`, `custom.lua`, `custom.json`, and default theme symlink `~/.config/themes/current`.
