local augroup = vim.api.nvim_create_augroup("native_statusline", { clear = true })

local icons = {
	control = " ",
	lsp = "󰒋 ",
	git = {
		added = " ",
		modified = " ",
		removed = " ",
	},
	diagnostics = {
		Error = " ",
		Warn = " ",
		Info = " ",
		Hint = " ",
	},
	filetypes = {
		lua = "",
		vim = "",
		javascript = "",
		typescript = "",
		typescriptreact = "",
		json = "",
		markdown = "",
		python = "",
		sh = "",
		zsh = "",
	},
}

local modes = {
	n = { name = "NORMAL", hl = "MiniStatuslineModeNormal" },
	no = { name = "O-PENDING", hl = "MiniStatuslineModeOther" },
	nov = { name = "O-PENDING", hl = "MiniStatuslineModeOther" },
	noV = { name = "O-PENDING", hl = "MiniStatuslineModeOther" },
	niI = { name = "NORMAL", hl = "MiniStatuslineModeNormal" },
	niR = { name = "NORMAL", hl = "MiniStatuslineModeNormal" },
	niV = { name = "NORMAL", hl = "MiniStatuslineModeNormal" },
	i = { name = "INSERT", hl = "MiniStatuslineModeInsert" },
	ic = { name = "INSERT", hl = "MiniStatuslineModeInsert" },
	ix = { name = "INSERT", hl = "MiniStatuslineModeInsert" },
	v = { name = "VISUAL", hl = "MiniStatuslineModeVisual" },
	V = { name = "V-LINE", hl = "MiniStatuslineModeVisual" },
	["\22"] = { name = "V-BLOCK", hl = "MiniStatuslineModeVisual" },
	s = { name = "SELECT", hl = "MiniStatuslineModeVisual" },
	S = { name = "S-LINE", hl = "MiniStatuslineModeVisual" },
	["\19"] = { name = "S-BLOCK", hl = "MiniStatuslineModeVisual" },
	R = { name = "REPLACE", hl = "MiniStatuslineModeReplace" },
	Rc = { name = "REPLACE", hl = "MiniStatuslineModeReplace" },
	Rv = { name = "V-REPLACE", hl = "MiniStatuslineModeReplace" },
	c = { name = "COMMAND", hl = "MiniStatuslineModeCommand" },
	cv = { name = "EX", hl = "MiniStatuslineModeCommand" },
	ce = { name = "EX", hl = "MiniStatuslineModeCommand" },
	r = { name = "PROMPT", hl = "MiniStatuslineModeOther" },
	rm = { name = "MORE", hl = "MiniStatuslineModeOther" },
	["r?"] = { name = "CONFIRM", hl = "MiniStatuslineModeOther" },
	t = { name = "TERMINAL", hl = "MiniStatuslineModeOther" },
}

local function hi(name, opts)
	vim.api.nvim_set_hl(0, name, opts)
end

local function setup_highlights()
	local c = require("colors").catppuccin
	local fg = c.foreground
	local bg = c.color0
	local dark = c.background

	hi("MiniStatuslineModeNormal", { fg = dark, bg = c.color2, bold = true })
	hi("MiniStatuslineModeInsert", { fg = dark, bg = c.color4, bold = true })
	hi("MiniStatuslineModeVisual", { fg = dark, bg = c.color5, bold = true })
	hi("MiniStatuslineModeReplace", { fg = dark, bg = c.color1, bold = true })
	hi("MiniStatuslineModeCommand", { fg = dark, bg = c.color3, bold = true })
	hi("MiniStatuslineModeOther", { fg = fg, bg = bg, bold = true })
	hi("MiniStatuslineDevinfo", { fg = c.color15, bg = bg })
	hi("MiniStatuslineFilename", { fg = fg, bg = nil })
	hi("MiniStatuslineFileinfo", { fg = c.color15, bg = bg })
	hi("NativeStatuslineFiletypeIcon", { fg = c.color4, bg = bg })
	hi("NativeStatuslineLocation", { fg = dark, bg = c.accent, bold = true })
	hi("NativeStatuslineGitAdd", { fg = c.color2, bg = bg })
	hi("NativeStatuslineGitChange", { fg = c.color3, bg = bg })
	hi("NativeStatuslineGitDelete", { fg = c.color1, bg = bg })
	hi("NativeStatuslineDiagnosticError", { fg = c.color1, bg = bg })
	hi("NativeStatuslineDiagnosticWarn", { fg = c.color3, bg = bg })
	hi("NativeStatuslineDiagnosticInfo", { fg = c.color4, bg = bg })
	hi("NativeStatuslineDiagnosticHint", { fg = c.color6, bg = bg })
end

local function is_truncated(width)
	return vim.o.columns < width
end

local function color(hl, text)
	return string.format("%%#%s#%s%%#MiniStatuslineDevinfo#", hl, text)
end

local function git_root(path)
	if path == "" then
		return ""
	end

	local dir = vim.fn.fnamemodify(path, ":p:h")
	return vim.fn.system({ "git", "-C", dir, "rev-parse", "--show-toplevel" }):gsub("%s+$", "")
end

local function update_git_cache(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	local root = git_root(name)

	if root == "" or vim.v.shell_error ~= 0 then
		vim.b[bufnr].statusline_git = nil
		vim.b[bufnr].statusline_path = name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]"
		return
	end

	local branch = vim.fn.system({ "git", "-C", root, "branch", "--show-current" }):gsub("%s+$", "")
	if branch == "" then
		branch = vim.fn.system({ "git", "-C", root, "rev-parse", "--short", "HEAD" }):gsub("%s+$", "")
	end

	local rel_path = name ~= "" and vim.fn.fnamemodify(name, ":p"):sub(#root + 2) or "[No Name]"
	local diff = name ~= "" and vim.fn.system({ "git", "-C", root, "diff", "--numstat", "--", rel_path }) or ""
	local added, removed = diff:match("^(%d+)%s+(%d+)")

	vim.b[bufnr].statusline_git = {
		head = branch ~= "" and branch or "-",
		added = tonumber(added) or 0,
		removed = tonumber(removed) or 0,
	}
	vim.b[bufnr].statusline_path = rel_path
end

local function section_mode()
	local mode = modes[vim.fn.mode()] or { name = vim.fn.mode():upper(), hl = "MiniStatuslineModeOther" }
	return string.format("%%#%s# %s %%*", mode.hl, mode.name)
end

local function section_git()
	if is_truncated(75) then
		return ""
	end

	local git = vim.b.statusline_git
	if not git then
		return ""
	end

	local parts = { icons.control .. " " .. git.head }
	if git.added > 0 then
		table.insert(parts, color("NativeStatuslineGitAdd", icons.git.added) .. git.added)
	end
	if git.removed > 0 then
		table.insert(parts, color("NativeStatuslineGitDelete", icons.git.removed) .. git.removed)
	end

	return "%#MiniStatuslineDevinfo# " .. table.concat(parts, " ") .. " %*"
end

local function section_diagnostics()
	if is_truncated(75) then
		return ""
	end

	if vim.diagnostic.is_enabled and not vim.diagnostic.is_enabled() then
		return ""
	end

	local counts = vim.diagnostic.count(0)
	local items = {
		{
			severity = vim.diagnostic.severity.ERROR,
			icon = icons.diagnostics.Error,
			hl = "NativeStatuslineDiagnosticError",
		},
		{
			severity = vim.diagnostic.severity.WARN,
			icon = icons.diagnostics.Warn,
			hl = "NativeStatuslineDiagnosticWarn",
		},
		{
			severity = vim.diagnostic.severity.INFO,
			icon = icons.diagnostics.Info,
			hl = "NativeStatuslineDiagnosticInfo",
		},
		{
			severity = vim.diagnostic.severity.HINT,
			icon = icons.diagnostics.Hint,
			hl = "NativeStatuslineDiagnosticHint",
		},
	}

	local parts = {}
	for _, item in ipairs(items) do
		local count = counts[item.severity] or 0
		if count > 0 then
			table.insert(parts, color(item.hl, item.icon) .. count)
		end
	end

	return #parts > 0 and "%#MiniStatuslineDevinfo# " .. table.concat(parts, " ") .. " %*" or ""
end

local function section_filename()
	return "%#MiniStatuslineFilename# " .. ((vim.fn.expand("%:t") ~= "" and "%t" or "[No Name]") .. "%m%r") .. " %*"
end

local function section_fileinfo()
	local filetype = vim.bo.filetype
	if filetype == "" then
		return ""
	end

	local icon = icons.filetypes[filetype]
	local info = icon and (color("NativeStatuslineFiletypeIcon", icon) .. " " .. filetype) or filetype
	if is_truncated(120) or vim.bo.buftype ~= "" then
		return "%#MiniStatuslineFileinfo# " .. info .. " %*"
	end

	return "%#MiniStatuslineFileinfo# " .. info .. " %*"
end

local function section_lsp()
	if is_truncated(75) then
		return ""
	end

	local clients = vim.lsp.get_clients({ bufnr = 0 })
	return #clients > 0 and ("%#MiniStatuslineDevinfo# " .. icons.lsp .. #clients .. " %*") or ""
end

local function section_searchcount()
	if vim.v.hlsearch == 0 or is_truncated(75) then
		return ""
	end

	local ok, count = pcall(vim.fn.searchcount, { recompute = true })
	if not ok or count.current == nil or count.total == 0 then
		return ""
	end

	if count.incomplete == 1 then
		return "%#MiniStatuslineDevinfo# ?/? %*"
	end

	local too_many = ">" .. count.maxcount
	local current = count.current > count.maxcount and too_many or count.current
	local total = count.total > count.maxcount and too_many or count.total
	return "%#MiniStatuslineDevinfo# [" .. current .. "/" .. total .. "] %*"
end

local function section_location()
	return "%#NativeStatuslineLocation# %2l:%-2v %p%%:%-L %*"
end

function _G._statusline()
	return table.concat({
		section_mode(),
		section_git(),
		section_diagnostics(),
		section_lsp(),
		section_filename(),
		"%=",
		section_fileinfo(),
		section_searchcount(),
		section_location(),
	}, "")
end

setup_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
	group = augroup,
	callback = setup_highlights,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
	group = augroup,
	callback = function(event)
		update_git_cache(event.buf)
	end,
})

vim.api.nvim_create_autocmd({ "DiagnosticChanged", "LspAttach", "LspDetach" }, {
	group = augroup,
	callback = function()
		vim.cmd("redrawstatus!")
	end,
})

vim.o.statusline = "%!v:lua._statusline()"
