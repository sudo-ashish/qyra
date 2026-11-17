-- hypr/modules/state.lua
-- Loads active state from Tier 2 state.json and merges Tier 3 custom.json overrides.

local M = {}

local function parse_json_value(str, pos)
	pos = str:find("%S", pos) or pos
	if not pos or pos > #str then
		return nil, pos
	end
	local c = str:sub(pos, pos)
	if c == "{" then
		local obj = {}
		pos = pos + 1
		while true do
			pos = str:find("%S", pos)
			if not pos or str:sub(pos, pos) == "}" then
				return obj, (pos or #str) + 1
			end
			if str:sub(pos, pos) == "," then
				pos = pos + 1
				pos = str:find("%S", pos)
			end
			if not pos or str:sub(pos, pos) == "}" then
				return obj, (pos or #str) + 1
			end
			local k, next_pos = parse_json_value(str, pos)
			if not k or not next_pos then
				return obj, pos
			end
			pos = str:find(":", next_pos)
			if not pos then
				return obj, next_pos
			end
			pos = pos + 1
			local v
			v, pos = parse_json_value(str, pos)
			obj[k] = v
		end
	elseif c == '"' then
		local e = str:find('"', pos + 1)
		if not e then
			return "", #str + 1
		end
		return str:sub(pos + 1, e - 1), e + 1
	elseif str:sub(pos, pos + 3) == "true" then
		return true, pos + 4
	elseif str:sub(pos, pos + 4) == "false" then
		return false, pos + 5
	elseif str:sub(pos, pos + 3) == "null" then
		return nil, pos + 4
	else
		local e = str:find("[,%s%}]", pos) or (#str + 1)
		return tonumber(str:sub(pos, e - 1)), e
	end
end

local function read_file(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local c = f:read("*a")
	f:close()
	return c
end

function M.load()
	local home = os.getenv("HOME") or ""
	local state_path = home .. "/.local/state/qyra/state.json"
	local custom_path = home .. "/.config/qyra/custom.json"

	local state = {
		hypr = {
			gapsIn = 2,
			gapsOut = 4,
			borderSize = 0,
			rounding = 10,
			roundingPower = 10,
			activeOpacity = 0.95,
			inactiveOpacity = 0.88,
			blurEnabled = true,
			blurSize = 6,
			blurPasses = 4,
			animationsEnabled = true,
			layout = "dwindle",
		},
		input = {
			sensitivity = 0.5,
			naturalScroll = true,
			disableWhileTyping = true,
			capsToEscape = true,
		},
	}

	local state_text = read_file(state_path)
	if state_text then
		pcall(function()
			local s = parse_json_value(state_text, 1)
			if s and s.hypr then
				for k, v in pairs(s.hypr) do
					state.hypr[k] = v
				end
			end
			if s and s.input then
				for k, v in pairs(s.input) do
					state.input[k] = v
				end
			end
		end)
	end

	local custom_text = read_file(custom_path)
	if custom_text then
		pcall(function()
			local c = parse_json_value(custom_text, 1)
			if c and c.hypr then
				for k, v in pairs(c.hypr) do
					state.hypr[k] = v
				end
			end
			if c and c.input then
				for k, v in pairs(c.input) do
					state.input[k] = v
				end
			end
		end)
	end

	return state
end

return M
