-- hypr/dev_entrypoint.lua
-- Dev entrypoint for testing Qyra Hyprland config safely in a nested window:
-- Usage: Hyprland -c ./hypr/dev_entrypoint.lua

local src = debug.getinfo(1, "S").source
local dir = ""
if src:sub(1, 1) == "@" then
    dir = src:sub(2):match("(.*/)") or ""
end

if dir == "" then
    dir = (os.getenv("PWD") or ".") .. "/hypr/"
end

package.path = dir .. "?.lua;"
            .. dir .. "?/init.lua;"
            .. package.path

require("core_init")
