-----------------------
---- LOOK AND FEEL ----
-----------------------

local state_mod = require("modules.state")
local state = state_mod.load()
local h = state.hypr

hl.config({
	general = {
		gaps_in = h.gapsIn or 2,
		gaps_out = h.gapsOut or 4,
		border_size = h.borderSize or 0,
		resize_on_border = true,
		allow_tearing = false,
		layout = h.layout or "dwindle",
	},

	decoration = {
		rounding = h.rounding or 10,
		rounding_power = h.roundingPower or 10,
		active_opacity = h.activeOpacity or 0.95,
		inactive_opacity = h.inactiveOpacity or 0.88,

		shadow = {
			enabled = false,
			range = 4,
			render_power = 3,
		},

		blur = {
			enabled = (h.blurEnabled ~= false),
			size = h.blurSize or 6,
			passes = h.blurPasses or 4,
			vibrancy = 0.45,
			contrast = 2,
			brightness = 0.8,
			new_optimizations = true,
			popups = true,
			popups_ignorealpha = 0.2,
		},
	},

	animations = {
		enabled = (h.animationsEnabled ~= false),
	},

	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},
})
