local M = {}

local layouts = require("snacks.picker.config.layouts")

layouts.default_wider_preview = vim.deepcopy(layouts.default)
layouts.default_wider_preview.layout[2].width = 0.8

local idx = 1
local preferred = {
	"default",
	"default_wider_preview",
}

M.preferred_layout = function()
	return preferred[idx]
end

M.set_next_preferred_layout = function(picker)
	idx = idx % #preferred + 1
	picker:set_layout(preferred[idx])
end

return M
