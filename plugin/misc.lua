-- stylua: ignore start
Config.on_filetype("python", function(ev)
	vim.pack.add({ "https://github.com/linux-cultist/venv-selector.nvim" })

	require("venv-selector").setup({
		hooks = {},
		search = {},
		cache = {
			file = "~/.local/share/nvim/nvim/venv-selector/cache",
		},
		---@diagnostic disable-next-line: missing-fields
		options = {
			log_level = "INFO",
			notify_user_on_venv_activation = true,
			override_notify = false,
		},
	})

	local set_venv_keymap = function(buf)
		vim.keymap.set("n", "<leader>cv", "<cmd>VenvSelect<cr>", {
			buffer = buf,
			desc = "Select VirtualEnv",
		})
	end

	-- This FileType event loaded the plugin, so map the buffer that triggered it too.
	set_venv_keymap(ev.buf)

	vim.api.nvim_create_autocmd("FileType", {
		group = vim.api.nvim_create_augroup("bizak_python_venv_keymaps", { clear = true }),
		pattern = "python",
		callback = function(event)
			set_venv_keymap(event.buf)
		end,
	})
end)

Config.on_event({ "BufReadPost", "BufNewFile" }, function()
	vim.pack.add({ "https://github.com/folke/todo-comments.nvim" })
	vim.pack.add({ "https://github.com/NMAC427/guess-indent.nvim" })

	require("todo-comments").setup({})

	require("guess-indent").setup({})

	local set = vim.keymap.set

	-- stylua: ignore start
	set({ "n" }, "]t", function() require("todo-comments").jump_next() end, { desc = "Next Todo" })
	set({ "n" }, "[t", function() require("todo-comments").jump_prev() end, { desc = "Prev Todo" })
	set("n", "<leader>st", function() Snacks.picker.todo_comments() end, { desc = "Todo" })
	set("n", "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" }}) end, { desc = "Todo/Fix/Fixme" })
end)

Config.later(function()
	vim.pack.add({ "https://github.com/dstein64/vim-startuptime" })
	vim.pack.add({ "https://github.com/folke/flash.nvim" })
	vim.pack.add({ "https://github.com/nvim-zh/colorful-winsep.nvim" })
	vim.pack.add({ "https://github.com/atiladefreitas/dooing" })
	vim.pack.add({ "https://github.com/chrisgrieser/nvim-chainsaw" })
	vim.pack.add({ "https://github.com/wansmer/treesj" })
	vim.pack.add({ "https://github.com/mawkler/modicator.nvim" })

	local set = vim.keymap.set

	require("chainsaw").setup()

	local chainsaw = require("chainsaw")

	set({ "n", "v", "x" }, "<leader>lv", function() chainsaw.variableLog() end, { desc = "Log variable" })
	set({ "n", "v", "x" }, "<leader>lo", function() chainsaw.objectLog() end, { desc = "Log object" })
	set({ "n", "v", "x" }, "<leader>lt", function() chainsaw.typeLog() end, { desc = "Log type" })
	set({ "n", "v", "x" }, "<leader>la", function() chainsaw.assertLog() end, { desc = "Log assert" })
	set({ "n", "v", "x" }, "<leader>lm", function() chainsaw.messageLog() end, { desc = "Log custom message" })
	set({ "n", "v", "x" }, "<leader>li", function() chainsaw.timeLog() end, { desc = "Place time counter" })
	set({ "n", "v", "x" }, "<leader>ld", function() chainsaw.debugLog() end, { desc = "Debug log" })
	set({ "n", "v", "x" }, "<leader>ls", function() chainsaw.stacktraceLog() end, { desc = "Print stacktrace" })
	set({ "n", "v", "x" }, "<leader>lc", function() chainsaw.clearLog() end, { desc = "Clear console" })
	set({ "n", "v", "x" }, "<leader>lr", function() chainsaw.removeLogs() end, { desc = "🛑 Delete logs" })

	require("dooing").setup({
		pretty_print_json = true,
		per_project = {
			default_filename = "tasks.json", -- Default filename for project todos
			auto_gitignore = true, -- Auto-add to .gitignore (true/false/"prompt")
		},
	})

	require("modicator").setup()

	require("treesj").setup({
    use_default_keymaps = false
  })

	set({"n", "v", "x"}, "<leader>fmm", function () require("treesj").toggle() end, { desc = "Toggle code block"})
	set({"n", "v", "x"}, "<leader>fmM", function ()
		require("treesj").toggle({split = {recursive = true}})
	end, { desc = "Toggle code block"})

	require("colorful-winsep").setup()

	require("flash").setup({})

	local flash = require("flash")

  set({ "n", "x", "o" }, "s", function() flash.jump() end, { desc = "Flash" })
  set({ "n", "o", "x" }, "S", function() flash.treesitter() end, { desc = "Flash Treesitter" })
  set("o", "r", function() flash.remote() end, { desc = "Remote Flash" })
  set({ "o", "x" }, "R", function() flash.treesitter_search() end, { desc = "Treesitter Search" })
  set({ "c" }, "<c-s>", function() flash.toggle() end, { desc = "Toggle Flash Search" })

  set({ "n", "o", "x" }, "<c-space>", function()
    flash.treesitter({
      actions = {
        ["<c-space>"] = "next",
        ["<BS>"] = "prev"
      }
    })
  end, { desc = "Treesitter Incremental Selection" })
end)

Config.on_event({ "BufReadPost", "BufNewFile" }, function()
	vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })
	require("gitsigns").setup({
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "▎" },
			untracked = { text = "▎" },
		},
		signs_staged = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "▎" },
		},
	})

	Config.later(function()
		Snacks.toggle({
			name = "Git Signs",
			get = function()
				return require("gitsigns.config").config.signcolumn
			end,
			set = function(state)
				require("gitsigns").toggle_signs(state)
			end,
		}):map("<leader>uG")
	end)

	-- keymaps
	local gs = package.loaded.gitsigns

	local function map(mode, l, r, desc)
		vim.keymap.set(mode, l, r, { desc = desc, silent = true })
	end
	map("n", "]h", function()
		if vim.wo.diff then
			vim.cmd.normal({ "]c", bang = true })
		else
			gs.nav_hunk("next")
		end
	end, "Next Hunk")
	map("n", "[h", function()
		if vim.wo.diff then
			vim.cmd.normal({ "[c", bang = true })
		else
			gs.nav_hunk("prev")
		end
	end, "Prev Hunk")
	map("n", "]H", function()
		gs.nav_hunk("last")
	end, "Last Hunk")
	map("n", "[H", function()
		gs.nav_hunk("first")
	end, "First Hunk")
	map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
	map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
	map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
	map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
	map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
	map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
	map("n", "<leader>ghb", function()
		gs.blame_line({ full = true })
	end, "Blame Line")
	map("n", "<leader>ghB", function()
		gs.blame()
	end, "Blame Buffer")
	map("n", "<leader>ghd", gs.diffthis, "Diff This")
	map("n", "<leader>ghD", function()
		gs.diffthis("~")
	end, "Diff This ~")
	map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
end)

Config.on_event({ "BufReadPost", "BufNewFile" }, function()
	vim.pack.add({
		"https://github.com/MeanderingProgrammer/render-markdown.nvim",
		"https://github.com/nvim-tree/nvim-web-devicons",
	})

	require("render-markdown").setup({
		file_types = { "markdown" },
	})

	vim.g.render_markdown_enabled = vim.g.render_markdown_enabled ~= false

	Config.later(function()
		Snacks.toggle({
			name = "Markdown Render",
			get = function()
				return vim.g.render_markdown_enabled ~= false
			end,
			set = function(state)
				vim.g.render_markdown_enabled = state
				vim.cmd("RenderMarkdown " .. (state and "enable" or "disable"))
			end,
		}):map("<leader>um")

		Snacks.toggle({
			name = "Markdown Render (Buffer)",
			get = function()
				return vim.b.render_markdown_enabled ~= false
			end,
			set = function(state)
				vim.b.render_markdown_enabled = state
				vim.cmd("RenderMarkdown " .. (state and "buf_enable" or "buf_disable"))
			end,
		}):map("<leader>uM")
	end)
end)

Config.on_filetype("lua", function()
	vim.pack.add({ "https://github.com/folke/lazydev.nvim" })

	require("lazydev").setup({
		library = {
			{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			{ path = "snacks.nvim", words = { "Snacks" } },
			{ path = "nvim-lspconfig", words = { "lspconfig.settings" } },
		},
	})
end)

Config.on_event({ "BufReadPost", "BufNewFile" }, function()
	vim.pack.add({ "https://github.com/monaqa/dial.nvim" })

	local augend = require("dial.augend")
	local logical_alias = augend.constant.new({
		elements = { "&&", "||" },
		word = false,
		cyclic = true,
	})

	local ordinal_numbers = augend.constant.new({
		elements = {
			"first",
			"second",
			"third",
			"fourth",
			"fifth",
			"sixth",
			"seventh",
			"eighth",
			"ninth",
			"tenth",
		},
		word = false,
		cyclic = true,
	})

	local months = augend.constant.new({
		elements = {
			"January",
			"February",
			"March",
			"April",
			"May",
			"June",
			"July",
			"August",
			"September",
			"October",
			"November",
			"December",
		},
		word = true,
		cyclic = true,
	})

	local groups = {
		default = {
			augend.integer.alias.decimal,
			augend.integer.alias.decimal_int,
			augend.integer.alias.hex,
			augend.date.alias["%Y/%m/%d"],
			augend.constant.alias.en_weekday,
			augend.constant.alias.en_weekday_full,
			ordinal_numbers,
			months,
			augend.constant.alias.bool,
			augend.constant.alias.Bool,
			logical_alias,
		},
		vue = {
			augend.constant.new({ elements = { "let", "const" } }),
			augend.hexcolor.new({ case = "lower" }),
			augend.hexcolor.new({ case = "upper" }),
		},
		typescript = {
			augend.constant.new({ elements = { "let", "const" } }),
		},
		css = {
			augend.hexcolor.new({ case = "lower" }),
			augend.hexcolor.new({ case = "upper" }),
		},
		markdown = {
			augend.constant.new({
				elements = { "[ ]", "[x]" },
				word = false,
				cyclic = true,
			}),
			augend.misc.alias.markdown_header,
		},
		json = {
			augend.semver.alias.semver,
		},
		lua = {
			augend.constant.new({
				elements = { "and", "or" },
				word = true,
				cyclic = true,
			}),
		},
		python = {
			augend.constant.new({
				elements = { "and", "or" },
			}),
		},
	}

	for name, group in pairs(groups) do
		if name ~= "default" then
			vim.list_extend(group, vim.deepcopy(groups.default))
		end
	end

	require("dial.config").augends:register_group(groups)
	vim.g.dials_by_ft = {
		css = "css",
		vue = "vue",
		javascript = "typescript",
		typescript = "typescript",
		typescriptreact = "typescript",
		javascriptreact = "typescript",
		json = "json",
		lua = "lua",
		markdown = "markdown",
		sass = "css",
		scss = "css",
		python = "python",
	}

	local dial = function(kind, mode)
		local group = vim.g.dials_by_ft[vim.bo.filetype] or "default"
		require("dial.map").manipulate(kind, mode, group)
	end

	vim.keymap.set("n", "<C-a>", function()
		dial("increment", "normal")
	end, { desc = "Increment" })

	vim.keymap.set("n", "<C-x>", function()
		dial("decrement", "normal")
	end, { desc = "Decrement" })

	vim.keymap.set("n", "g<C-a>", function()
		dial("increment", "gnormal")
	end, { desc = "Increment" })

	vim.keymap.set("n", "g<C-x>", function()
		dial("decrement", "gnormal")
	end, { desc = "Decrement" })

	vim.keymap.set("x", "<C-a>", function()
		dial("increment", "visual")
	end, { desc = "Increment" })

	vim.keymap.set("x", "<C-x>", function()
		dial("decrement", "visual")
	end, { desc = "Decrement" })

	vim.keymap.set("x", "g<C-a>", function()
		dial("increment", "gvisual")
	end, { desc = "Increment" })

	vim.keymap.set("x", "g<C-x>", function()
		dial("decrement", "gvisual")
	end, { desc = "Decrement" })
end)

Config.on_event({ "BufReadPre", "BufNewFile" }, function()
	vim.pack.add({
		"https://github.com/folke/sidekick.nvim",
		"https://github.com/supermaven-inc/supermaven-nvim",
		"https://github.com/onsails/lspkind.nvim",
	})

	---@module 'supermaven-nvim'
	require("supermaven-nvim").setup({
		disable_inline_completion = not vim.g.ai_cmp,
		ignore_filetypes = { "bigfile", "snacks_input", "snacks_notif" },
		keymaps = {
			accept_suggestion = nil, -- handled by blink.cmp
		},
	})

	require("lspkind").init({
		---@diagnostic disable-next-line: missing-fields
		symbol_map = {
			Supermaven = " ",
		},
	})

	require("sidekick").setup({
		cli = {
			mux = {
				backend = "tmux",
			},
		},
	})

	Config.later(function()
		Snacks.toggle({
			name = "AI",
get = function()
		return vim.g.ai_cmp == true
	end,
	set = function(state)
		vim.g.ai_cmp = state
		require("supermaven-nvim.completion_preview").disable_inline_completion = not state

		local api = require("supermaven-nvim.api")
		if state then
			api.start()
		else
			api.stop()
		end
	end,
		}):map("<leader>uA")
	end)

	-- === KEYMAPS ===
	local set = vim.keymap.set

	set({ "n", "t", "i", "x" }, "<C-.>", function()
		require("sidekick.cli").focus()
	end, { desc = "Sidekick Focus" })
	set("n", "<leader>aa", function()
		require("sidekick.cli").toggle()
	end, { desc = "Sidekick Toggle CLI" })
	set("n", "<leader>as", function()
		require("sidekick.cli").select({ filter = { installed = true } })
	end, { desc = "Select CLI" })
	set("n", "<leader>ad", function()
		require("sidekick.cli").close()
	end, { desc = "Detach a CLI Session" })
	set({ "n", "x" }, "<leader>at", function()
		require("sidekick.cli").send({ msg = "{this}" })
	end, { desc = "Send This" })
	set("n", "<leader>af", function()
		require("sidekick.cli").send({ msg = "{file}" })
	end, { desc = "Send File" })
	set("x", "<leader>av", function()
		require("sidekick.cli").send({ msg = "{selection}" })
	end, { desc = "Send Visual Selection" })
	set({ "n", "x" }, "<leader>ap", function()
		require("sidekick.cli").prompt()
	end, { desc = "Sidekick Select Prompt" })
end)
