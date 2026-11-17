# QYRA — WORKSPACE MANDATES & ARCHITECTURAL LAWS

You are engineering **Qyra**, a standalone Arch Linux + Hyprland (Lua API) + Quickshell (v0.3.2+) desktop environment.
Before planning, creating, or modifying any file, you MUST read `@docs/ARCHITECTURE.md` and `@docs/ROADMAP.md`.

---

## RULE 0: MANDATORY RESEARCH-FIRST PROTOCOL (ZERO HALLUCINATIONS)
You are strictly forbidden from guessing API signatures, QML property names, or Hyprland Lua syntax.
1. **Verify Hyprland Lua API First**:
   - Hyprland is configured in pure Lua (`hyprland.lua` via the `hl.*` API).
   - Before writing or modifying any file in `hypr/`, inspect local Lua stubs in `/usr/share/hypr/stubs` or search the official Hyprland Lua documentation.
   - NEVER write legacy `.conf` hyprlang syntax (the ONLY exception is `hyprlock.conf`).
2. **Verify Quickshell Native APIs First**:
   - Before writing any QML file, inspect installed Quickshell QML module types or consult the official Quickshell documentation (`https://quickshell.org/docs/v0.3.2/`).
   - Verify exact property names, signals, and methods on `Quickshell.Io`, `Quickshell.Networking`, `Quickshell.Bluetooth`, `Quickshell.Services.Pipewire`, `Quickshell.Services.UPower`, `Quickshell.Services.Mpris`, `Quickshell.Services.Notifications`, `Quickshell.Services.SystemTray`, and `Quickshell.Hyprland`.
3. **Stop and Verify**: If you are unsure whether a native property or method exists in Quickshell or Hyprland Lua, search local stubs or web documentation BEFORE writing fallback shell scripts.

---

## RULE 1: NATIVE-ONLY MANDATE (ZERO CLI WRAPPER SLOP)
Never spawn a `Process` or shell script (`sh -c`, `bash`) when a native C++/QML or Lua binding exists.

| Subsystem | FORBIDDEN (Do NOT Use) | MANDATORY NATIVE SOLUTION |
| :--- | :--- | :--- |
| **Config Persistence** | Manual `JSON.parse()` / `JSON.stringify()` | `Quickshell.Io` (`FileView` + `JsonAdapter` + `JsonObject`) |
| **Ephemeral UI State** | Temp files in `/tmp` | `Quickshell.PersistentProperties` |
| **Wi-Fi / Networking** | `nmcli`, `iwctl`, `wpa_cli` | `Quickshell.Networking` (`Networking.devices`, `WifiDevice`, `WifiNetwork`) |
| **Bluetooth** | `bluetoothctl` | `Quickshell.Bluetooth` |
| **Audio & Volume** | `pactl`, `wpctl`, `pamixer` | `Quickshell.Services.Pipewire` (`Pipewire.defaultAudioSink`, `PwObjectTracker`) |
| **Battery & Power** | `upower -i`, `/sys/class/power_supply` | `Quickshell.Services.UPower` (`UPower.displayDevice`, `PowerProfiles`) |
| **Media Playback** | `playerctl` polling loops | `Quickshell.Services.Mpris` (`Mpris.players`) |
| **System Tray** | External tray daemons | `Quickshell.Services.SystemTray` |
| **Notifications** | `dunst`, `mako` | `Quickshell.Services.Notifications` (`NotificationServer`) |
| **Hyprland State** | `hyprctl workspaces -j` polling | `Quickshell.Hyprland` (`Hyprland.workspaces`, `Hyprland.activeToplevel`) |
| **Live Hyprland Config** | `hyprctl reload` (causes stutter) | `hyprctl eval 'hl.config({...})'` (debounced via 20ms `Timer`) |

*Exception*: External execution via `Quickshell.execDetached` or `Process` is ONLY permitted when no native C++ module exists: `hyprctl eval`, `awww` (wallpaper daemon), `qyra-theme-gen`, and git/package update commands.

---

## RULE 2: 3-TIER HIDDEN CORE vs. USER SANDBOX ARCHITECTURE
To prevent users from accidentally corrupting core logic or suffering merge conflicts during updates, enforce this strict 3-tier XDG split:

1. **Tier 1 — Immutable Hidden Core (`~/.local/share/qyra/` or `/usr/share/qyra/`)**:
   - Houses all Quickshell QML source (`shell/`), core Hyprland Lua modules (`hypr/modules/*.lua`, `hypr/keybinds/*.lua`), default fallback config (`defaults/config.json`), and helper binaries (`bin/qyractl`, `bin/qyra-theme-gen`).
   - Users NEVER edit Tier 1 directly. The in-app Qyra updater replaces Tier 1 cleanly.
2. **Tier 2 — Hidden Machine State (`~/.local/state/qyra/`)**:
   - Houses `state.json` (managed atomically by Quickshell's `FileView` + `JsonAdapter`), `snapshots/*.json`, and `last-good.json`.
   - Kept out of `~/.config/` so users do not manually break the active JSON schema.
3. **Tier 3 — User-Editable Sandbox (`~/.config/`)**:
   - **`~/.config/hypr/hyprland.lua`**: Minimal loader that prepends `~/.local/share/qyra/hypr/?.lua` to `package.path`, calls `require("core_init")`, and wraps `pcall(require, "custom")` so syntax errors in user configs never crash Hyprland boot.
   - **`~/.config/hypr/custom.lua`**: User playground for personal monitor layouts, extra keybinds, and custom window rules.
   - **`~/.config/qyra/custom.json`**: Optional sparse JSON file for manual user overrides. Merged cleanly over `state.json`; if malformed, ignored with a desktop notification rather than crashing Qyra.
   - **`~/.config/themes/<theme_name>/`**: User and preset theme directories (`background` + `colors.toml` + `generated/*`), with `~/.config/themes/current` symlinked to the active theme.

---

## RULE 3: 4-LAYER MODULARITY, DUAL BARS & SCHEMA-DRIVEN UI
1. **Zero Logic in UI Views**:
   - `FullBar.qml`, `IslandBar.qml`, and `SettingsWindow.qml` must contain **ZERO** `Process` calls, DBus calls, or file I/O. All system state lives in `shell/services/*.qml` singletons.
2. **Schema-Driven Settings & Generic Keybind Toggles**:
   - Every configurable option MUST be declared in `Config.qml` (`JsonAdapter`) and documented in `Schema.qml` (`key`, `category`, `label`, `type`, `defaultValue`, `options`/`min`/`max`).
   - `SettingsWindow.qml` (`FloatingWindow`) dynamically generates controls from `Schema.qml`. Never hardcode individual setting rows.
   - Keybinds toggle or cycle settings strictly via generic IPC calls (`qyractl config toggle <key>` and `qyractl config cycle <key>`) backed by `Schema.qml`.
3. **Dual-Mode Bar Parity (`"bar"` vs `"island"`)**:
   - `FullBar.qml` (edge-anchored panel) and `IslandBar.qml` (centered dynamic floating pill) have distinct visual design languages but MUST consume the exact same `shell/services/*.qml` singletons and mode-aware `shell/bars/modules/*.qml` micro-widgets (e.g., `BatteryModule` supporting `"icon"`, `"percentage"`, and `"hybrid"`).
4. **Live Hyprland Sync Resource Discipline**:
   - Never run background polling loops for Hyprland config sync. Apply initial state once at boot via `looknfeel.lua` / `theme.lua`, and trigger runtime `hyprctl eval` strictly on QML property change signals using a **20ms debounce `Timer`**.
5. **Hard File Size Cap**:
   - No QML or Lua file may exceed 250 lines. Split complex views into modular sub-components immediately.

## RULE 4: SANDBOX ISOLATION & ~/QDeck REFERENCE PROTOCOL
1. **`~/QDeck` is Strictly Read-Only Reference**:
   - Inspect `~/QDeck/hypr/` (`modules/*.lua`, `keybinds/*.lua`, `hyprlock.conf`) and `~/QDeck` scripts to match proven Hyprland Lua patterns, IPC idioms, and hardware keybindings.
   - NEVER modify, delete, or create files inside `~/QDeck/`.
2. **Live `~/.config/hypr/` is Off-Limits During Development**:
   - NEVER write files to `~/.config/hypr/` or run `install.sh` against the user's live home directory during development.
   - All Hyprland Lua code must be written inside `<repo>/hypr/` and tested exclusively via the nested compositor entrypoint (`<repo>/hypr/dev_entrypoint.lua`).
