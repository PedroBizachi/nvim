Config.later(function()
	vim.pack.add({
		"https://github.com/folke/snacks.nvim",
		"https://github.com/mbbill/undotree",
		"https://github.com/smjonas/inc-rename.nvim",
		"https://github.com/folke/trouble.nvim",
	})

	Config.on_event({ "BufReadPost", "BufNewFile" }, function()
		vim.pack.add({ "https://github.com/folke/trouble.nvim" })

		require("trouble").setup({})

		local set = vim.keymap.set

		-- stylua: ignore start
		set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
		set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
		set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
		set("n", "<leader>cS", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", { desc = "LSP Definitions/references/... (Trouble)" })
		set("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
		set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
	end)

	-- Better LSP renaming
	require("inc_rename").setup({})

	---@type snacks.picker
	local picker_actions = vim.tbl_extend("force", require("trouble.sources.snacks").actions, {
		opencode_send = function(picker) ---@param picker snacks.Picker
			local items = vim.tbl_map(function(item) ---@param item snacks.picker.Item
				return item.file
						and require("opencode").format({
							path = item.file,
							from = item.pos,
							to = item.end_pos,
						})
					or item.text
			end, picker:selected({ fallback = true }))

			require("opencode").prompt(table.concat(items, ", ") .. " ")
		end,
		sidekick_send = function(picker) ---@param picker snacks.Picker
			return require("sidekick.cli.picker.snacks").send(picker)
		end,
	})

	-- @type snacks.Config
	require("snacks").setup({
		indent = {
			scope = {
				hl = {
					"SnacksIndent1",
					"SnacksIndent2",
					"SnacksIndent3",
					"SnacksIndent4",
					"SnacksIndent5",
					"SnacksIndent6",
					"SnacksIndent7",
					"SnacksIndent8",
				},
			},
		},
		picker = {
			enabled = true,
			ui_select = true,
			-- TODO: Enable backdrop
			win = {
				input = {
					keys = {
						["<a-c>"] = { "cycle_layouts", mode = { "i", "n" } },
						["<c-t>"] = {
							"trouble_open",
							mode = { "n", "i" },
						},
						["<a-a>"] = {
							"opencode_send",
							"sidekick_send",
							mode = { "n", "i" },
						},
					},
				},
			},
			actions = vim.tbl_extend("force", picker_actions, {
				cycle_layouts = function(picker)
					require("util.snacks-picker").set_next_preferred_layout(picker)
				end,
			}),
			layout = {
				layout = {
					backdrop = { transparent = true },
				},
				preset = function()
					return require("util.snacks-picker").preferred_layout()
				end,
			},
		},
		styles = {
			notification = {
				wo = { wrap = true },
			},
		},
		terminal = {
			shell = { vim.o.shell, "-i", "-l" },
			win = {
				keys = {
					vim.keymap.set({ "n", "t" }, "<c-_>", function()
						Snacks.terminal.toggle()
					end, { desc = "Toggle Terminal" }),
					vim.keymap.set({ "n", "t" }, "<c-/>", function()
						Snacks.terminal.toggle()
					end, { desc = "Toggle Terminal" }),
				},
			},
		},
		input = { enabled = true },
		notifier = {
			style = "fancy",
		},
		scroll = { enabled = true },
		scope = { enabled = true },
		toggle = { enabled = true },
		statuscolumn = { enabled = true, refresh = 100 },
		lazygit = { enabled = true },
		quickfile = { enabled = true },
		bufdelete = { enabled = true },
		words = { enabled = true },
		bigfile = { enabled = true },
	})

	local set = vim.keymap.set

	-- stylua: ignore start
	-- Top Pickers & Explorer
	set("n", "<leader><space>", function() Snacks.picker.smart() end, { desc = "Smart Find Files" })
	set("n", "<leader>,", function() Snacks.picker.buffers() end, { desc = "Buffers", })
	set("n", "<leader>:", function() Snacks.picker.command_history() end, { desc = "Command History", })
	set("n", "<leader>n", function() Snacks.notifier.show_history() end, { desc = "Notification History", })
	-- find
	set("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers", })
	set("n", "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Find Config File", })
	set("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find Files", })
	set("n", "<leader>fg", function() Snacks.picker.git_files() end, { desc = "Find Git Files", })
	set("n", "<leader>fp", function() Snacks.picker.projects() end, { desc = "Projects", })
	set("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent", })
	-- git
	set("n", "<leader>gb", function() Snacks.picker.git_branches() end, { desc = "Git Branches", })
	set("n", "<leader>gl", function() Snacks.picker.git_log() end, { desc = "Git Log", })
	set("n", "<leader>gL", function() Snacks.picker.git_log_line() end, { desc = "Git Log Line", })
	set("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git Status", })
	set("n", "<leader>gS", function() Snacks.picker.git_stash() end, { desc = "Git Stash", })
	set("n", "<leader>gd", function() Snacks.picker.git_diff() end, { desc = "Git Diff (Hunks)", })
	set("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Log File", })
	-- gh
	set("n", "<leader>gi", function() Snacks.picker.gh_issue() end, { desc = "GitHub Issues (open)", })
	set("n", "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, { desc = "GitHub Issues (all)", })
	set("n", "<leader>gp", function() Snacks.picker.gh_pr() end, { desc = "GitHub Pull Requests (open)", })
	set("n", "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, { desc = "GitHub Pull Requests (all)", })
	-- Grep
	set("n", "<leader>sb", function() Snacks.picker.lines() end, { desc = "Buffer Lines", })
	set("n", "<leader>sB", function() Snacks.picker.grep_buffers() end, { desc = "Grep Open Buffers", })
	set("n", "<leader>sg", function() Snacks.picker.grep() end, { desc = "Grep", })
	set({"n", "x"}, "<leader>sw", function() Snacks.picker.grep_word() end, { desc = "Grep Word" })
	-- search
	set("n", '<leader>s"', function() Snacks.picker.registers() end, { desc = "Registers", })
	set("n", "<leader>s/", function() Snacks.picker.search_history() end, { desc = "Search History", })
	set("n", "<leader>sa", function() Snacks.picker.autocmds() end, { desc = "Autocmds", })
	set("n", "<leader>sc", function() Snacks.picker.command_history() end, { desc = "Command History", })
	set("n", "<leader>sC", function() Snacks.picker.commands() end, { desc = "Commands", })
	set("n", "<leader>sd", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics", })
	set("n", "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, { desc = "Buffer Diagnostics", })
	set("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "Help Pages", })
	set("n", "<leader>sH", function() Snacks.picker.highlights() end, { desc = "Highlights", })
	set("n", "<leader>si", function() Snacks.picker.icons() end, { desc = "Icons", })
	set("n", "<leader>sj", function() Snacks.picker.jumps() end, { desc = "Jumps", })
	set("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps", })
	set("n", "<leader>sl", function() Snacks.picker.loclist() end, { desc = "Location List", })
	set("n", "<leader>sm", function() Snacks.picker.marks() end, { desc = "Marks", })
	set("n", "<leader>sM", function() Snacks.picker.man() end, { desc = "Man Pages", })
	set("n", "<leader>sq", function() Snacks.picker.qflist() end, { desc = "Quickfix List", })
	set("n", "<leader>sR", function() Snacks.picker.resume() end, { desc = "Resume", })
	set("n", "<leader>su", function()
		local ok = pcall(Snacks.picker.undo)
		if not ok then
			vim.cmd.UndotreeToggle()
		end
	end, { desc = "Undo History", })
	set("n", "<leader>uC", function() Snacks.picker.colorschemes() end, { desc = "Colorschemes", })
	-- LSP
	set("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, { desc = "LSP Symbols", })
	set("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, { desc = "LSP Workspace Symbols", })
	set({"n"}, "<leader>cd", vim.diagnostic.open_float, {desc = "Line Diagnostics" })

	Snacks.toggle({
		name = "Format on Save",
		get = function()
			return vim.g.autoformat ~= false
		end,
		set = function(state)
			vim.g.autoformat = state
		end,
	}):map("<leader>uf")
	Snacks.toggle({
		name = "Format on Save (Buffer)",
		get = function()
			return vim.b.autoformat ~= false
		end,
		set = function(state)
			vim.b.autoformat = state
		end,
	}):map("<leader>uF")
	Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
	Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
	Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
	Snacks.toggle.diagnostics():map("<leader>ud")
	Snacks.toggle.line_number():map("<leader>ul")
	Snacks.toggle
		.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" })
		:map("<leader>uc")
	-- Replaced by "Toggle AI"
	-- Snacks.toggle
	-- 	.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" })
	-- 	:map("<leader>uA")
	Snacks.toggle.treesitter():map("<leader>uT")
	Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
	Snacks.toggle.dim():map("<leader>uD")
	Snacks.toggle.animate():map("<leader>ua")
	Snacks.toggle.indent():map("<leader>ug")
	Snacks.toggle.scroll():map("<leader>uS")
	Snacks.toggle.profiler():map("<leader>dpp")
	Snacks.toggle.profiler_highlights():map("<leader>dph")
	if vim.lsp.inlay_hint then
		Snacks.toggle.inlay_hints():map("<leader>uh")
	end
	-- stylua: ignore end
	require("colors").apply()
end)
