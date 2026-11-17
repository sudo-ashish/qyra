---------------
---- INPUT ----
---------------

local state_mod = require("modules.state")
local state = state_mod.load()
local inp = state.input

local kb_opts = ""
if inp.capsToEscape then
	kb_opts = "caps:escape"
end

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = kb_opts,
		kb_rules = "",
		numlock_by_default = true,
		follow_mouse = 1,
		sensitivity = inp.sensitivity or 0.5,

		touchpad = {
			disable_while_typing = (inp.disableWhileTyping ~= false),
			natural_scroll = (inp.naturalScroll ~= false),
		},
	},
})
