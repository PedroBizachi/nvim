-- Mini.Icons
Config.later(function()
	vim.pack.add({ "https://github.com/mini.nvim/mini.nvim" })

	-- Set up to not prefer extension-based icon for some extensions
	local ext3_blocklist = { scm = true, txt = true, yml = true }
	local ext4_blocklist = { json = true, yaml = true }
	require("mini.icons").setup({
		use_file_extension = function(ext, _)
			return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
		end,
	})

	-- Mock 'nvim-tree/nvim-web-devicons' for plugins without 'mini.icons' support.
	Config.later(MiniIcons.mock_nvim_web_devicons)

	-- Add LSP kind icons. Useful for 'mini.completion'.
	Config.later(MiniIcons.tweak_lsp_kind)

	require("mini.pairs").setup({
		modes = { insert = true, command = true, terminal = false },
		-- skip autopair when next character is one of these
		skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
		-- skip autopair when the cursor is inside these treesitter nodes
		skip_ts = { "string" },
		-- skip autopair when next character is closing pair
		-- and there are more closing pairs than opening pairs
		mappings = {
			["<"] = { action = "open", pair = "<>", neigh_pattern = "^[^\\]" },
			[">"] = { action = "close", pair = "<>", neigh_pattern = "^[^\\]" },
		},
		skip_unbalanced = true,
		-- better deal with markdown code blocks
		markdown = true,
	})

	-- Simple and easy statusline.
	local statusline = require("mini.statusline")
	local statusline_devinfo_hl = "%#MiniStatuslineDevinfo#"
	local statusline_icon_hl = function(hl)
		local source = vim.api.nvim_get_hl(0, { name = hl, link = false })
		local devinfo = vim.api.nvim_get_hl(0, { name = "MiniStatuslineDevinfo", link = false })
		local name = "MiniStatuslineIcon" .. hl:gsub("[^%w_]", "_")

		vim.api.nvim_set_hl(0, name, {
			fg = source.fg or devinfo.fg,
			bg = devinfo.bg,
			bold = true,
		})

		return "%#" .. name .. "#"
	end
	local color = function(hl, text)
		return string.format("%s%s%s", statusline_icon_hl(hl), text, statusline_devinfo_hl)
	end
	local bold_statusline_groups = function()
		for _, group in ipairs({
			"MiniStatuslineModeNormal",
			"MiniStatuslineModeInsert",
			"MiniStatuslineModeVisual",
			"MiniStatuslineModeReplace",
			"MiniStatuslineModeCommand",
			"MiniStatuslineModeOther",
			"MiniStatuslineDevinfo",
			"MiniStatuslineFilename",
			"MiniStatuslineFileinfo",
			"MiniStatuslineInactive",
		}) do
			local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
			if next(hl) ~= nil then
				vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", hl, { bold = true }))
			end
		end
	end

	local default_section_mode = statusline.section_mode
	local neovim_logo = vim.g.have_nerd_font and " " or "NVIM"
	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_mode = function(args)
		args = args or {}

		local mode, hl = default_section_mode(args)
		if mode == "" then
			return mode, hl
		end

		if vim.api.nvim_get_mode().mode == "n" and statusline.is_truncated(args.trunc_width) then
			return neovim_logo, hl
		end

		return neovim_logo .. " " .. mode, hl
	end

	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_git = function(args)
		args = args or {}
		if statusline.is_truncated(args.trunc_width) then
			return ""
		end

		local git = vim.b.gitsigns_status_dict
		if not git then
			return ""
		end

		local icon = args.icon or Config.icons.kinds.Control
		local parts = { icon .. (git.head ~= "" and git.head or "-") }

		local icons = Config.icons.git
		if (git.added or 0) > 0 then
			table.insert(parts, color("GitSignsAdd", icons.added) .. git.added)
		end
		if (git.changed or 0) > 0 then
			table.insert(parts, color("GitSignsChange", icons.modified) .. git.changed)
		end
		if (git.removed or 0) > 0 then
			table.insert(parts, color("GitSignsDelete", icons.removed) .. git.removed)
		end

		return table.concat(parts, " ")
	end

	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_diagnostics = function(args)
		args = args or {}
		if statusline.is_truncated(args.trunc_width) or not vim.diagnostic.is_enabled() then
			return ""
		end

		local counts = vim.diagnostic.count(0)
		local items = {
			{ severity = vim.diagnostic.severity.ERROR, icon = Config.icons.diagnostics.Error, hl = "DiagnosticError" },
			{ severity = vim.diagnostic.severity.WARN, icon = Config.icons.diagnostics.Warn, hl = "DiagnosticWarn" },
			{ severity = vim.diagnostic.severity.INFO, icon = Config.icons.diagnostics.Info, hl = "DiagnosticInfo" },
			{ severity = vim.diagnostic.severity.HINT, icon = Config.icons.diagnostics.Hint, hl = "DiagnosticHint" },
		}

		local parts = {}
		for _, item in ipairs(items) do
			local count = counts[item.severity] or 0
			if count > 0 then
				table.insert(parts, color(item.hl, item.icon) .. count)
			end
		end

		return table.concat(parts, " ")
	end

	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_diff = function()
		return ""
	end

	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_lsp = function(args)
		args = args or {}
		if statusline.is_truncated(args.trunc_width) then
			return ""
		end

		local clients = vim.lsp.get_clients({ bufnr = 0 })
		if #clients == 0 then
			return ""
		end

		return (vim.g.have_nerd_font and "󰒋 " or "LSP ") .. #clients
	end

	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_filename = function(args)
		args = args or {}

		return (vim.fn.expand("%:t") ~= "" and " %t" or "[No Name]") .. "%m%r"
	end

	local section_supermaven = function()
		local ok, api = pcall(require, "supermaven-nvim.api")
		if not ok or not api.is_running() then
			return ""
		end

		return color("CmpItemKindSupermaven", Config.icons.kinds.Supermaven)
	end
	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_fileinfo = function(args)
		args = args or {}
		local filetype = vim.bo.filetype
		if filetype == "" then
			return ""
		end

		local filetype_info = filetype
		if vim.g.have_nerd_font and MiniIcons then
			local icon, hl = MiniIcons.get("filetype", filetype)
			filetype_info = color(hl, " ") .. color(hl, icon) .. " " .. filetype
		end
		local supermaven = section_supermaven()

		if statusline.is_truncated(args.trunc_width) or vim.bo.buftype ~= "" then
			return table.concat(
				vim.tbl_filter(function(item)
					return item ~= ""
				end, { supermaven, filetype_info }),
				" "
			)
		end

		local venv = ""
		if vim.bo.filetype == "python" then
			local ok, vs = pcall(require, "venv-selector")
			if ok then
				local path = vs.venv()
				if path and path ~= "" then
					venv = "(" .. vim.fn.fnamemodify(path, ":t") .. ")"
				end
			end
		end

		return table.concat(
			vim.tbl_filter(function(item)
				return item ~= ""
			end, { supermaven, filetype_info, venv }),
			" "
		)
	end

	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_searchcount = function(args)
		if vim.v.hlsearch == 0 or statusline.is_truncated(args.trunc_width) then
			return ""
		end
		local ok, s_count = pcall(vim.fn.searchcount, (args or {}).options or { recompute = true })
		if not ok or s_count.current == nil or s_count.total == 0 then
			return ""
		end

		if s_count.incomplete == 1 then
			return "?/?"
		end

		local too_many = ">" .. s_count.maxcount
		local current = s_count.current > s_count.maxcount and too_many or s_count.current
		local total = s_count.total > s_count.maxcount and too_many or s_count.total
		return "[" .. current .. "/" .. total .. "]"
	end

	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_location = function()
		return "%2l:%-2v %p%%:%-L"
	end

	local function active_statusline()
		local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
		local git = statusline.section_git({ trunc_width = 40 })
		local diff = statusline.section_diff({ trunc_width = 75 })
		local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
		local lsp = statusline.section_lsp({ trunc_width = 75 })
		local filename = statusline.section_filename({ trunc_width = 140 })
		local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
		local search = statusline.section_searchcount({ trunc_width = 75 })
		local location = statusline.section_location({ trunc_width = 75 })

		return statusline.combine_groups({
			{ hl = mode_hl, strings = { mode } },
			{ hl = "MiniStatuslineDevinfo", strings = { git, diff } },
			"%<", -- Mark general truncate point
			{ hl = "MiniStatuslineFilename", strings = { filename } },
			"%=", -- End left alignment
			{ hl = "MiniStatuslineDevinfo", strings = { fileinfo, lsp, diagnostics } },
			{ hl = mode_hl, strings = { search, location } },
		})
	end

	statusline.setup({
		content = {
			active = active_statusline,
		},
		use_icons = vim.g.have_nerd_font,
	})
	vim.schedule(bold_statusline_groups)

	local ai = require("mini.ai")
	ai.setup({
		n_lines = 500,
		mappings = {
			around = "a",
			inside = "i",
			around_next = "an",
			inside_next = "in",
			around_last = "al",
			inside_last = "il",
		},
		custom_textobjects = {
			o = ai.gen_spec.treesitter({
				a = { "@block.outer", "@conditional.outer", "@loop.outer" },
				i = { "@block.inner", "@conditional.inner", "@loop.inner" },
			}),
			f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
			c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
			t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
			d = { "%f[%d]%d+" },
			e = {
				{
					"%u[%l%d]+%f[^%l%d]",
					"%f[%S][%l%d]+%f[^%l%d]",
					"%f[%P][%l%d]+%f[^%l%d]",
					"^[%l%d]+%f[^%l%d]",
				},
				"^().*()$",
			},
			g = function()
				local from = { line = 1, col = 1 }
				local to = {
					line = vim.fn.line("$"),
					col = math.max(vim.fn.getline("$"):len(), 1),
				}

				return { from = from, to = to }
			end,
			u = ai.gen_spec.function_call(),
			U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
		},
	})

	require("mini.tabline").setup()
	require("mini.files").setup()
	require("colors").apply()
	bold_statusline_groups()
end)
