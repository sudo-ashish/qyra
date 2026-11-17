-- hypr/core_init.lua
-- Core orchestrator for Qyra Hyprland configuration.
-- Loads environment, hardware setup, keybinds, and reactive settings.

require("modules.env")
require("modules.monitors")
require("keybinds.tiling")
require("keybinds.multimedia")
require("keybinds.utility")
require("keybinds.qyra")
require("keybinds.clipboard")
require("modules.autostart")
require("modules.looknfeel")
require("modules.theme")
require("modules.animation")
require("modules.misc")
require("modules.input")
require("modules.gesture")
require("modules.windowrule")
