-----------------
----  THEME  ----
-----------------

local home = os.getenv("HOME") or ""
local theme_file = home .. "/.config/themes/current/generated/hypr.lua"

local ok, colors = pcall(dofile, theme_file)
if not ok or type(colors) ~= "table" then
	colors = {
		active_border = "0xff7daea3",
		inactive_border = "0xff504945",
		shadow = "0x66000000",
		bg = "0xff282828",
		fg = "0xffebdbb2",
		surface = "0xff3c3836",
	}
end

hl.config({
	general = {
		["col.active_border"] = colors.active_border,
		["col.inactive_border"] = colors.inactive_border,
	},
})
