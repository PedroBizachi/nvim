vim.loader.enable()

local Config = {}

---@class Config
---@field on_packchanged fun(plugin_name: string, kinds: string[], callback: function, desc?: string)
---@field now fun(f: function) Execute immediately. Use for startup-critical config.
---@field later fun(f: function) Execute after startup. Use for config not needed immediately.
---@field new_autocmd fun(event: string|string[], pattern: string|string[], callback: function, desc?: string)
---@field on_event fun(event: string|string[], f: function) Execute once on first matching event.
---@field on_filetype fun(ft: string|string[], f: function) Execute once on first matching filetype.
---@field icons table Default icons for the config
---@type Config
_G.Config = Config
---@type Config
Config = _G.Config

local group = vim.api.nvim_create_augroup("native-lazy-config", { clear = true })

local function safely(label, f)
	local ok, err = xpcall(f, debug.traceback)
	if not ok then
		vim.notify(label .. " failed:\n" .. err, vim.log.levels.ERROR)
	end
end

Config.on_packchanged = function(plugin_name, kinds, callback, desc)
	local f = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if not (name == plugin_name and vim.tbl_contains(kinds, kind)) then
			return
		end
		if not ev.data.active then
			vim.cmd.packadd(plugin_name)
		end
		callback(ev.data)
	end
	Config.new_autocmd("PackChanged", "*", f, desc)
end

Config.now = function(f)
	safely("now", f)
end

Config.later = function(f)
	vim.schedule(function()
		safely("later", f)
	end)
end

Config.new_autocmd = function(event, pattern, callback, desc)
	vim.api.nvim_create_autocmd(event, {
		group = group,
		pattern = pattern,
		callback = callback,
		desc = desc,
	})
end

Config.on_event = function(event, f)
	vim.api.nvim_create_autocmd(event, {
		group = group,
		once = true,
		callback = function()
			local label = type(event) == "table" and table.concat(event, ",") or event
			safely("event:" .. label, f)
		end,
	})
end

Config.on_filetype = function(ft, f)
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		pattern = ft,
		once = true,
		callback = function(ev)
			local label = type(ft) == "table" and table.concat(ft, ",") or ft
			safely("filetype:" .. label, function()
				f(ev)
			end)
		end,
	})
end

Config.icons = {
	misc = {
		dots = "󰇘",
	},
	ft = {
		octo = " ",
		gh = " ",
		["markdown.gh"] = " ",
	},
	dap = {
		Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
		Breakpoint = " ",
		BreakpointCondition = " ",
		BreakpointRejected = { " ", "DiagnosticError" },
		LogPoint = ".>",
	},
	diagnostics = {
		Error = " ",
		Warn = " ",
		Hint = " ",
		Info = " ",
	},
	git = {
		added = " ",
		modified = " ",
		removed = " ",
	},
	kinds = {
		Array = " ",
		Boolean = "󰨙 ",
		Class = " ",
		Codeium = "󰘦 ",
		Color = " ",
		Control = " ",
		Collapsed = " ",
		Constant = "󰏿 ",
		Constructor = " ",
		Copilot = " ",
		Enum = " ",
		EnumMember = " ",
		Event = " ",
		Field = " ",
		File = " ",
		Folder = "󰝰 ",
		Function = "󰊕 ",
		Interface = " ",
		Key = " ",
		Keyword = " ",
		Method = "󰊕 ",
		Module = " ",
		Namespace = "󰦮 ",
		Null = " ",
		Number = "󰎠 ",
		Object = " ",
		Operator = " ",
		Package = " ",
		Property = " ",
		Reference = " ",
		Snippet = "󱄽 ",
		String = " ",
		Struct = "󰆼 ",
		Supermaven = "",
		TabNine = "󰏚 ",
		Text = " ",
		TypeParameter = " ",
		Unit = " ",
		Value = " ",
		Variable = "󰀫 ",
		Log = " ",
	},
}

Config.now(function()
	require("options")
	require("colorscheme")
end)

Config.later(function()
	require("autocmds")
	require("keymaps")
	require("diagnostics")
end)
