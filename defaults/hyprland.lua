-- ~/.config/hypr/hyprland.lua
-- Minimal failsafe boot loader for Qyra desktop environment.
-- Deployed to Tier 3 (~/.config/hypr/hyprland.lua) by install.sh.

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
    hl.exec_cmd("notify-send -u critical 'Qyra: Error in custom.lua' '" .. tostring(err):gsub("'", "\\'") .. "'")
end
