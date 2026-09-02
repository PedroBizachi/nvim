Config.later(function()
	vim.pack.add({
		"https://github.com/folke/noice.nvim",
		"https://github.com/MunifTanjim/nui.nvim",
	})

	require("noice").setup({
		cmdline = {
			enabled = true,
			view = "cmdline",
			format = {
				-- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
				-- view: (default is cmdline view)
				-- opts: any options passed to the view
				-- icon_hl_group: optional hl_group for the icon
				-- title: set to anything or empty string to hide
				substitute = { pattern = "^:%s*%%?s/", icon = "󰛔 ", lang = "regex" },
				cmdline = { pattern = "^:", icon = "", lang = "vim" },
				search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
				search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
				filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
				lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
				help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
				input = { view = "cmdline_input", icon = "󰥻 " }, -- Used by input()
				-- lua = false, -- to disable a format, set to `false`
			},
		},
		documentation = {
			opts = {
				border = "none",
			},
		},
		messages = {
			enabled = true,
		},
		lsp = {
			hover = {
				silent = true,
			},
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
			signature = {
				enabled = true,
			},
		},
		presets = {
			bottom_search = true,
			inc_rename = true,
			command_palette = true,
			long_message_to_split = true,
		},
		notify = {
			enabled = false,
		},
		routes = {
			{
				filter = {
					event = "msg_show",
					any = {
						{ find = "%d+L, %d+B" },
						{ find = "; after #%d+" },
						{ find = "; before #%d+" },
					},
				},
				view = "mini",
			},
			{
				filter = { event = "msg_show", kind = "search_count" },
				opts = { skip = true },
			},
			{
				filter = { event = "msg_show", min_height = 10 },
				view = "split",
				opts = { enter = true },
			},
		},
	})

	-- === KEYMAPS ===
	local set = vim.keymap.set

  -- stylua: ignore start
  set("c", "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, { desc = "Redirect Cmdline" })
  set("n", "<leader>snl", function() require("noice").cmd("last") end, { desc = "Last Message" })
  set("n", "<leader>snh", function() require("noice").cmd("history") end, { desc = "Message History" })
  set("n", "<leader>sna", function() require("noice").cmd("all") end, { desc = "All Messages" })
  set("n", "<leader>snd", function() require("noice").cmd("dismiss") end, { desc = "Dismiss Messages" })
  set("n", "<leader>snt", function() require("noice").cmd("pick") end, { desc = "Message Picker" })
  set({ "i", "n", "s" }, "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, { silent = true, expr = true, desc = "Scroll Forward" })
  set({ "i", "n", "s" }, "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, { silent = true, expr = true, desc = "Scroll Backward" })
end)
