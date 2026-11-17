-------------------
---- AUTOSTART ----
-------------------

local home = os.getenv("HOME") or ""
local qyra_shell = home .. "/.local/share/qyra/shell"

hl.on("hyprland.start", function()
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("qs -p " .. qyra_shell)
end)
